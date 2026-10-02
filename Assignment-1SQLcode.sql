Use retail_events_db;
select * from dim_campaigns;
select * from dim_products;
select* from dim_Stores;
select * from fact_Events;


-- Q1. Basic Filtering – High-Value Products
-- Find all event records where the base_price is greater than 1,000.

-- Display:
-- - event_id
-- - store_id
-- - product_code
-- - base_price
-- - promo_type

-- Concepts:
-- SELECT, WHERE, comparison operators.

SELECT event_id,store_id,product_code, base_price, promo_type FROM Fact_Events where base_price>1000;
-- ------------------------------------------------------------

-- Q2. Sorting Promotional Events
-- Display all events where quantity sold after the promotion was greater than 100.

-- Display:
-- - event_id
-- - product_code
-- - promo_type
-- - quantity_sold(before_promo)
-- - quantity_sold(after_promo)

-- Sort by quantity_sold(after_promo) in descending order.

-- Concepts:
-- WHERE, ORDER BY, DESC.
SELECT event_id, product_code, promo_type,`quantity_sold(before_promo)`,`quantity_sold(after_promo)` FROM fact_events
WHERE `quantity_sold(after_promo)` >100
ORDER BY `quantity_sold(after_promo)` DESC;
-- ------------------------------------------------------------

-- Q3. DISTINCT Promotion Types
-- Find all unique promotion types used in the dataset.

-- Display only the unique promo_type values.

-- Concepts:
-- DISTINCT.
SELECT DISTINCT promo_type FROM fact_events;

-- ------------------------------------------------------------

-- Q4. Basic Aggregation
-- Calculate the following for the complete fact_events table:

-- - Total number of events
-- - Total quantity sold before promotion
-- - Total quantity sold after promotion
-- - Average base price
-- - Maximum base price
-- - Minimum base price

-- Return all metrics in one row.

-- Concepts:
-- COUNT, SUM, AVG, MAX, MIN.

