/* Data with Danny
8 week SQL challenge

Week 1: Case Study #1 - Danny's Diner
Link: https://8weeksqlchallenge.com/case-study-1/
*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
	SUM(m.price) AS 'Price_spent'
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

/*
Output:
A	76
B	74
C	36
*/

-- 2. How many days has each customer visited the restaurant?

SELECT
	customer_id,
	COUNT(DISTINCT(order_date)) AS 'Days_visited'
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

/*
Output:
A	4
B	6
C	2
*/

-- 3. What was the first item from the menu purchased by each customer?

-- Here using temp tables and windows function.

WITH order_table AS (
select
	s.customer_id,
	s.order_date,
	s.product_id,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS 'order_rank',
	m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
)

SELECT 
	customer_id,
	product_name
FROM order_table
WHERE order_rank = 1
GROUP BY customer_id, product_name;

/*
Output:
A	curry
A	sushi
B	curry
C	ramen
*/

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH freq_list AS (
SELECT 
	s.product_id,
	m.product_name,
	COUNT(s.product_id) AS times_item_purchases
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
)

SELECT
	product_name,
	times_item_purchases
FROM freq_list
WHERE  times_item_purchases = (SELECT MAX(times_item_purchases) FROM freq_list);

/*
Output:
ramen	8
*/

-- This question could have been solved without using SQL CTE. Solving with that method:

