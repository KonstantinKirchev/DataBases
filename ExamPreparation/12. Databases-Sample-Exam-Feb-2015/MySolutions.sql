USE Ads
GO
--Problem 1
SELECT
	Title
FROM Ads
ORDER BY Title
--Problem 2
SELECT
	Title,
	Date
FROM Ads
WHERE Date BETWEEN '26-Dec-2014 ' AND '2-Jan-2015 '
ORDER BY Date
--Problem 3
SELECT
	Title,
	Date,
	IIF(ImageDataURL IS NULL, 'no', 'yes') AS [Has Image]
FROM Ads
ORDER BY Id
--Problem 4
SELECT
	*
FROM Ads
WHERE TownId IS NULL
OR CategoryId IS NULL
OR ImageDataURL IS NULL
ORDER BY Id
--Problem 5
SELECT
	a.Title,
	t.Name AS Town
FROM Ads a
LEFT JOIN Towns t
	ON a.TownId = t.Id
ORDER BY a.Id
--Problem 6
SELECT
	a.Title AS Title,
	c.Name AS CategoryName,
	t.Name AS TownName,
	ad.Status
FROM Ads a
LEFT JOIN Categories c
	ON a.CategoryId = c.Id
LEFT JOIN Towns t
	ON a.TownId = t.Id
LEFT JOIN AdStatuses ad
	ON a.StatusId = ad.Id
--Problem 7
SELECT
	a.Title AS Title,
	c.Name AS CategoryName,
	t.Name AS TownName,
	ad.Status
FROM Ads a
LEFT JOIN Categories c
	ON a.CategoryId = c.Id
LEFT JOIN Towns t
	ON a.TownId = t.Id
LEFT JOIN AdStatuses ad
	ON a.StatusId = ad.Id
WHERE ad.Status = 'Published'
AND t.Name IN ('Sofia', 'Blagoevgrad', 'Stara Zagora')
ORDER BY a.Title
--Problem 8
SELECT
	MIN(Date) AS MinDate,
	MAX(Date) AS MaxDate
FROM Ads
--Problem 9
SELECT TOP 10
	a.Title,
	a.Date,
	ad.Status
FROM Ads a
JOIN AdStatuses ad
	ON a.StatusId = ad.Id
ORDER BY a.Date DESC
----------------------------------------------------
--Other Problem 
SELECT a.*
FROM
(SELECT TOP 10
	a.Title,
	a.Date,
	ad.Status
FROM Ads a
JOIN AdStatuses ad
	ON a.StatusId = ad.Id
ORDER BY a.Date DESC) a
ORDER BY a.Date
----------------------------------------------------
--Problem 10
SELECT
	a.Id,
	a.Title,
	a.Date,
	ad.Status
FROM Ads a
JOIN AdStatuses ad
	ON a.StatusId = ad.Id
WHERE ad.Status <> 'Published'
AND a.Date BETWEEN '2014-12-01' AND '2014-12-31'
ORDER BY a.Id
----------------------------------------------
--Second Variant
SELECT
	a.Id,
	Title,
	Date,
	Status
FROM Ads a
JOIN AdStatuses s
	ON a.StatusId = s.Id
WHERE MONTH(Date) = (SELECT MONTH(MIN(Date)) FROM Ads)
AND YEAR(Date) = (SELECT YEAR(MIN(Date)) FROM Ads)
AND Status <> 'Published'
ORDER BY a.Id
----------------------------------------------
--Problem 11
SELECT
	ad.Status,
	COUNT(a.StatusId) AS Count
FROM Ads a
JOIN AdStatuses ad
	ON a.StatusId = ad.Id
GROUP BY ad.Status
ORDER BY ad.Status
--Problem 12
SELECT
	t.Name AS [Town Name],
	ad.Status,
	COUNT(a.StatusId) AS Count
FROM Ads a
JOIN AdStatuses ad
	ON a.StatusId = ad.Id
JOIN Towns t
	ON a.TownId = t.Id
GROUP BY	ad.Status,
			t.Name
ORDER BY t.Name, ad.Status
--Problem 13

