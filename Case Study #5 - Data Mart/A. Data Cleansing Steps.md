# 🛒 Case Study #5 - Data Mart

## 🧼 Solution - A. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:
- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
  
<img width="166" alt="image" src="https://user-images.githubusercontent.com/81607668/131438667-3b7f3da5-cabc-436d-a352-2022841fc6a2.png">
  
- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:  

| segment | demographic | 
| ------- | ----------- |
| C | Couples |
| F | Families |

- Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

## Data Exploration

Ok, before I begin with the solution, I'm running some queries to get a feel of the data.

````sql
SELECT *
FROM data_mart.weekly_sales
LIMIT 5
````

<img width="825" alt="image" src="https://user-images.githubusercontent.com/81607668/131461620-3cf44ebc-dbde-43d2-bbd4-bc8a648c4e1d.png">

````sql
SELECT COUNT(*)
FROM data_mart.weekly_sales
````

<img width="89" alt="image" src="https://user-images.githubusercontent.com/81607668/131461755-6e86df9d-a923-4f2c-96b0-f656e4867ff4.png">

There are total of 17,117 rows.

````sql
SELECT DISTINCT region
FROM data_mart.weekly_sales
````

There are 2 `platform`s - Shopify and Retail.

<img width="115" alt="image" src="https://user-images.githubusercontent.com/81607668/131462951-3d93f35b-751b-4270-a0d4-d17f2d52bfe5.png">

````sql
SELECT DISTINCT segment
FROM data_mart.weekly_sales
ORDER BY segment
````

There are 8 unique `segment`s.

<img width="102" alt="image" src="https://user-images.githubusercontent.com/81607668/131462305-91713443-b243-4099-88e4-95f9c7cb65f6.png">

````sql
SELECT DISTINCT customer_type
FROM data_mart.weekly_sales
````

There are 3 types of `customer_type`.

<img width="142" alt="image" src="https://user-images.githubusercontent.com/81607668/131462439-eeb70a70-5533-48fd-aa5a-ee1a36d0e2d1.png">

## Create New Table `clean_weekly_sales`

Here, we construct the structure of `clean_weekly_sales` table and lay out the actions to be taken.

_`*` represent new columns_

| Columns | Actions to take |
| ------- | --------------- |
| week_date | Convert to `DATE`
| week_number* | Add number of week  
| month_number* | Extract month from `week_date`
| calendar_year* | Extract year from `week_date`
| region | No changes
| platform | No changes
| segment | No changes
| age_band* | Based on `segment`, 1 = `Young Adults`, 2 = `Middle Aged` and 3 or 4 = `Retirees` 
| demographic* | Based on `segment`, C = `Couples` and F = `Families`, null = `unknown`
| transactions | No changes
| avg_transaction* | Divide `sales` with `transactions` and round up to 2 decimal places
| sales | No changes

**Answer:**

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region, 
  platform, 
  segment,
  CASE WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales);

<img width="1148" alt="image" src="https://user-images.githubusercontent.com/81607668/131474035-528e0af6-d848-427b-bbd9-73956a775f86.png">

Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/B.%20Data%20Exploration.md_ for **B. Data Exploration** solution!
