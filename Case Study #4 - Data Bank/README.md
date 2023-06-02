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
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM data_bank.customer_nodes;
````

**Answer:**

|unique_nodes|
|:----|
|5|

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

**4. How many days on average are customers reallocated to a different node?**

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

Update Jun 2, 2023: Even after 2 years, I continue to find this question incredibly challenging. I have cleaned up the code and provided additional explanations. 

The key aspect to understanding the solution is to build up the tabele and run the CTEs cumulatively (run CTE 1 first, then run CTE 1 & 2, and so on). This approach allows for a better understanding of why specific columns were created or how the information in the tables progressed. 

```sql
-- CTE 1 - To identify transaction amount as an inflow (+) or outflow (-)
WITH monthly_balances_cte AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    SUM(CASE 
      WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN -txn_amount
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY 
    customer_id, txn_date 
)

-- CTE 2 - Use GENERATE_SERIES() to generate as a series of last day of the month for each customer.
, monthend_series_cte AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
)

-- CTE 3 - Calculate total monthly change and ending balance for each month using window function SUM()
, monthly_changes_cte AS (
  SELECT 
    monthend_series_cte.customer_id, 
    monthend_series_cte.ending_month,
    SUM(monthly_balances_cte.transaction_balance) OVER (
      PARTITION BY monthend_series_cte.customer_id, monthend_series_cte.ending_month
      ORDER BY monthend_series_cte.ending_month
    ) AS total_monthly_change,
    SUM(monthly_balances_cte.transaction_balance) OVER (
      PARTITION BY monthend_series_cte.customer_id 
      ORDER BY monthend_series_cte.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ending_balance
  FROM monthend_series_cte
  LEFT JOIN monthly_balances_cte
    ON monthend_series_cte.ending_month = monthly_balances_cte.closing_month
    AND monthend_series_cte.customer_id = monthly_balances_cte.customer_id
)

-- Final query: Display the output of customer monthly statement with the ending balances. 
SELECT 
customer_id, 
  ending_month, 
  COALESCE(total_monthly_change, 0) AS total_monthly_change, 
  MIN(ending_balance) AS ending_balance
 FROM monthly_changes_cte
 GROUP BY 
  customer_id, ending_month, total_monthly_change
 ORDER BY 
  customer_id, ending_month;
```

**Answer:**

Showing results for customers ID 1, 2 and 3 only:
|customer_id|ending_month|total_monthly_change|ending_balance|
|:----|:----|:----|:----|
|1|2020-01-31T00:00:00.000Z|312|312|
|1|2020-02-29T00:00:00.000Z|0|312|
|1|2020-03-31T00:00:00.000Z|-952|-964|
|1|2020-04-30T00:00:00.000Z|0|-640|
|2|2020-01-31T00:00:00.000Z|549|549|
|2|2020-02-29T00:00:00.000Z|0|549|
|2|2020-03-31T00:00:00.000Z|61|610|
|2|2020-04-30T00:00:00.000Z|0|610|
|3|2020-01-31T00:00:00.000Z|144|144|
|3|2020-02-29T00:00:00.000Z|-965|-821|
|3|2020-03-31T00:00:00.000Z|-401|-1222|
|3|2020-04-30T00:00:00.000Z|493|-729|

***

**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**

For this question, I have created 2 temporary tables to solve the questions below:
- Create temp table #1 `customer_monthly_balances` by copying and pasting the code from the solution to Question 4. 
- Use temp table #1 `ranked_monthly_balances` to create temp table #2 by applying the `ROW_NUMBER()` function. 

```sql
-- Temp table #1: Create a temp table using Question 4 solution
CREATE TEMP TABLE customer_monthly_balances AS (
  WITH monthly_balances_cte AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    SUM(CASE 
      WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN -txn_amount
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY 
    customer_id, txn_date 
), monthend_series_cte AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
), monthly_changes_cte AS (
  SELECT 
    monthend_series_cte.customer_id, 
    monthend_series_cte.ending_month,
    SUM(monthly_balances_cte.transaction_balance) OVER (
      PARTITION BY monthend_series_cte.customer_id, monthend_series_cte.ending_month
      ORDER BY monthend_series_cte.ending_month
    ) AS total_monthly_change,
    SUM(monthly_balances_cte.transaction_balance) OVER (
      PARTITION BY monthend_series_cte.customer_id 
      ORDER BY monthend_series_cte.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ending_balance
  FROM monthend_series_cte
  LEFT JOIN monthly_balances_cte
    ON monthend_series_cte.ending_month = monthly_balances_cte.closing_month
    AND monthend_series_cte.customer_id = monthly_balances_cte.customer_id 
)

SELECT 
  customer_id, 
  ending_month, 
  COALESCE(total_monthly_change, 0) AS total_monthly_change, 
  MIN(ending_balance) AS ending_balance
FROM monthly_changes_cte
GROUP BY 
  customer_id, ending_month, total_monthly_change
ORDER BY 
  customer_id, ending_month;
);

-- Temp table #2: Create a temp table using temp table #1 `customer_monthly_balances`
CREATE TEMP TABLE ranked_monthly_balances AS (
  SELECT 
    customer_id, 
    ending_month, 
    ending_balance,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS sequence
  FROM customer_monthly_balances
);
```

