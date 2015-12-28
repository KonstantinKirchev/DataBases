declare @max money;
set @max = (select min(Salary)*1.10 from Employees);
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary <= @max
