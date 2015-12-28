SELECT t.Name AS Town, COUNT(e.ManagerID) AS [Number of managers]
FROM Employees e
JOIN Addresses a
ON e.AddressID = a.AddressID
JOIN Towns t
ON a.TownID = t.TownID 
WHERE e.EmployeeID IN 
(SELECT DISTINCT ManagerID FROM Employees)
GROUP BY t.Name
ORDER BY t.Name