USE Ads
GO
CREATE TABLE Countries
(Id int not null identity primary key, 
Name nvarchar(max) not null) 
GO
ALTER TABLE Towns
ADD CountryId int
GO
ALTER TABLE Towns
ADD CONSTRAINT FK_Towns_Countries
FOREIGN KEY(CountryId) REFERENCES Countries(Id)
GO
INSERT INTO Countries(Name) VALUES ('Bulgaria'), ('Germany'), ('France')
UPDATE Towns SET CountryId = (SELECT Id FROM Countries WHERE Name='Bulgaria')
INSERT INTO Towns VALUES
('Munich', (SELECT Id FROM Countries WHERE Name='Germany')),
('Frankfurt', (SELECT Id FROM Countries WHERE Name='Germany')),
('Berlin', (SELECT Id FROM Countries WHERE Name='Germany')),
('Hamburg', (SELECT Id FROM Countries WHERE Name='Germany')),
('Paris', (SELECT Id FROM Countries WHERE Name='France')),
('Lyon', (SELECT Id FROM Countries WHERE Name='France')),
('Nantes', (SELECT Id FROM Countries WHERE Name='France'))
GO
UPDATE Ads
SET TownId = (SELECT t.Id FROM Towns t WHERE t.Name = 'Paris')
WHERE DATENAME(WEEKDAY,Date) = 'Friday'
GO
UPDATE Ads
SET TownId = (SELECT t.Id FROM Towns t WHERE t.Name = 'Hamburg')
WHERE DATENAME(WEEKDAY,Date) = 'Thursday'
GO
DELETE FROM Ads
WHERE Id IN
(SELECT a.Id FROM Ads a
JOIN AspNetUsers u
ON a.OwnerId = u.Id
JOIN AspNetUserRoles ar
ON ar.UserId = u.Id
JOIN AspNetRoles r
ON ar.RoleId = r.Id
WHERE r.Name = 'Partner')
GO

INSERT INTO Ads (Title, Text, OwnerId, Date, StatusId)
VALUES('Free Book',
'Free C# Book', 
(SELECT Id FROM AspNetUsers WHERE Name = 'nakov'),
getdate(),
(SELECT Id FROM AdStatuses WHERE Status = 'Waiting Approval'))
GO
SELECT t.Name AS Town, c.Name AS Country, COUNT(a.Id) AS AdsCount
FROM Towns t
FULL JOIN Countries c
ON t.CountryId = c.Id
FULL JOIN Ads a
ON a.TownId = t.Id
GROUP BY t.Name, c.Name
ORDER BY t.Name, c.Name
-----------------------------------------------------------------------------------
USE Forum
GO
CREATE TABLE Towns
(Id int not null identity primary key, 
Name nvarchar(max) not null)
GO
ALTER TABLE Users
ADD TownId int
GO
ALTER TABLE Users
ADD CONSTRAINT FK_Users_Towns
FOREIGN KEY (TownId) REFERENCES Towns(Id)
GO
INSERT INTO Towns(Name) VALUES ('Sofia'), ('Berlin'), ('Lyon')
UPDATE Users SET TownId = (SELECT Id FROM Towns WHERE Name='Sofia')
INSERT INTO Towns VALUES
('Munich'), ('Frankfurt'), ('Varna'), ('Hamburg'), ('Paris'), ('Lom'), ('Nantes')
GO 
UPDATE Users
SET TownId = (SELECT Id FROM Towns WHERE Name = 'Paris')
WHERE DATENAME(WEEKDAY,RegistrationDate) = 'Friday'
GO
UPDATE Answers
SET QuestionId = (SELECT Id FROM Questions WHERE Title = 'Java += operator')
WHERE DATENAME(WEEKDAY,CreatedOn) IN ('Monday','Sunday') AND MONTH(CreatedOn) = 2
GO
CREATE Table [#AnswerIds] (
	AnswerId int not null
)