SELECT
	au.UserName AS UserName,
	COUNT(a.Id) AS AdsCount,
	IIF(au.UserName IN(
		SELECT au.UserName 
		FROM AspNetUsers au
		LEFT JOIN AspNetUserRoles anur
		ON au.Id = anur.UserId
		LEFT JOIN AspNetRoles ar
		ON ar.Id = anur.RoleId
		WHERE ar.Name = 'Administrator' ),'yes','no') 
AS IsAdministrator
FROM AspNetUsers au 
LEFT JOIN Ads a
ON a.OwnerId = au.Id
GROUP BY au.UserName
ORDER BY au.UserName

--Problem 14
SELECT
	COUNT(a.Id) AS AdsCount,
	ISNULL(t.Name, '(no town)') AS Town
FROM Ads a
LEFT JOIN Towns t
	ON a.TownId = t.Id
GROUP BY t.Name
HAVING COUNT(a.Id) IN (2, 3)
ORDER BY t.Name
--Problem 15

SELECT
	d1.Date AS [FirstDate],
	d2.Date AS [SecondDate]
FROM	Ads d1,
		Ads d2
WHERE d1.Date < d2.Date
AND DATEDIFF(HOUR, d1.Date, d2.Date) < 12
ORDER BY d1.Date, d2.Date

--Problem 16 Create a table Countries(Id, Name). Use auto-increment for the primary key. 
--Add a new column CountryId in the Towns table to link each town to some country (non-mandatory link). 
--Create a foreign key between the Countries and Towns tables.
USE Ads
GO
CREATE TABLE Countries
(Id int NOT NULL IDENTITY PRIMARY KEY,
Name nvarchar(max) NOT NULL)
GO
ALTER TABLE Towns
ADD CountryId int
GO
ALTER TABLE Towns
ADD CONSTRAINT FK_Towns_Countries
  FOREIGN KEY (CountryId) REFERENCES Countries(Id)
GO
INSERT INTO Countries (Name)
	VALUES ('Bulgaria'), ('Germany'), ('France')
GO
UPDATE Towns
SET CountryId = (SELECT
	Id
FROM Countries
WHERE Name = 'Bulgaria')
GO
INSERT INTO Towns
	VALUES ('Munich', (SELECT Id FROM Countries WHERE Name = 'Germany')),
	('Frankfurt', (SELECT Id FROM Countries WHERE Name = 'Germany')),
	('Berlin', (SELECT Id FROM Countries WHERE Name = 'Germany')),
	('Hamburg', (SELECT Id FROM Countries WHERE Name = 'Germany')),
	('Paris', (SELECT Id FROM Countries WHERE Name = 'France')),
	('Lyon', (SELECT Id FROM Countries WHERE Name = 'France')),
	('Nantes', (SELECT Id FROM Countries WHERE Name = 'France'))
GO
UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Paris')
WHERE DATENAME(WEEKDAY, Date) = 'Friday'
GO
UPDATE Ads
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Hamburg')
WHERE DATENAME(WEEKDAY, Date) = 'Thursday'
GO
DELETE FROM Ads
WHERE OwnerId IN (SELECT au.Id
	FROM AspNetUsers au
	JOIN AspNetUserRoles aur
		ON aur.UserId = au.Id
	JOIN AspNetRoles ar
		ON aur.RoleId = ar.Id
	WHERE ar.Name = 'Partner')
GO
INSERT INTO Ads (Title, Text, Date, OwnerId, StatusId)
	VALUES ('Free Book', 'Free C# Book', GETDATE(), (SELECT a.Id FROM AspNetUsers a WHERE a.UserName = 'nakov'), (SELECT a.Id FROM AdStatuses a WHERE a.Status = 'Waiting Approval'))
GO
SELECT
	t.Name AS Town,
	c.Name AS Country,
	COUNT(a.Id) AS AdsCount
FROM Towns t
FULL JOIN Countries c
	ON t.CountryId = c.Id
FULL JOIN Ads a
	ON a.TownId = t.Id
GROUP BY t.Name, c.Name
ORDER BY t.Name, c.Name
--Problem 17
USE Ads
GO
IF (object_id(N'AllAds') IS NOT NULL)
DROP VIEW AllAds
GO
CREATE VIEW AllAds
AS
SELECT
	a.Id,
	a.Title,
	u.UserName AS Author,
	a.Date,
	t.Name AS Town,
	c.Name AS Category,
	s.Status
