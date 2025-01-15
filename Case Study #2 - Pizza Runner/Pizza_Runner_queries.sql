-- Link to Case Study : https://8weeksqlchallenge.com/case-study-2/

CREATE TABLE runners (
  runner_id INT PRIMARY KEY,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name VARCHAR(25)
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(25)
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name VARCHAR(25)
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- All the tables has been created as well as populated.
  -- Now Let's clean the customer_orders and runners_orders table one at a time
  
  
-- Cleaning: customer_orders
SELECT * FROM customer_orders;
SELECT 
	*,
	CASE WHEN exclusions = '' OR exclusions = 'null' THEN NULL ELSE exclusions END AS exclusion_cleaned,
    CASE WHEN extras = '' OR extras = 'null' THEN NULL ELSE extras END AS extras_cleaned
FROM customer_orders;

UPDATE customer_orders
SET exclusions = CASE WHEN exclusions = '' OR exclusions = 'null' THEN NULL ELSE exclusions END;
UPDATE customer_orders
SET extras = CASE WHEN extras = '' OR extras = 'null' THEN NULL ELSE extras END;

-- Cleaning: runner_orders
SELECT * FROM runner_orders;
SELECT 
	*,
	CASE WHEN pickup_time = 'null' THEN NULL ELSE pickup_time END AS pick_time_cleaned,
    CASE WHEN distance = 'null' THEN NULL ELSE REGEXP_REPLACE(distance, '[kK][mM]', '') END AS distance_cleaned,
    CASE WHEN duration = 'null' THEN NULL ELSE REGEXP_REPLACE(duration, '[a-z]+', '') END AS duration_cleaned,
    CASE WHEN cancellation = 'null' or cancellation = '' THEN NULL ELSE cancellation END AS cancellation_cleaned
FROM runner_orders;

UPDATE runner_orders
SET
 pickup_time = CASE WHEN pickup_time = 'null' THEN NULL ELSE pickup_time END,
 distance = CASE WHEN distance = 'null' THEN NULL ELSE REGEXP_REPLACE(distance, '[kK][mM]', '') END,
 duration = CASE WHEN duration = 'null' THEN NULL ELSE REGEXP_REPLACE(duration, '[a-z]+', '') END,
 cancellation = CASE WHEN cancellation = 'null' or cancellation = '' THEN NULL ELSE cancellation END;

/*
	CASE STUDY QUESTIONS
		A. Pizza Metrics
			1. How many pizzas were ordered?
			2. How many unique customer orders were made?
			3. How many successful orders were delivered by each runner?
			4. How many of each type of pizza was delivered?
			5. How many Vegetarian and Meatlovers were ordered by each customer?
			6. What was the maximum number of pizzas delivered in a single order?
			7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
			8. How many pizzas were delivered that had both exclusions and extras?
			9. What was the total volume of pizzas ordered for each hour of the day?
			10. What was the volume of orders for each day of the week?
		
        B. Runner and Customer Experience
			1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
			2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
			3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
			4. What was the average distance travelled for each customer?
			5. What was the difference between the longest and shortest delivery times for all orders?
			6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
			7. What is the successful delivery percentage for each runner?

		C. Ingredient Optimisation
			1. What are the standard ingredients for each pizza?
			2. What was the most commonly added extra?
			3. What was the most common exclusion?
			4. Generate an order item for each record in the customers_orders table in the format of one of the following:
				Meat Lovers
				Meat Lovers - Exclude Beef
				Meat Lovers - Extra Bacon
				Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
			5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
				For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
			6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
        
		D. Pricing and Ratings
			1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
			2. What if there was an additional $1 charge for any pizza extras?
				- Add cheese is $1 extra
			3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
				how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data 
                for ratings for each successful customer order between 1 to 5.
			4. Using your newly generated table - can you join all of the information together to form a table which has the following 
				information for successful deliveries?
				customer_id
				order_id
				runner_id
				rating
				order_time
				pickup_time
				Time between order and pickup
				Delivery duration
				Average speed
				Total number of pizzas
			5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
				how much money does Pizza Runner have left over after these deliveries?
*/

-- Lets start with answering part 1
-- A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS pizzas_ordered
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT *
FROM runner_orders;
SELECT runner_id, COUNT(*) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(c.order_id) AS No_of_pizzas_delivered
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
WITH customers_orders AS (
SELECT customer_id, pizza_name
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
-- GROUP BY customer_id
)
SELECT customer_id,
SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS "Meatlovers",
SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS 'Vegetarian'
FROM customers_orders
GROUP BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id , COUNT(*) AS number_of_pizzas
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY number_of_pizzas DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END ) AS no_change,
SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS atleast_one_change  
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS pizzas_with_both
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL AND c.exclusions IS NOT NULL AND c.extras IS NOT NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT day(order_time) AS date_of_month ,hour(order_time) AS hours, COUNT(*) AS volume
FROM customer_orders
GROUP BY day(order_time), hours;

