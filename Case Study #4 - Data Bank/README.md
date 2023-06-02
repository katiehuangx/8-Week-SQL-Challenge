## Case Study #4: Data Bank

<img src="https://user-images.githubusercontent.com/81607668/130343294-a8dcceb7-b6c3-4006-8ad2-fab2f6905258.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-4/). 

***

## Business Task
Danny launched a new initiative, Data Bank which runs **banking activities** and also acts as the world’s most secure distributed **data storage platform**!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. 

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram

<img width="631" alt="image" src="https://user-images.githubusercontent.com/81607668/130343339-8c9ff915-c88c-4942-9175-9999da78542c.png">

**Table 1: `regions`**

This regions table contains the `region_id` and their respective `region_name` values.

<img width="176" alt="image" src="https://user-images.githubusercontent.com/81607668/130551759-28cb434f-5cae-4832-a35f-0e2ce14c8811.png">

**Table 2: `customer_nodes`**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

<img width="412" alt="image" src="https://user-images.githubusercontent.com/81607668/130551806-90a22446-4133-45b5-927c-b5dd918f1fa5.png">

**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

<img width="343" alt="image" src="https://user-images.githubusercontent.com/81607668/130551879-2d6dfc1f-bb74-4ef0-aed6-42c831281760.png">

***

## Question and Solution

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/2GtQz4wZtuNNu7zXH5HtV4/3). It would be great to work together on the questions!

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/katiehuangx/).

## 🏦 A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

````sql
SELECT COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;
````

**Answer:**

<img width="97" alt="image" src="https://user-images.githubusercontent.com/81607668/130343558-c73b2bd4-d799-4506-9d9f-2fe0125f9c8f.png">

- There are 5 unique nodes on the Data Bank system.

***

**2. What is the number of nodes per region?**

````sql
SELECT
  regions.region_name, 
  COUNT(DISTINCT customers.node_id) AS node_count
FROM data_bank.regions
JOIN data_bank.customer_nodes AS customers
  ON regions.region_id = customers.region_id
GROUP BY regions.region_name;
````

**Answer:**

|region_name|node_count|
|:----|:----|
|Africa|5|
|America|5|
|Asia|5|
|Australia|5|
|Europe|5|

***

**3. How many customers are allocated to each region?**

````sql
SELECT 
  region_id, 
  COUNT(customer_id) AS customer_count
FROM data_bank.customer_nodes
GROUP BY region_id
ORDER BY region_id;
````

**Answer:**

|region_id|customer_count|
|:----|:----|
|1|770|
|2|735|
|3|714|
|4|665|
|5|616|

***

**5. How many days on average are customers reallocated to a different node?**

````sql
WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,
    end_date - start_date AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
) 
, total_node_days AS (
  SELECT 
    customer_id,
    node_id,
    SUM(days_in_node) AS total_days_in_node
  FROM node_days
  GROUP BY customer_id, node_id
)

SELECT ROUND(AVG(total_days_in_node)) AS avg_node_reallocation_days
FROM total_node_days;
````

**Answer:**

|avg_node_reallocation_days|
|:----|
|24|

- On average, customers are reallocated to a different node every 24 days.

***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**



***

## 🏦 B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

````sql
SELECT
  txn_type, 
  COUNT(customer_id) AS transaction_count, 
  SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;
````

**Answer:**

|txn_type|transaction_count|total_amount|
|:----|:----|:----|
|purchase|1617|806537|
|deposit|2671|1359168|
|withdrawal|1580|793003|

***

**2. What is the average total historical deposit counts and amounts for all customers?**

````sql
WITH deposits AS (
  SELECT 
    customer_id, 
    COUNT(customer_id) AS txn_count, 
    AVG(txn_amount) AS avg_amount
  FROM data_bank.customer_transactions
  WHERE txn_type = 'deposit'
  GROUP BY customer_id
)

SELECT 
  ROUND(AVG(txn_count)) AS avg_deposit_count, 
  ROUND(AVG(avg_amount)) AS avg_deposit_amt
FROM deposits;
````
**Answer:**

|avg_deposit_count|avg_deposit_amt|
|:----|:----|
|5|509|

- The average historical deposit count is 5 and the average historical deposit amount is $ 509.

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

First, create a CTE called `monthly_transactions` to determine the count of deposit, purchase and withdrawal for each customer categorised by month using `CASE` statement and `SUM()`. 

