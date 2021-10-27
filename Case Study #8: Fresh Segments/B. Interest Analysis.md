# 🍅 Case Study #8 - Fresh Segments

## 📚 Solution - B. Interest Analysis

### 1. Which interests have been present in all `month_year` dates in our dataset?

Find out how many unique `month_year` in dataset.

```sql
SELECT 
  COUNT(DISTINCT month_year) AS unique_month_year_count, 
  COUNT(DISTINCT interest_id) AS unique_interest_id_count
FROM fresh_segments.interest_metrics;
```

<img width="465" alt="image" src="https://user-images.githubusercontent.com/81607668/139030151-64461d42-4215-4da1-bc6e-c701b9a8f357.png">

There are 14 distinct `month_year` dates and 1202 distinct `interest_id`s.

```sql
WITH interest_cte AS (
SELECT 
  interest_id, 
  COUNT(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
GROUP BY interest_id
)

SELECT 
  c.total_months,
  COUNT(DISTINCT c.interest_id)
FROM interest_cte c
WHERE total_months = 14
GROUP BY c.total_months
ORDER BY count DESC;
```

<img width="263" alt="image" src="https://user-images.githubusercontent.com/81607668/139029765-3403fb8b-e93d-4fde-989b-b648d62fcb3f.png">

480 interests out of 1202 interests are present in all the `month_year` dates.

### 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

Find out the point in which interests present in a particular number of months are not performing well. For example, interest id 101 only appeared in 6 months due to non or lack of clicks and interactions, so we can consider to cut the interest off. 

```sql
WITH cte_interest_months AS (
SELECT
  interest_id,
  MAX(DISTINCT month_year) AS total_months
FROM fresh_segments.interest_metrics
WHERE interest_id IS NOT NULL
GROUP BY interest_id
),
cte_interest_counts AS (
  SELECT
    total_months,
    COUNT(DISTINCT interest_id) AS interest_count
  FROM cte_interest_months
  GROUP BY total_months
)

SELECT
  total_months,
  interest_count,
  ROUND(100 * SUM(interest_count) OVER (ORDER BY total_months DESC) / -- Create running total field using cumulative values of interest count
      (SUM(INTEREST_COUNT) OVER ()),2) AS cumulative_percentage
FROM cte_interest_counts;
```

<img width="446" alt="image" src="https://user-images.githubusercontent.com/81607668/139035737-cfe32a44-5c48-4376-a9bc-96c15daf162b.png">

Interests with total months of 6 and above received a 90% and above percentage. Interests below this mark should be investigated to improve their clicks and customer interactions. 

### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective. 

### 5. If we include all of our interests regardless of their counts - how many unique interests are there for each month?
