CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date  DATE,
  product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS total_amount_spent
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) AS days_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH order_rank AS (
SELECT customer_id, order_date, product_name AS first_item,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, order_date,first_item
)
SELECT customer_id, order_date,first_item
FROM order_rank
WHERE ranking = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, COUNT(customer_id) AS No_of_purchases
FROM menu m JOIN sales s
ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY No_of_purchases DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH popular_dish AS (
SELECT customer_id, product_name, count(m.product_id) AS prod_count,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(m.product_id) DESC) AS RANKING
FROM sales s JOIN menu m
ON s.product_id  = m.product_id
GROUP BY customer_id, product_name
)
SELECT customer_id, product_name
FROM popular_dish
WHERE RANKING = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH fist_purchase_after_member AS (
SELECT s.customer_id, product_name, join_date, order_date,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking
FROM sales s 
JOIN menu m ON s.product_id = m.product_id 
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
)
SELECT customer_id, product_name
FROM fist_purchase_after_member
WHERE ranking = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH last_purchase_before_member AS (
SELECT s.customer_id, product_name, join_date, order_date,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS ranking
FROM sales s 
JOIN menu m ON s.product_id = m.product_id 
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
)
SELECT customer_id, product_name,order_date
FROM last_purchase_before_member
WHERE ranking = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(m.product_id) AS total_items, SUM(m.price) AS amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id,
SUM(
	CASE
		WHEN product_name = 'sushi' THEN 20*price ELSE 10*price END
	) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
SUM(
	CASE 
		WHEN product_name = 'sushi' OR (order_date BETWEEN join_date AND DATE(DATE(join_date) + 6)) THEN 20*price ELSE 10*price END 
	) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON mb.customer_id = s.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY customer_id
ORDER BY s.customer_id;

