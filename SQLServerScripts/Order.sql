-- Sequence object for generating MaDon
CREATE SEQUENCE MaDonHang_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE  
    CACHE 50;
GO

-- DonHang Table
CREATE TABLE [DonHang] (
    MaDon VARCHAR(8) PRIMARY KEY,
    UserID VARCHAR(8) NOT NULL,
    DiaChi NVARCHAR(255) NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT N'Pending',
    SoTien DECIMAL(12 , 2 ) DEFAULT 0.00,
    NgayDatHang DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (UserID) REFERENCES [User] (UserID),
    
    CONSTRAINT CK_DonHang_TrangThai CHECK (TrangThai IN (
        N'Pending', 
        N'Processing',
        N'Shipping',
        N'Delivered',
        N'Cancelled'
    ))
);
GO

-- DonHangItem Table
CREATE TABLE [DonHangItem] (
    MaDon VARCHAR(8) NOT NULL,
    MaSP VARCHAR(8) NOT NULL,
    SoLuong INT NOT NULL,
    GiaLucBan DECIMAL(10, 2) NOT NULL, -- Price at time of order

    PRIMARY KEY (MaDon, MaSP),
    CONSTRAINT CK_DonHangItem_SoLuong CHECK (SoLuong > 0), 
    CONSTRAINT CK_DonHangItem_GiaLucBan CHECK (GiaLucBan >= 0),
    
    FOREIGN KEY (MaDon) REFERENCES [DonHang](MaDon),
    FOREIGN KEY (MaSP) REFERENCES [SanPham](MaSP)
);
GO








