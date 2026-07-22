-- ================================================
-- FILE: 7_statistical_analysis.sql
-- PURPOSE: Statistical analysis of Olist dataset
-- Author: Your Name
-- Date: 2024
-- ================================================
USE olist_ecommerce;
-- ================================================
-- SECTION 1: DESCRIPTIVE STATISTICS
-- Basic statistical measures for key columns
-- ================================================
-- 1.1 Order Value Distribution Statistics
SELECT 'Order Price' AS metric,
    ROUND(MIN(price), 2) AS minimum,
    ROUND(MAX(price), 2) AS maximum,
    ROUND(AVG(price), 2) AS mean,
    ROUND(STDDEV(price), 2) AS std_deviation,
    ROUND(VARIANCE(price), 2) AS variance,
    ROUND(STDDEV(price) / AVG(price) * 100, 2) AS coefficient_of_variation_pct
FROM order_items;
-- 1.2 Freight Value Distribution Statistics
SELECT 'Freight Value' AS metric,
    ROUND(MIN(freight_value), 2) AS minimum,
    ROUND(MAX(freight_value), 2) AS maximum,
    ROUND(AVG(freight_value), 2) AS mean,
    ROUND(STDDEV(freight_value), 2) AS std_deviation,
    ROUND(
        STDDEV(freight_value) / AVG(freight_value) * 100,
        2
    ) AS coefficient_of_variation_pct
FROM order_items;
-- 1.3 Review Score Distribution Statistics
SELECT 'Review Score' AS metric,
    MIN(review_score) AS minimum,
    MAX(review_score) AS maximum,
    ROUND(AVG(review_score), 2) AS mean,
    ROUND(STDDEV(review_score), 2) AS std_deviation
FROM order_reviews_raw;
-- 1.4 Delivery Days Distribution Statistics
SELECT 'Delivery Days' AS metric,
    MIN(actual_delivery_days) AS minimum,
    MAX(actual_delivery_days) AS maximum,
    ROUND(AVG(actual_delivery_days), 2) AS mean,
    ROUND(STDDEV(actual_delivery_days), 2) AS std_deviation
FROM delivery_analysis;
-- ================================================
-- SECTION 2: MEDIAN CALCULATIONS
-- MySQL has no built-in MEDIAN function
-- Using ROW_NUMBER approach
-- ================================================
-- 2.1 Median Order Price
SELECT ROUND(AVG(price), 2) AS median_price
FROM (
        SELECT price,
            ROW_NUMBER() OVER (
                ORDER BY price
            ) AS rn,
            COUNT(*) OVER() AS total
        FROM order_items
    ) t
WHERE rn IN (
        FLOOR((total + 1) / 2),
        CEIL((total + 1) / 2)
    );
-- 2.2 Median Delivery Days
SELECT ROUND(AVG(actual_delivery_days), 2) AS median_delivery_days
FROM (
        SELECT actual_delivery_days,
            ROW_NUMBER() OVER (
                ORDER BY actual_delivery_days
            ) AS rn,
            COUNT(*) OVER() AS total
        FROM delivery_analysis
        WHERE actual_delivery_days IS NOT NULL
    ) t
WHERE rn IN (
        FLOOR((total + 1) / 2),
        CEIL((total + 1) / 2)
    );
-- 2.3 Median Payment Value
SELECT ROUND(AVG(payment_value), 2) AS median_payment_value
FROM (
        SELECT payment_value,
            ROW_NUMBER() OVER (
                ORDER BY payment_value
            ) AS rn,
            COUNT(*) OVER() AS total
        FROM order_payments
        WHERE payment_value > 0
    ) t
WHERE rn IN (
        FLOOR((total + 1) / 2),
        CEIL((total + 1) / 2)
    );
-- ================================================
-- SECTION 3: PERCENTILE ANALYSIS
-- Understanding data distribution
-- ================================================
-- 3.1 Order Price Percentiles
SELECT '25th Percentile (Q1)' AS percentile,
    ROUND(AVG(price), 2) AS price_value
FROM (
        SELECT price,
            PERCENT_RANK() OVER (
                ORDER BY price
            ) AS pct_rank
        FROM order_items
    ) t
WHERE pct_rank <= 0.25
UNION ALL
SELECT '50th Percentile (Median)',
    ROUND(AVG(price), 2)
FROM (
        SELECT price,
            PERCENT_RANK() OVER (
                ORDER BY price
            ) AS pct_rank
        FROM order_items
    ) t
