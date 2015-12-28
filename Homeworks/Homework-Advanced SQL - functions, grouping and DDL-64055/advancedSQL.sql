/*Problem 1.	Write a SQL query to find the names and salaries of the employees that take the minimal salary in the company.*/
SELECT e.FirstName, e.LastName, e.Salary 
FROM Employees AS e
WHERE e.Salary = 
	(SELECT MIN(e.Salary) FROM Employees AS e)

/*Problem 2.	Write a SQL query to find the names and salaries of the employees that have a salary that is up to 10% higher 
than the minimal salary for the company.*/
SELECT e.FirstName, e.LastName, e.Salary 
FROM Employees AS e
WHERE e.Salary <
(SELECT MIN(e.Salary) * 1.1 FROM Employees AS e)


/*Problem 3.	Write a SQL query to find the full name, salary and department of the employees that take the minimal salary 
in their department.*/
SELECT CONCAT(e.FirstName,' ', e.LastName) AS [Full Name], e.Salary, d.Name AS Department
FROM Employees AS e
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary =
(SELECT MIN(e.Salary) FROM Employees AS e
WHERE e.DepartmentID = d.DepartmentID)

/*Problem 4.	Write a SQL query to find the average salary in the department #1.*/
SELECT AVG(e.Salary) AS [Average Salary] 
FROM Employees AS e
WHERE e.DepartmentID = 1 

/*Problem 5.	Write a SQL query to find the average salary in the "Sales" department.*/
SELECT AVG(e.Salary) AS [Average Salary for Sales] 
FROM Employees AS e
JOIN Departments As d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'

/*Problem 6.	Write a SQL query to find the number of employees in the "Sales" department.*/
SELECT COUNT(*) AS [Sales employees count] 
FROM Employees AS e
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'

/*Problem 7.	Write a SQL query to find the number of all employees that have manager.*/
SELECT COUNT(*) AS [Employees with mangaer]
FROM Employees
WHERE ManagerID IS NOT NULL


/*Problem 8.	Write a SQL query to find the number of all employees that have no manager.*/
SELECT COUNT(*) AS [Employees without manager]
FROM Employees As e
WHERE e.ManagerID IS NULL

/*Problem 9.	Write a SQL query to find all departments and the average salary for each of them.*/
SELECT d.Name AS Department, AVG(e.Salary) AS [Average Salary] 
FROM Employees AS e
JOIN Departments As d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name


/*Problem 10.	Write a SQL query to find the count of all employees in each department and for each town. */
SELECT t.Name AS Town, d.Name AS DEpartment, COUNT(d.Name) AS [Employees Count]
FROM Employees AS e
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
JOIN Addresses as a
ON e.AddressID = a.AddressID
JOIN Towns AS t
ON a.TownID = t.TownID
GROUP BY t.Name, d.Name

/*Problem 11.	Write a SQL query to find all managers that have exactly 5 employees.*/
SELECT m.FirstName, m.LastName, COUNT(e.EmployeeID) 
FROM Employees AS e
JOIN Employees AS m
ON e.ManagerID = m.EmployeeID
GROUP BY m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) = 5

/*Problem 12.	Write a SQL query to find all employees along with their managers.*/
SELECT e.FirstName + ' ' + e.LastName AS Employee, ISNULL(m.FirstName + ' ' + m.LastName, '(no manager)') AS Manager
FROM Employees AS e
LEFT JOIN Employees AS m
ON e.ManagerID = m.EmployeeID

/*Problem 13.	Write a SQL query to find the names of all employees whose last name is exactly 5 characters long. */
SELECT e.FirstName, e.LastName 
FROM Employees AS e
WHERE LEN(e.LastName) = 5

/*Problem 14.	Write a SQL query to display the current date and time in the following format 
"day.month.year hour:minutes:seconds:milliseconds". */
SELECT CONVERT(varchar(10), GETDATE(), 104) + ' ' + CONVERT(varchar(12), GETDATE(), 114)

/*Problem 15.	Write a SQL statement to create a table Users.*/
CREATE TABLE Users(
	UserID int IDENTITY,
	Username nvarchar(50) NOT NULL,
	UserPassword nvarchar(50) NOT NULL,
	FullName nvarchar(50) NOT NULL,
	LastLogin date,
	CONSTRAINT PK_Users PRIMARY KEY(UserID),
	CONSTRAINT UNQ_Users UNIQUE(Username),
	CONSTRAINT CHK_Password CHECK (LEN(UserPassword) >= 5))
	GO

/*Problem 16.	Write a SQL statement to create a view that displays the users from the Users table that have been in 
the system today.*/
CREATE VIEW UsersToday AS
SELECT * FROM Users
WHERE LastLogin = GETDATE();
Go

/*Problem 17.	Write a SQL statement to create a table Groups. */
CREATE TABLE Groups(
	GroupID int IDENTITY,
	Name nvarchar(50) NOT NULL,
	CONSTRAINT PK_Groups PRIMARY KEY(GroupID),
	CONSTRAINT UNQ_Group UNIQUE(Name)
);
GO