In the main query, select the `mth` column and count the number of unique customers where:
- `deposit_count` is greater than 1, indicating more than one deposit (`deposit_count > 1`).
- Either `purchase_count` is greater than or equal to 1 (`purchase_count >= 1`) OR `withdrawal_count` is greater than or equal to 1 (`withdrawal_count >= 1`).

````sql
WITH monthly_transactions AS (
  SELECT 
    customer_id, 
    DATE_PART('month', txn_date) AS mth,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM data_bank.customer_transactions
  GROUP BY customer_id, DATE_PART('month', txn_date)
)

SELECT
  mth,
  COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count > 1 
  AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY mth
ORDER BY mth;
````

**Answer:**

|month|customer_count|
|:----|:----|
|1|170|
|2|277|
|3|292|
|4|103|

***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**

This is a particularly difficult question - with probably the most `CTE`s I have in a single query - there are 5 `CTE`s! 

I'm sure there's a shorter way to write the syntax, but I reckoned this is the best way as it allows me to build on my results. Take your time and run the table `CTE` by `CTE` to see the full picture and gain a complete understanding of the solution. 

````sql
-- CTE 1 - To identify transaction amount as an inflow (+) or outflow (-)
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    txn_type, 
    txn_amount,
    SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_date, txn_type, txn_amount
),

-- CTE 2 - Use GENERATE_SERIES() to generate as a series of last day of the month for each customer.
last_day AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
),

-- CTE 3 - Create closing balance for each month using Window function SUM() to add changes during the month
solution_t1 AS (
  SELECT 
    ld.customer_id, 
    ld.ending_month,
    COALESCE(mb.transaction_balance, 0) AS monthly_change,
    SUM(mb.transaction_balance) OVER 
      (PARTITION BY ld.customer_id ORDER BY ld.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
  FROM last_day ld
  LEFT JOIN monthly_balances mb
    ON ld.ending_month = mb.closing_month
      AND ld.customer_id = mb.customer_id
),

-- CTE 4 - Use Window function ROW_NUMBER() to rank transactions within each month
solution_t2 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
  FROM solution_t1
),

-- CTE 5 - Use Window function LEAD() to query value in next row and retrieve NULL for last row
solution_t3 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance, 
    record_no,
    LEAD(record_no) OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
  FROM solution_t2
)

SELECT 
  customer_id, ending_month, 
  monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;
````

**Answer:**

<img width="634" alt="image" src="https://user-images.githubusercontent.com/81607668/130431426-1882daec-8c93-4818-b041-943883aa21cb.png">

***

**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**

For this question, I created 2 temp tables
  - Create `temp table #1` from Q4's solution. All you have to do is copy + paste the Q4 syntax and create a temp table.
  - Then, using temp table #1, create `temp table #2` by running a `ROW_NUMBER` function to rank records for individual customer.

````sql
-- Create temp table #1 using solution from Question 4
CREATE TEMP TABLE q5 AS (
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    txn_type, 
    txn_amount,
    SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_date, txn_type, txn_amount
),
last_day AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
),
solution_t1 AS (
  SELECT 
    ld.customer_id, ld.ending_month,
    COALESCE(mb.transaction_balance, 0) AS monthly_change,
    SUM(mb.transaction_balance) OVER 
      (PARTITION BY ld.customer_id ORDER BY ld.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
  FROM last_day ld
  LEFT JOIN monthly_balances mb
    ON ld.ending_month = mb.closing_month
      AND ld.customer_id = mb.customer_id
),
solution_t2 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
  FROM solution_t1
),
solution_t3 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance, 
    record_no,
    LEAD(record_no) OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
FROM solution_t2
)

SELECT 
  customer_id, ending_month, 
  monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL);

-- Create temp table #2
CREATE TEMP TABLE q5_sequence AS (
SELECT 
  customer_id, ending_month, closing_balance,
  ROW_NUMBER() OVER 
    (PARTITION BY customer_id ORDER BY ending_month) AS sequence
FROM q5)
````

**- What percentage of customers have a negative first month balance?**

````sql
SELECT *
FROM q5_sequence
WHERE sequence = 1 AND
  closing_balance::TEXT LIKE '-%';
````

I run the syntax above to get output below where it confirmed that I am getting only records with negative first month balances.

<img width="604" alt="image" src="https://user-images.githubusercontent.com/81607668/130543803-5755f638-9cdd-4454-9c91-1e20d275365c.png">

