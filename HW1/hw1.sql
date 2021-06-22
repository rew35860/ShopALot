-- DROPPING TABLES BEFORE CREATING IF EXISTS -- 
DROP TABLE IF EXISTS Workfor; 
DROP TABLE IF EXISTS Own; 
DROP TABLE IF EXISTS Stockedby; 
DROP TABLE IF EXISTS Orderitems; 
DROP TABLE IF EXISTS Orders; 
DROP TABLE IF EXISTS Products; 
DROP TABLE IF EXISTS Stores; 
DROP TABLE IF EXISTS Vehicles;
DROP TABLE IF EXISTS Shoppers; 
DROP TABLE IF EXISTS Customers; 
DROP TABLE IF EXISTS UserPhone; 
DROP TABLE IF EXISTS Users; 


-- Entity tables below: --
CREATE TABLE Users (
	user_id VARCHAR(100) NOT NULL PRIMARY KEY, 
	email VARCHAR(100), 
	first_name VARCHAR(100) NOT NULL, 
	last_name VARCHAR(100) NOT NULL
);

CREATE TABLE UserPhone (
	user_id VARCHAR(100) REFERENCES Users(user_id),
	kind VARCHAR(20) 
	CHECK(kind IN ('HOME', 'OFFICE', 'MOBILE')) NOT NULL, 
	number VARCHAR(20) NOT NULL,
	PRIMARY KEY(user_id, number)
);

CREATE TABLE Customers (
	customer_id VARCHAR(100) REFERENCES Users(user_id),
	PRIMARY KEY(customer_id)
);

CREATE TABLE Shoppers (
	user_id VARCHAR(100) REFERENCES Users(user_id),
	capacity INTEGER,
	PRIMARY KEY(user_id)
);

CREATE TABLE Vehicles (
	state VARCHAR(15) NOT NULL, 
	license_plate VARCHAR(20) NOT NULL, 
	year INTEGER, 
	model VARCHAR(50), 
	make VARCHAR(50) NOT NULL, 
	color VARCHAR(50) NOT NULL,
	PRIMARY KEY(state, license_plate)
);

CREATE TABLE Stores (
	store_id VARCHAR(10) PRIMARY KEY, 
	name VARCHAR(100) NOT NULL, 
	street VARCHAR(100) NOT NULL, 
	city VARCHAR(100) NOT NULL, 
	state VARCHAR(100) NOT NULL, 
	zip_code INTEGER NOT NULL, 
	phone VARCHAR(100) NOT NULL, 
	categories TEXT NOT NULL
);

CREATE TABLE Products (
	product_id VARCHAR(50) PRIMARY KEY, 
	
	category VARCHAR(100)
	CHECK(category IN ('Baby Care', 'Beverages', 'Bread & Bakery', 
	'Breakfast & Cereal', 'Canned Goods & Soups', 'Condiments & Spice & Bake', 
	'Cookies & Snacks & Candy', 'Dairy & Eggs & Cheese', 'Deli', 
	'Frozen Foods', 'Fruits & Vegetables', 'Grains & Pasta & Sides', 
	'Meat & Seafood', 'Paper & Cleaning & Home', 'Personal Care & Health', 
	'Pet Care')) NOT NULL, 
	
	name VARCHAR(100) NOT NULL, 
	description VARCHAR(100) NOT NULL, 
	list_price decimal(5 , 2 )
);

CREATE TABLE Orders (
	order_id VARCHAR(100) PRIMARY KEY, 
	total_price decimal(5 , 2 ), 
	time_placed TIMESTAMP NOT NULL, 
	pickup_time TIMESTAMP, 
	customer_id VARCHAR(100) REFERENCES Customers(customer_id) ON DELETE CASCADE, 
	shopper_id VARCHAR(100) REFERENCES Shoppers(user_id) ON DELETE CASCADE, 
	state VARCHAR(100) NOT NULL, 
	license_plate VARCHAR(20) NOT NULL,
	FOREIGN KEY (state, license_plate) REFERENCES Vehicles(state, license_plate) ON DELETE CASCADE,
	store_id VARCHAR(10) REFERENCES Stores(store_id) ON DELETE CASCADE, 
	time_fulfilled TIMESTAMP
);

CREATE TABLE OrderItems (
	item_id VARCHAR(50), 
	qty INTEGER NOT NULL, 
	selling_price decimal(5 , 2 ) NOT NULL, 
	order_id VARCHAR(100) REFERENCES Orders(order_id) ON DELETE CASCADE, 
	product_id VARCHAR(100) REFERENCES Products(product_id) ON DELETE CASCADE,
	PRIMARY KEY(item_id, order_id)
);

-- Relationship tables below: --
CREATE TABLE StockedBy (
	product_id VARCHAR(100) REFERENCES Products(product_id) ON DELETE CASCADE, 
	store_id VARCHAR(100) REFERENCES Stores(store_id) ON DELETE CASCADE, 
	qty INTEGER NOT NULL,
	PRIMARY KEY(product_id, store_id)
);

