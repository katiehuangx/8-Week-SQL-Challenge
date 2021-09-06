# 🛒 Case Study #5 - Data Mart

## 🛍 Solution - B. Data Exploration

**1. What day of the week is used for each week_date value?**

````sql
SELECT 
  DISTINCT(TO_CHAR(week_date, 'day')) AS week_day 
FROM clean_weekly_sales;
````

**Answer:**

<img width="110" alt="image" src="https://user-images.githubusercontent.com/81607668/131616348-81580d0e-b919-439a-821d-7997d958f59e.png">

- Monday is used for each `week_date` value.

**2. What range of week numbers are missing from the dataset?**
- First, generate the full range of week numbers for the entire year from 1st week to 52nd week.
- Then, do a LEFT OUTER JOIN of `week_number_cte` with `clean_weekly_sales` - make sure that the join sequence is CTE followed by the temp table as doing this on reverse would result in null result (unless you run a RIGHT OUTER JOIN instead!).

````sql
WITH week_number_cte AS (
  SELECT GENERATE_SERIES(1,52) AS week_number)
  
SELECT 
  DISTINCT c.week_number
FROM week_number_cte c
LEFT OUTER JOIN clean_weekly_sales s
  ON c.week_number = s.week_number
WHERE s.week_number IS NULL; -- Filter for the missing week numbers whereby the values would be `null`
````

**Answer:**

_I'm posting only 5 rows here - ensure that you retrieved 28 rows!_

<img width="239" alt="image" src="https://user-images.githubusercontent.com/81607668/131644275-6a91200f-61fe-4b71-83d4-7b51945e4531.png">

- 28 `week_number`s are missing from the dataset.

**3. How many total transactions were there for each year in the dataset?**

````sql
SELECT 
  calendar_year, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
````

**Answer:**

<img width="318" alt="image" src="https://user-images.githubusercontent.com/81607668/131616261-82cb0fca-2d55-4bd0-8859-508e0fda23ec.png">

**4. What is the total sales for each region for each month?**

````sql
SELECT 
  region, 
  month_number, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
````

**Answer:**

_As there are 7 regions and results came up to 49 rows, I'm only showing solution for AFRICA and ASIA._

<img width="641" alt="image" src="https://user-images.githubusercontent.com/81607668/131622450-4bb787d6-8481-4798-acda-67db888e925b.png">

**5. What is the total count of transactions for each platform?**

````sql
SELECT 
  platform, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
````

**Answer:**

<img width="319" alt="image" src="https://user-images.githubusercontent.com/81607668/131622827-35d01869-ab06-45f9-b5ac-6e9b6be8d74e.png">

**6. What is the percentage of sales for Retail vs Shopify for each month?**

````sql
WITH transactions_cte AS (
  SELECT 
    calendar_year, 
    month_number, 
    platform, 
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
)

SELECT 
  calendar_year, 
  month_number, 
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS retail_percentage,
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS shopify_percentage
  FROM transactions_cte
  GROUP BY calendar_year, month_number
  ORDER BY calendar_year, month_number;
````

**Answer:**

_The results came up to 20 rows, so I'm only showing solution year 2018._

<img width="628" alt="image" src="https://user-images.githubusercontent.com/81607668/131631945-ea79d106-e848-4008-b70f-9dedd73ba0dd.png">

**7. What is the percentage of sales by demographic for each year in the dataset?**

````sql
WITH demographic_sales AS (
  SELECT 
    calendar_year, 
    demographic, 
    SUM(sales) AS yearly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, demographic
)

SELECT 
  calendar_year, 
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Couples' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS couples_percentage,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Families' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS families_percentage,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'unknown' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS unknown_percentage
FROM demographic_sales
GROUP BY calendar_year
ORDER BY calendar_year;
````

**Answer:**

<img width="755" alt="image" src="https://user-images.githubusercontent.com/81607668/131632947-ba6d9444-73e2-4ecd-9ff2-5bd6ab78f66d.png">

**8. Which age_band and demographic values contribute the most to Retail sales?**

````sql
SELECT 
  age_band, 
  demographic, 
  SUM(sales) AS retail_sales,
  ROUND(100 * SUM(sales)::NUMERIC / SUM(SUM(sales)) OVER (),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;
````

**Answer:**

<img width="650" alt="image" src="https://user-images.githubusercontent.com/81607668/131634091-bc09c295-f880-4ec1-ad2f-d503bb3b04b9.png">

The highest retail sales are contributed by unknown `age_band` and `demographic` at 42% followed by retired families at 16.73% and retired couples at 16.07%.

**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

````sql
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
````

**Answer:**

<img width="636" alt="image" src="https://user-images.githubusercontent.com/81607668/131635398-0d54f57b-b813-4a2f-9d9c-320cf033ff97.png">

What's the difference between `avg_transaction_row` and `avg_transaction_group`?
- `avg_transaction_row` is the average transaction in dollars by taking each row's sales divided by the row's number of transactions.
- `avg_transaction_group` is the average transaction in dollars by taking total sales divided by total number of transactions for the entire data set.

The more accurate answer to find average transaction size for each year by platform would be `avg_transaction_group`.

***

Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/C.%20Before%20%26%20After%20Analysis.md) for solution to **C. Before & After Analysis**!
