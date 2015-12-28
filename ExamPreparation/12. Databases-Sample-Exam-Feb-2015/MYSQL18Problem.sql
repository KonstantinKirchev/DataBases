drop database if exists `orders`;

CREATE SCHEMA `orders` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ;

use `orders`;

CREATE TABLE products
(id int not null auto_increment primary key,
 product_name nvarchar(500),
 price decimal(10,2));
 
 CREATE TABLE customers
(id int not null auto_increment primary key,
 customer_name nvarchar(500));
 
 CREATE TABLE orders
(id int not null auto_increment primary key,
 order_date datetime);
 
 CREATE TABLE order_items
(id int not null auto_increment primary key,
 order_id int,
 product_id int,
 quantity decimal(10,2));
 
 ALTER TABLE order_items
 ADD CONSTRAINT fk_order_items_order
 foreign key (order_id) references orders(id);
 
  ALTER TABLE order_items
 ADD CONSTRAINT fk_order_items_product
 foreign key (product_id) references products(id);
 
INSERT INTO `products` 
VALUES (1,'beer',1.20), (2,'cheese',9.50), (3,'rakiya',12.40), (4,'salami',6.33), (5,'tomatos',2.50), (6,'cucumbers',1.35), (7,'water',0.85), (8,'apples',0.75);
INSERT INTO `customers` 
VALUES (1,'Peter'), (2,'Maria'), (3,'Nakov'), (4,'Vlado');
INSERT INTO `orders` 
VALUES (1,'2015-02-13 13:47:04'), (2,'2015-02-14 22:03:44'), (3,'2015-02-18 09:22:01'), (4,'2015-02-11 20:17:18');
INSERT INTO `order_items` 
VALUES (12,4,6,2.00), (13,3,2,4.00), (14,3,5,1.50), (15,2,1,6.00), (16,2,3,1.20), (17,1,2,1.00), (18,1,3,1.00), (19,1,4,2.00), (20,1,5,1.00), (21,3,1,4.00), (22,1,1,3.00);


select p.product_name, COUNT(o.id) as num_orders, ifnull(SUM(oi.quantity), 0) as quantity, p.price, ifnull(SUM(oi.quantity) * p.price, 0) as total_price
from products p 
left join order_items oi
on p.id = oi.product_id
left join orders o
on o.id = oi.order_id
group by p.product_name, p.price
order by p.product_name