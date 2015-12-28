CREATE TABLE TestTable
(id int IDENTITY,
dates date,
info nvarchar(50))
GO

DECLARE @n int = 10000000
DECLARE @date date = '10-10-2010'

BEGIN TRANSACTION
WHILE(@n>0)
BEGIN
INSERT INTO TestTable
VALUES (@date, 'Text')
SET @n = @n - 1
END

rollback tran
