USE Diablo
GO

--Problem 1

SELECT *
FROM 
ORDER BY 

--Problem 2

SELECT *
FROM 
ORDER BY 

--Problem 3

SELECT *
FROM 
ORDER BY 

--Problem 4

SELECT *
FROM 
ORDER BY 

--Problem 5

SELECT *
FROM 
ORDER BY 

--Problem 6

SELECT *
FROM 
ORDER BY 

--Problem 7

SELECT *
FROM 
ORDER BY 

--Problem 8

SELECT *
FROM 
ORDER BY 

--Problem 9

SELECT *
FROM 
ORDER BY 

--Problem 10

SELECT *
FROM 
ORDER BY 

--Problem 11

SELECT *
FROM 
ORDER BY

--Problem 12

SELECT *
FROM 
ORDER BY

--Problem 13

USE Ads
GO

IF OBJECT_ID('Countries') IS NOT NULL
  DROP TABLE Countries

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

UPDATE Ads
SET TownId = (SELECT t.Id FROM Towns t WHERE t.Name = 'Paris')
WHERE DATENAME(WEEKDAY,Date) = 'Friday'
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
---------------------------------------------------------------------
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
----------------------------------------------------------------------

INSERT INTO Ads (Title, Text, OwnerId, Date, StatusId)
VALUES('Free Book',
'Free C# Book', 
(SELECT Id FROM AspNetUsers WHERE Name = 'nakov'),
getdate(),
(SELECT Id FROM AdStatuses WHERE Status = 'Waiting Approval'))
GO

SELECT *
FROM Countries
ORDER BY CountryCode

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

--Problem 15

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

--Problem 16

DROP DATABASE IF EXISTS `Job Portal`;

CREATE DATABASE `Job Portal`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `Job Portal`;

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` nvarchar(45) NOT NULL,
  `fullname` nvarchar(45),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `job_ads`;

CREATE TABLE `job_ads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` nvarchar(100) NOT NULL,
  `description` text,
  `author_id` int(11) not null,
  `salary_id` int(11) not null,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_job_ads_users`
    FOREIGN KEY (`author_id`) 
    REFERENCES `users` (`id`),
  CONSTRAINT `fk_job_ads_salaries` 
    FOREIGN KEY (`salary_id`) 
    REFERENCES `salaries` (`id`)
);

DROP TABLE IF EXISTS `salaries`;

CREATE TABLE `salaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_value` decimal(10,2) NOT NULL,
  `to_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `job_ad_applications`;

CREATE TABLE `job_ad_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_ad_id` int(11) not null,
  `user_id` int(11) not null,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_job_ad_applications_job_ads`
    FOREIGN KEY (`job_ad_id`) 
    REFERENCES `job_ads` (`id`),
  CONSTRAINT `fk_job_ad_applications_users` 
    FOREIGN KEY (`user_id`) 
    REFERENCES `users` (`id`)
);

insert into users (username, fullname)
values ('pesho', 'Peter Pan'),
('gosho', 'Georgi Manchev'),
('minka', 'Minka Dryzdeva'),
('jivka', 'Jivka Goranova'),
('gago', 'Georgi Georgiev'),
('dokata', 'Yordan Malov'),
('glavata', 'Galin Glavomanov'),
('petrohana', 'Peter Petromanov'),
('jubata', 'Jivko Jurandov'),
('dodo', 'Donko Drozev'),
('bobo', 'Bay Boris');

insert into salaries (from_value, to_value)
values (300, 500),
(400, 600),
(550, 700),
(600, 800),
(1000, 1200),
(1300, 1500),
(1500, 2000),
(2000, 3000);

insert into job_ads (title, description, author_id, salary_id)
values ('PHP Developer', NULL, (select id from users where username = 'gosho'), (select id from salaries where from_value = 300)),
('Java Developer', 'looking to hire Junior Java Developer to join a team responsible for the development and maintenance of the payment infrastructure systems', (select id from users where username = 'jivka'), (select id from salaries where from_value = 1000)),
('.NET Developer', 'net developers who are eager to develop highly innovative web and mobile products with latest versions of Microsoft .NET, ASP.NET, Web services, SQL Server and related applications.', (select id from users where username = 'dokata'), (select id from salaries where from_value = 1300)),
('JavaScript Developer', 'Excellent knowledge in JavaScript', (select id from users where username = 'minka'), (select id from salaries where from_value = 1500)),
('C++ Developer', NULL, (select id from users where username = 'bobo'), (select id from salaries where from_value = 2000)),
('Game Developer', NULL, (select id from users where username = 'jubata'), (select id from salaries where from_value = 600)),
('Unity Developer', NULL, (select id from users where username = 'petrohana'), (select id from salaries where from_value = 550));

insert into job_ad_applications(job_ad_id, user_id)
values 
	((select id from job_ads where title = 'C++ Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = 'Game Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = 'Java Developer'), (select id from users where username = 'gosho')),
	((select id from job_ads where title = '.NET Developer'), (select id from users where username = 'minka')),
	((select id from job_ads where title = 'JavaScript Developer'), (select id from users where username = 'minka')),
	((select id from job_ads where title = 'Unity Developer'), (select id from users where username = 'petrohana')),
	((select id from job_ads where title = '.NET Developer'), (select id from users where username = 'jivka')),
	((select id from job_ads where title = 'Java Developer'), (select id from users where username = 'jivka'));

select u.username, u.fullname, ja.title as Job, s.from_value as 'From Value', s.to_value as 'To Value'
from job_ad_applications jaa
join job_ads ja
on jaa.job_ad_id = ja.Id
join users u
on jaa.user_id = u.Id
join salaries s
on ja.salary_id = s.Id
order by u.username, ja.title