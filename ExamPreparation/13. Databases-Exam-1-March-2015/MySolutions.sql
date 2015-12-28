USE Geography
GO
--Problem 1
SELECT PeakName
FROM Peaks
ORDER BY PeakName
GO
--Problem 2
SELECT top 30 CountryName, Population
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY Population DESC, CountryName
GO
--Problem 3
SELECT CountryName, CountryCode, iif(CurrencyCode='EUR','Euro','Not Euro') AS Currency
FROM Countries
ORDER BY CountryName
GO
--Problem 4
SELECT CountryName AS [Country Name], IsoCode AS [ISO Code]
FROM Countries
WHERE CountryName LIKE '%a%A%a%'
ORDER BY IsoCode
--Problem 5
SELECT p.PeakName, m.MountainRange AS Mountain, p.Elevation
FROM Peaks p 
JOIN Mountains m
ON p.MountainId = m.Id
ORDER BY p.Elevation DESC, p.PeakName
--Problem 6
SELECT p.PeakName, m.MountainRange AS Mountain, c.CountryName, con.ContinentName
FROM Peaks p 
JOIN Mountains m
ON p.MountainId = m.Id
JOIN MountainsCountries mc
ON mc.MountainId = m.Id
JOIN Countries c
ON mc.CountryCode = c.CountryCode
JOIN Continents con
ON c.ContinentCode = con.ContinentCode
ORDER BY p.PeakName, c.CountryName
--Problem 7
SELECT r.RiverName AS River, COUNT(c.CountryCode) AS [Countries Count]
FROM Rivers r
JOIN CountriesRivers cr
ON cr.RiverId = r.Id
JOIN Countries c
ON cr.CountryCode = c.CountryCode
GROUP BY r.RiverName
HAVING COUNT(c.CountryCode) >= 3
ORDER BY r.RiverName
-------------------------------------------------------
--Second Version
SELECT 
  r.RiverName AS [River], 
  (SELECT COUNT(DISTINCT CountryCode) 
   FROM CountriesRivers 
   WHERE RiverId = r.Id) AS [Countries Count]
FROM
  Rivers r
WHERE
  (SELECT COUNT(DISTINCT CountryCode) 
   FROM CountriesRivers 
   WHERE RiverId = r.Id) >= 3
ORDER BY RiverName
-------------------------------------------------------
--Problem 8
SELECT MAX(Elevation) AS MaxElevation, MIN(Elevation) AS MinElevation, AVG(Elevation) AS AverageElevation 
FROM Peaks
--Problem 9
SELECT c.CountryName, con.ContinentName, COUNT(r.Id) AS RiversCount, ISNULL(SUM(r.Length),0) AS TotalLength
FROM Countries c
LEFT JOIN Continents con
ON c.ContinentCode = con.ContinentCode
LEFT JOIN CountriesRivers cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers r
ON cr.RiverId = r.Id
GROUP BY c.CountryName, con.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, c.CountryName
--Problem 10
SELECT cu.CurrencyCode AS CurrencyCode, cu.Description AS Currency, COUNT(co.CountryCode) AS NumberOfCountries
FROM Currencies cu
LEFT JOIN Countries co
ON co.CurrencyCode = cu.CurrencyCode
GROUP BY cu.CurrencyCode, cu.Description
ORDER BY NumberOfCountries DESC, Currency 
--Problem 11
SELECT con.ContinentName AS ContinentName, SUM(cou.AreaInSqKm) AS CountriesArea, SUM(CAST(cou.Population AS BIGINT)) AS CountriesPopulation
FROM Continents con
JOIN Countries cou
ON cou.ContinentCode = con.ContinentCode
GROUP BY con.ContinentName
ORDER BY CountriesPopulation DESC
--------------------------------------------------
--Second Version
SELECT
  ct.ContinentName,
  SUM(CONVERT(numeric, c.AreaInSqKm)) AS CountriesArea,
  SUM(CONVERT(numeric, c.Population)) AS CountriesPopulation
FROM
  Countries c
  LEFT JOIN Continents ct ON ct.ContinentCode = c.ContinentCode
GROUP BY ct.ContinentName
ORDER BY CountriesPopulation DESC
--------------------------------------------------
--Problem 12
SELECT c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.Length) AS LongestRiverLength
FROM Countries c
LEFT JOIN CountriesRivers cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers r
ON cr.RiverId = r.Id
LEFT JOIN MountainsCountries mc
ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains m
ON mc.MountainId = m.Id
LEFT JOIN Peaks p
ON p.MountainId = m.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName
--Problem 13
SELECT p.PeakName, r.RiverName, LOWER(SUBSTRING(p.PeakName,1,LEN(p.PeakName)-1) + r.RiverName) AS Mix
FROM Peaks p, Rivers r
WHERE RIGHT(p.PeakName,1) = LEFT(r.RiverName,1)
ORDER BY Mix
--Problem 14
SELECT
  c.CountryName AS [Country],
  p.PeakName AS [Highest Peak Name],
  p.Elevation AS [Highest Peak Elevation],
  m.MountainRange AS [Mountain]
