SELECT e.FirstName+' '+ISNULL(e.MiddleName,'')+' '+e.LastName AS [Employee], d.Name AS [Department]
FROM Employees e
JOIN Departments d
ON (e.DepartmentID = d.DepartmentID 
AND e.HireDate BETWEEN '1/1/1995' AND '12/31/2005'
AND d.Name IN ('Sales', 'Finance'))