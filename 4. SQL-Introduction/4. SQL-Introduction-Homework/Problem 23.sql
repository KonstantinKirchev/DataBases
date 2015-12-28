SELECT e.FirstName+' '+e.LastName AS [Employee Full Name], m.FirstName+' '+m.LastName AS [Manager Full Name]
FROM Employees e
LEFT OUTER JOIN Employees m
ON e.ManagerID = m.EmployeeID