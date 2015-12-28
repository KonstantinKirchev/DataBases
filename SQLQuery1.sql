USE Diablo
GO
SELECT *
FROM Characters

SELECT Name
FROM Characters
ORDER BY name

GO

SELECT TOP 50 Name AS Game, CONVERT(NVARCHAR(10),start, 120) as Start
FROM Games
WHERE start BETWEEN '1/1/2011' AND '1/1/2013'
ORDER BY start , name

GO
select *
from users

SELECT Username, RIGHT(Email, LEN(Email) - CHARINDEX('@', email)) AS [Email Provider]
from users
ORDER BY [Email Provider], Username

GO

SELECT Username, IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

GO

SELECT Name AS Game, CASE  
     WHEN (DATEPART(HOUR,Start) >= 0 AND DATEPART(HOUR,Start) < 12) THEN 'Morning'
	 WHEN (DATEPART(HOUR,Start) >= 12 AND DATEPART(HOUR,Start) < 18) THEN 'Afternoon'
	 WHEN (DATEPART(HOUR,Start) >= 18  AND DATEPART(HOUR,Start) < 24) THEN 'Evening'
	 END
	    AS [Part of the Day],
		CASE  
     WHEN Duration <= 3 THEN 'Extra Short'
	 WHEN Duration >= 4 AND Duration <= 6 THEN 'Short'
	 WHEN Duration > 6 THEN 'Long'
	 WHEN Duration IS NULL THEN 'Extra Long'
	 END
	    AS Duration
FROM Games
ORDER BY Name, Duration, [Part of the Day]


SELECT RIGHT(Email, LEN(Email) - CHARINDEX('@', email)) AS [Email Provider], count(Id) AS [Number Of Users]
FROM Users
GROUP BY  RIGHT(Email, LEN(Email) - CHARINDEX('@', email))  
ORDER BY count(Id) DESC, [Email Provider]

SELECT g.Name AS Game, gt.Name AS [Game Type] , u.Username, ug.Level, ug.Cash, c.Name AS [Character]
FROM Users u
JOIN UsersGames ug
ON ug.UserId = u.Id
JOIN Games g
ON ug.GameId = g.Id
JOIN GameTypes gt
ON g.GameTypeId = gt.Id
JOIN Characters c
ON ug.CharacterId = c.Id
ORDER BY ug.Level DESC, u.Username, g.Name

GO

SELECT u.Username, g.Name AS Game, COUNT(i.Id) AS [Items Count], SUM(i.Price) AS [Items Price]
FROM UsersGames ug
JOIN Users u
ON ug.UserId = u.Id
JOIN UserGameItems ugi
ON ugi.UserGameId = ug.Id
JOIN Games g
ON ug.GameId = g.Id
JOIN Items i
ON ugi.ItemId = i.Id
GROUP BY u.Username, g.Name
HAVING COUNT(i.Id) >= 10
ORDER BY COUNT(i.Id) DESC , SUM(i.Price) DESC, u.Username

SELECT i.Name, i.Price, i.MinLevel, s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
FROM Items i
JOIN [Statistics] s
ON i.StatisticId = s.Id
WHERE s.Speed > 
(SELECT AVG(s.Speed) FROM Items i
JOIN [Statistics] s
ON i.StatisticId = s.Id) AND
s.Luck > 
(SELECT AVG(s.Luck) FROM Items i
JOIN [Statistics] s
ON i.StatisticId = s.Id) AND
s.Mind > 
(SELECT AVG(s.Mind) FROM Items i
JOIN [Statistics] s
ON i.StatisticId = s.Id)
ORDER BY i.Name


SELECT i.Name as Item, i.Price, i.MinLevel, gt.Name AS [Forbidden Game Type]
FROM Items i
LEFT JOIN GameTypeForbiddenItems gtfi
ON gtfi.ItemId = i.Id
LEFT JOIN GameTypes gt
ON gtfi.GameTypeId = gt.Id
ORDER BY [Forbidden Game Type] DESC, i.Name

GO

SELECT i.Name AS [Item Name]
FROM Items i
LEFT JOIN UserGameItems ugi
ON ugi.ItemId = i.Id
LEFT JOIN UsersGames ug
ON ugi.UserGameId = ug.Id
LEFT JOIN Users u
ON ug.UserId = u.Id
LEFT JOIN Games g
ON ug.GameId = g.Id
WHERE u.Username = 'Stamat' AND g.Name = 'Safflower' --AND ((ug.Level >=11 AND ug.Level <=12) OR (ug.Level >=19 AND ug.Level <=21))
ORDER BY i.Name

--12 Problem

