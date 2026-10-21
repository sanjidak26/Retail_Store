
-- ==========================================
-- FILE 4: BUSINESS ANALYSIS
-- ==========================================

USE retail_store;

-- Q1. Gross sales, returns and net revenue
SELECT
    ROUND(SUM(CASE WHEN qty > 0
        THEN total_amt ELSE 0 END), 2)
        AS gross_sales,

    ROUND(SUM(CASE WHEN qty < 0
        THEN total_amt ELSE 0 END), 2)
        AS returns_value,

    ROUND(SUM(total_amt), 2) AS net_revenue
FROM transactions;

-- Q2. Revenue by sales channel
SELECT
    store_type,
    COUNT(*) AS transaction_rows,
    ROUND(SUM(total_amt), 2) AS net_revenue
FROM transactions
GROUP BY store_type
ORDER BY net_revenue DESC;

-- Q3. Revenue by product category
SELECT
    p.prod_cat,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_cat
ORDER BY net_revenue DESC;

-- Q4. Revenue by subcategory
SELECT
    p.prod_cat,
    p.prod_subcat,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_cat, p.prod_subcat
ORDER BY net_revenue DESC;

-- Q5. Monthly net revenue
SELECT
    DATE_FORMAT(tran_date, '%Y-%m') AS sales_month,
    ROUND(SUM(total_amt), 2) AS net_revenue
FROM transactions
GROUP BY DATE_FORMAT(tran_date, '%Y-%m')
ORDER BY sales_month;

-- Q6. Return rows and return value by category
SELECT
    p.prod_cat,
    SUM(CASE WHEN t.qty < 0
        THEN 1 ELSE 0 END) AS return_rows,
    ROUND(SUM(CASE WHEN t.qty < 0
        THEN ABS(t.total_amt) ELSE 0 END), 2)
        AS return_value,
    ROUND(SUM(CASE WHEN t.qty > 0
        THEN t.total_amt ELSE 0 END), 2)
        AS gross_sales
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_cat
ORDER BY return_value DESC;

-- Q7. Top 10 customers by net spend
SELECT
    c.customer_id,
    c.gender,
    c.city_code,
    ROUND(SUM(t.total_amt), 2) AS net_spend
FROM customer c
JOIN transactions t
    ON c.customer_id = t.cust_id
GROUP BY c.customer_id, c.gender, c.city_code
ORDER BY net_spend DESC
LIMIT 10;

-- Q8. Revenue by customer gender
SELECT
    COALESCE(c.gender, 'Unknown') AS gender,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM customer c
JOIN transactions t
    ON c.customer_id = t.cust_id
GROUP BY COALESCE(c.gender, 'Unknown')
ORDER BY net_revenue DESC;

-- Q9. Total transaction rows and return rows
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN qty < 0 THEN 1 ELSE 0 END) AS return_rows
FROM transactions;

-- Q10. Date range covered by the dataset
SELECT
    MIN(tran_date) AS first_transaction_date,
    MAX(tran_date) AS last_transaction_date,
    DATEDIFF(MAX(tran_date), MIN(tran_date)) AS days_covered
FROM transactions;

-- Q11. Category containing the DIY subcategory
SELECT DISTINCT
    prod_cat,
    prod_subcat
FROM prod_cat_info
WHERE LOWER(prod_subcat) = 'diy';

-- Q12. Customer count by city
SELECT
    COALESCE(CAST(city_code AS CHAR), 'Unknown') AS city,
    COUNT(*) AS customer_count
FROM customer
GROUP BY city_code
ORDER BY customer_count DESC;

-- Q13. Subcategories under Books
SELECT
    prod_subcat
FROM prod_cat_info
WHERE LOWER(prod_cat) = 'books'
ORDER BY prod_subcat;

-- Q14. Maximum positive quantity in a transaction row
SELECT
    MAX(qty) AS maximum_quantity
FROM transactions
WHERE qty > 0;

-- Q15. Net revenue from Electronics and Books
SELECT
    p.prod_cat,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat IN ('Electronics', 'Books')
GROUP BY p.prod_cat
ORDER BY net_revenue DESC;

-- Q16. Customers with more than 10 non-return transactions
SELECT
    cust_id,
    COUNT(*) AS purchase_transactions,
    ROUND(SUM(total_amt), 2) AS net_spend
FROM transactions
WHERE qty > 0
GROUP BY cust_id
HAVING COUNT(*) > 10
ORDER BY purchase_transactions DESC;

-- Q17. Electronics and Clothing revenue at Flagship stores
SELECT
    p.prod_cat,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat IN ('Electronics', 'Clothing')
  AND t.store_type = 'Flagship store'
GROUP BY p.prod_cat
ORDER BY net_revenue DESC;

-- Q18. Electronics revenue by subcategory for male customers
SELECT
    p.prod_subcat,
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN prod_cat_info p
    ON t.prod_cat_code = p.prod_cat_code
   AND t.prod_subcat_code = p.prod_sub_cat_code
JOIN customer c
    ON t.cust_id = c.customer_id
