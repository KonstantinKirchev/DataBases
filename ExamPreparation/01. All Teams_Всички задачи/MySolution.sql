USE Football
GO
--Problem 1
SELECT TeamName
FROM Teams 
ORDER BY TeamName
--Problem 2
SELECT TOP 50 CountryName, Population
FROM Countries
ORDER BY Population DESC, CountryName
--Problem 3
SELECT CountryName, CountryCode, IIF(CurrencyCode='EUR','Inside','Outside') AS Eurozone
FROM Countries
ORDER BY CountryName
--Problem 4
SELECT TeamName AS [Team Name], CountryCode AS [Country Code]
FROM Teams
WHERE TeamName LIKE '%[0-9]%'
ORDER BY CountryCode
--Problem 5
SELECT c1.CountryName AS [Home Team], c2.CountryName AS [Away Team], i.MatchDate AS [Match Date]
FROM InternationalMatches i
JOIN Countries c1
ON i.HomeCountryCode = c1.CountryCode
JOIN Countries c2
ON i.AwayCountryCode = c2.CountryCode
ORDER BY i.MatchDate DESC
--Problem 6
SELECT t.TeamName AS [Team Name], l.LeagueName AS League,ISNULL(c.CountryName,'International') AS [League Country]
FROM Teams t
LEFT JOIN Leagues_Teams lt
ON lt.TeamId = t.Id
LEFT JOIN Leagues l
ON lt.LeagueId = l.Id
LEFT JOIN Countries c
ON l.CountryCode = c.CountryCode
ORDER BY t.TeamName, League
----------------------------------------------------
--Second Version
SELECT
  TeamName AS [Team Name],
  LeagueName AS [League],
  (CASE WHEN l.CountryCode IS NULL THEN 'International' ELSE c.CountryName END) AS [League Country]
FROM Teams t
JOIN Leagues_Teams lt on t.Id = lt.TeamId
JOIN Leagues l on l.id = lt.LeagueId
LEFT JOIN Countries c on c.CountryCode = l.CountryCode
ORDER BY TeamName
----------------------------------------------------
--Problem 7
SELECT t.TeamName AS Team, 
(SELECT COUNT(DISTINCT tm.Id)
FROM TeamMatches tm
WHERE tm.HomeTeamId = t.Id OR tm.AwayTeamId = t.Id) AS [Matches Count]
FROM Teams t
WHERE (SELECT COUNT(DISTINCT tm.Id)
FROM TeamMatches tm
WHERE tm.HomeTeamId = t.Id OR tm.AwayTeamId = t.Id) > 1
ORDER BY t.TeamName
--Problem 8
SELECT l.LeagueName AS [League Name], 
       COUNT(DISTINCT lt.TeamId) AS Teams, 
	   COUNT(DISTINCT tm.Id) AS Matches, 
	   ISNULL(AVG(tm.HomeGoals + tm.AwayGoals),0) AS [Average Goals]
FROM Leagues l
LEFT JOIN Leagues_Teams lt
ON lt.LeagueId = l.Id
LEFT JOIN TeamMatches tm
ON tm.LeagueId = l.Id
GROUP BY l.LeagueName
ORDER BY Teams DESC, Matches DESC
--Problem 9
select t.TeamName,
	isnull((select sum(tm.HomeGoals) from TeamMatches tm where tm.HomeTeamId = t.Id), 0) + 
    isnull((select sum(tm.AwayGoals) from TeamMatches tm where tm.AwayTeamId = t.Id), 0) as [Total Goals]
from Teams t
order by [Total Goals] desc, t.TeamName
--Problem 10
SELECT tm1.MatchDate AS [First Date], tm2.MatchDate AS [Second Date]
FROM TeamMatches tm1, TeamMatches tm2
WHERE CAST(tm1.MatchDate AS DATE) = CAST(tm2.MatchDate AS DATE) AND tm1.MatchDate < tm2.MatchDate
ORDER BY tm1.MatchDate DESC, tm2.MatchDate DESC
-------------------------------------------------------
--Second Version
SELECT tm1.MatchDate AS [First Date], tm2.MatchDate AS [Second Date]
FROM TeamMatches tm1, TeamMatches tm2
WHERE
  tm2.MatchDate > tm1.MatchDate AND
  DATEDIFF(day, tm1.MatchDate, tm2.MatchDate) < 1
ORDER BY tm1.MatchDate DESC, tm2.MatchDate DESC
-------------------------------------------------------
--Problem 11
SELECT LOWER(SUBSTRING(t1.TeamName,1,LEN(t1.TeamName)-1) + reverse(t2.TeamName)) AS Mix
FROM Teams t1, Teams t2
WHERE RIGHT(t1.TeamName,1) = LEFT(reverse(t2.TeamName),1)
ORDER BY Mix
--Problem 12
SELECT c.CountryName AS [Country Name], COUNT(DISTINCT im.Id) AS [International Matches], COUNT(DISTINCT tm.Id) AS [Team Matches]
FROM Countries c
LEFT JOIN InternationalMatches im
ON im.HomeCountryCode = c.CountryCode OR im.AwayCountryCode = c.CountryCode
LEFT JOIN Leagues l
ON l.CountryCode = c.CountryCode
LEFT JOIN TeamMatches tm
ON tm.LeagueId = l.Id
GROUP BY c.CountryName
HAVING COUNT(DISTINCT im.Id) > 0 OR COUNT(DISTINCT tm.Id) > 0
ORDER BY [International Matches] DESC, [Team Matches] DESC, c.CountryName
GO
--Problem 13
IF OBJECT_ID('FriendlyMatches') IS NOT NULL
  DROP TABLE FriendlyMatches
