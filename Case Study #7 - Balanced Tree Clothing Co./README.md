## 🌲 Case Study #7: Balanced Tree

<img src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/8ada3c0c-e90a-47a7-9a5c-8ffd6ee3eef8" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-7/). 

***

## Business Task

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams **analyse their sales performance and generate a basic financial report** to share with the wider business.

## Entity Relationship Diagram

<img width="932" alt="image" src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/2ce4df84-2b05-4fe9-a50c-47c903b392d5">

**Table 1: `product_details`**

|product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
|:----|:----|:----|:----|:----|:----|:----|:----|:----|
|c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
|e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
|e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
|d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
|72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|
|9ec847|54|Grey Fashion Jacket - Womens|1|4|12|Womens|Jacket|Grey Fashion|
|5d267b|40|White Tee Shirt - Mens|2|5|13|Mens|Shirt|White Tee|
|c8d436|10|Teal Button Up Shirt - Mens|2|5|14|Mens|Shirt|Teal Button Up|
|2a2353|57|Blue Polo Shirt - Mens|2|5|15|Mens|Shirt|Blue Polo|
|f084eb|36|Navy Solid Socks - Mens|2|6|16|Mens|Socks|Navy Solid|


**Table 2: `sales`**

|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|:----|:----|:----|:----|:----|:----|:----|
|c4a632|4|13|17|true|54f307|2021-02-13T01:59:43.296Z|
|5d267b|4|40|17|true|54f307|2021-02-13T01:59:43.296Z|
|b9a74d|4|17|17|true|54f307|2021-02-13T01:59:43.296Z|
|2feb6b|2|29|17|true|54f307|2021-02-13T01:59:43.296Z|
|c4a632|5|13|21|true|26cc98|2021-01-19T01:39:00.345Z|
|e31d39|2|10|21|true|26cc98|2021-01-19T01:39:00.345Z|
|72f5d4|3|19|21|true|26cc98|2021-01-19T01:39:00.345Z|
|2a2353|3|57|21|true|26cc98|2021-01-19T01:39:00.345Z|
|f084eb|3|36|21|true|26cc98|2021-01-19T01:39:00.345Z|
|c4a632|1|13|21|false|ef648d|2021-01-27T02:18:17.164Z|

**Table 3: `product_hierarchy`**

|id|parent_id|level_text|level_name|
|:----|:----|:----|:----|
|1|null|Womens|Category|
|2|null|Mens|Category|
|3|1|Jeans|Segment|
|4|1|Jacket|Segment|
|5|2|Shirt|Segment|
|6|2|Socks|Segment|
|7|3|Navy Oversized|Style|
|8|3|Black Straight|Style|
|9|3|Cream Relaxed|Style|
|10|4|Khaki Suit|Style|

**Table 4: `product_prices`**

|id|product_id|price|
|:----|:----|:----|
|7|c4a632|13|
|8|e83aa3|32|
|9|e31d39|10|
|10|d5e9a6|23|
|11|72f5d4|19|
|12|9ec847|54|
|13|5d267b|40|
|14|c8d436|10|
|15|2a2353|57|
|16|f084eb|36|

***

## Question and Solution

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/dkhULDEjGib3K58MvDjYJr/8). It would be great to work together on the questions!

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/katiehuangx/).

## 📈 A. High Level Sales Analysis

**1. What was the total quantity sold for all products?**

```sql
SELECT 
  product.product_name, 
  SUM(sales.qty) AS total_quantity
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.product_name;
```

**Answer:**

|product_name|total_quantity|
|:----|:----|
|White Tee Shirt - Mens|3800|
|Navy Solid Socks - Mens|3792|
|Grey Fashion Jacket - Womens|3876|
|Navy Oversized Jeans - Womens|3856|
|Pink Fluro Polkadot Socks - Mens|3770|
|Khaki Suit Jacket - Womens|3752|
|Black Straight Jeans - Womens|3786|
|White Striped Socks - Mens|3655|
|Blue Polo Shirt - Mens|3819|
|Indigo Rain Jacket - Womens|3757|
|Cream Relaxed Jeans - Womens|3707|
|Teal Button Up Shirt - Mens|3646|

***

**2. What is the total generated revenue for all products before discounts?**

```sql
SELECT 
  product.product_name, 
  SUM(sales.qty) * SUM(sales.price) AS total_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.product_name;
```