**- What percentage of customers have a negative first month balance? What percentage of customers have a positive first month balance?**

To address both questions, I'm using one solution since the questions are asking opposite spectrums of each other.  

````sql
-- Method 1
SELECT 
  ROUND(100.0 * 
    SUM(CASE 
      WHEN ending_balance::TEXT LIKE '-%' THEN 1 ELSE 0 END)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS negative_first_month_percentage,
  ROUND(100.0 * 
    SUM(CASE 
      WHEN ending_balance::TEXT NOT LIKE '-%' THEN 1 ELSE 0 END)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS positive_first_month_percentage
FROM ranked_monthly_balances
WHERE ranked_row = 1;
````

A cheeky solution would be to simply calculate one of the percentages requested and then deducting it from 100%.
```sql
-- Method 2
SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS negative_first_month_percentage,
  100 - ROUND(100.0 * COUNT(customer_id)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS positive_first_month_percentage
FROM ranked_monthly_balances
WHERE ranked_row = 1
  AND ending_balance::TEXT LIKE '-%';
```

**Answer:**

|negative_first_month_percentage|positive_first_month_percentage|
|:----|:----|
|44.8|55.2|

**- What percentage of customers increase their opening month’s positive closing balance by more than 5% in the following month?**

I'm using `LEAD()` window function to query the balances for the following month and then, filtering the results to select only the records with balances for the 1st and 2nd month. 

Important assumptions:
- Negative balances in the `following_balance` field have been excluded from the results. This is because a higher negative balance in the following month does not represent a true increase in balances. 
- Including negative balances could lead to a misrepresentation of the answer as the percentage of variance would still appear as a positive percentage. 

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT 
    customer_id, 
    ending_month, 
    ROUND(100.0 * 
      (following_balance - ending_balance) / ending_balance,1) AS variance
  FROM following_month_cte  
  WHERE ending_month = '2020-01-31'
    AND following_balance::TEXT NOT LIKE '-%'
  GROUP BY 
    customer_id, ending_month, ending_balance, following_balance
  HAVING ROUND(100.0 * (following_balance - ending_balance) / ending_balance,1) > 5.0
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS increase_5_percentage
FROM variance_cte; 
````

**Answer:**

|increase_5_percentage|
|:----|
|20.0|

- Among the customers, 20% experience a growth of more than 5% in their positive closing balance from the opening month to the following month.

**- What percentage of customers reduce their opening month’s positive closing balance by more than 5% in the following month?**

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT 
    customer_id, 
    ending_month, 
    ROUND((100.0 * 
      following_balance - ending_balance) / ending_balance,1) AS variance
  FROM following_month_cte  
  WHERE ending_month = '2020-01-31'
    AND following_balance::TEXT NOT LIKE '-%'
  GROUP BY 
    customer_id, ending_month, ending_balance, following_balance
  HAVING ROUND((100.0 * (following_balance - ending_balance)) / ending_balance,2) < 5.0
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS reduce_5_percentage
FROM variance_cte; 
````

**Answer:**

|reduce_5_percentage|
|:----|
|25.6|

- Among the customers, 25.6% experience a drop of more than 5% in their positive closing balance from the opening month to the following month.

**- What percentage of customers move from a positive balance in the first month to a negative balance in the second month?**

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT *
  FROM following_month_cte
  WHERE ending_month = '2020-01-31'
    AND ending_balance::TEXT NOT LIKE '-%'
    AND following_balance::TEXT LIKE '-%'
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS positive_to_negative_percentage
FROM variance_cte;
````

**Answer:**

|positive_to_negative_percentage|
|:----|
|20.2|

- Among the customers, 20.2% transitioned from having a positive balance (`ending_balance`) in the first month to having a negative balance (`following_balance`) in the following month.

***

Do give me a 🌟 if you like what you're reading. Thank you! 🙆🏻‍♀️
