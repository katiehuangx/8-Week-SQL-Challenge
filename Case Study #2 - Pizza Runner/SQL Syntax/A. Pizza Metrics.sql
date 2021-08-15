--A. Pizza Metrics
--1. How many pizzas were ordered?

SELECT COUNT(DISTINCT(order_id)) AS no_of_pizzas_ordered
FROM #customer_orders;

--2. How many unique customer orders were made?
SELECT customer_id, COUNT(order_id) AS unique_orders
FROM #customer_orders
GROUP BY customer_id

--3. How many successful orders were delivered by each runner?
SELECT COUNT(order_id) AS successful_orders
FROM #runner_orders
WHERE distance != 0

--4. How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(pizza_id) AS no_of_delivered_pizza
FROM #customer_orders AS c
JOIN #runner_orders AS r
	ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY pizza_id

--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS no_of_orders
FROM #customer_orders AS c
JOIN pizza_names AS p
	ON c.pizza_id= p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id

--6. What was the maximum number of pizzas delivered in a single order?
WITH tempo AS
(
SELECT c.order_id, COUNT(c.pizza_id) AS no_of_pizzas_per_order
FROM #customer_orders AS c
JOIN #runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.order_id
)

SELECT MAX(no_of_pizzas_per_order) AS max_no_of_pizzas_in_single_order
FROM tempo

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
	SUM(CASE 
		WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
		ELSE 0
		END) AS with_changes,
	SUM(CASE 
		WHEN c.exclusions IS NULL OR c.extras IS NULL THEN 1 
		ELSE 0
		END) AS no_changes
FROM #customer_orders AS c
JOIN #runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id

--8. How many pizzas were delivered that had both exclusions and extras?
SET ANSI_NULLS OFF

SELECT c.order_id, 
	SUM(CASE
		WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
		ELSE 0
		END) AS no_of_pizza_delivered_w_exclusions_extras
FROM #customer_orders AS c
JOIN #runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.distance >= 1 
	AND exclusions <> ' ' 
	AND extras <> ' ' 
GROUP BY c.order_id, c.pizza_id

--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR, [order_time]) AS hour_of_the_day, COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY DATEPART(HOUR, [order_time])

--10. What was the volume of orders for each day of the week?
SELECT DATEPART(DAY, [order_time]) AS day_of_week, COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY DATEPART(DAY, [order_time])
