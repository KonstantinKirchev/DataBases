SELECT e.*, a.AddressText
FROM Employees e
JOIN Addresses a
ON e.AddressID = a.AddressID