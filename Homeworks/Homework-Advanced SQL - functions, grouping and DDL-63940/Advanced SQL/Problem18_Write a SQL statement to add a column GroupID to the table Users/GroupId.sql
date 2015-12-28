ALTER TABLE Users
	ADD GroupId int
	CONSTRAINT FK_Users_Groups
		FOREIGN KEY (GroupId) REFERENCES Groups(Id)
