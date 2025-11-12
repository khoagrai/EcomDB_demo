CREATE TABLE [DiaChi] (
    UserID VARCHAR(8) PRIMARY KEY, 
    TinhThanh NVARCHAR(50),
    PhuongXa NVARCHAR(50),
    DuongVaSoNha NVARCHAR(200),
    
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO







-- Retrieve address by UserID
CREATE PROCEDURE GetDiaChiByUserID (
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        UserID,
        TinhThanh,
        PhuongXa,
        DuongVaSoNha
    FROM
        [DiaChi]
    WHERE
        UserID = @input_UserID;
END
GO








-- Inserting sample address data for UserIDs USE00001 to USE00010

INSERT INTO [DiaChi] (UserID, TinhThanh, PhuongXa, DuongVaSoNha) VALUES
('USE00001', N'Thành phố Hà Nội', N'Phường ABC', N'Số 10, ngõ 175, Giải Phóng'),
('USE00002', N'Thành phố Hồ Chí Minh', N'Phường 12', N'123 Đường Nguyễn Huệ, Quận 1'),
('USE00003', N'Thành phố Đà Nẵng', N'Phường Hải Châu I', N'45 Đường Bạch Đằng'),
('USE00004', N'Tỉnh Thừa Thiên Huế', N'Phường Vĩnh Ninh', N'200 Đường Hùng Vương'),
('USE00005', N'Thành phố Hải Phòng', N'Phường Máy Tơ', N'Lô 5, Khu đô thị Vinhomes'),
('USE00006', N'Tỉnh Cần Thơ', N'Phường Cái Khế', N'Số 88, Đường 30 Tháng 4'),
('USE00007', N'Tỉnh Quảng Ninh', N'Phường Bãi Cháy', N'1A Đường Hạ Long'),
('USE00008', N'Tỉnh Khánh Hòa', N'Phường Lộc Thọ', N'79 Đường Trần Phú, Nha Trang'),
('USE00009', N'Tỉnh Đồng Nai', N'Phường Trảng Dài', N'Khu phố 4, Đường Nguyễn Ái Quốc'),
('USE00010', N'Tỉnh Bình Dương', N'Phường Thuận Giao', N'Số 33, Đại lộ Bình Dương');
GO

-- Display results
SELECT * FROM [DiaChi];
GO

