B. Data Analysis Questions

--1
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM foodie_fi.subscriptions;

--2
SELECT
  DATE_PART('month',start_date) AS month_date,
  TO_CHAR(start_date, 'Month') AS month_name,
  COUNT(*) AS trial_subscriptions
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY DATE_PART('month',start_date), 
  TO_CHAR(start_date, 'Month')
ORDER BY month_date;

--3
SELECT 
  s.plan_id,
  p.plan_name,
  SUM(
    CASE WHEN s.start_date <= '2020-12-31' THEN 1
    ELSE 0 END) AS events_2020,
  SUM(
    CASE WHEN s.start_date >= '2021-01-01' THEN 1
    ELSE 0 END) AS events_2021
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
GROUP BY s.plan_id, p.plan_name
ORDER BY s.plan_id;

--4
SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 4;

--5
WITH ranking AS 
(
SELECT 
  s.customer_id, 
  s.plan_id, 
  p.plan_name,
  ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
)
  
SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),0) AS churn_percentage
FROM ranking
WHERE plan_id = 4
  AND plan_rank = 2;

--6
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan
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

--7
WITH next_plan AS (
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) as next_date
FROM foodie_fi.subscriptions
WHERE start_date <= '2020-12-31'
),
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
ORDER BY plan_id;

--8
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM foodie_fi.subscriptions
WHERE plan_id = 3
  AND start_date <= '2020-12-31';

--9
WITH 
  trial_plan AS 
  (SELECT 
      customer_id, 
      start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
  ),
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
  
--10
WITH trial_plan AS 
  (SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
  ),
  annual_plan AS
  (SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
  ),
  bins AS 
  (SELECT 
    WIDTH_BUCKET(ap.annual_date - tp.trial_date, 0, 360, 12) AS avg_days_to_upgrade
    FROM trial_plan tp
    JOIN annual_plan ap
        ON tp.customer_id = ap.customer_id)
  
SELECT 
  ((avg_days_to_upgrade - 1)*30 || ' - ' || (avg_days_to_upgrade)*30) || ' days' AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;

--11
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(plan_id, 1) OVER(
    PARTITION BY customer_id 
    ORDER BY plan_id) as next_plan
FROM foodie_fi.subscriptions)

SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;
  
-----
