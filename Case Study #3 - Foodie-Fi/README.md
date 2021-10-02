# 🥑 Case Study #3: Foodie-Fi

<img src="https://user-images.githubusercontent.com/81607668/129742132-8e13c136-adf2-49c4-9866-dec6be0d30f0.png" width="500" height="520" alt="image">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- Solution
  - [A. Customer Journey](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/A.%20Customer%20Journey.md)
  - [B. Data Analysis Questions](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/B.%20Data%20Analysis%20Questions.md)
  - [Complete SQL Syntax](https://github.com/katiehuangx/8-Week-SQL-Challenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/SQL%20Syntax)

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/129744449-37b3229b-80b2-4cce-b8e0-707d7f48dcec.png)

**Table 1: plans**

<img width="207" alt="image" src="https://user-images.githubusercontent.com/81607668/135704535-a82fdd2f-036a-443b-b1da-984178166f95.png">

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: subscriptions**

<img width="245" alt="image" src="https://user-images.githubusercontent.com/81607668/135704564-30250dd9-6381-490a-82cf-d15e6290cf3a.png">

Customer subscriptions show the **exact date** where their specific plan_id starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the start_date in the subscriptionstable will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn — they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

## Case Study Questions

### A. Customer Journey

View my solution [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/A.%20Customer%20Journey.md).
  
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

### B. Data Analysis Questions

View my solution [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/B.%20Data%20Analysis%20Questions.md).
  
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

### C. Challenge Payment Question
  
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

***
