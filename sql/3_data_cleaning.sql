-- PHASE 3 : DATA CLEANING

USE olist_ecommerce;

SELECT 
customer_id,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state,
COUNT(*) AS count
FROM customer_raw
GROUP BY 
customer_id,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state
HAVING count > 1;

SELECT 
geolocation_zip_code_prefix,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state,
COUNT(*) as count
FROM geolocation_raw
GROUP BY
geolocation_zip_code_prefix,
geolocation_lat,
geolocation_lng,
geolocation_city,
geolocation_state
HAVING count > 1;

SELECT 
order_id,
order_item_id,
product_id,
seller_id,
price,
freight_value,
shipping_limit_date,
COUNT(*) AS count
FROM order_items
GROUP BY 
order_id,
order_item_id,
product_id,
seller_id,
price,
freight_value,
shipping_limit_date
HAVING count > 1;

SELECT 
order_id,
payment_sequential,
payment_type,
payment_installments,
payment_value,
COUNT(*) AS count
FROM order_payments
GROUP BY
order_id,
payment_sequential,
payment_type,
payment_installments,
payment_value
HAVING count > 1;

SELECT
order_id,
customer_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated,
COUNT(*) AS count
FROM order_raw
GROUP BY 
order_id,
customer_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated
HAVING count > 1;

SELECT
review_id,
order_id,
review_score,
review_comment_title,
review_comment_message,
review_creation_date,
review_answer_timestamp,
COUNT(*) AS count
FROM order_reviews_raw
GROUP BY
review_id,
order_id,
review_score,
review_comment_title,
review_comment_message,
review_creation_date,
review_answer_timestamp
HAVING count > 1;

SELECT
product_category_name,
product_category_name_english,
COUNT(*) AS count
FROM product_name_raw
GROUP BY
product_category_name,
product_category_name_english
HAVING count > 1;

SELECT
product_id,
product_category_name,
product_name_lenght,
product_description_lenght,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm,
COUNT(*) AS count
FROM products_raw
GROUP BY
product_id,
product_category_name,
product_name_lenght,
product_description_lenght,
product_photos_qty,
product_weight_g,
product_length_cm,
product_height_cm,
product_width_cm
HAVING count > 1;

SELECT
seller_id,
seller_zip_code_prefix,
seller_city,
seller_state,
COUNT(*) AS count
FROM sellers_raw
GROUP BY
seller_id,
seller_zip_code_prefix,
seller_city,
seller_state
HAVING count > 1;


CREATE TABLE geolocation_clean AS
SELECT
geolocation_zip_code_prefix,
AVG(geolocation_lat) as geolocation_lat,
AVG(geolocation_lng) AS geolocation_lng,
MIN(geolocation_city) AS geolocation_city,
MIN(geolocation_state) AS geolocation_state
FROM geolocation_raw
GROUP BY geolocation_zip_code_prefix;

SELECT COUNT(*) FROM geolocation_raw;
SELECT COUNT(*) FROM geolocation_clean;

SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'geolocation_clean'
AND TABLE_SCHEMA = 'olist_ecommerce';


SELECT 
SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) as customer_id_nulls,
SUM(CASE WHEN customer_unique_id IS NULL OR customer_unique_id = '' THEN 1 ELSE 0 END) as customer_unique_id_nulls,
SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) as customer_zip_code_prefix_nulls,
SUM(CASE WHEN customer_city IS NULL OR customer_city = '' THEN 1 ELSE 0 END) as customer_city_nulls,
SUM(CASE WHEN customer_state IS NULL OR customer_state IS NULL OR customer_state = '' THEN 1 ELSE 0 END) as customer_state_nulls
FROM customer_raw;

SELECT
SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) as geolocation_zip_code_prefix_nulls,
SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS geolocation_lat_nulls,
SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS geolocation_lng_nulls,
SUM(CASE WHEN geolocation_city IS NULL OR geolocation_city = '' THEN 1 ELSE 0 END) AS geolocation_city_nulls,
SUM(CASE WHEN geolocation_state IS NULL OR geolocation_state = '' THEN 1 ELSE 0 END) AS geolocation_state_nulls
FROM geolocation_raw;

SELECT
SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) as order_id_nulls,
SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) as order_item_id_nulls,
SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) as product_id_nulls,
SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) as seller_id_nulls,
SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) as price_nulls,
SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) as freight_value_nulls,
SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) as shipping_nulls
FROM order_items;

