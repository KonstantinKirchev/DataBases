SELECT e.FirstName + ' ' + e.LastName AS Employee, e.JobTitle AS [Job Title] ,m.FirstName + ' ' + m.LastName AS Manager
FROM Employees e
JOIN Employees m
ON e.ManagerID = m.EmployeeID
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
GO

SELECT e.FirstName,e.LastName,e.Salary,d.Name
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary < (SELECT AVG(e.Salary)
FROM Employees e
WHERE d.DepartmentID = e.DepartmentID)
ORDER BY e.Salary DESC
GO

SELECT p.Name, SUM(e.Salary)
FROM Projects p
JOIN EmployeesProjects ep
ON ep.ProjectID = p.ProjectID
JOIN Employees e
ON ep.EmployeeID = e.EmployeeID
GROUP BY p.Name
ORDER BY p.Name

SELECT e.FirstName+' '+ e.LastName, e.Salary, d.Name
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = (SELECT MIN(e.Salary) FROM Employees e WHERE e.DepartmentID = d.DepartmentID)