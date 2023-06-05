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

For this case study there is only a single table: `data_mart.weekly_sales`

<img width="287" alt="image" src="https://user-images.githubusercontent.com/81607668/131438278-45e6a4e8-7cf5-468a-937b-2c306a792782.png">

Here are some further details about the dataset:

1. Data Mart has international operations using a multi-region strategy.
2. Data Mart has both, a retail and online `platform` in the form of a Shopify store front to serve their customers.
3. Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart.
4. `transactions` is the count of unique purchases made through Data Mart and `sales` is the actual dollar amount of purchases.

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a `week_date` value which represents the start of the sales week.

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

Let's construct the structure of `clean_weekly_sales` table and lay out the actions to be taken.

_`*` represent new columns_

| Column Name | Action to take |
| ------- | --------------- |
| week_date | Convert to `DATE` using `TO_DATE`
| week_number* | Extract number of week using `DATE_PART` 
| month_number* | Extract number of month using `DATE_PART` 
| calendar_year* | Extract year using `DATE_PART`
| region | No changes
| platform | No changes
| segment | No changes
| age_band* | Use `CASE` statement and apply conditional logic on `segment` with 1 = `Young Adults`, 2 = `Middle Aged`, 3/4 = `Retirees` and null = `Unknown`
| demographic* | Use `CASE WHEN` and apply conditional logic on based on `segment`, C = `Couples` and F = `Families` and null = `Unknown`
| transactions | No changes
| avg_transaction* | Divide `sales` with `transactions` and round up to 2 decimal places
| sales | No changes

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
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales
);
````

<img width="1148" alt="image" src="https://user-images.githubusercontent.com/81607668/131474035-528e0af6-d848-427b-bbd9-73956a775f86.png">

***

## 🛍 B. Data Exploration

**1. What day of the week is used for each week_date value?**

````sql
SELECT DISTINCT(TO_CHAR(week_date, 'day')) AS week_day 
FROM clean_weekly_sales;
````

**Answer:**

|week_day|
|:----|
|monday|

- Monday is used for the `week_date` value.

**2. What range of week numbers are missing from the dataset?**
- First, generate a range of week numbers for the entire year from 1st week to the 52nd week using the `GENERATE_SERIES()` function.
- Then, perform a `LEFT JOIN` with the `clean_weekly_sales`. Ensure that the join sequence is the CTE followed by the `clean_weekly_sales` as reversing the sequence would result in null results (unless you opt for a `RIGHT JOIN` instead!).

````sql
WITH week_number_cte AS (
  SELECT GENERATE_SERIES(1,52) AS week_number
)
  
SELECT DISTINCT week_no.week_number
FROM week_number_cte AS week_no
LEFT JOIN clean_weekly_sales AS sales
  ON week_no.week_number = sales.week_number
WHERE sales.week_number IS NULL; -- Filter to identify the missing week numbers where the values are `NULL`.
````

**Answer:**

_I'm posting only the results of 5 rows here. Ensure that you have retrieved 28 rows!_

|week_number|
|:----|
|1|
|2|
|3|
|37|
|41|

- The dataset is missing a total of 28 `week_number` records.

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

|calendar_year|total_transactions|
|:----|:----|
|2018|346406460|
|2019|365639285|
|2020|375813651|

**4. What is the total sales for each region for each month?**

````sql
SELECT 
  month_number, 
  region, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY month_number, region
ORDER BY month_number, region;
````

**Answer:**

I'm only showing the results for the month of March. 

|month_number|region|total_sales|
|:----|:----|:----|
|3|AFRICA|567767480|
|3|ASIA|529770793|
|3|CANADA|144634329|
|3|EUROPE|35337093|
|3|OCEANIA|783282888|
|3|SOUTH AMERICA|71023109|
|3|USA|225353043|

**5. What is the total count of transactions for each platform?**

````sql
SELECT 
  platform, 
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
````

**Answer:**

|platform|total_transactions|
|:----|:----|
|Retail|1081934227|
|Shopify|5925169|

**6. What is the percentage of sales for Retail vs Shopify for each month?**

````sql
WITH monthly_transactions AS (
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
    (CASE 
      WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) 
    / SUM(monthly_sales),2) AS retail_percentage,
  ROUND(100 * MAX 
    (CASE 
      WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END)
    / SUM(monthly_sales),2) AS shopify_percentage
