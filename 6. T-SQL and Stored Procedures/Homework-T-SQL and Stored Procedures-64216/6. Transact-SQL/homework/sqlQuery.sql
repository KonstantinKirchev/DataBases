CREATE DATABASE BankAccounts
GO

USE BankAccounts
GO

/*Problem 1.	
Create a database with two tables
Persons (id (PK), first name, last name, SSN) and 
Accounts (id (PK), person id (FK), balance). 
Insert few records for testing. 
Write a stored procedure that selects the full names of all persons.
*/
IF OBJECT_ID('Persons', N'U') IS NOT NULL
DROP TABLE Persons
GO

CREATE TABLE dbo.Persons
(
    Id int IDENTITY(1,1) NOT NULL,
    FirstName	NVARCHAR(100) NULL,
	LastName NVARCHAR(100) NULL,
	SSN	NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_PERSONS PRIMARY KEY(Id) 
);
GO

IF OBJECT_ID('Accounts', N'U') IS NOT NULL
DROP TABLE Accounts
GO

CREATE TABLE dbo.Accounts
(
    Id int IDENTITY(1,1) NOT NULL,
    PersonId int NOT NULL,
	Balance MONEY NOT NULL DEFAULT 0,
	CONSTRAINT PK_Accounts PRIMARY KEY(Id),
	CONSTRAINT FK_Accounts_Persons FOREIGN KEY(PersonId) REFERENCES Persons(Id)
);
GO

INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Mango', 'Mangov', 'no security number')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Boris', 'Tupalov', '5409124576')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Damyan', 'Hristov', '7905124578')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Hristina', 'Penkova', '6565165164')
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('Bogdan', 'Kaloyanov', '8941654951')

INSERT INTO Accounts (PersonId, Balance)
	VALUES (1, 340.56)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (2, 8500.56)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (3, 9320.56)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (4, 5340.56)
INSERT INTO Accounts (PersonId, Balance)
	VALUES (5, 389.56)
GO

IF OBJECT_ID('usp_GetFullNames') IS NOT NULL
DROP PROC usp_GetFullNames
GO

CREATE PROCEDURE dbo.usp_GetFullNames 
AS SELECT
	CONCAT(FirstName, ' ', LastName) AS [Full Name]
FROM Persons
GO

EXEC dbo.usp_GetFullNames
GO

/*Problem 2.	Create a stored procedure
Your task is to create a stored procedure that accepts a number as 
a parameter and returns all persons who have more money in their 
accounts than the supplied number.
*/

IF OBJECT_ID('usp_GetReacherPersons') IS NOT NULL
DROP PROC usp_GetReacherPersons
GO

CREATE PROCEDURE dbo.usp_GetReacherPersons (@limit MONEY)
AS
SELECT
	p.FirstName,
	p.LastName,
	p.SSN,
	a.Balance
FROM Persons p
JOIN Accounts a
	ON p.Id = a.PersonId
WHERE a.Balance > @limit
GO

EXEC dbo.usp_GetReacherPersons 500
EXEC dbo.usp_GetReacherPersons 5400
GO

/*Problem 3.	Create a function with parameters
Your task is to create a function that accepts as parameters ?
 sum, yearly interest rate and number of months. 
 It should calculate and return the new sum. 
 Write a SELECT to test whether the function works as expected.
*/
IF OBJECT_ID('ufn_CalculateBalanceWithInterest') IS NOT NULL
DROP FUNCTION ufn_CalculateBalanceWithInterest
GO

CREATE FUNCTION dbo.ufn_CalculateBalanceWithInterest
(
    @sum MONEY,
	@yearlyInterestRate MONEY,
	@monthsCount DECIMAL(6,2)
)
RETURNS INT
AS
BEGIN
	DECLARE @RESULT AS MONEY
SET @RESULT = @sum + @sum * @monthsCount * @yearlyInterestRate / (12 * 100)
RETURN @RESULT
END
GO

SELECT
	dbo.ufn_CalculateBalanceWithInterest(3500, 8.9, 12) AS [Final Balance]
GO