-- 10. What was the volume of orders for each day of the week?
SELECT WEEK(order_time) AS week_of_month, dayname(order_time) AS day_of_week, COUNT(*) as volume
FROM customer_orders
GROUP BY week_of_month, day_of_week;

--  B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date, 1) AS week_of_month, COUNT(runner_id) AS No_of_runners
FROM runners
GROUP BY week_of_month;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id ,AVG(MINUTE(TIMEDIFF(pickup_time,order_time))) AS avg_arrival_time
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id,COUNT(*) AS num_of_pizzas ,AVG(MINUTE(TIMEDIFF(pickup_time,order_time))) AS avg_order_prep_dur 
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.order_id
ORDER BY num_of_pizzas DESC;

-- 4. What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(CAST(distance AS signed)),2) AS avg_distance_travelled
FROM customer_orders c 
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(CAST(duration as signed)) - MIN(CAST(duration AS signed)) ) AS delivery_time_diff
FROM runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, distance/(duration/60) AS avg_speed_kmph
FROM runner_orders
WHERE cancellation IS NULL
ORDER BY 1;

-- 7. What is the successful delivery percentage for each runner?
SELECT runner_id, ROUND(SUM(CASE WHEN cancellation IS NULL THEN 1 END)*100/COUNT(*),2) as successful_delivery_percentage
FROM runner_orders
GROUP BY runner_id;



-- C. Ingredient Optimisation

-- 1. What are the standard ingredients for each pizza?
SELECT pizza_name, GROUP_CONCAT(topping_name SEPARATOR ', ') AS ingredients
FROM pizza_names pn
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt  ON FIND_IN_SET(pt.topping_id,REPLACE(toppings, ' ','')) > 0
GROUP BY pizza_name;

SELECT pizza_name, topping_id ,topping_name
FROM pizza_names pn
JOIN pizza_recipes pr ON pn.pizza_id = pr.pizza_id
JOIN pizza_toppings pt  ON FIND_IN_SET(pt.topping_id,REPLACE(toppings, ' ','')) > 0
ORDER BY pizza_name;

-- 2. What was the most commonly added extra?
WITH extras_per_order AS (
SELECT order_id,customer_id,extras,topping_name, topping_id AS extras_seperated
FROM customer_orders c
JOIN pizza_toppings ON FIND_IN_SET(topping_id, REPLACE(extras,' ','')) > 0
)
SELECT extras_seperated, topping_name, COUNT(*) AS number_of_times_added
FROM extras_per_order
GROUP BY extras_seperated, topping_name
ORDER BY number_of_times_added DESC, extras_seperated;

-- 3. What was the most common exclusion?
WITH exclusion_per_order AS (
SELECT order_id,customer_id,exclusions,topping_name, topping_id AS exclusion_seperated
FROM customer_orders c
JOIN pizza_toppings ON FIND_IN_SET(topping_id, REPLACE(exclusions,' ','')) > 0
)
SELECT exclusion_seperated, topping_name, COUNT(*) AS number_of_times_added
FROM exclusion_per_order
GROUP BY exclusion_seperated, topping_name
ORDER BY number_of_times_added DESC, exclusion_seperated;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--    Meat Lovers
--    Meat Lovers - Exclude Beef
--    Meat Lovers - Extra Bacon
--    Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH extras_list AS (
	SELECT 	order_id, 
			customer_id, 
            extras,
            GROUP_CONCAT(topping_name, ' ') AS toppings
	FROM	customer_orders c
			JOIN pizza_toppings ON FIND_IN_SET(topping_id, REPLACE(extras, ' ','')) > 0
	GROUP BY order_id, customer_id, extras
), exclusion_list AS (
	SELECT 	c.order_id, 
			customer_id, 
            exclusions,
            GROUP_CONCAT(DISTINCT topping_name, ' ') AS toppings
	FROM	customer_orders c
			JOIN pizza_toppings ON FIND_IN_SET(topping_id, REPLACE(exclusions, ' ','')) > 0
	GROUP BY c.order_id, customer_id, exclusions
)

