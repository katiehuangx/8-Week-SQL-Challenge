# 🍕 Case Study #2 Pizza Runner

## Solution - C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?

### 2. What was the most commonly added extra?

```sql
WITH toppings_cte AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes)

SELECT 
  t.topping_id, pt.topping_name, 
  COUNT(t.topping_id) AS topping_count
FROM toppings_cte t
INNER JOIN pizza_runner.pizza_toppings pt
  ON t.topping_id = pt.topping_id
GROUP BY t.topping_id, pt.topping_name
ORDER BY topping_count DESC;
```

**Solution**

<img width="582" alt="image" src="https://user-images.githubusercontent.com/81607668/138807557-08909e2e-8201-4e53-87b8-f927928292fb.png">

### 3. What was the most common exclusion?

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

### 6. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

### 7. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
