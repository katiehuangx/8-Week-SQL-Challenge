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

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT DISTINCT(s.product_id), COUNT(s.product_id) AS no_of_orders, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY no_of_orders DESC;

--5. Which item was the most popular for each customer?
SELECT DISTINCT(s.customer_id), s.product_id, m.product_name, COUNT(m.product_id) AS no_of_orders
FROM dbo.menu AS m
JOIN dbo.sales AS s
	ON m.product_id = s.product_id
GROUP BY s.customer_id, s.product_id, m.product_name
ORDER BY s.customer_id, no_of_orders DESC;

--6. Which item was purchased first by the customer after they became a member?
WITH summary (customer_id, join_date, order_date, product_id, rank) AS 
	(
    SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id
		ORDER BY s.order_date) 
		AS rank
    FROM sales AS s
	JOIN members AS m
		ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date
	)

SELECT s.customer_id, s.order_date, s.product_id, m2.product_name 
FROM summary AS s
JOIN menu AS m2
	ON s.product_id = m2.product_id
WHERE rank = 1;

--7. Which item was purchased just before the customer became a member?
WITH summary (customer_id, join_date, order_date, product_id, rank) AS 
	(
    SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id
		ORDER BY s.order_date DESC) 
		AS rank
    FROM sales AS s
	JOIN members AS m
		ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date
	)

SELECT s.customer_id, s.order_date, s.product_id, m2.product_name 
FROM summary AS s
JOIN menu AS m2
	ON s.product_id = m2.product_id
WHERE rank = 1;

--8. What is the total items and amount spent for each member before they became a member?
WITH summary (customer_id, join_date, order_date, product_id, price) AS 
	(
    SELECT s.customer_id, m.join_date, s.order_date, s.product_id, mm.price
      --  ROW_NUMBER() OVER(PARTITION BY s.customer_id
		--ORDER BY s.order_date DESC) 
		--AS rank
    FROM sales AS s
	JOIN members AS m
		ON s.customer_id = m.customer_id
	JOIN menu AS mm
		ON s.product_id = mm.product_id
	WHERE s.order_date < m.join_date
	)

SELECT s.customer_id, SUM(m.price) AS total_spent_before_member
FROM summary AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH price_points AS
(
SELECT *, 
CASE
	WHEN product_id = 1 THEN price * 20
	ELSE price * 10
END AS points
FROM menu
)

SELECT DISTINCT(s.customer_id), SUM(p.price) AS total_spent, SUM(p.points) AS total_points
FROM price_points AS p
JOIN sales AS s
	ON p.product_id = s.product_id
GROUP BY s.customer_id, p.price, p.points

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 1. Find validity date of each customer and get last date of January
-- 2. Use CASE WHEN to allocate points by date and product id
-- 3. SUM price and points

WITH dates AS (
SELECT *, DATEADD(day, 6, join_date) AS valid_date, EOMONTH('2021-01-31') AS last_date
FROM members AS m)


SELECT d.customer_id, d.join_date, d.valid_date, d.last_date, s.order_date, s.product_id, m.price,
CASE
	WHEN s.order_date < d.join_date THEN price * 0
	WHEN s.order_date <= d.join_date AND s.order_date <= d.valid_date THEN price * 20
	WHEN s.order_date BETWEEN d.valid_date AND d.last_date AND s.product_id = 1 THEN price * 20
	ELSE price * 10
	END as points
FROM dates AS d
JOIN sales AS s
	ON d.customer_id = s.customer_id
JOIN menu AS m
	ON s.product_id = m.product_id












