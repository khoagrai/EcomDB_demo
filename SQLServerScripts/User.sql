CREATE TABLE [User] (
    UserID VARCHAR(8) PRIMARY KEY, 
    Password NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10) NOT NULL, 
    SoDienThoai VARCHAR(20) UNIQUE, 
    Email VARCHAR(100) NOT NULL UNIQUE,
    
    -- Constraint to enforce 'Nam' or 'Nu' for GioiTinh
    CONSTRAINT CK_User_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu'))
);

-- Sequence object to manage the auto-incrementing number part of UserID
CREATE SEQUENCE UserID_Seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    CACHE 50;
GO




-- Insert User

CREATE PROCEDURE InsertUser (
    @p_Password NVARCHAR(255),
    @p_HoTen NVARCHAR(100),
    @p_GioiTinh NVARCHAR(10),
    @p_SoDienThoai VARCHAR(20),
    @p_Email VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON; -- Prevents sending rowcount message

    DECLARE @v_NextValue INT;
    DECLARE @v_NewUserID VARCHAR(8);

    -- 1. Get the next value from the sequence
    SET @v_NextValue = NEXT VALUE FOR UserID_Seq;
    
    -- 2. Format new ID (prefix 'USE' + 5 digits)
    SET @v_NewUserID = 'USE' + FORMAT(@v_NextValue, 'D5'); 

    -- 3. Insert the new user record
    INSERT INTO [User] (UserID, Password, HoTen, GioiTinh, SoDienThoai, Email)
    VALUES (@v_NewUserID, @p_Password, @p_HoTen, @p_GioiTinh, @p_SoDienThoai, @p_Email);
    
    -- Return generated UserID
    SELECT @v_NewUserID AS ReturnNewUserID;
END;
GO







-- Insert sample data

EXEC InsertUser N'hashed_pass_a', N'Nguyen Van A', N'Nam', '0901234567', 'nguyenvana@email.com';
EXEC InsertUser N'hashed_pass_b', N'Tran Thi B', N'Nu', '0917654321', 'tranthib@email.com';
EXEC InsertUser N'hashed_pass_c', N'Le Minh Canh', N'Nam', '0988777666', 'leminhc@email.com';
EXEC InsertUser N'hashed_pass_d', N'Pham Thu Hang', N'Nu', '0399888777', 'phthuha@email.com';
EXEC InsertUser N'hashed_pass_e', N'Vu Dinh Dung', N'Nam', '0861112222', 'vudung@email.com';
EXEC InsertUser N'hash_f', N'Hoang Van F', N'Nam', '0812345678', 'hoangf@email.com';
EXEC InsertUser N'hash_g', N'Ngo Thi G', N'Nu', '0937654321', 'ngog@email.com';
EXEC InsertUser N'hash_h', N'Dao Quoc H', N'Nam', '0978888777', 'daoh@email.com';
EXEC InsertUser N'hash_i', N'Lam Khanh I', N'Nu', '0389999000', 'lami@email.com';
EXEC InsertUser N'hash_j', N'Mai Dinh J', N'Nam', '0891113333', 'maij@email.com';
EXEC InsertUser N'hash_k', N'Phan Thi K', N'Nu', '0945556666', 'phank@email.com';
EXEC InsertUser N'hash_l', N'Tran Ba L', N'Nam', '0923456789', 'tranl@email.com';
EXEC InsertUser N'hash_m', N'Vo Thu M', N'Nu', '0367890123', 'vom@email.com';
EXEC InsertUser N'hash_n', N'Bui Duc N', N'Nam', '0778889990', 'buin@email.com';
EXEC InsertUser N'hash_o', N'Do Lan Oanh', N'Nu', '0961234567', 'doanh@email.com';

SELECT * FROM [User];