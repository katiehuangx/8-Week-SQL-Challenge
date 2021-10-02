# 🥑 Case Study #3 - Foodie-Fi

## 🎞 Solution - B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

To find the number of Foodie-Fi's unique customers, I use `DISTINCT` and wrap `COUNT` around it.

````sql
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM foodie_fi.subscriptions;
````

**Answer:**

<img width="159" alt="image" src="https://user-images.githubusercontent.com/81607668/129764903-bb0480aa-bf92-46f7-b0e1-f4d0f9e96ae1.png">

- Foodie-Fi has 1,000 unique customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

Question is asking for the monthly numbers of users on trial plan.
- Firstly, I extract numerical month using `DATE_PART`.
- Then, I use `TO_CHAR` to extract the string or name of the month.
- `DATE_PART` is used to extract numerical values from a date, whereas `TO_CHAR` extracts the string value (i.e. January, Wednesday)
- Filter for `plan_id = 0` for trial plans.

````sql
SELECT
  DATE_PART('month',start_date) AS month_date, -- Cast to month in numbers
  TO_CHAR(start_date, 'Month') AS month_name, -- Cast to month in month's name
  COUNT(*) AS trial_subscriptions
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY DATE_PART('month',start_date), 
  TO_CHAR(start_date, 'Month')
ORDER BY month_date;
````

**Answer:**

<img width="366" alt="image" src="https://user-images.githubusercontent.com/81607668/129826377-f4da52b6-13de-4871-be98-bf438f2ac230.png">

- March has the highest number of trial plans, whereas February has the lowest number of trial plans.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

Question is asking for the number of plans for start dates occurring on 1 Jan 2021 and after grouped by plan names.
- Filter plans with start_dates occurring on 2021–01–01 and after.
- Group and order results by plan.

_Note: Question calls for events occuring after 1 Jan 2021, however I ran the query for events in 2020 as well as I was curious with the year-on-year results._

````sql
SELECT 
  p.plan_id,
  p.plan_name,
  COUNT(*) AS events
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY p.plan_id;
````

**Answer:**

<img width="592" alt="image" src="https://user-images.githubusercontent.com/81607668/129830050-4d345585-c8c5-4346-8b3b-9f718920c54b.png">

- There were 0 customer on trial plan in 2021. Does it mean that there were no new customers in 2021, or did they jumped on basic monthly plan without going through the 7-week trial?
- We should also look at the data and look at the customer proportion for 2020 and 2021.

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

I like to write down the steps and breakdown the questions into parts.

**Steps:**
- Find the number of customers who churned.
- Find the percentage of customers who churned and round it to 1 decimal place.
- What's the churned plan_id? Filter to 4

````sql
SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 4;
````

**Answer:**

<img width="368" alt="image" src="https://user-images.githubusercontent.com/81607668/129840630-adebba8c-9219-4816-bba6-ba8119f298d9.png">

- There are 307 customers who have churned, which is 30.7% of Foodie-Fi customer base.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

In order to identify which customer churned straight after the trial plan, I rank each customer's plans using a `ROW_NUMBER`. Remember to partition by unique customer.

My understanding is that if a customer churned immediately after trial, the plan ranking would look like this.

- Trial Plan - Rank 1
- Churned - Rank 2

Using the CTE, I filtered for `plan id = 4` (churn plan) and `rank = 2` (being customers who churned immediately after trial) and find the percentage of churned customers.

````sql
-- To find ranking of the plans by customers and plans
WITH ranking AS (
SELECT 
  s.customer_id, 
  s.plan_id, 
  p.plan_name,
  -- Run a ROW_NUMBER() to rank the plans from 0 to 4
  ROW_NUMBER() OVER (
    PARTITION BY s.customer_id 
    ORDER BY s.plan_id) AS plan_rank 
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id)
  
SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),0) AS churn_percentage
FROM ranking
WHERE plan_id = 4 -- Filter to churn plan
  AND plan_rank = 2 -- Filter to rank 2 as customers who churned immediately after trial have churn plan ranked as 2
````

**Answer:**

<img width="378" alt="image" src="https://user-images.githubusercontent.com/81607668/129834269-98ab360b-985a-4c25-9d42-c89b97ba6ba8.png">

