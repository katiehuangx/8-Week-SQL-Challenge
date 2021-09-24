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

````sql
WITH cookie AS (
  SELECT 
    u.user_id, 
    COUNT(e.cookie_id) AS cookie_id_count
  FROM clique_bait.users AS u
  JOIN clique_bait.events AS e
    ON u.cookie_id = e.cookie_id
  GROUP BY u.user_id)

SELECT 
  ROUND(AVG(cookie_id_count),2) AS avg_cookie_id
FROM cookie;
````

<img width="138" alt="image" src="https://user-images.githubusercontent.com/81607668/134653056-db4d9c33-f484-4c2c-a21d-b34e49c87d53.png">

**3. What is the unique number of visits by all users per month?**

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

````sql
SELECT 
  100*COUNT(e.visit_id)/
    (SELECT COUNT(*) FROM clique_bait.events) AS percentage_purchase
FROM clique_bait.events AS e
JOIN clique_bait.event_identifier AS ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';
````

<img width="179" alt="image" src="https://user-images.githubusercontent.com/81607668/134654086-6f051c8e-cf26-4929-936e-1bbfd7ff0f19.png">

6. What is the percentage of visits which view the checkout page but do not have a purchase event?

**7. What are the top 3 pages by number of views?**

````sql
SELECT 
  ph.page_name, 
  COUNT(*) AS page_views
FROM clique_bait.events AS e
JOIN clique_bait.page_hierarchy AS ph
  ON e.page_id = ph.page_id
GROUP BY ph.page_name
ORDER BY page_views DESC
LIMIT 3;
````

<img width="249" alt="image" src="https://user-images.githubusercontent.com/81607668/134699614-a8b3f78c-8972-4472-bd30-19aaac4dc86b.png">

8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?

