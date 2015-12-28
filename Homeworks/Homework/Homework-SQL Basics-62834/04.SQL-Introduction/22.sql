USE SoftUni;
GO

SELECT d.Name as [Departments and Towns]
FROM Departments d
UNION ALL
SELECT t.Name
FROM Towns t;
GO