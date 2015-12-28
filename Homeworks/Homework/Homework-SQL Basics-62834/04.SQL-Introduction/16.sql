USE SoftUni;
GO

SELECT FirstName, MiddleName, LastName, JobTitle, Salary, ManagerID
FROM Employees
WHERE Salary > 50000
ORDER BY Salary ASC;
GO