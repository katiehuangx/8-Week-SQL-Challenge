# 🐟 Case Study #6 - Clique Bait

## 👩🏻‍💻 Solution - C. Campaigns Analysis

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
*** 
  
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?
