CREATE TABLE Games(
	Id int IDENTITY,
	Description nvarchar(40) NOT NULL,
	GameDate datetime NOT NULL,
	CONSTRAINT PK_Id_Games PRIMARY KEY(Id)
)
GO

BEGIN TRANSACTION
DECLARE @index int,
		@description nvarchar(40);
SET @index = 0;
SET	@description = 'Test description...';

WHILE @index < 10000000
BEGIN
	INSERT INTO Games(Description, GameDate)
		VALUES(@description, DATEADD(MINUTE, @index, GETDATE()))	

	SET @index = @index + 1
END
COMMIT TRANSACTION
GO

-- clear cache
DBCC DROPCLEANBUFFERS;

SET STATISTICS IO  ON
SET STATISTICS TIME  ON

SELECT * FROM Games
WHERE GameDate BETWEEN GETDATE() AND DATEADD(HOUR, 5, GETDATE())