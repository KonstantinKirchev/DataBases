WITH summary AS (
SELECT  t.Name, COUNT(*) AS [Number of Employees] FROM Towns t
JOIN Addresses a ON t.TownID = a.TownID
JOIN Employees e ON a.AddressID = e.AddressID
GROUP BY t.Name
)
SELECT Name, [Number of Employees]
FROM summary s
WHERE s.[Number of Employees] =
        (SELECT MAX([Number of Employees]) AS MaxCount
        FROM summary s)
--Khaving s.[Number of Employees] = (SELECT MAX(s.[Number of Employees]) FROM summary)


-------------

