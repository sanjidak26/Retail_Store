
-- ==========================================
-- RETAIL STORE ANALYTICS
-- FILE 1: DATABASE AND STAGING SCHEMA
-- Database: MySQL
-- ==========================================

CREATE DATABASE IF NOT EXISTS retail_store;
USE retail_store;

-- 1. Customer staging table
CREATE TABLE IF NOT EXISTS customer_stg (
    customer_id VARCHAR(30),
    dob VARCHAR(30),
    gender VARCHAR(10),
    city_code VARCHAR(30)
);

-- 2. Transaction staging table
CREATE TABLE IF NOT EXISTS transactions_stg (
    transaction_id VARCHAR(30),
    cust_id VARCHAR(30),
    tran_date VARCHAR(30),
    prod_subcat_code VARCHAR(30),
    prod_cat_code VARCHAR(30),
    Qty VARCHAR(30),
    Rate VARCHAR(30),
    Tax VARCHAR(30),
    total_amt VARCHAR(30),
    Store_type VARCHAR(100)
);

-- 3. Product category staging table
CREATE TABLE IF NOT EXISTS prod_cat_info_stg (
    prod_cat_code VARCHAR(30),
    prod_cat VARCHAR(100),
    prod_sub_cat_code VARCHAR(30),
    prod_subcat VARCHAR(100)
);

-- Verify staging table row counts
SELECT 'Customers' AS dataset, COUNT(*) AS row_count
FROM customer_stg
UNION ALL
SELECT 'Transactions', COUNT(*)
FROM transactions_stg
UNION ALL
SELECT 'Product Categories', COUNT(*)
FROM prod_cat_info_stg;
