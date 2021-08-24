## Case Study #4: Data Bank

<img src="https://user-images.githubusercontent.com/81607668/130343294-a8dcceb7-b6c3-4006-8ad2-fab2f6905258.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- Solution
  - [A. Customer Nodes Exploration](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/A.%20Customer%20Nodes%20Exploration.md)
  - [B. Customer Transactions](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/B.%20Customer%20Transactions.md)
  - [Complete SQL Syntax](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/SQL%20Syntax/Complete%20SQL%20solution.sql)

***

## Business Task
Danny launched a new initiative, Data Bank which runs **banking activities** and also acts as the world’s most secure distributed **data storage platform**!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. 

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram

<img width="631" alt="image" src="https://user-images.githubusercontent.com/81607668/130343339-8c9ff915-c88c-4942-9175-9999da78542c.png">

**Table 1: Regions**

This regions table contains the region_id and their respective region_name values.

<img width="176" alt="image" src="https://user-images.githubusercontent.com/81607668/130551759-28cb434f-5cae-4832-a35f-0e2ce14c8811.png">

**Table 2: Customer Nodes**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

<img width="412" alt="image" src="https://user-images.githubusercontent.com/81607668/130551806-90a22446-4133-45b5-927c-b5dd918f1fa5.png">

**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

<img width="343" alt="image" src="https://user-images.githubusercontent.com/81607668/130551879-2d6dfc1f-bb74-4ef0-aed6-42c831281760.png">

***

## Case Study Questions

### A. Customer Nodes Exploration

View my solution [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/A.%20Customer%20Nodes%20Exploration.md).

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

### B. Customer Transactions

View my solution [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/B.%20Customer%20Transactions.md).
  
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:
  - Have a negative first month balance?
  - Have a positive first month balance?
  - Increase their opening month’s positive closing balance by more than 5% in the following month?
  - Reduce their opening month’s positive closing balance by more than 5% in the following month?
  - Move from a positive balance in the first month to a negative balance in the second month?
  
***

Do give me a 🌟 if you like what you're reading. Thank you! 🙆🏻‍♀️
