INSERT INTO Groups(Name)
VALUES ('Administrator'),('Moderator'), ('User')

INSERT INTO Users(UserName, UserPassword, FullName, GroupId) 
 	VALUES 
		('kosta', 'kostapass', 'Konstantin Kirchev', 1), 
		('dido', '4324325', 'DON Dido', 1), 
		('ancheto', '1919191', 'Anna Topolska', 3), 
		('ralichka', '1010101', 'Rali Rai', 2), 
		('beden', 'abvabv', 'Beden Mangal', 3), 
		('bogat', 'adminpass', 'Bogat Pi4', 1) 
