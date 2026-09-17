IF OBJECT_ID('staging_superstore','U') IS NOT NULL DROP TABLE staging_superstore;
CREATE TABLE staging_superstore (
    row_id          VARCHAR(20),
    order_id        VARCHAR(50),
    order_date      VARCHAR(50),  
    ship_date       VARCHAR(50),
    ship_mode       VARCHAR(100),
    customer_id     VARCHAR(50),
    customer_name   VARCHAR(200),
    segment         VARCHAR(100),
    country         VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(50),
    region          VARCHAR(100),
    product_id      VARCHAR(50),
    category        VARCHAR(100),
    sub_category    VARCHAR(200),
    product_name    VARCHAR(500),
    sales           VARCHAR(50),   
    quantity        VARCHAR(50),
    discount        VARCHAR(50),
    profit          VARCHAR(50)
);
/*
BULK INSERT staging_superstore
FROM 'C:\Users\cn_fu\OneDrive\Masaüstü\archive\Sample - Superstore.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);
*/

-- Sanity check
SELECT COUNT(*) AS staging_row_count FROM staging_superstore;
SELECT TOP 5 * FROM staging_superstore;

-- sub_category should always be a short word like "Chairs"
SELECT sub_category, product_name
FROM staging_superstore
WHERE LEN(sub_category) > 30
ORDER BY LEN(sub_category) DESC;

-- profit should always be numeric-looking text
SELECT row_id, sales, quantity, discount, profit
FROM staging_superstore
WHERE ISNUMERIC(sales) = 0 OR ISNUMERIC(quantity) = 0
   OR ISNUMERIC(discount) = 0 OR ISNUMERIC(profit) = 0;