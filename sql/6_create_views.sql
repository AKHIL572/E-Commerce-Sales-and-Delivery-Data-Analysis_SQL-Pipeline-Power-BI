-- PHASE 6 : CREATE VIEWS


 USE olist_ecommerce;
-- =========================================================
-- VIEW 1 : SALES SUMMARY
-- Purpose:
-- Main dashboard dataset for revenue & sales analysis
-- =========================================================

CREATE OR REPLACE VIEW sales_summary AS
SELECT
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    o.order_status,
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    pay.payment_type,
    pay.total_payment_value,
    pay.avg_installments,
    oi.order_item_id,
    oi.product_id,
    pr.product_category_name,
    pn.product_category_name_english,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value
FROM order_raw o
JOIN customer_raw c
ON o.customer_id = c.customer_id
JOIN (
    SELECT
        order_id,
        MAX(payment_type) AS payment_type,
        SUM(payment_value) AS total_payment_value,
        AVG(payment_installments) AS avg_installments
    FROM order_payments
    GROUP BY order_id
) pay
ON o.order_id = pay.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products_raw pr ON oi.product_id = pr.product_id
LEFT JOIN product_name_raw pn ON pr.product_category_name = pn.product_category_name;


-- =========================================================
-- VIEW 2 : DELIVERY ANALYSIS
-- Purpose:
-- Delivery performance & delay analysis
-- =========================================================

CREATE OR REPLACE VIEW delivery_analysis AS
SELECT
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    c.customer_state,
    c.customer_city,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated,
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS actual_delivery_days,
    DATEDIFF(o.order_estimated, o.order_purchase_timestamp) AS estimated_delivery_days,
    DATEDIFF(o.order_delivered_customer_date, o.order_estimated) AS delay_days,
    
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated THEN 'Late'
        WHEN o.order_delivered_customer_date <= o.order_estimated THEN 'On Time'
        ELSE 'Unknown'
    END AS delivery_status
FROM order_raw o
JOIN customer_raw c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL;



-- =========================================================
-- VIEW 3 : CUSTOMER ANALYSIS
-- Purpose:
-- Customer spending & behavior analysis
-- =========================================================

CREATE OR REPLACE VIEW customer_analysis AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    ROUND(SUM(oi.price), 2) AS total_spent,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    
    MIN(o.order_purchase_timestamp) AS first_order,
    MAX(o.order_purchase_timestamp) AS last_order,

    DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) AS customer_lifetime_days
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city;
    
-- =========================================================
-- VIEW 4 : PRODUCT ANALYSIS
-- Purpose:
-- Product/category performance analysis
-- =========================================================

CREATE OR REPLACE VIEW product_analysis AS
SELECT
    pr.product_id,
    pr.product_category_name,
    pn.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price,
    ROUND(AVG(DISTINCT orr.review_score), 2) AS avg_review_score,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_value,
    ROUND(AVG(pr.product_weight_g), 2) AS avg_weight_g
FROM products_raw pr
JOIN order_items oi ON pr.product_id = oi.product_id
LEFT JOIN product_name_raw pn ON pr.product_category_name = pn.product_category_name
LEFT JOIN order_reviews_raw orr ON oi.order_id = orr.order_id
GROUP BY
    pr.product_id,
    pr.product_category_name,
    pn.product_category_name_english;
    
    
-- =========================================================
-- VIEW 5 : PAYMENT ANALYSIS
-- Purpose:
-- Payment trends & installment analysis
-- =========================================================

CREATE OR REPLACE VIEW payment_analysis AS
SELECT
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    o.order_status,
    c.customer_state,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    CASE
        WHEN p.payment_installments = 1 THEN 'Single Payment'
        WHEN p.payment_installments BETWEEN 2 AND 6 THEN 'Medium Installments'
        ELSE 'High Installments'
    END AS installment_category
FROM order_raw o
JOIN order_payments p ON o.order_id = p.order_id
JOIN customer_raw c ON o.customer_id = c.customer_id;


SELECT COUNT(*) FROM sales_summary;
SELECT COUNT(*) FROM delivery_analysis;
SELECT COUNT(*) FROM customer_analysis;
SELECT COUNT(*) FROM product_analysis;
SELECT COUNT(*) FROM payment_analysis;


SELECT * FROM sales_summary;
SELECT * FROM delivery_analysis;
SELECT * FROM customer_analysis;
SELECT * FROM product_analysis;
SELECT * FROM payment_analysis;

SELECT COUNT(DISTINCT order_id)
FROM order_raw;

SELECT COUNT(DISTINCT order_id)
FROM sales_summary;

CREATE OR REPLACE VIEW customer_payment_analysis AS
SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    o.order_status,
    p.payment_type,
    p.payment_value,
    p.payment_installments,
    CASE
        WHEN p.payment_installments = 1
        THEN 'Single Payment'
        WHEN p.payment_installments BETWEEN 2 AND 6
        THEN 'Medium Installments'
        ELSE 'High Installments'
    END AS installment_category,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,

    -- Pre-calculated total spent per customer
    cs.total_spent,
    cs.total_orders,
    cs.avg_order_value

FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
JOIN order_payments p ON o.order_id = p.order_id
JOIN order_items oi ON o.order_id = oi.order_id
-- Subquery to get pre-calculated customer totals
JOIN (
    SELECT
        c2.customer_unique_id,
        ROUND(SUM(oi2.price), 2) AS total_spent,
        COUNT(DISTINCT o2.order_id) AS total_orders,
        ROUND(
            SUM(oi2.price) / COUNT(DISTINCT o2.order_id)
        , 2) AS avg_order_value
    FROM customer_raw c2
    JOIN order_raw o2 ON c2.customer_id = o2.customer_id
    JOIN order_items oi2 ON o2.order_id = oi2.order_id
    GROUP BY c2.customer_unique_id
) cs ON c.customer_unique_id = cs.customer_unique_id;

SELECT COUNT(*) FROM customer_payment_analysis;
SELECT * FROM customer_payment_analysis;

SHOW VARIABLES LIKE "secure_file_priv";

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_payment_analysis.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM customer_payment_analysis;

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_summary.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM sales_summary;

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/delivery_analysis.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM delivery_analysis;

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_analysis.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM customer_analysis;

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_analysis.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM product_analysis;


SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payment_analysis.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM payment_analysis;