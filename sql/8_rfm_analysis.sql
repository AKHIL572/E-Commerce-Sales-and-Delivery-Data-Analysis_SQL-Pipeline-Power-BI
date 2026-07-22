-- ================================================
-- FILE: 8_rfm_analysis.sql
-- PURPOSE: RFM Customer Segmentation Analysis
-- Author: Your Name
-- Date: 2024
-- Description: Segments customers into meaningful
--              business groups based on purchase
--              behavior using RFM methodology
-- ================================================
USE olist_ecommerce;
-- ================================================
-- STEP 1: CALCULATE RAW RFM VALUES
-- Reference date: Last date in dataset
-- Dataset ends: August 31, 2018
-- ================================================
-- 1.1 First check the last order date
SELECT MAX(order_purchase_timestamp) AS last_order_date
FROM order_raw;
-- Result: Should be around August 2018
-- 1.2 Calculate raw RFM metrics per customer
CREATE OR REPLACE VIEW rfm_raw AS
SELECT c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    -- RECENCY: Days since last purchase
    -- Lower days = more recent = better
    DATEDIFF(
        '2018-08-31',
        MAX(o.order_purchase_timestamp)
    ) AS recency_days,
    -- FREQUENCY: Number of orders placed
    COUNT(DISTINCT o.order_id) AS frequency,
    -- MONETARY: Total amount spent
    ROUND(SUM(oi.price), 2) AS monetary_value,
    -- Additional metrics for context
    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS last_purchase,
    DATEDIFF(
        MAX(o.order_purchase_timestamp),
        MIN(o.order_purchase_timestamp)
    ) AS customer_lifespan_days
FROM customer_raw c
    JOIN order_raw o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id,
    c.customer_state,
    c.customer_city;
-- Verify the view
SELECT COUNT(*) AS total_customers
FROM rfm_raw;
SELECT *
FROM rfm_raw
LIMIT 10;
-- ================================================
-- STEP 2: CHECK RFM DISTRIBUTIONS
-- Understand the data before scoring
-- ================================================
-- 2.1 Recency Distribution
SELECT MIN(recency_days) AS min_recency,
    MAX(recency_days) AS max_recency,
    ROUND(AVG(recency_days), 2) AS avg_recency,
    ROUND(STDDEV(recency_days), 2) AS std_recency
FROM rfm_raw;
-- 2.2 Frequency Distribution
SELECT frequency,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM rfm_raw
GROUP BY frequency
ORDER BY frequency;
-- 2.3 Monetary Distribution
SELECT MIN(monetary_value) AS min_spend,
    MAX(monetary_value) AS max_spend,
    ROUND(AVG(monetary_value), 2) AS avg_spend,
    ROUND(STDDEV(monetary_value), 2) AS std_spend
FROM rfm_raw;
-- ================================================
-- STEP 3: ASSIGN RFM SCORES (1-5)
-- Using NTILE(5) to split customers into
-- 5 equal groups per dimension
-- ================================================
CREATE OR REPLACE VIEW rfm_scored AS
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    -- RECENCY SCORE
    -- Lower recency_days = more recent = higher score
    -- So we reverse the ranking
    6 - NTILE(5) OVER (
        ORDER BY recency_days ASC
    ) AS r_score,
    -- FREQUENCY SCORE
    -- Higher frequency = higher score
    NTILE(5) OVER (
        ORDER BY frequency ASC
    ) AS f_score,
    -- MONETARY SCORE
    -- Higher monetary = higher score
    NTILE(5) OVER (
        ORDER BY monetary_value ASC
    ) AS m_score
FROM rfm_raw;
-- Verify scores
SELECT *
FROM rfm_scored
LIMIT 20;
-- ================================================
-- STEP 4: CALCULATE COMBINED RFM SCORE
-- ================================================
CREATE OR REPLACE VIEW rfm_combined AS
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    -- Combined RFM Score (weighted)
    -- Recency weighted 40% — most important predictor
    -- Frequency weighted 30%
    -- Monetary weighted 30%
    ROUND(
        (r_score * 0.4) + (f_score * 0.3) + (m_score * 0.3),
        2
    ) AS rfm_score,
    -- Simple concatenated score for segmentation
    CONCAT(r_score, f_score, m_score) AS rfm_cell