FROM monthly_transactions
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;
````

**Answer:**

_Although I am only displaying the rows for the year 2018, please note that the overall results consist of 20 rows._

|calendar_year|month_number|retail_percentage|shopify_percentage|
|:----|:----|:----|:----|
|2018|3|97.92|2.08|
|2018|4|97.93|2.07|
|2018|5|97.73|2.27|
|2018|6|97.76|2.24|
|2018|7|97.75|2.25|
|2018|8|97.71|2.29|
|2018|9|97.68|2.32|

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
    (CASE 
      WHEN demographic = 'Couples' THEN yearly_sales ELSE NULL END)
    / SUM(yearly_sales),2) AS couples_percentage,
  ROUND(100 * MAX 
    (CASE 
      WHEN demographic = 'Families' THEN yearly_sales ELSE NULL END)
    / SUM(yearly_sales),2) AS families_percentage,
  ROUND(100 * MAX 
    (CASE 
      WHEN demographic = 'unknown' THEN yearly_sales ELSE NULL END)
    / SUM(yearly_sales),2) AS unknown_percentage
FROM demographic_sales
GROUP BY calendar_year;
````

**Answer:**

|calendar_year|couples_percentage|families_percentage|unknown_percentage|
|:----|:----|:----|:----|
|2019|27.28|32.47|40.25|
|2018|26.38|31.99|41.63|
|2020|28.72|32.73|38.55|

**8. Which age_band and demographic values contribute the most to Retail sales?**

````sql
SELECT 
  age_band, 
  demographic, 
  SUM(sales) AS retail_sales,
  ROUND(100 * 
    SUM(sales)::NUMERIC 
    / SUM(SUM(sales)) OVER (),
  1) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;
````

**Answer:**

|age_band|demographic|retail_sales|contribution_percentage|
|:----|:----|:----|:----|
|unknown|unknown|16067285533|40.5|
|Retirees|Families|6634686916|16.7|
|Retirees|Couples|6370580014|16.1|
|Middle Aged|Families|4354091554|11.0|
|Young Adults|Couples|2602922797|6.6|
|Middle Aged|Couples|1854160330|4.7|
|Young Adults|Families|1770889293|4.5|

The majority of the highest retail sales accounting for 42% are contributed by unknown `age_band` and `demographic`. This is followed by retired families at 16.73% and retired couples at 16.07%.

**9. Can we use the `avg_transaction` column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

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

|calendar_year|platform|avg_transaction_row|avg_transaction_group|
|:----|:----|:----|:----|
|2018|Retail|43|36|
|2018|Shopify|188|192|
|2019|Retail|42|36|
|2019|Shopify|178|183|
|2020|Retail|41|36|
|2020|Shopify|175|179|

The difference between `avg_transaction_row` and `avg_transaction_group` is as follows:
- `avg_transaction_row` calculates the average transaction size by dividing the sales of each row by the number of transactions in that row.
- On the other hand, `avg_transaction_group` calculates the average transaction size by dividing the total sales for the entire dataset by the total number of transactions.

For finding the average transaction size for each year by platform accurately, it is recommended to use `avg_transaction_group`.

***

## 🧼 C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**

Before we proceed, we determine the the week_number corresponding to '2020-06-15' to use it as a filter in our analysis. 

````sql
SELECT DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15' 
  AND calendar_year = '2020';
````

|week_number|
|:----|
|25|
 
The `week_number` is 25. I created 2 CTEs:
- `packaging_sales` CTE: Filter the dataset for 4 weeks before and after `2020-06-15` and calculate the sum of sales within the period.
- `before_after_changes` CTE: Utilize a `CASE` statement to capture the sales for 4 weeks before and after `2020-06-15` and then calculate the total sales for the specified period.

