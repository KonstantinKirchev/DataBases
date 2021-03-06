
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary = 
  (SELECT MAX(Salary) FROM Employees)

---------------------------------------------------------------------

SELECT FirstName, LastName, DepartmentID, Salary
FROM Employees
WHERE DepartmentID IN 
  (SELECT DepartmentID FROM Departments
   WHERE Name='Sales')

---------------------------------------------------------------------

SELECT FirstName, LastName, DepartmentID, Salary
FROM Employees e
WHERE Salary = 
  (SELECT MAX(Salary) FROM Employees 
   WHERE DepartmentID = e.DepartmentID)
ORDER BY DepartmentID

---------------------------------------------------------------------

SELECT FirstName, LastName, EmployeeID, ManagerID
FROM Employees e
WHERE EXISTS
  (SELECT EmployeeID
   FROM Employees m
   WHERE m.EmployeeID = e.ManagerID
     AND m.DepartmentID = 1)

---------------------------------------------------------------------

SELECT
  AVG(Salary) [Average Salary],
  MAX(Salary) [Max Salary],
  MIN(Salary) [Min Salary],
  SUM(Salary) [Salary Sum]
FROM Employees
WHERE JobTitle = 'Production Technician'

---------------------------------------------------------------------

SELECT MIN(HireDate) MinHD, MAX(HireDate) MaxHD
FROM Employees

---------------------------------------------------------------------

SELECT MIN(LastName), MAX(LastName)
FROM Employees

---------------------------------------------------------------------

SELECT COUNT(*) Cnt FROM Employees
WHERE DepartmentID = 3

---------------------------------------------------------------------

SELECT
  COUNT(ManagerID) MgrCount,
  COUNT(*) AllCount
FROM Employees
WHERE DepartmentID = 16

---------------------------------------------------------------------

SELECT
  AVG(ManagerID) Avg,
  SUM(ManagerID) / COUNT(*) AvgAll
FROM Employees

---------------------------------------------------------------------

SELECT e.FirstName, e.LastName, e.HireDate, d.Name
FROM Employees e 
  JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate = 
  (SELECT MIN(HireDate) FROM Employees 
   WHERE DepartmentID = d.DepartmentID)

---------------------------------------------------------------------

SELECT DepartmentID, SUM(Salary)
FROM Employees
GROUP BY DepartmentID

---------------------------------------------------------------------

SELECT 
  DepartmentID, JobTitle, 
  SUM(Salary) as Salaries,
  COUNT(*) as Count
FROM Employees
GROUP BY DepartmentID, JobTitle

---------------------------------------------------------------------

-- This SQL query is illegal!
SELECT DepartmentID, COUNT(LastName)
FROM Employees

---------------------------------------------------------------------

-- This SQL query is illegal!
SELECT DepartmentID, AVG(Salary)
FROM Employees
WHERE AVG(Salary) > 30
GROUP BY DepartmentID

---------------------------------------------------------------------

SELECT DepartmentID, JobTitle, 
  SUM(Salary) AS Cost, MIN(HireDate) as StartDate
FROM Employees
GROUP BY DepartmentID, JobTitle

---------------------------------------------------------------------

SELECT DepartmentID, COUNT(EmployeeID) as EmpCount,
  AVG(Salary) as AverageSalary
FROM Employees
GROUP BY DepartmentID
HAVING COUNT(EmployeeID) BETWEEN 3 AND 5

---------------------------------------------------------------------

SELECT COUNT(*) AS EmpCount, d.Name AS DeptName
FROM Employees e 
  JOIN Departments d
    ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate BETWEEN '1999-2-1' AND '2002-12-31'
GROUP BY d.Name
HAVING COUNT(*) > 5
ORDER BY EmpCount DESC

---------------------------------------------------------------------

SELECT Name AS [Projects Name], 
  ISNULL(EndDate, GETDATE()) AS [End Date]
FROM Projects

---------------------------------------------------------------------

SELECT Name AS [Projects Name], 
  COALESCE(EndDate, GETDATE()) AS [End Date]
FROM Projects

---------------------------------------------------------------------

SELECT LastName, LEN(LastName) AS LastNameLen,
  UPPER(LastName) AS UpperLastName
FROM Employees
WHERE RIGHT(LastName, 3) = 'son'

---------------------------------------------------------------------

SELECT FLOOR(3.14)

---------------------------------------------------------------------

SELECT ROUND(5.86, 0)

---------------------------------------------------------------------

SELECT DATEADD(day, 15, GETDATE())

---------------------------------------------------------------------

SELECT CONVERT(DATETIME, '20051231', 112)

---------------------------------------------------------------------

SELECT CONVERT(VARCHAR, GETDATE(), 103)

---------------------------------------------------------------------

SELECT Name AS [Projects Name], 
  ISNULL(CONVERT(nvarchar(50), EndDate), 
  'Not Finished') AS [Date Finished]
FROM Projects

---------------------------------------------------------------------

CREATE TABLE Persons (
  PersonID int IDENTITY,
  Name nvarchar(100) NOT NULL,
  CONSTRAINT PK_Persons PRIMARY KEY(PersonID)
)

GO

CREATE VIEW [First 10 Persons] AS
SELECT TOP 10 Name FROM Persons

---------------------------------------------------------------------

CREATE TABLE Countries (
  CountryID int IDENTITY,
  Name nvarchar(100) NOT NULL,
  CONSTRAINT PK_Countries PRIMARY KEY(CountryID)
)

GO

CREATE TABLE Cities (
  CityID int IDENTITY,
  Name nvarchar(100) NOT NULL,
  CountryID int NOT NULL,
  CONSTRAINT PK_Cities PRIMARY KEY(CityID)
)

---------------------------------------------------------------------

-- Add a foreign key constraint Cities --> Countries
ALTER TABLE Cities
ADD CONSTRAINT FK_Cities_Countries
  FOREIGN KEY (CountryID)
  REFERENCES Countries(CountryID)

-- Add column Population to the table Countries
ALTER TABLE Countries ADD Population int

-- Remove column Population from the table Countries
ALTER TABLE Countries DROP COLUMN Population

---------------------------------------------------------------------

DROP TABLE Persons

ALTER TABLE Cities
DROP CONSTRAINT FK_Cities_Countries

---------------------------------------------------------------------

REVOKE SELECT ON Employees FROM public

---------------------------------------------------------------------

CREATE TABLE Groups (
  GroupID int IDENTITY,
  Name nvarchar(100) NOT NULL,
  CONSTRAINT PK_Groups PRIMARY KEY(GroupID)
)

CREATE TABLE Users (
  UserID int IDENTITY,
  UserName nvarchar(100) NOT NULL,
  GroupID int NOT NULL,
  CONSTRAINT PK_Users PRIMARY KEY(UserID),
  CONSTRAINT FK_Users_Groups FOREIGN KEY(GroupID)
    REFERENCES Groups(GroupID)
)

---------------------------------------------------------------------

BEGIN TRAN
DELETE FROM EmployeesProjects;
DELETE FROM Projects;
ROLLBACK TRAN

---------------------------------------------------------------------
