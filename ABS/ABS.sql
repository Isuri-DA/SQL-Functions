---- ABS() @ List of SQL functions
---- AV sample schema @ https://livesql.oracle.com/
---- 09/25/2024



-- ******************
-- The ABS() function in SQL returns the absolute value of a numeric expression, meaning it converts negative numbers to positive numbers.

select ABS(-25) from dual;

select ABS(-150), ABS(85), ABS(-22.5f) ,ABS('22.5') from dual;

select ABS('22.5f') from dual;  -- but ABS('22.5') works , Oracle supports implicit data conversion




-- 1. Finding the Maximum Deviation from an Average

-- after improvements 
WITH cte_cat_prices AS (
    -- Calculate unit prices per category in one step
    SELECT 
        pr.CATEGORY_ID, 
        pr.CATEGORY_NAME, 
        ROUND(SUM(sf.SALES) / SUM(sf.UNITS), 2) AS UNIT_PRICE
    FROM 
        av.product_dim pr
    JOIN 
        av.sales_fact sf ON pr.CATEGORY_ID = sf.CATEGORY_ID
    GROUP BY 
        pr.CATEGORY_ID, 
        pr.CATEGORY_NAME
),
-- Calculate the overall average unit price only once
avg_price AS (
    SELECT AVG(UNIT_PRICE) AS AVG_UNIT_PRICE FROM cte_cat_prices
)
SELECT 
    ccp.CATEGORY_ID, 
    ccp.CATEGORY_NAME, 
    ccp.UNIT_PRICE, 
    ap.AVG_UNIT_PRICE, 
    ABS(ccp.UNIT_PRICE - ap.AVG_UNIT_PRICE) AS dev_from_avgprice
FROM 
    cte_cat_prices ccp
CROSS JOIN 
    avg_price ap
ORDER BY 
    ccp.UNIT_PRICE;

-- 1st try
/* with cte_cat_prices as
    (select * from av.product_dim pr join 
    (select CATEGORY_ID as CAT_ID, round((sum(SALES)/sum(UNITS)),2) as UNIT_PRICE from av.sales_fact group by CATEGORY_ID) up on
    pr.CATEGORY_ID = up.CAT_ID)
select CATEGORY_ID,CATEGORY_NAME ,UNIT_PRICE ,(select avg(UNIT_PRICE) from cte_cat_prices) as AVG_UNIT_PRICE,
    abs(UNIT_PRICE - (select avg(UNIT_PRICE) from cte_cat_prices)) as dev_from_avgprice 
    from cte_cat_prices
    order by UNIT_PRICE ;
*/



-- 2. Ranking by Closest Value Using ABS()

WITH cte_cat_prices AS (
    -- Calculate unit prices per category in one step
    SELECT 
        pr.CATEGORY_ID, 
        pr.CATEGORY_NAME, 
        ROUND(SUM(sf.SALES) / SUM(sf.UNITS), 2) AS UNIT_PRICE
    FROM 
        av.product_dim pr
    JOIN 
        av.sales_fact sf ON pr.CATEGORY_ID = sf.CATEGORY_ID
    GROUP BY 
        pr.CATEGORY_ID, 
        pr.CATEGORY_NAME
),
ranked_products AS (
	SELECT CATEGORY_ID, CATEGORY_NAME,UNIT_PRICE,
    	ROW_NUMBER() OVER (ORDER BY ABS(UNIT_PRICE - 250)) AS rank_closest_to_250
    FROM cte_cat_prices
)
    SELECT CATEGORY_NAME, UNIT_PRICE, rank_closest_to_250
	FROM ranked_products
	WHERE rank_closest_to_250 <= 3;


---- CO sample schema @ https://livesql.oracle.com/
---- 09/27/2024

-- 4. Handling Outliers in Time Series Data

WITH CTE_ORDER_TOTALS AS
(
    SELECT 
        ORD.ORDER_ID,
        ORD.ORDER_DATETIME,
        SUM(ORI.UNIT_PRICE) AS TOTAL_PRICE
    FROM 
        CO.ORDERS ORD
    JOIN 
        CO.ORDER_ITEMS ORI ON ORD.ORDER_ID = ORI.ORDER_ID
    -- WHERE ORD.ORDER_ID BETWEEN 791 AND 800
    GROUP BY 
        ORD.ORDER_ID, 
        ORD.ORDER_DATETIME
),
CTE_WITH_DEVIATION AS
(
    SELECT 
        t1.ORDER_DATETIME, 
        t1.TOTAL_PRICE, 
        LAG(t1.TOTAL_PRICE, 1, 0) OVER (ORDER BY t1.ORDER_DATETIME) AS PREV_TOTAL_PRICE,
        ABS(t1.TOTAL_PRICE - LAG(t1.TOTAL_PRICE, 1, 0) OVER (ORDER BY t1.ORDER_DATETIME)) AS PRICE_DEVIATION
    FROM 
        CTE_ORDER_TOTALS t1
)
SELECT * 
FROM 
    CTE_WITH_DEVIATION
WHERE 
    PRICE_DEVIATION > 100;
