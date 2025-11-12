-- Retrieves a summary list of all carts associated with a user.
CREATE PROCEDURE GetMaGioHangByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaGioHang,
        UserID,
        TongSoTien
    FROM
        [GioHang]
    WHERE
        UserID = @input_UserID;
END
GO

-- Procedure to retrieve all items and product details
-- in a user's shopping cart using their MaGioHang.
CREATE PROCEDURE GetCartContentByMaGioHang (
    @input_MaGioHang VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        GH.MaGioHang,
        GHI.MaSP,
        S.TenSP AS ProductName,
        S.GiaTien AS CurrentPrice,
        GHI.SoLuong AS Quantity,
        (S.GiaTien * GHI.SoLuong) AS TotalItemPrice
    FROM
        [GioHang] GH
    INNER JOIN
        [GioHangItem] GHI ON GH.MaGioHang = GHI.MaGioHang
    INNER JOIN
        [SanPham] S ON GHI.MaSP = S.MaSP
    WHERE
        GH.MaGioHang = @input_MaGioHang;
END
GO

-- Procedure to retrieve all items and product details 
-- in a user's shopping cart using their UserID.
CREATE PROCEDURE GetCartContentByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        GH.MaGioHang,
        GHI.MaSP,
        S.TenSP AS ProductName,
        S.GiaTien AS CurrentPrice,
        GHI.SoLuong AS Quantity,
        (S.GiaTien * GHI.SoLuong) AS TotalItemPrice
    FROM
        [GioHang] GH
    INNER JOIN
        [GioHangItem] GHI ON GH.MaGioHang = GHI.MaGioHang
    INNER JOIN
        [SanPham] S ON GHI.MaSP = S.MaSP
    WHERE
        GH.UserID = @input_UserID;
END
GO











-- Retrieves a summary list of all orders placed by a user.
CREATE PROCEDURE GetOrderListByUserID(
    @input_UserID VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        MaDon,
        NgayDatHang AS OrderDate,
        SoTien AS OrderTotal,
        TrangThai AS OrderStatus,
        DiaChi AS ShippingAddress
    FROM
        [DonHang]
    WHERE
        UserID = @input_UserID
    ORDER BY
        NgayDatHang DESC;
END
GO

-- Retrieves the detailed line items and product info for an order.
CREATE PROCEDURE GetOrderContentByMaDon(
    @input_MaDon VARCHAR(8)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        DHI.MaSP,
        S.TenSP AS ProductName,
        DHI.GiaLucBan AS PriceAtOrder,
        DHI.SoLuong AS Quantity,
        (DHI.GiaLucBan * DHI.SoLuong) AS TotalLineItemPrice
    FROM
        [DonHangItem] DHI
    INNER JOIN
        [SanPham] S ON DHI.MaSP = S.MaSP
    WHERE
        DHI.MaDon = @input_MaDon
    ORDER BY
        DHI.SoLuong DESC;
END
GO










-- USP GET TOP PURCHASED ITEMS BY A USER
CREATE PROCEDURE GetTopPurchasedItems (
    @p_UserID VARCHAR(8),
    @p_Limit INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Validation of input parameters (Check if UserID exists)
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE UserID = @p_UserID)
    BEGIN
        -- Throw an error message instead of returning a result set with an error message
        SELECT CAST('Error: UserID does not exist.' AS NVARCHAR(100)) AS ErrorMessage;
        RETURN;
    END

    -- 2. Execute the required query
    SELECT TOP (@p_Limit)
        P.TenSP, 
        SUM(DI.SoLuong) AS TotalPurchased,
        SUM(DI.SoLuong * P.GiaTien) AS TotalValue 
    FROM 
        [DonHang] DH
    INNER JOIN 
        [DonHangItem] DI ON DH.MaDon = DI.MaDon
    INNER JOIN 
        [SanPham] P ON DI.MaSP = P.MaSP 
    WHERE 
        DH.UserID = @p_UserID
    GROUP BY 
        DI.MaSP, P.TenSP 
    ORDER BY
        SUM(DI.SoLuong) DESC;
END
GO