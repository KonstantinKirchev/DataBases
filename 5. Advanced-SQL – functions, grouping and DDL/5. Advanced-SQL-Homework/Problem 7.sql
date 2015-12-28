SELECT COUNT(e.EmployeeID) AS [Employees with manager]
FROM Employees e
JOIN Employees m
ON m.EmployeeID = e.ManagerID