FROM Ads a
LEFT JOIN AspNetUsers u
	ON a.OwnerId = u.Id
LEFT JOIN Towns t
	ON a.TownId = t.Id
LEFT JOIN Categories c
	ON a.CategoryId = c.Id
LEFT JOIN AdStatuses s
	ON a.StatusId = s.Id
GO
SELECT
	*
FROM AllAds
GO
IF (object_id(N'fn_ListUsersAds') IS NOT NULL)
DROP FUNCTION fn_ListUsersAds
GO

CREATE FUNCTION fn_ListUsersAds()
	RETURNS @tbl_UsersAds TABLE(
		UserName NVARCHAR(MAX),
		AdDates NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE UsersCursor CURSOR FOR 
	SELECT UserName
	FROM AspNetUsers
	ORDER BY UserName DESC

	OPEN UsersCursor;
	DECLARE @username NVARCHAR(MAX);
	FETCH NEXT FROM UsersCursor INTO @username;
	WHILE @@FETCH_STATUS = 0 
		BEGIN
			DECLARE @adDates NVARCHAR(MAX) = NULL;
			SELECT
				@adDates =
						CASE
							WHEN @adDates IS NULL THEN CONVERT(NVARCHAR(MAX), Date, 112)
							ELSE @adDates + '; ' + CONVERT(NVARCHAR(MAX), Date, 112)
						END
		FROM AllAds
		WHERE Author = @username
		ORDER BY Date

		INSERT INTO @tbl_UsersAds
			VALUES (@username, @adDates)

		FETCH NEXT FROM UsersCursor INTO @username;
		END;
CLOSE UsersCursor;
DEALLOCATE UsersCursor;
RETURN;
END
GO

SELECT
	*
FROM fn_ListUsersAds()
--Problem 18

DROP DATABASE if exists `orders`;
CREATE SCHEMA `orders` 
DEFAULT CHARACTER SET utf8 
COLLATE utf8_unicode_ci ;

USE `orders`;

CREATE TABLE products
(id int not null auto_increment primary key,
 product_name nvarchar(500),
 price decimal(10,2));
 
 CREATE TABLE customers
(id int not null auto_increment primary key,
 customer_name nvarchar(500));
 
 CREATE TABLE orders
(id int not null auto_increment primary key,
 order_date datetime);
 
 CREATE TABLE order_items
(id int not null auto_increment primary key,
 order_id int,
 product_id int,
 quantity decimal(10,2));
 
 ALTER TABLE order_items
 ADD CONSTRAINT fk_order_items_order
 foreign key (order_id) references orders(id);
 
 ALTER TABLE order_items
 ADD CONSTRAINT fk_order_items_product
 foreign key (product_id) references products(id);

INSERT INTO `products` 
VALUES (1,'beer',1.20), (2,'cheese',9.50), (3,'rakiya',12.40), (4,'salami',6.33), (5,'tomatos',2.50), (6,'cucumbers',1.35), (7,'water',0.85), (8,'apples',0.75); INSERT INTO `customers` 
VALUES (1,'Peter'), (2,'Maria'), (3,'Nakov'), (4,'Vlado'); INSERT INTO `orders` 
VALUES (1,'2015-02-13 13:47:04'), (2,'2015-02-14 22:03:44'), (3,'2015-02-18 09:22:01'), (4,'2015-02-11 20:17:18'); INSERT INTO `order_items` 
VALUES (12,4,6,2.00), (13,3,2,4.00), (14,3,5,1.50), (15,2,1,6.00), (16,2,3,1.20), (17,1,2,1.00), (18,1,3,1.00), (19,1,4,2.00), (20,1,5,1.00), (21,3,1,4.00), (22,1,1,3.00); 

SELECT
	p.product_name,
	COUNT(o.id) AS num_orders,
	ifnull(SUM(oi.quantity), 0) AS quantity,
	p.price,
	ifnull(SUM(oi.quantity) * p.price, 0) AS total_price
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON o.id = oi.order_id
GROUP BY p.product_name,p.price
ORDER BY p.product_name