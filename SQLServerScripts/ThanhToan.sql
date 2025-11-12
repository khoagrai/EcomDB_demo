CREATE TABLE [ThanhToan] (
    MaThanhToan INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
    UserID VARCHAR(8),
    MaDon VARCHAR(8),
    SoTien DECIMAL(12,2),
    NgayGio DATETIME DEFAULT GETDATE(),
    PhuongThuc NVARCHAR(40),
    GhiChu NVARCHAR(200),
    
    CONSTRAINT CK_ThanhToan_SoTien CHECK (SoTien > 0),
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID),
    FOREIGN KEY (MaDon) REFERENCES [DonHang](MaDon)
);
GO








-- Stored Procedure to insert a new payment record
CREATE PROCEDURE InsertThanhToan (
    @input_MaDon VARCHAR(8),
    @input_PhuongThuc NVARCHAR(40),
    @input_GhiChu NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @v_UserID VARCHAR(8);
    DECLARE @v_SoTien DECIMAL(12,2);
    
    -- 1. Fetch UserID and SoTien from the DonHang table
    SELECT
        @v_UserID = UserID, 
        @v_SoTien = SoTien
    FROM
        [DonHang] DH
    WHERE
        DH.MaDon = @input_MaDon;

    -- Check if the order was found and has a positive amount
    IF @v_UserID IS NULL
    BEGIN
        ;THROW 51000, 'Error: Order ID (MaDon) not found.', 1;
        RETURN;
    END

    -- 2. Insert new payment record
    INSERT INTO [ThanhToan] (UserID, MaDon, SoTien, PhuongThuc, GhiChu) 
    VALUES (@v_UserID, @input_MaDon, @v_SoTien, @input_PhuongThuc, @input_GhiChu);
END
GO







-- Retrieve ThanhToan by MaDon
CREATE PROCEDURE GetThanhToanByMaDon (
    @input_MaDon VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaThanhToan,
        UserID,
        MaDon,
        SoTien,
        NgayGio,
        PhuongThuc,
        GhiChu
    FROM
        [ThanhToan]
    WHERE
        MaDon = @input_MaDon;
END
GO










-- Insert sample payment
EXEC InsertThanhToan @input_MaDon = 'ORD00001', 
                     @input_PhuongThuc = N'Cash', 
                     @input_GhiChu = N'Hello this ghi chu hello';
GO

-- Display results
SELECT * FROM [ThanhToan];
GO