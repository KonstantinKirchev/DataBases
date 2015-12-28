SELECT *
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'

BEGIN TRAN
DELETE FROM Employees;
ROLLBACK TRAN