WHERE pct_rank <= 0.50
UNION ALL
SELECT '75th Percentile (Q3)',
    ROUND(AVG(price), 2)
FROM (
        SELECT price,
            PERCENT_RANK() OVER (
                ORDER BY price
            ) AS pct_rank
        FROM order_items
    ) t
WHERE pct_rank <= 0.75
UNION ALL
SELECT '90th Percentile',
    ROUND(AVG(price), 2)
FROM (
        SELECT price,
            PERCENT_RANK() OVER (
                ORDER BY price
            ) AS pct_rank
        FROM order_items
    ) t
WHERE pct_rank <= 0.90
UNION ALL
SELECT '95th Percentile',
    ROUND(AVG(price), 2)
FROM (
        SELECT price,
            PERCENT_RANK() OVER (
                ORDER BY price
            ) AS pct_rank
        FROM order_items
    ) t
WHERE pct_rank <= 0.95;
-- ================================================
-- SECTION 4: CORRELATION ANALYSIS
-- Relationship between key business variables
-- ================================================
-- 4.1 Delivery Days vs Review Score Correlation
-- Formula: Pearson correlation coefficient
-- Range: -1 (perfect negative) to +1 (perfect positive)
SELECT ROUND(
        (
            COUNT(*) * SUM(actual_delivery_days * review_score) - SUM(actual_delivery_days) * SUM(review_score)
        ) / SQRT(
            (
                COUNT(*) * SUM(actual_delivery_days * actual_delivery_days) - SUM(actual_delivery_days) * SUM(actual_delivery_days)
            ) * (
                COUNT(*) * SUM(review_score * review_score) - SUM(review_score) * SUM(review_score)
            )
        ),
        4
    ) AS delivery_vs_review_correlation
FROM delivery_analysis da
    JOIN order_reviews_raw orr ON da.order_id = orr.order_id
WHERE da.actual_delivery_days IS NOT NULL;
-- 4.2 Price vs Review Score Correlation
SELECT ROUND(
        (
            COUNT(*) * SUM(oi.price * orr.review_score) - SUM(oi.price) * SUM(orr.review_score)
        ) / SQRT(
            (
                COUNT(*) * SUM(oi.price * oi.price) - SUM(oi.price) * SUM(oi.price)
            ) * (
                COUNT(*) * SUM(orr.review_score * orr.review_score) - SUM(orr.review_score) * SUM(orr.review_score)
            )
        ),
        4
    ) AS price_vs_review_correlation
FROM order_items oi
    JOIN order_reviews_raw orr ON oi.order_id = orr.order_id;
-- 4.3 Freight Value vs Review Score Correlation
SELECT ROUND(
        (
            COUNT(*) * SUM(oi.freight_value * orr.review_score) - SUM(oi.freight_value) * SUM(orr.review_score)
        ) / SQRT(
            (
                COUNT(*) * SUM(oi.freight_value * oi.freight_value) - SUM(oi.freight_value) * SUM(oi.freight_value)
            ) * (
                COUNT(*) * SUM(orr.review_score * orr.review_score) - SUM(orr.review_score) * SUM(orr.review_score)
            )
        ),
        4
    ) AS freight_vs_review_correlation
FROM order_items oi
    JOIN order_reviews_raw orr ON oi.order_id = orr.order_id;
-- 4.4 Delay Days vs Review Score Correlation
-- Most important business correlation
SELECT ROUND(
        (
            COUNT(*) * SUM(da.delay_days * orr.review_score) - SUM(da.delay_days) * SUM(orr.review_score)
        ) / SQRT(
            (
                COUNT(*) * SUM(da.delay_days * da.delay_days) - SUM(da.delay_days) * SUM(da.delay_days)
            ) * (
                COUNT(*) * SUM(orr.review_score * orr.review_score) - SUM(orr.review_score) * SUM(orr.review_score)
            )
        ),
        4
    ) AS delay_vs_review_correlation
FROM delivery_analysis da
    JOIN order_reviews_raw orr ON da.order_id = orr.order_id
WHERE da.delay_days IS NOT NULL;
-- ================================================
-- SECTION 5: DISTRIBUTION ANALYSIS
-- Understanding spread and skewness of data
-- ================================================
-- 5.1 Revenue Distribution by Bucket
-- Shows how orders are distributed across price ranges
SELECT CASE
        WHEN price < 50 THEN 'Under R$50'
        WHEN price BETWEEN 50 AND 100 THEN 'R$50 - R$100'
        WHEN price BETWEEN 100 AND 200 THEN 'R$100 - R$200'
        WHEN price BETWEEN 200 AND 500 THEN 'R$200 - R$500'
        WHEN price BETWEEN 500 AND 1000 THEN 'R$500 - R$1000'
        ELSE 'Above R$1000'
    END AS price_bucket,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(
        SUM(price) * 100.0 / SUM(SUM(price)) OVER(),
        2
    ) AS revenue_percentage