SELECT
SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) as order_id_nulls,
SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) as payment_sequential_nulls,
SUM(CASE WHEN payment_type IS NULL OR payment_type = '' THEN 1 ELSE 0 END) as paymnent_type_nulls,
SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) as payment_installments_nulls,
SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) as payment_value_nulls
FROM order_payments;

SELECT 
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) as order_id_nulls,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) as customer_id_nulls,
    SUM(CASE WHEN order_status IS NULL OR order_status = '' THEN 1 ELSE 0 END) as status_nulls,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) as purchase_nulls,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) as approved_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) as carrier_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as customer_nulls,
    SUM(CASE WHEN order_estimated IS NULL THEN 1 ELSE 0 END) as estimated_nulls
FROM order_raw;

SELECT 
    SUM(CASE WHEN review_id IS NULL OR review_id = '' THEN 1 ELSE 0 END) as review_id_nulls,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) as order_id_nulls,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) as score_nulls,
    SUM(CASE WHEN review_comment_title IS NULL OR review_comment_title = '' THEN 1 ELSE 0 END) as title_nulls,
    SUM(CASE WHEN review_comment_message IS NULL OR review_comment_message = '' THEN 1 ELSE 0 END) as message_nulls,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) as creation_nulls,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) as answer_nulls
FROM order_reviews_raw;

SELECT 
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) as category_name_nulls,
    SUM(CASE WHEN product_category_name_english IS NULL OR product_category_name_english = '' THEN 1 ELSE 0 END) as category_english_nulls
FROM product_name_raw;

SELECT 
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) as product_id_nulls,
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) as category_nulls,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) as name_length_nulls,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) as desc_length_nulls,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) as photos_nulls,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) as weight_nulls,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) as length_nulls,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) as height_nulls,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) as width_nulls
FROM products_raw;

SELECT 
    SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) as seller_id_nulls,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) as zip_nulls,
    SUM(CASE WHEN seller_city IS NULL OR seller_city = '' THEN 1 ELSE 0 END) as city_nulls,
    SUM(CASE WHEN seller_state IS NULL OR seller_state = '' THEN 1 ELSE 0 END) as state_nulls
FROM sellers_raw;


SELECT COUNT(*) as total_products FROM products_raw;

SELECT * FROM products_raw 
WHERE product_category_name IS NULL 
OR product_category_name = ''
LIMIT 10;

SELECT COUNT(*) 
FROM order_items oi
JOIN products_raw p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NULL 
OR p.product_category_name = '';

SET SQL_SAFE_UPDATES = 0;

UPDATE products_raw
SET product_category_name = 'Unknown'
WHERE product_category_name = 'UNKNOWN';

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) 
FROM products_raw
WHERE product_category_name = 'unknown';

SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';


SET SQL_SAFE_UPDATES = 0;

UPDATE geolocation_raw
SET geolocation_city = CONVERT(CAST(CONVERT(geolocation_city USING latin1) AS BINARY) USING utf8mb4)
WHERE geolocation_city LIKE '%Ã%';

SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT geolocation_city 
FROM geolocation_raw 
WHERE geolocation_city LIKE '%Ã%'
LIMIT 10;

-- Step 1: Drop both tables
DROP TABLE geolocation_raw;
DROP TABLE geolocation_clean;