````sql
WITH packaging_sales AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 21 AND 28) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
)
, before_after_changes AS (
  SELECT 
    SUM(CASE 
      WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_packaging_sales,
    SUM(CASE 
      WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_packaging_sales
  FROM packaging_sales
)

SELECT 
  after_packaging_sales - before_packaging_sales AS sales_variance, 
  ROUND(100 * 
    (after_packaging_sales - before_packaging_sales) 
    / before_packaging_sales,2) AS variance_percentage
FROM before_after_changes;
````

**Answer:**

|sales_variance|variance_percentage|
|:----|:----|
|-26884188|-1.15|

Since the implementation of the new sustainable packaging, there has been a decrease in sales amounting by $26,884,188 reflecting a negative change at 1.15%. Introducing a new packaging does not always guarantee positive results as customers may not readily recognise your product on the shelves due to the change in packaging.

***

**2. What about the entire 12 weeks before and after?**

We can apply a similar approach and solution to address this question. 

````sql
WITH packaging_sales AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE (week_number BETWEEN 13 AND 37) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
)
, before_after_changes AS (
  SELECT 
    SUM(CASE 
      WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_packaging_sales,
    SUM(CASE 
      WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_packaging_sales
  FROM packaging_sales
)

SELECT 
  after_packaging_sales - before_packaging_sales AS sales_variance, 
  ROUND(100 * 
    (after_packaging_sales - before_packaging_sales) / before_packaging_sales,2) AS variance_percentage
FROM before_after_changes;
````

**Answer:**

|sales_variance|variance_percentage|
|:----|:----|
|-152325394|-2.14|

Looks like the sales have experienced a further decline, now at a negative 2.14%! If I'm Danny's boss, I wouldn't be too happy with the results.

***

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**

I'm breaking down this question to 2 parts.

**Part 1: How do the sale metrics for 4 weeks before and after compare with the previous years in 2018 and 2019?**
- Basically, the question is asking us to find the sales variance between 4 weeks before and after `'2020-06-15'` for years 2018, 2019 and 2020. Perhaps we can find a pattern here.
- We can apply the same solution as above and add `calendar_year` into the syntax. 

````sql
WITH changes AS (
  SELECT 
    calendar_year,
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN 21 AND 28
  GROUP BY calendar_year, week_number
)
, before_after_changes AS (
  SELECT 
    calendar_year,
    SUM(CASE 
      WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_packaging_sales,
    SUM(CASE 
      WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_packaging_sales
  FROM changes
  GROUP BY calendar_year
)

SELECT 
  calendar_year, 
  after_packaging_sales - before_packaging_sales AS sales_variance, 
  ROUND(100 * 
    (after_packaging_sales - before_packaging_sales) 
    / before_packaging_sales,2) AS variance_percentage
FROM before_after_changes;
````

**Answer:**

|calendar_year|sales_variance|variance_percentage|
|:----|:----|:----|
|2018|4102105|0.19|
|2019|2336594|0.10|
|2020|-26884188|-1.15|

In 2018, there was a sales variance of $4,102,105, indicating a positive change of 0.19% compared to the period before the packaging change.

Similarly, in 2019, there was a sales variance of $2,336,594, corresponding to a positive change of 0.10% when comparing the period before and after the packaging change.

However, in 2020, there was a substantial decrease in sales following the packaging change. The sales variance amounted to $26,884,188, indicating a significant negative change of -1.15%. This reduction represents a considerable drop compared to the previous years.

**Part 2: How do the sale metrics for 12 weeks before and after compare with the previous years in 2018 and 2019?**
- Use the same solution above and change to week 13 to 24 for before and week 25 to 37 for after.

````sql
WITH changes AS (
  SELECT 
    calendar_year, 
    week_number, 
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN 13 AND 37
  GROUP BY calendar_year, week_number
)
, before_after_changes AS (
  SELECT 
    calendar_year,
    SUM(CASE 
      WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_packaging_sales,
    SUM(CASE 
      WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_packaging_sales
  FROM changes
  GROUP BY calendar_year
)

SELECT 
  calendar_year, 
  after_packaging_sales - before_packaging_sales AS sales_variance, 
  ROUND(100 * 
    (after_packaging_sales - before_packaging_sales) 
    / before_packaging_sales,2) AS variance_percentage
FROM before_after_changes;
````

**Answer:**

|calendar_year|sales_variance|variance_percentage|
|:----|:----|:----|
|2018|104256193|1.63|
|2019|-20740294|-0.30|
|2020|-152325394|-2.14|

There was a fair bit of percentage differences in all 3 years. However, now when you compare the worst year to their best year in 2018, the sales percentage difference is even more stark at a difference of 3.77% (1.63% + 2.14%).

When comparing the sales performance across all three years, there were noticeable variations in the percentage differences. However, the most significant contrast emerges when comparing the worst-performing year in 2020 to the best-performing year in 2018. In this comparison, the sales percentage difference becomes even more apparent with a significant gap of 3.77% (1.63% + 2.14%).

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
