SELECT DepartmentID, AVG(Salary) as SalariesCost
FROM Employees
GROUP BY DepartmentID 
ORDER BY DepartmentID 
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY

