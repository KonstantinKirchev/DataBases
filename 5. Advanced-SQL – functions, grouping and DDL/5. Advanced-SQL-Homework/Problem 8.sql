SELECT COUNT(EmployeeID) AS [Employees without manager]
FROM Employees 
WHERE ManagerID is NULL
