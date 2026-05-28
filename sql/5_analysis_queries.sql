-- PHASE 5 : ANALYSIS

USE olist_ecommerce;

-- 1. How many orders are there for each order status?
SELECT order_status, COUNT(order_id) as Total
FROM order_raw
GROUP BY order_status
ORDER BY Total DESC;

-- 2. What is the total number of customers in each state?
SELECT customer_state, COUNT(customer_unique_id) as Total
FROM customer_raw
GROUP BY customer_state
ORDER BY Total DESC
LIMIT 10;

-- 3. What are the top 10 product categories by number of products available in the store?
SELECT product_category_name, COUNT(product_id) as Count
FROM products_raw
GROUP BY product_category_name
ORDER BY Count DESC
LIMIT 10;

-- 4. What is the total number of orders placed each year and month?
SELECT YEAR(order_purchase_timestamp) as Year,MONTH(order_purchase_timestamp) as Month, COUNT(order_id) as Total
FROM order_raw
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY Year, Month;

-- 5. How many orders were delivered late? meaning delivered after the estimated delivery date?
SELECT COUNT(order_id) as late_delivered_count 
FROM order_raw
WHERE order_estimated < order_delivered_customer_date AND order_delivered_customer_date IS NOT NULL;

-- 6. What is the average time in days between order purchase and actual delivery?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) as Average_Time_Taken
FROM order_raw
WHERE order_delivered_customer_date IS NOT NULL;

-- 7. What is the total revenue generated from all orders?
SELECT SUM(price) as Total_Revenue
FROM order_items;

-- 8. What is the most used payment method and how many times was each used?
SELECT payment_type, COUNT(order_id) as Count
FROM order_payments
GROUP BY payment_type
ORDER BY Count DESC;

-- 9. What is the average number of installments used by customers?
SELECT AVG(payment_installments) as Average
FROM order_payments;

-- 10. What is the distribution of review scores? meaning how many reviews for each score 1 to 5?
SELECT review_score, COUNT(review_id) as Distribution
FROM order_reviews_raw
GROUP BY review_score;

-- 11. What is the average review score overall?
SELECT AVG(review_score) as Average_review_score
FROM order_reviews_raw;

-- 12. How many reviews have comments and how many don't?
SELECT 
SUM(CASE WHEN review_comment_message IS NOT NULL AND review_comment_message != '' THEN 1 ELSE 0 END) as Has_comment,
SUM(CASE WHEN review_comment_message IS NULL OR review_comment_message = '' THEN 1 ELSE 0 END) as Has_no_comment
FROM order_reviews_raw;

-- 13. What is the average price of products sold?
SELECT AVG(price) as Average_price
FROM order_items;

-- 14. What is the average freight value?

SELECT AVG(freight_value) as average
FROM order_items;

-- 15. What is the most expensive product ever sold?
SELECT p.product_category_name, o.price
FROM order_items o
JOIN products_raw P ON o.product_id = p.product_id
ORDER BY o.price DESC
LIMIT 1;

-- 16. What is the average product weight in grams?
SELECT AVG(product_weight_g) as average
FROM products_raw;

-- 17. How many products have missing category name? (we already fixed this but write the query anyway for practice)
SELECT COUNT(product_id) as missing_name
FROM products_raw
WHERE product_category_name IS NULL OR product_category_name = '';

-- 18. How many sellers are there in each state?
SELECT seller_state, COUNT(seller_id) as Number_of_sellers
FROM sellers_raw
GROUP BY seller_state
ORDER BY Number_of_sellers DESC;

-- 19. Which state has the most sellers?
SELECT seller_state, COUNT(seller_id) as Count
FROM sellers_raw
GROUP BY seller_state
ORDER BY Count DESC
LIMIT 1;

-- 20. How many unique customers are there in total?
SELECT COUNT(DISTINCT customer_unique_id) as count
FROM customer_raw;

-- 21. Which city has the most customers?
SELECT customer_city, COUNT(customer_unique_id) as Count
FROM customer_raw
GROUP BY customer_city
ORDER BY Count DESC
LIMIT 1;

