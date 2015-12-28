USE SoftUni;
GO

Select e.FirstName, e.MiddleName, e.LastName, e.HireDate, d.Name AS [Department Name]
FROM Employees e
JOIN Departments d ON e.EmployeeID = d.DepartmentID
WHERE d.Name = 'Sales' OR d.Name = 'Finance'
      AND e.HireDate BETWEEN 1995 AND 2005;
GO