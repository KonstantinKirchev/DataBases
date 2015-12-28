USE SoftUni;
GO

SELECT e.FirstName, e.LastName, e.JobTitle, m.ManagerId
FROM Employees e
LEFT OUTER JOIN Employees m ON e.EmployeeID = m.ManagerID;
GO

SELECT e.FirstName, e.LastName, e.JobTitle, m.ManagerId
FROM Employees e
RIGHT OUTER JOIN Employees m ON e.EmployeeID = m.ManagerID;
GO