/*Problem 4.	
Create a stored procedure that uses the function from the previous example.
Your task is to create a stored procedure that uses the function from the
previous example to give an interest to a person's account for one month. 
It should take the AccountId and the interest rate as parameters.
*/
 IF OBJECT_ID('usp_CalculateBalanceWithInterest') IS NOT NULL
DROP PROC usp_CalculateBalanceWithInterest
GO

CREATE PROCEDURE dbo.usp_CalculateBalanceWithInterest 
    @accountId int,
    @interestRate MONEY  
AS
	DECLARE @initialBalance MONEY
SET @initialBalance = (SELECT
	Balance
FROM Accounts
WHERE Id = @accountId)
--select  [dbo].[fn_CalculateBalanceWithInterest](@initialBalance, @interestRate, 1)
RETURN dbo.ufn_CalculateBalanceWithInterest(@initialBalance, @interestRate, 1)

EXEC dbo.usp_CalculateBalanceWithInterest	2,
											5.00
GO
/*Problem 5.	Add two more stored procedures WithdrawMoney and DepositMoney.
Add two more stored procedures WithdrawMoney (AccountId, money) and
 DepositMoney (AccountId, money) that operate in transactions.
*/
IF OBJECT_ID('usp_WithdrawMoney') IS NOT NULL
DROP PROC usp_WithdrawMoney
GO

CREATE PROCEDURE dbo.usp_WithdrawMoney 
    @AccountId INT ,
    @Amount  INT
AS

DECLARE @FinalBalance MONEY
DECLARE @Limit MONEY = 0

SET @FinalBalance = (SELECT
	Balance
FROM Accounts
WHERE Id = @AccountId)
- @Amount

BEGIN TRAN CandidateWithdrawal
WITH MARK N'Subtracts some amount of money from existing bank account. Does not allow the account to have negative balace after withdrawal!'

IF @FinalBalance < @Limit BEGIN
RAISERROR (N'Insufficient amount', 16, 2)
ROLLBACK TRAN
END ELSE BEGIN
UPDATE Accounts
SET Balance = @FinalBalance
WHERE Id = @AccountId
COMMIT TRAN
END
GO

EXEC dbo.usp_WithdrawMoney	2,
							22000
EXEC dbo.usp_WithdrawMoney	2,
							220
GO

IF OBJECT_ID('usp_DepositMoney') IS NOT NULL
DROP PROC usp_DepositMoney
GO

CREATE PROC dbo.usp_DepositMoney
	@AccountId INT,
	@Amount MONEY
AS
	DECLARE @FinalAmount MONEY
	BEGIN TRAN CandidateDeposit WITH MARK N'Adds a given amount to a Bank account. Does not allow negative amount to be added!'
	IF @Amount < 0		BEGIN
		RAISERROR(N'You are not allowed to deposit negative amounts', 16, 2)
		ROLLBACK TRAN
	END
SET @FinalAmount = (SELECT
	Balance
FROM Accounts
WHERE Id = @AccountId)
+ @Amount
UPDATE Accounts
SET Balance = @FinalAmount
WHERE Id = @AccountId
COMMIT TRAN
GO

EXEC dbo.usp_DepositMoney	2,
							220
GO

/*Problem 6.	Create table Logs.
Create another table ? Logs (LogID, AccountID, OldSum, NewSum).
 Add a trigger to the Accounts table that enters a new entry into the Logs 
 table every time the sum on an account changes.
*/

USE BankAccounts
GO
IF OBJECT_ID('Logs', N'U') IS NOT NULL
DROP TABLE Logs
GO

CREATE TABLE Logs(
	Id INT IDENTITY(1,1) NOT NULL,
	AccountId INT NULL,
	OldBalance MONEY NULL, 
	NewBalance MONEY NULL,
	CONSTRAINT PK_Logs PRIMARY KEY(Id),
	CONSTRAINT FK_Logs_Accounts FOREIGN KEY(AccountId) REFERENCES Accounts(Id)
);
GO

IF OBJECT_ID('TR_OnAccountBalanceUpdate', 'TR') IS NOT NULL
DROP TRIGGER TR_OnBalanceUpdate
GO

CREATE TRIGGER TR_OnAccountBalanceUpdate
    ON [dbo].[Accounts]
    FOR UPDATE, INSERT
    AS
    BEGIN
