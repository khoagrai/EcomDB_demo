CREATE TABLE Thuoc (
    MaSP VARCHAR(20) NOT NULL,         -- FK -> SanPham
    MaCH VARCHAR(20) NOT NULL,         -- FK -> CuaHang
    SoLuongTonKho INT NOT NULL CHECK (SoLuongTonKho >= 0),
    SoLuongNhap INT NOT NULL CHECK (SoLuongNhap >= 0),

    PRIMARY KEY (MaSP, MaCH),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    FOREIGN KEY (MaCH) REFERENCES CuaHang(MaCH)
);
