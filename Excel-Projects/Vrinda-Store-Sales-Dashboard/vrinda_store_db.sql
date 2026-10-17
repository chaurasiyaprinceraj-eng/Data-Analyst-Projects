-- VRINDA STORE SALES ANALYSIS
-- Corrected and organised SQL script
-- Table assumed to be available as: vrinda_store_sales
-- Run against the same database/schema used by the Python notebook.

-- ============================================================
-- SQL-Q1: DATASET STRUCTURE AND BASELINE VALIDATION
-- ============================================================

-- 1. Inspect table structure
DESCRIBE vrinda_store_sales;

-- 2. Inspect complete table definition
SHOW CREATE TABLE vrinda_store_sales;

-- 3. Total source records
SELECT COUNT(*) AS total_records
FROM vrinda_store_sales;

-- 4. Total revenue
SELECT SUM(amount) AS total_revenue
FROM vrinda_store_sales;

-- 5. Unique order IDs versus source records
-- A repeated order_id does not automatically mean a duplicate row.
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS records_above_unique_order_count
FROM vrinda_store_sales;

-- 6. Unique customers
SELECT COUNT(DISTINCT cust_id) AS unique_customers
FROM vrinda_store_sales;

-- 7. Total quantity
SELECT SUM(qty) AS total_quantity
FROM vrinda_store_sales;

-- 8. Gender-wise revenue
SELECT
    gender,
    SUM(amount) AS total_revenue
FROM vrinda_store_sales
GROUP BY gender
ORDER BY total_revenue DESC;


-- ============================================================
-- SQL-Q2: MULTI-FLAG FINANCIAL RECONCILIATION
-- ============================================================

-- 1. Inspect actual order statuses before interpreting flags
SELECT DISTINCT status
FROM vrinda_store_sales
ORDER BY status;

-- 2. Classify records and show all four possible flags,
-- including flags with zero records.
--
-- IMPORTANT:
-- "Revenue Leak" and "Reversal Check" are investigation labels
-- based on the assumptions below; they do not prove actual loss,
-- refund completion, or accounting leakage.
--
-- COUNT(DISTINCT order_id) = distinct orders represented in a flag.
-- COUNT(*) = source records/rows represented in a flag.

WITH classified_data AS (
    SELECT
        order_id,
        amount,
        CASE
            WHEN status = 'Delivered' AND amount > 0
                THEN 'Valid Revenue'
            WHEN status = 'Delivered' AND amount = 0
                THEN 'Revenue Leak'
            WHEN status IN ('Cancelled', 'Refunded', 'Returned')
                 AND amount > 0
                THEN 'Reversal Check'
            ELSE 'Review'
        END AS revenue_flag
    FROM vrinda_store_sales
),
flag_list AS (
    SELECT 'Valid Revenue' AS revenue_flag
    UNION ALL SELECT 'Revenue Leak'
    UNION ALL SELECT 'Reversal Check'
    UNION ALL SELECT 'Review'
),
flag_summary AS (
    SELECT
        revenue_flag,
        COUNT(DISTINCT order_id) AS distinct_orders,
        COUNT(*) AS total_records,
        SUM(amount) AS total_amount
    FROM classified_data
    GROUP BY revenue_flag
)
SELECT
    f.revenue_flag,
    COALESCE(s.distinct_orders, 0) AS distinct_orders,
    COALESCE(s.total_records, 0) AS total_records,
    COALESCE(s.total_amount, 0) AS total_amount
FROM flag_list AS f
LEFT JOIN flag_summary AS s
    ON f.revenue_flag = s.revenue_flag
ORDER BY FIELD(
    f.revenue_flag,
    'Valid Revenue',
    'Revenue Leak',
    'Reversal Check',
    'Review'
);

-- 3. Validate NULL and negative amounts by status
SELECT
    status,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount_records,
    SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS negative_amount_records
FROM vrinda_store_sales
GROUP BY status
ORDER BY status;

-- 4. Overall reconciliation: record count and revenue
SELECT
    COUNT(*) AS total_records,
    SUM(amount) AS total_revenue,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amount_records,
    SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS negative_amount_records
FROM vrinda_store_sales;


-- ============================================================
-- SQL-Q3: CHANNEL / CATEGORY REVENUE RANKING
-- Returns the highest-revenue category (including ties) per channel.
-- This is not a full category report: WHERE revenue_rank = 1
-- intentionally filters to top-ranked categories only.
-- ============================================================

WITH channel_category_revenue AS (
    SELECT
        channel,
        category,
        SUM(amount) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY channel
            ORDER BY SUM(amount) DESC
        ) AS revenue_rank
    FROM vrinda_store_sales
    GROUP BY channel, category
),
channel_revenue AS (
    SELECT
        channel,
        SUM(amount) AS channel_revenue
    FROM vrinda_store_sales
    GROUP BY channel
)
SELECT
    c.channel,
    c.category,
    c.total_revenue,
    s.channel_revenue,
    c.revenue_rank,
    ROUND(
        c.total_revenue / NULLIF(s.channel_revenue, 0) * 100,
        2
    ) AS revenue_contribution_pct
FROM channel_category_revenue AS c
JOIN channel_revenue AS s
    ON s.channel = c.channel
WHERE c.revenue_rank = 1
ORDER BY
    c.total_revenue DESC,
    s.channel_revenue DESC;


-- ============================================================
-- END-OF-SCRIPT RECONCILIATION REFERENCE
-- Expected baseline from the reviewed Excel/Python source:
-- total_records = 31047
-- total_revenue = 21176377.00
-- gender revenue:
--   Women = 13562773.00
--   Men   =  7613604.00
-- If results differ, investigate data source, filters, data types,
-- status/category mappings, and import consistency. Do not force-match.
