# Case Study 1: Danny's Diner

## Solution

[View the complete code](https://github.com/YogeshOlla/8-Weeks-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/SQL%20Code/Case%20Study%201%20-%20Danny's%20Diner.sql).

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT customer_id, SUM(price) AS total_amount_spent
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id;
````

#### Answer:
| customer_id | total_amount_spent |
| ----------- | ------------------ |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

- Customer A, B and C spent $76, $74 and $36 respectively.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id, COUNT(DISTINCT(order_date)) AS days_visited
FROM sales
GROUP BY customer_id;
````

#### Answer:
| customer_id | days_visited |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A, B and C visited 4, 6 and 2 times respectively.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
WITH order_rank AS 
(
SELECT 
	customer_id, 
	order_date, 
	product_name AS first_item,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, order_date,first_item
)

SELECT 
	customer_id, 
	order_date,
	first_item
FROM order_rank
WHERE ranking = 1;
````

#### Answer:
| customer_id | order_date   | first_item   |
| ----------- | ------------ | ------------ |
| A           | 2021-01-01   | sushi 	    |
| A           | 2021-01-01   | curry        |
| B           | 2021-01-01   | curry        |
| C           | 2021-01-01   | ramen        |

- Customer A's first order is curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT 
	product_name, 
	COUNT(customer_id) AS No_of_purchases
FROM menu m JOIN sales s
ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY No_of_purchases DESC
LIMIT 1;
````



#### Answer:
| product_name  | No_of_purchases | 
| ----------- | ----------- |
| ramen       | 8|


- Most purchased item on the menu is ramen which is purchased 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
WITH popular_dish AS 
(
SELECT 
	customer_id, 
	product_name, 
	count(m.product_id) AS prod_count,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(m.product_id) DESC) AS RANKING
FROM sales s JOIN menu m
ON s.product_id  = m.product_id
GROUP BY customer_id, product_name
)

SELECT 
	customer_id, 
	product_name
FROM popular_dish
WHERE RANKING = 1;
````

#### Answer:
| customer_id | product_name |
| ----------- | ----------   | 
| A           | ramen        |
| B           | sushi        |
| B           | curry        |
| B           | ramen        |
| C           | ramen        |

- Customer A and C's favourite item is ramen while customer B savours all items on the menu. 

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH fist_purchase_after_member AS 
(
SELECT 
	s.customer_id, 
	product_name, 
	join_date, 
	order_date,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking
FROM sales s 
JOIN menu m ON s.product_id = m.product_id 
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
)

SELECT 
	customer_id, 
	product_name
FROM fist_purchase_after_member
WHERE ranking = 1;

````


#### Answer:
| customer_id |  product_name |
| ----------- | ------------  |
| A           |  curry        |
| B           |  sushi        |

After becoming member 
- Customer A's first order was curry.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
WITH last_purchase_before_member AS 
(
SELECT 
	s.customer_id, 
	product_name, 
	join_date, 	
	order_date,
	DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS ranking
FROM sales s 
JOIN menu m ON s.product_id = m.product_id 
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
)

SELECT 
	customer_id, 
	product_name,
	order_date
FROM last_purchase_before_member
WHERE ranking = 1;

````

#### Answer:
| customer_id |product_name |order_date  |
| ----------- | ----------  |---------- |
| A           |  sushi      |2021-01-01 | 
| A           |  curry      |2021-01-01 | 
| B           |  sushi      |2021-01-04 |

Before becoming a member 
- Customer A’s last order was sushi and curry.
- Customer B’s last order was sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT 
	s.customer_id, 
	COUNT(m.product_id) AS total_items, 
	SUM(m.price) AS amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;
````


#### Answer:
| customer_id |total_items | amount_spent |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

Before becoming a member
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
SELECT 
	customer_id,
	SUM(
		CASE
			WHEN product_name = 'sushi' THEN 20*price ELSE 10*price END
	   ) AS points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;
````


#### Answer:
| customer_id | Points | 
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for customer A, B and C are 860, 940 and 360 respectively.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
SELECT 
	s.customer_id,
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
````

#### Answer:
| Customer_id | Points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A and B are 1,370 and 820 respectively.

***