--01. --
CREATE TABLE Persons
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
SSN nvarchar(50) NOT NULL UNIQUE,
)
GO
--Accounts (id (PK), person id (FK), balance). Insert few records for testing.
CREATE TABLE Accounts
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
PersonId INT NOT NULL,
CONSTRAINT fk_PersonId FOREIGN KEY (PersonId) REFERENCES Persons(Id),
Balance MONEY
)
GO
 
--Insert some data
INSERT INTO Persons VALUES ('Gosho', 'Georgiev', '136-426-632')
INSERT INTO Persons VALUES ('Ivan', 'Ivanov', '174-135-163')
INSERT INTO Persons VALUES ('Dokror', 'Radeva', '306-760-158')
INSERT INTO Persons VALUES ('Pesho', 'Peshkov', '307-560-158')
 
INSERT INTO Accounts VALUES (1, 0)
INSERT INTO Accounts VALUES (2, 1230)
INSERT INTO Accounts VALUES (3, 10640.36)
INSERT INTO Accounts VALUES (4, 5320.24)

GO

CREATE PROC usp_FullNamesOfPersons
AS
	SELECT FirstName + ' ' + LastName as FullName FROM Persons
GO

EXEC usp_FullNamesOfPersons
GO

--02. --
CREATE PROC usp_HasMoreMoney(@amount money)
AS
	SELECT * 
	FROM Persons p
	JOIN Accounts a
		on p.Id = a.PersonId
	WHERE a.Balance > @amount
GO

EXEC usp_HasMoreMoney
	@amount = 10000
GO

--03. --
CREATE FUNCTION dbo.CalculateNewSum(@sum int, @yearlyRate int, @months int)
RETURNS int 
AS 
BEGIN
    DECLARE @monthlyInterestRate money
	SET @monthlyInterestRate = @yearlyRate / 12
	RETURN @sum * (1 + @months * @monthlyInterestRate / 100)
END;
GO

SELECT
	FirstName + ' ' + LastName AS [Full Name],
	dbo.CalculateNewSum(a.Balance, 7, 24) AS NewSum
FROM Persons p
	JOIN Accounts a
		ON a.PersonId = p.Id

--04. --
CREATE PROC usp_GiveInterest(@accountId int, @interestRate int)
AS
	SELECT 
		a.Balance,
		dbo.CalculateNewSum(a.Balance, @interestRate, 1) AS NewBalance
	FROM Accounts a
	WHERE a.Id = @accountId
GO

EXEC usp_GiveInterest
	@accountId = 1,
	@interestRate = 20
GO

--05. --
CREATE PROC usp_Withdraw(@accountId int, @money int)
AS
	UPDATE Accounts 
	SET Balance = Balance - @money
	WHERE Id = @accountId
GO

EXEC usp_Withdraw
	@accountId = 2,
	@money = 300
GO

CREATE PROC usp_Deposit(@accountId int, @money int)
AS
	UPDATE Accounts 
	SET Balance = Balance + @money
	WHERE Id = @accountId
GO

EXEC usp_Deposit
	@accountId = 2,
	@money = 300
GO

--06. --
CREATE TABLE Logs
(
LogID INT PRIMARY KEY IDENTITY NOT NULL,
AccountID INT NOT NULL,
OldSum money NOT NULL,
NewSum money NOT NULL UNIQUE,
)
GO

CREATE TRIGGER tr_SaveLog on Accounts FOR UPDATE
AS
	INSERT INTO Logs(AccountID, OldSum, NewSum)
		Values((SELECT Id FROM deleted), (SELECT Balance FROM deleted), (SELECT Balance FROM inserted)) 
GO

EXEC usp_Deposit
	@accountId = 2,
	@money = 300
GO

--07. --
USE SoftUni
GO

CREATE FUNCTION ufn_checkWord(@string nvarchar(100), @word nvarchar(100)) RETURNS INT
	BEGIN
		DECLARE  @char nvarchar(1)

		DECLARE @wcount int, @index int, @len int
		SET @wcount= 0
		SET @index = 1
		SET @len= LEN(@word)
	
		WHILE @index <= @len
		BEGIN
			set @char = SUBSTRING(@word, @index, 1)

			if CHARINDEX(@char, @string) = 0
				BEGIN
					RETURN 0
				END

			SET @index= @index+ 1
		END

		RETURN 1
	END
GO

DECLARE empCursor CURSOR READ_ONLY FOR
	(SELECT e.FirstName, e.LastName, t.Name
	FROM Employees e
		JOIN Addresses a
			ON a.AddressID = e.AddressID
		JOIN Towns t
			ON t.TownID = a.TownID)

OPEN empCursor
DECLARE @firstName nvarchar(50), @lastName nvarchar(50), @town nvarchar(50), @string nvarchar(50)
FETCH NEXT FROM empCursor INTO @firstName, @lastName, @town

SET @string = 'isofagrek'

WHILE @@FETCH_STATUS = 0
  BEGIN
    FETCH NEXT FROM empCursor INTO @firstName, @lastName, @town
	IF dbo.ufn_checkWord(@string, @firstName) = 1
		BEGIN
			print @firstName
		END	
	IF dbo.ufn_checkWord(@string, @lastName) = 1
		BEGIN
			print @lastName
		END	
	IF dbo.ufn_checkWord(@string, @town) = 1
		BEGIN
			print @town
		END	
  END

CLOSE empCursor
DEALLOCATE empCursor

GO

--08. --
DECLARE empCursor CURSOR READ_ONLY FOR SELECT
	e.FirstName + ' ' + e.LastName,
	t.Name
FROM Employees e
INNER JOIN Addresses a
	ON a.AddressID = e.AddressID
INNER JOIN Towns t
	ON t.TownID = a.TownID
		ORDER BY t.Name

OPEN empCursor
DECLARE  @town nvarchar(50),@fullName nvarchar(50) ,@currentTown nvarchar(50), @currentFullName nvarchar(50)
FETCH NEXT FROM empCursor INTO @fullName, @town
WHILE @@FETCH_STATUS = 0
  BEGIN
	SET @currentTown = @town
	SET @currentFullName = @fullName
	FETCH NEXT FROM empCursor INTO @fullName, @town

	IF( @currentTown = @town)
		PRINT @town + ': ' + @fullName + ' & ' + @currentFullName
  END
CLOSE empCursor
DEALLOCATE empCursor
GO

--09. --
EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

CREATE ASSEMBLY ConcatenateStrings
AUTHORIZATION dbo
FROM 'E:\ConcatenateStrings.dll' --- Please change the path, I have uploaded the file
WITH PERMISSION_SET = SAFE
GO
 
CREATE AGGREGATE dbo.StrConcat (@value nvarchar(MAX)) RETURNS nvarchar(MAX)
EXTERNAL NAME ConcatenateStrings.[ConcatenateStrings.StringConcatenator]

/*
DROP AGGREGATE dbo.StrConcat
DROP ASSEMBLY ConcatenateStrings
*/

USE SoftUni
SELECT dbo.StrConcat(FirstName + ' ' + LastName)
FROM Employees