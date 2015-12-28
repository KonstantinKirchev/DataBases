SELECT e.FirstName + ' ' + e.LastName AS FullName , 
CASE
     WHEN m.FirstName + ' ' + m.LastName  IS NULL THEN 'No manager' 
     ELSE m.FirstName + ' ' + m.LastName 
END
AS Manager 
FROM Employees e
LEFT OUTER JOIN Employees m
ON e.ManagerID = m.EmployeeID

SELECT e.FirstName + ' ' + e.LastName AS FullName , ISNULL( m.FirstName + ' ' + m.LastName, 'No manager') AS Manager 
FROM Employees e
LEFT OUTER JOIN Employees m
ON e.ManagerID = m.EmployeeID