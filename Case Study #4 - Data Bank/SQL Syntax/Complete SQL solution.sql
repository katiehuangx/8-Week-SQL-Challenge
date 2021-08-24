--------------------------------------------
--Solution for A. Customer Nodes Exploration
--------------------------------------------

--1. How many unique nodes are there on the Data Bank system?
SELECT 
  COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;

--2. What is the number of nodes per region?
SELECT 
  r.region_id, r.region_name, 
  COUNT(node_id) AS node_count
FROM data_bank.regions r
JOIN data_bank.customer_nodes n
  ON r.region_id = n.region_id
GROUP BY r.region_id, r.region_name
ORDER BY region_id;

--3. How many customers are allocated to each region?
SELECT 
  region_id, 
  COUNT(customer_id) AS customer_count
FROM data_bank.customer_nodes
GROUP BY region_id
ORDER BY region_id;

--4. How many days on average are customers reallocated to a different node?
WITH node_diff AS (
  SELECT 
    customer_id, node_id, start_date, end_date,
    (end_date - start_date) AS diff
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
),
sum_diff_cte AS (
  SELECT 
    customer_id, node_id, 
    SUM(diff) AS sum_diff
  FROM node_diff
  GROUP BY customer_id, node_id
)

SELECT 
  ROUND(AVG(sum_diff),0) AS avg_reallocation_days
FROM sum_diff_cte;

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

--24/08/2021: Pending. To be updated.

---------------------------------------
--Solution for B. Customer Transactions
---------------------------------------

--1. What is the unique count and total amount for each transaction type?
SELECT 
  txn_type, 
  COUNT(*), 
  SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;

--2. What is the average total historical deposit counts and amounts for all customers?
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
  ROUND(AVG(avg_amount),2) AS avg_deposit_amount
FROM deposits
WHERE txn_type = 'deposit';

--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

-- Group customer transactions into month and type
WITH monthly_transactions AS (
  SELECT 
    customer_id, 
    DATE_PART('month', txn_date) AS month,
    SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
FROM data_bank.customer_transactions
GROUP BY customer_id, month)

SELECT
  month,
  COUNT(DISTINCT customer_id) AS customer_count
FROM monthly_transactions
WHERE deposit_count >= 2 
  AND (purchase_count > 1 OR withdrawal_count > 1)
GROUP BY month
ORDER BY month;

--4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.
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
    customer_id, ending_month, monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month 
      ORDER BY ending_month) AS record_no
  FROM solution_t1
),
solution_t3 AS (
  SELECT 
    customer_id, ending_month, monthly_change, closing_balance, record_no,
    LEAD(record_no) OVER 
    (PARTITION BY customer_id, ending_month 
    ORDER BY ending_month) AS lead_no
  FROM solution_t2)

SELECT 
  customer_id, ending_month, monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;

--5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:

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
    customer_id, ending_month, monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month 
      ORDER BY ending_month) AS record_no
  FROM solution_t1
),
solution_t3 AS (
  SELECT 
    customer_id, ending_month, monthly_change, closing_balance, record_no,
    LEAD(record_no) OVER 
    (PARTITION BY customer_id, ending_month 
    ORDER BY ending_month) AS lead_no
  FROM solution_t2)

SELECT 
  customer_id, ending_month, monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL);

CREATE TEMP TABLE q5_sequence AS (
SELECT 
  customer_id, ending_month, closing_balance,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ending_month) AS sequence
FROM q5)

--Have a negative first month balance?
SELECT *
FROM q5_sequence
WHERE sequence = 1 
  AND closing_balance::TEXT LIKE '-%';
  
SELECT 
  ROUND(100 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS negative_first_month_percentage
FROM q5_sequence
WHERE sequence = 1 
  AND closing_balance::TEXT LIKE '-%';

--Have a positive first month balance?
SELECT 
  ROUND(100 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS positive_first_month_percentage
FROM q5_sequence
WHERE sequence = 1 
  AND closing_balance::TEXT NOT LIKE '-%';
  
--Increase their opening month’s positive closing balance by more than 5% in the following month?
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER 
      (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
variance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, next_balance, 
    ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) AS variance
  FROM next_balance_cte  
  WHERE ending_month = '2020-01-31'
    AND next_balance::TEXT NOT LIKE '-%'
  GROUP BY customer_id, ending_month, closing_balance, next_balance
  HAVING ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) > 5.0)

SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS variance_more_5_percentage
FROM variance_cte;

--Reduce their opening month’s positive closing balance by more than 5% in the following month?
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
variance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, next_balance, 
    ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) AS variance
  FROM next_balance_cte  
  WHERE ending_month = '2020-01-31'
    AND next_balance::TEXT LIKE '-%'
  GROUP BY customer_id, ending_month, closing_balance, next_balance
  HAVING ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) > 5.0)

SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS neg_variance_more_5_percentage
FROM variance_cte;

--Move from a positive balance in the first month to a negative balance in the second month?
WITH next_balance_cte AS (
  SELECT 
    customer_id, ending_month, closing_balance, 
    LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY ending_month) AS next_balance
  FROM q5_sequence
),
positive_negative AS (
  SELECT *
  FROM next_balance_cte
  WHERE ending_month = '2020-01-31'
    AND closing_balance::TEXT NOT LIKE '-%'
    AND next_balance::TEXT LIKE '-%')

SELECT 
  ROUND(100.0 * COUNT(*)::NUMERIC / 
    (SELECT COUNT(DISTINCT customer_id)
    FROM q5_sequence),2) AS positive_1st_negative_2nd_percentage
FROM positive_negative;
  
-------------------------------