-- 22. How many unique zip codes are there in each state?
SELECT geolocation_state, COUNT(DISTINCT geolocation_zip_code_prefix) as Count
FROM geolocation_clean
GROUP BY geolocation_state
ORDER BY Count DESC;



-- LEVEL 2 : JOINS

-- Customer + Order Analysis
-- 1. Which Brazilian states have the highest number of orders? Show state and total orders for top 10 states.
SELECT c.customer_state, COUNT(o.order_id) as total_orders
FROM customer_raw c 
JOIN order_raw o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;

-- 2. What is the total revenue generated per customer state? Show top 10 states by revenue. (hint: customer_raw + order_raw + order_items)
SELECT c.customer_state, SUM(oi.price) as total_revenue
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Which cities have the highest number of orders? Show top 10 cities.
SELECT c.customer_city, COUNT(o.order_id) as Count
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY Count DESC
LIMIT 10;

-- Order + Payment Analysis
-- 4. What is the total revenue per payment type? Show all payment types and their total revenue.
SELECT op.payment_type, SUM(oi.price) as total_revenue
FROM order_payments op
JOIN order_items oi ON op.order_id = oi.order_id
GROUP BY op.payment_type
ORDER BY total_revenue DESC;

-- 5. What is the average payment value per order status? (hint: order_raw + order_payments)
SELECT os.order_status, AVG(op.payment_value) as Average_value
FROM order_raw os
JOIN order_payments op ON os.order_id = op.order_id
GROUP BY os.order_status
ORDER BY Average_value DESC;

-- Order + Review Analysis
-- 6. What is the average review score for each order status? (hint: order_raw + order_reviews_raw)
SELECT os.order_status, AVG(orr.review_score) as average_score
FROM order_raw os
JOIN order_reviews_raw orr ON os.order_id = orr.order_id
GROUP BY os.order_status
ORDER BY average_score DESC;

-- 7. How many orders have reviews and how many don't? (hint: order_raw + order_reviews_raw using LEFT JOIN)
SELECT
SUM(CASE WHEN orr.order_id IS NOT NULL THEN 1 ELSE 0 END) as has_review,
SUM(CASE WHEN orr.order_id IS NULL THEN 1 ELSE 0 END) as has_no_review
FROM order_raw o
LEFT JOIN order_reviews_raw orr ON o.order_id = orr.order_id;

-- Product + Order Analysis
-- 8. What are the top 10 best selling product categories by number of items sold? (hint: order_items + products_raw)
SELECT p.product_category_name, COUNT(oi.order_item_id) as Count
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY Count DESC
LIMIT 10;

-- 9. What is the total revenue generated per product category? Show top 10 categories. (hint: order_items + products_raw)
SELECT p.product_category_name, SUM(oi.price) as total_revenue
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 10. What is the average review score per product category? Show top 10 highest rated categories. (hint: order_reviews_raw + order_items + products_raw)
SELECT p.product_category_name, AVG(orr.review_score) as average_score
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN order_reviews_raw orr ON oi.order_id = orr.order_id
GROUP BY p.product_category_name
ORDER BY average_score DESC
LIMIT 10;

-- Seller Analysis
-- 11. Who are the top 10 sellers by total revenue? Show seller_id and total revenue. (hint: order_items + sellers_raw)
SELECT s.seller_id, SUM(oi.price) as total_revenue
FROM sellers_raw s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- 12. Which seller state generates the most revenue? (hint: order_items + sellers_raw)
SELECT s.seller_state, SUM(oi.price) as revenue
FROM sellers_raw s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC
LIMIT 1;

-- 13. How many orders does each seller have on average? (hint: order_items + sellers_raw)
SELECT AVG(order_count) as avg_orders_per_seller
FROM (
    SELECT s.seller_id, COUNT(oi.order_id) as order_count
    FROM sellers_raw s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_id
) as seller_counts;

-- Delivery Analysis
-- 14. What is the average delivery time in days per customer state? Show top 10 slowest states. (hint: order_raw + customer_raw)
SELECT c.customer_state, 
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) as avg_days
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_days DESC
LIMIT 10;

