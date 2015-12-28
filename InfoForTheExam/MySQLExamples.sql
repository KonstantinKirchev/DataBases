DROP DATABASE IF EXISTS `orders`;

CREATE DATABASE `orders`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `orders`;

DROP TABLE IF EXISTS `products`;

CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` nvarchar(45) NOT NULL,
  `price` decimal(10,2),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `customers`;

CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` nvarchar(100) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `orders`;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `order_items`;

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_order_items_orders`
    FOREIGN KEY (`order_id`) 
    REFERENCES `orders` (`id`),
    CONSTRAINT `fk_order_items_products`
    FOREIGN KEY (`product_id`) 
    REFERENCES `products` (`id`)
);
USE orders;
INSERT INTO `products` VALUES (1,'beer',1.20), (2,'cheese',9.50), (3,'rakiya',12.40), (4,'salami',6.33), (5,'tomatos',2.50), (6,'cucumbers',1.35), (7,'water',0.85), (8,'apples',0.75);
INSERT INTO `customers` VALUES (1,'Peter'), (2,'Maria'), (3,'Nakov'), (4,'Vlado');
INSERT INTO `orders` VALUES (1,'2015-02-13 13:47:04'), (2,'2015-02-14 22:03:44'), (3,'2015-02-18 09:22:01'), (4,'2015-02-11 20:17:18');
INSERT INTO `order_items` VALUES (12,4,6,2.00), (13,3,2,4.00), (14,3,5,1.50), (15,2,1,6.00), (16,2,3,1.20), (17,1,2,1.00), (18,1,3,1.00), (19,1,4,2.00), (20,1,5,1.00), (21,3,1,4.00), (22,1,1,3.00);

select p.name as product_name, COUNT(o.id) as num_orders, ifnull(SUM(oi.quantity),0) as quantity, p.price as price, ifnull((SUM(oi.quantity) * price), 0) as total_price  
from products p
left join order_items oi
on oi.product_id = p.id
left join orders o
on oi.order_id = o.id 
group by p.name, p.price
order by p.name;

DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;
CREATE TABLE `training_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_name` nvarchar(100) not null,
  `training_description` nvarchar(500),
  `url` nvarchar(100),
  PRIMARY KEY (`id`)
);

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_name` nvarchar(100) not null,
  `course_description` nvarchar(500),
  PRIMARY KEY (`id`)
);

CREATE TABLE `timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `training_center_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_timetable_courses`
    FOREIGN KEY (`course_id`) 
    REFERENCES `courses` (`id`),
    CONSTRAINT `fk_timetable_training_centers`
    FOREIGN KEY (`training_center_id`) 
    REFERENCES `training_centers` (`id`)
);

USE `trainings`;

INSERT INTO `training_centers` VALUES (1, 'Sofia Learning', NULL, 'http://sofialearning.org'), (2, 'Varna Innovations & Learning', 'Innovative training center, located in Varna. Provides trainings in software development and foreign languages', 'http://vil.edu'), (3, 'Plovdiv Trainings & Inspiration', NULL, NULL),
(4, 'Sofia West Adult Trainings', 'The best training center in Lyulin', 'https://sofiawest.bg'), (5, 'Software Trainings Ltd.', NULL, 'http://softtrain.eu'),
(6, 'Polyglot Language School', 'English, French, Spanish and Russian language courses', NULL), (7, 'Modern Dances Academy', 'Learn how to dance!', 'http://danceacademy.bg');

INSERT INTO `courses` VALUES (101, 'Java Basics', 'Learn more at https://softuni.bg/courses/java-basics/'), (102, 'English for beginners', '3-month English course'), (103, 'Salsa: First Steps', NULL), (104, 'Avancée Français', 'French language: Level III'), (105, 'HTML & CSS', NULL), (106, 'Databases', 'Introductionary course in databases, SQL, MySQL, SQL Server and MongoDB'), (107, 'C# Programming', 'Intro C# corse for beginners'), (108, 'Tango dances', NULL), (109, 'Spanish, Level II', 'Aprender Español');

INSERT INTO `timetable`(course_id, training_center_id, start_date) VALUES (101, 1, '2015-01-31'), (101, 5, '2015-02-28'), (102, 6, '2015-01-21'), (102, 4, '2015-01-07'), (102, 2, '2015-02-14'), (102, 1, '2015-03-05'), (102, 3, '2015-03-01'), (103, 7, '2015-02-25'), (103, 3, '2015-02-19'), (104, 5, '2015-01-07'), (104, 1, '2015-03-30'), (104, 3, '2015-04-01'), (105, 5, '2015-01-25'), (105, 4, '2015-03-23'), (105, 3, '2015-04-17'), (105, 2, '2015-03-19'), (106, 5, '2015-02-26'), (107, 2, '2015-02-20'), (107, 1, '2015-01-20'), (107, 3, '2015-03-01'), (109, 6, '2015-01-13');

UPDATE `timetable` t JOIN `courses` c ON t.course_id = c.id
SET t.start_date = DATE_SUB(t.start_date, INTERVAL 7 DAY)
WHERE c.course_name REGEXP '^[a-j]{1,5}.*s$';

select tc.training_name as 'training center', t.start_date as 'start date', c.course_name as 'course name', c.course_description as 'more info'
from timetable t
join training_centers tc
on t.training_center_id = tc.id
join courses c
on t.course_id = c.id
order by t.start_date, tc.id;












DROP DATABASE IF EXISTS `trainings`;

CREATE DATABASE `trainings`
CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE `trainings`;

DROP TABLE IF EXISTS `training_centers`;

CREATE TABLE `training_centers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text,
  `url` varchar(2083),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `courses`;

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `courses_timetable`;

