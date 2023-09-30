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

