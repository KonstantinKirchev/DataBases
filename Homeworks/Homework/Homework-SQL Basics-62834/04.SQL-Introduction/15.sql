USE SoftUni;
GO

SELECT FirstName, MiddleName, LastName, JobTitle, Salary, ManagerID
FROM Employees
WHERE ManagerID IS NULL
ORDER BY Salary ASC;
GO