CREATE VIEW [Logged in today] 
 	AS SELECT * FROM Users u 
	WHERE DATEDIFF(DAY, u.LastLogin, GETDATE()) = 0 