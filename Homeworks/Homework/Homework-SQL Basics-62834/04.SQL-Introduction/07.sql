USE SoftUni;
GO

SELECT (FirstName + ' ' + MiddleName + ' ' + LastName) as FullName
FROM Employees
WHERE MiddleName IS NOT NULL;
GO