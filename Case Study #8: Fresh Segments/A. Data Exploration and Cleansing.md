# 🍅 Case Study #8 - Fresh Segments

## 🧼 Solution - A. Data Exploration and Cleansing

**1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month**

```sql
ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year::DATE;
```

<kbd><img width="970" alt="image" src="https://user-images.githubusercontent.com/81607668/138912360-49996d84-23e4-40a7-98a1-9a8e9341b492.png"></kbd>

**2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the `null` values appearing first?**

```sql
SELECT 
  month_year, COUNT(*)
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST;
```

<kbd><img width="291" alt="image" src="https://user-images.githubusercontent.com/81607668/138890088-7c376d99-d0dc-4a87-a605-bcbd05e12091.png"></kbd>

**3. What do you think we should do with these `null` values in the `fresh_segments.interest_metrics`?**

The `null` values appear in `_month`, `_year`, `month_year`, and `interest_id`. The corresponding values in `composition`, `index_value`, `ranking`, and `percentile_ranking` fields are not meaningful without the specific information on `interest_id` and dates. 

Before dropping the values, it would be useful to find out the percentage of `null` values.

```sql
SELECT 
  ROUND(100 * (SUM(CASE WHEN interest_id IS NULL THEN 1 END) * 1.0 /
    COUNT(*)),2) AS null_perc
FROM fresh_segments.interest_metrics
```

<kbd><img width="112" alt="image" src="https://user-images.githubusercontent.com/81607668/138892507-5b89eba8-45c7-4edf-9c05-42347f47c746.png"></kbd>

The percentage of null values is 8.36% which is less than 10%, hence I would suggest to drop all the `null` values.

```sql
DELETE FROM fresh_segments.interest_metrics
WHERE interest_id IS NULL;

-- Run again to confirm that there are no null values.
SELECT 
  ROUND(100 * (SUM(CASE WHEN interest_id IS NULL THEN 1 END) * 1.0 /
    COUNT(*)),2) AS null_perc
FROM fresh_segments.interest_metrics
```

<kbd><img width="120" alt="image" src="https://user-images.githubusercontent.com/81607668/138899920-52b8249c-ba52-4d47-b3b2-6d7c76558007.png"></kbd>

Confirmed that there are no `null` values in `fresh_segments.interest_metrics`.

**4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?**

```sql
SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id is NULL THEN 1 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id is NULL THEN 1 END) AS not_in_map
FROM fresh_segments.interest_map map
FULL OUTER JOIN fresh_segments.interest_metrics metrics
  ON metrics.interest_id = map.id;
```

<kbd><img width="617" alt="image" src="https://user-images.githubusercontent.com/81607668/138908809-72bef6fa-825e-40e5-a326-43e9bc56f24d.png"></kbd>

- There are 1,209 unique `id`s in `interest_map`.
- There are 1,202 unique `interest_id`s in `interest_metrics`.
- There are no `interest_id` that did not appear in `interest_map`. All 1,202 ids were present in the `interest_metrics` table.
- There are 7 `id`s that did not appear in `interest_metrics`. 

**5. Summarise the id values in the `fresh_segments.interest_map` by its total record count in this table**

I found the solution for this question to be strange - hence I came up with another summary of the id values too.

Original solution:

```sql 
SELECT COUNT(*)
FROM fresh_segments.interest_map
```

<kbd><img width="97" alt="image" src="https://user-images.githubusercontent.com/81607668/138911356-34884a1e-2c84-4769-b3cc-7916776a044c.png"></kbd>

My solution:

```sql
SELECT 
  id, 
  interest_name, 
  COUNT(*)
FROM fresh_segments.interest_map map
JOIN fresh_segments.interest_metrics metrics
  ON map.id = metrics.interest_id
GROUP BY id, interest_name
ORDER BY count DESC, id;
```

<kbd><img width="589" alt="image" src="https://user-images.githubusercontent.com/81607668/138911619-24d6e402-d4f0-48cb-8fa6-9ebecb035e90.png"></kbd>

**6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where 'interest_id = 21246' in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the id column.**



**7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?**

***
