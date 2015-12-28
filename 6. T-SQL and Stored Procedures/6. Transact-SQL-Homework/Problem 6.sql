CREATE TABLE Logs
(Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
AccountId int NOT NULL,
OldSum money NOT NULL,
NewSum money NOT NULL
CONSTRAINT FK_Logs_Accounts FOREIGN KEY (AccountId)
REFERENCES Accounts(Id))

GO

CREATE TRIGGER tr_BankAccountUpdate ON Accounts FOR UPDATE
AS
INSERT INTO dbo.Logs(AccountId, OldSum, NewSum)
SELECT d.Id, d.Balance, i.Balance
FROM INSERTED i
JOIN DELETED d
ON i.Id = d.Id

GO

SELECT *
FROM Logs