SELECT d.Name AS Department, e.JobTitle AS [Job Title], AVG(e.Salary) AS [Average Salary]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY e.JobTitle, d.Name, e.Salary