````sql
SELECT 
  ROUND(100 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS negative_first_month_percentage
FROM q5_sequence
WHERE sequence = 1 AND
-- Take note that the condition is asking for closing balance with a negative integer.
  closing_balance::TEXT LIKE '-%';
````

**Answer:**

<img width="263" alt="image" src="https://user-images.githubusercontent.com/81607668/130543862-6c38d5a3-22a3-4333-bac7-844a1c608ae7.png">

- 31.4% of customers have a negative first month balance.

**- What percentage of customers have a positive first month balance?**

````sql
SELECT 
  ROUND(100 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS positive_first_month_percentage
FROM q5_sequence
WHERE sequence = 1 AND
-- Take note that the condition below is asking for closing balance that is NOT with a negative integer.
  closing_balance::TEXT NOT LIKE '-%';
````

**Answer:**

<img width="261" alt="image" src="https://user-images.githubusercontent.com/81607668/130544192-1f1b663b-9a31-43bd-9218-d1e4827a9961.png">

- 68.6% of customers have a positive first month balance.

**- What percentage of customers increase their opening month’s positive closing balance by more than 5% in the following month?**

- Use `LEAD()` function to query the following month's balances and, then filter to select records with 1st month and 2nd month balances only. 
- Also, filter for `next_balance` with positive balances only. 
- We must exclude negative balances from the results because a higher negative balance in the following month does not represent an increase in balances and could mispresent our answer as the percentage of variance would still result in a positive percentage. 

````sql
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER 
      (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
variance_cte AS (
  SELECT 
    customer_id, ending_month, 
    closing_balance, next_balance, 
    ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) AS variance
  FROM next_balance_cte  
  WHERE ending_month = '2020-01-31'
    AND next_balance::TEXT NOT LIKE '-%'
  GROUP BY customer_id, ending_month, closing_balance, next_balance
  HAVING ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) > 5.0)
````

<img width="701" alt="image" src="https://user-images.githubusercontent.com/81607668/130546284-c2632ab5-f732-4382-861a-2a2a5b405e8d.png">

````sql
-- Run this syntax with the above syntax as well
SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS variance_more_5_percentage
FROM variance_cte; 
````

**Answer:**

<img width="237" alt="image" src="https://user-images.githubusercontent.com/81607668/130546364-96b2e542-9053-41e2-a9c8-c0d031660f59.png">

- 2.8% of customers increase their opening month's positive closing balance by more than 5% in the following month.

**- What percentage of customers reduce their opening month’s positive closing balance by more than 5% in the following month?**

````sql
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER 
      (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
variance_cte AS (
  SELECT 
    customer_id, ending_month, 
    closing_balance, next_balance, 
    ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) AS variance
  FROM next_balance_cte  
  WHERE ending_month = '2020-01-31'
    AND next_balance::TEXT LIKE '-%'
  GROUP BY customer_id, ending_month, closing_balance, next_balance
  HAVING ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) > 5.0)
````

<img width="662" alt="image" src="https://user-images.githubusercontent.com/81607668/130546489-00e52b31-d223-4e02-8f5f-602cb1b718b4.png">

````sql
-- Run this syntax with the above syntax as well
SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS neg_variance_more_5_percentage
FROM variance_cte;
````

**Answer:**

<img width="274" alt="image" src="https://user-images.githubusercontent.com/81607668/130546582-e1875e51-e598-43c1-b826-40696a0ec107.png">

- 4.2% of customers reduce their opening month's positive closing balance by more than 5% in the following month.

**- What percentage of customers move from a positive balance in the first month to a negative balance in the second month?**

````sql
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER 
      (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
positive_negative AS (
  SELECT *
  FROM next_balance_cte
  WHERE ending_month = '2020-01-31'
    AND closing_balance::TEXT NOT LIKE '-%'
    AND next_balance::TEXT LIKE '-%')
````

<img width="600" alt="image" src="https://user-images.githubusercontent.com/81607668/130547016-1344dd2f-b29b-4d49-9773-38b440039680.png">

````sql
-- Run this syntax with the above syntax as well
SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS positive_1st_negative_2nd_percentage
FROM positive_negative;
````

**Answer:**

<img width="312" alt="image" src="https://user-images.githubusercontent.com/81607668/130547175-5d2a6b78-182a-4d65-ab23-5a152d57bac3.png">

- 22.8% of customers move from a positive balance (refer: closing_balance) in the first month to a negative balance (refer: next_balance) in the second month.

  
***

Do give me a 🌟 if you like what you're reading. Thank you! 🙆🏻‍♀️
