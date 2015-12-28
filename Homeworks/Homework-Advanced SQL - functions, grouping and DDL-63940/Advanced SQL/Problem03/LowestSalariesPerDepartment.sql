SELECT e.FirstName + ' ' + e.LastName AS [Employee], e.Salary, d.Name AS [Department]
FROM Employees e JOIN Departments d 
	ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = 
	(SELECT MIN(Salary) FROM Employees
	WHERE DepartmentID = d.DepartmentID)