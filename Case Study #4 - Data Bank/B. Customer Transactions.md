# 💵 Case Study #4 - Data Bank

## 🏦 Solution - B. Customer Transactions

1. What is the unique count and total amount for each transaction type?

SELECT 
  txn_type, 
  COUNT(*), 
  SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type

**Answer:**

<img width="479" alt="image" src="https://user-images.githubusercontent.com/81607668/130349158-acb36028-df02-472a-bd34-15856f93b2b8.png">

2. What is the average total historical deposit counts and amounts for all customers?

--Find count of each transaction type and average transaction amount for each customer
WITH deposits AS (
  SELECT 
    customer_id, 
    txn_type, 
    COUNT(*) AS txn_count, 
    AVG(txn_amount) AS avg_amount
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_type)

SELECT 
  ROUND(AVG(txn_count),0) AS avg_deposit, 
  ROUND(AVG(avg_amount),2) AS avg_amount
FROM deposits
WHERE txn_type = 'deposit';

**Answer:**

<img width="325" alt="image" src="https://user-images.githubusercontent.com/81607668/130349626-97309a3e-790b-47a9-b9bf-32e7f6f078e7.png">

- The average historical deposit count is 5 and average historical deposit amounts are (currency) 508.61.

3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
5. What is the closing balance for each customer at the end of the month?
6. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:
  - Have a negative first month balance?
  - Have a positive first month balance?
  - Increase their opening month’s positive closing balance by more than 5% in the following month?
  - Reduce their opening month’s positive closing balance by more than 5% in the following month?
  - Move from a positive balance in the first month to a negative balance in the second month?
