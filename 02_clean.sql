
-- ==========================================
-- FILE 2: DATA CLEANING
-- Run after 01_schema.sql
-- ==========================================

USE retail_store;

-- Remove previously created clean tables so
-- this script can be rerun from the beginning.
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS prod_cat_info;

-- 1. Clean customer data
CREATE TABLE customer AS
SELECT
    CAST(TRIM(customer_id) AS UNSIGNED) AS customer_id,

    STR_TO_DATE(
        REPLACE(TRIM(dob), '/', '-'),
        '%d-%m-%Y'
    ) AS dob,

    NULLIF(TRIM(gender), '') AS gender,

    CAST(
        NULLIF(TRIM(city_code), '')
        AS UNSIGNED
    ) AS city_code

FROM customer_stg
WHERE TRIM(customer_id) REGEXP '^[0-9]+$';

ALTER TABLE customer
ADD PRIMARY KEY (customer_id);

-- 2. Clean transaction data
-- DISTINCT removes rows identical across all columns.
CREATE TABLE transactions AS
SELECT DISTINCT
    CAST(TRIM(transaction_id) AS UNSIGNED)
        AS transaction_id,

    CAST(TRIM(cust_id) AS UNSIGNED)
        AS cust_id,

    STR_TO_DATE(
        REPLACE(TRIM(tran_date), '/', '-'),
        '%d-%m-%Y'
    ) AS tran_date,

    CAST(TRIM(prod_subcat_code) AS UNSIGNED)
        AS prod_subcat_code,

    CAST(TRIM(prod_cat_code) AS UNSIGNED)
        AS prod_cat_code,

    CAST(TRIM(Qty) AS SIGNED) AS qty,

    CAST(TRIM(Rate) AS DECIMAL(12,2)) AS rate,

    CAST(TRIM(Tax) AS DECIMAL(12,2)) AS tax,

    CAST(TRIM(total_amt) AS DECIMAL(14,2))
        AS total_amt,

    TRIM(Store_type) AS store_type,

    CASE
        WHEN CAST(TRIM(Qty) AS SIGNED) < 0
            THEN 1
        ELSE 0
    END AS is_return

FROM transactions_stg
WHERE TRIM(transaction_id) REGEXP '^[0-9]+$'
  AND TRIM(cust_id) REGEXP '^[0-9]+$';

CREATE INDEX idx_transactions_customer
ON transactions (cust_id);

CREATE INDEX idx_transactions_date
ON transactions (tran_date);

-- 3. Clean product category data
CREATE TABLE prod_cat_info AS
SELECT DISTINCT
    CAST(TRIM(prod_cat_code) AS UNSIGNED)
        AS prod_cat_code,

    TRIM(prod_cat) AS prod_cat,

    CAST(TRIM(prod_sub_cat_code) AS UNSIGNED)
        AS prod_sub_cat_code,

    TRIM(prod_subcat) AS prod_subcat

FROM prod_cat_info_stg
WHERE TRIM(prod_cat_code) REGEXP '^[0-9]+$'
  AND TRIM(prod_sub_cat_code) REGEXP '^[0-9]+$';

ALTER TABLE prod_cat_info
ADD PRIMARY KEY (prod_cat_code, prod_sub_cat_code);

-- 4. Check cleaned row counts
SELECT 'Customers' AS dataset, COUNT(*) AS row_count
FROM customer
UNION ALL
SELECT 'Transactions', COUNT(*)
FROM transactions
UNION ALL
SELECT 'Product Categories', COUNT(*)
FROM prod_cat_info;
