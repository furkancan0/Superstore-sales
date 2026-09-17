-- Total of sales by month (year-to-date) cumulative sum 
WITH monthly AS (
    SELECT d.year, MONTH(d.full_date) AS month_num, SUM(f.sales) AS monthly_sales
    FROM fact_sales f
    JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, MONTH(d.full_date)
)
SELECT year, month_num, monthly_sales,
       SUM(monthly_sales) OVER (PARTITION BY year ORDER BY month_num
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_ytd
FROM monthly
ORDER BY year, month_num;

-- Year-over-year growth by category
WITH yearly_category AS (
    SELECT p.category, d.year, SUM(f.sales) AS total_sales
    FROM fact_sales f
    JOIN dim_product p ON p.product_key = f.product_key
    JOIN dim_date d    ON d.date_key = f.date_key
    GROUP BY p.category, d.year
)
SELECT category, year, total_sales,
       LAG(total_sales) OVER (PARTITION BY category ORDER BY year) AS prev_year_sales,
       CAST(ROUND(100.0 * (total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY year))
             / NULLIF(LAG(total_sales) OVER (PARTITION BY category ORDER BY year), 0), 1) AS DECIMAL(6,1)) AS yoy_growth_pct
FROM yearly_category
ORDER BY category, year;

-- Top 3 products by profit WITHIN each category
WITH ranked_products AS (
    SELECT p.category, p.product_name, SUM(f.profit) AS total_profit,
           ROW_NUMBER() OVER (PARTITION BY p.category ORDER BY SUM(f.profit) DESC) AS rn
    FROM fact_sales f
    JOIN dim_product p ON p.product_key = f.product_key
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, total_profit
FROM ranked_products
WHERE rn <= 3
ORDER BY category, total_profit DESC;

-- 3-month moving average of sales (smooths out noisy months)
WITH monthly AS (
    SELECT d.year, MONTH(d.full_date) AS month_num, SUM(f.sales) AS monthly_sales
    FROM fact_sales f
    JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, MONTH(d.full_date)
)
SELECT year, month_num, monthly_sales,
       AVG(monthly_sales) OVER (ORDER BY year, month_num
                                 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3mo
FROM monthly
ORDER BY year, month_num;

-- A5: Customer value quartiles(4 equal-sized buckets)
-- Top 25% of customers generate 55% of revenue.
WITH customer_totals AS (
    SELECT c.customer_name, SUM(f.sales) AS total_sales
    FROM fact_sales f
    JOIN dim_customer c ON c.customer_key = f.customer_key
    GROUP BY c.customer_name
),
quartiles AS (
    SELECT customer_name, total_sales,
           NTILE(4) OVER (ORDER BY total_sales DESC) AS spend_quartile
    FROM customer_totals
)
SELECT spend_quartile,
       COUNT(*) AS customers,
       SUM(total_sales) AS quartile_revenue,
       CAST(ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS DECIMAL(6,1)) AS pct_of_total_revenue
FROM quartiles
GROUP BY spend_quartile
ORDER BY spend_quartile;

-- "80/20 rule" check, built from a cumulative sum.
WITH customer_profit AS (
    SELECT c.customer_name, SUM(f.profit) AS total_profit
    FROM fact_sales f
    JOIN dim_customer c ON c.customer_key = f.customer_key
    GROUP BY c.customer_name
), ranked 
AS (SELECT customer_name, total_profit,
           SUM(total_profit) OVER (ORDER BY total_profit DESC
                                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_profit,
           SUM(total_profit) OVER () AS grand_total_profit,
           ROW_NUMBER() OVER (ORDER BY total_profit DESC) AS customer_rank,
           COUNT(*) OVER () AS total_customers
    FROM customer_profit)
SELECT customer_name, total_profit, customer_rank, total_customers,
       ROUND(100.0 * running_profit / grand_total_profit, 1) AS cumulative_profit_pct
FROM ranked
WHERE running_profit <= grand_total_profit * 0.8
ORDER BY total_profit DESC;

-- Each customer's first purchase date - every order they placed
SELECT distinct c.customer_name, f.order_id, d.full_date AS order_date,
       MIN(d.full_date) OVER (PARTITION BY c.customer_key) AS first_purchase_date,
       DATEDIFF(DAY, MIN(d.full_date) OVER (PARTITION BY c.customer_key), d.full_date) AS days_since_first_purchase
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
JOIN dim_date d      ON d.date_key = f.date_key
ORDER BY c.customer_name, order_date;