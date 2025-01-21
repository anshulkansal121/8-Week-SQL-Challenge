-- Explore the Tables:
SELECT* FROM plans;

SELECT * FROM subscriptions;

/*
CASE STUDY QUESTIONS: 
A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

B. Data Analysis Questions
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

C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions 
table with the following requirements:
	- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
	- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
	- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
	- once a customer churns they will no longer make payments

D. Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, 
but answers that make sense from both a technical and a business perspective make an amazing impression!

1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

*/


-- B. Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS No_of_customers
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
	YEAR(start_date) AS "YEAR", 
	MONTH(start_date) AS "MONTH", 
	MONTHNAME(start_date) AS "MONTHNAME", 
    COUNT(customer_id) AS customers_subscribed
FROM subscriptions
WHERE plan_id = 0
GROUP BY YEAR(start_date), MONTH(start_date), MONTHNAME(start_date)
ORDER BY 1,2;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT plan_id,plan_name, COUNT(*) AS event
FROM subscriptions s
JOIN plans p USING(plan_id)
WHERE YEAR(start_date) > '2020'
GROUP BY plan_id,plan_name
ORDER BY 1;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
	COUNT(customer_id) AS customers_churned,
    ROUND(COUNT(customer_id)*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percent_customer_churned
FROM subscriptions
WHERE plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT 
	COUNT(s2.customer_id) AS customers_churned, 
	ROUND((cOUNT(s2.customer_id)*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions)),0) AS percent_customer_churned
FROM subscriptions s1 JOIN subscriptions s2 USING (customer_id)
WHERE s1.plan_id = 0 AND s2.plan_id = 4 AND s2.start_date <= DATE_ADD(s1.start_date, INTERVAL 7 DAY); 

-- Another Approach
WITH subscription_rank AS (
SELECT 
	customer_id, plan_id,
    plan_name,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS ranking
FROM subscriptions JOIN plans USING(plan_id)
)

SELECT *
FROM subscription_rank
WHERE plan_id = 4 AND ranking =2;

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH subscriptions_ranked AS 
(
	SELECT 
		customer_id, 
		plan_id, 
        plan_name,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS ranking
	FROM subscriptions s
    JOIN plans p USING(plan_id)
)
SELECT plan_name, COUNT(customer_id) AS customer_count, ROUND((COUNT(customer_id))*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),2) AS percentage
FROM subscriptions_ranked
WHERE ranking = 2
GROUP BY plan_name
ORDER BY customer_count DESC; 
    
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- SELECT plan_id, plan_name, COUNT(*)
-- FROM subscriptions s
-- JOIN plans p USING(plan_id)
-- WHERE start_date <='2020-12-31'
-- GROUP BY plan_id, plan_name;

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(customer_id) AS customers_with_annual_plans
FROM subscriptions
WHERE YEAR(start_date) = '2020' AND plan_id = 3;

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
SELECT ROUND(AVG(DATEDIFF(s2.start_date,s1.start_date)),2) AS avg_days
FROM subscriptions s1
JOIN subscriptions s2 ON s1.customer_id = s2.customer_id
AND s1.plan_id + 3 = s2.plan_id
WHERE s2.plan_id = 3; 

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH days_breakdown AS (
	SELECT
		CONCAT(
			FLOOR(DATEDIFF(s2.start_date,s1.start_date) / 30) * 30 + 1, 
			'-', 
			FLOOR(DATEDIFF(s2.start_date,s1.start_date) / 30) * 30 + 30, 
			' days'
		) AS breakdown,
		ROUND((DATEDIFF(s2.start_date,s1.start_date)),2) AS avg_days
	FROM subscriptions s1
	JOIN subscriptions s2 ON s1.customer_id = s2.customer_id
	AND s1.plan_id + 3 = s2.plan_id
	WHERE s2.plan_id = 3
)
SELECT breakdown, ROUND(AVG(avg_days)) AS avg_days
FROM days_breakdown
GROUP BY breakdown;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT 
	COUNT(*) as customer_downgraded
FROM subscriptions s1
JOIN subscriptions s2 ON s1.customer_id = s2.customer_id
AND s1.plan_id - 1 = s2.plan_id
WHERE s2.plan_id = 1 AND 
	  YEAR(s2.start_date) = '2020' AND 
	  YEAR(s1.start_date) = '2020' AND 
      s2.start_date > s1.start_date;