SET NOCOUNT ON
INSERT INTO Logs (AccountId, OldBalance, NewBalance)
	VALUES ((SELECT Id FROM INSERTED), (SELECT Balance FROM DELETED), (SELECT Balance FROM INSERTED))
END
GO

INSERT INTO Accounts (PersonId, Balance)
	VALUES (4, 4444.44)
EXEC dbo.usp_DepositMoney	2,
							220
EXEC dbo.usp_WithdrawMoney	2,
							22000
EXEC dbo.usp_WithdrawMoney	2,
							220
GO

/*Problem 7.	Define function in the SoftUni database.
Define a function in the database SoftUni that returns all Employees' names 
(first or middle or last name) and all town's names that are comprised of
 given set of letters. 
Example: 'oistmiahf' will return 'Sofia', 'Smith', but not 'Rob' and 'Guy'.
*/
USE SoftUni
GO

IF OBJECT_ID('ufn_ConsistsOfCharSet') IS NOT NULL
DROP FUNCTION ufn_ConsistsOfCharSet
GO
CREATE FUNCTION dbo.ufn_ConsistsOfCharSet
(
    @CheckString NVARCHAR(MAX),
	@Pattern NVARCHAR(255)
)
RETURNS INT
AS
BEGIN
	DECLARE @Index INT = 1
	DECLARE @CurrentChar NVARCHAR(1)
	DECLARE @CheckStringLength INT = LEN(@CheckString)
	WHILE @Index <= @CheckStringLength
		BEGIN
		SET	@CurrentChar = SUBSTRING(@CheckString, @Index, 1)
			IF(CHARINDEX(@CurrentChar, @Pattern) <= 0)
				BEGIN
					RETURN 0
				END
				SET @Index += 1
		END
    RETURN 1

END
GO
--TESTS
--SELECT dbo.ufn_ConsistsOfCharSet('Sofia','safkio')
--SELECT dbo.ufn_ConsistsOfCharSet('Rob','oistmiahf' )
--SELECT dbo.ufn_ConsistsOfCharSet('Smith','oistmiahf' )
--GO

IF OBJECT_ID('ufn_GetNamesAndTownsFromCharset') IS NOT NULL
DROP FUNCTION ufn_GetNamesAndTownsFromCharset
GO
CREATE FUNCTION dbo.ufn_GetNamesAndTownsFromCharset
(
    @Charset NVARCHAR(MAX)
)
RETURNS @NamesAndTownsFromCharset TABLE 
(
	[Names or Towns] NVARCHAR(100)
)
AS
BEGIN
	DECLARE @NameOrTown NVARCHAR(100)
	DECLARE cursor_ConsistsOfCharSet CURSOR FOR
		SELECT FirstName AS [Names or Towns] FROM Employees
		UNION
		SELECT MiddleName AS [Names or Towns] FROM Employees
		UNION
		SELECT LastName AS [Names or Towns] FROM Employees
		UNION
		SELECT Name AS [Names or Towns] FROM Towns

	OPEN cursor_ConsistsOfCharSet
	FETCH NEXT FROM cursor_ConsistsOfCharSet INTO @NameOrTown

	WHILE @@fetch_status = 0 BEGIN
		IF(dbo.ufn_ConsistsOfCharSet(@NameOrTown, @Charset) = 1)
			BEGIN
				INSERT INTO @NamesAndTownsFromCharset([Names or Towns]) VALUES(@NameOrTown)
			END
		FETCH NEXT FROM cursor_ConsistsOfCharSet INTO @NameOrTown
	END

	CLOSE cursor_ConsistsOfCharSet
	DEALLOCATE cursor_ConsistsOfCharSet

    RETURN 
END
GO

--TESTS
SELECT * FROM dbo.ufn_GetNamesAndTownsFromCharset('oistmiahf')
SELECT * FROM dbo.ufn_GetNamesAndTownsFromCharset('redmond')
GO

/*Problem 8.	Using database cursor write a T-SQL
Using database cursor write a T-SQL script that scans all employees and 
their addresses and prints all pairs of employees that live in the same town.
*/

DECLARE empCursor CURSOR READ_ONLY FOR
 
