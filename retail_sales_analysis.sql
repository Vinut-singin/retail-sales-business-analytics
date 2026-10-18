/*
PROJECT: Retail Sales & Business Performance Analytics
DIALECT: MySQL 8.0+
DATASET: Sample Superstore (CSV)
PURPOSE: Analyze sales, profit, orders, product/category performance, regional trends,
         monthly growth, discount impact, customer contribution, and shipping patterns.

IMPORTANT:
1. Download the Sample Superstore CSV and import it into a MySQL table named `superstore`.
2. This script assumes the CSV column names have been normalized as shown in the CREATE TABLE below.
3. If your import tool keeps spaces in column names, rename them or update query identifiers.
4. The dataset is sample data; do not present findings as real-company results.
*/

-- =========================================================
-- 0. TABLE SETUP (run only if you need to create the table)
-- =========================================================
CREATE TABLE IF NOT EXISTS superstore (
    row_id INT,
    order_id VARCHAR(30),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(30),
    country VARCHAR(80),
    city VARCHAR(80),
    state VARCHAR(80),
    postal_code VARCHAR(20),
    region VARCHAR(30),
    product_id VARCHAR(30),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(12,2),
    quantity INT,
    discount DECIMAL(6,4),
    profit DECIMAL(12,2)
);

-- =========================================================
-- 1. DATA QUALITY CHECKS
-- =========================================================

-- 1.1 Total records
SELECT COUNT(*) AS total_rows
FROM superstore;

-- 1.2 Check missing values in key fields
SELECT
    SUM(order_id IS NULL OR order_id = '') AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(product_id IS NULL OR product_id = '') AS missing_product_id,
    SUM(category IS NULL OR category = '') AS missing_category,
    SUM(sales IS NULL) AS missing_sales,
    SUM(profit IS NULL) AS missing_profit
FROM superstore;

-- 1.3 Check exact duplicate row IDs
SELECT row_id, COUNT(*) AS occurrences
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;

-- 1.4 Check suspicious values
SELECT *
FROM superstore
WHERE sales < 0 OR quantity <= 0 OR discount < 0 OR discount > 1;

-- 1.5 Date coverage
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(DISTINCT order_date) AS distinct_order_dates
FROM superstore;

-- =========================================================
-- 2. EXECUTIVE KPI SUMMARY
-- =========================================================

SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS units_sold,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM superstore;

-- =========================================================
-- 3. SALES AND PROFIT OVER TIME
-- =========================================================

-- 3.1 Monthly sales and profit
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
    ROUND(SUM(sales), 2) AS monthly_sales,
    ROUND(SUM(profit), 2) AS monthly_profit,
    COUNT(DISTINCT order_id) AS monthly_orders,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY month_start;

-- 3.2 Month-over-month sales change using LAG (MySQL 8+)
WITH monthly AS (
    SELECT
        CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS month_start,
        SUM(sales) AS monthly_sales
    FROM superstore
    GROUP BY CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE)
),
with_previous AS (
    SELECT
        month_start,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month_start) AS previous_month_sales
    FROM monthly
)
SELECT
    month_start,
    ROUND(monthly_sales, 2) AS monthly_sales,
    ROUND(previous_month_sales, 2) AS previous_month_sales,
    ROUND(monthly_sales - previous_month_sales, 2) AS sales_change,
    ROUND(100 * (monthly_sales - previous_month_sales) /
          NULLIF(previous_month_sales, 0), 2) AS mom_growth_pct
FROM with_previous
ORDER BY month_start;

-- 3.3 Year-over-year sales comparison (if the dataset spans multiple years)
SELECT
    YEAR(order_date) AS sales_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore
GROUP BY YEAR(order_date)
ORDER BY sales_year;

-- =========================================================
-- 4. PRODUCT AND CATEGORY PERFORMANCE
-- =========================================================

-- 4.1 Category performance
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

-- 4.2 Sub-category performance
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY category, sub_category
ORDER BY total_profit DESC;

