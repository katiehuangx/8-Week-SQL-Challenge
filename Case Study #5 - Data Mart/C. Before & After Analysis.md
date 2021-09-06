# 🛒 Case Study #5 - Data Mart

## 🧼 Solution - C. Before & After Analysis

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

Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/D.%20Bonus%20Question.md) for **D. Bonus Question** solution! 🙌🏻