CREATE TABLE `timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `training_center_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_courses_timetable_courses`
    FOREIGN KEY (`course_id`) 
    REFERENCES `courses` (`id`),
  CONSTRAINT `fk_courses_timetable_training_centers` 
    FOREIGN KEY (`training_center_id`) 
    REFERENCES `training_centers` (`id`)
);

INSERT INTO `training_centers` VALUES
(1, 'Sofia Learning', NULL, 'http://sofialearning.org'),
(2, 'Varna Innovations & Learning', 'Innovative training center, located in Varna. Provides trainings in software development and foreign languages', 'http://vil.edu'),
(3, 'Plovdiv Trainings & Inspiration', NULL, NULL),
(4, 'Sofia West Adult Trainings', 'The best training center in Lyulin', 'https://sofiawest.bg'),
(5, 'Software Trainings Ltd.', NULL, 'http://softtrain.eu'),
(6, 'Polyglot Language School', 'English, French, Spanish and Russian language courses', NULL),
(7, 'Modern Dances Academy', 'Learn how to dance!', 'http://danceacademy.bg');

INSERT INTO `courses` VALUES
(101, 'Java Basics', 'Learn more at https://softuni.bg/courses/java-basics/'),
(102, 'English for beginners', '3-month English course'),
(103, 'Salsa: First Steps', NULL),
(104, 'Avancée Français', 'French language: Level III'),
(105, 'HTML & CSS', NULL),
(106, 'Databases', 'Introductionary course in databases, SQL, MySQL, SQL Server and MongoDB'),
(107, 'C# Programming', 'Intro C# corse for beginners'),
(108, 'Tango dances', NULL),
(109, 'Spanish, Level II', 'Aprender Español');

INSERT INTO `timetable`(course_id, training_center_id, start_date) VALUES
(101, 1, '2015-01-31'), (101, 5, '2015-02-28'),
(102, 6, '2015-01-21'), (102, 4, '2015-01-07'), (102, 2, '2015-02-14'), (102, 1, '2015-03-05'), (102, 3, '2015-03-01'),
(103, 7, '2015-02-25'), (103, 3, '2015-02-19'),
(104, 5, '2015-01-07'), (104, 1, '2015-03-30'), (104, 3, '2015-04-01'),
(105, 5, '2015-01-25'), (105, 4, '2015-03-23'), (105, 3, '2015-04-17'), (105, 2, '2015-03-19'),
(106, 5, '2015-02-26'),
(107, 2, '2015-02-20'), (107, 1, '2015-01-20'), (107, 3, '2015-03-01'), 
(109, 6, '2015-01-13');

UPDATE `timetable` t
  JOIN `courses` c ON t.course_id = c.id
SET t.start_date = DATE_SUB(t.start_date, INTERVAL 7 DAY)
WHERE c.name REGEXP '^[a-j]{1,5}.*s$';

SELECT 
  tc.name AS `traning center`,
  t.start_date AS `start date`,
  c.name AS `course name`,
  c.description AS `more info`
FROM `timetable` t
  JOIN `courses` c ON t.course_id = c.id
  JOIN `training_centers` tc ON t.training_center_id = tc.id
ORDER BY t.start_date, t.id