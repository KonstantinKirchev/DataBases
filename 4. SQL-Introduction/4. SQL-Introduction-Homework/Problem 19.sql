SELECT e.*, a.AddressText
FROM Employees e, Addresses a
WHERE e.AddressID = a.AddressID