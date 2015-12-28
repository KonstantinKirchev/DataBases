
----------------- Problem 1.------------------------
/*
+ Create a database with two tables
+ Persons (id (PK), first name, last name, SSN) and 
+ Accounts (id (PK), person id (FK), balance). 
+ Insert few records for testing. 
Write a stored procedure that selects the full names of all persons.
*/

--create Database
USE master
GO
CREATE DATABASE TransactHomeWorkDB
GO
USE TransactHomeWorkDB
GO
-- create 2 tables Persons and Accounts
CREATE TABLE Persons (
Id int IDENTITY NOT NULL,
FirstName nvarchar(20) NOT NULL,
LastName nvarchar(20) NOT NULL,
SSN nvarchar(10) NOT NULL,
CONSTRAINT PK_Persons PRIMARY KEY CLUSTERED(Id ASC) )
GO

CREATE TABLE Acounts (
Id int IDENTITY NOT NULL,
PersonId int NOT NULL  FOREIGN KEY REFERENCES Persons(Id),
Balance money not null default 0,
CONSTRAINT PK_Acounts PRIMARY KEY CLUSTERED(Id ASC),
CONSTRAINT uc_PersonID UNIQUE (PersonId))
GO

-- Insert few records for testing. 
INSERT INTO Persons (FirstName, LastName, SSN)
	VALUES ('A', 'A', '1111111111'), ('C', 'C', '2222222222'), ('B', 'B', '3333333333')

INSERT INTO Acounts (PersonId, Balance)
	VALUES ('2', 1000.00), ('3', 500), ('1', 0);
GO

-- Stored procedure that selects the full names of all persons.
CREATE PROC USP_getFullNamePersons AS
SELECT
	Id [No.],
	FirstName + ' ' + LastName [FULL NAME]
FROM Persons
GO

EXEC USP_getFullNamePersons
GO
--------------- END Problem 1 ----------------------
--************************************************--

----------------- Problem 2 ------------------------
/*Create a stored procedure
that accepts a number as a parameter and 
returns all persons who have more money in their accounts than the supplied number.
*/

CREATE proc usp_getPersonsWithMoreMoney (@value money) AS
SELECT
	p.Id,
	FirstName + ' ' + LastName [FULL NAME],
	a.Balance
FROM Persons p
INNER JOIN Acounts a
	ON a.PersonId = p.Id
WHERE a.Balance > @value
GO

EXEC usp_getPersonsWithMoreMoney 10
GO

--------------- END Problem 2 ----------------------
--************************************************--

----------------- Problem 3 ------------------------
/*Create a function with parameters
Your task is to create a function that accepts as parameters 
– sum, yearly interest rate and number of months.
It should calculate and return the ***new sum***. 
Write a SELECT to test whether the function works as expected.
*/

CREATE FUNCTION ufn_calculateRate (@sum money, @interest float, @months int) RETURNS  money 
AS 
BEGIN
	DECLARE @interestMontly float
	SET @interestMontly = @interest / 12
	RETURN @sum * (1 + @months * @interestMontly / 100)
END
GO

SELECT
	dbo.ufn_calculateRate(100, 4.3, 1) AS [SUM WITH Interest]
GO

--------------- END Problem 3 ----------------------
--************************************************--

----------------- Problem 4 ------------------------
/*Create a stored procedure 
that uses the function from the previous example.
to give an interest to a person's account for one month. 
It should take the AccountId and the interest rate as parameters.
*/

CREATE proc usp_OneMonthRate (@personId int, @rate float) 
AS
	DECLARE @personalBalance money
	SET @personalBalance = (SELECT a.Balance FROM Persons p
		INNER JOIN Acounts a ON a.PersonId = p.Id
		WHERE p.Id = @personId)
	DECLARE @sumWithInterest MONEY
	SET @sumWithInterest = dbo.ufn_calculateRate(@personalBalance, @rate, 1)
	SELECT @personId [Person ID], @personalBalance [Current Ballance],@sumWithInterest-@personalBalance[One Month Rate], @sumWithInterest[Balance with One Month Rate]		