SELECT *
FROM Items
WHERE Name = 'Blackguard' /*51*/

SELECT *
FROM Items
WHERE Name = 'Bottomless Potion of Amplification' /*71*/

SELECT *
FROM Items
WHERE Name = 'Eye of Etlich (Diablo III)' /*157*/

SELECT *
FROM Items
WHERE Name = 'Gem of Efficacious Toxin' /*184*/

SELECT *
FROM Items
WHERE Name = 'Golden Gorget of Leoric' /*197*/

SELECT *
FROM Items
WHERE Name = 'Hellfire Amulet' /*223*/

SELECT u.Username, g.Name, ug.Cash, i.Name AS [Item Name]
FROM Users u
JOIN UsersGames ug
ON ug.UserId = u.Id
JOIN Games g
ON ug.GameId = g.Id
JOIN UserGameItems ugi
ON ugi.UserGameId = ug.Id
JOIN Items i
ON ugi.ItemId = i.Id
WHERE g.Name = 'Edinburgh'
ORDER BY [Item Name]

INSERT INTO UserGameItems (ItemId, UserGameId) /*235*/
VALUES (
(SELECT Id
FROM Items
WHERE Name = 'Blackguard'),
235)
GO
INSERT INTO UserGameItems (ItemId, UserGameId)
VALUES
((SELECT Id
FROM Items
WHERE Name = 'Bottomless Potion of Amplification'),
235)
GO
INSERT INTO UserGameItems (ItemId, UserGameId)
VALUES
((SELECT Id
FROM Items
WHERE Name = 'Eye of Etlich (Diablo III)'),
235)
GO
INSERT INTO UserGameItems (ItemId, UserGameId)
VALUES
((SELECT Id
FROM Items
WHERE Name = 'Gem of Efficacious Toxin'),
235)
GO
INSERT INTO UserGameItems (ItemId, UserGameId)
VALUES
((SELECT Id
FROM Items
WHERE Name = 'Golden Gorget of Leoric'),
235)
GO
INSERT INTO UserGameItems (ItemId, UserGameId)
VALUES
((SELECT Id
FROM Items
WHERE Name = 'Hellfire Amulet'),
235)

SELECT SUM(Price)
FROM Items
WHERE Name IN ('Hellfire Amulet', 'Golden Gorget of Leoric', 'Gem of Efficacious Toxin', 'Eye of Etlich (Diablo III)', 'Bottomless Potion of Amplification', 'Blackguard')

SELECT u.Username
FROM Users u
JOIN UsersGames ug
ON ug.UserId = u.Id
WHERE u.Username = 'Alex'

UPDATE UsersGames
SET Cash = Cash - (SELECT SUM(Price)
FROM Items
WHERE Name IN ('Hellfire Amulet', 'Golden Gorget of Leoric', 'Gem of Efficacious Toxin', 'Eye of Etlich (Diablo III)', 'Bottomless Potion of Amplification', 'Blackguard')) 
WHERE UserId = 5

--------------------------------------------------------------------------------------------
USE Diablo
GO
IF OBJECT_ID('fn_CashInUsersGames') IS NOT NULL
  DROP FUNCTION fn_CashInUsersGames
GO

CREATE FUNCTION fn_CashInUsersGames(@gamename nvarchar(max))
	RETURNS @tbl_UsersQuestions TABLE(
		SumCash decimal(10,2)
	)
AS
BEGIN
	DECLARE cashCursor CURSOR FOR
	SELECT ug.Cash FROM Games g
	JOIN UsersGames ug
	  ON ug.GameId = g.Id
	WHERE g.Name = @gamename AND (ug.Id % 2) = 0
    ORDER BY ug.Cash DESC

	OPEN cashCursor
	DECLARE @Cash DECIMAL(10,2)
	DECLARE @Sum DECIMAL(10,2)
	FETCH NEXT FROM cashCursor INTO @Cash
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Sum = @Sum + @Cash
		INSERT INTO @tbl_UsersQuestions
		VALUES(@Sum)
		FETCH NEXT FROM cashCursor INTO @Cash;
	END
	CLOSE cashCursor
	DEALLOCATE cashCursor
	
RETURN;
END
GO

SELECT * FROM dbo.fn_CashInUsersGames('Bali')
UNION
SELECT * FROM dbo.fn_CashInUsersGames('Lily Stargazer')
UNION
SELECT * FROM dbo.fn_CashInUsersGames('Love in a mist')
UNION
SELECT * FROM dbo.fn_CashInUsersGames('Mimosa')
UNION
SELECT * FROM dbo.fn_CashInUsersGames('Ming fern')