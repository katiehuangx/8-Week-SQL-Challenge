------------------------
-----DATA CLEANING------
------------------------

--SQL functions: Create temp table, CASE WHEN, TRIM, ALTER TABLE, ALTER data type, filtering using '%'

--TABLE: customer_orders

SELECT order_id, customer_id, pizza_id, 
CASE
	WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	ELSE extras
	END AS extras,
	order_time
INTO #customer_orders
FROM customer_orders

--TABLE: runner_orders

exec sp_help runner_orders

--pickup_time - remove nulls and replace with ' '
--distance - remove km and nulls
--duration - remove minutes and nulls
--cancellation - remove NULL and null and replace with ' ' 

SELECT order_id, runner_id,  
CASE
	WHEN pickup_time LIKE 'null' THEN ' '
	ELSE pickup_time
	END AS pickup_time,
CASE
	WHEN distance LIKE 'null' THEN ' '
	WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	ELSE distance
	END AS distance,
CASE
	WHEN duration LIKE 'null' THEN ' '
	WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	ELSE duration
	END AS duration,
CASE
	WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	ELSE cancellation
	END AS cancellation
INTO #runner_orders
FROM runner_orders

ALTER TABLE #runner_orders
ALTER COLUMN pickup_time DATETIME

ALTER TABLE #runner_orders
ALTER COLUMN distance FLOAT

ALTER TABLE #runner_orders
ALTER COLUMN duration INT
