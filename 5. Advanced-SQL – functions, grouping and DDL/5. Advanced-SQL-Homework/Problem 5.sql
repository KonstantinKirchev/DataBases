SELECT d.Name as [Department], AVG(e.Salary) as [Average Salary for Sales Department]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID 
GROUP BY d.Name
HAVING d.Name = 'Sales'