-- Profit by category
SELECT p.category, SUM(f.sales) AS total_sales, SUM(f.profit) AS total_profit
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_profit DESC;
 
-- Top 10 customers by sales
SELECT TOP 10 c.customer_name, SUM(f.sales) AS total_sales
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.customer_name
ORDER BY total_sales DESC;
 
-- Monthly sales trend
SELECT d.year, MONTH(d.full_date) AS month_num, d.month_name, SUM(f.sales) AS total_sales
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year, MONTH(d.full_date), d.month_name
ORDER BY d.year, month_num;
 
-- Region discount-to-profit ratio (which regions discount heavily but don't profit from it)
SELECT l.region,
       AVG(f.discount) AS avg_discount,
       SUM(f.profit)   AS total_profit,
       SUM(f.sales)    AS total_sales
FROM fact_sales f
JOIN dim_location l ON l.location_key = f.location_key
GROUP BY l.region
ORDER BY total_profit ASC;