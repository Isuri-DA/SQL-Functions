---- ABS() @ List of SQL functions
---- AV sample schema @ https://livesql.oracle.com/
---- 09/25/2024


select * from av.geography_dim;
--REGION_ID	REGION_NAME	COUNTRY_ID	COUNTRY_NAME	STATE_PROVINCE_ID	STATE_PROVINCE_NAME

select * from av.sales_fact;
--MONTH_ID	CATEGORY_ID	STATE_PROVINCE_ID	UNITS	SALES
    
select * from av.time_dim;
-- YEAR_ID	YEAR_NAME	YEAR_END_DATE	QUARTER_ID	QUARTER_NAME	QUARTER_END_DATE	QUARTER_OF_YEAR	MONTH_ID	MONTH_NAME	MONTH_END_DATE	MONTH_OF_YEAR	MONTH_LONG_NAME	SEASON	SEASON_ORDER	MONTH_OF_QUARTER

select * from av.product_dim;
-- DEPARTMENT_ID	DEPARTMENT_NAME	CATEGORY_ID	CATEGORY_NAME


-- ******************
-- The ABS() function in SQL returns the absolute value of a numeric expression, meaning it converts negative numbers to positive numbers.


