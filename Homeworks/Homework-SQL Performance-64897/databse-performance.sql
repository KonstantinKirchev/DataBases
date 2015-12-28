create database PerformanceHomewordDb
go
 
use PerformanceHomewordDb
 
create table Concerts(
        Id int Identity Primary Key,
        Performer nvarchar(100),
        [Date] date
)
go
 
-- Insert 10000 different values
SET NOCOUNT ON
DECLARE @ConcertCount int = (SELECT COUNT(*) FROM Concerts)
DECLARE @RowCount int = 10000
WHILE @RowCount > 0
BEGIN
  DECLARE @Performer nvarchar(100) =
    'Name ' + CONVERT(nvarchar(100), @RowCount) + ': ' +
    CONVERT(nvarchar(100), newid())
  DECLARE @Date datetime =
        DATEADD(month, CONVERT(varbinary, newid()) % (50 * 12), getdate())
  INSERT INTO Concerts(Performer, [Date])
  VALUES(@Performer, @Date)
  SET @RowCount = @RowCount - 1
END
SET NOCOUNT OFF
 
-- Copy values until the total count is 1 000 000
WHILE (SELECT COUNT(*) FROM Concerts) < 1000000
BEGIN
  INSERT INTO Concerts(Performer, [Date])
  SELECT Performer, [Date] FROM Concerts
END
 
select count(*) from Concerts
 
CHECKPOINT; DBCC DROPCLEANBUFFERS;
 
-- time taken - 6 sec
select * from Concerts
        where [date] > '10-10-2010' AND [date] < '10-10-2012'