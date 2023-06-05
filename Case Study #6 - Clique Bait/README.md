# Case Study #6: Clique Bait

<img src="https://user-images.githubusercontent.com/81607668/134615258-d1108e0d-0816-4cd7-a972-d45580f82352.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-6/). 

***

## Business Task
Clique Bait is an online seafood store. 

In this case study - you are required to support the founder and CEO Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

## Entity Relationship Diagram

<img width="825" alt="image" src="https://user-images.githubusercontent.com/81607668/134619326-f560a7b0-23b2-42ba-964b-95b3c8d55c76.png">

**Table: `users`**

<img width="366" alt="image" src="https://user-images.githubusercontent.com/81607668/134623074-7c51d63a-c0a4-41e0-a6fc-257e4ca3997d.png">

**Table: `events`**

<img width="849" alt="image" src="https://user-images.githubusercontent.com/81607668/134623132-dfa2acd3-60c9-4305-9bea-6b39a9403c14.png">

**Table: `event_identifier`**

<img width="273" alt="image" src="https://user-images.githubusercontent.com/81607668/134623311-1ad16fe7-36e3-45b6-9dc6-8114333cf473.png">

**Table: `page_hierarchy`**

<img width="576" alt="image" src="https://user-images.githubusercontent.com/81607668/134623202-3158ca06-6f04-4b67-91f1-e184761e885c.png">

**Table: `campaign_identifier`**

<img width="792" alt="image" src="https://user-images.githubusercontent.com/81607668/134623354-0977d67c-fc61-4e61-90ee-f24a29682a9b.png">

***

## Question and Solution

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/jmnwogTsUE8hGqkZv9H7E8/17). It would be great to work together on the questions!

