# 💵 Case Study #4 - Data Bank

## 🏦 Solution - B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

````sql
SELECT 
  txn_type, 
  COUNT(*), 
  SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type
````

**Answer:**

<img width="479" alt="image" src="https://user-images.githubusercontent.com/81607668/130349158-acb36028-df02-472a-bd34-15856f93b2b8.png">

***

**2. What is the average total historical deposit counts and amounts for all customers?**

````sql
--Find count of each transaction type and average transaction amount for each customer
WITH deposits AS (
  SELECT 
    customer_id, 
    txn_type, 
    COUNT(*) AS txn_count, 
    AVG(txn_amount) AS avg_amount
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_type)

SELECT 
  ROUND(AVG(txn_count),0) AS avg_deposit, 
  ROUND(AVG(avg_amount),2) AS avg_amount
FROM deposits
WHERE txn_type = 'deposit';
````
**Answer:**

<img width="325" alt="image" src="https://user-images.githubusercontent.com/81607668/130349626-97309a3e-790b-47a9-b9bf-32e7f6f078e7.png">

- The average historical deposit count is 5 and average historical deposit amounts are 508.61.

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

- First, create a CTE with output counting the number of deposits, purchases and withdrawals for each customer grouped by month.
- Then, filter the results to deposits being 2 or more transactions and 1 or more purchase or withdrawal in a single month for each transaction.

````sql
WITH monthly_transactions AS (
SELECT 
  customer_id, 
  DATE_PART('month', txn_date) AS month,
  SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
  SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
  SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM data_bank.customer_transactions
GROUP BY customer_id, month
ORDER BY customer_id, month)

SELECT
  month,
  COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count >= 2 AND 
  (purchase_count > 1 OR withdrawal_count > 1)
GROUP BY month
ORDER BY month;
````

**Answer:**

<img width="305" alt="image" src="https://user-images.githubusercontent.com/81607668/130412903-8b6686b4-c591-4154-be30-fa34e9e93e53.png">

***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**

This is a particularly difficult question - with probably the most CTEs I have in a single query! 5 CTEs! 

I'm quite sure there's a shorter way to write the syntax, but I decided to create separate tables and combine them to understand them better.

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

-- CTE 2 - To generate txn_date as a series of last day of month for each customer
last_day AS (
SELECT
  DISTINCT customer_id,
  ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
FROM data_bank.customer_transactions
),

-- CTE 3 - Create closing balance for each month using Window function SUM() to add monthly_change
solution_t1 AS (
SELECT 
  ld.customer_id, 
  ld.ending_month,
  COALESCE(mb.transaction_balance, 0) AS monthly_change,
  SUM(mb.transaction_balance) OVER 
    (PARTITION BY ld.customer_id ORDER BY ld.ending_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS closing_balance
FROM last_day ld
LEFT JOIN monthly_balances mb
  ON ld.ending_month = mb.closing_month
  AND ld.customer_id = mb.customer_id
),

-- CTE 4 - Use Window function ROW_NUMBER() to rank the transaction within each month
solution_t2 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance,
  ROW_NUMBER() OVER (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
FROM solution_t1
),

-- CTE 5 - Use Window function LEAD() to query the value in next row and retrieve NULL for last row
solution_t3 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance, record_no,
  LEAD(record_no) OVER (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
FROM solution_t2)

SELECT customer_id, ending_month, monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;
````

**Answer:**

<img width="634" alt="image" src="https://user-images.githubusercontent.com/81607668/130431426-1882daec-8c93-4818-b041-943883aa21cb.png">

***

**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**

````sql
-- Create a temp table using solution from Question 4
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
SELECT ld.customer_id, ld.ending_month,
  COALESCE(mb.transaction_balance, 0) AS monthly_change,
  SUM(mb.transaction_balance) OVER 
    (PARTITION BY ld.customer_id ORDER BY ld.ending_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS closing_balance
FROM last_day ld
LEFT JOIN monthly_balances mb
  ON ld.ending_month = mb.closing_month
  AND ld.customer_id = mb.customer_id
),
solution_t2 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance,
  ROW_NUMBER() OVER 
    (PARTITION BY customer_id, ending_month 
    ORDER BY ending_month) AS record_no
FROM solution_t1
),
solution_t3 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance, record_no,
  LEAD(record_no) OVER 
  (PARTITION BY customer_id, ending_month 
  ORDER BY ending_month) AS lead_no
FROM solution_t2)

SELECT customer_id, ending_month, monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL);

-- Create another temp table here
CREATE TEMP TABLE q5_sequence AS (
SELECT customer_id, ending_month, closing_balance,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ending_month) AS sequence
FROM q5)
````

**- What percentage of customers have a negative first month balance?**

````sql
SELECT *
FROM q5_sequence
WHERE sequence = 1 AND
  closing_balance::TEXT LIKE '-%';
````

I run the syntax above to get the output below where it confirms that I am getting records with negative first month balances only.

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

````sql
WITH next_balance_cte AS (
SELECT customer_id, ending_month, closing_balance, 
  LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
FROM q5_sequence
),
variance_cte AS (
SELECT customer_id, ending_month, closing_balance, next_balance, 
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
SELECT customer_id, ending_month, closing_balance, 
  LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
FROM q5_sequence
),
variance_cte AS (
SELECT customer_id, ending_month, closing_balance, next_balance, 
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
SELECT customer_id, ending_month, closing_balance, 
  LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
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