SELECT COUNT(*) AS `Total number of events`,
SUM(`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`,
AVG(base_price) AS`Average base price`,
MAX(base_price)AS `Maximum base price`,
MIN(base_price)AS `Minimum base price`
from fact_events;

-- ============================================================
-- MEDIUM QUESTIONS
-- ============================================================

-- Q5. Sales Volume by Promotion Type
-- For each promo_type, calculate:

-- - Number of events
-- - Total quantity sold before promotion
-- - Total quantity sold after promotion

-- Sort by total quantity sold after promotion in descending order.

-- Concepts:
-- GROUP BY, COUNT, SUM, ORDER BY.

SELECT Promo_type,
Count(*) AS `Number of events`,
SUM(`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`
FROM fact_events
GROUP BY promo_type
ORDER BY `Total quantity sold after promotion` DESC;

-- ------------------------------------------------------------

-- Q6. Promotion Uplift
-- For every promotion type, calculate:

-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity increase/decrease

-- Use:

-- Quantity Change = After Promo Quantity - Before Promo Quantity

-- Display:
-- - promo_type
-- - total_before
-- - total_after
-- - quantity_change

-- Sort by quantity_change descending.

-- Concepts:
-- GROUP BY, SUM, arithmetic calculations, aliases.
SELECT 
promo_type,
SUM(`quantity_sold(before_promo)`) AS `total_before`,
SUM(`quantity_sold(after_promo)`)AS `total_after`,
SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`) AS `quantity_change`
FROM fact_events
GROUP BY promo_type
ORDER BY  `quantity_change` DESC; 


-- ------------------------------------------------------------

-- Q7. Product Performance
-- Using fact_events and dim_products, calculate total quantity sold after promotion for every product.

-- Display:
-- - product_code
-- - product_name
-- - category
-- - total quantity after promotion

-- Sort by total quantity after promotion descending.

-- Concepts:
-- INNER JOIN, GROUP BY, SUM, ORDER BY.
SELECT f.product_code,
product_name,
category,
SUM(`quantity_sold(after_promo)`)AS `total quantity after promotion`
FROM fact_events f
JOIN dim_products d ON f.product_code = d.product_code
GROUP BY f.product_code, d.product_name, d.category
ORDER BY `total quantity after promotion` DESC;

-- ------------------------------------------------------------

-- Q8. Category-Level Performance
-- Using fact_events and dim_products, calculate for every product category:

-- - Number of events
-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity change

-- Sort categories by total quantity after promotion descending.

-- Concepts:
-- JOIN, GROUP BY, SUM, COUNT, arithmetic calculations.

SELECT 
d.category,
Count(*) AS `Number of events`,
SUM(`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`,
SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`) AS `quantity_change`
FROM fact_events f 
JOIN dim_products d ON f.product_code = d.product_code
GROUP BY category
ORDER BY `Total quantity sold after promotion` DESC;

-- ------------------------------------------------------------

-- Q9. Store Performance
-- Using fact_events and dim_stores, calculate for every city:

-- - Number of promotional events
-- - Total quantity before promotion
-- - Total quantity after promotion

-- Display:
-- - city
-- - event_count
-- - total_before
-- - total_after

-- Sort cities by total_after descending.

-- Concepts:
-- JOIN, GROUP BY, aggregation, ORDER BY.
SELECT 
city,
COUNT(event_id) AS `event_count`,
SUM(`quantity_sold(before_promo)`) AS `total_before`,
SUM(`quantity_sold(after_promo)`)AS `total_after`
FROM fact_events f 
JOIN dim_stores as d ON f.store_id= d.store_id
GROUP BY city
ORDER BY `total_after` DESC;

-- ------------------------------------------------------------

-- Q10. Campaign Performance
-- Using fact_events and dim_campaigns, calculate for each campaign:

-- - Campaign name
-- - Start date
-- - End date
-- - Number of events
-- - Total quantity before promotion
-- - Total quantity after promotion

-- Sort by total quantity after promotion descending.

-- Concepts:
-- JOIN, GROUP BY, date columns, aggregation.
SELECT campaign_name,
start_date AS `Start date`,
end_Date AS `End date`,
COUNT(event_id) AS `Number of events`,
SUM(`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`
FROM dim_campaigns d  
JOIN fact_events f ON f.campaign_id= d.campaign_id
GROUP BY d.campaign_id, d.campaign_name, d.start_date, d.end_date
ORDER BY `Total quantity sold after promotion` DESC;


-- ------------------------------------------------------------

-- Q11. Product Category with HAVING
-- Find product categories where the total quantity sold after promotion is greater than 1,000.

-- Display:
-- - category
-- - total quantity after promotion
-- - average base price

-- Sort by total quantity after promotion descending.

-- Concepts:
-- JOIN, GROUP BY, HAVING, AVG, SUM.

SELECT category,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`,
AVG(base_price) AS `average base price`
FROM fact_events f
JOIN dim_products d on d.product_code= f.product_code
GROUP BY category
HAVING `Total quantity sold after promotion`>1000
ORDER BY `Total quantity sold after promotion` DESC;


-- ------------------------------------------------------------

-- Q12. Store + Category Analysis
-- Using fact_events, dim_stores and dim_products, calculate total quantity sold after promotion for every combination of:

-- - City
-- - Product category

-- Display:
-- - city
-- - category
-- - total quantity after promotion

-- Sort first by city and then by total quantity descending.

-- Concepts:
-- Multiple JOINs, GROUP BY, ORDER BY.

SELECT city,
category,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`
FROM fact_events f 
JOIN dim_products dp ON dp.product_code= f.product_code
JOIN dim_stores ds ON ds.store_id= f.store_id
GROUP BY city, category
ORDER BY city ASC, `Total quantity sold after promotion` DESC;

-- ------------------------------------------------------------

-- Q13. Promotion Effectiveness by Product
-- For each product, calculate:

-- - Product name
-- - Category
-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity change
-- - Percentage change

-- Use:

-- Percentage Change =
-- ((After Promo - Before Promo) / Before Promo) * 100

-- Handle division by zero appropriately.

-- Sort by percentage change descending.

-- Concepts:
-- JOIN, GROUP BY, arithmetic calculations, NULLIF, percentage calculations.
SELECT d.product_name,
d.category,
SUM(`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
SUM(`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`,
SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`) AS `quantity_change`,
((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) / NULLIF(SUM(`quantity_sold(before_promo)`), 0)) * 100 AS `Percentage Change`
FROM fact_events f
JOIN dim_products d ON d.product_code = f.product_code
GROUP BY d.product_name, d.category
ORDER BY `Percentage Change` DESC;



-- ------------------------------------------------------------

-- Q14. Campaign and Promotion Type Analysis
-- For each campaign and promo_type combination, calculate:

-- - Number of events
-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity change

-- Display:
-- - campaign_name
-- - promo_type
-- - event_count
-- - total_before
-- - total_after
-- - quantity_change

-- Sort by campaign_name and quantity_change descending.

-- Concepts:
-- Multiple GROUP BY columns, JOIN, aggregation, ORDER BY.
SELECT campaign_name,
promo_type,
count(*) AS event_count,
SUM(`quantity_sold(before_promo)`) AS `total_before`,
SUM(`quantity_sold(after_promo)`)AS total_after,
SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`) AS quantity_change
from dim_campaigns dm 
JOIN fact_events f ON dm.campaign_id= f.campaign_id
GROUP BY  campaign_name, promo_type
ORDER BY campaign_name , quantity_change DESC;

-- ------------------------------------------------------------

-- Q15. Product Revenue Before and After Promotion
-- For each product, calculate:

-- 1. Revenue before promotion =
--    base_price × quantity_sold(before_promo)

-- 2. Revenue after promotion =
--    base_price × quantity_sold(after_promo)

-- 3. Revenue difference =
--    Revenue after - Revenue before

-- Display:
-- - product_name
-- - category
-- - revenue_before
-- - revenue_after
-- - revenue_difference

-- Sort by revenue_difference descending.

-- Concepts:
-- JOIN, GROUP BY, SUM, arithmetic calculations, aliases.
SELECT product_name,
category,
SUM(base_price * `quantity_sold(before_promo)` )AS `Revenue before promotion`,
SUM(base_price * `quantity_sold(after_promo)`) AS `Revenue after promotion`,
SUM(base_price * `quantity_sold(after_promo)`)- SUM(base_price * `quantity_sold(before_promo)` ) AS `Revenue difference`
FROM dim_products dp 
JOIN fact_events f ON dp.product_code = f.product_code
GROUP BY  dp.product_name, dp.category
ORDER BY `Revenue difference` DESC;
-- ------------------------------------------------------------

-- Q16. Classify Promotion Performance
-- For every promotion type, calculate total quantity before and after promotion.

-- Then classify the promotion using CASE:

-- - Percentage change >= 50% → "High Impact"
-- - Percentage change >= 20% → "Medium Impact"
-- - Percentage change < 20% → "Low Impact"

-- Display:
-- - promo_type
-- - total_before
-- - total_after
-- - percentage_change
-- - performance_category

-- Sort by percentage_change descending.

-- Concepts:
-- GROUP BY, CASE, arithmetic calculations, NULLIF, aliases.
SELECT 
promo_type,
SUM(`quantity_sold(before_promo)`) AS total_before,
SUM(`quantity_sold(after_promo)`)AS total_after,
((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) /
 NULLIF(SUM(`quantity_sold(before_promo)`), 0)) * 100 AS percentage_change,
 CASE WHEN ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) /
 NULLIF(SUM(`quantity_sold(before_promo)`), 0)) * 100 >= 50 THEN "High Impact"
 WHEN  ((SUM(`quantity_sold(after_promo)`) - SUM(`quantity_sold(before_promo)`)) /
 NULLIF(SUM(`quantity_sold(before_promo)`), 0)) * 100 >= 20 THEN "Medium Impact"
 ELSE "Low Impact"
END AS performance_category
FROM FACT_EVENTS
GROUP BY promo_type
ORDER BY percentage_change DESC;
 

-- ============================================================
-- HARD QUESTIONS
-- ============================================================

-- Q17. Top Products Within Each Category
-- Using a CTE:

-- 1. Calculate total quantity sold after promotion for every product.
-- 2. Rank products within each category based on total quantity sold after promotion.
-- 3. Return only the top 2 products from every category.

-- Display:
-- - category
-- - product_name
-- - total_quantity_after
-- - category_rank

-- Concepts:
-- CTE, JOIN, GROUP BY, DENSE_RANK/ROW_NUMBER,
-- PARTITION BY, window functions.
WITH product_info AS(
	SELECT d.category,
	d.product_name,
	SUM(f.`quantity_sold(after_promo)`) AS total_quantity_after,
    DENSE_RANK() OVER (
    PARTITION BY category 
    ORDER BY SUM(`quantity_sold(after_promo)`) DESC 
    ) AS category_rank
    FROM fact_events f
    JOIN dim_products d ON f.product_code = d.product_code
    GROUP BY d.category, d.product_name
)
SELECT category, product_name,
 total_quantity_after, category_rank
 FROM product_info 
 WHERE category_rank <= 2;
-- ------------------------------------------------------------

-- Q18. Best-Performing Stores Within Each City
-- Calculate total quantity sold after promotion for each store.

-- Join dim_stores to obtain the city.

-- Then rank stores within each city based on total quantity sold after promotion.

-- Return the top 2 stores from each city.

-- Display:
-- - city
-- - store_id
-- - total_quantity_after
-- - city_rank

-- Concepts:
-- JOIN, CTE, GROUP BY, window functions,
-- PARTITION BY, RANK/DENSE_RANK.
WITH product_info as(
	SELECT dm.city,dm.store_id,
    SUM(f.`quantity_sold(after_promo)`) AS total_quantity_after,
    DENSE_RANK() OVER(
    PARTITION BY dm.city
    ORDER BY SUM(f.`quantity_sold(after_promo)`) DESC
    ) AS city_rank
    FROM fact_events f
    JOIN dim_stores dm ON dm.store_id= f.store_id
    GROUP BY dm.city,dm.store_id
)
SELECT city, store_id,
total_quantity_after, city_rank
from product_info 
where city_rank<=2;
-- ------------------------------------------------------------

-- Q19. Campaign-Level Product Performance
-- For every campaign and product:

-- Calculate:
-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity change
-- - Percentage change

-- Then rank products within each campaign based on percentage change.

-- Return the top 3 products for every campaign.

-- Display:
-- - campaign_name
-- - product_name
-- - total_before
-- - total_after
-- - quantity_change
-- - percentage_change
-- - campaign_rank

-- Concepts:
-- Multiple JOINs, CTE, GROUP BY, arithmetic calculations,
-- NULLIF, window functions, PARTITION BY, ranking.
WITH product_info AS (
	SELECT dc.campaign_name,dp.product_name,
	SUM(f.`quantity_sold(before_promo)`) AS total_before,
	SUM(f.`quantity_sold(after_promo)`)AS total_after,
    SUM(f.`quantity_sold(after_promo)`)-SUM(f.`quantity_sold(before_promo)`) AS quantity_change,
	((SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`)) /
	NULLIF(SUM(f.`quantity_sold(before_promo)`), 0)) * 100 AS percentage_change,
    ROW_NUMBER() OVER(
	PARTITION BY dc.campaign_name
	ORDER BY ((SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`)) /
			NULLIF(SUM(f.`quantity_sold(before_promo)`), 0)) * 100 DESC
	) AS campaign_rank
    FROM fact_events f 
	JOIN dim_products dp ON dp.product_code= f.product_code
	JOIN dim_campaigns dc ON dc.campaign_id= f.campaign_id
    GROUP BY dc.campaign_name,dp.product_name
)
SELECT campaign_name, product_name, total_before, total_after,quantity_change,percentage_change,campaign_rank
FROM product_info 
where campaign_rank<=3;

-- ------------------------------------------------------------

-- Q20. Complete Promotional Performance Analysis
-- Create a complete analytical report at the product-category level.

-- For every product, calculate:

-- - Product name
-- - Category
-- - Number of promotional events
-- - Total quantity before promotion
-- - Total quantity after promotion
-- - Quantity change
-- - Percentage change
-- - Revenue before promotion
-- - Revenue after promotion
-- - Revenue change
-- - Average base price
-- - Product rank within its category

-- Use:

-- Quantity Change =
-- Total After - Total Before

-- Percentage Change =
-- ((Total After - Total Before) / Total Before) * 100

-- Revenue Before =
-- SUM(base_price × quantity_before)

-- Revenue After =
-- SUM(base_price × quantity_after)

-- Revenue Change =
-- Revenue After - Revenue Before

-- Then:

-- 1. Rank products within each category by Revenue Change.
-- 2. Return only the top 2 products from each category.
-- 3. Use appropriate handling for division by zero.

-- Concepts:
-- - Multiple JOINs
-- - CTEs
-- - GROUP BY
-- - COUNT
-- - SUM
-- - AVG
-- - CASE
-- - NULLIF
-- - Arithmetic calculations
-- - Percentage calculations
-- - Window functions
-- - PARTITION BY
-- - DENSE_RANK / ROW_NUMBER
-- - Filtering ranked results
-- - Business analysis
WITH product_info AS(
	SELECT dp.product_name AS `Product name`, dp.category,
    count(f.event_id) AS `Number of promotional events`,
    SUM(f.`quantity_sold(before_promo)`) AS `Total quantity sold before promotion`,
	SUM(f.`quantity_sold(after_promo)`)AS `Total quantity sold after promotion`,
    SUM(f.`quantity_sold(after_promo)`)-SUM(f.`quantity_sold(before_promo)`) AS `Quantity Change`,
	((SUM(f.`quantity_sold(after_promo)`) - SUM(f.`quantity_sold(before_promo)`)) /
	NULLIF(SUM(f.`quantity_sold(before_promo)`), 0)) * 100 AS `Percentage Change`,
    SUM(base_price * `quantity_sold(before_promo)` )AS `Revenue before promotion`,
	SUM(base_price * `quantity_sold(after_promo)`) AS `Revenue after promotion`,
	SUM(base_price * `quantity_sold(after_promo)`)- SUM(base_price * `quantity_sold(before_promo)` ) AS `Revenue change`,
    AVG(f.base_price) AS `Average base price`,
    dense_rank() OVER(
    PARTITION BY Category
    ORDER BY SUM(base_price * `quantity_sold(after_promo)`)- SUM(base_price * `quantity_sold(before_promo)`) DESC 
    ) AS `Product rank within its category`
    FROM dim_products dp
    JOIN fact_events f ON dp.product_code=f.product_code
    Group by dp.product_name, dp.category
)
SELECT `Product name`, Category, `Number of promotional events`, `Total quantity sold before promotion`,
`Total quantity sold after promotion`, `Quantity Change`, `Percentage Change`, `Revenue before promotion`,
`Revenue after promotion`, `Revenue change`,`Average base price`, `Product rank within its category`
FROM product_info where `Product rank within its category`<=2;




