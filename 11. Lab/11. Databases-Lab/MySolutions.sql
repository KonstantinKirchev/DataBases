USE Forum
GO
--Problem 1
SELECT Title
FROM Questions
ORDER BY Title
--Problem 2
SELECT Content, CreatedOn 
FROM Answers
WHERE CreatedOn BETWEEN '15-Jun-2012' AND '22-Mar-2013'
ORDER BY CreatedOn, Id
--Problem 3
SELECT Username, LastName, IIF(PhoneNumber IS NULL,0,1) AS [Has Phone]
FROM Users
ORDER BY LastName, Id
--Problem 4
SELECT q.Title AS [Question Title] , u.Username AS Author
FROM Questions q
JOIN Users u
ON q.UserId = u.Id
ORDER BY q.Id
--Problem 5
SELECT a.Content AS [Answer Content], a.CreatedOn, u.Username AS [Answer Author], q.Title AS [Question Title], c.Name AS [Category Name] 
FROM Answers a
JOIN Questions q
ON a.QuestionId = q.Id
JOIN Categories c
ON q.CategoryId = c.Id
JOIN Users u
ON a.UserId = u.Id
ORDER BY c.Name, u.Username, a.CreatedOn
--Problem 6
SELECT c.Name, q.Title, q.CreatedOn
FROM Categories c
LEFT JOIN Questions q
ON q.CategoryId = c.Id
ORDER BY c.Name
--Problem 7
SELECT DISTINCT u.Id, u.Username, u.FirstName, u.PhoneNumber, u.RegistrationDate, u.Email
FROM Users u
WHERE u.PhoneNumber IS NULL AND u.Id IN (SELECT u.Id
FROM Users u
LEFT JOIN Questions q
ON q.UserId = u.Id
WHERE q.UserId IS NULL)
ORDER BY u.RegistrationDate
------------------------------------------------
--Second Version
SELECT u.Id, u.Username, u.FirstName, u.PhoneNumber, u.RegistrationDate, u.Email
FROM Users u
LEFT OUTER JOIN Questions q
	ON q.UserId = u.Id
WHERE PhoneNumber IS NULL AND q.Id is NULL
ORDER BY RegistrationDate
------------------------------------------------
--Problem 8
SELECT MIN(CreatedOn) AS MinDate , MAX(CreatedOn) AS MaxDate
FROM Answers
WHERE CreatedOn BETWEEN '2012' AND '2015'
------------------------------------------------
--Second Version
SELECT TOP 1 a1.CreatedOn AS MinDate, a2.CreatedOn AS MaxDate
FROM Answers a1, Answers a2
WHERE MONTH(a1.CreatedOn) = (SELECT MIN(MONTH(a1.CreatedOn)) FROM Answers a1 WHERE YEAR(a1.CreatedOn) = '2012')
AND YEAR(a1.CreatedOn) = '2012'
AND MONTH(a2.CreatedOn) = (SELECT MAX(MONTH(a2.CreatedOn)) FROM Answers a2 WHERE YEAR(a2.CreatedOn) = '2014')
AND YEAR(a2.CreatedOn) = '2014'
ORDER BY a1.CreatedOn, a2.CreatedOn DESC
------------------------------------------------
--Problem 9
SELECT TOP 10 a.Content, a.CreatedOn, u.Username 
FROM Answers a
JOIN Users u
ON a.UserId = u.Id
ORDER BY a.CreatedOn 
--Problem 10
SELECT a.Content AS [Answer Content], q.Title AS Question, c.Name AS Category
FROM Answers a
JOIN Questions q
ON a.QuestionId = q.Id
JOIN Categories c
ON q.CategoryId = c.Id
WHERE YEAR(a.CreatedOn) = 2015 AND MONTH(a.CreatedOn) = 1
ORDER BY c.Name
-----------------------------------------------------------------
--Second Version
SELECT a.Content [Answer Content], q.Title [Question], c.Name [Category]
FROM Answers a
JOIN Questions q 
	ON q.Id = a.QuestionId
JOIN Categories c
	ON q.CategoryId = c.Id
WHERE 
	(MONTH(a.CreatedOn) = (SELECT MONTH(MIN(CreatedOn)) FROM Answers) OR MONTH(a.CreatedOn) = (SELECT MONTH(MAX(CreatedOn)) FROM Answers))
	AND YEAR(a.CreatedOn) = (SELECT YEAR(MAX(CreatedOn)) FROM Answers)
	AND	IsHidden = 1
ORDER BY c.Name
------------------------------------------------------------
--Problem 11
SELECT c.Name AS Category, COUNT(a.Id) AS [Answers Count]
FROM Categories c
LEFT JOIN Questions q
ON q.CategoryId = c.Id
LEFT JOIN Answers a
ON a.QuestionId = q.Id
GROUP BY c.Name
ORDER BY [Answers Count] DESC
--Problem 12
SELECT c.Name AS Category, u.Username, u.PhoneNumber, COUNT(a.Id) AS [Answers Count]
FROM Categories c
LEFT JOIN Questions q
ON q.CategoryId = c.Id
LEFT JOIN Answers a
ON a.QuestionId = q.Id
LEFT JOIN Users u
ON a.UserId = u.Id
GROUP BY c.Name, u.Username, u.PhoneNumber
HAVING COUNT(a.Id) > 0 AND u.PhoneNumber IS NOT NULL
ORDER BY [Answers Count] DESC
--Problem 13
---- Task 1

CREATE TABLE Towns(
	Id int NOT NULL IDENTITY PRIMARY KEY,
	Name nvarchar(50) NOT NULL
)
GO

ALTER TABLE Users ADD TownId int
GO

ALTER TABLE Users ADD CONSTRAINT FK_Users_Towns
FOREIGN KEY(TownId) REFERENCES Towns(Id)
GO

---- Task 2

INSERT INTO Towns(Name) VALUES ('Sofia'), ('Berlin'), ('Lyon')

UPDATE Users SET TownId = (SELECT Id FROM Towns WHERE Name='Sofia')

INSERT INTO Towns VALUES
('Munich'), ('Frankfurt'), ('Varna'), ('Hamburg'), ('Paris'), ('Lom'), ('Nantes')

---- Task 3

UPDATE Users
SET TownId = (SELECT Id FROM Towns WHERE Name='Paris')
WHERE DATEPART(weekday, RegistrationDate) = 6

---- Task 4

UPDATE Answers
SET QuestionId = (SELECT Id FROM Questions WHERE Title = 'Java += operator')
WHERE 
	(DATEPART(weekday, CreatedOn) = 1 or DATEPART(weekday, CreatedOn) = 2)
	and 
	MONTH(CreatedOn) = 2
	
---- Task 5
BEGIN TRAN

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

ROLLBACK TRAN
---- Task 6

INSERT INTO Questions(Title, Content, CategoryId, UserId, CreatedOn)
VALUES (
	'Fetch NULL values in PDO query', 
	'When I run the snippet, NULL values are converted to empty strings. How can fetch NULL values?', 
	(SELECT Id FROM Categories WHERE Name='Databases'),
	(SELECT Id FROM Users WHERE UserName='darkcat'), 
	GETDATE())
	
---- Task 7

SELECT t.Name as Town, u.Username as Username, COUNT(a.Id) as AnswersCount
FROM
  Answers a
  FULL OUTER JOIN Users u ON u.Id = a.UserId
  FULL OUTER JOIN Towns t ON u.TownId = t.Id
GROUP BY t.Name, u.Username
ORDER BY AnswersCount DESC, u.Username
--Problem 14
USE Forum
GO
CREATE VIEW AllQuestions
AS
SELECT u.Id AS UId, u.Username, u.FirstName, u.LastName, u.Email, u.PhoneNumber, u.RegistrationDate,
q.Id AS QId, q.Title, q.Content, q.CategoryId, q.UserId, q.CreatedOn
FROM Questions q
RIGHT JOIN Users u
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
		SELECT Username  FROM Users
		ORDER BY UserName
	OPEN UsersCursor;
	DECLARE @username NVARCHAR(MAX);
	FETCH NEXT FROM UsersCursor INTO @username;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @questions NVARCHAR(MAX) = NULL;
		SELECT
			@questions = CASE
				WHEN @questions IS NULL THEN Title
				ELSE @questions + ', ' + Title
			END
		FROM AllQuestions
		WHERE UserName  = @username
		ORDER BY Title DESC

		INSERT INTO @tbl_UsersQuestions
		VALUES(@username, @questions)
		
		FETCH NEXT FROM UsersCursor INTO @username;
	END;
	CLOSE UsersCursor;
	DEALLOCATE UsersCursor;
	RETURN;
END
GO

SELECT * FROM fn_ListUsersQuestions()
