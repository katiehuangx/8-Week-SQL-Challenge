# 🍕 Case Study #2 Pizza Runner

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129739658-a233932a-9f79-4280-a618-8bab6d3bd1f2.png)

- On Week 1 of Jan 2021, 2 new runners signed up.
- On Week 2 and 3 of Jan 2021, 1 new runner signed up.

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

The question asks for the average pickup time **for each runner**, so the result is grouped by `runner_id`. An order with several pizzas has one pickup, so the CTE keeps one row per order (otherwise a runner's average would be skewed towards orders with more pizzas).

````sql
WITH time_taken_cte AS
(
  SELECT 
    c.order_id, 
    r.runner_id,
    DATEDIFF(SECOND, c.order_time, r.pickup_time) / 60.0 AS pickup_minutes
  FROM #customer_orders AS c
  JOIN #runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id, r.runner_id, c.order_time, r.pickup_time
)

SELECT 
  runner_id,
  ROUND(AVG(pickup_minutes), 2) AS avg_pickup_minutes
FROM time_taken_cte
GROUP BY runner_id
ORDER BY runner_id;
````

**Answer:**

| runner_id | avg_pickup_minutes |
|:----|:----|
| 1 | 14.33 |
| 2 | 20.01 |
| 3 | 10.47 |

- Runner 1 takes about 14.3 minutes on average to arrive at Pizza Runner HQ to pick up an order, runner 2 about 20 minutes and runner 3 about 10.5 minutes.
- Across all delivered orders, the overall average is about 16 minutes.

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
  FROM #customer_orders AS c
  JOIN #runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  pizza_order, 
  AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129739816-05e3ba03-d3fe-4206-8557-869930a897d1.png)

- On average, a single pizza order takes 12 minutes to prepare.
- An order with 3 pizzas takes 30 minutes at an average of 10 minutes per pizza.
- It takes 16 minutes to prepare an order with 2 pizzas which is 8 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate.

### 4. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
SELECT 
  c.customer_id, 
  AVG(r.distance) AS avg_distance
FROM #customer_orders AS c
JOIN #runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129739847-5e338f4f-b42c-4531-9685-e2e822063183.png)

_(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)_

- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.

### 5. What was the difference between the longest and shortest delivery times for all orders?

_Edit 08/10/21: Thanks to my reader, Ankush Taneja on Medium who caught my mistake. I've amended to the correct solution. Also, I was doing this case study using SQL Server few months ago, but I'm using PostgreSQL on SQLpad now so there could be a slight difference to the syntax._

Firstly, I'm going to filter results with non-null duration first just to have a feel. You can skip this step and go straight to the answer.

````sql
SELECT 
  order_id, duration
FROM #runner_orders
WHERE duration not like ' ';
````

<img width="269" alt="image" src="https://user-images.githubusercontent.com/81607668/136523519-98efb655-d144-496b-a946-42c1c5415403.png">

```sql
SELECT MAX(duration::NUMERIC) - MIN(duration::NUMERIC) AS delivery_time_difference
FROM runner_orders2
where duration not like ' ';
```

**Answer:**

<img width="196" alt="image" src="https://user-images.githubusercontent.com/81607668/136523820-c4504a25-83f8-4236-b08e-37bf542caad0.png">

- The difference between longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance, (r.duration / 60) AS duration_hr , 
  ROUND((r.distance/r.duration * 60), 2) AS avg_speed
FROM #runner_orders AS r
JOIN #customer_orders AS c
  ON r.order_id = c.order_id
WHERE distance != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129739931-54127037-0879-43bf-b53f-e4a1a6ebffeb.png)

_(Average speed = Distance in km / Duration in hour)_
- Runner 1’s average speed runs from 37.5km/h to 60km/h.
- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. Danny should investigate Runner 2 as the average speed has a 300% fluctuation rate!
- Runner 3’s average speed is 40km/h

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM #runner_orders
GROUP BY runner_id;
````

**Answer:**

![image](https://user-images.githubusercontent.com/81607668/129740007-021d78fb-ec32-46c0-98f2-9e8f1891baed.png)

- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery

_(It’s not right to attribute successful delivery to runners as order cancellations are out of the runner’s control.)_

***
