# 🥑 Case Study #3 - Foodie-Fi

## 🎞 Solution - A. Customer Journey

Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

<img width="261" alt="Screenshot 2021-08-17 at 11 36 10 PM" src="https://user-images.githubusercontent.com/81607668/129756709-75919d79-e1cd-4187-a129-bdf90a65e196.png">

**Answer:**

````sql
SELECT
  s.customer_id,f.plan_id, f.plan_name,  s.start_date
FROM foodie_fi.plans f
JOIN foodie_fi.subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19)
````

<img width="556" alt="image" src="https://user-images.githubusercontent.com/81607668/129758340-b7cd527c-31f3-4f33-8d99-5b0a4baab378.png">

From the sample results, I will choose 3 customers and write about their onboarding journey.

<img width="560" alt="image" src="https://user-images.githubusercontent.com/81607668/129757897-df606bb6-aeb8-4235-8244-d61a3952a84a.png">

Customer 1 started the free trial on 1 Aug 2020 and subsequently subscribed to the basic monthly plan on 8 Aug 2020 after the 7-days trial has ended.

<img width="512" alt="image" src="https://user-images.githubusercontent.com/81607668/129761134-7fa840f5-673e-4ec6-8831-e3971c1fcd50.png">

Customer 13 started the free trial on 15 Dec 2020, then subscribed to the basic monthly plan on 22 Dec 2020. 3 months later on 29 Mar 2021, customer upgraded to the pro monthly plan.

<img width="549" alt="image" src="https://user-images.githubusercontent.com/81607668/129761434-39009802-c813-437d-a292-ddd26ac8ac29.png">

Customer 15 commenced free trial on 17 Mar 2020, then upgraded to pro monthly plan on 24 Mar 2020 after the trial ended. In the following month on 29 Apr 2020, the customer terminated subscription and churned until the paid subscription ended on 24/25 May 2020.

***

Click here for [solution](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/B.%20Data%20Analysis%20Questions.md) to **B. Data Analysis Questions**! 🙌🏻