WHERE p.prod_cat = 'Electronics'
  AND c.gender = 'M'
GROUP BY p.prod_subcat
ORDER BY net_revenue DESC;

-- Q19. Sales and return percentages by subcategory
-- Top 5 subcategories by gross sales

WITH subcategory_sales AS (
    SELECT
        p.prod_cat,
        p.prod_subcat,

        SUM(CASE
            WHEN t.qty > 0 THEN t.total_amt
            ELSE 0
        END) AS gross_sales,

        SUM(CASE
            WHEN t.qty < 0 THEN ABS(t.total_amt)
            ELSE 0
        END) AS return_value

    FROM transactions t
    JOIN prod_cat_info p
        ON t.prod_cat_code = p.prod_cat_code
       AND t.prod_subcat_code = p.prod_sub_cat_code

    GROUP BY p.prod_cat, p.prod_subcat
)
SELECT
    prod_cat,
    prod_subcat,
    ROUND(gross_sales, 2) AS gross_sales,
    ROUND(return_value, 2) AS return_value,

    ROUND(
        100.0 * gross_sales /
        NULLIF((SELECT SUM(gross_sales)
                FROM subcategory_sales), 0),
        2
    ) AS sales_percent,

    ROUND(
        100.0 * return_value /
        NULLIF((SELECT SUM(return_value)
                FROM subcategory_sales), 0),
        2
    ) AS returns_percent

FROM subcategory_sales
ORDER BY gross_sales DESC
LIMIT 5;
-- Q20. Net revenue from customers aged 25–35
-- during the last 30 days of the dataset

WITH dataset_end AS (
    SELECT MAX(tran_date) AS last_date
    FROM transactions
)
SELECT
    ROUND(SUM(t.total_amt), 2) AS net_revenue
FROM transactions t
JOIN customer c
    ON t.cust_id = c.customer_id
CROSS JOIN dataset_end d
WHERE TIMESTAMPDIFF(YEAR, c.dob, d.last_date)
      BETWEEN 25 AND 35
  AND t.tran_date BETWEEN DATE_SUB(d.last_date, INTERVAL 29 DAY)
                      AND d.last_date;

-- Q21. Rank customers by net spend within each city
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.city_code,
        ROUND(SUM(t.total_amt), 2) AS net_spend
    FROM customer c
    JOIN transactions t
        ON c.customer_id = t.cust_id
    GROUP BY c.customer_id, c.city_code
),
ranked_customers AS (
    SELECT
        customer_id,
        city_code,
        net_spend,
        RANK() OVER (
            PARTITION BY city_code
            ORDER BY net_spend DESC
        ) AS customer_rank
    FROM customer_spending
)
SELECT
    customer_id,
    city_code,
    net_spend,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY city_code, customer_rank;

-- Q22. Month-on-month net revenue growth using LAG()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(tran_date, '%Y-%m') AS sales_month,
        SUM(total_amt) AS net_revenue
    FROM transactions
    GROUP BY DATE_FORMAT(tran_date, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        sales_month,
        net_revenue,
        LAG(net_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    sales_month,
    ROUND(net_revenue, 2) AS net_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(net_revenue - previous_month_revenue, 2)
        AS revenue_change,
    ROUND(
        100.0 * (net_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percent
FROM revenue_with_previous
ORDER BY sales_month;

-- Q23. RFM customer segmentation

WITH customer_rfm AS (
    SELECT
        c.customer_id,
        DATEDIFF(
            (SELECT MAX(tran_date) FROM transactions),
            MAX(CASE WHEN t.qty > 0 THEN t.tran_date END)
        ) AS recency_days,
        COUNT(CASE WHEN t.qty > 0 THEN 1 END) AS frequency,
        ROUND(
            SUM(CASE WHEN t.qty > 0 THEN t.total_amt ELSE 0 END),
            2
        ) AS monetary
    FROM customer c
    JOIN transactions t
        ON c.customer_id = t.cust_id
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'
        WHEN frequency_score >= 4
             AND monetary_score >= 3
            THEN 'Loyal'
        WHEN recency_score <= 2
             AND frequency_score >= 3
            THEN 'At-risk'
        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Lost'
        ELSE 'Regular'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_score DESC, frequency_score DESC;

-- Q24. Cohort analysis by first purchase month

WITH customer_first_purchase AS (
    SELECT
        cust_id,
        MIN(tran_date) AS first_purchase_date
    FROM transactions
    WHERE qty > 0
    GROUP BY cust_id
),
customer_activity AS (
    SELECT DISTINCT
        t.cust_id,
        DATE_FORMAT(f.first_purchase_date, '%Y-%m') AS cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            f.first_purchase_date,
            t.tran_date
        ) AS months_since_first_purchase
    FROM transactions t
    JOIN customer_first_purchase f
        ON t.cust_id = f.cust_id
    WHERE t.qty > 0
)
SELECT
    cohort_month,
    months_since_first_purchase,
    COUNT(DISTINCT cust_id) AS active_customers
FROM customer_activity
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;

