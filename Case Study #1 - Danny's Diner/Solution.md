# Case Study #1: Danny's Diner - Solution

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