-- 15. Which product categories have the most late deliveries? Show top 10. (hint: order_raw + order_items + products_raw)
SELECT p.product_category_name, COUNT(o.order_id) as late_deliveries
FROM order_raw o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products_raw p ON oi.product_id = p.product_id
WHERE o.order_delivered_customer_date > o.order_estimated
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY late_deliveries DESC
LIMIT 10;

-- Payment + Product Analysis
-- 16. What is the most popular payment type for each product category? (hint: order_items + products_raw + order_payments)
SELECT product_category_name, payment_type, payment_count
FROM (
    SELECT p.product_category_name, 
           op.payment_type,
           COUNT(*) as payment_count,
           ROW_NUMBER() OVER (PARTITION BY p.product_category_name 
                             ORDER BY COUNT(*) DESC) as rn
    FROM products_raw p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN order_payments op ON oi.order_id = op.order_id
    GROUP BY p.product_category_name, op.payment_type
) ranked
WHERE rn = 1
ORDER BY payment_count DESC
LIMIT 10;

-- Customer + Seller Geography
-- 17. Show the number of sellers and customers in each state together in one result. (hint: customer_raw + sellers_raw using separate counts)
SELECT 
    COALESCE(s.seller_state, c.customer_state) as state,
    COALESCE(s.seller_count, 0) as no_sellers,
    COALESCE(c.customer_count, 0) as no_customers
FROM 
    (SELECT seller_state, COUNT(seller_id) as seller_count
     FROM sellers_raw GROUP BY seller_state) s
LEFT JOIN 
    (SELECT customer_state, COUNT(customer_id) as customer_count
     FROM customer_raw GROUP BY customer_state) c
ON s.seller_state = c.customer_state
ORDER BY no_sellers DESC;


-- Level 3 : GROUP BY & AGGRAGATE FUNCTIONS

-- Time Based Analysis
-- 1. What is the total revenue per month for 2017 and 2018? Show year, month and revenue ordered by year and month.
SELECT YEAR(o.order_purchase_timestamp) as Year, Month(o.order_purchase_timestamp) as Month, SUM(oi.price) as total_revenue
FROM order_raw o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE YEAR(o.order_purchase_timestamp) BETWEEN 2017 AND 2018
GROUP BY Year, Month
ORDER BY total_revenue DESC;

-- 2. Which month of the year has the highest average order value across all years?
SELECT  MONTH(o.order_purchase_timestamp) as Month, AVG(oi.price) as average_order
FROM order_raw o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY Month
ORDER BY average_order DESC
LIMIT 1;

-- 3. What is the month over month revenue growth rate for 2018?
SELECT 
    MONTH(o.order_purchase_timestamp) as Month,
    SUM(oi.price) as revenue,
    LAG(SUM(oi.price)) OVER (ORDER BY MONTH(o.order_purchase_timestamp)) as prev_month_revenue,
    ROUND((SUM(oi.price) - LAG(SUM(oi.price)) OVER (ORDER BY MONTH(o.order_purchase_timestamp))) 
        / LAG(SUM(oi.price)) OVER (ORDER BY MONTH(o.order_purchase_timestamp)) * 100, 2) as growth_rate
FROM order_raw o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE YEAR(o.order_purchase_timestamp) = 2018
GROUP BY MONTH(o.order_purchase_timestamp)
ORDER BY Month;

-- Customer Analysis
-- 4. What is the average order value per customer state?
SELECT c.customer_state, AVG(oi.price) as average_value
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY customer_state
ORDER BY average_value DESC;

-- 5. What percentage of total orders does each order status represent? Show status and percentage.
SELECT order_status, COUNT(order_id) as total_count, ROUND(COUNT(order_id)*100 / (SELECT COUNT(*) FROM order_raw), 2) as percentage
FROM order_raw 
GROUP BY order_status
ORDER BY percentage DESC;

-- 6. What is the average number of items per order?
SELECT AVG(total_item) as avg_items
FROM (
SELECT order_id, COUNT(order_item_id) as total_item
FROM order_items
GROUP BY order_id) as order_count;

