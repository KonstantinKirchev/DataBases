USE SoftUni
GO

CREATE FUNCTION fn_StrConcat(@input NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @strLen INT = LEN(@input)
DECLARE @index INT = 1
DECLARE @currentChar NVARCHAR(5) = ' '
DECLARE @result NVARCHAR(MAX) = ''
WHILE (@index <= @strLen)
BEGIN
SET @currentChar = SUBSTRING(@input, @index, 1)
IF @currentChar = ' ' 
BEGIN
	IF @index <> 1 AND @index <> @strLen
	BEGIN
	SET @currentChar = ', '
	END
END
SET @result = @result +	@currentChar
SET @index += 1
END
RETURN @result
END

GO

SELECT dbo.fn_StrConcat(FirstName + ' ' + LastName) AS [Full Name]
FROM Employees

GO
