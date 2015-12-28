SELECT d.Name AS Department, AVG(e.Salary) AS [Avarage Salary]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name