-- Product Analysis
-- 7. What is the average price per product category? Show top 10 most expensive categories.
SELECT p.product_category_name, AVG(oi.price) as average_price
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY average_price DESC
LIMIT 10;

-- 8. What percentage of total revenue does each product category contribute? Show top 10.
SELECT p.product_category_name, SUM(oi.price) as total_revenue, ROUND(SUM(oi.price) * 100 / (SELECT SUM(price) FROM order_items), 2) as percentage
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name 
ORDER BY percentage
LIMIT 10;

-- 9. What is the average freight cost per product category? Show top 10 most expensive freight categories.
SELECT p.product_category_name, AVG(oi.freight_value) as average_value
FROM products_raw p 
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY average_value DESC
LIMIT 10;

-- Seller Performance
-- 10. What is the average revenue per seller per state?
SELECT s.seller_id, s.seller_state, AVG(oi.price) as avg_revenue
FROM sellers_raw s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_state, s.seller_id
ORDER BY avg_revenue DESC;

-- 11. What percentage of total sellers does each state have?
SELECT seller_state, COUNT(seller_id) as total_count, ROUND( COUNT(seller_id) * 100 / (SELECT COUNT(*) FROM sellers_raw), 2) as percentage
FROM sellers_raw
GROUP BY seller_state
ORDER BY percentage;

-- Review Analysis
-- 12. What is the percentage of each review score out of total reviews?
SELECT review_score, COUNT(review_id) as total_review, ROUND(COUNT(review_id) * 100 / (SELECT COUNT(*) FROM order_reviews_raw), 2) as percentage_score
FROM order_reviews_raw
GROUP BY review_score
ORDER BY percentage_score DESC; 

-- 13. Which product categories have below average review scores?
SELECT product_category_name, avg_score
FROM (SELECT p.product_category_name, AVG(orr.review_score) as avg_score
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN order_reviews_raw orr ON oi.order_id = orr.order_id
GROUP BY p.product_category_name) as category_score
WHERE avg_score > (SELECT AVG(review_score) FROM order_reviews_raw)
ORDER BY avg_score;

-- Delivery Performance
-- 14. What is the on time delivery rate per customer state? Show percentage of orders delivered on time.
-- Correct version
SELECT 
    c.customer_state,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated 
                   THEN 1 ELSE 0 END) * 100.0 / COUNT(o.order_id), 2) as ontime_percentage
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY ontime_percentage DESC;

-- 15. What is the average freight cost per customer state? Show top 10 most expensive states.
SELECT c.customer_state, AVG(oi.freight_value) as avg_value
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY avg_value DESC
LIMIT 10;



-- LEVEL 4 : Subqueries

-- Basic Subqueries
-- 1. Which products have a price above the average price of all products sold?
SELECT p.product_category_name, AVG(oi.price) as avg_price
FROM products_raw p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING AVG(oi.price) > (
    SELECT AVG(price) FROM order_items
)
ORDER BY avg_price DESC;

-- 2. Which customers have placed more orders than the average number of orders per customer?
SELECT customer_id, order_count
FROM (
    SELECT customer_id, COUNT(order_id) as order_count
    FROM order_raw
    GROUP BY customer_id
) as customer_orders
WHERE order_count > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) as order_count
        FROM order_raw
        GROUP BY customer_id
    ) as avg_orders
)
ORDER BY order_count DESC;

-- 3. Which sellers have total revenue above the average seller revenue?
SELECT seller_id, total_revenue
FROM (
    SELECT seller_id, SUM(price) as total_revenue
    FROM order_items
    GROUP BY seller_id
) as seller_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT SUM(price) as total_revenue
        FROM order_items
        GROUP BY seller_id
    ) as avg_revenue
)
ORDER BY total_revenue DESC;

-- Correlated Subqueries

-- 4. For each product category, show the product with the highest price.
SELECT p.product_category_name, 
       oi.product_id,
       oi.price
FROM order_items oi
JOIN products_raw p ON oi.product_id = p.product_id
WHERE oi.price = (
    SELECT MAX(oi2.price)
    FROM order_items oi2
    JOIN products_raw p2 ON oi2.product_id = p2.product_id
    WHERE p2.product_category_name = p.product_category_name
)
ORDER BY oi.price DESC;

