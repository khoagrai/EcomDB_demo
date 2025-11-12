-- Sequence for generating MaGioHang
CREATE SEQUENCE MaGioHang_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE  
    CACHE 50;
GO

-- GioHang Table
CREATE TABLE [GioHang] (
    MaGioHang VARCHAR(8) PRIMARY KEY, 
    UserID VARCHAR(8) NOT NULL UNIQUE, 
    TongSoTien DECIMAL(12, 2) DEFAULT 0.00,
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

-- GioHangItem Table
CREATE TABLE [GioHangItem] (
    MaGioHang VARCHAR(8) NOT NULL,
    MaSP VARCHAR(8) NOT NULL,
    SoLuong INT NOT NULL,

    PRIMARY KEY (MaGioHang, MaSP),
    CONSTRAINT CK_GioHangItem_SoLuong CHECK (SoLuong > 0), 
    
    FOREIGN KEY (MaGioHang) REFERENCES [GioHang](MaGioHang),
    FOREIGN KEY (MaSP) REFERENCES [SanPham](MaSP) 
);
GO









-- Insert new GioHang
CREATE PROCEDURE InsertGioHang (
    @p_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_NextValue INT;
    DECLARE @v_NewMaGioHang VARCHAR(8);
    
    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR MaGioHang_Seq;
    
    -- 2. Format new ID (prefix 'CAR' + 5 digits)
    SET @v_NewMaGioHang = 'CAR' + FORMAT(@v_NextValue, 'D5');
    
    -- 3. Insert the new cart record
    INSERT INTO [GioHang] (MaGioHang, UserID)
    VALUES (@v_NewMaGioHang, @p_UserID);
    
    -- Return generated Cart ID
    SELECT @v_NewMaGioHang AS ReturnNewCartID;
END;
GO









-- Function to calculate the total price for a given cart
CREATE FUNCTION ufn_CalculateCartTotal (@p_MaGioHang VARCHAR(8))
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @v_Total DECIMAL(12, 2);

    SELECT 
        @v_Total = SUM(GI.SoLuong * P.GiaTien)
    FROM 
        [GioHangItem] GI
    INNER JOIN 
        [SanPham] P ON GI.MaSP = P.MaSP
    WHERE 
        GI.MaGioHang = @p_MaGioHang;

    RETURN ISNULL(@v_Total, 0.00); 
END;
GO









-- Trigger to update TongSoTien in GioHang after changes to GioHangItem
CREATE TRIGGER trg_UpdateGioHangTotal
ON [GioHangItem]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Determine the MaGioHang values affected by the operation
    DECLARE @AffectedCartIDs TABLE (MaGioHang VARCHAR(8) PRIMARY KEY);
    
    INSERT INTO @AffectedCartIDs (MaGioHang)
    SELECT MaGioHang FROM INSERTED
    UNION
    SELECT MaGioHang FROM DELETED;

    -- Update the TongSoTien for all affected carts using the UDF
    UPDATE GH
    SET TongSoTien = dbo.ufn_CalculateCartTotal(AC.MaGioHang)
    FROM [GioHang] GH
    INNER JOIN @AffectedCartIDs AC ON GH.MaGioHang = AC.MaGioHang;
END;
GO












-- Creating 6 Carts
EXEC InsertGioHang 'USE00001';
EXEC InsertGioHang 'USE00002';
EXEC InsertGioHang 'USE00003';
EXEC InsertGioHang 'USE00004';
EXEC InsertGioHang 'USE00005';
EXEC InsertGioHang 'USE00006';
GO

-- Cart 1 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00001', 'PRO00001', 5),
('CAR00001', 'PRO00003', 1), 
('CAR00001', 'PRO00005', 3), 
('CAR00001', 'PRO00012', 1); 
GO

-- Cart 2 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00002', 'PRO00002', 1), 
('CAR00002', 'PRO00004', 2), 
('CAR00002', 'PRO00008', 1),
('CAR00002', 'PRO00007', 1);
GO

-- Cart 3 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00003', 'PRO00006', 2),
('CAR00003', 'PRO00009', 1),
('CAR00003', 'PRO00010', 1),
('CAR00003', 'PRO00013', 6);
GO

-- Cart 4 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00004', 'PRO00001', 1),
('CAR00004', 'PRO00004', 1),
('CAR00004', 'PRO00011', 1),
('CAR00004', 'PRO00014', 2);
GO

-- Cart 5 (4 items)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00005', 'PRO00015', 1), 
('CAR00005', 'PRO00014', 1),
('CAR00005', 'PRO00010', 1),
('CAR00005', 'PRO00008', 1); 
GO

-- Cart 6 (1 item)
INSERT INTO [GioHangItem] (MaGioHang, MaSP, SoLuong) VALUES 
('CAR00006', 'PRO00003', 1);
GO

-- Display results
SELECT * FROM [GioHang];
SELECT * FROM [GioHangItem];