FROM
  Countries c
  LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
  LEFT JOIN Mountains m ON m.Id = mc.MountainId
  LEFT JOIN Peaks p ON p.MountainId = m.Id
WHERE p.Elevation =
  (SELECT MAX(p.Elevation)
   FROM MountainsCountries mc
     LEFT JOIN Mountains m ON m.Id = mc.MountainId
     LEFT JOIN Peaks p ON p.MountainId = m.Id
   WHERE c.CountryCode = mc.CountryCode)
UNION
SELECT
  c.CountryName AS [Country],
  '(no highest peak)' AS [Highest Peak Name],
  0 AS [Highest Peak Elevation],
  '(no mountain)' AS [Mountain]
FROM
  Countries c
  LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
  LEFT JOIN Mountains m ON m.Id = mc.MountainId
  LEFT JOIN Peaks p ON p.MountainId = m.Id
WHERE 
  (SELECT MAX(p.Elevation)
   FROM MountainsCountries mc
     LEFT JOIN Mountains m ON m.Id = mc.MountainId
     LEFT JOIN Peaks p ON p.MountainId = m.Id
   WHERE c.CountryCode = mc.CountryCode) IS NULL
ORDER BY c.CountryName, [Highest Peak Name]
-------------------------------------------------------------
--Second Variant
-------------------------------------------------------------
WITH chp AS
    (SELECT
	    c.CountryName,
        p.PeakName,
        p.Elevation,
        m.MountainRange,
        ROW_NUMBER() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS rn
    FROM Countries AS c
    LEFT JOIN CountriesRivers AS cr
    ON c.CountryCode = cr.CountryCode
    LEFT JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
    LEFT JOIN Mountains AS m
    ON mc.MountainId = m.Id
    LEFT JOIN Peaks p
    ON p.MountainId = m.Id)

SELECT
    chp.CountryName AS [Country],
    ISNULL(chp.PeakName, '(no highest peak)') AS [Highest Peak Name],
    ISNULL(chp.Elevation, 0)  AS [Highest Peak Elevation],
    CASE WHEN chp.PeakName IS NOT NULL THEN chp.MountainRange ELSE '(no mountain)' END AS [Mountain]
FROM chp
WHERE rn = 1
--Problem 15
GO
CREATE TABLE Monasteries
(Id int not null identity primary key, 
Name nvarchar(100) not null, 
CountryCode char(2) not null,
CONSTRAINT FK_Monasteries_Countries 
FOREIGN KEY (CountryCode) REFERENCES Countries(CountryCode))
GO
INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')
GO
ALTER TABLE Countries
ADD IsDeleted nvarchar(10) not null DEFAULT ('false')
GO
UPDATE Countries
SET IsDeleted = 'true'
WHERE CountryCode IN ((SELECT c.CountryCode 
FROM Countries c 
JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
JOIN Rivers r ON cr.RiverId = r.Id
GROUP BY c.CountryCode
HAVING COUNT(r.Id) > 3))
GO
SELECT m.Name AS Monastery, c.CountryName AS Country
FROM Monasteries m
JOIN Countries c
ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 'false'
ORDER BY m.Name
--Problem 16
GO
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'
GO
INSERT INTO Monasteries(Name, CountryCode)
VALUES ('Hanga Abbey',
(SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))
GO
INSERT INTO Monasteries(Name, CountryCode)
VALUES ('Myin-Tin-Daik',
(SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))
GO
SELECT con.ContinentName, c.CountryName, COUNT(m.Id) AS MonasteriesCount
FROM Continents con
LEFT JOIN Countries c
ON c.ContinentCode = con.ContinentCode
LEFT JOIN Monasteries m
ON m.CountryCode = c.CountryCode
GROUP BY con.ContinentName, c.CountryName, c.IsDeleted
Having c.IsDeleted = 'false'
ORDER BY MonasteriesCount DESC, c.CountryName
--Problem 17

IF OBJECT_ID('fn_MountainsPeaksJSON') IS NOT NULL
  DROP FUNCTION fn_MountainsPeaksJSON
GO

