CREATE PROC usp_MonthlyInterest(@accountId int, @interestRate money)
AS
DECLARE @oldSum money
SELECT
	@oldSum = Balance
FROM Accounts
WHERE Id = @accountId

DECLARE @newSum MONEY = dbo.ufn_CalculateInterest(@oldSum, @interestRate, 1)

SELECT
	p.FirstName,
	p.LastName,
	@newSum - @oldSum AS [Month interest]
FROM Persons p
JOIN Accounts a
	ON p.Id = a.PersonId
WHERE @accountId = a.Id
GO

EXEC usp_MonthlyInterest	1, 5