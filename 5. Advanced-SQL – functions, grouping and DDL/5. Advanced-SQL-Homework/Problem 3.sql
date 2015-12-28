SELECT e.FirstName+' '+e.LastName as FullName, e.Salary, d.Name as Deparment
FROM Employees e 
JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
WHERE e.Salary = 
  (SELECT MIN(e.Salary) FROM Employees e 
   WHERE DepartmentID = d.DepartmentID)