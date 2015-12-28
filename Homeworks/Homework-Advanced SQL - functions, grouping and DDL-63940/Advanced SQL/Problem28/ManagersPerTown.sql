SELECT t.Name, COUNT(DISTINCT m.EmployeeID) FROM Towns t
JOIN Addresses a ON t.TownID = a.TownID
JOIN Employees e ON a.AddressID = e.AddressID
JOIN Employees m ON e.ManagerID = m.EmployeeID
GROUP BY t.Name