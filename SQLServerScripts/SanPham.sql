-- ==========================================
-- BẢNG CHA: SANPHAM (SQL SERVER VERSION)
-- ==========================================

CREATE TABLE SanPham (
    MaSP VARCHAR(8) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL UNIQUE,
    GiaTien DECIMAL(10,2) CHECK (GiaTien > 0),
    MoTa NVARCHAR(255),
    LoaiSP NVARCHAR(50) DEFAULT N'Chưa phân loại'
);

-- TẠO BẢNG RIÊNG ĐỂ THÊM PREFIX
create table sequenceCounter (
	sq_name varchar(50) primary key,
	id int not null,
);
insert into sequenceCounter (sq_name, id)
values ('MaSP', 0);
GO
-- ==========================================
-- PROCEDURE InsertSanPham
-- PREFIX: PRO000001, PRO000002...
-- ==========================================

CREATE OR ALTER PROCEDURE InsertSanPham
    @TenSP      NVARCHAR(150),
    @GiaTien    DECIMAL(12,2),
    @MoTa       NVARCHAR(1000) = NULL,
    @LoaiSP     NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_nextV INT;
    DECLARE @v_newID VARCHAR(8);

    -- Tăng giá trị trong bảng sequenceCounter và lấy giá trị mới
    UPDATE dbo.sequenceCounter
    SET id = id + 1
    WHERE sq_name = 'MaSP';

    -- Lấy giá trị vừa mới tăng
    SELECT @v_nextV = id
    FROM dbo.sequenceCounter
    WHERE sq_name = 'MaSP';

    -- Tạo mã đúng định dạng PRO000001
    SET @v_newID = 'PRO' + RIGHT('00000' + CAST(@v_nextV AS VARCHAR(5)), 5);
    -- Ví dụ: @v_nextV = 1  → PRO000001
    --         @v_nextV = 23 → PRO000023

    -- Chèn vào bảng SanPham
    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@v_newID, @TenSP, @GiaTien, @MoTa, @LoaiSP);

    PRINT 'Thêm sản phẩm thành công! Mã SP: ' + @v_newID;
    SELECT @v_newID AS MaSP_Moi;
END
GO

