# 🥑 Case Study #3: Foodie-Fi

<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

**Table 1: `plans`**

<img width="207" alt="image" src="https://user-images.githubusercontent.com/81607668/135704535-a82fdd2f-036a-443b-b1da-984178166f95.png">

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

<img width="245" alt="image" src="https://user-images.githubusercontent.com/81607668/135704564-30250dd9-6381-490a-82cf-d15e6290cf3a.png">

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

## Question and Solution

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/rHJhRrXy5hbVBNJ6F6b9gJ/16). It would be great to work together on the questions!

Additionally, I have also published this case study on [Medium](https://medium.com/analytics-vidhya/8-week-sql-challenge-case-study-3-foodie-fi-3d8497376ea9?sk=579afc01c30aa6149d85050f8a46ddef).

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/katiehuangx/).

## 🎞️ A. Customer Journey

Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

**Table: Sample of `subscriptions` table**

<img width="261" alt="Screenshot 2021-08-17 at 11 36 10 PM" src="https://user-images.githubusercontent.com/81607668/129756709-75919d79-e1cd-4187-a129-bdf90a65e196.png">

**Answer:**

```sql
SELECT
  sub.customer_id,
  plans.plan_id, 
  plans.plan_name,  
  sub.start_date
FROM foodie_fi.plans
JOIN foodie_fi.subscriptions AS sub
  ON plans.plan_id = sub.plan_id
WHERE sub.customer_id IN (1,2,11,13,15,16,18,19);
```

<img width="556" alt="image" src="https://user-images.githubusercontent.com/81607668/129758340-b7cd527c-31f3-4f33-8d99-5b0a4baab378.png">

Based on the results above, I have selected three customers to focus on and will now share their onboarding journey.

_(Refer to the table below)_

Customer 1: This customer initiated their journey by starting the free trial on 1 Aug 2020. After the trial period ended, on 8 Aug 2020, they subscribed to the basic monthly plan.

<img width="560" alt="image" src="https://user-images.githubusercontent.com/81607668/129757897-df606bb6-aeb8-4235-8244-d61a3952a84a.png">

Customer 13: The onboarding journey for this customer began with a free trial on 15 Dec 2020. Following the trial period, on 22 Dec 2020, they subscribed to the basic monthly plan. After three months, on 29 Mar 2021, they upgraded to the pro monthly plan.

<img width="512" alt="image" src="https://user-images.githubusercontent.com/81607668/129761134-7fa840f5-673e-4ec6-8831-e3971c1fcd50.png">

Customer 15: Initially, this customer commenced their onboarding journey with a free trial on 17 Mar 2020. Once the trial ended, on 24 Mar 2020, they upgraded to the pro monthly plan. However, the following month, on 29 Apr 2020, the customer decided to terminate their subscription and subsequently churned until the paid subscription ends. 

<img width="549" alt="image" src="https://user-images.githubusercontent.com/81607668/129761434-39009802-c813-437d-a292-ddd26ac8ac29.png">

***

## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

To determine the count of unique customers for Foodie-Fi, I utilize the `COUNT()` function wrapped around `DISTINCT`.

```sql
SELECT COUNT(DISTINCT customer_id) AS num_of_customers
FROM foodie_fi.subscriptions;
```

**Answer:**

<img width="159" alt="image" src="https://user-images.githubusercontent.com/81607668/129764903-bb0480aa-bf92-46f7-b0e1-f4d0f9e96ae1.png">

- Foodie-Fi has 1,000 unique customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