GO

EXEC usp_OneMonthRate 2 , 4.3
GO
--------------- END Problem 4 ----------------------
--************************************************--

----------------- Problem 5 ------------------------
/*
Add two more stored procedures
WithdrawMoney (AccountId, money) 
DepositMoney (AccountId, money) 
that operate in transactions.
*/
-- CREATE WithdrawMoney (the procedure will trow error so to rollback transaction if the is problems)
CREATE PROC WithdrawMoney (@AccountId INT, @amount money)
AS
	DECLARE @CurrentBalance money
	SELECT @CurrentBalance = Balance FROM Acounts WHERE Id = @AccountId
	IF (@amount < 0 OR @amount > @CurrentBalance) 
		BEGIN
			RAISERROR ('*** the operation can not be performed due to incorrect amount! ***', 16, 1)
		END
	ELSE
		BEGIN
			UPDATE Acounts
			SET Balance = @CurrentBalance - @amount WHERE Id = @AccountId
		END
GO
--test procedure in transaction
BEGIN TRANSACTION
	EXEC WithdrawMoney 3, 100
	-- the balance in id=3 should be 0, 
	-- the procedure should return ERROR with MSG and the transaction should be ROLLBACK
COMMIT

BEGIN TRANSACTION
	EXEC WithdrawMoney 1, 100
	-- the balance in id=1 should be 1000
	-- the procedure should calculate new value of balance and write it in table. 
	-- the transaction shoul be COMMITED
COMMIT
GO

-- CREATE DepositMoney (the procedure will trow error so to rollback transaction if the is problems)
CREATE PROC DepositMoney (@AccountId INT, @amount money)
AS
	DECLARE @CurrentBalance money
	SELECT @CurrentBalance = Balance FROM Acounts WHERE Id = @AccountId
	IF (@amount < 0 ) 
		BEGIN
			RAISERROR ('*** the operation can not be performed due to incorrect amount! ***', 16, 1)
		END
	ELSE
		BEGIN
			UPDATE Acounts
			SET Balance = @CurrentBalance + @amount WHERE Id = @AccountId
		END
GO
--test procedure in transaction
BEGIN TRANSACTION
	EXEC DepositMoney 3, -100
	-- the balance in id=3 should be 0, 
	-- the procedure should return ERROR with MSG and the transaction should be ROLLBACK
COMMIT

BEGIN TRANSACTION
	EXEC DepositMoney 1, 100
	-- the balance in id=1 should be 900
	-- the procedure should calculate new value of balance and write it in table. 
	-- the transaction shoul be COMMITED
COMMIT
GO

--------------- END Problem 5 ----------------------
--************************************************--

----------------- Problem 6 ------------------------
/*
Create table Logs (LogID, AccountID, OldSum, NewSum). 
Add a trigger to the Accounts table 
that enters a new entry into the Logs table every time the sum on an account changes.
*/
--create Logs table
CREATE TABLE Logs (
LogID INT IDENTITY NOT NULL,
AccountID int NOT NULL  FOREIGN KEY REFERENCES Acounts(Id),
OldSum money null,
NewSum money null,
CONSTRAINT PK_Logs PRIMARY KEY CLUSTERED (LogID ASC),
)
GO
--create trigger
CREATE TRIGGER TR_AccChange on Acounts
FOR UPDATE 
AS
BEGIN
	INSERT INTO Logs (AccountID, OldSum, NewSum)
	SELECT i.Id, d.Balance, i.Balance 
	FROM INSERTED i, DELETED d
END
GO
--test the trigger
BEGIN TRANSACTION
	EXEC WithdrawMoney 1, 100
COMMIT

BEGIN TRANSACTION
	EXEC DepositMoney 1, 100
COMMIT