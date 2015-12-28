SELECT m.FirstName, m.LastName, count(e.EmployeeID) AS [Employees count]
FROM Employees e
JOIN Employees m
on e.ManagerID = m.EmployeeID
GROUP BY m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) = 5