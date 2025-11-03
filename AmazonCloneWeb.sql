-- =========================================
-- DATABASE: AmazonCloneWeb (Fixed version)
-- =========================================

IF DB_ID('AmazonCloneWeb') IS NOT NULL
BEGIN
    ALTER DATABASE AmazonCloneWeb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AmazonCloneWeb;
END;
GO

CREATE DATABASE AmazonCloneWeb;
GO
USE AmazonCloneWeb;
GO

-- =========================================
-- 1️⃣ ProductType
-- =========================================
CREATE TABLE ProductType (
    ProductTypeID INT IDENTITY(1,1) PRIMARY KEY,
    ProductTypeName NVARCHAR(100) NOT NULL
);
GO

-- =========================================
-- 2️⃣ Product
-- =========================================
CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL,
    ProductTypeID INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL CHECK (Price >= 0),
    Image NVARCHAR(255),
    Description NVARCHAR(MAX),
    CreateDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductTypeID) REFERENCES ProductType(ProductTypeID)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- =========================================
-- 3️⃣ Customer
-- =========================================
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    [Password] NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100),
    [Address] NVARCHAR(255),
    Phone NVARCHAR(20),
    CreateDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- =========================================
-- 4️⃣ Status
-- =========================================
CREATE TABLE Status (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName NVARCHAR(100) NOT NULL
);
GO

-- =========================================
-- 5️⃣ Order
-- =========================================
CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) DEFAULT 0 CHECK (TotalAmount >= 0),
    StatusID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (StatusID) REFERENCES Status(StatusID)
);
GO

-- =========================================
-- 6️⃣ OrderDetails
-- =========================================
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

-- =========================================
-- 7️⃣ Favorite
-- =========================================
CREATE TABLE Favorite (
    FavoriteID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT UQ_Favorite UNIQUE (CustomerID, ProductID)
);
GO

-- =========================================
-- 8️⃣ Department
-- =========================================
CREATE TABLE Department (
    DepartmentID NVARCHAR(10) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
);
GO

-- =========================================
-- 9️⃣ Staff
-- =========================================
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    StaffName NVARCHAR(100) NOT NULL,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    [Password] NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    IsActive BIT DEFAULT 1
);
GO

-- =========================================
-- 🔟 Delegation
-- =========================================
CREATE TABLE Delegation (
    DelegationID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    DepartmentID NVARCHAR(10) NOT NULL,
    AssignDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- =========================================
-- 1️⃣1️⃣ WebSite
-- =========================================
CREATE TABLE WebSite (
    WebSiteID INT IDENTITY(1,1) PRIMARY KEY,
    PageName NVARCHAR(100) NOT NULL,
    PageURL NVARCHAR(255) NOT NULL
);
GO

-- =========================================
-- 1️⃣2️⃣ [Authorization]
-- =========================================
CREATE TABLE [Authorization] (
    AuthorizationID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID NVARCHAR(10) NOT NULL,
    WebSiteID INT NOT NULL,
    CanRead BIT DEFAULT 1,
    CanWrite BIT DEFAULT 0,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (WebSiteID) REFERENCES WebSite(WebSiteID)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

-- =========================================
-- 1️⃣3️⃣ View
-- =========================================
CREATE VIEW vOrderDetails AS
SELECT 
    od.OrderDetailID,
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS Total,
    o.OrderDate,
    s.StatusName
FROM OrderDetails od
JOIN [Order] o ON od.OrderID = o.OrderID
JOIN Customer c ON o.CustomerID = c.CustomerID
JOIN Product p ON od.ProductID = p.ProductID
JOIN Status s ON o.StatusID = s.StatusID;
GO

-- =========================================
-- 1️⃣4️⃣ INSERT DATA
-- =========================================

-- ProductType
INSERT INTO ProductType (ProductTypeName) VALUES
(N'Quần áo'), (N'Giày dép'), (N'Điện tử'), (N'Đồ gia dụng'), (N'Thể thao');

-- Product
INSERT INTO Product (ProductName, ProductTypeID, Price, Image, Description)
VALUES
(N'Áo thun nam basic', 1, 199000, 'shirt1.jpg', N'Áo thun cotton thoáng mát.'),
(N'Áo hoodie thể thao', 1, 349000, 'hoodie1.jpg', N'Hoodie nỉ unisex.'),
(N'Giày thể thao Nike Air', 2, 1499000, 'nike_air.jpg', N'Giày chạy bộ chính hãng.'),
(N'Bình đun siêu tốc', 4, 399000, 'kettle.jpg', N'Bình đun nước inox 2L.'),
(N'Tai nghe Bluetooth', 3, 599000, 'headphone.jpg', N'Tai nghe không dây âm thanh sống động.');

-- Customer
INSERT INTO Customer (CustomerName, Username, [Password], Email, [Address], Phone)
VALUES
(N'Nguyễn Văn A', 'tomy123', '123456', 'tomy@gmail.com', N'Hà Nội', '0901000001'),
(N'Trần Thị B', 'user1', '123456', 'user1@gmail.com', N'Hồ Chí Minh', '0901000002'),
(N'Lê Văn C', 'nhom7', '123456', 'nhom7@gmail.com', N'Đà Nẵng', '0901000003');

-- Status
INSERT INTO Status (StatusName)
VALUES (N'Chờ xử lý'), (N'Đang giao hàng'), (N'Hoàn tất'), (N'Hủy đơn');

-- Order
INSERT INTO [Order] (CustomerID, OrderDate, TotalAmount, StatusID)
VALUES
(1, GETDATE(), 1698000, 3),
(2, GETDATE(), 399000, 1),
(3, GETDATE(), 1499000, 2);

-- OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(1, 1, 2, 199000),
(1, 3, 1, 1499000),
(2, 4, 1, 399000),
(3, 3, 1, 1499000);

-- Favorite
INSERT INTO Favorite (CustomerID, ProductID)
VALUES (1, 3), (1, 1), (2, 4), (3, 5);

-- Department
INSERT INTO Department (DepartmentID, DepartmentName)
VALUES
('BGD', N'Ban giám đốc'),
('PKD', N'Phòng kinh doanh'),
('PKT', N'Phòng kế toán'),
('PNS', N'Phòng nhân sự');

-- Staff
INSERT INTO Staff (StaffName, Username, [Password], Email, Phone)
VALUES
(N'Nguyễn Quản Trị', 'admin', 'admin123', 'admin@amazonclone.com', '0912000001'),
(N'Lê Kinh Doanh', 'sales1', '123456', 'sales1@amazonclone.com', '0912000002'),
(N'Trần Kế Toán', 'account1', '123456', 'account1@amazonclone.com', '0912000003');

-- Delegation
INSERT INTO Delegation (StaffID, DepartmentID)
VALUES (1, 'BGD'), (2, 'PKD'), (3, 'PKT');

-- WebSite
INSERT INTO WebSite (PageName, PageURL)
VALUES
(N'Trang chủ', '/index.html'),
(N'Sản phẩm', '/product.html'),
(N'Giỏ hàng', '/cart.html'),
(N'Đơn hàng', '/order.html'),
(N'Quản trị', '/admin.html');

-- [Authorization]
INSERT INTO [Authorization] (DepartmentID, WebSiteID, CanRead, CanWrite)
VALUES
('BGD', 5, 1, 1),
('PKD', 2, 1, 1),
('PKD', 4, 1, 1),
('PKT', 4, 1, 0),
('PNS', 5, 1, 0);
GO

-- ✅ Test view
SELECT * FROM vOrderDetails;
GO
