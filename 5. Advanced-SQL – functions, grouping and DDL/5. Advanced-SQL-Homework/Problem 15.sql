CREATE TABLE Users (
	Id int IDENTITY,
	UserName nvarchar(50) UNIQUE NOT NULL,
	UserPassword nvarchar(50),
	FullName nvarchar(50) NOT NULL,
	LastLogin datetime,
	CONSTRAINT PK_Users PRIMARY KEY(Id),
	CONSTRAINT PasswordMinLength CHECK (DATALENGTH([UserPassword]) > 4))
	
INSERT INTO Users(UserName, UserPassword, FullName, LastLogin) 
VALUES ('Gosho', 'goshovica', 'Gosho Goshev', GETDATE() - 5), 
 	   ('Pesho', 'peshovica', 'Pesho Peshev', GETDATE() - 2), 
 	   ('Stanka', 'stankovica', 'Stanka Stankova', GETDATE() - 1) 
GO 





