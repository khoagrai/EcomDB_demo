CREATE TABLE NhanVienGiaoHang (
    CCCD VARCHAR(20) NOT NULL PRIMARY KEY,
    MaDH VARCHAR(20) NOT NULL,                 -- FK -> DonHang
    HoTen NVARCHAR(50),
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    NgayBatDauLam DATE,

    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDon)
);