CREATE FUNCTION fn_MountainsPeaksJSON()
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @json NVARCHAR(MAX) = '{"mountains":['

	DECLARE mountainsCursor CURSOR FOR
	SELECT Id, MountainRange FROM Mountains

	OPEN mountainsCursor
	DECLARE @MountainName NVARCHAR(MAX)
	DECLARE @MountainId INT
	FETCH NEXT FROM mountainsCursor INTO @MountainId, @MountainName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @json = @json + '{"name":"' + @MountainName + '","peaks":['

		DECLARE peaksCursor CURSOR FOR
		SELECT PeakName, Elevation FROM Peaks 
		WHERE MountainId = @MountainId

		OPEN peaksCursor
		DECLARE @PeakName NVARCHAR(MAX)
		DECLARE @Elevation INT
		FETCH NEXT FROM peaksCursor INTO @PeakName, @Elevation
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @json = @json + '{"name"' + ':"' + @PeakName + '","elevation":' + CONVERT(NVARCHAR(MAX), @Elevation) + '}'
			FETCH NEXT FROM peaksCursor INTO @PeakName, @Elevation
			IF @@FETCH_STATUS = 0
				SET @json = @json + ','
		END
		CLOSE peaksCursor
		DEALLOCATE peaksCursor	
		SET @json = @json + ']}'

		FETCH NEXT FROM mountainsCursor INTO @MountainId, @MountainName
		IF @@FETCH_STATUS = 0
			SET @json = @json + ','
	END
	CLOSE mountainsCursor
	DEALLOCATE mountainsCursor

	SET @json = @json + ']}'
	RETURN @json
END
GO

SELECT dbo.fn_MountainsPeaksJSON()
--Problem 18
DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;

DROP TABLE IF EXISTS `training_centers`;

CREATE TABLE `training_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text,
  `url` varchar(2083),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `courses`;

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `courses_timetable`;

CREATE TABLE `timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `training_center_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_courses_timetable_courses`
    FOREIGN KEY (`course_id`) 
    REFERENCES `courses` (`id`),
  CONSTRAINT `fk_courses_timetable_training_centers` 
    FOREIGN KEY (`training_center_id`) 
    REFERENCES `training_centers` (`id`)
);
USE trainings;
INSERT INTO `training_centers` VALUES (1, 'Sofia Learning', NULL, 'http://sofialearning.org'), (2, 'Varna Innovations & Learning', 'Innovative training center, located in Varna. Provides trainings in software development and foreign languages', 'http://vil.edu'), (3, 'Plovdiv Trainings & Inspiration', NULL, NULL),
(4, 'Sofia West Adult Trainings', 'The best training center in Lyulin', 'https://sofiawest.bg'), (5, 'Software Trainings Ltd.', NULL, 'http://softtrain.eu'),
(6, 'Polyglot Language School', 'English, French, Spanish and Russian language courses', NULL), (7, 'Modern Dances Academy', 'Learn how to dance!', 'http://danceacademy.bg');

INSERT INTO `courses` VALUES (101, 'Java Basics', 'Learn more at https://softuni.bg/courses/java-basics/'), (102, 'English for beginners', '3-month English course'), (103, 'Salsa: First Steps', NULL), (104, 'Avancée Français', 'French language: Level III'), (105, 'HTML & CSS', NULL), (106, 'Databases', 'Introductionary course in databases, SQL, MySQL, SQL Server and MongoDB'), (107, 'C# Programming', 'Intro C# corse for beginners'), (108, 'Tango dances', NULL), (109, 'Spanish, Level II', 'Aprender Español');

INSERT INTO `timetable`(course_id, training_center_id, start_date) VALUES (101, 1, '2015-01-31'), (101, 5, '2015-02-28'), (102, 6, '2015-01-21'), (102, 4, '2015-01-07'), (102, 2, '2015-02-14'), (102, 1, '2015-03-05'), (102, 3, '2015-03-01'), (103, 7, '2015-02-25'), (103, 3, '2015-02-19'), (104, 5, '2015-01-07'), (104, 1, '2015-03-30'), (104, 3, '2015-04-01'), (105, 5, '2015-01-25'), (105, 4, '2015-03-23'), (105, 3, '2015-04-17'), (105, 2, '2015-03-19'), (106, 5, '2015-02-26'), (107, 2, '2015-02-20'), (107, 1, '2015-01-20'), (107, 3, '2015-03-01'), (109, 6, '2015-01-13');

SET SQL_SAFE_UPDATES = 0;
UPDATE `timetable` t JOIN `courses` c ON t.course_id = c.id
SET t.start_date = DATE_SUB(t.start_date, INTERVAL 7 DAY)
WHERE c.name REGEXP '^[a-j]{1,5}.*s$';


SELECT 
  tc.name AS `training center`,
  t.start_date AS `start date`,
  c.name AS `course name`,
  c.description AS `more info`
FROM `timetable` t
  JOIN `courses` c ON t.course_id = c.id
  JOIN `training_centers` tc ON t.training_center_id = tc.id
ORDER BY t.start_date, t.id