-- PHASE 1\2 : DATATYPE CONVERTION

SELECT 
    MAX(product_name_lenght),
    MAX(product_description_lenght),
    MAX(product_photos_qty),
    MAX(product_weight_g),
    MAX(product_length_cm),
    MAX(product_height_cm),
    MAX(product_width_cm)
FROM products_raw;

SELECT MAX(customer_zip_code_prefix) FROM customer_raw;
SELECT MAX(geolocation_zip_code_prefix) FROM geolocation_raw;
SELECT MAX(order_item_id) FROM order_items;
SELECT MAX(payment_sequential) FROM order_payments;
SELECT MAX(payment_installments) FROM order_payments;
SELECT MAX(seller_zip_code_prefix) FROM sellers_raw;
SELECT MAX(review_score) FROM order_reviews_raw;

ALTER TABLE order_items
MODIFY COLUMN order_item_id TINYINT;

ALTER TABLE order_payments
MODIFY COLUMN payment_sequential TINYINT,
MODIFY COLUMN payment_installments TINYINT;

ALTER TABLE order_reviews_raw
MODIFY COLUMN review_score TINYINT;

ALTER TABLE products_raw
MODIFY COLUMN product_name_lenght TINYINT,
MODIFY COLUMN product_description_lenght SMALLINT UNSIGNED,
MODIFY COLUMN product_photos_qty TINYINT,
MODIFY COLUMN product_weight_g SMALLINT UNSIGNED,
MODIFY COLUMN product_length_cm TINYINT,
MODIFY COLUMN product_height_cm TINYINT,
MODIFY COLUMN product_width_cm TINYINT;

SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'olist_ecommerce'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT 
MAX(LENGTH(customer_id)),
MAX(LENGTH(customer_unique_id)),
MAX(LENGTH(customer_city)),
MAX(LENGTH(customer_state))
FROM customer_raw;

SELECT 
MAX(LENGTH(geolocation_city)),
MAX(LENGTH(geolocation_state))
FROM geolocation_raw;

SELECT 
MAX(LENGTH(order_id)),
MAX(LENGTH(product_id)),
MAX(LENGTH(seller_id))
FROM order_items;

SELECT 
MAX(LENGTH(order_id)),
MAX(LENGTH(payment_type))
FROM order_payments;

SELECT 
MAX(LENGTH(order_id)),
MAX(LENGTH(customer_id)),
MAX(LENGTH(order_status))
FROM order_raw;

SELECT 
MAX(LENGTH(review_id)),
MAX(LENGTH(order_id)),
MAX(LENGTH(review_comment_title)),
MAX(LENGTH(review_comment_message))
FROM order_reviews_raw;

SELECT 
MAX(LENGTH(product_category_name)),
MAX(LENGTH(product_category_name_english))
FROM product_name_raw;

SELECT 
MAX(LENGTH(product_id)),
MAX(LENGTH(product_category_name))
FROM products_raw;

SELECT 
MAX(LENGTH(seller_id)),
MAX(LENGTH(seller_city)),
MAX(LENGTH(seller_state))
FROM sellers_raw;

ALTER TABLE customer_raw
MODIFY COLUMN customer_id VARCHAR(32),
MODIFY COLUMN customer_unique_id VARCHAR(32),
MODIFY COLUMN customer_city VARCHAR(50),
MODIFY COLUMN customer_state VARCHAR(2);

ALTER TABLE geolocation_raw
MODIFY COLUMN geolocation_city VARCHAR(50),
MODIFY COLUMN geolocation_state VARCHAR(2);

ALTER TABLE order_items
MODIFY COLUMN order_id VARCHAR(32),
MODIFY COLUMN product_id VARCHAR(32),
MODIFY COLUMN seller_id VARCHAR(32);

ALTER TABLE order_payments
MODIFY COLUMN order_id VARCHAR(32),
MODIFY COLUMN payment_type VARCHAR(20);

ALTER TABLE order_raw
MODIFY COLUMN order_id VARCHAR(32),
MODIFY COLUMN customer_id VARCHAR(32),
MODIFY COLUMN order_status VARCHAR(20);

ALTER TABLE order_reviews_raw
MODIFY COLUMN review_id VARCHAR(32),
MODIFY COLUMN order_id VARCHAR(32),
MODIFY COLUMN review_comment_title VARCHAR(50);

ALTER TABLE product_name_raw
MODIFY COLUMN product_category_name VARCHAR(50),
MODIFY COLUMN product_category_name_english VARCHAR(50);

ALTER TABLE products_raw
MODIFY COLUMN product_id VARCHAR(32),
MODIFY COLUMN product_category_name VARCHAR(50);

ALTER TABLE sellers_raw
MODIFY COLUMN seller_id VARCHAR(32),
MODIFY COLUMN seller_city VARCHAR(50),
MODIFY COLUMN seller_state VARCHAR(2);

