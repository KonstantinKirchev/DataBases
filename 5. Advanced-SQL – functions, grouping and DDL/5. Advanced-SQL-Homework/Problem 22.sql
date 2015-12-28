INSERT INTO Users(FullName, UserName, UserPassword)
	SELECT (e.FirstName + ' '+ e.LastName),
	(SUBSTRING(e.FirstName,0,5) + LOWER(e.LastName)),
	(SUBSTRING(e.FirstName,0,2) + LOWER(e.LastName))
	FROM Employees e
	