SELECT a.FirstName, a.LastName, t1.Name, b.FirstName, b.LastName
FROM Employees a
JOIN Addresses adr
ON a.AddressID = adr.AddressID
JOIN Towns t1
ON adr.TownID = t1.TownID,
 Employees b
JOIN Addresses ad
ON b.AddressID = ad.AddressID
JOIN Towns t2
ON ad.TownID = t2.TownID
WHERE t1.Name = t2.Name
  AND a.EmployeeID <> b.EmployeeID
ORDER BY a.FirstName, b.FirstName
 
OPEN empCursor
DECLARE @firstName1 NVARCHAR(50)
DECLARE @lastName1 NVARCHAR(50)
DECLARE @town NVARCHAR(50)
DECLARE @firstName2 NVARCHAR(50)
DECLARE @lastName2 NVARCHAR(50)
FETCH NEXT FROM empCursor
        INTO @firstName1, @lastName1, @town, @firstName2, @lastName2
 
WHILE @@FETCH_STATUS = 0
        BEGIN
                PRINT @firstName1 + ' ' + @lastName1 +
                        '     ' + @town + '      ' + @firstName2 + ' ' + @lastName2
                FETCH NEXT FROM empCursor
                        INTO @firstName1, @lastName1, @town, @firstName2, @lastName2
        END
 
CLOSE empCursor
DEALLOCATE empCursor
 
 
/*Problem 9.	Define a .NET aggregate function
Define a .NET aggregate function StrConcat that takes as input a sequence of strings
 and return a single string that consists of the input strings separated by ','. 
 For example the following SQL statement should return a single string:
	SELECT StrConcat (FirstName + ' ' + LastName)
	FROM Employees*/

CREATE SCHEMA Aggregates
GO
CREATE ASSEMBLY SQLAggregateFunctions
	AUTHORIZATION dbo
	FROM	'E:\ttittoIT\GitHub\Databases\TransactSQLHW\SQLAggregateFunctions.dll'
	WITH PERMISSION_SET=SAFE
GO

CREATE AGGREGATE dbo.StrConcat(@String nvarchar(max), @Delimiter nvarchar(30)) 
RETURNS nvarchar(max)
EXTERNAL NAME SQLAggregateFunctions.[SQLAggregateFunctions.StrConcat]
GO

EXEC SP_CONFIGURE 'show advanced options' , '1';
GO
RECONFIGURE;
GO
EXEC SP_CONFIGURE 'clr enabled' , '1'
GO
RECONFIGURE;
GO

USE SoftUni
GO

SELECT dbo.StrConcat(FirstName+' '+LastName, ', ')
FROM dbo.Employees

/*Problem 10.	*Write a T-SQL script
Write a T-SQL script that shows for each town a list of all employees that live in it.
 Sample output:
Sofia -> Svetlin Nakov, Martin Kulov, Vladimir Georgiev
Ottawa -> Jose Saraiva, 
? */

USE SoftUni
GO

DECLARE CURSOR_EmployeesInSameTown CURSOR READ_ONLY FOR
SELECT e.FirstName, e.LastName , t.Name AS TownName
FROM Employees e JOIN Addresses a
	ON a.AddressID=e.AddressID
JOIN Towns t
	ON t.TownID=a.TownID
GROUP BY t.TownID, e.FirstName, e.LastName, t.Name

OPEN CURSOR_EmployeesInSameTown 
DECLARE @FirstName nvarchar(50), @LastName nvarchar(50), @TownName nvarchar(50),@LastTownName nvarchar(50),
 @EmpInSameTown nvarchar(max)

FETCH NEXT FROM CURSOR_EmployeesInSameTown INTO @FirstName, @LastName, @TownName 
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TownName = @LastTownName
			SET @EmpInSameTown += @FirstName + ' ' + @LastName + ', '
		ELSE
			BEGIN 
			PRINT @EmpInSameTown
			SET @LastTownName =  @TownName
			SET @EmpInSameTown = @TownName + ' -> '
			END
	FETCH NEXT FROM CURSOR_EmployeesInSameTown INTO @FirstName, @LastName, @TownName 
	END

CLOSE CURSOR_EmployeesInSameTown 
DEALLOCATE CURSOR_EmployeesInSameTown 
GO