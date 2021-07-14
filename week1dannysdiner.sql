CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;

------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?
SELECT DISTINCT (customer_id), SUM(price) AS total_spent
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id;

--2. How many days has each customer visited the restaurant?
SELECT DISTINCT (customer_id), COUNT(order_date) AS visit_no
FROM dbo.sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
SELECT customer_id, order_date, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
WHERE order_date = '2021-01-01'
GROUP BY s.customer_id, order_date, product_name
ORDER BY order_date ASC
--OFFSET 0 ROWS
--FETCH NEXT 3 ROWS ONLY;

SELECT DISTINCT customer_id
FROM dbo.sales AS s


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT DISTINCT(s.product_id), COUNT(s.product_id) AS no_of_orders, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY no_of_orders DESC;

--5. Which item was the most popular for each customer?
SELECT DISTINCT(s.product_id), COUNT(s.product_id) AS no_of_orders, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY no_of_orders DESC;

--6. Which item was purchased first by the customer after they became a member?
SELECT DISTINCT(m.customer_id) AS member_id, m.join_date, order_date
FROM dbo.members AS m
JOIN dbo.sales AS s
ON m.customer_id = s.customer_id
WHERE order_date >= join_date
GROUP BY m.customer_id, join_date, order_date
ORDER BY join_date






