// Introduction
mongo
use SoftUni
db
show dbs

// Add data in db
var bulk = db.courses.initializeUnorderedBulkOp();
bulk.insert({ name: "Programming Basics", level: 0, trainers: ["Svetlin Nakov", "Angel Georgiev"], isActive: true, studentsCount: 140 });
bulk.insert({ name: "Java Basics", level: 1, trainers: ["Bogomil Dimitrov", "Yordan Darakchiev"], isActive: true, studentsCount: 16 });
bulk.insert({ name: "Web Fundamentals", level: 1, trainers: ["Nikolay Bankin"], isActive: true, studentsCount: 58 });
bulk.insert({ name: "JavaScript Basics", level: 1, trainers: ["Bogomil Dimitrov", "Vladimir Georgiev"], isActive: true, studentsCount: 44 });
bulk.insert({ name: "PHP Basics", level: 1, trainers: ["Nikolay Bankin", "Angel Georgiev"], isActive: true, studentsCount: 63 });
bulk.insert({ name: "Teamwork and Personal Skills", level: 1, trainers: ["Angel Georgiev"], isActive: true, studentsCount: 129 });
bulk.insert({ name: "Object-Oriented Programming", level: 2, trainers: ["Yordan Darakchiev", "Atanas Rusenov"], isActive: true, studentsCount: 78 });
bulk.insert({ name: "High-Quality Code", level: 2, trainers: ["Yordan Darakchiev", "Atanas Rusenov"], isActive: true, studentsCount: 121 });
bulk.insert({ name: "Advanced JavaScript", level: 2, trainers: ["Vladimir Georgiev"], isActive: true, studentsCount: 53 });
bulk.insert({ name: "JavaScript Applications", level: 2, trainers: ["Bogomil Dimitrov", "Vladimir Georgiev"], isActive: true, studentsCount: 63 });
bulk.insert({ name: "SPA with AngularJS", level: 2, trainers: ["Bogomil Dimitrov", "Vladimir Georgiev"], isActive: true, studentsCount: 28 });
bulk.insert({ name: "Databases", level: 3, trainers: ["Svetlin Nakov", "Vladimir Georgiev", "Boris Hristov"], isActive: true, studentsCount: 94 });
bulk.insert({ name: "Database Applications", level: 3, trainers: ["Svetlin Nakov", "Vladimir Georgiev", "Nayden Gochev"], isActive: true, studentsCount: 11 });
bulk.insert({ name: "Web Services and Cloud", level: 3, trainers: ["Svetlin Nakov", "Vladimir Georgiev"], isActive: true, studentsCount: 39 });
bulk.insert({ name: "Web Development", level: 3, trainers: ["Svetlin Nakov", "Vladimir Georgiev"], isActive: true, studentsCount: 60 });
bulk.insert({ name: "ASP.NET MVC", level: 3, trainers: ["Svetlin Nakov", "Vladimir Georgiev"], isActive: true, studentsCount: 30 });
bulk.execute();

// Authentication
use SoftUni
db.createUser({
	"user": "vgeorgiev",
	"pwd": "slojnaParola123",
	"roles": ["readWrite", "dbAdmin"]
});
db.auth("vgeorgiev", "slojnaParola123");

// Read
use SoftUni
db.courses.find({ level: { $gt: 2 }}, { name: true }).limit(5);

db.courses.find({ name: "Databases" });
db.courses.find({ name: { $eq: "Databases" }});

db.courses.find({ 
	$or: [
		{ level: { $eq: 0 }}, 
		{ level: { $gt: 2 }}
	]
});

// Insert
db.courses.insert({
	name: "Algorithms",
	description: "Data Structures and Algorithms",
	level: 4
});

// Bulk insert
var bulk = db.courses.initializeUnorderedBulkOp();
bulk.insert({ name: "SEO and Online marketing", level: 4 });
bulk.insert({ name: "Quality Assurance", level: 4 });
bulk.insert({ name: "node.js", level: 4});
bulk.insert({ name: "Software Engineering", level: 4});
bulk.insert({ name: "Computer Networks", level: 4});
bulk.insert({ name: "Artificial Intelligence", level: 4});
bulk.execute();

// Update
db.courses.update(
	{ name: { $et: "Databases" } },
	{ $set: { description: "Concepts, MSSQL, MySQL, Oracle..." } },
	{ multi: true }
);

// Delete
db.courses.remove({ name: "Databases" });

// Aggregation TODO: Not working! Fix it!
db.courses.aggregate([ 
	{ $match: { isActive: true }}, 
	{ $group: { _id: "$level", students: { $sum: "$studentsCount" } } } 
]);