-- ==========================================
-- CÁC BẢNG CON
-- ==========================================
CREATE TABLE ThucPhamDongHop (
    MaSP VARCHAR(8) PRIMARY KEY,
    ThanhPhan VARCHAR(255),
    HanSuDung DATE,
    NhaSanXuat VARCHAR(100),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE DoGiaDung (
    MaSP VARCHAR(8) PRIMARY KEY,
    ChatLieu VARCHAR(100),
    BaoHanh VARCHAR(50) DEFAULT '12 tháng',
    ThuongHieu VARCHAR(100),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE DoTuoiSong (
    MaSP VARCHAR(8) PRIMARY KEY,
    NhietDoBaoQuan DECIMAL(5,2),
    XuatXu VARCHAR(100),
    NgayNhap DATE,
    HanSuDung DATE,
    CHECK (HanSuDung > NgayNhap),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)
GO
-- ==========================================
-- 3 PROCEDURE THÊM SẢN PHẨM THEO LOẠI
-- ==========================================

-- PROCEDURE 1: ĐỒ TƯƠI SỐNG
CREATE OR ALTER PROCEDURE Add_DoTuoiSong
    @TenSP      NVARCHAR(100),
    @GiaTien    DECIMAL(10,2),
    @MoTa       NVARCHAR(255) = NULL,
    @NhietDo    DECIMAL(5,2),
    @XuatXu     NVARCHAR(100),
    @HanSuDung  DATE               
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    IF @HanSuDung < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR(N'Hạn sử dụng không được nhỏ hơn ngày hiện tại!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    -- Sinh mã PRO000001, PRO000002...
    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    -- Thêm vào bảng cha
    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Đồ tươi sống');

    -- Thêm vào bảng con
    INSERT INTO DoTuoiSong (MaSP, NhietDoBaoQuan, XuatXu, NgayNhap, HanSuDung)
    VALUES (@NewMaSP, @NhietDo, @XuatXu, CAST(GETDATE() AS DATE), @HanSuDung);

    PRINT N'Thêm đồ tươi sống thành công! Mã SP: ' + @NewMaSP;
END
GO

-- PROCEDURE 2: ĐỒ GIA DỤNG
CREATE OR ALTER PROCEDURE Add_DoGiaDung
    @TenSP       NVARCHAR(100),
    @GiaTien     DECIMAL(10,2),
    @MoTa        NVARCHAR(255) = NULL,
    @ChatLieu    NVARCHAR(100),
    @BaoHanh     NVARCHAR(50) = N'12 tháng',
    @ThuongHieu  NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Đồ gia dụng');

    INSERT INTO DoGiaDung (MaSP, ChatLieu, BaoHanh, ThuongHieu)
    VALUES (@NewMaSP, @ChatLieu, @BaoHanh, @ThuongHieu);

    PRINT N'Thêm đồ gia dụng thành công! Mã SP: ' + @NewMaSP;
END
GO

-- PROCEDURE 3: THỰC PHẨM ĐÓNG HỘP
CREATE OR ALTER PROCEDURE Add_ThucPhamDongHop
    @TenSP      NVARCHAR(100),
    @GiaTien    DECIMAL(10,2),
    @MoTa       NVARCHAR(255) = NULL,
    @ThanhPhan  NVARCHAR(255),
    @NhaSX      NVARCHAR(100),
    @HanSuDung  DATE                
AS
BEGIN
    SET NOCOUNT ON;

    IF @GiaTien <= 0
    BEGIN
        RAISERROR(N'Giá tiền phải lớn hơn 0!', 16, 1);
        RETURN;
    END

    IF @HanSuDung < DATEADD(MONTH, 3, CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR(N'Thực phẩm đóng hộp phải có hạn sử dụng ít nhất 3 tháng!', 16, 1);
        RETURN;
    END

    DECLARE @NewMaSP VARCHAR(10);

    UPDATE dbo.sequenceCounter SET id = id + 1 WHERE sq_name = 'MaSP';
    SELECT @NewMaSP = 'PRO' + RIGHT('00000' + CAST(id AS VARCHAR(5)), 5)
    FROM dbo.sequenceCounter WHERE sq_name = 'MaSP';

    INSERT INTO SanPham (MaSP, TenSP, GiaTien, MoTa, LoaiSP)
    VALUES (@NewMaSP, @TenSP, @GiaTien, @MoTa, N'Thực phẩm đóng hộp');

    INSERT INTO ThucPhamDongHop (MaSP, ThanhPhan, HanSuDung, NhaSanXuat)
    VALUES (@NewMaSP, @ThanhPhan, @HanSuDung, @NhaSX);

    PRINT N'Thêm thực phẩm đóng hộp thành công! Mã SP: ' + @NewMaSP;
END
GO

-- ==========================================
-- TEST DỮ LIỆU
-- ==========================================
-- 1. Thêm sản phẩm ĐỒ TƯƠI SỐNG
EXEC Add_DoTuoiSong 
    @TenSP     = N'Thịt bò Úc nhập khẩu',
    @GiaTien   = 150000.00,
    @MoTa      = N'Thịt bò tươi ngon, nhập khẩu trực tiếp từ Úc',
    @NhietDo   = 5.0,
    @XuatXu    = N'Úc',
    @HanSuDung = '2025-11-25';  

-- 2. Thêm sản phẩm ĐỒ GIA DỤNG
EXEC Add_DoGiaDung 
    @TenSP      = N'Bình đun siêu tốc Philips HD4646',
    @GiaTien    = 490000.00,
    @MoTa       = N'Công suất 1.8L, giữ nhiệt tốt, inox 304',
    @ChatLieu   = N'Inox 304',
    @BaoHanh    = N'24 tháng',
    @ThuongHieu = N'Philips';

-- 3. Thêm sản phẩm THỰC PHẨM ĐÓNG HỘP
EXEC Add_ThucPhamDongHop 
    @TenSP     = N'Cá ngừ hộp 3 Miền',
    @GiaTien   = 32000.00,
    @MoTa      = N'Hộp thiếc 150g, ngon tuyệt đối',
    @ThanhPhan = N'Cá ngừ, dầu ăn, muối, gia vị',
    @NhaSX     = N'Công ty Vissan',
    @HanSuDung = '2027-06-30';  

-- 4. Thêm vài sản phẩm KHÁC (không thuộc 3 bảng con – để chứng minh LoaiSP linh hoạt)
EXEC InsertSanPham N'Áo thun cotton Uniqlo', 199000, N'Chất liệu mềm mại, thấm hút tốt', N'Thời trang';
EXEC InsertSanPham N'Túi xách Charles & Keith', 1290000, N'Da PU cao cấp, sang trọng', N'Phụ kiện thời trang';
EXEC InsertSanPham N'Dầu gội Head & Shoulders 850ml', 165000, N'Ngăn gàu hiệu quả', N'Chăm sóc cá nhân';




-- Thêm sản phẩm tươi sống
EXEC Add_DoTuoiSong 'Cà Chua Đà Lạt', 25000.00, 'Cà chua bi Đà Lạt, dùng làm salad', 5.0, 'VN', '2025-11-25';
EXEC Add_DoTuoiSong 'Gạo Thơm', 120000.00, 'Bao 5kg gạo thơm đặc sản', 5.0, 'VN', '2025-11-25';
EXEC Add_DoTuoiSong 'Khoai Tay Đà Lạt', 42000.00, 'Túi 1kg khoai tây vàng tươi', 5.0, 'VN', '2025-11-25';
EXEC Add_DoTuoiSong 'Táo Đỏ Mỹ', 35000.00, 'Táo Galamus New Zealand, ngon ngọt, giòn tan', 5.0, 'VN', '2025-11-25';
EXEC Add_DoTuoiSong 'Thịt Bò Phi Lê', 199000.00, 'Thịt bò Úc cắt lát dày 1.5cm, tươi mới', 5.0, 'VN', '2025-11-25';
EXEC Add_DoTuoiSong 'Trứng Gà Ta', 38000.00, 'Vỉ 10 quả trứng gà ta, đảm bảo chất lượng', 5.0, 'VN', '2025-11-25';

-- Thêm sản phẩm đồ gia dụng
EXEC Add_DoGiaDung 'Kem Đánh Răng', 28000.00, 'Tuýp 180g kem đánh răng tạo bọt', 'không', '12 tháng', 'PS';
EXEC Add_DoGiaDung 'Giày Vệ Sinh', 55000.00, 'Gói lớn 10 cuộn giấy 3 lớp', 'Giấy', '12 tháng', 'GiayTot';

-- Thêm thực phẩm đóng hộp
EXEC Add_ThucPhamDongHop 'Cà Phê Đen', 65000.00, 'Gói 500g cà phê rang xay nguyên chất', 'Cà phê', 'Công ty CaPheDen', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Bánh Mì Sandwich', 18000.00, 'Túi 10 lát bánh mì nguyên cám', 'Bột mì', 'Công ty NewBread', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Đường Cát Trắng', 22500.00, 'Túi 1kg đường tinh luyện', 'Đường', 'Công ty DuongMia', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Nước Mắm Nam Ngư', 45000.00, 'Chai 750ml nước mắm cá cơm', 'Cá cơm, muối', 'Công ty Nuoc Mam Ngon', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Muối I-ốt', 9900.00, 'Gói 500g muối i-ốt', 'Muối, Iot', 'Công ty MuoiBien', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Bia Sài Gòn', 15000.00, 'Lon bia 330ml, uống lạnh ngon hơn', 'Nước, Lúa mạch', 'Công ty Bia So 1', '2026-11-25';
EXEC Add_ThucPhamDongHop 'Sữa Tươi Không Đường', 32000.00, 'Hộp 1 lít sữa tươi thanh trùng', 'Sữa', 'Công ty Sua VN', '2026-11-25';


-- ==========================================
-- KIỂM TRA KẾT QUẢ SIÊU ĐẸP (DÙNG CHO BẢN BÁO CÁO)
-- ==========================================

SELECT *
FROM SanPham 
ORDER BY MaSP;

SELECT * FROM DoTuoiSong;

SELECT * FROM DoGiaDung;

SELECT * FROM ThucPhamDongHop;