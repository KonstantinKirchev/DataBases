USE SoftUni;
GO

SELECT e.FirstName, e.LastName, a.AddressText
FROM Employees e, Addresses a
WHERE e.EmployeeID = a.AddressID;
GO