If you have any questions, reach out to me on [LinkedIn](https://www.linkedin.com/in/katiehuangx/).

## 👩🏻‍💻 A. Digital Analysis

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

## 👩🏻‍💻 B. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:

1. How many times was each product viewed?
2. How many times was each product added to cart?
3. How many times was each product added to a cart but not purchased (abandoned)?
4. How many times was each product purchased?

## Planning Our Strategy

Let us visualize the output table.

| Column | Description | 
| ------- | ----------- |
| product | Name of the product |
| views | Number of views for each product |
| cart_adds | Number of cart adds for each product |
| abandoned | Number of times product was added to a cart, but not purchased |
| purchased | Number of times product was purchased |

These information would come from these 2 tables.
- `events` table - visit_id, page_id, event_type
- `page_hierarchy` table - page_id, product_category

**Solution**

- Note 1 - In `product_page_events` CTE, find page views and cart adds for individual visit ids by wrapping `SUM` around `CASE statements` so that we do not have to group the results by `event_type` as well.
- Note 2 - In `purchase_events` CTE, get only visit ids that have made purchases.
- Note 3 - In `combined_table` CTE, merge `product_page_events` and `purchase_events` using `LEFT JOIN`. Take note of the table sequence. In order to filter for visit ids with purchases, we use a `CASE statement` and where visit id is not null, it means the visit id is a purchase. 

```sql
WITH product_page_events AS ( -- Note 1
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, -- 1 for Page View
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add -- 2 for Add Cart
  FROM clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS ( -- Note 2
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 -- 3 for Purchase
),
combined_table AS ( -- Note 3
  SELECT 
    ppe.visit_id, 
    ppe.product_id, 
    ppe.product_name, 
    ppe.product_category, 
    ppe.page_view, 
    ppe.cart_add,
    CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
  FROM product_page_events AS ppe
  LEFT JOIN purchase_events AS pe
    ON ppe.visit_id = pe.visit_id
),
product_info AS (
  SELECT 
    product_name, 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_table
  GROUP BY product_id, product_name, product_category)

SELECT *
FROM product_info
ORDER BY product_id;
```

The logic behind `abandoned` column in which `cart_add = 1` where a customer adds an item into the cart, but `purchase = 0` customer did not purchase and abandoned the cart.

<kbd><img width="845" alt="image" src="https://user-images.githubusercontent.com/81607668/136649917-ff1f7daa-9fb6-4077-9196-8596cd6eb424.png"></kbd>

***

Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

**Solution**

```sql
WITH product_page_events AS ( -- Note 1
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, -- 1 for Page View
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add -- 2 for Add Cart
  FROM clique_bait.events AS e
  JOIN clique_bait.page_hierarchy AS ph
    ON e.page_id = ph.page_id
  WHERE product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category
),
purchase_events AS ( -- Note 2
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3 -- 3 for Purchase
),
combined_table AS ( -- Note 3
  SELECT 
    ppe.visit_id, 
    ppe.product_id, 
    ppe.product_name, 
    ppe.product_category, 
    ppe.page_view, 
    ppe.cart_add,
    CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
  FROM product_page_events AS ppe
  LEFT JOIN purchase_events AS pe
    ON ppe.visit_id = pe.visit_id
),
product_category AS (
  SELECT 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_table
  GROUP BY product_category)

SELECT *
FROM product_category
```

<kbd><img width="661" alt="image" src="https://user-images.githubusercontent.com/81607668/136650026-e6817dd2-ab30-4d5f-ab06-0b431f087dad.png"></kbd>

***

Use your 2 new output tables - answer the following questions:

**1. Which product had the most views, cart adds and purchases?**

**2. Which product was most likely to be abandoned?**

<kbd><img width="820" alt="Screenshot 2021-10-09 at 4 18 13 PM" src="https://user-images.githubusercontent.com/81607668/136650364-0f44ac58-8be7-4f4e-89a7-2598a24af5ce.png"></kbd>

- Oyster has the most views.
- Lobster has the most cart adds and purchases.
- Russian Caviar is most likely to be abandoned.

**3. Which product had the highest view to purchase percentage?**

```sql
SELECT 
    product_name, 
  product_category, 
  ROUND(100 * purchases/views,2) AS purchase_per_view_percentage
FROM product_info
ORDER BY purchase_per_view_percentage DESC
```

<kbd><img width="599" alt="image" src="https://user-images.githubusercontent.com/81607668/136650641-8baf945d-6dcf-4932-aa9e-0d6483325db6.png"></kbd>

- Lobster has the highest view to purchase percentage at 48.74%.

**4. What is the average conversion rate from view to cart add?**

**5. What is the average conversion rate from cart add to purchase?**

```sql
SELECT 
  ROUND(100*AVG(cart_adds/views),2) AS avg_view_to_cart_add_conversion,
  ROUND(100*AVG(purchases/cart_adds),2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_info
```

<kbd><img width="624" alt="image" src="https://user-images.githubusercontent.com/81607668/136651154-c0151b34-189b-4978-92c6-b4c81955d94b.png"></kbd>

- Average views to cart adds rate is 60.95% and average cart adds to purchases rate is 75.93%.
- Although the cart add rate is lower, but the conversion of potential customer to the sales funnel is at least 15% higher.

***

## 👩🏻‍💻 C. Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- `user_id`
- `visit_id`
- `visit_start_time`: the earliest event_time for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
  
**Solution**

Steps:
- We will merge multiple tables:
  - Using INNER JOIN for `users` and `events` table
  - Joining `campaign_identifier` table using LEFT JOIN as we want all lines that have `event_time` between `start_date` and `end_date`. 
  - Joining `page_hierachy` table using LEFT JOIN as we want all the rows in the `page_hierachy` table
- To generate earliest `visit_start_time` for each unique `visit_id`, use `MIN()` to find the 1st `visit_time`. 
- Wrap `SUM()` with CASE statement in order to find the total number of counts for `page_views`, `cart_adds`, `purchase`, ad `impression` and ad `click`.
- To get a list of products added into cart sorted by sequence, 
-   Firstly, use a CASE statement to only get cart add events. 
-   Then, use `STRING_AGG()` to separate products by comma `,` and sort the sequence using `sequence_number`.

```sql
SELECT 
  u.user_id, e.visit_id, 
  MIN(e.event_time) AS visit_start_time,
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
  SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchase,
  c.campaign_name,
  SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression, 
  SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click, 
  STRING_AGG(CASE WHEN p.product_id IS NOT NULL AND e.event_type = 2 THEN p.page_name ELSE NULL END, 
    ', ' ORDER BY e.sequence_number) AS cart_products
FROM clique_bait.users AS u
INNER JOIN clique_bait.events AS e
  ON u.cookie_id = e.cookie_id
LEFT JOIN clique_bait.campaign_identifier AS c
  ON e.event_time BETWEEN c.start_date AND c.end_date
LEFT JOIN clique_bait.page_hierarchy AS p
  ON e.page_id = p.page_id
GROUP BY u.user_id, e.visit_id, c.campaign_name;
```  

| user_id | visit_id | visit_start_time         | page_views | cart_adds | purchase | campaign_name                     | impression | click | cart_products                                                  |
|---------|----------|--------------------------|------------|-----------|----------|-----------------------------------|------------|-------|----------------------------------------------------------------|
| 1       | 02a5d5   | 2020-02-26T16:57:26.261Z | 4          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     |                                                                |
| 1       | 0826dc   | 2020-02-26T05:58:37.919Z | 1          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     |                                                                |
| 1       | 0fc437   | 2020-02-04T17:49:49.603Z | 10         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster     |
| 1       | 30b94d   | 2020-03-15T13:12:54.024Z | 9          | 7         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab |
| 1       | 41355d   | 2020-03-25T00:11:17.861Z | 6          | 1         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Lobster                                                        |

***
  
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?