SELECT 
	c.order_id,
    c.customer_id,
    CONCAT(p.pizza_name,
    CASE
		WHEN c.exclusions IS NOT NULL THEN CONCAT(' - Exclude ', exl.toppings) ELSE '' 
	END,
    CASE
		WHEN c.extras IS NOT NULL THEN CONCAT(' - Extras ',el.toppings) ELSE ''
	END) AS order_description
FROM customer_orders c 
JOIN pizza_names p USING(pizza_id)
LEFT JOIN extras_list el USING(order_id)
LEFT JOIN exclusion_list exl USING(order_id)
ORDER BY 1,2;

SELECT * FROM customer_orders;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--    For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- To be done

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- first find the base ingredients of each pizza per order
-- then calculate all the extra ingredients and exclusions made in each order
-- Now add the base ingredients and extras and subtract exclusion from it
WITH BaseIngredients as (
    SELECT   pt.topping_id,
             COUNT(*) as base_count 
    FROM 
		customer_orders c 
		JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id 
		JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, REPLACE(pr.toppings, ' ','')) > 0
        JOIN runner_orders r ON c.order_id = r.order_id
    GROUP BY 1
), Extras as (
    SELECT   topping_id AS extras,
             COUNT(*) as extra_count
    FROM  customer_orders c
    JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, REPLACE(extras,' ','')) > 0
    WHERE extras IS NOT NULL
    GROUP BY 1
), Exclusions AS(
	SELECT	topping_id AS exclusions,
			COUNT(*) AS exclusion_count
	FROM customer_orders c
    JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, REPLACE(exclusions, ' ','')) > 0
    WHERE exclusions IS NOT NULL
    GROUP BY 1
), TotalIngredients as (
    SELECT   topping_id,
             (COALESCE(base_count, 0) + COALESCE(extra_count, 0)- COALESCE(exclusion_count,0)) as total_count
    FROM     BaseIngredients Bi 
			 LEFT JOIN Extras e ON Bi.topping_id = e.extras 
			 LEFT JOIN Exclusions ex ON Bi.topping_id = ex.exclusions
)
SELECT   pt.topping_name,
         ti.total_count
FROM     TotalIngredients ti JOIN pizza_toppings pt ON ti.topping_id = pt.topping_id
ORDER BY 2 DESC;

-- D. Pricing and Ratings

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
	SUM(
		CASE 
			WHEN pizza_name = 'Vegetarian' THEN 10 ELSE 12 END
    ) AS total_revenue
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;

-- 2. What if there was an additional $1 charge for any pizza extras?
-- 	- Add cheese is $1 extra
SELECT 
	SUM(
		CASE 
			WHEN extras IS NULL THEN 
				CASE WHEN pizza_name = 'Vegetarian' THEN 10 ELSE 12 END
			WHEN extras IS NOT NULL THEN 
				CASE WHEN pizza_name = 'Vegetarian' THEN 10 + LENGTH(REPLACE(extras,', ','')) ELSE 12 + LENGTH(REPLACE(extras,', ','')) END
			END
	) AS total_revenue
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;

SELECT extras, LENGTH(REPLACE(extras,', ','')) FROM customer_orders;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- 	how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data 
-- 	for ratings for each successful customer order between 1 to 5.

-- Theoritical

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following 
-- 	information for successful deliveries?
-- 				customer_id
-- 				order_id
-- 				runner_id
-- 				rating
-- 				order_time
-- 				pickup_time
-- 				Time between order and pickup
-- 				Delivery duration
-- 				Average speed
-- 				Total number of pizzas

-- Theoritical
-- 	5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH total_revenue_by_pizzas AS 
(
SELECT 
	SUM(
		CASE 
			WHEN pizza_name = 'Vegetarian' THEN 10 ELSE 12 END
    ) AS total_revenue
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
), runners_cost AS
(
SELECT SUM(CAST(distance AS DECIMAL))*0.30 AS runner_salary
FROM runner_orders
WHERE cancellation IS NULL
)

SELECT (total_revenue - runner_salary) AS Profit
FROM total_revenue_by_pizzas, runners_cost;