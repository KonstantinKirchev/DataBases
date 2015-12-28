ALTER FUNCTION ufn_CalculateInterest(@sum money,@interestRate money, @numberOfMonths int)
RETURNS money
AS
BEGIN
DECLARE @yearInterest money = @sum * @interestRate / 100
DECLARE @monthInterest money = @yearInterest / 12
DECLARE @finalSum money = (@monthInterest * @numberOfMonths) + @sum
RETURN @finalSum
 
END

GO
SELECT
	FirstName + ' ' + LastName AS [Full Name],
	dbo.ufn_CalculateInterest(a.Balance, 5, 24) AS BalanceAfterInterest
FROM Persons p
JOIN Accounts a
	ON a.PersonId = p.Id