# Case Study #1: Danny's Diner - Solution

View the complete syntax [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/week1dannysdiner.sql).

***
### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id, SUM(price) AS total_spent
FROM dbo.sales AS s
JOIN dbo.menu AS m
   ON s.product_id = m.product_id
GROUP BY s.customer_id;
````

#### Steps:
- Use **SUM** and **GROUP BY** to find out total spent by each customer.
- Use **JOIN** to merge ***sales*** and ***menu*** tables as ***customer_id*** and ***price*** are from both tables.


#### Answer:
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_no
FROM dbo.sales
GROUP BY customer_id;
````

#### Steps:
- Use **DISTINCT** and wrap with **COUNT** to find out the number of days each customer visited the restaurant.
- If we do not use **DISTINCT** on ***order_date***, the number of days may be repeated. 
- For example, if Customer A visited the restaurant twice on '2021–01–07', then number of days may have counted as 2 days instead of 1 day.

#### Answer:
| customer_id | visit_no |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH summary AS
(
   SELECT customer_id, order_date, product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id
    ORDER BY s.order_date) AS rank
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
)

SELECT customer_id, order_date, product_name, rank
FROM summary
WHERE rank = 1
GROUP BY customer_id, order_date, product_name, rank;
````

#### Steps:
- Create a temp table **CTE**. In the ***summary*** **CTE**, use **Windows function** with **DENSE_RANK** to create a new column ***rank*** based on ***order_date***.
- Instead of **ROW_NUMBER** or **RANK**, use **DENSE_RANK** as ***order_date*** is not time-stamped hence, there is no sequence as to which item is ordered first if 2 or more items are ordered on the same day.
- Subsequently, **GROUP BY** all columns to show rank = 1 only.

#### Answer:
| customer_id | order_date | product_name | rank |
| ----------- | ----------- |------------ |----- |
| A           | 2021-01-01 | curry        | 1    |
| A           | 2021-01-01 | sushi        | 1    |
| B           | 2021-01-01 | curry        | 1    |
| C           | 2021-01-01 | ramen        | 1    |

- Customer A's first orders are curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT s.product_id, COUNT(s.product_id) AS no_of_orders, product_name
FROM dbo.sales AS s
JOIN dbo.menu AS m
   ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY no_of_orders DESC;
````

#### Steps:
- Create a temp table **CTE**. In the ***summary*** **CTE**, use **Windows function** with **DENSE_RANK** to create a new column ***rank*** based on ***order_date***.
- Instead of **ROW_NUMBER** or **RANK**, use **DENSE_RANK** as ***order_date*** is not time-stamped hence, there is no sequence as to which item is ordered first if 2 or more items are ordered on the same day.
- Subsequently, **GROUP BY** all columns to show rank = 1 only.

#### Answer:
| product_id | no_of_orders | product_name | 
| ----------- | ----------- |------------ |
| 3           | 8 | ramen       |
| 2           | 4 | curry      |
| 1           | 3 | sushi       |

- Most purchased item on the menu is ramen which is 8 times. Yummy!

***

### 5. Which item was the most popular for each customer?

````sql
WITH summary AS
(
  SELECT s.customer_id, s.product_id, m.product_name, COUNT(m.product_id) AS no_of_orders,
   DENSE_RANK() OVER(PARTITION BY s.customer_id
   ORDER BY COUNT(m.product_id) DESC) AS rank
FROM dbo.menu AS m
JOIN dbo.sales AS s
   ON m.product_id = s.product_id
GROUP BY s.customer_id, s.product_id, m.product_name
)

SELECT customer_id, product_id, product_name, rank
FROM summary 
WHERE rank = 1;
````

#### Steps:
- Create a CTE to rank the number of orders for each product by DESC order for each customer.
- Generate results where rank of product = 1 only as the most popular product for each customer.

#### Answer:
| customer_id | product_id | product_name | rank |
| ----------- | ---------- |------------  |----- |
| A           | 3          | ramen        |  1   |
| B           | 1          | sushi        |  1   |
| B           | 2          | curry        |  1   |
| B           | 3          | ramen        |  1   |
| C           | 3          | ramen        |  1   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me!

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH summary (customer_id, join_date, order_date, product_id, rank) AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
   DENSE_RANK() OVER(PARTITION BY s.customer_id
   ORDER BY s.order_date) AS rank
   FROM sales AS s
   JOIN members AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date >= m.join_date
)

SELECT s.customer_id, s.join_date, s.order_date, s.product_id, m2.product_name 
FROM summary AS s
JOIN menu AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
````

#### Steps:
- Create **CTE** and filter ***order_date*** to be on or after ***join_date***and rank ***product_id*** by ***order_date***.
- filter the table by rank = 1 to show 1st item purchased by each customer.

#### Answer:
| customer_id | join_date | order_date  | product_id | product_name |
| ----------- | ---------- |----------  |----------- |--------------|
| A           | 2021-01-07 | 2021-01-07 |  2         | curry        |
| B           | 2021-01-09 | 2021-01-11 |  1         | sushi        |

- Customer A's first order as member is curry.
- Customer B's first order as member is sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH summary (customer_id, join_date, order_date, product_id, rank) AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
   DENSE_RANK() OVER(PARTITION BY s.customer_id
   ORDER BY s.order_date DESC) AS rank
   FROM sales AS s
   JOIN members AS m
      ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)

SELECT s.customer_id, s.join_date, s.order_date, s.product_id, m2.product_name 
FROM summary AS s
JOIN menu AS m2
   ON s.product_id = m2.product_id
WHERE rank = 1;
````

#### Steps:
- Create a **CTE** to create new column ***rank*** by using **Windows function** and partitioning ***customer_id*** by descending ***order_date*** to find out the last ***order_date*** before customer becomes a member.
- Filter ***order_date*** before ***join_date***.

#### Answer:
| customer_id | join_date | order_date  | product_id | product_name |
| ----------- | ---------- |----------  |----------- |--------------|
| A           | 2021-01-07 | 2021-01-01 |  1         | sushi        |
| A           | 2021-01-07 | 2021-01-01 |  2         | curry        |
| B           | 2021-01-09 | 2021-01-04 |  1         | sushi        |

- Customer A’s last order before becoming a member is sushi and curry.
- Whereas for Customer B, it's sushi. That must have been a real good sushi!

***








