SELECT * FROM pizza_db.pizza_sales;

-- DATA PREPROCESSING --
UPDATE pizza_sales
SET order_date= STR_TO_DATE(order_date,"%Y-%m-%d");

UPDATE pizza_sales
SET order_time = STR_TO_DATE(order_time, '%H:%i:%s');

ALTER TABLE pizza_sales
ADD COLUMN ingredients_count INT;

UPDATE pizza_sales
SET ingredients_count=
	CHAR_LENGTH(pizza_ingredients)-
    CHAR_LENGTH(REPLACE(pizza_ingredients,",",""))
    +1;

ALTER TABLE pizza_sales
ADD COLUMN  day_parts VARCHAR(20) AFTER order_time;
UPDATE pizza_sales
SET day_parts= CASE
   WHEN order_time BETWEEN "09:00:00" AND "12:00:00" THEN "morning"
   WHEN order_time BETWEEN "12:00:00" AND "16:00:00" THEN "afternoon"
   WHEN order_time BETWEEN "16:00:00" AND "20:00:00" THEN "evening"
   ELSE "night"
   END;
   
ALTER TABLE pizza_sales
ADD COLUMN cheese VARCHAR(25) AFTER ingredients_count,
ADD COLUMN sauce VARCHAR(25) AFTER cheese ;
UPDATE pizza_sales
SET cheese = CASE
                WHEN pizza_ingredients LIKE "%cheese%" THEN "with_cheese"
                ELSE "without_cheese"
            END,
    sauce = CASE
                WHEN pizza_ingredients LIKE "%Sauce%" THEN "with_sauce"
                ELSE "without_sauce"
            END
                

  
-- cte --
WITH revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales),
      total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales)

-- DATA ANALYSIS --
-- total revenue generated --
SELECT ROUND(SUM(total_price),2) AS "Total Revenue" FROM pizza_sales;

-- total orders placed --
SELECT COUNT(DISTINCT order_id) AS "Total Orders" FROM pizza_sales;

-- total pizzas sold --
SELECT SUM(quantity) AS "Total Pizzas Sold" FROM pizza_sales;

-- average order value --
SELECT ROUND(SUM(total_price)/COUNT(DISTINCT order_id),2) AS "Average Order Value (AOV)" FROM pizza_sales;

-- average pizzas per order -- 
SELECT FLOOR(SUM(quantity)/COUNT(DISTINCT order_id)) AS "Average Pizzas Per Order" FROM pizza_sales;

-- daily trend for total orders --
SELECT DAYNAME(order_date) AS "Day",COUNT(DISTINCT order_id) AS "Orders Count" FROM pizza_sales
GROUP BY DAYNAME(order_date)
ORDER BY COUNT(DISTINCT order_id) DESC;

-- hourly trend for total orders --
SELECT HOUR(order_time) AS "Hour",COUNT(DISTINCT order_id) AS "Orders Count" FROM pizza_sales
GROUP BY HOUR(order_time)
ORDER BY COUNT(DISTINCT order_id) DESC;

-- day parts trend --
SELECT day_parts, COUNT(DISTINCT order_id) AS "Orders Count" FROM pizza_sales
GROUP BY day_parts
ORDER BY COUNT(DISTINCT order_id) DESC;

-- pizza category popularity --

WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
     total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.pizza_category,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_popularity",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue"
    FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN 
	total_revenue t3
GROUP BY t1.pizza_category
ORDER BY   COUNT(DISTINCT t1.order_id) DESC;

-- pizza size popularity --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
 total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.pizza_size,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue"
    FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN 
	total_revenue t3
GROUP BY t1.pizza_size
ORDER BY   COUNT(DISTINCT t1.order_id) DESC;
-- Overall_analysis popularity wise --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
     total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.pizza_category,t1.pizza_size,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue"FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3
GROUP BY t1.pizza_category,t1.pizza_size
ORDER BY   ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC ;
-- ingredients_count --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.ingredients_count,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.ingredients_count
ORDER BY   COUNT(DISTINCT t1.order_id) DESC;

WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.pizza_name,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.pizza_name
ORDER BY  SUM(total_price) DESC LIMIT 5;
-- cheese--
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.cheese,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.cheese;
-- sauce --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.sauce,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.sauce
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC ;
-- cheese and sauce--
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.cheese,t1.sauce,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.cheese,t1.sauce
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC;

WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT
	MONTHNAME(t1.order_date),
    t1.pizza_name,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY MONTHNAME(t1.order_date),t1.pizza_name
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC  ;

-- daily trend of orders and revenue --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    DAYNAME(t1.order_date) AS "day",
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY DAYNAME(t1.order_date)
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC ;

