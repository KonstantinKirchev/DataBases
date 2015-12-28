CREATE PROC usp_WithdrawMoney (@accountId int, @money money) 
AS
DECLARE @oldSum money
SELECT
	@oldSum = Balance
FROM Accounts
WHERE Id = @accountId
IF (@money < 0) BEGIN
RAISERROR ('The amount must be positive.', 16, 1)
END
IF (@money > @oldSum) BEGIN
RAISERROR ('the amount should be less than the balance.', 16, 1)
END
UPDATE Accounts
SET Balance = (Balance - @money)
WHERE Accounts.Id = @accountId

GO
EXEC usp_WithdrawMoney	1,
						11500

GO
CREATE PROC usp_DepositMoney (@accountId int, @money money) 
AS
IF (@money < 0) BEGIN
RAISERROR ('the amount must be a positive number', 16, 1)
END
UPDATE Accounts
SET Balance = Balance + @money
WHERE Accounts.Id = @accountId
GO
EXEC usp_DepositMoney	1,
						21500
GO
SELECT
	p.FirstName,
	p.LastName,
	a.Balance
FROM Persons p
JOIN Accounts a
	ON a.PersonId = p.Id