INSERT INTO [#AnswerIds]
SELECT a.Id FROM Answers a
WHERE (SELECT SUM(Value)
FROM Answers aa
JOIN Votes v ON v.AnswerId = a.Id) < 0

DELETE FROM Votes
FROM Votes v
WHERE v.AnswerId in 
	(
		SELECT a.Id FROM Answers a
		WHERE (SELECT SUM(Value)
		FROM Answers aa
		JOIN Votes v ON v.AnswerId = a.Id) < 0)

DELETE FROM Answers
FROM Answers a
WHERE a.Id in (SELECT * FROM [#AnswerIds])

DROP TABLE [#AnswerIds]
GO
INSERT INTO Questions (Title, Content, CategoryId, UserId, CreatedOn)
VALUES 
('Fetch NULL values in PDO query',
'When I run the snippet, NULL values are converted to empty strings. How can fetch NULL values?',
(SELECT c.Id FROM Categories c WHERE c.Name = 'Databases'),
(SELECT u.Id FROM Users u WHERE u.Username = 'darkcat'),
GETDATE())

SELECT t.Name AS Town, u.Username AS Username, COUNT(a.Id) AS [AnswersCount]
FROM Towns t
LEFT JOIN Users u
ON u.TownId = t.Id
LEFT JOIN Answers a
ON a.UserId = u.Id
GROUP BY t.Name, u.Username
ORDER BY COUNT(a.Id) DESC, u.Username

--------------------------------------------------------------------------------------
USE Geography
GO
CREATE TABLE Monasteries
(Id int not null identity primary key, 
Name nvarchar(max) not null, 
CountryCode char(2) not null)
GO
ALTER TABLE Monasteries
ADD CONSTRAINT FK_Monasteries_Countries
FOREIGN KEY (CountryCode) REFERENCES Countries(CountryCode)
GO
INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')
GO
ALTER TABLE Countries
ADD IsDeleted nvarchar(10) not null DEFAULT ('false')
GO
UPDATE Countries
SET IsDeleted = 'true'
WHERE CountryCode IN 
(SELECT c.CountryCode 
FROM Countries c
JOIN CountriesRivers cr
ON cr.CountryCode = c.CountryCode
JOIN Rivers r
ON cr.RiverId = r.Id
GROUP BY c.CountryCode
HAVING COUNT(r.Id)>3)
GO
SELECT m.Name AS Monastery, c.CountryName AS Country
FROM Monasteries m
JOIN Countries c
ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 'false'
ORDER BY m.Name
GO
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'
GO
INSERT INTO Monasteries (Name, CountryCode)
VALUES ('Hanga Abbey',
(SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))
GO
INSERT INTO Monasteries (Name, CountryCode)
VALUES ('Myin-Tin-Daik',
(SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))
GO
SELECT con.ContinentName AS ContinentName, c.CountryName AS CountryName, COUNT(m.Id) AS MonasteriesCount
FROM Continents con
LEFT JOIN Countries c
ON c.ContinentCode = con.ContinentCode
LEFT JOIN Monasteries m
ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 'false'
GROUP BY con.ContinentName, c.CountryName
ORDER BY COUNT(m.Id) DESC, c.CountryName

---------------------------------------------------------------------------------------------
USE Football
GO
CREATE TABLE FriendlyMatches
(Id int not null identity primary key, 
HomeTeamId int not null, 
AwayTeamId int not null, 
MatchDate datetime not null,
CONSTRAINT FK_FriendlyMatches_HomeTeams
FOREIGN KEY (HomeTeamId) REFERENCES Teams(Id),
CONSTRAINT FK_FriendlyMatches_AwayTeams
FOREIGN KEY (AwayTeamId) REFERENCES Teams(Id))
GO
INSERT INTO Teams(TeamName) VALUES
 ('US All Stars'),
 ('Formula 1 Drivers'),
 ('Actors'),
 ('FIFA Legends'),
 ('UEFA Legends'),
 ('Svetlio & The Legends')
GO

INSERT INTO FriendlyMatches(
  HomeTeamId, AwayTeamId, MatchDate) VALUES
  
((SELECT Id FROM Teams WHERE TeamName='US All Stars'), 
 (SELECT Id FROM Teams WHERE TeamName='Liverpool'),
 '30-Jun-2015 17:00'),
 
((SELECT Id FROM Teams WHERE TeamName='Formula 1 Drivers'), 
 (SELECT Id FROM Teams WHERE TeamName='Porto'),
 '12-May-2015 10:00'),
 
((SELECT Id FROM Teams WHERE TeamName='Actors'), 
 (SELECT Id FROM Teams WHERE TeamName='Manchester United'),
 '30-Jan-2015 17:00'),

((SELECT Id FROM Teams WHERE TeamName='FIFA Legends'), 
 (SELECT Id FROM Teams WHERE TeamName='UEFA Legends'),
 '23-Dec-2015 18:00'),

((SELECT Id FROM Teams WHERE TeamName='Svetlio & The Legends'), 
 (SELECT Id FROM Teams WHERE TeamName='Ludogorets'),
 '22-Jun-2015 21:00')

GO

SELECT t1.TeamName AS [Home Team], t2.TeamName AS [Away Team], fm.MatchDate AS [Match Date]
FROM FriendlyMatches fm
JOIN Teams t1
ON fm.HomeTeamId = t1.Id
JOIN Teams t2
ON fm.AwayTeamId = t2.Id
UNION
SELECT t1.TeamName AS [Home Team], t2.TeamName AS [Away Team], tm.MatchDate AS [Match Date]
FROM TeamMatches tm
JOIN Teams t1
ON tm.HomeTeamId = t1.Id 
JOIN Teams t2
ON tm.AwayTeamId = t2.Id
ORDER BY fm.MatchDate DESC
GO
ALTER TABLE Leagues 
ADD IsSeasonal nvarchar(10) not null DEFAULT ('false')
GO
INSERT INTO TeamMatches (HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES 
((SELECT Id FROM Teams WHERE TeamName = 'Empoli'),
(SELECT Id FROM Teams WHERE TeamName = 'Parma'),
2,
2,
'19-Apr-2015 16:00',
(SELECT Id FROM Leagues WHERE LeagueName = 'Italian Serie A'))
GO
INSERT INTO TeamMatches (HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES 
((SELECT Id FROM Teams WHERE TeamName = 'Internazionale'),
(SELECT Id FROM Teams WHERE TeamName = 'AC Milan'),
0,
0,
'19-Apr-2015 21:45',
(SELECT Id FROM Leagues WHERE LeagueName = 'Italian Serie A'))
GO
UPDATE Leagues
SET IsSeasonal = 'true'
WHERE LeagueName IN 
(SELECT l.LeagueName 
FROM Leagues l
JOIN TeamMatches tm
ON tm.LeagueId = l.Id
GROUP BY l.LeagueName
HAVING COUNT(tm.Id) > 0)
GO
SELECT t1.TeamName AS [Home Team], 
       tm.HomeGoals AS [Home Goals], 
	   t2.TeamName AS [Away Team], 
	   tm.AwayGoals AS [Away Goals], 
	   l.LeagueName AS [League Name]
FROM TeamMatches tm
JOIN Leagues l
ON tm.LeagueId = l.Id
JOIN Teams t1
ON tm.HomeTeamId = t1.Id
JOIN Teams t2
ON tm.AwayTeamId = t2.Id
WHERE tm.MatchDate > '10-Apr-2015'
ORDER BY l.LeagueName, tm.HomeGoals DESC, tm.AwayGoals DESC