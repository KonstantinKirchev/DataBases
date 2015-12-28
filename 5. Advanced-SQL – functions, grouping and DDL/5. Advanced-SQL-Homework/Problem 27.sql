SELECT TOP 1 t.Name AS Name, COUNT(a.TownID) AS [Number of employees]
FROM Employees e
JOIN Addresses a
ON e.AddressID = a.AddressID
JOIN Towns t
ON a.TownID = t.TownID
GROUP BY a.TownID, t.Name
ORDER BY COUNT(a.TownID) DESC