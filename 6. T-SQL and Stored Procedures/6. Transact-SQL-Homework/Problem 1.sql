CREATE TABLE Persons
(Id int IDENTITY,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
SSN nvarchar(20) NOT NULL,
CONSTRAINT PK_Persons PRIMARY KEY(Id))

GO
INSERT Persons(FirstName,LastName,SSN)
VALUES('Konstantin','Kirchev','8203213456'),
('Svetlin', 'Nakov', '8008053433'),
('Ralitsa', 'Raicheva', '7508101933'),
('Dido', 'Didov', '4706036637'),
('Asq', 'Vuchkova', '78010053409'),
('Ivaylo', 'Dinev', '8108053898')

GO
CREATE TABLE Accounts
(Id int IDENTITY,
PersonId int NOT NULL,
Balance money NOT NULL,
CONSTRAINT PK_Accounts PRIMARY KEY(Id),
CONSTRAINT FK_Accounts_Persons FOREIGN KEY(PersonId)
REFERENCES Persons(Id))

GO
INSERT Accounts(PersonId,Balance)
VALUES(1,50000.00),
(2,150000.00),
(3,5000.00),
(4,30000.00),
(5,1500.00),
(6,10000.00)

GO
SELECT *
FROM Persons

GO
CREATE PROCEDURE usp_FullName
AS
SELECT FirstName+' '+LastName AS [Full Name]
FROM Persons

GO
EXEC usp_FullName
