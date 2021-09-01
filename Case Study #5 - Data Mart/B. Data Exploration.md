# 🛒 Case Study #5 - Data Mart

## 🛍 Solution - B. Data Exploration

1. What day of the week is used for each week_date value?

````sql
SELECT 
  DISTINCT(TO_CHAR(week_date, 'day')) AS week_day
FROM clean_weekly_sales;
````

<img width="110" alt="image" src="https://user-images.githubusercontent.com/81607668/131616348-81580d0e-b919-439a-821d-7997d958f59e.png">

2. What range of week numbers are missing from the dataset?

3. How many total transactions were there for each year in the dataset?

````sql
SELECT 
  calendar_year, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
````

<img width="318" alt="image" src="https://user-images.githubusercontent.com/81607668/131616261-82cb0fca-2d55-4bd0-8859-508e0fda23ec.png">

4. What is the total sales for each region for each month?

````sql
SELECT 
  region, 
  month_number, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
````

_As there are 7 regions and results came up to 49 rows, I'm only showing solution for AFRICA and ASIA._

<img width="641" alt="image" src="https://user-images.githubusercontent.com/81607668/131622450-4bb787d6-8481-4798-acda-67db888e925b.png">

5. What is the total count of transactions for each platform?

````sql
SELECT platform, SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;
````

<img width="319" alt="image" src="https://user-images.githubusercontent.com/81607668/131622827-35d01869-ab06-45f9-b5ac-6e9b6be8d74e.png">

10. What is the percentage of sales for Retail vs Shopify for each month?



12. What is the percentage of sales by demographic for each year in the dataset?
13. Which age_band and demographic values contribute the most to Retail sales?
14. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
