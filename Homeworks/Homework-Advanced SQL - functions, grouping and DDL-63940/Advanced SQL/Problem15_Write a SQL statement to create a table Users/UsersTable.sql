CREATE TABLE Users (
	ID int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	Username varchar(50) NOT NULL UNIQUE, 
	Password varchar(50),
	FullName varchar(50),
	LastLogin smalldatetime,
	CONSTRAINT [PasswordLength] CHECK (DATALENGTH([Password]) > 2)
)