In other words, the question is asking for the monthly count of users on the trial plan subscription.
- To start, extract the numerical value of month from `start_date` column using the `DATE_PART()` function, specifying the 'month' part of a date. 
- Filter the results to retrieve only users with trial plan subscriptions (`plan_id = 0). 

```sql
SELECT
  DATE_PART('month', start_date) AS month_date, -- Cast start_date as month in numerical format
  COUNT(sub.customer_id) AS trial_plan_subscriptions
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 0 -- Trial plan ID is 0
GROUP BY DATE_PART('month',start_date)
ORDER BY month_date;
```

**Answer:**

<img width="366" alt="image" src="https://user-images.githubusercontent.com/81607668/129826377-f4da52b6-13de-4871-be98-bf438f2ac230.png">

Among all the months, March has the highest number of trial plans, while February has the lowest number of trial plans.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

To put it simply, we have to determine the count of plans with start dates on or after 1 January 2021 grouped by plan names. 
1. Filter plans based on their start dates by including only the plans occurring on or after January 1, 2021.
2. Calculate the number of customers as the number of events. 
3. Group results based on the plan names. For better readability, order results in ascending order of the plan ID. 

````sql
SELECT 
  plans.plan_id,
  plans.plan_name,
  COUNT(sub.customer_id) AS num_of_events
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans
  ON sub.plan_id = plans.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY plans.plan_id, plans.plan_name
ORDER BY plans.plan_id;
````

**Answer:**

| plan_id | plan_name     | num_of_events |
| ------- | ------------- | ------------- |
| 1       | basic monthly | 8             |
| 2       | pro monthly   | 60            |
| 3       | pro annual    | 63            |
| 4       | churn         | 71            |

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Let's analyze the question:
- First, we need to determine
  - The number of customers who have churned, meaning those who have discontinued their subscription.
  - The total number of customers, including both active and churned ones.

- To calculate the churn rate, we divide the number of churned customers by the total number of customers. The result should be rounded to one decimal place.

```sql
SELECT
  COUNT(DISTINCT sub.customer_id) AS churned_customers,
  ROUND(100.0 * COUNT(sub.customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    	FROM foodie_fi.subscriptions)
  ,1) AS churn_percentage
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans
  ON sub.plan_id = plans.plan_id
WHERE plans.plan_id = 4; -- Filter results to customers with churn plan only
```

**Answer:**

<img width="368" alt="image" src="https://user-images.githubusercontent.com/81607668/129840630-adebba8c-9219-4816-bba6-ba8119f298d9.png">

- Out of the total customer base of Foodie-Fi, 307 customers have churned. This represents approximately 30.7% of the overall customer count.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

Within a CTE called `ranked_cte`, determine which customers churned immediately after the trial plan by utilizing `ROW_NUMBER()` function to assign rankings to each customer's plans. 

In this scenario, if a customer churned right after the trial plan, the plan rankings would appear as follows:
- Trial Plan - Rank 1
- Churned - Rank 2

In the outer query:
- Apply 2 conditions in the WHERE clause:
  - Filter `plan_id = 4`. 
  - Filter for customers who have churned immediately after their trial with `row_num = 2`.
- Count the number of customers who have churned immediately after their trial period using a `CASE` statement by checking if the row number is 2 (`row_num = 2`) and the plan name is 'churn' (`plan_name = 'churn'`). 
- Calculate the churn percentage by dividing the `churned_customers` count by the total count of distinct customer IDs in the `subscriptions` table. Round percentage to a whole number.

```sql
WITH ranked_cte AS (
  SELECT 
    sub.customer_id, 
    plans.plan_id, 
	  ROW_NUMBER() OVER (
      PARTITION BY sub.customer_id 
      ORDER BY sub.start_date) AS row_num
  FROM foodie_fi.subscriptions AS sub
  JOIN foodie_fi.plans 
    ON sub.plan_id = plans.plan_id
)
  
SELECT 
	COUNT(CASE 
    WHEN row_num = 2 AND plan_name = 'churn' THEN 1 
    ELSE 0 END) AS churned_customers,
	ROUND(100.0 * COUNT(
    CASE 
      WHEN row_num = 2 AND plan_name = 'churn' THEN 1 
      ELSE 0 END) 
	  / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ) AS churn_percentage
FROM ranked_cte
WHERE plan_id = 4 -- Filter to churn plan.
  AND row_num = 2; -- Customers who have churned immediately after trial have churn plan ranked as 2.
```

Here's another solution using the `LEAD()` window function:
```sql
WITH ranked_cte AS (
  SELECT 
    sub.customer_id,  
    plans.plan_name, 
	  LEAD(plans.plan_name) OVER ( 
      PARTITION BY sub.customer_id
      ORDER BY sub.start_date) AS next_plan
  FROM foodie_fi.subscriptions AS sub
  JOIN foodie_fi.plans 
    ON sub.plan_id = plans.plan_id
)
  
SELECT 
  COUNT(customer_id) AS churned_customers,
  ROUND(100.0 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ) AS churn_percentage
FROM ranked_cte
WHERE plan_name = 'trial' 
  AND next_plan = 'churn;
```

**Answer:**

<img width="378" alt="image" src="https://user-images.githubusercontent.com/81607668/129834269-98ab360b-985a-4c25-9d42-c89b97ba6ba8.png">

- A total of 92 customers churned immediately after the initial free trial period, representing approximately 9% of the entire customer base.

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
WITH next_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    LEAD(plan_id) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) as next_plan_id
  FROM foodie_fi.subscriptions
)

SELECT 
  next_plan_id AS plan_id, 
  COUNT(customer_id) AS converted_customers,
  ROUND(100 * 
    COUNT(customer_id)::NUMERIC 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ,1) AS conversion_percentage
FROM next_plans
WHERE next_plan_id IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan_id
ORDER BY next_plan_id;
```

**Answer:**

| plan_id | converted_customers | conversion_percentage |
| ------- | ------------------- | --------------------- |
| 1       | 546                 | 54.6                  |
| 2       | 325                 | 32.5                  |
| 3       | 37                  | 3.7                   |
| 4       | 92                  | 9.2                   |

- More than 80% of Foodie-Fi's customers are on paid plans with a majority opting for Plans 1 and 2. 
- There is potential for improvement in customer acquisition for Plan 3 as only a small percentage of customers are choosing this higher-priced plan.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

In the cte called `next_dates`, we begin by filtering the results to include only the plans with start dates on or before '2020-12-31'. To identify the next start date for each plan, we utilize the `LEAD()` window function.

In the outer query,  we filter the results where the `next_date` is NULL. This step helps us identify the most recent plan that each customer subscribed to as of '2020-12-31'. 

Lastly, we perform calculations to determine the total count of customers and the percentage of customers associated with each trial plan. 

```sql
WITH next_dates AS (
  SELECT
    customer_id,
    plan_id,
  	start_date,
    LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS next_date
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
)

SELECT
	plan_id, 
	COUNT(DISTINCT customer_id) AS customers,
  ROUND(100.0 * 
    COUNT(DISTINCT customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ,1) AS percentage
FROM next_dates
WHERE next_date IS NULL
GROUP BY plan_id;
```

**Answer:**

<img width="448" alt="image" src="https://user-images.githubusercontent.com/81607668/130024738-f16ad7dc-5fed-469f-9c6d-0a24453e1dcd.png">

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(DISTINCT customer_id) AS num_of_customers
FROM foodie_fi.subscriptions
WHERE plan_id = 3
  AND start_date <= '2020-12-31';
```

**Answer:**

<img width="160" alt="image" src="https://user-images.githubusercontent.com/81607668/129848711-3b64442a-5724-4723-bea7-e4515a8687ec.png">

- 196 customers have upgraded to an annual plan in 2020.

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

This question is straightforward and the query provided is self-explanatory. 

````sql
WITH trial_plan AS (
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
), annual_plan AS (
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
)
-- Find the average of the differences between the start date of a trial plan and a pro annual plan.
SELECT 
  ROUND(
    AVG(
      annual.annual_date - trial.trial_date)
  ,0) AS avg_days_to_upgrade
FROM trial_plan AS trial
JOIN annual_plan AS annual
  ON trial.customer_id = annual.customer_id;
````

**Answer:**

<img width="182" alt="image" src="https://user-images.githubusercontent.com/81607668/129856015-4bafa22c-b732-4c71-93d6-c9417e8556b9.png">

- On average, customers take approximately 105 days from the day they join Foodie-Fi to upgrade to an annual plan.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

To understand how the `WIDTH_BUCKET()` function works in creating buckets of 30-day periods, you can refer to this [StackOverflow](https://stackoverflow.com/questions/50518548/creating-a-bin-column-in-postgres-to-check-an-integer-and-return-a-string) answer.

```sql
WITH trial_plan AS (
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
), annual_plan AS (
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
), bins AS (
-- bins CTE: Put customers in 30-day buckets based on the average number of days taken to upgrade to a pro annual plan.
  SELECT 
    WIDTH_BUCKET(annual.annual_date - trial.trial_date, 0, 365, 12) AS avg_days_to_upgrade
  FROM trial_plan AS trial
  JOIN annual_plan AS annual
    ON trial.customer_id = annual.customer_id
)
  
SELECT 
  ((avg_days_to_upgrade - 1) * 30 || ' - ' || avg_days_to_upgrade * 30 || ' days') AS bucket, 
  COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
```

**Answer:**

| bucket         | num_of_customers |
| -------------- | ---------------- |
| 0 - 30 days    | 49               |
| 30 - 60 days   | 24               |
| 60 - 90 days   | 35               |
| 90 - 120 days  | 35               |
| 120 - 150 days | 43               |
| 150 - 180 days | 37               |
| 180 - 210 days | 24               |
| 210 - 240 days | 4                |
| 240 - 270 days | 4                |
| 270 - 300 days | 1                |
| 300 - 330 days | 1                |
| 330 - 360 days | 1                |

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH ranked_cte AS (
  SELECT 
    sub.customer_id,  
  	plans.plan_id,
    plans.plan_name, 
	  LEAD(plans.plan_id) OVER ( 
      PARTITION BY sub.customer_id
      ORDER BY sub.start_date) AS next_plan_id
  FROM foodie_fi.subscriptions AS sub
  JOIN foodie_fi.plans 
    ON sub.plan_id = plans.plan_id
 WHERE DATE_PART('year', start_date) = 2020
)
  
SELECT 
  COUNT(customer_id) AS churned_customers
FROM ranked_cte
WHERE plan_id = 2
  AND next_plan_id = 1;
```

**Answer:**

In 2020, there were no instances where customers downgraded from a pro monthly plan to a basic monthly plan.

***
