# 🛒 Case Study #5 - Data Mart

## 🧼 Solution - C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:
**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**

Before we start, we find out the week_number of '2020-06-15' so that we can use it for filtering. 

````sql
SELECT DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15' 
  AND calendar_year = '2020'
````

<img width="138" alt="image" src="https://user-images.githubusercontent.com/81607668/131943472-5de6c243-c8e9-490d-8a4d-7bf990b4fd21.png">
 
The week_number is 25. Then, I created 2 CTEs
- changes CTE: Filter to 4 weeks before and after '2020-06-15 and SUM up the sales
- changes_2 CTE: Run a CASE WHEN for 4 weeks before and after '2020-06-15' and wrap with SUM as we only want the total sales for the period.

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

<img width="528" alt="image" src="https://user-images.githubusercontent.com/81607668/131943973-1406a95d-8fde-4b12-9390-d91c22d7ddff.png">

Since the new sustainable packaging came into effect, the sales has dropped by $26,884,188 at a negative 1.15%. A new packaging isn't always the best idea - as customers may not recognise your product's new packaging on the shelves!

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

<img width="582" alt="image" src="https://user-images.githubusercontent.com/81607668/131946233-45fa874e-0632-462d-9451-5ed4299b6183.png">

Looks like the sales has gone done even more with a negative 2.14%! I won't be happy if I'm Danny's boss 😆

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**


