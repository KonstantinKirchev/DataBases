INSERT INTO WorkHours([Date],Task, [Hours], Comments, EmployeeId)
	VALUES (GETDATE(),'Open the store', 7, 'The total sales are: 120.00 lv.', 1),
	(GETDATE(),'Close for a lunch break', 12, 'The total sales are: 220.00 lv.', 2),
	(GETDATE(),'Afternoon break', 15, 'The total sales are: 350.00 lv.', 1),
	(GETDATE(),'Close the store', 17, 'The total sales are: 600.00 lv.', 3)

	UPDATE WorkHours
	SET [Hours] = 19
	WHERE [Hours] = 17

	DELETE FROM WorkHours
	WHERE [Hours] = 15