CREATE TABLE Own (
	state VARCHAR(100) NOT NULL, 
	license_plate VARCHAR(20) NOT NULL,
	FOREIGN KEY (state, license_plate) REFERENCES Vehicles(state, license_plate) ON DELETE CASCADE,
	user_id VARCHAR(100) REFERENCES Users(user_id) ON DELETE CASCADE,
	PRIMARY KEY(state, license_plate, user_id)
);

CREATE TABLE WorkFor (
	store_id VARCHAR(100) REFERENCES Stores(store_id) ON DELETE CASCADE, 
	shopper_id VARCHAR(100) REFERENCES Shoppers(user_id) ON DELETE CASCADE,
	PRIMARY KEY(store_id, shopper_id)
);


-- Data Loading --
copy users from '/Users/rew/Downloads/ShopALot.com Data/users.csv' delimiter ',' CSV HEADER;
copy UserPhone from '/Users/rew/Downloads/ShopALot.com Data/phones.csv' delimiter ',' CSV HEADER;
copy customers from '/Users/rew/Downloads/ShopALot.com Data/customers.csv' delimiter ',' CSV HEADER;
copy shoppers from '/Users/rew/Downloads/ShopALot.com Data/shoppers.csv' delimiter ',' CSV HEADER;
copy vehicles from '/Users/rew/Downloads/ShopALot.com Data/vehicles.csv' delimiter ',' CSV HEADER;
copy stores from '/Users/rew/Downloads/ShopALot.com Data/stores.csv' delimiter ',' CSV HEADER;
copy products from '/Users/rew/Downloads/ShopALot.com Data/products.csv' delimiter ',' CSV HEADER;
copy orders from '/Users/rew/Downloads/ShopALot.com Data/orders.csv' delimiter ',' CSV HEADER;
copy orderitems from '/Users/rew/Downloads/ShopALot.com Data/orderitems.csv' delimiter ',' CSV HEADER;
copy stockedby from '/Users/rew/Downloads/ShopALot.com Data/stockedby.csv' delimiter ',' CSV HEADER;
copy own from '/Users/rew/Downloads/ShopALot.com Data/own.csv' delimiter ',' CSV HEADER;
copy workfor from '/Users/rew/Downloads/ShopALot.com Data/workfor.csv' delimiter ',' CSV HEADER;


-- -- HOMEWORK 2 -- 
-- select o.shopper_id, o.order_id, COUNT (DISTINCT oi.item_id) as unique_items
-- from orders o, orderitems oi 
-- where o.order_id = oi.order_id and o.shopper_id = '0JKLY'
-- order by o.shopper_ido.order_id;

-- select o.shopper_id, o.order_id, oi.item_id, oi.qty 
-- from Orders o, OrderItems oi 
-- where o.order_id = oi.order_id;

-- copy (select o.shopper_id, o.order_id, oi.item_id, qty.oi from Orders o, OrderItems oi where o.order_id = oi.order_id)
-- to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/shoppersq7b.csv' DELIMITER ',' CSV HEADER;


-- select o.order_id, p.name, p.category, p.list_price 
-- from orderItems o, products p 
-- where o.product_id = p.product_id and o.order_id = '005SN';

copy (select o.order_id, p.name, p.category, p.list_price, o.item_id from orderItems o, products p where o.product_id = p.product_id and p.list_price IS NOT NULL) 
to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/nameCatasc.csv' DELIMITER ',' CSV HEADER;


-- copy (SELECT o.customer_id, o.order_id, o.total_price FROM Orders o) to 
-- '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/ordersq7a.csv' DELIMITER ',' CSV HEADER;


-- select SUM(o.total_price) from orders o 
-- where o.customer_id = '32976' and o.time_placed >= '2020-03-01 00:00:00' and o.time_placed <= '2020-09-01 00:00:00';

-- copy (select o.customer_id, o.order_id, o.total_price, o.time_placed from orders o where o.total_price is not null) to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/customersq7d.csv' DELIMITER ',' CSV HEADER;

-- copy Customers to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/customers.csv' DELIMITER ',' CSV HEADER;
-- copy Products to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/products.csv' DELIMITER ',' CSV HEADER;
-- copy Orders to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/orders.csv' DELIMITER ',' CSV HEADER;
-- copy Orderitems to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/orderitems.csv' DELIMITER ',' CSV HEADER;
-- copy (select * from products p where p.list_price is not null) to '/Users/rew/Desktop/School/CS 122D/HW/HW2/CSV files/productsq6.csv' DELIMITER ',' CSV HEADER;

-- --Query Answers--
-- -- Problem A --
-- SELECT (SELECT COUNT(*) FROM stores) as stores_count,
-- 	(SELECT COUNT(*) FROM customers) as customer_count, 
-- 	(SELECT COUNT(*) FROM products) as products_count;

-- -- Problem B --
-- SELECT sp.user_id as Shoppers
-- FROM Shoppers sp, Stores s, Workfor w
-- WHERE sp.user_id = w.shopper_id 
-- 	and s.store_id = w.store_id 
-- 	and sp.capacity > 4
-- 	and s.city = 'Seattle' 
-- 	and s.state = 'WA';