-- Step 2: Recreate geolocation_raw
CREATE TABLE geolocation_raw (
    geolocation_zip_code_prefix INT,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

LOAD DATA LOCAL INFILE 'C:/csv/olist_geolocation_dataset.csv'
INTO TABLE geolocation_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 4: Immediately verify encoding
SELECT DISTINCT geolocation_city 
FROM geolocation_raw 
WHERE geolocation_city LIKE '%ã%'
OR geolocation_city LIKE '%ão%'
LIMIT 10;

-- Check how many rows have each problem
SELECT 
    SUM(CASE WHEN geolocation_city LIKE '%ã%' OR 
                  geolocation_city LIKE '%ã%' OR
                  geolocation_city LIKE '%í%' OR
                  geolocation_city LIKE '%ó%' THEN 1 ELSE 0 END) as correct_special_chars,
    SUM(CASE WHEN geolocation_city LIKE '%Ã%' OR 
                  geolocation_city LIKE '%£%' THEN 1 ELSE 0 END) as corrupted,
    SUM(CASE WHEN geolocation_city NOT LIKE '%ã%' AND
                  geolocation_city NOT LIKE '%Ã%' AND
                  geolocation_city NOT LIKE '%£%' THEN 1 ELSE 0 END) as plain_text,
    COUNT(*) as total
FROM geolocation_raw;

-- payment_type
SELECT payment_type, COUNT(*) as count
FROM order_payments
GROUP BY payment_type
ORDER BY count DESC;

-- payment_installments
SELECT payment_installments, COUNT(*) as count
FROM order_payments
GROUP BY payment_installments
ORDER BY count DESC;

-- review_score
SELECT review_score, COUNT(*) as count
FROM order_reviews_raw
GROUP BY review_score
ORDER BY count DESC;

-- customer_state
SELECT customer_state, COUNT(*) as count
FROM customer_raw
GROUP BY customer_state
ORDER BY count DESC;

-- seller_state
SELECT seller_state, COUNT(*) as count
FROM sellers_raw
GROUP BY seller_state
ORDER BY count DESC;

-- geolocation_state
SELECT geolocation_state, COUNT(*) as count
FROM geolocation_raw
GROUP BY geolocation_state
ORDER BY count DESC;

-- product_photos_qty
SELECT product_photos_qty, COUNT(*) as count
FROM products_raw
GROUP BY product_photos_qty
ORDER BY count DESC;

-- geolocation boundaries (Brazil is between these coordinates)
SELECT COUNT(*) as out_of_bounds
FROM geolocation_raw
WHERE geolocation_lat < -33.75 OR geolocation_lat > 5.27
OR geolocation_lng < -73.99 OR geolocation_lng > -28.85;

SELECT * FROM order_payments
WHERE payment_type = 'not_defined';

-- Check 0 installment orders
SELECT * FROM order_payments
WHERE payment_installments = 0;

-- Check out of bounds coordinates
SELECT * FROM geolocation_raw
WHERE geolocation_lat < -33.75 OR geolocation_lat > 5.27
OR geolocation_lng < -73.99 OR geolocation_lng > -28.85;

-- Document findings
-- 3 orders with not_defined payment type, value = 0
-- 2 orders with 0 installments, likely data entry error

SET SQL_SAFE_UPDATES = 0;

DELETE FROM geolocation_raw
WHERE geolocation_lat < -33.75 OR geolocation_lat > 5.27
OR geolocation_lng < -73.99 OR geolocation_lng > -28.85;

SET SQL_SAFE_UPDATES=1;

CREATE TABLE geolocation_clean AS
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) as geolocation_lat,
    AVG(geolocation_lng) as geolocation_lng,
    MIN(geolocation_city) as geolocation_city,
    MIN(geolocation_state) as geolocation_state
FROM geolocation_raw
GROUP BY geolocation_zip_code_prefix;


-- Orders in order_items that don't exist in order_raw
SELECT COUNT(*) FROM order_items oi
LEFT JOIN order_raw o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Orders in order_payments that don't exist in order_raw
SELECT COUNT(*) FROM order_payments op
LEFT JOIN order_raw o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Products in order_items that don't exist in products_raw
SELECT COUNT(*) FROM order_items oi
LEFT JOIN products_raw p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Sellers in order_items that don't exist in sellers_raw
SELECT COUNT(*) FROM order_items oi
LEFT JOIN sellers_raw s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Customers in order_raw that don't exist in customer_raw
SELECT COUNT(*) FROM order_raw o
LEFT JOIN customer_raw c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orders where approval came before purchase (impossible!)
SELECT COUNT(*) FROM order_raw
WHERE order_approved_at < order_purchase_timestamp;

-- Orders where delivery came before shipping (impossible!)
SELECT COUNT(*) FROM order_raw
WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- Orders where estimated delivery is before purchase (impossible!)
SELECT COUNT(*) FROM order_raw
WHERE order_estimated < order_purchase_timestamp;


-- Extremely high prices
SELECT * FROM order_items
WHERE price > 5000
ORDER BY price DESC
LIMIT 10;

-- Extremely high freight values
SELECT * FROM order_items
WHERE freight_value > 500
ORDER BY freight_value DESC
LIMIT 10;

-- Extremely heavy products
SELECT * FROM products_raw
WHERE product_weight_g > 30000
ORDER BY product_weight_g DESC
LIMIT 10;