/*Problem 18.	Write a SQL statement to add a column GroupID to the table Users.*/
ALTER TABLE Users
ADD GroupID INT FOREIGN KEY REFERENCES Groups(GroupID);
INSERT Groups VALUES('PHP')
INSERT Groups VALUES('C#')
INSERT Groups VALUES('JS')
INSERT Groups VALUES('Databases')
INSERT Users VALUES ('JonSnow', 'agjhhh', 'Jon Snow',  GETDATE(), 1);
INSERT Users VALUES ('Hoeedor', '54321', 'Hodor', GETDATE(), 2);
INSERT Users VALUES ('NoHands', 'abcdef', 'Jaime Lannister', GETDATE(), 3);
INSERT Users VALUES ('TheViper', '12345678', 'Oberin Martell', GETDATE(), 4);

--SELECT * FROM Users

/*Problem 19.	Write SQL statements to insert several records in the Users and Groups tables.*/
--done


/*Problem 20.	Write SQL statements to update some of the records in the Users and Groups tables.*/
UPDATE Users 
SET Username = 'HODOR!!!'
WHERE UserID = 2

UPDATE Groups
SET Name = Name + ' + JS Apps'
WHERE GroupID = 3

--SELECT * FROM Groups

/*Problem 21.	Write SQL statements to delete some of the records from the Users and Groups tables.*/
DELETE FROM Users 
WHERE UserID = 2

--SELECT * FROM Users

DELETE FROM Groups
WHERE Name = 'C#'

/*Problem 22.	Write SQL statements to insert in the Users table the names of all employees from the Employees table.*/
 INSERT INTO Users 
 SELECT e.FirstName + e.LastName AS Username,
		'blaaa' AS [Password],
		e.FirstName + ' ' + e.LastName AS FullName,
		GETDATE() AS LastLogin,
		1 AS GroupID 
		FROM Employees AS e

/*Problem 23.	Write a SQL statement that changes the password to NULL for all users that have not been in the system 
since 10.03.2010.*/
UPDATE Users SET UserPassword = NULL
WHERE LastLogin <= CAST('2013-10-03' AS DATETIME)

/*Problem 24.	Write a SQL statement that deletes all users without passwords (NULL password).*/
DELETE FROM Users WHERE UserPassword IS NULL

/*Problem 25.	Write a SQL query to display the average employee salary by department and job title.*/
SELECT d.Name AS Department, e.JobTitle, AVG(Salary) AS [Average Salary]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name, e.JobTitle
ORDER BY JobTitle;

/*Problem 26.	Write a SQL query to display the minimal employee salary by department and job title along with the 
name of some of the employees that take it.*/
SELECT d.Name AS [Department],
       e.JobTitle,
	   CONCAT(e.FirstName, ' ', e.LastName) AS [Employee Name],
       e.Salary AS [Min Salary]
FROM Employees e
JOIN Departments d
ON e.DepartmentID = d.DepartmentID
GROUP BY d.Name,
         e.JobTitle,
		 CONCAT(e.FirstName, ' ', e.LastName),
		 e.Salary,
		 e.DepartmentID
HAVING e.Salary = 
(SELECT MIN(Salary) FROM Employees
WHERE JobTitle = e.JobTitle AND DepartmentID = e.DepartmentID)
ORDER BY Department;

/*Problem 27.	Write a SQL query to display the town where maximal number of employees work.*/
SELECT TOP(1) t.Name AS Name, COUNT(e.EmployeeID) AS [Employees count]
FROM Employees e
JOIN Addresses a
ON e.AddressID = a.AddressID
JOIN Towns t
ON a.TownID = t.TownID
GROUP BY t.Name
ORDER BY [Employees count] DESC

/*Problem 28.	Write a SQL query to display the number of managers from each town.*/
SELECT t.Name AS Town, COUNT(e.ManagerID) AS [Managers count]
FROM Employees e
JOIN Employees m
ON e.ManagerID = m.EmployeeID
JOIN Addresses a
ON m.AddressID = a.AddressID
JOIN Towns t
ON a.TownID = t.TownID
GROUP BY t.Name
 

/*Problem 29.	Write a SQL to create table WorkHours to store work reports for each employee.*/
CREATE TABLE WorkHours (
  WorkHourID int IDENTITY,
  WorkDate datetime,
  EmployeeID int FOREIGN KEY REFERENCES Employees(EmployeeID) NOT NULL,
  Task nvarchar(150) NOT NULL,
  WorkHours int NOT NULL,
  Comment nvarchar(300) NULL,
  CONSTRAINT PK_WorkHours PRIMARY KEY(WorkHourID)
)

/*Problem 30.	Issue few SQL statements to insert, update and delete of some data in the table.*/
--samo tolkova...

/*Problem 31.	Define a table WorkHoursLogs to track all changes in the WorkHours table with triggers.*/

/*Problem 32.	Start a database transaction, delete all employees from the 'Sales' department along with all 
dependent records from the pother tables. At the end rollback the transaction.*/

/*Problem 33.	Start a database transaction and drop the table EmployeesProjects.*/

/*Problem 34.	Find how to use temporary tables in SQL Server.*/
