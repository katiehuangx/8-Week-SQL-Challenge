# 💵 Case Study #4 - Data Bank

## 🏦 Solution - A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

````sql
SELECT 
  COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;
````

**Answer:**

<img width="97" alt="image" src="https://user-images.githubusercontent.com/81607668/130343558-c73b2bd4-d799-4506-9d9f-2fe0125f9c8f.png">

- There are 5 unique nodes on Data Bank system.

***

**2. What is the number of nodes per region?**

````sql
SELECT 
  r.region_id, 
  r.region_name, 
  COUNT(*) AS node_count
FROM data_bank.regions r
JOIN data_bank.customer_nodes n
  ON r.region_id = n.region_id
GROUP BY r.region_id, r.region_name
ORDER BY region_id;
````

**Answer:**

<img width="391" alt="image" src="https://user-images.githubusercontent.com/81607668/130343679-c49a7b82-bef5-4242-a6ec-b449f643f656.png">

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

<img width="296" alt="image" src="https://user-images.githubusercontent.com/81607668/130344283-5c675490-b8b1-46ea-93df-0683ff87243b.png">

***

**5. How many days on average are customers reallocated to a different node?**

````sql
WITH node_diff AS (
  SELECT 
    customer_id, node_id, start_date, end_date,
    end_date - start_date AS diff
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
  ORDER BY customer_id, node_id
  ),
sum_diff_cte AS (
  SELECT 
    customer_id, node_id, SUM(diff) AS sum_diff
  FROM node_diff
  GROUP BY customer_id, node_id)

SELECT 
  ROUND(AVG(sum_diff),2) AS avg_reallocation_days
FROM sum_diff_cte;
````

**Answer:**

<img width="178" alt="image" src="https://user-images.githubusercontent.com/81607668/130345231-fd91f86f-1a2a-466a-b5b4-ccee80d15c92.png">

- On average, customers are reallocated to a different node every 24 days.

***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

_Updating_

***

Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/B.%20Customer%20Transactions.md) for **B. Customer Transactions** solution!
