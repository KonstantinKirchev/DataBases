SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary = 
(SELECT min(Salary) FROM Employees)
