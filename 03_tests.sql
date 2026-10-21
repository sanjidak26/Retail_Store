
-- ==========================================
-- FILE 3: DATA QUALITY TESTS
-- ==========================================

USE retail_store;

-- TEST 1: Row counts
SELECT 'customer' AS table_name, COUNT(*) AS row_count
FROM customer
UNION ALL
SELECT 'transactions', COUNT(*)
FROM transactions
UNION ALL
SELECT 'prod_cat_info', COUNT(*)
FROM prod_cat_info;

-- TEST 2: Duplicate customer IDs
SELECT customer_id, COUNT(*) AS occurrences
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- TEST 3: Remaining exact transaction duplicates
SELECT
    transaction_id, cust_id, tran_date, qty,
    prod_cat_code, prod_subcat_code,
    rate, tax, total_amt, store_type,
    COUNT(*) AS occurrences
FROM transactions
GROUP BY
    transaction_id, cust_id, tran_date, qty,
    prod_cat_code, prod_subcat_code,
    rate, tax, total_amt, store_type
HAVING COUNT(*) > 1;

-- TEST 4: Missing customer fields
SELECT
    SUM(dob IS NULL) AS missing_dob,
    SUM(gender IS NULL) AS missing_gender,
    SUM(city_code IS NULL) AS missing_city
FROM customer;

-- TEST 5: Invalid transaction dates
SELECT COUNT(*) AS invalid_dates
FROM transactions
WHERE tran_date IS NULL;

-- TEST 6: Transactions without a customer match
SELECT COUNT(*) AS unmatched_customers
FROM transactions t
LEFT JOIN customer c
    ON t.cust_id = c.customer_id
WHERE c.customer_id IS NULL;

-- TEST 7: Transactions without a product match
-- Match on BOTH category and subcategory codes.
SELECT COUNT(*) AS unmatched_products
FROM transactions t
LEFT JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat_code IS NULL;

-- TEST 8: Count return rows
SELECT
    SUM(is_return = 1) AS return_rows,
    SUM(is_return = 0) AS non_return_rows
FROM transactions;

-- TEST 9: Check tax calculation
SELECT COUNT(*) AS tax_mismatches
FROM transactions
WHERE ABS(tax - (0.105 * qty * rate)) > 0.01;

-- TEST 10: Returns without a matching sale ID
SELECT DISTINCT r.transaction_id
FROM transactions r
WHERE r.qty < 0
  AND NOT EXISTS (
      SELECT 1
      FROM transactions s
      WHERE s.transaction_id = r.transaction_id
        AND s.qty > 0
  );
  
-- TEST 11: Check transaction amount integrity
SELECT COUNT(*) AS amount_mismatches
FROM transactions
WHERE ABS(
    ABS(total_amt) - (ABS(qty * rate) + tax)
) > 0.01;

-- TEST 12: Reconcile gross sales, returns and net revenue
SELECT
    ROUND(SUM(
        CASE WHEN qty > 0 THEN total_amt ELSE 0 END
    ), 2) AS gross_sales,

    ROUND(SUM(
        CASE WHEN qty < 0 THEN total_amt ELSE 0 END
    ), 2) AS returns_value,

    ROUND(SUM(total_amt), 2) AS actual_net_revenue,

    ROUND(
        SUM(CASE WHEN qty > 0 THEN total_amt ELSE 0 END)
        + SUM(CASE WHEN qty < 0 THEN total_amt ELSE 0 END),
        2
    ) AS calculated_net_revenue
FROM transactions;