-- 5. For each state, show the customer who has placed the most orders.
SELECT customer_state, customer_id, order_count
FROM (
    SELECT c.customer_state,
           c.customer_id,
           COUNT(o.order_id) as order_count,
           ROW_NUMBER() OVER (
               PARTITION BY c.customer_state 
               ORDER BY COUNT(o.order_id) DESC
           ) as rn
    FROM customer_raw c
    JOIN order_raw o ON c.customer_id = o.customer_id
    GROUP BY c.customer_state, c.customer_id
) as ranked
WHERE rn = 1
ORDER BY customer_state;

-- Subqueries in FROM clause
-- 6. What is the average number of orders per customer per state?
SELECT customer_state, 
       AVG(order_count) as avg_orders_per_customer
FROM (
    SELECT c.customer_state,
           c.customer_id,
           COUNT(o.order_id) as order_count
    FROM customer_raw c
    JOIN order_raw o ON c.customer_id = o.customer_id
    GROUP BY c.customer_state, c.customer_id
) as customer_orders
GROUP BY customer_state
ORDER BY avg_orders_per_customer DESC;

-- 7. What is the average revenue per order per month for 2018?
SELECT Month, AVG(order_revenue) as avg_revenue_per_order
FROM (
    SELECT MONTH(o.order_purchase_timestamp) as Month,
           o.order_id,
           SUM(oi.price) as order_revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY MONTH(o.order_purchase_timestamp), o.order_id
) as monthly_orders
GROUP BY Month
ORDER BY Month;

-- Subqueries with EXISTS
-- 8. Which orders have at least one item with price above R$500?
-- Without EXISTS (using IN)
SELECT order_id FROM order_raw
WHERE order_id IN (SELECT order_id FROM order_items WHERE price > 500);

-- With EXISTS (more efficient for large datasets)
SELECT o.order_id 
FROM order_raw o
WHERE EXISTS (
    SELECT 1 
    FROM order_items oi
    WHERE oi.order_id = o.order_id
    AND oi.price > 500
);

-- 9. Which sellers have never sold a product in the 'cama_mesa_banho' category?
SELECT DISTINCT s.seller_id, s.seller_state
FROM sellers_raw s
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN products_raw p ON oi.product_id = p.product_id
    WHERE oi.seller_id = s.seller_id
    AND p.product_category_name = 'cama_mesa_banho'
)
ORDER BY s.seller_state;

-- Combining Multiple Subqueries
-- 10. Which product categories have both above average price AND above average review score?
SELECT category_prices.product_category_name,
       category_prices.avg_price,
       category_reviews.avg_score
FROM (
    SELECT p.product_category_name, AVG(oi.price) as avg_price
    FROM products_raw p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_category_name
    HAVING AVG(oi.price) > (SELECT AVG(price) FROM order_items)
) as category_prices
JOIN (
    SELECT p.product_category_name, AVG(orr.review_score) as avg_score
    FROM products_raw p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN order_reviews_raw orr ON oi.order_id = orr.order_id
    GROUP BY p.product_category_name
    HAVING AVG(orr.review_score) > (SELECT AVG(review_score) FROM order_reviews_raw)
) as category_reviews
ON category_prices.product_category_name = category_reviews.product_category_name
ORDER BY avg_price DESC;

-- 11. What percentage of revenue comes from orders with review score 5 compared to review score 1?
SELECT
    ROUND(SUM(CASE WHEN orr.review_score = 5 THEN oi.price ELSE 0 END) * 100.0 / 
        SUM(oi.price), 2) as score5_percentage,
    ROUND(SUM(CASE WHEN orr.review_score = 1 THEN oi.price ELSE 0 END) * 100.0 / 
        SUM(oi.price), 2) as score1_percentage
FROM order_items oi
JOIN order_reviews_raw orr ON oi.order_id = orr.order_id;

-- 12. Which states have both above average number of customers AND above average number of sellers?
SELECT customer_state as state,
       customer_count,
       seller_count
