# 📖 Data Dictionary — Olist E-Commerce Database

**Database Name:** olist_ecommerce
**Version:** 1.0
**Last Updated:** 2024
**Author:** Your Name
**Total Tables:** 9 raw tables + 1 clean table + 6 views

---

## 📋 Table of Contents

1. [customers_raw](#1-customers_raw)
2. [order_raw](#2-order_raw)
3. [order_items](#3-order_items)
4. [order_payments](#4-order_payments)
5. [order_reviews_raw](#5-order_reviews_raw)
6. [products_raw](#6-products_raw)
7. [sellers_raw](#7-sellers_raw)
8. [geolocation_raw](#8-geolocation_raw)
9. [geolocation_clean](#9-geolocation_clean)
10. [product_name_raw](#10-product_name_raw)
11. [Views](#11-analytical-views)

---

## Database Schema Overview
```
customer_raw
↓ customer_id
order_raw ←──────────────── order_reviews_raw
    ↓ order_id                   (order_id)
order_items ←──────────── order_payments
↓ product_id  ↓ seller_id   (order_id)
products_raw  sellers_raw
↓ product_category_name  ↓ seller_zip_code_prefix
product_name_raw          geolocation_clean

```

**Schema Type:** Snowflake Schema

---

## 1. customers_raw

**Purpose:** Stores customer information and location details.
One row per customer per order (customer_id is unique per order,
customer_unique_id identifies the actual unique person).

**Row Count:** 99,441
**Primary Key:** customer_id

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| customer_id | VARCHAR(32) | NOT NULL | Unique identifier per order — same person can have multiple customer_ids | `06b8999e2fba1a1fbc88172c00ba8bc7` |
| customer_unique_id | VARCHAR(32) | NOT NULL | True unique customer identifier — use this for unique customer count | `861eff4711a542e4b93843c6dd7febb0` |
| customer_zip_code_prefix | INT | NOT NULL | First 5 digits of customer ZIP code | `14409` |
| customer_city | VARCHAR(50) | NOT NULL | Customer city name | `franca` |
| customer_state | VARCHAR(2) | NOT NULL | Brazilian state abbreviation | `SP` |

**Important Notes:**
- Use `customer_unique_id` for counting unique customers
- Use `customer_id` for joining with `order_raw`
- `customer_city` has encoding issues — city names may show
  corrupted Portuguese characters due to source data limitation
- 27 distinct states present — all Brazilian states covered

**Valid Values for customer_state:**
```
AC, AL, AM, AP, BA, CE, DF, ES, GO, MA, MG, MS, MT,
PA, PB, PE, PI, PR, RJ, RN, RO, RR, RS, SC, SE, SP, TO
```

---

## 2. order_raw

**Purpose:** Central order table containing all order details,
status information and delivery timestamps.
This is the most important table in the database.

**Row Count:** 99,441
**Primary Key:** order_id
**Foreign Keys:**
- customer_id → customers_raw(customer_id)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| order_id | VARCHAR(32) | NOT NULL | Unique order identifier | `e481f51cbdc54678b7cc49136f2d6af7` |
| customer_id | VARCHAR(32) | NOT NULL | Links to customers_raw | `9ef432eb6251297304e76186b10a928d` |
| order_status | VARCHAR(20) | NOT NULL | Current status of the order | `delivered` |
| order_purchase_timestamp | DATETIME | NOT NULL | When customer placed the order | `2017-10-02 10:56:33` |
| order_approved_at | DATETIME | YES | When payment was approved. NULL if not yet approved | `2017-10-02 11:07:15` |
| order_delivered_carrier_date | DATETIME | YES | When order was handed to carrier. NULL if not shipped | `2017-10-04 19:55:00` |
| order_delivered_customer_date | DATETIME | YES | When customer received order. NULL if not delivered | `2017-10-10 21:25:13` |
| order_estimated_delivery_date | DATETIME | NOT NULL | Promised delivery date shown to customer | `2017-10-18 00:00:00` |

**Valid Values for order_status:**

| Status | Count | Meaning |
|---|---|---|
| delivered | 96,478 | Successfully delivered to customer |
| shipped | 1,107 | In transit to customer |
| canceled | 625 | Order was canceled |
| unavailable | 609 | Item not available |
| invoiced | 314 | Invoice generated, not yet shipped |
| processing | 301 | Being prepared for shipment |
| created | 5 | Just created, not yet processed |
| approved | 2 | Payment approved, not yet invoiced |

**Important Notes:**
- NULL in delivery date columns is expected and correct
- NULL means the event has not happened yet
- Use `order_delivered_customer_date IS NOT NULL`
  when analyzing delivery performance
- Dataset covers September 2016 to August 2018

---

## 3. order_items

**Purpose:** Contains details of each item within an order.
One order can have multiple items — one row per item.

**Row Count:** 112,650
**Primary Key:** (order_id, order_item_id) — Composite
**Foreign Keys:**
- order_id → order_raw(order_id)
- product_id → products_raw(product_id)
- seller_id → sellers_raw(seller_id)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| order_id | VARCHAR(32) | NOT NULL | Links to order_raw | `00010242fe8c5a6d1ba2dd792cb16214` |
| order_item_id | TINYINT | NOT NULL | Sequential item number within order. 1 = first item, 2 = second item | `1` |
| product_id | VARCHAR(32) | NOT NULL | Links to products_raw | `4244733e06e7ecb4970a6e2683c13e61` |
| seller_id | VARCHAR(32) | NOT NULL | Links to sellers_raw | `48436dade18ac8b2bce089ec2a041202` |
| shipping_limit_date | DATETIME | NOT NULL | Deadline for seller to hand order to carrier | `2017-09-19 09:45:35` |
| price | DECIMAL(10,2) | NOT NULL | Product price in Brazilian Reais (R$) | `58.90` |
| freight_value | DECIMAL(10,2) | NOT NULL | Shipping cost in Brazilian Reais (R$) | `13.29` |

**Important Notes:**
- `price` does NOT include freight — add freight_value for total
- `order_item_id` MAX value is 21 — one order had 21 items
- Use SUM(price) for revenue analysis — NOT payment_value
- 112,650 rows vs 99,441 orders = avg 1.13 items per order

---

## 4. order_payments

**Purpose:** Contains payment information for each order.
One order can have multiple payment rows if customer
used multiple payment methods.

**Row Count:** 103,886
**Primary Key:** (order_id, payment_sequential) — Composite
**Foreign Keys:**
- order_id → order_raw(order_id)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| order_id | VARCHAR(32) | NOT NULL | Links to order_raw | `b81ef226f3fe1789b1e8b2acac839d17` |
| payment_sequential | TINYINT | NOT NULL | Payment sequence number. 1 = first payment method used | `1` |
| payment_type | VARCHAR(20) | NOT NULL | Payment method used | `credit_card` |
| payment_installments | TINYINT | NOT NULL | Number of installments chosen. 1 = single payment | `8` |
| payment_value | DECIMAL(10,2) | NOT NULL | Amount paid in this payment row in R$ | `99.33` |

**Valid Values for payment_type:**

| Type | Count | Percentage |
|---|---|---|
| credit_card | 76,795 | 73.78% |
| boleto | 19,784 | 19.44% |
| voucher | 5,775 | 5.33% |
| debit_card | 1,529 | 1.41% |
| not_defined | 3 | 0.003% |

**Important Notes:**
- `not_defined` payment type has 3 orders with R$0.00 value
  — documented data quality issue
- 2 orders have 0 installments — documented data quality issue
- payment_value total (R$15.70M) exceeds price total (R$13.59M)
  because payment includes freight costs
- Use SUM(price) from order_items for revenue
  NOT SUM(payment_value) from this table

**Installment Distribution:**

| Installments | Orders | Meaning |
|---|---|---|
| 1 | 52,546 | Single full payment |
| 2-6 | 38,321 | Medium installments |
| 7+ | 13,019 | High installments |

---

## 5. order_reviews_raw

**Purpose:** Contains customer reviews submitted after delivery.
Not every order has a review.

**Row Count:** 99,224
**Primary Key:** id (auto-generated — review_id has duplicates)
**Foreign Keys:**
- order_id → order_raw(order_id)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| id | INT AUTO_INCREMENT | NOT NULL | System generated unique ID — added during cleaning | `1` |
| review_id | VARCHAR(32) | NOT NULL | Review identifier — NOT unique (814 duplicates found) | `7bc2406110b926393aa56f80a40eba40` |
| order_id | VARCHAR(32) | NOT NULL | Links to order_raw | `73fc7af87114b39712e6da79b0a377eb` |
| review_score | TINYINT | NOT NULL | Customer rating 1-5 stars | `4` |
| review_comment_title | VARCHAR(50) | YES | Optional review title — 87,655 NULLs (88.2%) | `Recomendo` |
| review_comment_message | TEXT | YES | Optional review message — 58,247 NULLs (58.7%) | `Produto chegou no prazo` |
| review_creation_date | DATETIME | NOT NULL | When review form was sent to customer | `2018-01-18 00:00:00` |
| review_answer_timestamp | DATETIME | NOT NULL | When customer submitted the review | `2018-01-18 21:46:00` |

**Review Score Distribution:**

| Score | Count | Percentage | Meaning |
|---|---|---|---|
| 5 ⭐⭐⭐⭐⭐ | 57,327 | 57.78% | Excellent |
| 4 ⭐⭐⭐⭐ | 19,142 | 19.29% | Good |
| 3 ⭐⭐⭐ | 8,179 | 8.24% | Average |
| 2 ⭐⭐ | 3,151 | 3.18% | Poor |
| 1 ⭐ | 11,423 | 11.51% | Very Poor |

**Important Notes:**
- `review_id` is NOT unique — 814 duplicate review_ids found
  linked to different orders — source data quality issue
- Auto-increment `id` column was added as true primary key
- High NULL rate in comment fields is expected and normal
- review_score values are only 1, 2, 3, 4, 5 — no other values

---

## 6. products_raw

**Purpose:** Contains product specifications and category information.
One row per unique product.

**Row Count:** 32,951
**Primary Key:** product_id
**Foreign Keys:**
- product_category_name → product_name_raw(product_category_name)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| product_id | VARCHAR(32) | NOT NULL | Unique product identifier | `1e9e8ef04dbcff4541ed26657ea517e5` |
| product_category_name | VARCHAR(50) | YES | Portuguese category name. 610 NULLs labeled 'unknown' | `perfumaria` |
| product_name_lenght | TINYINT | YES | Number of characters in product name | `40` |
| product_description_lenght | SMALLINT UNSIGNED | YES | Number of characters in product description | `287` |
| product_photos_qty | TINYINT | YES | Number of product photos | `1` |
| product_weight_g | SMALLINT UNSIGNED | YES | Product weight in grams | `225` |
| product_length_cm | TINYINT | YES | Product length in centimeters | `16` |
| product_height_cm | TINYINT | YES | Product height in centimeters | `10` |
| product_width_cm | TINYINT | YES | Product width in centimeters | `14` |

**Important Notes:**
- 610 products had NULL category — labeled as 'unknown'
  during data cleaning phase
- These 610 unknown products appear in 1,603 orders
- `product_name_lenght` — spelling is intentional
  (matches original Kaggle dataset column name)
- Weight range: 0g to 40,425g (40kg)
- 3 categories exist in products_raw but not in
  product_name_raw: pc_gamer, portateis_cozinha,
  unknown — added manually during cleaning

**Dimension Ranges:**

| Measurement | Min | Max | Unit |
|---|---|---|---|
| Weight | 0 | 40,425 | grams |
| Length | 0 | 105 | cm |
| Height | 0 | 105 | cm |
| Width | 0 | 118 | cm |
| Photos | 0 | 20 | count |

---

## 7. sellers_raw

**Purpose:** Contains seller information and location.
One row per unique seller.

**Row Count:** 3,095
**Primary Key:** seller_id

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| seller_id | VARCHAR(32) | NOT NULL | Unique seller identifier | `3442f8959a84dea7ee197c632cb2df15` |
| seller_zip_code_prefix | INT | NOT NULL | First 5 digits of seller ZIP code | `13023` |
| seller_city | VARCHAR(50) | NOT NULL | Seller city name | `campinas` |
| seller_state | VARCHAR(2) | NOT NULL | Brazilian state abbreviation | `SP` |

**Seller Distribution by State (Top 5):**

| State | Sellers | Percentage |
|---|---|---|
| SP | 1,849 | 59.74% |
| PR | 349 | 11.28% |
| MG | 244 | 7.88% |
| SC | 190 | 6.14% |
| RJ | 171 | 5.53% |

**Important Notes:**
- São Paulo (SP) has 59.74% of all sellers
- Some states have only 1 seller
- seller_city has same encoding issues as customer_city

---

## 8. geolocation_raw

**Purpose:** Contains latitude and longitude coordinates
for Brazilian ZIP codes. Has significant duplicates —
use geolocation_clean for analysis.

**Row Count:** 1,000,163 (raw) — heavily duplicated
**Primary Key:** None (duplicates exist)

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| geolocation_zip_code_prefix | INT | NOT NULL | First 5 digits of ZIP code | `1037` |
| geolocation_lat | DOUBLE | NOT NULL | Latitude coordinate | `-23.54562128` |
| geolocation_lng | DOUBLE | NOT NULL | Longitude coordinate | `-46.63929205` |
| geolocation_city | VARCHAR(50) | NOT NULL | City name — has encoding issues | `sao paulo` |
| geolocation_state | VARCHAR(2) | NOT NULL | State abbreviation | `SP` |

**Important Notes:**
- DO NOT use this table directly for analysis
- Use `geolocation_clean` instead
- 1,000,163 rows but only 19,015 unique ZIP codes
- Each ZIP code has average 53 coordinate points
- 31 coordinates were outside Brazil's boundaries
  and were deleted during cleaning phase
- Mixed UTF-8 encoding causes city name corruption

---

## 9. geolocation_clean

**Purpose:** Clean version of geolocation created during
data cleaning phase. One row per ZIP code with
averaged coordinates. Use this for all geographic analysis.

**Row Count:** 19,011
**Primary Key:** geolocation_zip_code_prefix
**Created By:** Phase 2 data cleaning

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| geolocation_zip_code_prefix | INT | NOT NULL | Unique ZIP code | `1014` |
| geolocation_lat | DOUBLE | NOT NULL | Average latitude for this ZIP code | `-23.5468` |
| geolocation_lng | DOUBLE | NOT NULL | Average longitude for this ZIP code | `-46.6380` |
| geolocation_city | VARCHAR(50) | NOT NULL | City name (encoding issues still present) | `sao paulo` |
| geolocation_state | VARCHAR(2) | NOT NULL | State abbreviation | `SP` |

**How it was created:**
```sql
CREATE TABLE geolocation_clean AS
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) as geolocation_lat,
    AVG(geolocation_lng) as geolocation_lng,
    MIN(geolocation_city) as geolocation_city,
    MIN(geolocation_state) as geolocation_state
FROM geolocation_raw
GROUP BY geolocation_zip_code_prefix;
```

---

## 10. product_name_raw

**Purpose:** Translation table mapping Portuguese product
category names to English equivalents.

**Row Count:** 74 (71 original + 3 added during cleaning)
**Primary Key:** product_category_name

| Column | Datatype | Nullable | Description | Example |
|---|---|---|---|---|
| product_category_name | VARCHAR(50) | NOT NULL | Portuguese category name — primary key | `beleza_saude` |
| product_category_name_english | VARCHAR(50) | NOT NULL | English translation | `health_beauty` |

**Important Notes:**
- 3 categories were manually added during cleaning:
  1. `unknown` → `unknown`
  2. `pc_gamer` → `pc_gamer`
  3. `portateis_cozinha_e_preparadores_de_alimentos`
     → `portable_kitchen_and_food_preparers`
- These were missing from original dataset but
  exist in products_raw table

---

## 11. Analytical Views

**Purpose:** Pre-built views created for Power BI dashboard.
These combine multiple tables into analysis-ready datasets.

### View 1: sales_summary
**Purpose:** Main revenue and sales analysis dataset

| Key Columns | Description |
|---|---|
| order_id | Unique order identifier |
| order_date, order_year, order_month | Time dimensions for filtering |
| order_status | Current order status |
| customer_state, customer_city | Geographic dimensions |
| payment_type, total_payment_value | Payment information |
| product_category_name_english | English category name |
| price, freight_value, total_item_value | Revenue metrics |

**Row Count:** 112,647
**Source Tables:** order_raw, customer_raw, order_payments,
order_items, products_raw, product_name_raw

---

### View 2: delivery_analysis
**Purpose:** Delivery performance analysis

| Key Columns | Description |
|---|---|
| actual_delivery_days | How long delivery actually took |
| estimated_delivery_days | How long was promised |
| delay_days | Difference (negative=early, positive=late) |
| delivery_status | 'On Time' or 'Late' or 'Unknown' |

**Row Count:** 96,476
**Source Tables:** order_raw, customer_raw

---

### View 3: customer_analysis
**Purpose:** Customer behavior metrics

| Key Columns | Description |
|---|---|
| total_orders | How many orders customer placed |
| total_spent | Total R$ spent by customer |
| avg_order_value | Average spend per order |
| customer_lifetime_days | Days between first and last order |

**Row Count:** 98,666
**Source Tables:** customer_raw, order_raw, order_items

---

### View 4: product_analysis
**Purpose:** Product and category performance

| Key Columns | Description |
|---|---|
| total_orders | Orders containing this product |
| total_items_sold | Total units sold |
| total_revenue | Total R$ revenue from product |
| avg_review_score | Average customer rating |

**Row Count:** 32,951
**Source Tables:** products_raw, order_items,
product_name_raw, order_reviews_raw

---

### View 5: payment_analysis
**Purpose:** Payment trends and installment analysis

| Key Columns | Description |
|---|---|
| installment_category | Single/Medium/High installments |
| payment_type | Method used |
| payment_value | Amount paid |

**Row Count:** 103,886
**Source Tables:** order_raw, order_payments, customer_raw

---

### View 6: customer_payment_analysis
**Purpose:** Combined customer and payment data for Page 4 dashboard

| Key Columns | Description |
|---|---|
| customer_unique_id | True unique customer identifier |
| total_spent | Pre-calculated total spend per customer |
| total_orders | Pre-calculated order count per customer |
| installment_category | Payment behavior classification |

**Row Count:** ~112,000
**Source Tables:** customer_raw, order_raw,
order_payments, order_items

---

## 🔗 Relationship Summary

| Child Table | Foreign Key | Parent Table | Parent Key |
|---|---|---|---|
| order_raw | customer_id | customer_raw | customer_id |
| order_items | order_id | order_raw | order_id |
| order_items | product_id | products_raw | product_id |
| order_items | seller_id | sellers_raw | seller_id |
| order_payments | order_id | order_raw | order_id |
| order_reviews_raw | order_id | order_raw | order_id |
| products_raw | product_category_name | product_name_raw | product_category_name |

**Cascade Rules:**
- ON DELETE RESTRICT — prevents deletion of parent rows
- ON UPDATE CASCADE — automatically updates child references

---

## ⚠️ Known Data Quality Issues

| Issue | Table | Column | Count | Resolution |
|---|---|---|---|---|
| Missing category | products_raw | product_category_name | 610 | Labeled 'unknown' |
| Duplicate review_id | order_reviews_raw | review_id | 814 | Added auto-increment PK |
| Not defined payment | order_payments | payment_type | 3 | Documented — value R$0 |
| Zero installments | order_payments | payment_installments | 2 | Documented |
| Out of bounds coords | geolocation_raw | lat/lng | 31 | Deleted |
| Mixed encoding | Multiple | city columns | Unknown | Documented as limitation |
| Missing categories | product_name_raw | product_category_name | 3 | Manually added |