FROM rfm_scored;
-- ================================================
-- STEP 5: CUSTOMER SEGMENTATION
-- Assign business segment based on RFM scores
-- ================================================
CREATE OR REPLACE VIEW rfm_segments AS
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    rfm_score,
    rfm_cell,
    -- BUSINESS SEGMENT ASSIGNMENT
    CASE
        -- Champions: Bought recently, buy often, spend most
        WHEN r_score >= 4
        AND f_score >= 4
        AND m_score >= 4 THEN 'Champion' -- Loyal Customers: Buy regularly with good value
        WHEN r_score >= 3
        AND f_score >= 3
        AND m_score >= 3 THEN 'Loyal Customer' -- Potential Loyalists: Recent buyers with average frequency
        WHEN r_score >= 4
        AND f_score >= 2
        AND m_score >= 2 THEN 'Potential Loyalist' -- Recent Customers: Bought recently but few times
        WHEN r_score >= 4
        AND f_score = 1 THEN 'Recent Customer' -- Promising: Recent buyer but not spending much yet
        WHEN r_score >= 3
        AND f_score = 1
        AND m_score = 1 THEN 'Promising' -- Need Attention: Above average but buying less recently
        WHEN r_score = 3
        AND f_score >= 3
        AND m_score >= 3 THEN 'Need Attention' -- About to Sleep: Below average recency and frequency
        WHEN r_score = 2
        AND f_score <= 2
        AND m_score <= 2 THEN 'About to Sleep' -- At Risk: Good customers who havent bought recently
        WHEN r_score <= 2
        AND f_score >= 3
        AND m_score >= 3 THEN 'At Risk' -- Cannot Lose Them: Made big purchases but not recently
        WHEN r_score = 1
        AND m_score >= 4 THEN 'Cannot Lose Them' -- Lost: Lowest scores across all dimensions
        WHEN r_score = 1
        AND f_score = 1
        AND m_score = 1 THEN 'Lost' -- Hibernating: Low recency and frequency
        ELSE 'Hibernating'
    END AS customer_segment,
    -- SEGMENT PRIORITY for marketing action
    CASE
        WHEN r_score >= 4
        AND f_score >= 4
        AND m_score >= 4 THEN 1
        WHEN r_score <= 2
        AND f_score >= 3
        AND m_score >= 3 THEN 2
        WHEN r_score = 1
        AND m_score >= 4 THEN 3
        WHEN r_score >= 4
        AND f_score = 1 THEN 4
        ELSE 5
    END AS action_priority
FROM rfm_combined;
-- ================================================
-- STEP 6: SEGMENT ANALYSIS
-- Understanding each customer segment
-- ================================================
-- 6.1 Segment Size and Value Summary
SELECT customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS pct_of_customers,
    ROUND(AVG(monetary_value), 2) AS avg_spend,
    ROUND(SUM(monetary_value), 2) AS total_revenue,
    ROUND(
        SUM(monetary_value) * 100.0 / SUM(SUM(monetary_value)) OVER(),
        2
    ) AS pct_of_revenue,
    ROUND(AVG(recency_days), 0) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(rfm_score), 2) AS avg_rfm_score
FROM rfm_segments
GROUP BY customer_segment
ORDER BY avg_rfm_score DESC;
-- 6.2 Champion Customers Detail
-- Most valuable customers
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    rfm_score
FROM rfm_segments
WHERE customer_segment = 'Champion'
ORDER BY monetary_value DESC
LIMIT 20;
-- 6.3 At Risk Customers
-- Good customers who haven't bought recently
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    rfm_score
FROM rfm_segments
WHERE customer_segment = 'At Risk'
ORDER BY monetary_value DESC
LIMIT 20;
-- 6.4 Cannot Lose Them
-- High value customers who are slipping away
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value
FROM rfm_segments
WHERE customer_segment = 'Cannot Lose Them'
ORDER BY monetary_value DESC;
-- ================================================
-- STEP 7: GEOGRAPHIC RFM ANALYSIS
-- Which states have best customer segments?
-- ================================================
-- 7.1 Best customer segments by state
SELECT customer_state,
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS avg_spend
FROM rfm_segments
WHERE customer_segment IN (
        'Champion',
        'Loyal Customer',
        'At Risk',
        'Cannot Lose Them'
    )
GROUP BY customer_state,
    customer_segment
ORDER BY customer_state,
    customer_count DESC;
-- 7.2 Average RFM score by state
SELECT customer_state,
    COUNT(*) AS customers,
    ROUND(AVG(rfm_score), 2) AS avg_rfm_score,
    ROUND(AVG(monetary_value), 2) AS avg_spend,
    ROUND(AVG(recency_days), 0) AS avg_recency