- There are 92 customers who churned straight after the initial free trial which is at 9% of entire customer base.

### 6. What is the number and percentage of customer plans after their initial free trial?

Question is asking for number and percentage of customers who converted to becoming paid customer after the trial. 

**Steps:**
- Find customer's next plan which is located in the next row using `LEAD()`. Run the `next_plan_cte` separately to view the next plan results and understand how `LEAD()` works.
- Filter for `non-null next_plan`. Why? Because a next_plan with null values means that the customer has churned. 
- Filter for `plan_id = 0` as every customer has to start from the trial plan at 0.

````sql
-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id, 1) OVER( -- Offset by 1 to retrieve the immediate row's value below 
    PARTITION BY customer_id 
    ORDER BY plan_id) as next_plan
FROM foodie_fi.subscriptions)

SELECT 
  next_plan, 
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;
````
**Answer:**

<img width="589" alt="image" src="https://user-images.githubusercontent.com/81607668/129843509-2cfb76ed-82cc-4291-a59f-a854580a115e.png">

- More than 80% of customers are on paid plans with small 3.7% on plan 3 (pro annual $199). Foodie-Fi has to strategize on their customer acquisition who would be willing to spend more.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

````sql
-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan AS(
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) as next_date
FROM foodie_fi.subscriptions
WHERE start_date <= '2020-12-31'),
-- To find breakdown of customers with existing plans on or after 31 Dec 2020
customer_breakdown AS (
  SELECT plan_id, COUNT(DISTINCT customer_id) AS customers
    FROM next_plan
    WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
      OR (next_date IS NULL AND start_date < '2020-12-31')
    GROUP BY plan_id)

SELECT plan_id, customers, 
  ROUND(100 * customers::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS percentage
FROM customer_breakdown
GROUP BY plan_id, customers
ORDER BY plan_id
````

**Answer:**

<img width="448" alt="image" src="https://user-images.githubusercontent.com/81607668/130024738-f16ad7dc-5fed-469f-9c6d-0a24453e1dcd.png">

### 8. How many customers have upgraded to an annual plan in 2020?

````sql
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM foodie_fi.subscriptions
WHERE plan_id = 3
  AND start_date <= '2020-12-31'
````

**Answer:**

<img width="160" alt="image" src="https://user-images.githubusercontent.com/81607668/129848711-3b64442a-5724-4723-bea7-e4515a8687ec.png">

- 196 customers upgraded to an annual plan in 2020.

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

````sql
-- Filter results to customers at trial plan = 0
WITH trial_plan AS 
(SELECT 
  customer_id, 
  start_date AS trial_date
FROM foodie_fi.subscriptions
WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS
(SELECT 
  customer_id, 
  start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
)

SELECT 
  ROUND(AVG(annual_date - trial_date),0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id;
````

**Answer:**

<img width="182" alt="image" src="https://user-images.githubusercontent.com/81607668/129856015-4bafa22c-b732-4c71-93d6-c9417e8556b9.png">

- On average, it takes 105 days for a customer to upragde to an annual plan from the day they join Foodie-Fi.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

````sql
-- Filter results to customers at trial plan = 0
WITH trial_plan AS 
(SELECT 
  customer_id, 
  start_date AS trial_date
FROM foodie_fi.subscriptions
WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS
(SELECT 
  customer_id, 
  start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
),
-- Sort values above in buckets of 12 with range of 30 days each
bins AS 
(SELECT 
  WIDTH_BUCKET(ap.annual_date - tp.trial_date, 0, 360, 12) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id)
  
SELECT 
  ((avg_days_to_upgrade - 1) * 30 || ' - ' || (avg_days_to_upgrade) * 30) || ' days' AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
````

**Answer:**

<img width="399" alt="image" src="https://user-images.githubusercontent.com/81607668/130019061-d2b54041-83ff-4a92-b30e-f519fb904d91.png">

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

````sql
-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan
FROM foodie_fi.subscriptions)

SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;
````

**Answer:**

<img width="115" alt="image" src="https://user-images.githubusercontent.com/81607668/130021792-6c37301f-bdf8-4d57-bbfd-ca86fc759a70.png">

- No customer has downgrade from pro monthly to basic monthly in 2020.
