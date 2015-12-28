USE SoftUni
GO
DECLARE empCursor CURSOR READ_ONLY FOR
  SELECT e.FirstName, e.LastName, t.Name
  FROM Employees e
  JOIN Addresses a
  ON e.AddressID = a.AddressID
  JOIN Towns t
  ON a.TownID = t.TownID

OPEN empCursor
DECLARE @firstName nvarchar(50), @lastName nvarchar(50) , @town nvarchar (50)
FETCH NEXT FROM empCursor INTO @firstName, @lastName, @town

WHILE @@FETCH_STATUS = 0
  BEGIN

	DECLARE innerEmpCursor CURSOR READ_ONLY FOR
	SELECT e.FirstName, e.LastName, t.Name
	FROM Employees e
	INNER JOIN Addresses a
		ON a.AddressID = e.AddressID
	INNER JOIN Towns t
		ON a.TownID = t.TownID
	WHERE t.Name = @town
	ORDER BY a.AddressID

	OPEN innerEmpCursor
	DECLARE @innerFirstName NVARCHAR(MAX), 
	@innerLastName NVARCHAR(MAX),
	@innerTown NVARCHAR(MAX)
	FETCH NEXT FROM innerEmpCursor INTO 
		@innerFirstName, 
		@innerLastName, 
		@innerTown
		WHILE @@FETCH_STATUS = 0
			BEGIN
			PRINT @innerLastName + ': ' 
				+ @firstName + ' ' 
				+ @lastName + ' ' 
				+ @town + ' ' 
				+ @innerFirstName
			FETCH NEXT FROM innerEmpCursor 
			INTO @innerFirstName, 
				@innerLastName, 
				@innerTown
		END
	CLOSE innerEmpCursor
	DEALLOCATE innerEmpCursor
	FETCH NEXT FROM empCursor 
	INTO @firstName, 
		@lastName, 
		@town

  END

CLOSE empCursor
DEALLOCATE empCursor
