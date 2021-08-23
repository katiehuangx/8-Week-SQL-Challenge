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

Firstly, I will show each CTE's output in order to provide a walkthrough of my thought process. I have also appended the full syntax below. 

_Note: If you have a shorter solution to this question, please share yours with me 🙂_

````sql
-- CTE 1 - To affix the transaction amount as an inflow (+) or outflow (-)
WITH monthly_balances AS (
SELECT 
  customer_id, 
  (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
  txn_type, 
  txn_amount,
  SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
    ELSE txn_amount END) AS transaction_balance
FROM data_bank.customer_transactions
GROUP BY customer_id, txn_date, txn_type, txn_amount)
````

Referring to the output below, deposits are inflow hence, it is a positive value whereas purchases and withdrawals are outflow hence, they are negative values with a '-' affix.
<img width="757" alt="image" src="https://user-images.githubusercontent.com/81607668/130432171-91eaa3db-9ac9-4e19-a512-72720859b0cd.png">


````sql
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
solution_t2 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance,
  ROW_NUMBER() OVER (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
FROM solution_t1
),
solution_t3 AS (
SELECT customer_id, ending_month, monthly_change, closing_balance, record_no,
  LEAD(record_no) OVER (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
FROM solution_t2)

SELECT customer_id, ending_month, monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;

Answer:

<img width="634" alt="image" src="https://user-images.githubusercontent.com/81607668/130431426-1882daec-8c93-4818-b041-943883aa21cb.png">

6. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:
  - Have a negative first month balance?
  - Have a positive first month balance?
  - Increase their opening month’s positive closing balance by more than 5% in the following month?
  - Reduce their opening month’s positive closing balance by more than 5% in the following month?
  - Move from a positive balance in the first month to a negative balance in the second month?
