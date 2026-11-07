/* =====================================================================
   NovaStore E-Ticaret Veri Yönetim Sistemi
   Hazırlayan : Muhammed Enis Ermiş
   Veritabanı : SQL Server 2022 (T-SQL)
   ===================================================================== */


/* =====================================================================
   BÖLÜM 1: VERİ TABANI TASARIMI (DDL)
   ===================================================================== */

-- 1. Veri tabanı oluşturma
-- Hocam dosyayı tekrar tekrar çalıştırırken hata almamak için varsa önce siliyorum
USE master;
GO

IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

-- Kolonlar yönergede varchar istendiği için Türkçe karakterler (ş, ğ, ı, İ) bozulmasın diye
-- veri tabanını Türkçe collation ile oluşturdum
CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO

-- 2. Tablolar
-- Önce başka tabloya bağlı olmayan ana tabloları (Categories, Customers),
-- sonra foreign key ile onlara bağlanan tabloları oluşturdum

-- A. Categories (Kategoriler)
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- C. Customers (Müşteriler)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) UNIQUE   -- aynı e-posta ile iki müşteri olamaz
);
GO

-- B. Products (Ürünler)
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT DEFAULT 0,       -- stok girilmezse 0 kabul ediliyor
    CategoryID  INT,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- D. Orders (Siparişler)
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT,
    OrderDate   DATETIME DEFAULT GETDATE(),   -- tarih girilmezse siparişin verildiği an yazılıyor
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- E. OrderDetails (Sipariş Detayları - Ara Tablo)
-- Bir siparişte birden fazla ürün, bir ürün de birden fazla siparişte olabildiği için
-- çoka çok ilişkiyi bu ara tabloyla kurdum
CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT,
    ProductID INT,
    Quantity  INT,
    CONSTRAINT FK_OrderDetails_Orders   FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO


/* =====================================================================
   BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
   ===================================================================== */

-- Görev 1: 5 adet kategori
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');
GO

-- Görev 2: Her kategoriden ürün, burada 12 ürün (aşağıda stoksuz eklediğimle toplam 13)
-- Bazı ürünlerin stoğunu bilerek 20'nin altında tuttum, 1. soruda listelensin diye
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kablosuz Kulaklık',      1299.90, 45, 1),
('Akıllı Saat',            3499.00, 12, 1),
('Bluetooth Hoparlör',      899.50,  8, 1),
('Erkek Kapüşonlu Sweatshirt', 549.90, 60, 2),
('Kadın Kot Ceket',         899.00, 15, 2),
('Spor Ayakkabı',          1799.00, 25, 2),
('Suç ve Ceza',             149.90, 80, 3),
('Simyacı',                 119.00,  5, 3),
('Nemlendirici Krem',       249.90, 35, 4),
('Parfüm 50 ml',            899.90, 18, 4),
('Kahve Makinesi',         2599.00, 10, 5),
('Pamuk Nevresim Takımı',   749.00, 30, 5);
GO

-- Stock kolonunu boş geçince varsayılan 0 değerinin geldiğini görmek için stoksuz bir ürün
INSERT INTO Products (ProductName, Price, CategoryID) VALUES
('Masa Lambası', 459.00, 5);
GO

-- Görev 3: 6 müşteri
-- Zeynep Arslan'ın hiç siparişi yok, 5. soruda LEFT JOIN ile 0 ciro olarak görünüyor
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz',  'İstanbul', 'ahmet.yilmaz@mail.com'),
('Ayşe Demir',    'Ankara',   'ayse.demir@mail.com'),
('Mehmet Kaya',   'İzmir',    'mehmet.kaya@mail.com'),
('Elif Şahin',    'Bursa',    'elif.sahin@mail.com'),
('Can Öztürk',    'Antalya',  'can.ozturk@mail.com'),
('Zeynep Arslan', 'Eskişehir','zeynep.arslan@mail.com');
GO

-- Görev 4: Farklı tarihlerde 10 sipariş
-- TotalAmount'u elle yazmak yerine aşağıda sipariş detaylarından hesaplatıyorum,
-- o yüzden ilk başta 0 giriyorum
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-08-14 10:25', 0),
(2, '2026-08-29 16:40', 0),
(1, '2026-09-10 21:05', 0),
(3, '2026-09-18 12:15', 0),
(4, '2026-09-30 09:50', 0),
(5, '2026-10-07 19:30', 0),
(2, '2026-10-15 14:10', 0),
(3, '2026-10-24 11:45', 0),
(1, '2026-11-01 20:20', 0);
GO

