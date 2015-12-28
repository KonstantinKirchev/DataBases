USE SoftUni;
GO

SELECT e.FirstName, e.LastName, e.JobTitle, m.ManagerId, a.AddressText
FROM Employees e
INNER JOIN Employees m ON e.EmployeeID = m.ManagerID
INNER JOIN Addresses a ON e.EmployeeID = a.AddressID;
GO