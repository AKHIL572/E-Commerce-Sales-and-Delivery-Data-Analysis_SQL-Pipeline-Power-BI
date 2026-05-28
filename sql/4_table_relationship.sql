-- PHASE 4 : Table Relationships

-- Add primary keys

ALTER TABLE customer_raw
ADD PRIMARY KEY (customer_id);

ALTER TABLE geolocation_clean
ADD PRIMARY KEY (geolocation_zip_code_prefix);

ALTER TABLE order_raw
ADD PRIMARY KEY (order_id);

ALTER TABLE order_reviews_raw
ADD PRIMARY KEY (review_id);

-- Find the duplicate review_ids
SELECT review_id, COUNT(*) as count
FROM order_reviews_raw
GROUP BY review_id
HAVING count > 1
ORDER BY count DESC
LIMIT 10;

-- Total number of duplicate review_ids
SELECT COUNT(*) - COUNT(DISTINCT review_id) as duplicate_count
FROM order_reviews_raw;

-- See what's different between duplicate rows
SELECT * FROM order_reviews_raw
WHERE review_id = 'c444278834184f72b1484dfe47de7f97'
ORDER BY review_creation_date;

SELECT COUNT(DISTINCT order_id) as affected_orders
FROM order_reviews_raw
WHERE review_id IN (
    SELECT review_id
    FROM order_reviews_raw
    GROUP BY review_id
    HAVING COUNT(*) > 1
);

ALTER TABLE order_reviews_raw
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

SELECT * FROM order_reviews_raw LIMIT 5;

ALTER TABLE product_name_raw
ADD PRIMARY KEY (product_category_name);

ALTER TABLE products_raw
ADD PRIMARY KEY (product_id);

ALTER TABLE sellers_raw
ADD PRIMARY KEY (seller_id);

-- Composite keys

ALTER TABLE order_items
ADD PRIMARY KEY (order_id, order_item_id);

ALTER TABLE order_payments
ADD PRIMARY KEY (order_id, payment_sequential);

-- Foreign Keys

ALTER TABLE order_items
ADD FOREIGN KEY (order_id)
REFERENCES order_raw(order_id);

ALTER TABLE order_items
ADD FOREIGN KEY (product_id)
REFERENCES products_raw(product_id);

ALTER TABLE order_items
ADD FOREIGN KEY (seller_id)
REFERENCES sellers_raw(seller_id);

ALTER TABLE order_payments
ADD FOREIGN KEY (order_id)
REFERENCES order_raw(order_id);

ALTER TABLE order_raw
ADD FOREIGN KEY (customer_id)
REFERENCES customer_raw(customer_id);

ALTER TABLE order_reviews_raw
ADD FOREIGN KEY (order_id)
REFERENCES order_raw(order_id);


-- Step 1: Add 'unknown' to product_name_raw
INSERT INTO product_name_raw (product_category_name, product_category_name_english)
VALUES ('unknown', 'unknown');

-- Step 2: Verify it was added
SELECT * FROM product_name_raw 
WHERE product_category_name = 'unknown';

ALTER TABLE products_raw
ADD FOREIGN KEY (product_category_name)
REFERENCES product_name_raw(product_category_name);

SELECT COUNT(*) FROM products_raw
WHERE product_category_name = 'unknown';

SELECT COUNT(*) FROM product_name_raw
WHERE product_category_name = 'unknown';

-- Find ALL values in products_raw that don't exist in product_name_raw
SELECT DISTINCT p.product_category_name
FROM products_raw p
LEFT JOIN product_name_raw pn 
ON p.product_category_name = pn.product_category_name
WHERE pn.product_category_name IS NULL;

SELECT product_category_name, COUNT(*) as count
FROM products_raw
WHERE product_category_name IN ('pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos')
GROUP BY product_category_name;

-- Add missing categories
INSERT INTO product_name_raw (product_category_name, product_category_name_english)
VALUES 
('pc_gamer', 'pc_gamer'),
('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

-- Verify they were added
SELECT * FROM product_name_raw 
WHERE product_category_name IN ('pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos');

-- Now retry the foreign key
ALTER TABLE products_raw
ADD FOREIGN KEY (product_category_name)
REFERENCES product_name_raw(product_category_name);


-- GIVING CASCADE RULE

ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_1;
ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_2;
ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_3;
ALTER TABLE order_payments DROP FOREIGN KEY order_payments_ibfk_1;
ALTER TABLE order_raw DROP FOREIGN KEY order_raw_ibfk_1;
ALTER TABLE order_reviews_raw DROP FOREIGN KEY order_reviews_raw_ibfk_1;
ALTER TABLE products_raw DROP FOREIGN KEY products_raw_ibfk_1;


SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'olist_ecommerce'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- order_raw → customer_raw
ALTER TABLE order_raw
ADD FOREIGN KEY (customer_id) 
REFERENCES customer_raw(customer_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- order_items → order_raw
ALTER TABLE order_items
ADD FOREIGN KEY (order_id) 
REFERENCES order_raw(order_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- order_items → products_raw
ALTER TABLE order_items
ADD FOREIGN KEY (product_id) 
REFERENCES products_raw(product_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- order_items → sellers_raw
ALTER TABLE order_items
ADD FOREIGN KEY (seller_id) 
REFERENCES sellers_raw(seller_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- order_payments → order_raw
ALTER TABLE order_payments
ADD FOREIGN KEY (order_id) 
REFERENCES order_raw(order_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- order_reviews_raw → order_raw
ALTER TABLE order_reviews_raw
ADD FOREIGN KEY (order_id) 
REFERENCES order_raw(order_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- products_raw → product_name_raw
ALTER TABLE products_raw
ADD FOREIGN KEY (product_category_name) 
REFERENCES product_name_raw(product_category_name)
ON DELETE RESTRICT
ON UPDATE CASCADE;


-- INDEX FOR FOREIGN KEYS

CREATE INDEX idx_order_customer 
ON order_raw(customer_id);

CREATE INDEX idx_orderitems_order 
ON order_items(order_id);

CREATE INDEX idx_orderitems_product 
ON order_items(product_id);

CREATE INDEX idx_orderitems_seller 
ON order_items(seller_id);

CREATE INDEX idx_orderpayments_order 
ON order_payments(order_id);

CREATE INDEX idx_orderreviews_order 
ON order_reviews_raw(order_id);

CREATE INDEX idx_products_category 
ON products_raw(product_category_name);

-- INDEX FOR FEQUENTLY FILTERED COLUMN

CREATE INDEX idx_order_status 
ON order_raw(order_status);

CREATE INDEX idx_order_purchase 
ON order_raw(order_purchase_timestamp);

CREATE INDEX idx_review_score 
ON order_reviews_raw(review_score);

CREATE INDEX idx_customer_state 
ON customer_raw(customer_state);

CREATE INDEX idx_seller_state 
ON sellers_raw(seller_state);

CREATE INDEX idx_geolocation_zip 
ON geolocation_clean(geolocation_zip_code_prefix);

SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'olist_ecommerce'
AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME;


-- Try to delete a customer who has orders
-- This SHOULD fail with foreign key error
DELETE FROM customer_raw 
WHERE customer_id = (
    SELECT customer_id 
    FROM order_raw 
    LIMIT 1
);

-- Try to insert an order with non-existent customer
-- This SHOULD fail with foreign key error
INSERT INTO order_raw (order_id, customer_id, order_status)
VALUES ('test_order_123', 'non_existent_customer_xyz', 'created');

-- Verify normal operations still work
SELECT COUNT(*) FROM order_raw;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;