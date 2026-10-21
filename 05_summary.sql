
USE retail_store;

SELECT
    COUNT(*) AS transaction_rows,

    ROUND(SUM(CASE
        WHEN qty > 0 THEN total_amt
        ELSE 0
    END), 2) AS gross_sales,

    ROUND(SUM(CASE
        WHEN qty < 0 THEN total_amt
        ELSE 0
    END), 2) AS returns_value,

    ROUND(SUM(total_amt), 2) AS net_revenue

FROM transactions;
