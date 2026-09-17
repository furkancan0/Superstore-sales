-- customer dimension
IF OBJECT_ID('dim_customer','U') IS NOT NULL DROP TABLE dim_customer;
CREATE TABLE dim_customer (
    customer_key   INT IDENTITY(1,1) PRIMARY KEY,
    customer_id    VARCHAR(20),
    customer_name  VARCHAR(50),
    segment        VARCHAR(30)
);
 
INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT
    LTRIM(RTRIM(customer_id)),
    LTRIM(RTRIM(customer_name)),
    LTRIM(RTRIM(segment))
FROM staging_superstore;

CREATE INDEX ix_dim_customer_lookup ON dim_customer (customer_id, customer_name, segment);

-- customer product
IF OBJECT_ID('dim_product','U') IS NOT NULL DROP TABLE dim_product;
CREATE TABLE dim_product (
    product_key   INT IDENTITY(1,1) PRIMARY KEY,
    product_id    VARCHAR(20),
    product_name  VARCHAR(200),
    category      VARCHAR(30),
    sub_category  VARCHAR(30)
);
 
INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT
    LTRIM(RTRIM(product_id)),
    LTRIM(RTRIM(product_name)),
    LTRIM(RTRIM(category)),
    LTRIM(RTRIM(sub_category))
FROM staging_superstore;
 
CREATE INDEX ix_dim_product_lookup ON dim_product (product_id, product_name, category, sub_category);

-- location dimension
IF OBJECT_ID('dim_location','U') IS NOT NULL DROP TABLE dim_location;
CREATE TABLE dim_location (
    location_key  INT IDENTITY(1,1) PRIMARY KEY,
    city          VARCHAR(50),
    state         VARCHAR(50),
    region        VARCHAR(20),
    postal_code   VARCHAR(10)
);
 
INSERT INTO dim_location (city, state, region, postal_code)
SELECT DISTINCT
    LTRIM(RTRIM(city)),
    LTRIM(RTRIM(state)),
    LTRIM(RTRIM(region)),
    NULLIF(LTRIM(RTRIM(postal_code)), '')
FROM staging_superstore;

CREATE INDEX ix_dim_location_lookup ON dim_location (city, state, postal_code);

-- date dimension
IF OBJECT_ID('dim_date','U') IS NOT NULL DROP TABLE dim_date;
CREATE TABLE dim_date (
    date_key      INT PRIMARY KEY,     -- yyyyMMdd
    full_date     DATE,
    month_name    VARCHAR(10),
    quarter       TINYINT,
    year          SMALLINT
);
 
INSERT INTO dim_date (date_key, full_date, month_name, quarter, year)
SELECT DISTINCT
    CONVERT(INT, FORMAT(CONVERT(DATE, order_date, 101), 'yyyyMMdd')),  -- mm/dd/yyyy
    CONVERT(DATE, order_date, 101),
    DATENAME(MONTH, CONVERT(DATE, order_date, 101)),
    DATEPART(QUARTER, CONVERT(DATE, order_date, 101)),
    YEAR(CONVERT(DATE, order_date, 101))
FROM staging_superstore;