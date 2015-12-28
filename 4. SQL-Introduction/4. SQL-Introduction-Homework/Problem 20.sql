SELECT e.FirstName+' '+e.LastName AS EmpFullName,
       m.FirstName+' '+m.LastName AS MgrFullName
FROM Employees e
JOIN Employees m
  ON e.ManagerID = m.EmployeeID