FROM order_items
GROUP BY CASE
        WHEN price < 50 THEN 'Under R$50'
        WHEN price BETWEEN 50 AND 100 THEN 'R$50 - R$100'
        WHEN price BETWEEN 100 AND 200 THEN 'R$100 - R$200'
        WHEN price BETWEEN 200 AND 500 THEN 'R$200 - R$500'
        WHEN price BETWEEN 500 AND 1000 THEN 'R$500 - R$1000'
        ELSE 'Above R$1000'
    END
ORDER BY MIN(price);
-- 5.2 Delivery Days Distribution by Bucket
SELECT CASE
        WHEN actual_delivery_days <= 5 THEN '0-5 days (Fast)'
        WHEN actual_delivery_days BETWEEN 6 AND 10 THEN '6-10 days (Normal)'
        WHEN actual_delivery_days BETWEEN 11 AND 20 THEN '11-20 days (Slow)'
        WHEN actual_delivery_days BETWEEN 21 AND 30 THEN '21-30 days (Very Slow)'
        ELSE 'Over 30 days (Critical)'
    END AS delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM delivery_analysis
WHERE actual_delivery_days IS NOT NULL
GROUP BY CASE
        WHEN actual_delivery_days <= 5 THEN '0-5 days (Fast)'
        WHEN actual_delivery_days BETWEEN 6 AND 10 THEN '6-10 days (Normal)'
        WHEN actual_delivery_days BETWEEN 11 AND 20 THEN '11-20 days (Slow)'
        WHEN actual_delivery_days BETWEEN 21 AND 30 THEN '21-30 days (Very Slow)'
        ELSE 'Over 30 days (Critical)'
    END
ORDER BY MIN(actual_delivery_days);
-- ================================================
-- SECTION 6: PARETO ANALYSIS (80/20 Rule)
-- ================================================
-- 6.1 Do top 20% of sellers generate 80% of revenue?
WITH seller_revenue AS (
    SELECT seller_id,
        SUM(price) AS total_revenue,
        RANK() OVER (
            ORDER BY SUM(price) DESC
        ) AS revenue_rank,
        COUNT(*) OVER() AS total_sellers
    FROM order_items
    GROUP BY seller_id
),
seller_with_cumulative AS (
    SELECT seller_id,
        total_revenue,
        revenue_rank,
        total_sellers,
        SUM(total_revenue) OVER (
            ORDER BY revenue_rank
        ) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        ROUND(revenue_rank * 100.0 / total_sellers, 2) AS seller_percentile
    FROM seller_revenue
)
SELECT seller_percentile,
    ROUND(cumulative_revenue * 100.0 / grand_total, 2) AS cumulative_revenue_pct
FROM seller_with_cumulative
WHERE seller_percentile IN (10, 20, 30, 50, 80, 100)
ORDER BY seller_percentile;
-- 6.2 Do top 20% of categories generate 80% of revenue?
WITH category_revenue AS (
    SELECT p.product_category_name,
        SUM(oi.price) AS total_revenue,
        RANK() OVER (
            ORDER BY SUM(oi.price) DESC
        ) AS revenue_rank,
        COUNT(DISTINCT p.product_category_name) OVER() AS total_categories
    FROM order_items oi
        JOIN products_raw p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT product_category_name,
    ROUND(total_revenue, 2) AS revenue,
    ROUND(
        SUM(total_revenue) OVER (
            ORDER BY revenue_rank
        ) * 100.0 / SUM(total_revenue) OVER(),
        2
    ) AS cumulative_pct
FROM category_revenue
WHERE revenue_rank <= 15
ORDER BY revenue_rank;
-- ================================================
-- SECTION 7: SEASONAL ANALYSIS
-- ================================================
-- 7.1 Day of Week Analysis
-- Which days of week have most orders?
SELECT DAYNAME(order_purchase_timestamp) AS day_of_week,
    DAYOFWEEK(order_purchase_timestamp) AS day_number,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_order_value
FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DAYNAME(order_purchase_timestamp),
    DAYOFWEEK(order_purchase_timestamp)
ORDER BY day_number;
-- 7.2 Hour of Day Analysis
-- What time do customers shop most?
SELECT HOUR(order_purchase_timestamp) AS hour_of_day,
    COUNT(order_id) AS total_orders,
    ROUND(
        COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(),
        2
    ) AS percentage
FROM order_raw
GROUP BY HOUR(order_purchase_timestamp)
ORDER BY hour_of_day;
-- 7.3 Month over Month Growth Rate
WITH monthly_revenue AS (
    SELECT YEAR(o.order_purchase_timestamp) AS yr,
        MONTH(o.order_purchase_timestamp) AS mo,
        SUM(oi.price) AS revenue
    FROM order_raw o
        JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY yr,
        mo
)
SELECT yr AS year,
    mo AS month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        LAG(revenue) OVER (
            ORDER BY yr,
                mo
        ),
        2
    ) AS prev_month_revenue,
    ROUND(
        (
            revenue - LAG(revenue) OVER (
                ORDER BY yr,
                    mo
            )
        ) * 100.0 / LAG(revenue) OVER (
            ORDER BY yr,
                mo
        ),
        2
    ) AS mom_growth_rate_pct
