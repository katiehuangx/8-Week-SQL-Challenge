# 🐟 Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - B. Product Funnel Analysis

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
