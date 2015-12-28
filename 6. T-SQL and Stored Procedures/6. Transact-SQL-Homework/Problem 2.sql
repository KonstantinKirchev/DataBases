CREATE PROC usp_FilterPersonsByBalance(@balance int = 0)
AS
SELECT p.FirstName, p.LastName, a.Balance
FROM Persons p
JOIN Accounts a
ON a.PersonId = p.Id AND a.Balance > @balance

GO 

EXEC usp_FilterPersonsByBalance 20000