-- hourly trend --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    t1.day_parts,
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY t1.day_parts
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC;

-- monthly trend --
WITH total_orders AS (SELECT COUNT(DISTINCT order_id) AS "Total_Orders" FROM pizza_sales),
total_revenue AS (SELECT ROUND(SUM(total_price),2) AS "Total_Revenue" FROM pizza_sales)
SELECT 
    MONTHNAME(t1.order_date) AS "month",
    COUNT(DISTINCT t1.order_id) AS "orders_count",
    ROUND(SUM(total_price),2) AS "revenue_made",
    CONCAT(ROUND(COUNT(DISTINCT t1.order_id)*100/MAX(t2.Total_Orders),2),"%") AS "%_share",
    CONCAT(ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2),"%") AS "%_revenue" FROM
    pizza_sales t1
CROSS JOIN 
    total_orders t2
CROSS JOIN
    total_revenue t3    
GROUP BY MONTHNAME(t1.order_date)
ORDER BY ROUND(SUM(total_price)*100/MAX(t3.Total_Revenue),2) DESC;

-- calculating correlation coefficent --
SELECT 
    ROUND((COUNT(*) * SUM(unit_price * ingredients_count) - SUM(unit_price) * SUM(ingredients_count)) / 
    SQRT((COUNT(*) * SUM(unit_price * unit_price) - SUM(unit_price) * SUM(unit_price)) * 
         (COUNT(*) * SUM(ingredients_count * ingredients_count) - SUM(ingredients_count) * SUM(ingredients_count))),2)
    AS correlation_coefficient
FROM 
    pizza_sales;
-- co-occurence count--
SELECT 
    LEAST(a.pizza_category, b.pizza_category) AS category1,
    GREATEST(a.pizza_category, b.pizza_category) AS category2,
    COUNT(*) AS co_occurrence_count
FROM 
    pizza_sales a
JOIN 
    pizza_sales b ON a.order_id = b.order_id AND a.pizza_category!=b.pizza_category
GROUP BY  
    LEAST(a.pizza_category, b.pizza_category),
    GREATEST(a.pizza_category, b.pizza_category)
ORDER BY COUNT(*) DESC ;

-- month over month revenue analysis --
SELECT *, LAG(revenue_cm) OVER() AS "revenue_pm",
CONCAT(ROUND(((revenue_cm-LAG(revenue_cm) OVER())*100)/revenue_cm,2),"%") AS "revenue_change_%"
 FROM (SELECT 
      MONTHNAME(order_date) as "month",
      ROUND(SUM(total_price),2) AS "revenue_cm" 
      FROM pizza_sales
GROUP BY MONTHNAME(order_date)) t;

-- month over month orders analysis --
SELECT *, LAG(orders_cm) OVER() AS "orders_pm",
CONCAT(ROUND(((orders_cm-LAG(orders_cm) OVER())*100)/orders_cm,2),"%") AS "orders_change_%"
 FROM (SELECT 
      MONTHNAME(order_date) as "month",
      COUNT(DISTINCT order_id) AS "orders_cm" 
      FROM pizza_sales
GROUP BY MONTH(order_date),MONTHNAME(order_date)
ORDER BY MONTH(order_date)) t;
-- general questions to be answered --
select day_parts,cheese,sauce,count from (select day_parts,
cheese,sauce,COUNT(*) OVER(PARTITION BY day_parts,cheese,sauce) as "count",
ROW_NUMBER() OVER(PARTITION BY day_parts,cheese,sauce) AS "r" from pizza_sales) t
where t.r=1
order by count desc;

-- number of pizzas sold --
WITH total_pizzas_sold AS (SELECT SUM(quantity) AS "total_pizzas_sold" FROM pizza_sales)
SELECT day_parts,
        cheese,
        sauce,preference_count,
        CONCAT(ROUND(preference_count*100/total_pizzas_sold,2),"%") AS "%_count" FROM (SELECT
        day_parts,
        cheese,
        sauce,
        SUM(quantity) OVER(PARTITION BY day_parts, cheese, sauce) AS preference_count,
        ROW_NUMBER() OVER(PARTITION BY day_parts, cheese, sauce) AS r
    FROM
        pizza_sales) t
CROSS JOIN
      total_pizzas_sold t1
WHERE t.r=1
ORDER BY day_parts,preference_count DESC ;

SELECT * FROM pizza_sales;

-- pizza_name and the category most popular --

