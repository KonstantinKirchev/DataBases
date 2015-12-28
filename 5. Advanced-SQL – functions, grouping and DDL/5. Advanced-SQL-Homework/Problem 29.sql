CREATE TABLE WorkHours
	(Id int IDENTITY,
	[Date] date,
	Task nvarchar(50),
	[Hours] int,
	Comments nvarchar(50),
	EmployeeId int NOT NULL,
	CONSTRAINT PK_WorkHours PRIMARY KEY(Id),
	CONSTRAINT FK_Employees_WorkHours FOREIGN KEY(EmployeeId)
	REFERENCES Employees(EmployeeId))
