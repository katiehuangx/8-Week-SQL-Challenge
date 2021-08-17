# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
SELECT COUNT(*) AS pizza_order_count
FROM #customer_orders;
````

**Answer:**

![1*Ma9L4y6O_zhln6Wy7CdWMQ](https://user-images.githubusercontent.com/81607668/129473598-d6d55ab2-59c7-4040-97db-d1b0c1c5b294.png)

- Total of 14 pizzas were ordered.

### 2. How many unique customer orders were made?

````sql
SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM #customer_orders;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129737993-710198bd-433d-469f-b5de-14e4022a3a45.png)

- There are 10 unique customer orders.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT 
  runner_id, 
  COUNT(order_id) AS successful_orders
FROM #runner_orders
WHERE distance != 0
GROUP BY runner_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738112-6eada46a-8c32-495a-8e26-793b2fec89ef.png)

- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.

### 4. How many of each type of pizza was delivered?

````sql
SELECT 
  p.pizza_name, 
  COUNT(c.pizza_id) AS delivered_pizza_count
FROM #customer_orders AS c
JOIN #runner_orders AS r
  ON c.order_id = r.order_id
JOIN pizza_names AS p
  ON c.pizza_id = p.pizza_id
WHERE r.distance != 0
GROUP BY p.pizza_name;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738140-c9c002ff-5aed-48ab-bdfa-cadbd98973a9.png)

- There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.

### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
SELECT 
  c.customer_id, 
  p.pizza_name, 
  COUNT(p.pizza_name) AS order_count
FROM #customer_orders AS c
JOIN pizza_names AS p
  ON c.pizza_id= p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738167-269df165-1c9a-446a-b757-c7fc9a9021ed.png)

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 2 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 1 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
WITH pizza_count_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.pizza_id) AS pizza_per_order
  FROM #customer_orders AS c
  JOIN #runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id
)

SELECT 
  MAX(pizza_per_order) AS pizza_count
FROM pizza_count_cte;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738201-f676edd4-2530-4663-9ed8-6e6ec4d9cc68.png)

- Maximum number of pizza delivered in a single order is 3 pizzas.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
FROM #customer_orders AS c
JOIN #runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738236-2c4383cb-9d42-458c-b9be-9963c336ee58.png)

- Customer 101 and 102 likes his/her pizzas per the original recipe.
- Customer 103, 104 and 105 have their own preference for pizza topping and requested at least 1 change (extra or exclusion topping) on their pizza.

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT  
  SUM(
    CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
    ELSE 0
    END) AS pizza_count_w_exclusions_extras
FROM #customer_orders AS c
JOIN #runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance >= 1 
  AND exclusions <> ' ' 
  AND extras <> ' ';
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738278-dd3e7056-309d-42fc-a5e3-00f7b5d4609e.png)

- Only 1 pizza delivered that had both extra and exclusion topping. That’s one fussy customer!

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM #customer_orders
GROUP BY DATEPART(HOUR, [order_time]);
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738302-573430e9-1785-4c71-adc1-464ffa94de8a.png)

- Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm) and 21 (9:00 pm).
- Lowest volume of pizza ordered is at 11 (11:00 am), 19 (7:00 pm) and 23 (11:00 pm).

### 10. What was the volume of orders for each day of the week?

````sql
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129738331-233744f6-3b57-4f4f-9a51-f7a699a9eb2e.png)

- There are 5 pizzas ordered on Friday and Monday.
- There are 3 pizzas ordered on Saturday.
- There is 1 pizza ordered on Sunday.

***Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.md) for solution for B. Runner and Customer Experience!***