FROM (
    SELECT c.customer_state,
           COUNT(DISTINCT c.customer_id) as customer_count,
           COUNT(DISTINCT s.seller_id) as seller_count
    FROM customer_raw c
    LEFT JOIN sellers_raw s ON c.customer_state = s.seller_state
    GROUP BY c.customer_state
) as state_counts
WHERE customer_count > (SELECT AVG(customer_count) 
                        FROM (SELECT COUNT(customer_id) as customer_count
                              FROM customer_raw 
                              GROUP BY customer_state) as avg_c)
AND seller_count > (SELECT AVG(seller_count)
                    FROM (SELECT COUNT(seller_id) as seller_count
                          FROM sellers_raw 
                          GROUP BY seller_state) as avg_s)
ORDER BY customer_count DESC;



-- Level 5
-- ROW_NUMBER and RANK
-- 1. Rank all sellers by total revenue. Show seller_id, total revenue and their rank.
SELECT 
    seller_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM (
    SELECT seller_id, SUM(price) as total_revenue
    FROM order_items
    GROUP BY seller_id
) as seller_revenue;

-- 2. For each product category, rank products by price. Show top 3 most expensive products in each category.
SELECT product_category_name, product_id, price, price_rank
FROM (
    SELECT 
        p.product_category_name,
        oi.product_id,
        oi.price,
        RANK() OVER (
            PARTITION BY p.product_category_name 
            ORDER BY oi.price DESC
        ) as price_rank
    FROM order_items oi
    JOIN products_raw p ON oi.product_id = p.product_id
) as ranked
WHERE price_rank <= 3
ORDER BY product_category_name, price_rank;

-- 3. Rank customer states by total number of orders. Show state, order count and rank.
SELECT 
    c.customer_state,
    COUNT(o.order_id) as total_orders,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) as order_rank
FROM customer_raw c
JOIN order_raw o ON c.customer_id = o.customer_id
GROUP BY c.customer_state;

-- LAG and LEAD
-- 4. Show month over month revenue for 2018 with previous month revenue and growth rate using LAG.
SELECT 
    Month,
    revenue,
    LAG(revenue) OVER (ORDER BY Month) as prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY Month)) * 100.0 / 
        LAG(revenue) OVER (ORDER BY Month), 
    2) as growth_rate_percent
FROM (
    SELECT 
        MONTH(o.order_purchase_timestamp) as Month,
        SUM(oi.price) as revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY MONTH(o.order_purchase_timestamp)
) as monthly_revenue
ORDER BY Month;

-- 5. For each seller, show their monthly revenue and the next month revenue using LEAD.
SELECT 
    seller_id,
    Month,
    monthly_revenue,
    LEAD(monthly_revenue) OVER (
        PARTITION BY seller_id 
        ORDER BY Month
    ) as next_month_revenue
FROM (
    SELECT 
        oi.seller_id,
        MONTH(o.order_purchase_timestamp) as Month,
        SUM(oi.price) as monthly_revenue
    FROM order_items oi
    JOIN order_raw o ON oi.order_id = o.order_id
    WHERE YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY oi.seller_id, MONTH(o.order_purchase_timestamp)
) as seller_monthly
ORDER BY seller_id, Month;

-- Running Totals
-- 6. Show cumulative revenue by month for 2017 and 2018 combined — meaning running total that keeps adding each month.
SELECT 
    Year,
    Month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY Year, Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as cumulative_revenue
FROM (
    SELECT 
        YEAR(o.order_purchase_timestamp) as Year,
        MONTH(o.order_purchase_timestamp) as Month,
        SUM(oi.price) as monthly_revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) as monthly
ORDER BY Year, Month;

-- 7. Show what percentage of total revenue has been accumulated by each month — running percentage.
SELECT 
    Year,
    Month,
    monthly_revenue,
    cumulative_revenue,
    ROUND(cumulative_revenue * 100.0 / 
        SUM(monthly_revenue) OVER (), 2) as cumulative_percentage
