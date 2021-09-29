# 🐟 Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - A. Digital Analysis

**1. How many users are there?**

````sql
SELECT 
  COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;
````

<img width="104" alt="image" src="https://user-images.githubusercontent.com/81607668/134652899-1abcdeeb-f6ec-44e7-810c-be2dabfb1244.png">

**2. How many cookies does each user have on average?**

This was one of those tricky questions that seems easy, but the solution is not as clear as it seems. 

- Question is asking the number of cookies each user have on average. That's calling us to either use a `DISTINCT` or `GROUP BY` in order to ensure the count of cookies belonging to each user is unique.
- Next, round up the average cookie count with 0 decimal point as it will not make sense for the cookie to be in fractional form. 

````sql
WITH cookie AS (
  SELECT 
    user_id, 
    COUNT(cookie_id) AS cookie_id_count
  FROM clique_bait.users
  GROUP BY user_id)

SELECT 
  ROUND(AVG(cookie_id_count),0) AS avg_cookie_id
FROM cookie;
````

<img width="137" alt="image" src="https://user-images.githubusercontent.com/81607668/135193654-424d276f-fc66-4a1b-acee-b6a46f5c552e.png">

**3. What is the unique number of visits by all users per month?**
- First, extract numerical month from `event_time` so that we can group the data by month.
- Unique is a keyword to use `DISTINCT`.

````sql
SELECT 
  EXTRACT(MONTH FROM event_time) as month, 
  COUNT(DISTINCT visit_id) AS unique_visit_count
FROM clique_bait.events
GROUP BY EXTRACT(MONTH FROM event_time);
````

<img width="258" alt="image" src="https://user-images.githubusercontent.com/81607668/134653147-82b7f9d3-c8ec-4fb9-ac7b-cb036ae1d877.png">

**4. What is the number of events for each event type?**

````sql
SELECT 
  event_type, 
  COUNT(*) AS event_count
FROM clique_bait.events
GROUP BY event_type
ORDER BY event_type;
````

<img width="276" alt="image" src="https://user-images.githubusercontent.com/81607668/134653476-6e456622-1118-438f-b83d-3b1873dd01e8.png">

**5. What is the percentage of visits which have a purchase event?**
- Join the events and events_identifier table and filter by `Purchase` event only. 
- As the data is now filtered to having `Purchase` events only, counting the distinct visit IDs would give you the number of purchase events.
- Then, divide the number of purchase events with a subquery of total number of distinct visits from the `events` table.

````sql
SELECT 
  100 * COUNT(DISTINCT e.visit_id)/
    (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS percentage_purchase
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';
````

<img width="182" alt="image" src="https://user-images.githubusercontent.com/81607668/135199118-9d0a6d64-f95e-4b75-aab4-0fbd515235f6.png">

**6. What is the percentage of visits which view the checkout page but do not have a purchase event?**
The strategy to answer this question is to breakdown the question into 2 parts.

Part 1: Create a `CTE` and using `CASE statements`, find the `MAX()` of:
- `event_type` = 1 (Page View) and `page_id` = 12 (Checkout), and assign "1" to these events. These events are when user viewed the checkout page.
- `event_type` = 3 (Purchase) and assign "1" to these events. These events signifies users who made a purchase.

We're using MAX() because we do not want to group the results by `event_type` and `page_id`. Since the max score is "1", it would mean "Give me the max score for each event".

Part 2: Using the table we have created, find the percentage of visits which view checkout page.

````sql
WITH checkout_purchase AS (
SELECT 
  visit_id,
  MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
  MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM clique_bait.events
GROUP BY visit_id)

SELECT 
  ROUND(100 * (1-(SUM(purchase)::numeric/SUM(checkout))),2) AS percentage_checkout_view_with_no_purchase
FROM checkout_purchase
````

<img width="355" alt="image" src="https://user-images.githubusercontent.com/81607668/135203110-b284a131-88e2-4be8-94a6-63ba8cd74cf8.png">

**7. What are the top 3 pages by number of views?**

````sql
SELECT 
  ph.page_name, 
  COUNT(*) AS page_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE e.event_type = 1 -- "Page View"
GROUP BY ph.page_name
ORDER BY page_views DESC -- Order by descending to retrieve highest to lowest number of views
LIMIT 3; -- Limit results to 3 to find the top 3
````

**8. What is the number of views and cart adds for each product category?**

````sql
SELECT 
  ph.product_category, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY page_views DESC;
````

<img width="425" alt="image" src="https://user-images.githubusercontent.com/81607668/135204259-565b60b9-b6d9-4ff8-86fc-5d7b01b98726.png">

**9. What are the top 3 products by purchases?**


***

Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/B.%20Product%20Funnel%20Analysis.md) for solutions to **B. Product Funnel Analysis**!
