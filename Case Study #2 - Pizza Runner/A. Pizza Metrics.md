# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics _[MS SQL Server]_

### 1. How many pizzas were ordered?

SELECT COUNT(*) AS pizza_order_count
FROM #customer_orders;

**Answer:**

![1*Ma9L4y6O_zhln6Wy7CdWMQ](https://user-images.githubusercontent.com/81607668/129473598-d6d55ab2-59c7-4040-97db-d1b0c1c5b294.png)

- Total of 14 pizzas were ordered.

### 2. How many unique customer orders were made?

SELECT 
  COUNT(DISTINCT order_id) AS unique_order_count
FROM #customer_orders;

**Answer:**


- There are 10 unique customer orders.

### 3. How many successful orders were delivered by each runner?

SELECT 
  runner_id, 
  COUNT(order_id) AS successful_orders
FROM #runner_orders
WHERE distance != 0
GROUP BY runner_id;

**Answer:**
- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.


6. How many of each type of pizza was delivered?
7. How many Vegetarian and Meatlovers were ordered by each customer?
8. What was the maximum number of pizzas delivered in a single order?
9. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
10. How many pizzas were delivered that had both exclusions and extras?
11. What was the total volume of pizzas ordered for each hour of the day?
12. What was the volume of orders for each day of the week?
