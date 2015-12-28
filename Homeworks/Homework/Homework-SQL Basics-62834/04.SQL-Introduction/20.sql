USE SoftUni;
GO

SELECT e.FirstName, e.MiddleName, e.LastName, e.JobTitle, m.ManagerID
FROM Employees e
INNER JOIN Employees m
ON e.EmployeeID = m.ManagerID;
GO