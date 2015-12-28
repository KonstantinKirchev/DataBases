/* Problem 1.	Write a SQL query to find the names and salaries of the employees 
				that take the minimal salary in the company.*/
SELECT e.FirstName, e.LastName, e.Salary
FROM dbo.Employees e
	WHERE e.Salary = 
			(SELECT MIN(e.Salary) 
			FROM dbo.Employees e)

/* Problem 2.	Write a SQL query to find the names and salaries of the employees 
				that have a salary that is up to 10% higher than the minimal salary for the company.?*/
SELECT e.FirstName, e.LastName, e.Salary
FROM dbo.Employees e
	WHERE e.Salary BETWEEN 
			(SELECT MIN(e.Salary) FROM dbo.Employees e) AND
			(SELECT MIN(e.Salary) FROM dbo.Employees e) * 1.1

/*Problem 3.	Write a SQL query to find the full name, salary and department of the employees 
				that take the minimal salary in their department.*/
SELECT e.FirstName + ' ' + e.LastName AS [FullName], e.Salary, d.Name
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID
	WHERE e.Salary = 
			(SELECT MIN(e2.Salary) FROM dbo.Employees e2
				WHERE e2.DepartmentID = d.DepartmentID)

/* Problem 4.	Write a SQL query to find the average salary in the department #1.*/
SELECT AVG(e.Salary) AS [Average salary for department #1]
FROM dbo.Employees e
	WHERE e.DepartmentID = 1

/* Problem 5.	Write a SQL query to find the average salary in the "Sales" department.*/
SELECT AVG(e.Salary) AS [Average salary for Sales department]
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID
	WHERE d.Name = 'Sales'

/*Problem 6.	Write a SQL query to find the number of employees in the "Sales" department.*/
SELECT COUNT(e.FirstName) AS [Number of employees in the Sales department]
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'


/*Problem 7.	Write a SQL query to find the number of all employees that have manager.*/
SELECT COUNT(e.FirstName)
FROM dbo.Employees e
	WHERE e.ManagerID IS NOT NULL

/*Problem 8.	Write a SQL query to find the number of all employees that have no manager.*/
SELECT COUNT(e.FirstName)
FROM dbo.Employees e
	WHERE e.ManagerID IS NULL

/*Problem 9.	Write a SQL query to find all departments and the average salary for each of them.*/
SELECT d.Name AS [Department], AVG(e.Salary) AS [Average Salary]
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID
	GROUP BY d.Name

/*Problem 10.	Write a SQL query to find the count of all employees in each department and for each town.*/
SELECT t.Name AS [Town], d.Name AS [Department], COUNT(e.FirstName) AS [Employees count]
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID
	JOIN dbo.Addresses a 
		ON a.AddressID = e.AddressID
	JOIN dbo.Towns t 
		ON t.TownID = a.TownID
GROUP BY t.Name, d.Name

/*Problem 11.	Write a SQL query to find all managers that have exactly 5 employees.*/
SELECT m.FirstName, m.LastName, COUNT(e.FirstName) AS [Employees count]
FROM dbo.Employees e
	JOIN dbo.Employees m 
		ON m.EmployeeID = e.ManagerID
	GROUP BY m.FirstName, m.LastName
	HAVING COUNT(e.FirstName) = 5

/*Problem 12.	Write a SQL query to find all employees along with their managers.*/
SELECT e.FirstName + ' ' + e.LastName AS [FullName], 
		ISNULL(m.FirstName + ' ' + m.LastName, 'No manager') AS [Manager]
FROM dbo.Employees e
	LEFT JOIN dbo.Employees m 
		ON m.EmployeeID = e.ManagerID

/*Problem 13.	Write a SQL query to find the names of all employees whose last name is exactly 5 characters long.*/ 
SELECT e.LastName 
FROM dbo.Employees e
	WHERE LEN(e.LastName) = 5

/*Problem 14.	Write a SQL query to display the current date and time in 
				the following format "day.month.year hour:minutes:seconds:milliseconds". */
SELECT FORMAT(GETDATE(), 'dd.mm.yyyy hh:mm:ss:fff')

/*Problem 15.	Write a SQL statement to create a table Users.*/
CREATE TABLE Users (
	Id [int] PRIMARY KEY IDENTITY,
	UserName [nvarchar](50) UNIQUE NOT NULL,
	Password [nvarchar](50) NOT NULL,
	FullName [nvarchar](50),
	LastLogin [datetime])

ALTER TABLE dbo.Users 
ADD CONSTRAINT [MinLengthConstraint] CHECK (LEN(UserName) > 4)

INSERT INTO dbo.Users VALUES ('test1', '123', 'test1', GETDATE());
INSERT INTO dbo.Users VALUES ('test2', '123456', 'test2', GETDATE());

/*Problem 16.	Write a SQL statement to create a view that displays 
				the users from the Users table that have been in the system today.*/
CREATE VIEW user_logged_today AS
SELECT *
FROM dbo.Users u
	WHERE CONVERT(date, u.LastLogin) = CONVERT(date, GETDATE())

SELECT *
FROM dbo.user_logged_today ult

/*Problem 17.	Write a SQL statement to create a table Groups. 
				Groups should have unique name (use unique constraint). Define primary key and identity column.*/
CREATE TABLE Groups(
	Id [int] PRIMARY KEY IDENTITY,
	Name [nvarchar](20) UNIQUE)

/*Problem 18.	Write a SQL statement to add a column GroupID to the table Users.
				Fill some data in this new column and as well in the Groups table. 
				Write a SQL statement to add a foreign key constraint between tables Users and Groups tables.*/
ALTER TABLE dbo.Users
ADD GroupID [int]

INSERT INTO dbo.Groups (Name) 
VALUES ('C#'), ('DataBases'), ('Java')

ALTER TABLE dbo.Users
ADD CONSTRAINT FK_Users_Groups
FOREIGN KEY (GroupID) REFERENCES dbo.Groups(Id)

/*Problem 19.	Write SQL statements to insert several records in the Users and Groups tables.*/
INSERT INTO dbo.Users VALUES ('test34', '123456', 'test', GETDATE(), 1);
INSERT INTO dbo.Users VALUES ('test35', '123456', 'test', GETDATE(), 2);
INSERT INTO dbo.Users VALUES ('test36', '123456', 'test', GETDATE(), 3);
INSERT INTO dbo.Groups VALUES ('test34');
INSERT INTO dbo.Groups VALUES ('test35');

/*Problem 20.	Write SQL statements to update some of the records in the Users and Groups tables.*/
UPDATE dbo.Users 
	SET UserName = 'SomeName2' WHERE Id = 1
UPDATE dbo.Users 
	SET Password = 'Updated' WHERE Id = 1


SELECT * FROM dbo.Users u

/*Problem 21.	Write SQL statements to delete some of the records from the Users and Groups tables.*/
DELETE FROM dbo.Users 
WHERE dbo.Users.Id = 1

DELETE FROM dbo.Users 
WHERE dbo.Users.UserName = 'test1'

/*Problem 22.	Write SQL statements to insert in the Users table the names of all employees from the Employees table.
				Combine the first and last names as a full name. 
				For username use the first letter of the first name + the last name (in lowercase). 
				Use the same for the password, and NULL for last login time.*/
INSERT INTO dbo.Users
	SELECT 
	LEFT(e.FirstName, 1) + LOWER(e.LastName) + CAST(EmployeeID AS nvarchar(25)) AS [Username],
	LEFT(e.FirstName, 1) + LOWER(e.LastName),
	e.FirstName + ' ' + e.LastName,
	NULL,
	1
	FROM dbo.Employees e

SELECT * FROM users 

/*Problem 23.	Write a SQL statement that changes the password to NULL for all users 
				that have not been in the system since 10.03.2010.*/
ALTER TABLE dbo.Users
ALTER COLUMN Password [nvarchar](25) NULL

UPDATE dbo.Users
SET dbo.Users.Password = NULL 
WHERE CONVERT(date, dbo.Users.LastLogin) < CONVERT(date, '2010-03-10')

UPDATE dbo.Users
SET dbo.Users.Password = NULL 
WHERE dbo.Users.Id = 4


SELECT *
FROM dbo.Users u 

/*Problem 24.	Write a SQL statement that deletes all users without passwords (NULL password).*/
DELETE dbo.Users
WHERE dbo.Users.Password IS NULL 

/*Problem 25.	Write a SQL query to display the average employee salary by department and job title.*/
SELECT d.Name AS [Department], e.JobTitle, AVG(e.Salary) AS [Average salary]
FROM dbo.Employees e
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID 
	GROUP BY d.Name, e.JobTitle

/*Problem 26.	Write a SQL query to display the minimal employee salary by department and job title 
				along with the name of some of the employees that take it.*/
SELECT d.Name AS [Department], e.JobTitle, e.FirstName + e.LastName, MIN(e.Salary) 
FROM dbo.Employees e 
	JOIN dbo.Departments d 
		ON d.DepartmentID = e.DepartmentID 
	GROUP BY d.Name, e.JobTitle, e.FirstName, e.LastName

/*Problem 27.	Write a SQL query to display the town where maximal number of employees work.*/
SELECT TOP 1 t.Name, COUNT(e.FirstName) AS [Number of emplyees]
FROM dbo.Employees e
	JOIN dbo.Addresses a 
		ON a.AddressID = e.AddressID
	JOIN dbo.Towns t 
		ON t.TownID = a.TownID
	GROUP BY t.Name
	ORDER BY [Number of emplyees] DESC

/*Problem 28.	Write a SQL query to display the number of managers from each town.*/
SELECT t.Name, COUNT(DISTINCT  m.EmployeeID)
FROM dbo.Employees e
	JOIN dbo.Employees m 
		ON m.EmployeeID = e.ManagerID
	JOIN dbo.Addresses a 
		ON a.AddressID = m.AddressID
	JOIN dbo.Towns t 
		ON t.TownID = a.TownID
	WHERE e.ManagerID = m.EmployeeID
	GROUP BY t.Name 
	ORDER BY t.Name	

/*Problem 29.	Write a SQL to create table WorkHours to store work reports for each employee.
				Each employee should have id, date, task, hours and comments. 
				Don't forget to define identity, primary key and appropriate foreign key.*/
CREATE TABLE WorkHours(
	Id [int] PRIMARY KEY IDENTITY,
	Date [datetime] NOT NULL,
	Task [nvarchar](50) NOT NULL,
	Hours int NOT NULL,
	Comments [nvarchar](300),
	EmployeeId int UNIQUE FOREIGN KEY REFERENCES dbo.Employees(EmployeeID)
	)

/*Problem 30.	Issue few SQL statements to insert, update and delete of some data in the table.*/
INSERT INTO WorkHours VALUES(GETDATE(), 'Worker', 5, NULL, 1)
INSERT INTO WorkHours VALUES(GETDATE(), 'Worker', 15, NULL, 4)
UPDATE WorkHours SET Task = 'Not Worker' WHERE Id = 1
UPDATE WorkHours SET Task = 'Not Worker' WHERE Id = 2
DELETE FROM WorkHours WHERE WorkHours.Id = 1

SELECT * 
FROM WorkHours

/*Problem 31.	Define a table WorkHoursLogs to track all changes in the WorkHours table with triggers.
				For each change keep the old record data, the new record data and the command (insert / update / delete).*/
CREATE TABLE WorkHoursLogs(
	Id int PRIMARY KEY IDENTITY,
	OldDate date NOT NULL,
	NewDate date NOT NULL,
	OldTask nvarchar(30) NOT NULL,
	NewTask nvarchar(30) NOT NULL,
	OldHours int NOT NULL,
	NewHours int NOT NULL,
	OldComments nvarchar(150),
	NewComments nvarchar(150),
	CommandType nvarchar(25) NOT NULL,
	EmployeeId int UNIQUE FOREIGN KEY REFERENCES Employees(EmployeeID)
	)

CREATE TRIGGER track_changes_in_WorkHours
ON dbo.WorkHours
FOR UPDATE



/*Problem 32.	Start a database transaction, delete all employees from the 'Sales' department along 
				with all dependent records from the pother tables. At the end rollback the transaction.*/
BEGIN TRAN
DELETE FROM dbo.Employees
WHERE dbo.Employees.DepartmentID = 
				(SELECT d.DepartmentID 
					FROM dbo.Departments d
					WHERE d.Name = 'Sales')
ROLLBACK TRAN

/*Problem 33.	Start a database transaction and drop the table EmployeesProjects.
Then how you could restore back the lost table data?*/
BEGIN TRAN
SELECT * 
INTO #temporaryTable
FROM dbo.EmployeesProjects ep
DROP TABLE dbo.EmployeesProjects
COMMIT

/*Problem 34.	Find how to use temporary tables in SQL Server.
Using temporary tables backup all records from EmployeesProjects and restore them back after dropping and re-creating the table.*/

SELECT *
INTO dbo.EmployeesProjects 
FROM #temporaryTable

DROP TABLE #temporaryTable

SELECT *
FROM EmployeesProjects