-- 4.3 Top 10 products by sales
SELECT
    product_id,
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold
FROM superstore
GROUP BY product_id, product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 4.4 Bottom 10 products by profit (requires enough product records)
SELECT
    product_id,
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS units_sold
FROM superstore
GROUP BY product_id, product_name
ORDER BY total_profit ASC
LIMIT 10;

-- 4.5 Rank products by sales within each category
WITH product_sales AS (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY category, product_name
)
SELECT
    category,
    product_name,
    ROUND(total_sales, 2) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS sales_rank
FROM product_sales
ORDER BY category, sales_rank;

-- =========================================================
-- 5. REGIONAL AND GEOGRAPHICAL PERFORMANCE
-- =========================================================

-- 5.1 Region performance
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- 5.2 State performance: find strong and weak states
SELECT
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_profit ASC;

-- 5.3 City performance
SELECT
    city,
    state,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY city, state
ORDER BY total_sales DESC
LIMIT 15;

-- =========================================================
-- 6. DISCOUNT AND PROFITABILITY
-- =========================================================

-- 6.1 Profitability by discount band
SELECT
    CASE
        WHEN discount = 0 THEN '0% (No Discount)'
        WHEN discount <= 0.10 THEN '1–10%'
        WHEN discount <= 0.20 THEN '11–20%'
        WHEN discount <= 0.30 THEN '21–30%'
        ELSE 'Above 30%'
    END AS discount_band,
    COUNT(*) AS line_items,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
    ROUND(AVG(profit), 2) AS average_line_profit
FROM superstore
GROUP BY
    CASE
        WHEN discount = 0 THEN '0% (No Discount)'
        WHEN discount <= 0.10 THEN '1–10%'
        WHEN discount <= 0.20 THEN '11–20%'
        WHEN discount <= 0.30 THEN '21–30%'
        ELSE 'Above 30%'
    END
ORDER BY MIN(discount);

-- 6.2 Discount levels with negative total profit
SELECT
    category,
    sub_category,
    discount,
    COUNT(*) AS line_items,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY category, sub_category, discount
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- 6.3 Overall loss-making product groups
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- =========================================================
-- 7. CUSTOMER AND SEGMENT ANALYSIS
-- =========================================================

-- 7.1 Segment performance
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

-- 7.2 Top 10 customers by sales
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- 7.3 Customer contribution to overall sales
WITH customer_sales AS (
    SELECT customer_id, customer_name, SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(100 * total_sales / NULLIF(SUM(total_sales) OVER (), 0), 2) AS sales_contribution_pct
FROM customer_sales
ORDER BY total_sales DESC;

-- =========================================================
-- 8. SHIPPING ANALYSIS
-- =========================================================

-- 8.1 Shipping mode performance
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_days_to_ship
FROM superstore
GROUP BY ship_mode
ORDER BY total_orders DESC;

-- 8.2 Shipping duration by order (row-level)
SELECT
    order_id,
    order_date,
    ship_date,
    DATEDIFF(ship_date, order_date) AS days_to_ship,
    ship_mode
FROM superstore
WHERE order_date IS NOT NULL AND ship_date IS NOT NULL
ORDER BY days_to_ship DESC
LIMIT 20;

-- =========================================================
-- 9. BUSINESS QUESTION SUMMARY TABLES
-- =========================================================

-- 9.1 Which categories generate sales but weak profit?
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

-- 9.2 Which region-category combinations lose money?
SELECT
    region,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY region, category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- 9.3 Sales share by category
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(100 * SUM(sales) / NULLIF(SUM(SUM(sales)) OVER (), 0), 2) AS sales_share_pct
FROM superstore
GROUP BY category
ORDER BY total_sales DESC;

-- =========================================================
-- 10. OPTIONAL VIEW FOR POWER BI
-- =========================================================
CREATE OR REPLACE VIEW vw_superstore_sales AS
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit,
    DATEDIFF(ship_date, order_date) AS days_to_ship
FROM superstore;

-- End of project SQL script.
