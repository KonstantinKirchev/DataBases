USE Forum
GO
CREATE VIEW AllQuestions
AS
SELECT u.Id AS UId, u.Username, u.FirstName, u.LastName, u.Email, u.PhoneNumber, u.RegistrationDate,
       q.Id AS QId, q.Title, q.Content, q.CategoryId, q.UserId, q.CreatedOn
FROM Questions q
LEFT JOIN Users u
ON q.UserId = u.Id
GO
SELECT * FROM AllQuestions
GO
IF (object_id(N'fn_ListUsersQuestions') IS NOT NULL)
DROP FUNCTION fn_ListUsersQuestions
GO

CREATE FUNCTION fn_ListUsersQuestions()
	RETURNS @tbl_UsersQuestions TABLE(
		UserName NVARCHAR(MAX),
		Questions NVARCHAR(MAX)
	)
AS
BEGIN
	DECLARE UsersCursor CURSOR FOR
		SELECT UserName FROM Users
		ORDER BY UserName;
	OPEN UsersCursor;
	DECLARE @username NVARCHAR(MAX);
	FETCH NEXT FROM UsersCursor INTO @username;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @question NVARCHAR(MAX) = NULL;
		SELECT
			@question = CASE
				WHEN @question IS NULL THEN Title
				ELSE @question + ', ' + Title
			END
		FROM AllQuestions
		WHERE UserName = @username
		ORDER BY Title DESC;

		INSERT INTO @tbl_UsersQuestions
		VALUES(@username, @question)
		
		FETCH NEXT FROM UsersCursor INTO @username;
	END;
	CLOSE UsersCursor;
	DEALLOCATE UsersCursor;
	RETURN;
END
GO

SELECT * FROM fn_ListUsersQuestions()

------------------------------------------------------------------------------------
USE Ads
GO
CREATE VIEW AllAds
AS
SELECT a.Id, a.Title, u.UserName AS Author, a.Date, t.Name AS Town, c.Name AS Category, s.Status
FROM Ads a
LEFT JOIN Categories c
ON a.CategoryId = c.Id
LEFT JOIN AspNetUsers u
ON a.OwnerId = u.Id
LEFT JOIN Towns t
ON a.TownId = t.Id
LEFT JOIN AdStatuses s
ON a.StatusId = s.Id
GO
SELECT *
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
		SELECT UserName FROM AspNetUsers
		ORDER BY Username DESC;
	OPEN UsersCursor;
	DECLARE @username NVARCHAR(MAX);
	FETCH NEXT FROM UsersCursor INTO @username;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @ads NVARCHAR(MAX) = NULL;
		SELECT
			@ads = CASE
				WHEN @ads IS NULL THEN CONVERT(NVARCHAR(MAX), Date, 112)
				ELSE @ads + '; ' + CONVERT(NVARCHAR(MAX), Date, 112)
			END
		FROM AllAds
		WHERE Author = @username
		ORDER BY Date;

		INSERT INTO @tbl_UsersAds
		VALUES(@username, @ads)
		
		FETCH NEXT FROM UsersCursor INTO @username;
	END;
	CLOSE UsersCursor;
	DEALLOCATE UsersCursor;
	RETURN;
END
GO

SELECT * FROM fn_ListUsersAds()

-----------------------------------------------------------------------------
USE Geography
GO 
SELECT m.MountainRange, p.PeakName, p.Elevation
FROM Mountains m
JOIN Peaks p
ON p.MountainId = m.Id
GO
IF OBJECT_ID('fn_MountainsPeaksJSON') IS NOT NULL
  DROP FUNCTION fn_MountainsPeaksJSON
GO

CREATE FUNCTION fn_MountainsPeaksJSON()
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @json NVARCHAR(MAX) = '{"mountains":['

	DECLARE mountainsCursor CURSOR FOR
	SELECT Id, MountainRange FROM Mountains 

	OPEN mountainsCursor
	DECLARE @mountainId INT
	DECLARE @mountain NVARCHAR(MAX)
	FETCH NEXT FROM mountainsCursor INTO @mountainId, @mountain 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @json = @json + '{"name":"' + @mountain + '","peaks":['

		DECLARE peaksCursor CURSOR FOR
		SELECT p.PeakName, p.Elevation FROM Peaks p
		WHERE p.MountainId = @mountainId

		OPEN peaksCursor
		DECLARE @PeaksName NVARCHAR(MAX)
		DECLARE @Elevation NVARCHAR(MAX)
		FETCH NEXT FROM peaksCursor INTO @PeaksName, @Elevation
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @json = @json + '{"name":"' + @PeaksName + '","elevation":' + @Elevation + '}'
			FETCH NEXT FROM peaksCursor INTO @PeaksName, @Elevation
			IF @@FETCH_STATUS = 0
				SET @json = @json + ','
		END
		CLOSE peaksCursor
		DEALLOCATE peaksCursor	
		SET @json = @json + ']}'

		FETCH NEXT FROM mountainsCursor INTO @mountainId, @mountain
		IF @@FETCH_STATUS = 0
			SET @json = @json + ','
	END
	CLOSE mountainsCursor
	DEALLOCATE mountainsCursor

	SET @json = @json + ']}'
	RETURN @json
END
GO

SELECT dbo.fn_MountainsPeaksJSON()

-----------------------------------------------------------------------------------
USE Football
GO
IF OBJECT_ID('fn_TeamsJSON') IS NOT NULL
  DROP FUNCTION fn_TeamsJSON
GO

CREATE FUNCTION fn_TeamsJSON()
	RETURNS NVARCHAR(MAX)
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