FROM (
    SELECT 
        YEAR(o.order_purchase_timestamp) as Year,
        MONTH(o.order_purchase_timestamp) as Month,
        SUM(oi.price) as monthly_revenue,
        SUM(SUM(oi.price)) OVER (
            ORDER BY YEAR(o.order_purchase_timestamp), 
                     MONTH(o.order_purchase_timestamp)
        ) as cumulative_revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) IN (2017, 2018)
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
) as monthly
ORDER BY Year, Month;

-- PARTITION BY
-- 8. For each order status, show each order and what percentage of that status group's total value it represents.
SELECT 
    o.order_id,
    o.order_status,
    op.payment_value,
    SUM(op.payment_value) OVER (
        PARTITION BY o.order_status
    ) as status_total,
    ROUND(op.payment_value * 100.0 / 
        SUM(op.payment_value) OVER (PARTITION BY o.order_status), 
    4) as percentage_of_status
FROM order_raw o
JOIN order_payments op ON o.order_id = op.order_id
ORDER BY o.order_status, percentage_of_status DESC;

-- 9. Show each product category's revenue and what percentage it is of its seller state's total revenue.
SELECT 
    s.seller_state,
    p.product_category_name,
    SUM(oi.price) as category_revenue,
    SUM(SUM(oi.price)) OVER (
        PARTITION BY s.seller_state
    ) as state_total_revenue,
    ROUND(SUM(oi.price) * 100.0 / 
        SUM(SUM(oi.price)) OVER (PARTITION BY s.seller_state), 
    2) as percentage_of_state
FROM order_items oi
JOIN products_raw p ON oi.product_id = p.product_id
JOIN sellers_raw s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state, p.product_category_name
ORDER BY s.seller_state, percentage_of_state DESC;

-- Advanced Combinations
-- 10. Find sellers whose revenue in any single month was more than double their average monthly revenue — these are sellers with unusually high spike months.
SELECT seller_id, Month, monthly_revenue, avg_monthly_revenue
FROM (
    SELECT 
        seller_id,
        Month,
        monthly_revenue,
        AVG(monthly_revenue) OVER (
            PARTITION BY seller_id
        ) as avg_monthly_revenue
    FROM (
        SELECT 
            oi.seller_id,
            MONTH(o.order_purchase_timestamp) as Month,
            SUM(oi.price) as monthly_revenue
        FROM order_items oi
        JOIN order_raw o ON oi.order_id = o.order_id
        GROUP BY oi.seller_id, MONTH(o.order_purchase_timestamp)
    ) as seller_monthly
) as with_avg
WHERE monthly_revenue > avg_monthly_revenue * 2
ORDER BY seller_id, Month;

-- 11. For each customer state, show the month with highest orders and the month with lowest orders side by side.
SELECT 
    customer_state,
    MAX(CASE WHEN month_rank_asc = 1 THEN Month END) as worst_month,
    MAX(CASE WHEN month_rank_asc = 1 THEN monthly_orders END) as worst_month_orders,
    MAX(CASE WHEN month_rank_desc = 1 THEN Month END) as best_month,
    MAX(CASE WHEN month_rank_desc = 1 THEN monthly_orders END) as best_month_orders
FROM (
    SELECT 
        customer_state,
        Month,
        monthly_orders,
        RANK() OVER (PARTITION BY customer_state ORDER BY monthly_orders ASC) as month_rank_asc,
        RANK() OVER (PARTITION BY customer_state ORDER BY monthly_orders DESC) as month_rank_desc
    FROM (
        SELECT 
            c.customer_state,
            MONTH(o.order_purchase_timestamp) as Month,
            COUNT(o.order_id) as monthly_orders
        FROM customer_raw c
        JOIN order_raw o ON c.customer_id = o.customer_id
        GROUP BY c.customer_state, MONTH(o.order_purchase_timestamp)
    ) as state_monthly
) as ranked
GROUP BY customer_state
ORDER BY customer_state;

-- 12. Show a 3 month moving average of revenue for 2018.
SELECT 
    Month,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        ORDER BY Month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as moving_avg_3month
FROM (
    SELECT 
        MONTH(o.order_purchase_timestamp) as Month,
        SUM(oi.price) as monthly_revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_purchase_timestamp) = 2018
    GROUP BY MONTH(o.order_purchase_timestamp)
) as monthly
ORDER BY Month;