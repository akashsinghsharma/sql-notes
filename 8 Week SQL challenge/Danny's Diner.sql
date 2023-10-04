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
  FROM 
    sales s 
    JOIN menu m ON s.product_id = m.product_id 
  GROUP BY 
    s.product_id, 
    m.product_name
) 
SELECT 
  product_name, 
  times_item_purchases 
FROM 
  freq_list 
WHERE 
  times_item_purchases = (
    SELECT 
      MAX(times_item_purchases) 
    FROM 
      freq_list
  );

/*
Output:
ramen	8
*/

-- This question could have been solved without using SQL CTE. Solving with that method:

SELECT 
  TOP 1 m.product_name, 
  COUNT(s.product_id) AS 'freq' 
FROM 
  sales s 
  JOIN menu m ON s.product_id = m.product_id 
GROUP BY 
  s.product_id, 
  m.product_name 
ORDER BY 
  freq DESC;

-- Note that in MYSQL, TOP function is not available so use LIMIT while using MYSQL.

-- 5. Which item was the most popular for each customer?

WITH order_count AS (
  SELECT 
    customer_id, 
    product_id, 
    COUNT(product_id) AS 'order_count', 
    DENSE_RANK() OVER(
      PARTITION BY customer_id 
      ORDER BY 
        COUNT(product_id) DESC
    ) AS 'rank' 
  FROM 
    sales 
  GROUP BY 
    customer_id, 
    product_id
) 
SELECT 
  o.customer_id, 
  m.product_name, 
  o.order_count 
FROM 
  order_count AS o 
  JOIN menu AS m ON o.product_id = m.product_id 
WHERE 
  rank = 1;

/*
Output:
A	ramen	3
B	sushi	2
B	curry	2
B	ramen	2
C	ramen	3
*/

-- 6. Which item was purchased first by the customer after they became a member?

-- To solve this que, I am making an assumption that we are fetching records of all the items ordered after they became member, not just one item.
-- To fetch record of one item only, we can use row_number() in the windows function, I used dense_rank() instead.

WITH order_rank AS (
SELECT
	s.customer_id,
	s.order_date,
	s.product_id,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS 'order_rank'
FROM 
	sales s
	JOIN members mem ON mem.customer_id = s.customer_id
	AND s.order_date > mem.join_date
)

SELECT
	o.customer_id,
	o.order_date,
	m.product_name
FROM order_rank o
JOIN menu m
ON m.product_id = o.product_id
WHERE order_rank = 1;

/*
Output:
A	2021-01-10	ramen
B	2021-01-11	sushi
*/

-- 7. Which item was purchased just before the customer became a member?

WITH temp AS (
  SELECT 
    s.customer_id, 
    s.product_id, 
    s.order_date, 
    ROW_NUMBER() OVER(
      PARTITION BY s.customer_id 
      ORDER BY 
        s.order_date DESC
    ) AS 'before_rank' 
  FROM 
    sales s 
    JOIN members m ON m.customer_id = s.customer_id 
    AND s.order_date < m.join_date
) 
SELECT 
  t.customer_id, 
  m.product_name 
FROM 
  temp t 
  JOIN menu m ON t.product_id = m.product_id 
WHERE 
  t.before_rank = 1;

/*
Output:
A	sushi
B	sushi
*/

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
  s.customer_id, 
  COUNT(s.product_id) AS 'total_items', 
  SUM(m.price) AS 'total_price' 
FROM 
  sales s 
  JOIN menu m ON m.product_id = s.product_id 
  JOIN members mem on s.customer_id = mem.customer_id 
  AND s.order_date < mem.join_date 
GROUP BY 
  s.customer_id;

/*
Output:
A	2	25
B	3	40
*/