FROM monthly_revenue
ORDER BY yr,
    mo;
-- ================================================
-- SECTION 8: CUSTOMER SEGMENTATION STATISTICS
-- ================================================
-- 8.1 Customer Value Distribution
WITH customer_value AS (
    SELECT c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM customer_raw c
        JOIN order_raw o ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT CASE
        WHEN total_spent < 100 THEN 'Low Value (Under R$100)'
        WHEN total_spent BETWEEN 100 AND 300 THEN 'Medium Value (R$100-R$300)'
        WHEN total_spent BETWEEN 300 AND 1000 THEN 'High Value (R$300-R$1000)'
        ELSE 'Premium Value (Over R$1000)'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage,
    ROUND(AVG(total_spent), 2) AS avg_spend,
    ROUND(SUM(total_spent), 2) AS segment_revenue,
    ROUND(
        SUM(total_spent) * 100.0 / SUM(SUM(total_spent)) OVER(),
        2
    ) AS revenue_percentage
FROM customer_value
GROUP BY CASE
        WHEN total_spent < 100 THEN 'Low Value (Under R$100)'
        WHEN total_spent BETWEEN 100 AND 300 THEN 'Medium Value (R$100-R$300)'
        WHEN total_spent BETWEEN 300 AND 1000 THEN 'High Value (R$300-R$1000)'
        ELSE 'Premium Value (Over R$1000)'
    END
ORDER BY MIN(total_spent);
-- 8.2 Review Score by Delivery Status
-- Do late deliveries get worse reviews?
SELECT da.delivery_status,
    COUNT(*) AS order_count,
    ROUND(AVG(orr.review_score), 2) AS avg_review_score,
    ROUND(MIN(orr.review_score), 2) AS min_score,
    ROUND(MAX(orr.review_score), 2) AS max_score,
    ROUND(STDDEV(orr.review_score), 2) AS score_std_dev
FROM delivery_analysis da
    JOIN order_reviews_raw orr ON da.order_id = orr.order_id
GROUP BY da.delivery_status
ORDER BY avg_review_score DESC;
-- 8.3 Review Score by Delivery Speed Bucket
SELECT CASE
        WHEN actual_delivery_days <= 5 THEN '0-5 days (Fast)'
        WHEN actual_delivery_days BETWEEN 6 AND 10 THEN '6-10 days (Normal)'
        WHEN actual_delivery_days BETWEEN 11 AND 20 THEN '11-20 days (Slow)'
        WHEN actual_delivery_days BETWEEN 21 AND 30 THEN '21-30 days (Very Slow)'
        ELSE 'Over 30 days (Critical)'
    END AS delivery_speed,
    COUNT(*) AS orders,
    ROUND(AVG(orr.review_score), 2) AS avg_review_score
FROM delivery_analysis da
    JOIN order_reviews_raw orr ON da.order_id = orr.order_id
WHERE actual_delivery_days IS NOT NULL
GROUP BY CASE
        WHEN actual_delivery_days <= 5 THEN '0-5 days (Fast)'
        WHEN actual_delivery_days BETWEEN 6 AND 10 THEN '6-10 days (Normal)'
        WHEN actual_delivery_days BETWEEN 11 AND 20 THEN '11-20 days (Slow)'
        WHEN actual_delivery_days BETWEEN 21 AND 30 THEN '21-30 days (Very Slow)'
        ELSE 'Over 30 days (Critical)'
    END
ORDER BY MIN(actual_delivery_days);