-- -- Problem C --
-- SELECT s.store_id, s.name, COUNT(DISTINCT pr.product_id) as product_count
-- FROM Orderitems oi, Products pr, Stores s, Stockedby sb
-- WHERE sb.product_id = pr.product_id 
-- 	and sb.store_id = s.store_id
-- 	and pr.product_id = oi.product_id
-- 	and oi.selling_price < pr.list_price
-- GROUP BY s.store_id
-- ORDER BY COUNT(DISTINCT pr.product_id) DESC
-- LIMIT 10;

-- -- Problem D --
-- SELECT o.order_id, o.total_price, o.time_placed
-- FROM orderitems oi, orders o
-- WHERE oi.order_id = o.order_id
-- 	and time_placed > TO_TIMESTAMP('2020-05-01', 'YYYY-MM-DD')
-- 	and time_placed < TO_TIMESTAMP('2020-07-01', 'YYYY-MM-DD')
-- 	and oi.qty > 25; 

-- -- Problem E --
-- SELECT AVG(o.total_price) 
-- FROM Orders o
-- WHERE o.time_placed >= TO_TIMESTAMP('2020-03-25', 'YYYY-MM-DD')
-- 	and o.time_placed < TO_TIMESTAMP('2020-04-1', 'YYYY-MM-DD');

-- -- Problem F --
-- SELECT s.store_id, s.name, category_list, array_length(category_list, 1)
-- FROM Stores s, string_to_array(s.categories,', ') AS category_list
-- WHERE s.zip_code = 44401;

-- -- Problem G --
-- SELECT s.store_id, s.name, category_list
-- FROM Stores s, UNNEST(string_to_array(s.categories,', ')) AS category_list
-- WHERE s.zip_code = 44401
-- ORDER BY s.store_id;

-- -- Problem H --
-- SELECT cat.category_list as categories, cat.stores_count, pro.minimum, pro.maximum, pro.average
-- FROM (SELECT category_list, COUNT(s.store_id) as stores_count
-- 		FROM Stores s, UNNEST(string_to_array(s.categories, ', ')) AS category_list 
-- 		GROUP BY category_list
-- 		ORDER BY COUNT(s.store_id) DESC
-- 		LIMIT 5) as cat, 
-- 	(SELECT pr.category, min(pr.list_price) as minimum, max(pr.list_price) as maximum, avg(pr.list_price) as average
-- 		FROM Products pr
-- 		GROUP BY pr.category 
-- 		) as pro
-- where pro.category = cat.category_list
-- ORDER BY cat.stores_count DESC;

-- -- Problem I --
-- EXPLAIN ANALYZE SELECT COUNT(*) AS orders_greater_than_650
-- FROM Orders o 
-- WHERE o.total_price > 650;
-- /*The query scanned every column in Orders entity and filtered out 19996 rows that did not satisfy the condition, and the execution time is 5.539 ms.*/

-- -- Problem J --
-- SELECT COUNT(o.order_id)
-- FROM Orders o, (SELECT oi.order_id, SUM(oi.selling_price * oi.qty) AS price
-- 				FROM Orderitems oi 
-- 				GROUP BY oi.order_id) AS oi1
-- WHERE o.order_id = oi1.order_id and o.total_price != oi1.price;

-- UPDATE Orders o
-- SET total_price = offending_orders.price
-- FROM (SELECT o.order_id, o.total_price, oi1.price as price
-- 		FROM Orders o, (SELECT oi.order_id, SUM(oi.selling_price * oi.qty) AS price
-- 						FROM Orderitems oi 
-- 						GROUP BY oi.order_id) AS oi1
-- 		WHERE o.order_id = oi1.order_id and o.total_price != oi1.price) AS Offending_orders
-- WHERE o.order_id = Offending_orders.order_id;

-- -- Problem K --
-- CREATE INDEX total_price 
-- ON Orders(total_price);

-- -- RUN QUERY I WITH EXPLAIN ANALYZE -- 
-- EXPLAIN ANALYZE SELECT COUNT(*) AS orders_greater_than_650
-- FROM Orders o 
-- WHERE o.total_price > 650;
-- /* The running time after creating the index is 0.045 ms, which is much faster than before. I think the main reason is that the query doesn't scan every column in the Order entity, but only the subset (total_price).*/ 

-- -- Problem L -- 
-- SELECT s.state, s.city, s.zip_code, count(s.store_id)
-- FROM Stores s 
-- GROUP BY ROLLUP(s.state, s.city, s.zip_code)
-- ORDER BY (s.state, s.city, s.zip_code) DESC
-- LIMIT 20;

-- -- Problem M (extra credit) --      
-- SELECT pr.product_id, pr.name, pr.category, pr.list_price, 
-- 		DENSE_RANK() OVER (PARTITION BY pr.category ORDER BY pr.list_price DESC) AS ranks
-- FROM Products pr
-- LIMIT 10;

