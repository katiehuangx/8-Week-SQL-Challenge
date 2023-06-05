# Case Study #5: Data Mart

<img src="https://user-images.githubusercontent.com/81607668/131437982-fc087a4c-0b77-4714-907b-54e0420e7166.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-5/). 

***

## Business Task
Data Mart is an online supermarket that specialises in fresh produce.

In June 2020, large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to analyse and quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question to answer are the following:
- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

## Entity Relationship Diagram

For this case study there is only a single table: data_mart.weekly_sales

<img width="287" alt="image" src="https://user-images.githubusercontent.com/81607668/131438278-45e6a4e8-7cf5-468a-937b-2c306a792782.png">

Here are some further details about the dataset:

1. Data Mart has international operations using a multi-`region` strategy.
2. Data Mart has both, a retail and online `platform` in the form of a Shopify store front to serve their customers.
3. Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart.
4. `transactions` is the count of unique purchases made through Data Mart and `sales` is the actual dollar amount of purchases.

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

10 random rows are shown in the table output below from `data_mart.weekly_sales`.

<img width="649" alt="image" src="https://user-images.githubusercontent.com/81607668/131438417-1e21efa3-9924-490f-9bff-3c28cce41a37.png">

***

## Question and Solution

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/jmnwogTsUE8hGqkZv9H7E8/8). It would be great to work together on the questions!

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/katiehuangx/).

## 🧼 A. Data Cleansing Steps

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

**Answer:**

## Create New Table `clean_weekly_sales`

Let's construct the structure of `clean_weekly_sales` table and lay out the actions to be taken.

_`*` represent new columns_

| Columns | Actions to take |
| ------- | --------------- |
| week_date | Convert to `DATE` using `TO_DATE`
| week_number* | Extract number of week using `DATE_PART` 
| month_number* | Extract number of month using `DATE_PART` 
| calendar_year* | Extract year using `DATE_PART`
| region | No changes
| platform | No changes
| segment | No changes
| age_band* | Use `CASE WHEN` and based on `segment`, 1 = `Young Adults`, 2 = `Middle Aged`, 3/4 = `Retirees` and null = `Unknown`
| demographic* | Use `CASE WHEN` and based on `segment`, C = `Couples` and F = `Families` and null = `Unknown`
| transactions | No changes
| avg_transaction* | Divide `sales` with `transactions` and round up to 2 decimal places
| sales | No changes

**Answer:**

````sql
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
````

<img width="1148" alt="image" src="https://user-images.githubusercontent.com/81607668/131474035-528e0af6-d848-427b-bbd9-73956a775f86.png">

***

## 🛍 B. Data Exploration

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

## 🧼 C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**

Before we start, we find out the week_number of `'2020-06-15'` so that we can use it for filtering. 

````sql
SELECT 
  DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15' 
  AND calendar_year = '2020'
````

<img width="138" alt="image" src="https://user-images.githubusercontent.com/81607668/131943472-5de6c243-c8e9-490d-8a4d-7bf990b4fd21.png">
 
The week_number is 25. Then, I created 2 CTEs
- `changes` CTE: Filter to 4 weeks before and after `'2020-06-15` and `SUM` up the sales
- `changes_2` CTE: Run a `CASE WHEN` for 4 weeks before and after `'2020-06-15'` and wrap with `SUM` as we only want the total sales for the period.

````sql
WITH changes AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 21 AND 28) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
),
changes_2 AS (
  SELECT 
    SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_change
  FROM changes)

SELECT 
  before_change, 
  after_change, 
  after_change - before_change AS variance, 
  ROUND(100 * (after_change - before_change) / before_change,2) AS percentage
FROM changes_2
````

**Answer:**

<img width="528" alt="image" src="https://user-images.githubusercontent.com/81607668/131943973-1406a95d-8fde-4b12-9390-d91c22d7ddff.png">

Since the new sustainable packaging came into effect, the sales has dropped by $26,884,188 at a negative 1.15%. A new packaging isn't always the best idea - as customers may not recognise your product's new packaging on the shelves!

***

**2. What about the entire 12 weeks before and after?**

We can apply the same logic and solution to this question. 

````sql
WITH changes AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 13 AND 37) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
),
changes_2 AS (
  SELECT 
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_change
  FROM changes)

SELECT 
  before_change, 
  after_change, 
  after_change - before_change AS variance, 
  ROUND(100 * (after_change - before_change) / before_change,2) AS percentage
FROM changes_2
````

**Answer:**

<img width="582" alt="image" src="https://user-images.githubusercontent.com/81607668/131946233-45fa874e-0632-462d-9451-5ed4299b6183.png">

Looks like the sales has gone down even more with a negative 2.14%! I won't be happy if I'm Danny's boss 😆

***

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**

I'm breaking down this question to 2 parts.

**Part 1: How do the sale metrics for 4 weeks before and after compare with the previous years in 2018 and 2019?**
- Basically, the question is asking us to find the sales variance between 4 weeks before and after `'2020-06-15'` for years 2018, 2019 and 2020. Perhaps we can find a pattern here.
- We can apply the same solution as above and add `calendar_year` into the syntax. 

````sql
WITH summary AS (
  SELECT 
    calendar_year, -- added new column
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 21 AND 28) 
  GROUP BY calendar_year, week_number
),
summary_2 AS (
  SELECT 
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_sales
  FROM summary
  GROUP BY calendar_year
)

SELECT 
  calendar_year, 
  before_sales, 
  after_sales, 
  after_sales - before_sales AS sales_variance, 
  ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage
FROM summary_2
````

**Answer:**

<img width="735" alt="image" src="https://user-images.githubusercontent.com/81607668/131950161-371052e1-ad8b-4fe7-a1a1-97b968416d1d.png">

Let's a do some analysis with the results. 

We can see that in previous years in 2018 and 2019, there's a sort of consistent increase in sales in week 25 to 28 at an average of 0.15%. 

However, after the new packaging was implemented in 2020's week 25, there was a significant drop in sales at 1.15% and compared to the previous years, it's a reduction by 6.7%!

**Part 2: How do the sale metrics for 12 weeks before and after compare with the previous years in 2018 and 2019?**
- Use the same solution above and change to week 13 to 24 for before and week 25 to 37 for after.

````sql
WITH summary AS (
  SELECT 
    calendar_year, -- added new column
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 13 AND 37) 
  GROUP BY calendar_year, week_number
),
summary_2 AS (
  SELECT 
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_sales
  FROM summary
  GROUP BY calendar_year
)

SELECT 
  calendar_year, 
  before_sales, 
  after_sales, 
  after_sales - before_sales AS sales_variance, 
  ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage
FROM summary_2
````

**Answer:**

<img width="719" alt="image" src="https://user-images.githubusercontent.com/81607668/131950689-0241db95-6e4b-4b86-80cb-5cd2eada23cc.png">

There was a fair bit of percentage differences in all 3 years. However, now when you compare the worst year to their best year in 2018, the sales percentage difference is even more stark at a difference of 3.77% (1.63% + 2.14%).

***

## D. Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
- `region`
- `platform`
- `age_band`
- `demographic`
- `customer_type`

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

***
