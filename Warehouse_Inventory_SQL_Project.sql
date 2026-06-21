CREATE DATABASE warehouse_db;
USE warehouse_db;
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(255)
);

CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100),
    capacity INT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    warehouse_id INT,
    quantity INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    product_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    product_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);

INSERT INTO suppliers VALUES
(1,'ABC Traders','9876543210','abc@gmail.com','Chennai'),
(2,'XYZ Supplies','9123456780','xyz@gmail.com','Hyderabad'),
(3,'Global Mart','9988776655','global@gmail.com','Bangalore'),
(4,'Prime Goods','9001122334','prime@gmail.com','Delhi'),
(5,'Super Wholesale','9112233445','super@gmail.com','Mumbai'),
(6,'Royal Suppliers','9223344556','royal@gmail.com','Pune');

INSERT INTO products VALUES
(1,'Laptop','Electronics',55000,1),
(2,'Mobile','Electronics',20000,2),
(3,'Keyboard','Accessories',1500,1),
(4,'Mouse','Accessories',800,3),
(5,'Chair','Furniture',3000,4),
(6,'Table','Furniture',5000,5),
(7,'Printer','Electronics',12000,6);

INSERT INTO warehouses VALUES
(1,'Main WH','Chennai',10000),
(2,'North WH','Delhi',8000),
(3,'South WH','Bangalore',6000);

INSERT INTO inventory VALUES
(1,1,1,50,'2026-06-20'),
(2,2,1,30,'2026-06-20'),
(3,3,2,100,'2026-06-20'),
(4,4,2,10,'2026-06-20'),
(5,5,3,25,'2026-06-20'),
(6,6,3,40,'2026-06-20'),
(7,7,1,5,'2026-06-20');

INSERT INTO sales VALUES
(1,'Ravi',1,2,'2026-06-20'),
(2,'Meena',2,1,'2026-06-20'),
(3,'Kiran',1,1,'2026-06-20'),
(4,'Arjun',3,5,'2026-06-20'),
(5,'Divya',4,2,'2026-06-20'),
(6,'Sneha',5,1,'2026-06-20');

SELECT * FROM products
WHERE price > 10000;

SELECT * FROM products
WHERE name LIKE 'L%';

SELECT * FROM products
WHERE price BETWEEN 1000 AND 30000;

SELECT * FROM products
ORDER BY price DESC
LIMIT 3;

SELECT product_id, SUM(quantity) AS total_sold
FROM sales
GROUP BY product_id;

SELECT product_id, SUM(quantity) AS total_sold
FROM sales
GROUP BY product_id
HAVING SUM(quantity) > 2;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_suppliers
FROM suppliers;

SELECT COUNT(*) AS stocked_products
FROM inventory
WHERE quantity > 0;

SELECT SUM(quantity) AS total_stock
FROM inventory;

SELECT SUM(quantity) AS total_sold
FROM sales;

SELECT product_id, SUM(quantity) AS total_sold
FROM sales
GROUP BY product_id;

SELECT AVG(price) AS avg_price
FROM products;

SELECT AVG(quantity) AS avg_stock
FROM inventory;

SELECT MIN(quantity) AS min_stock
FROM inventory;

SELECT MAX(price) AS max_price
FROM products;

SELECT p.name, s.name AS supplier
FROM products p
INNER JOIN suppliers s
ON p.supplier_id = s.supplier_id;

SELECT p.name, i.quantity
FROM products p
LEFT JOIN inventory i
ON p.product_id = i.product_id;

SELECT 
    w.warehouse_id,
    w.name,
    i.product_id,
    i.quantity
FROM inventory i
RIGHT JOIN warehouses w
ON i.warehouse_id = w.warehouse_id;

SELECT 
    s.supplier_id,
    s.name,
    p.product_id,
    p.name AS product_name
FROM products p
RIGHT JOIN suppliers s
ON p.supplier_id = s.supplier_id;

SELECT 
    p1.name AS product1,
    p2.name AS product2,
    p1.price AS price1,
    p2.price AS price2
FROM products p1
JOIN products p2
ON p1.price > p2.price;


SELECT * FROM products
WHERE price = (SELECT MAX(price) FROM products);

SELECT * FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM sales);

CREATE VIEW stock_view AS
SELECT p.name, i.quantity
FROM products p
JOIN inventory i ON p.product_id = i.product_id;

SELECT * FROM stock_view;

INSERT INTO sales VALUES (7,'Test User',1,3,'2026-06-21');

SELECT * FROM inventory;

SELECT 
    name,
    price,
    RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;

SELECT 
    product_id,
    quantity,
    SUM(quantity) OVER (ORDER BY sale_id) AS running_total
FROM sales;

SELECT 
    product_id,
    SUM(quantity) AS total_sold,
    DENSE_RANK() OVER (ORDER BY SUM(quantity) DESC) AS sales_rank
FROM sales
GROUP BY product_id;

DELIMITER $$

CREATE PROCEDURE add_stock(
    IN pid INT,
    IN wid INT,
    IN qty INT
)
BEGIN
    UPDATE inventory
    SET quantity = quantity + qty,
        last_updated = NOW()
    WHERE product_id = pid
    AND warehouse_id = wid;
END $$

DELIMITER ;

CALL add_stock(1, 1, 20);

DELIMITER $$

CREATE PROCEDURE reduce_stock(
    IN pid INT,
    IN wid INT,
    IN qty INT
)
BEGIN
    UPDATE inventory
    SET quantity = quantity - qty,
        last_updated = NOW()
    WHERE product_id = pid
    AND warehouse_id = wid;
END $$

DELIMITER ;

CALL reduce_stock(1, 1, 5);

DELIMITER $$

CREATE PROCEDURE low_stock()
BEGIN
    SELECT 
        p.name,
        i.quantity
    FROM inventory i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.quantity < 10;
END $$

DELIMITER ;

CALL low_stock();