IF OBJECT_ID('fact_sales','U') IS NOT NULL DROP TABLE fact_sales;
CREATE TABLE fact_sales (
    sale_key      INT IDENTITY(1,1) PRIMARY KEY,
    order_id      VARCHAR(20),
    customer_key  INT REFERENCES dim_customer(customer_key),
    product_key   INT REFERENCES dim_product(product_key),
    location_key  INT REFERENCES dim_location(location_key),
    date_key      INT REFERENCES dim_date(date_key),
    ship_mode     VARCHAR(30),
    sales         DECIMAL(10,2),
    quantity      INT,
    discount      DECIMAL(4,2),
    profit        DECIMAL(10,2)
);
 
INSERT INTO fact_sales (order_id, customer_key, product_key, location_key, date_key,
                         ship_mode, sales, quantity, discount, profit)
SELECT
    s.order_id,
    c.customer_key,
    p.product_key,
    l.location_key,
    d.date_key,
    s.ship_mode,
    CAST(NULLIF(LTRIM(RTRIM(s.sales)), '') AS DECIMAL(10,2)),
    CAST(NULLIF(LTRIM(RTRIM(s.quantity)), '') AS INT),
    CAST(NULLIF(LTRIM(RTRIM(s.discount)), '') AS DECIMAL(4,2)),
    CAST(NULLIF(LTRIM(RTRIM(s.profit)), '') AS DECIMAL(10,2))
FROM staging_superstore s
JOIN dim_customer c  ON c.customer_id = LTRIM(RTRIM(s.customer_id))
                     AND c.customer_name = LTRIM(RTRIM(s.customer_name))
                     AND c.segment = LTRIM(RTRIM(s.segment))
JOIN dim_product p   ON p.product_id = LTRIM(RTRIM(s.product_id))
                     AND p.product_name = LTRIM(RTRIM(s.product_name))
                     AND p.category = LTRIM(RTRIM(s.category))
                     AND p.sub_category = LTRIM(RTRIM(s.sub_category))
JOIN dim_location l  ON l.city = LTRIM(RTRIM(s.city))
                     AND l.state = LTRIM(RTRIM(s.state))
                     AND ISNULL(l.postal_code,'') = ISNULL(NULLIF(LTRIM(RTRIM(s.postal_code)), ''),'')
JOIN dim_date d       ON d.full_date = CONVERT(DATE, s.order_date, 101);

-- join quality
SELECT COUNT(*) AS fact_row_count FROM fact_sales;

CREATE INDEX ix_fact_sales_customer ON fact_sales (customer_key);
CREATE INDEX ix_fact_sales_product  ON fact_sales (product_key);
CREATE INDEX ix_fact_sales_location ON fact_sales (location_key);
CREATE INDEX ix_fact_sales_date     ON fact_sales (date_key);