-- Stored Procedure to insert a new order (DonHang)
CREATE PROCEDURE InsertDonHang (
    @p_UserID VARCHAR(8),
    @p_DiaChi NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaDon VARCHAR(8);
    
    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR MaDonHang_Seq;
    
    -- 2. Format new ID (prefix 'ORD' + 5 digits)
    SET @v_NewMaDon = 'ORD' + FORMAT(@v_NextValue, 'D5');
    
    -- 3. Insert the new order record (TrangThai and SoTien default automatically)
    INSERT INTO [DonHang] (MaDon, UserID, DiaChi)
    VALUES (@v_NewMaDon, @p_UserID, @p_DiaChi);

    -- Return the newly generated Order ID
    SELECT @v_NewMaDon AS NewOrderID;
END;
GO










-- Function to calculate the total price for a given order (MaDon)
CREATE FUNCTION ufn_CalculateOrderTotal (@p_MaDon VARCHAR(8))
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @v_Total DECIMAL(12, 2);

    SELECT 
        @v_Total = SUM(DI.SoLuong * DI.GiaLucBan)
    FROM 
        [DonHangItem] DI
    WHERE 
        DI.MaDon = @p_MaDon;

    RETURN ISNULL(@v_Total, 0.00);
END;
GO





















-- Insert one item into one DonHang
CREATE PROCEDURE InsertDonHangItem (
    @p_MaDon VARCHAR(8), 
    @p_MaSP VARCHAR(8), 
    @p_SoLuong INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_GiaLucBan DECIMAL(10, 2); 
    
    -- 1. Get GiaTien from SanPham
    SELECT @v_GiaLucBan = GiaTien
    FROM SanPham
    WHERE MaSP = @p_MaSP;

    -- Check if price was found
    IF @v_GiaLucBan IS NULL 
    BEGIN
        -- Raise an error if product doesn't exist
        ;THROW 51000, 'Error: Product ID (MaSP) not found in SanPham table.', 1;
        RETURN;
    END
    
    -- Check if SoLuong is valid before insert
    IF @p_SoLuong <= 0
    BEGIN
        ;THROW 51001, 'Error: SoLuong must be greater than zero.', 1;
        RETURN;
    END

    -- 2. Insert the new order item
    INSERT INTO [DonHangItem] (MaDon, MaSP, SoLuong, GiaLucBan)
    VALUES (@p_MaDon, @p_MaSP, @p_SoLuong, @v_GiaLucBan);
END;
GO












-- Trigger to enforce valid status change on DonHang
CREATE TRIGGER trg_EnforceTrangThaiOrder
ON [DonHang]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if was actually changed
    IF UPDATE(TrangThai)
    BEGIN
        -- Find any rows where the old status (DELETED) and new status (INSERTED) 
        -- represent an invalid change according to the business rules.
        IF EXISTS (
            SELECT 1
            FROM DELETED d
            INNER JOIN INSERTED i ON d.MaDon = i.MaDon
            WHERE 
                (d.TrangThai = N'Pending' AND i.TrangThai NOT IN (N'Processing', N'Cancelled')) OR
                (d.TrangThai = N'Processing' AND i.TrangThai NOT IN (N'Shipping', N'Cancelled')) OR
                (d.TrangThai = N'Shipping' AND i.TrangThai <> N'Delivered') OR
                -- No changes for Delivered or Cancelled
                (d.TrangThai IN (N'Delivered', N'Cancelled'))
        )
        BEGIN
            -- Throw an error for the transaction and rollback
            ;THROW 50001, 'Invalid order status transition. Status must follow: Pending -> Processing -> Shipping -> Delivered, or Cancelled.', 1;
            RETURN;
        END
    END
END;
GO













-- Trigger to update SoTien in DonHang after changes to DonHangItem
CREATE TRIGGER trg_UpdateDonHangTotal
ON [DonHangItem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Determine the MaDon values affected by the operation
    DECLARE @AffectedOrderIDs TABLE (MaDon VARCHAR(8) PRIMARY KEY);
    
    INSERT INTO @AffectedOrderIDs (MaDon)
    SELECT MaDon FROM INSERTED
    UNION
    SELECT MaDon FROM DELETED;

    -- Update the SoTien for all affected orders using the UDF
    UPDATE DH
    SET SoTien = dbo.ufn_CalculateOrderTotal(AO.MaDon)
    FROM [DonHang] DH
    INNER JOIN @AffectedOrderIDs AO ON DH.MaDon = AO.MaDon;
END;
GO















-- 6 Inital Orders
EXEC InsertDonHang 'USE00001', N'123 Phan Van Tri, Q. Go Vap';
EXEC InsertDonHang 'USE00002', N'45 Tran Hung Dao, Q. 1';
EXEC InsertDonHang 'USE00003', N'789 Le Loi, Q. Binh Thanh';
EXEC InsertDonHang 'USE00004', N'50 Dien Bien Phu, Q. 3';
EXEC InsertDonHang 'USE00005', N'30 Vo Thi Sau, Q. Tan Binh';
EXEC InsertDonHang 'USE00006', N'10 Nguyen Hue, Q. 1';
GO

-- Order 1 (5 items)
EXEC InsertDonHangItem 'ORD00001', 'PRO00001', 3;
EXEC InsertDonHangItem 'ORD00001', 'PRO00004', 1;
EXEC InsertDonHangItem 'ORD00001', 'PRO00006', 2;
EXEC InsertDonHangItem 'ORD00001', 'PRO00009', 1;
EXEC InsertDonHangItem 'ORD00001', 'PRO00011', 1;
GO

-- Order 2 (5 items)
EXEC InsertDonHangItem 'ORD00002', 'PRO00002', 2;
EXEC InsertDonHangItem 'ORD00002', 'PRO00005', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00013', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00008', 1;
EXEC InsertDonHangItem 'ORD00002', 'PRO00014', 1;
GO

-- Order 3 (5 items)
EXEC InsertDonHangItem 'ORD00003', 'PRO00001', 10;
EXEC InsertDonHangItem 'ORD00003', 'PRO00002', 3;
EXEC InsertDonHangItem 'ORD00003', 'PRO00003', 5;
EXEC InsertDonHangItem 'ORD00003', 'PRO00007', 1;
EXEC InsertDonHangItem 'ORD00003', 'PRO00015', 1;
GO

-- Order 4 (5 items)
EXEC InsertDonHangItem 'ORD00004', 'PRO00003', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00007', 2;
EXEC InsertDonHangItem 'ORD00004', 'PRO00012', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00010', 1;
EXEC InsertDonHangItem 'ORD00004', 'PRO00011', 1;
GO

-- Order 5 (5 items)
EXEC InsertDonHangItem 'ORD00005', 'PRO00004', 3;
EXEC InsertDonHangItem 'ORD00005', 'PRO00006', 1;
EXEC InsertDonHangItem 'ORD00005', 'PRO00009', 2;
EXEC InsertDonHangItem 'ORD00005', 'PRO00013', 1;
EXEC InsertDonHangItem 'ORD00005', 'PRO00015', 1;
GO

-- Order 6 (1 item)
EXEC InsertDonHangItem 'ORD00006', 'PRO00003', 1; 
GO

SELECT * FROM [DonHang];
SELECT * FROM [DonHangItem];
GO