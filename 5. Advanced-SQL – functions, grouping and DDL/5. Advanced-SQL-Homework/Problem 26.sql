SELECT d.Name AS Department, e.JobTitle AS [Job Title], e.FirstName AS [First Name], MIN(e.Salary) AS [Min Salary]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name, e.JobTitle, e.FirstName, e.Salary