CREATE TABLE FriendlyMatches
(Id int not null identity primary key,
HomeTeamId int, 
AwayTeamId int, 
MatchDate datetime,
constraint FK_FriendlyMatches_HomeTeams
foreign key (HomeTeamId) references Teams(Id),
constraint FK_FriendlyMatches_AwayTeams
foreign key (AwayTeamId) references Teams(Id))
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
LEFT JOIN Teams t1
ON fm.HomeTeamId = t1.Id
LEFT JOIN Teams t2
ON fm.AwayTeamId = t2.Id
UNION
SELECT t1.TeamName AS [Home Team], t2.TeamName AS [Away Team], tm.MatchDate AS [Match Date]
FROM TeamMatches tm 
LEFT JOIN Teams t1
ON tm.HomeTeamId = t1.Id
LEFT JOIN Teams t2
ON tm.AwayTeamId = t2.Id
ORDER BY [Match Date] DESC
GO
--Problem 14
ALTER TABLE Leagues
  ADD IsSeasonal nvarchar(10) not null DEFAULT 'false'
GO
INSERT INTO TeamMatches(HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES ((SELECT Id FROM Teams WHERE TeamName='Empoli'),
(SELECT Id FROM Teams WHERE TeamName='Parma'), 
2, 
2, 
'19-Apr-2015 16:00',
(SELECT Id FROM Leagues WHERE LeagueName='Italian Serie A'))
GO
INSERT INTO TeamMatches(HomeTeamId, AwayTeamId, HomeGoals, AwayGoals, MatchDate, LeagueId)
VALUES ((SELECT Id FROM Teams WHERE TeamName='Internazionale'),
(SELECT Id FROM Teams WHERE TeamName='AC Milan'), 
0, 
0, 
'19-Apr-2015 21:45',
(SELECT Id FROM Leagues WHERE LeagueName='Italian Serie A'))
GO
UPDATE Leagues 
SET IsSeasonal = 'true'
WHERE Id IN (SELECT l.Id
FROM Leagues l
JOIN TeamMatches tm
ON tm.LeagueId = l.Id
GROUP BY l.Id
HAVING COUNT(tm.Id) > 0)
GO
SELECT t1.TeamName AS [Home Team], 
tm.HomeGoals AS [Home Goals], 
t2.TeamName AS [Away Team], 
tm.AwayGoals AS [Away Goals], 
l.LeagueName AS [League Name]
FROM TeamMatches tm
JOIN Teams t1 ON tm.HomeTeamId = t1.Id
JOIN Teams t2 ON tm.AwayTeamId = t2.Id
JOIN Leagues l ON tm.LeagueId = l.Id
WHERE tm.MatchDate > '10-Apr-2015'
ORDER BY l.LeagueName, tm.HomeGoals DESC, tm.AwayGoals DESC
GO
--Problem 15
IF OBJECT_ID('fn_TeamsJSON') IS NOT NULL
  DROP FUNCTION fn_TeamsJSON
GO
CREATE FUNCTION fn_TeamsJSON() 
RETURNS nvarchar(max)
AS
BEGIN
  DECLARE @json NVARCHAR(MAX) = '{"teams":['

	DECLARE teamsCursor CURSOR FOR
	SELECT Id, TeamName FROM Teams
	WHERE CountryCode = 'BG'
	ORDER BY TeamName

	OPEN teamsCursor
	DECLARE @TeamName NVARCHAR(MAX)
	DECLARE @TeamId INT
	FETCH NEXT FROM teamsCursor INTO @TeamId, @TeamName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @json = @json + '{"name":"' + @TeamName + '","matches":['

		DECLARE matchesCursor CURSOR FOR
		SELECT t1.TeamName, t2.TeamName, HomeGoals, AwayGoals, MatchDate FROM TeamMatches
		LEFT JOIN Teams t1 ON t1.Id = HomeTeamId
		LEFT JOIN Teams t2 ON t2.Id = AwayTeamId
		WHERE HomeTeamId = @TeamId OR AwayTeamId = @TeamId
		ORDER BY TeamMatches.MatchDate DESC

		OPEN matchesCursor
		DECLARE @HomeTeamName NVARCHAR(MAX)
		DECLARE @AwayTeamName NVARCHAR(MAX)
		DECLARE @HomeGoals INT
		DECLARE @AwayGoals INT
		DECLARE @MatchDate DATE
		FETCH NEXT FROM matchesCursor INTO @HomeTeamName, @AwayTeamName, @HomeGoals, @AwayGoals, @MatchDate
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @json = @json + '{"' + @HomeTeamName + '":' + CONVERT(NVARCHAR(MAX), @HomeGoals) + ',"' + 
						@AwayTeamName + '":' + CONVERT(NVARCHAR(MAX), @AwayGoals) + 
						',"date":' + CONVERT(NVARCHAR(MAX), @MatchDate, 103) + '}'
			FETCH NEXT FROM matchesCursor INTO @HomeTeamName, @AwayTeamName, @HomeGoals, @AwayGoals, @MatchDate
			IF @@FETCH_STATUS = 0
				SET @json = @json + ','
		END
		CLOSE matchesCursor
		DEALLOCATE matchesCursor	
		SET @json = @json + ']}'

		FETCH NEXT FROM teamsCursor INTO @TeamId, @TeamName
		IF @@FETCH_STATUS = 0
			SET @json = @json + ','
	END
	CLOSE teamsCursor
	DEALLOCATE teamsCursor

	SET @json = @json + ']}'
	RETURN @json
END
GO

SELECT dbo.fn_TeamsJSON()