WITH top_bottam_pizza AS (SELECT *,
RANK() OVER(PARTITION BY pizza_category ORDER BY revenue_generated DESC, order_frequency  DESC) AS "r" FROM
(SELECT 
	pizza_category,
    pizza_name,
    COUNT(order_id) AS "order_frequency",
    ROUND(SUM(total_price),2) AS "revenue_generated"
  FROM  pizza_sales    
GROUP BY pizza_category,pizza_name
ORDER BY COUNT(order_id) DESC, ROUND(SUM(total_price),2) DESC) t)

SELECT pizza_category,pizza_name,order_frequency,revenue_generated FROM top_bottam_pizza
WHERE r<=5  ;                     -- top/bottam 5 pizzas of every category --

-- top/bottam based on cheese and sauce information --
SELECT 
	pizza_category,
    cheese,
    sauce,
    COUNT(order_id) AS "order_frequency",
    ROUND(SUM(total_price),2) AS "revenue_generated"
  FROM  pizza_sales    
GROUP BY pizza_category,cheese,sauce 
ORDER BY ROUND(SUM(total_price),2) DESC, COUNT(order_id) DESC;

-- 
select *, rank() over(partition by day_parts order by count desc) from (select day_parts,pizza_name,COUNT(order_id) as "count" from pizza_sales
group by day_parts,pizza_name) t;

-- month wise top 5 pizza_name --
WITH cte1 as 
(SELECT *, RANK() OVER(PARTITION BY month ORDER BY revenue DESC) as "r" FROM 
(SELECT 
MONTHNAME(order_date) AS "month",
pizza_name, COUNT(DISTINCT order_id) as "orders_count",
SUM(total_price) AS "revenue" FROM pizza_sales
GROUP BY MONTHNAME(order_date),pizza_name) t)

SELECT month,pizza_name,orders_count,revenue FROM cte1
WHERE r<=2
ORDER BY month ASC,revenue DESC;



WITH total_pizzas_sold AS (SELECT SUM(quantity) AS "total_pizzas_sold" FROM pizza_sales)
SELECT Day,
        cheese,
        sauce,count,
        CONCAT(ROUND(count*100/total_pizzas_sold,2),"%") AS "%_count" FROM (SELECT
        DAYNAME(order_date) AS "Day",
        cheese,
        sauce,
        SUM(quantity) OVER(PARTITION BY day_parts, cheese, sauce) AS count,
        ROW_NUMBER() OVER(PARTITION BY day_parts) AS r
    FROM
        pizza_sales) t
CROSS JOIN
      total_pizzas_sold t1
WHERE t.r=1
ORDER BY count DESC;

WITH cte2 AS (SELECT *, 
RANK() OVER(PARTITION BY Day ORDER BY Quantities_sold DESC) AS "r" FROM
(SELECT DAYOFWEEK(order_date) AS "dw",DAYNAME(order_date) AS "Day",sauce, SUM(quantity) AS "Quantities_sold" FROM pizza_sales
GROUP BY DAYOFWEEK(order_date),DAYNAME(order_date),sauce
ORDER BY DAYOFWEEK(order_date)) t)

SELECT Day,sauce FROM cte2
WHERE r=1
ORDER BY dw ASC
;

SELECT DAYNAME(order_date),cheese,sauce,SUM(quantity) FROM pizza_sales
GROUP BY DAYNAME(order_date),cheese,sauce;
-- Classic is the most preferred category of every day --
WITH cte2 AS 
	(SELECT *, 
	RANK() OVER(PARTITION BY Day ORDER BY Quantities_sold DESC) AS "r" 
    FROM
		(SELECT DAYOFWEEK(order_date) AS "dw",DAYNAME(order_date) AS "Day",pizza_name,
        SUM(quantity) AS "Quantities_sold" 
        FROM pizza_sales
		GROUP BY DAYOFWEEK(order_date),DAYNAME(order_date),pizza_name
		) t)
SELECT Day,pizza_name FROM cte2
WHERE r=1
ORDER BY dw ASC;	

WITH cte2 AS 
	(SELECT *, 
	RANK() OVER(PARTITION BY day_parts ORDER BY Quantities_sold DESC) AS "r" 
    FROM
		(SELECT day_parts,cheese,
        SUM(quantity) AS "Quantities_sold" 
        FROM pizza_sales
		GROUP BY day_parts,cheese
		) t)
SELECT day_parts,cheese FROM cte2
WHERE r<=2;				   -- Classic and supreme --
							

 WITH cte2 AS (SELECT *, 
RANK() OVER(PARTITION BY day_parts ORDER BY Quantities_sold DESC) AS "r" FROM
(SELECT day_parts,cheese,sauce, SUM(quantity) AS "Quantities_sold" FROM pizza_sales
GROUP BY day_parts,cheese,sauce
) t)

SELECT day_parts,cheese,sauce FROM cte2
WHERE r=1;

SELECT * FROM pizza_sales