**Answer:**

|product_name|total_revenue|
|:----|:----|
|White Tee Shirt - Mens|192736000|
|Navy Solid Socks - Mens|174871872|
|Grey Fashion Jacket - Womens|266862600|
|Navy Oversized Jeans - Womens|63863072|
|Pink Fluro Polkadot Socks - Mens|137537140|
|Khaki Suit Jacket - Womens|107611112|
|Black Straight Jeans - Womens|150955392|
|White Striped Socks - Mens|77233805|
|Blue Polo Shirt - Mens|276022044|
|Indigo Rain Jacket - Womens|89228750|
|Cream Relaxed Jeans - Womens|46078010|
|Teal Button Up Shirt - Mens|45283320|

***

**3. What was the total discount amount for all products?**

```sql
SELECT 
  product.product_name, 
  SUM(sales.qty * sales.price * sales.discount/100) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.product_name;
```

**Answer:**

|product_name|total_discount|
|:----|:----|
|White Tee Shirt - Mens|17968|
|Navy Solid Socks - Mens|16059|
|Grey Fashion Jacket - Womens|24781|
|Navy Oversized Jeans - Womens|5538|
|Pink Fluro Polkadot Socks - Mens|12344|
|Khaki Suit Jacket - Womens|9660|
|Black Straight Jeans - Womens|14156|
|White Striped Socks - Mens|6877|
|Blue Polo Shirt - Mens|26189|
|Indigo Rain Jacket - Womens|8010|
|Cream Relaxed Jeans - Womens|3979|
|Teal Button Up Shirt - Mens|3925|

***

## 🧾 B. Transaction Analysis

**1. How many unique transactions were there?**

```sql
SELECT COUNT(DISTINCT txn_id) AS transaction_count
FROM balanced_tree.sales;
```

**Answer:**

|transaction_count|
|:----|
|2500|

***

**2. What is the average unique products purchased in each transaction?**

```sql
SELECT ROUND(AVG(total_quantity)) AS avg_unique_products
FROM (
  SELECT 
    txn_id, 
    SUM(qty) AS total_quantity
  FROM balanced_tree.sales
  GROUP BY txn_id
) AS total_quantities;
```

**Answer:**

|avg_unique_products|
|:----|
|18|

***

**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**

```sql
WITH revenue_cte AS (
  SELECT 
    txn_id, 
    SUM(price * qty) AS revenue
  FROM balanced_tree.sales
  GROUP BY txn_id
)

SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS median_25th,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_50th,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS median_75th
FROM revenue_cte;
```

**Answer:**

|median_25th|median_50th|median_75th|
|:----|:----|:----|
|375.75|509.5|647|

***

**4. What is the average discount value per transaction?**

```sql
SELECT ROUND(AVG(discount_amt)) AS avg_discount
FROM (
  SELECT 
	  txn_id,
    SUM(qty * price * discount/100) AS discount_amt
  FROM balanced_tree.sales
  GROUP BY txn_id
) AS discounted_value
```

**Answer:**

|avg_discount|
|:----|
|60|

**5. What is the percentage split of all transactions for members vs non-members?**

```sql
WITH transactions_cte AS (
  SELECT
    member,
    COUNT(DISTINCT txn_id) AS transactions
  FROM balanced_tree.sales
  GROUP BY member
)

SELECT
	member,
  transactions,
  ROUND(100 * transactions
    /(SELECT SUM(transactions) 
      FROM transactions_cte)) AS percentage
FROM transactions_cte
GROUP BY member, transactions;
```

**Answer:**

Members have a transaction count at 60% compared to than non-members who account for only 40% of the transactions.

|member|transactions|percentage|
|:----|:----|:----|
|false|995|40|
|true|1505|60|

***

**6. What is the average revenue for member transactions and non-member transactions?**

```sql
WITH revenue_cte AS (
  SELECT
    member,
  	txn_id,
    SUM(price * qty) AS revenue
  FROM balanced_tree.sales
  GROUP BY member, txn_id
)

SELECT
	member,
  ROUND(AVG(revenue),2) AS avg_revenue
FROM revenue_cte
GROUP BY member;
```

**Answer:**

The average revenue per transaction for members is only $1.23 higher compared to non-members.

|member|avg_revenue|
|:----|:----|
|false|515.04|
|true|516.27|

