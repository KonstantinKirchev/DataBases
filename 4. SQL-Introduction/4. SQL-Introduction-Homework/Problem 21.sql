SELECT e.FirstName+' '+e.LastName AS [Emp Full Name], m.FirstName+' '+m.LastName AS [Mng Full Name], a.AddressText AS [Address]
FROM Employees e
JOIN Employees m
ON e.ManagerID = m.EmployeeID
JOIN Addresses a
ON e.AddressID = a.AddressID