-- Son siparişte tarih vermedim, OrderDate varsayılan olarak GETDATE() ile bugünün tarihini alıyor
INSERT INTO Orders (CustomerID, TotalAmount) VALUES (4, 0);
GO

-- Sipariş detayları
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),   -- Ahmet: kulaklık
(1, 7, 2),   -- Ahmet: Suç ve Ceza
(2, 9, 2),
(2, 10, 1),
(3, 2, 1),   -- Ahmet: akıllı saat
(4, 4, 2),
(4, 6, 1),
(5, 11, 1),
(5, 12, 1),
(6, 3, 2),
(6, 8, 1),
(7, 5, 1),
(8, 7, 3),
(8, 8, 2),
(9, 6, 1),   -- Ahmet: spor ayakkabı
(9, 9, 1),
(10, 1, 1),
(10, 10, 1);
GO

-- Her siparişin toplam tutarını, içindeki ürünlerin adet x fiyat toplamı olarak güncelliyorum
UPDATE o
SET o.TotalAmount = t.Toplam
FROM Orders o
JOIN (
    SELECT od.OrderID, SUM(od.Quantity * p.Price) AS Toplam
    FROM OrderDetails od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY od.OrderID
) t ON t.OrderID = o.OrderID;
GO


/* =====================================================================
   BÖLÜM 3: SORGULAMA VE ANALİZ (DQL - SELECT ve JOIN)
   ===================================================================== */

-- Soru 1: Stoğu 20'den az olan ürünler, stoğa göre azalan sırada
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- Soru 2: Hangi müşteri hangi tarihte sipariş vermiş?
SELECT c.FullName    AS MusteriAdi,
       c.City        AS Sehir,
       o.OrderDate   AS SiparisTarihi,
       o.TotalAmount AS ToplamTutar
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;
GO

-- Soru 3: Ahmet Yılmaz'ın aldığı ürünler, fiyatları ve kategorileri
-- Beş tabloyu müşteriden kategoriye doğru zincir şeklinde bağladım
SELECT c.FullName     AS MusteriAdi,
       p.ProductName  AS UrunAdi,
       p.Price        AS Fiyat,
       cat.CategoryName AS Kategori
FROM Customers c
INNER JOIN Orders o        ON o.CustomerID  = c.CustomerID
INNER JOIN OrderDetails od ON od.OrderID    = o.OrderID
INNER JOIN Products p      ON p.ProductID   = od.ProductID
INNER JOIN Categories cat  ON cat.CategoryID = p.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';
GO

-- Soru 4: Hangi kategoride kaç ürün var?
-- LEFT JOIN kullandım ki ürünü olmayan bir kategori olsa bile 0 olarak listede çıksın
SELECT cat.CategoryName     AS Kategori,
       COUNT(p.ProductID)   AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY UrunSayisi DESC;
GO

-- Soru 5: Her müşterinin toplam cirosu, en çok harcayandan en aza
-- Hiç siparişi olmayan müşteri de görünsün diye LEFT JOIN ve ISNULL kullandım
SELECT c.FullName                      AS MusteriAdi,
       ISNULL(SUM(o.TotalAmount), 0)   AS ToplamCiro
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.FullName
ORDER BY ToplamCiro DESC;
GO

-- Soru 6: Siparişlerin üzerinden bugüne kadar kaç gün geçti?
SELECT o.OrderID,
       c.FullName                            AS MusteriAdi,
       o.OrderDate                           AS SiparisTarihi,
       DATEDIFF(DAY, o.OrderDate, GETDATE()) AS GecenGun
FROM Orders o
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
ORDER BY GecenGun DESC;
GO


/* =====================================================================
   BÖLÜM 4: İLERİ SEVİYE VERİ TABANI NESNELERİ
   ===================================================================== */

-- 1. View: Her seferinde uzun JOIN yazmamak için sipariş özetini tek tablo gibi getiren görünüm
CREATE VIEW vw_SiparisOzet AS
SELECT c.FullName    AS MusteriAdi,
       o.OrderDate   AS SiparisTarihi,
       p.ProductName AS UrunAdi,
       od.Quantity   AS Adet
FROM Orders o
INNER JOIN Customers c     ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON od.OrderID   = o.OrderID
INNER JOIN Products p      ON p.ProductID  = od.ProductID;
GO

-- View'ı normal bir tablo gibi sorgulayabiliyorum
SELECT * FROM vw_SiparisOzet
ORDER BY SiparisTarihi;
GO

-- 2. Yedekleme: Veri tabanının C:\Yedek\ klasörüne yedeğini alıyorum
-- (C:\Yedek klasörünün önceden açılmış olması gerekiyor)
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT, INIT, NAME = 'NovaStoreDB Tam Yedek';
GO