FROM rfm_segments
GROUP BY customer_state
ORDER BY avg_rfm_score DESC;
-- ================================================
-- STEP 8: MARKETING ACTION RECOMMENDATIONS
-- Based on RFM segments
-- ================================================
-- 8.1 Action recommendation per segment
SELECT customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary_value), 2) AS segment_revenue,
    CASE
        customer_segment
        WHEN 'Champion' THEN 'Reward them. Be early adopters of new products.'
        WHEN 'Loyal Customer' THEN 'Upsell higher value products. Ask for reviews.'
        WHEN 'Potential Loyalist' THEN 'Offer membership or loyalty program.'
        WHEN 'Recent Customer' THEN 'Provide onboarding support. Give first purchase discount.'
        WHEN 'Promising' THEN 'Create brand awareness. Offer free trials.'
        WHEN 'Need Attention' THEN 'Make limited time offers. Recommend based on purchase.'
        WHEN 'About to Sleep' THEN 'Share valuable resources. Recommend popular products.'
        WHEN 'At Risk' THEN 'Send personalized emails. Offer renewals.'
        WHEN 'Cannot Lose Them' THEN 'Win them back with exclusive deals. Talk to them.'
        WHEN 'Hibernating' THEN 'Offer relevant products and special discounts.'
        WHEN 'Lost' THEN 'Revive interest with reach out campaign. Ignore otherwise.'
    END AS recommended_action
FROM rfm_segments
GROUP BY customer_segment
ORDER BY segment_revenue DESC;
-- ================================================
-- STEP 9: RFM SCORE DISTRIBUTION ANALYSIS
-- ================================================
-- 9.1 Distribution of RFM combined scores
SELECT CASE
        WHEN rfm_score >= 4.5 THEN 'Elite (4.5-5.0)'
        WHEN rfm_score >= 4.0 THEN 'Excellent (4.0-4.5)'
        WHEN rfm_score >= 3.5 THEN 'Good (3.5-4.0)'
        WHEN rfm_score >= 3.0 THEN 'Average (3.0-3.5)'
        WHEN rfm_score >= 2.5 THEN 'Below Average (2.5-3.0)'
        WHEN rfm_score >= 2.0 THEN 'Poor (2.0-2.5)'
        ELSE 'Lost (Under 2.0)'
    END AS score_tier,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage,
    ROUND(AVG(monetary_value), 2) AS avg_spend
FROM rfm_segments
GROUP BY CASE
        WHEN rfm_score >= 4.5 THEN 'Elite (4.5-5.0)'
        WHEN rfm_score >= 4.0 THEN 'Excellent (4.0-4.5)'
        WHEN rfm_score >= 3.5 THEN 'Good (3.5-4.0)'
        WHEN rfm_score >= 3.0 THEN 'Average (3.0-3.5)'
        WHEN rfm_score >= 2.5 THEN 'Below Average (2.5-3.0)'
        WHEN rfm_score >= 2.0 THEN 'Poor (2.0-2.5)'
        ELSE 'Lost (Under 2.0)'
    END
ORDER BY MIN(rfm_score) DESC;
-- ================================================
-- STEP 10: EXPORT READY VIEW FOR POWER BI
-- Clean final view for dashboard use
-- ================================================
CREATE OR REPLACE VIEW rfm_dashboard AS
SELECT customer_unique_id,
    customer_state,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    rfm_score,
    customer_segment,
    action_priority,
    -- Segment grouping for simpler visualization
    CASE
        WHEN customer_segment IN ('Champion', 'Loyal Customer') THEN 'High Value'
        WHEN customer_segment IN (
            'Potential Loyalist',
            'Recent Customer',
            'Promising'
        ) THEN 'Growing'
        WHEN customer_segment IN ('Need Attention', 'About to Sleep') THEN 'At Risk - Low'
        WHEN customer_segment IN ('At Risk', 'Cannot Lose Them') THEN 'At Risk - High'
        ELSE 'Lost/Inactive'
    END AS segment_group
FROM rfm_segments;
-- Final verification
SELECT segment_group,
    COUNT(*) AS customers,
    ROUND(SUM(monetary_value), 2) AS total_revenue
FROM rfm_dashboard
GROUP BY segment_group
ORDER BY total_revenue DESC;