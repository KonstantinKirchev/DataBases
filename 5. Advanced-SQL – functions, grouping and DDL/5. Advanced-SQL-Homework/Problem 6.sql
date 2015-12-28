SELECT COUNT(e.EmployeeID) AS [Number of employees in Sales Department]
FROM Employees e
JOIN Departments d
on (e.DepartmentID = d.DepartmentID AND d.Name='Sales')

select count(EmployeeID) as CountEmp
from Employees e 
join Departments d
on e.DepartmentID = d.DepartmentID
group by e.DepartmentID ,d.Name
HAVING d.Name = 'Sales'