***

## 👚 C. Product Analysis

**1. What are the top 3 products by total revenue before discount?**

```sql
SELECT 
  product.product_id,
  product.product_name, 
  SUM(sales.qty) * SUM(sales.price) AS total_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.product_id, product.product_name
ORDER BY total_revenue DESC
LIMIT 3;
```

**Answer:**

|product_id|product_name|total_revenue|
|:----|:----|:----|
|2a2353|Blue Polo Shirt - Mens|276022044|
|9ec847|Grey Fashion Jacket - Womens|266862600|
|5d267b|White Tee Shirt - Mens|192736000|

***

**2. What is the total quantity, revenue and discount for each segment?**

```sql
SELECT 
  product.segment_id,
  product.segment_name, 
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  SUM((sales.qty * sales.price) * sales.discount/100) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.segment_id, product.segment_name;
```

**Answer:**

|segment_id|segment_name|total_quantity|total_revenue|total_discount|
|:----|:----|:----|:----|:----|
|4|Jacket|11385|366983|42451|
|6|Socks|11217|307977|35280|
|5|Shirt|11265|406143|48082|
|3|Jeans|11349|208350|23673|

***

**3. What is the top selling product for each segment?**

```sql
WITH top_selling_cte AS ( 
  SELECT 
    product.segment_id,
    product.segment_name, 
    product.product_id,
    product.product_name,
    SUM(sales.qty) AS total_quantity,
    RANK() OVER (
      PARTITION BY segment_id 
      ORDER BY SUM(sales.qty) DESC) AS ranking
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details AS product
    ON sales.prod_id = product.product_id
  GROUP BY 
    product.segment_id, product.segment_name, product.product_id, product.product_name
)

SELECT 
  segment_id,
  segment_name, 
  product_id,
  product_name,
  total_quantity
FROM top_selling_cte
WHERE ranking = 1;
```

**Answer:**

|segment_id|segment_name|product_id|product_name|total_quantity|
|:----|:----|:----|:----|:----|
|3|Jeans|c4a632|Navy Oversized Jeans - Womens|3856|
|4|Jacket|9ec847|Grey Fashion Jacket - Womens|3876|
|5|Shirt|2a2353|Blue Polo Shirt - Mens|3819|
|6|Socks|f084eb|Navy Solid Socks - Mens|3792|

***

**4. What is the total quantity, revenue and discount for each category?**

```sql
SELECT 
  product.category_id,
  product.category_name, 
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  SUM((sales.qty * sales.price) * sales.discount/100) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details AS product
	ON sales.prod_id = product.product_id
GROUP BY product.category_id, product.category_name
ORDER BY product.category_id;
```

**Answer:**

|category_id|category_name|total_quantity|total_revenue|total_discount|
|:----|:----|:----|:----|:----|
|1|Womens|22734|575333|66124|
|2|Mens|22482|714120|83362|

***

**5. What is the top selling product for each category?**

```sql
WITH top_selling_cte AS ( 
  SELECT 
    product.category_id,
    product.category_name, 
    product.product_id,
    product.product_name,
    SUM(sales.qty) AS total_quantity,
    RANK() OVER (
      PARTITION BY product.category_id 
      ORDER BY SUM(sales.qty) DESC) AS ranking
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details AS product
    ON sales.prod_id = product.product_id
  GROUP BY 
    product.category_id, product.category_name, product.product_id, product.product_name
)

SELECT 
  category_id,
  category_name, 
  product_id,
  product_name,
  total_quantity
FROM top_selling_cte
WHERE ranking = 1;
```

**Answer:**

|category_id|category_name|product_id|product_name|total_quantity|
|:----|:----|:----|:----|:----|
|1|Womens|9ec847|Grey Fashion Jacket - Womens|3876|
|2|Mens|2a2353|Blue Polo Shirt - Mens|3819|

***

**6. What is the percentage split of revenue by product for each segment?**

**Answer:**

***

**7. What is the percentage split of revenue by segment for each category?**

**Answer:**

***

**8. What is the percentage split of total revenue by category?**

**Answer:**

***

**9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**

**Answer:**

***

**10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**

**Answer:**

***

## 📝 Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

***

## 💡 Bonus Challenge

Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

Hint: you may want to consider using a recursive CTE to solve this problem!

***
