# 🔍 Data Quality Report — Olist E-Commerce Database

**Project:** Brazilian E-Commerce Analysis
**Database:** olist_ecommerce
**Report Date:** 2024
**Author:** Your Name
**Data Period:** September 2016 — August 2018

---

## 📊 Executive Summary

| Metric | Value |
|---|---|
| Total Tables Assessed | 9 |
| Total Rows Analyzed | 1,607,895 |
| Tables with Issues | 6 |
| Tables Perfectly Clean | 3 |
| Critical Issues Found | 2 |
| Issues Resolved | 7 |
| Issues Documented | 2 |
| Overall Data Quality Score | 82/100 |

---

## 🏆 Overall Quality Score by Table

| Table | Rows | Duplicates | Nulls | Encoding | Overall Score |
|---|---|---|---|---|---|
| customer_raw | 99,441 | ✅ 0% | ✅ 0% | ⚠️ City names | 90/100 |
| order_raw | 99,441 | ✅ 0% | ⚠️ Expected | ✅ Clean | 95/100 |
| order_items | 112,650 | ✅ 0% | ✅ 0% | ✅ Clean | 99/100 |
| order_payments | 103,886 | ✅ 0% | ✅ 0% | ✅ Clean | 97/100 |
| order_reviews_raw | 99,224 | ⚠️ review_id | ⚠️ Comments | ⚠️ Messages | 75/100 |
| products_raw | 32,951 | ✅ 0% | ⚠️ Category | ✅ Clean | 85/100 |
| sellers_raw | 3,095 | ✅ 0% | ✅ 0% | ⚠️ City names | 90/100 |
| geolocation_raw | 1,000,163 | 🔴 98.1% | ✅ 0% | 🔴 City names | 55/100 |
| product_name_raw | 71 | ✅ 0% | ✅ 0% | ✅ Clean | 100/100 |

---

## 📋 Detailed Issue Analysis

---

### Issue 1 — Incorrect Datatypes at Import
**Severity:** 🔴 Critical
**Status:** ✅ Resolved

**Description:**
Multiple columns were created with wrong datatypes
causing data loss during import. The most critical
was decimal values being stored as INT which
truncated all decimal places.

**Affected Tables and Columns:**

| Table | Column | Wrong Type | Correct Type | Data Loss |
|---|---|---|---|---|
| order_items | price | INT | DECIMAL(10,2) | Yes — decimals lost |
| order_items | freight_value | INT | DECIMAL(10,2) | Yes — decimals lost |
| order_payments | payment_value | INT | DECIMAL(10,2) | Yes — decimals lost |
| geolocation_raw | geolocation_lat | INT | DOUBLE | Yes — precision lost |
| geolocation_raw | geolocation_lng | INT | DOUBLE | Yes — precision lost |
| order_raw | all date columns | TEXT | DATETIME | No loss — conversion possible |
| order_reviews_raw | review_score | TEXT | TINYINT | No loss — conversion possible |
| products_raw | product_weight_g | INT | SMALLINT UNSIGNED | No loss — optimization |

**Evidence:**
```
Before fix — price column (INT):
58.90 → stored as 58 (lost .90)
99.33 → stored as 99 (lost .33)
13.29 → stored as 13 (lost .29)After fix — price column (DECIMAL):
58.90 → stored as 58.90 ✅
99.33 → stored as 99.33 ✅
13.29 → stored as 13.29 ✅

```
**Resolution:**
- Dropped and recreated 3 tables with correct datatypes
- Re-imported CSV files with proper column definitions
- Verified decimal values after re-import
- Converted date TEXT columns using STR_TO_DATE()

**SQL Fix Applied:**
```sql
-- Example fix for order_payments
DROP TABLE order_payments;

CREATE TABLE order_payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value DECIMAL(10,2)  -- Fixed!
);

LOAD DATA LOCAL INFILE 'order_payments.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

**Lesson Learned:**
Always define correct datatypes BEFORE importing data.
Never use INT for columns that contain decimal values.

---

### Issue 2 — Geolocation Duplicate Records
**Severity:** 🔴 Critical
**Status:** ✅ Resolved

**Description:**
The geolocation_raw table contained 1,000,163 rows
but only 19,015 unique ZIP codes. Each ZIP code had
an average of 53 coordinate points causing massive
data redundancy.

**Evidence:**

Raw table:    1,000,163 rows
Unique ZIPs:     19,015 unique ZIP codes
Duplication:      98.1% of rows are duplicates
Ratio:            ~53 rows per ZIP code on average

**Sample Duplicate Data:**

ZIP     LAT              LNG
01014   -23.5468         -46.6380
01014   -23.5469         -46.6381
01014   -23.5467         -46.6379
01014   -23.5470         -46.6382
(same ZIP, slightly different coordinates)

**Resolution:**
Created `geolocation_clean` table with one row
per ZIP code using averaged coordinates:

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

**Result:**
Before: 1,000,163 rows (raw)
After:     19,011 rows (clean)
Reduction:    98.1%

**Business Impact:**
- Raw table caused slow JOIN operations
- Clean table makes geographic analysis reliable
- Average coordinates are more accurate than
  any single point for a ZIP code area

---

### Issue 3 — NULL Values in Date Columns
**Severity:** 🟡 Expected — Documented
**Status:** ✅ Handled

**Description:**
Three date columns in order_raw contain NULL values.
These NULLs are NOT data errors — they represent
orders that have not yet reached that stage.

**NULL Count by Column:**

| Column | NULL Count | Percentage | Reason |
|---|---|---|---|
| order_approved_at | 160 | 0.16% | Payment not yet approved |
| order_delivered_carrier_date | 1,783 | 1.79% | Not yet shipped |
| order_delivered_customer_date | 2,965 | 2.98% | Not yet delivered |

**Verification:**
```sql
-- Confirmed NULLs are in non-delivered orders
SELECT order_status, COUNT(*) as count
FROM order_raw
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status;

-- Result:
-- shipped      → 1,107 (in transit — correct)
-- canceled     → 625   (canceled — correct)
-- unavailable  → 609   (unavailable — correct)
-- invoiced     → 314   (not shipped — correct)
-- processing   → 301   (not shipped — correct)
-- created      → 5     (just created — correct)
-- approved     → 2     (not shipped — correct)
```

**Resolution:**
- No data modification required
- NULL values are business-correct
- All analysis queries use
  `WHERE order_delivered_customer_date IS NOT NULL`
  when analyzing delivery performance
- STR_TO_DATE() with NULLIF() used during
  TEXT to DATETIME conversion to handle empty strings

---

### Issue 4 — Missing Product Categories
**Severity:** 🟡 Moderate
**Status:** ✅ Resolved

**Description:**
610 products in products_raw had NULL or empty
product_category_name. These products had valid
physical dimensions and were actively sold.

**Evidence:**
```sql
SELECT COUNT(*) FROM products_raw
WHERE product_category_name IS NULL
OR product_category_name = '';
-- Result: 610 products

SELECT COUNT(*) FROM order_items oi
JOIN products_raw p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NULL
OR p.product_category_name = '';
-- Result: 1,603 orders affected
```

**Impact Assessment:**
Total products:          32,951
Missing category:           610   (1.85%)
Orders with unknown cat:  1,603   (1.42% of all orders)
Revenue from unknown:  Included in total R$13.59M

**Resolution:**
- Labeled all 610 products as 'unknown' category
- Added 'unknown' entry to product_name_raw table
  to maintain referential integrity
- Products remain in analysis — not deleted

```sql
SET SQL_SAFE_UPDATES = 0;
UPDATE products_raw
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL
OR product_category_name = '';
SET SQL_SAFE_UPDATES = 1;

INSERT INTO product_name_raw
VALUES ('unknown', 'unknown');
```

**Business Recommendation:**
Olist should require mandatory category selection
during product listing to prevent future
uncategorized products.

---

### Issue 5 — Duplicate review_id in order_reviews_raw
**Severity:** 🟡 Moderate
**Status:** ✅ Resolved

**Description:**
The review_id column in order_reviews_raw was
expected to be unique but contained 814 duplicate
values. Same review_id appeared linked to
multiple different order_ids.

**Evidence:**
```sql
SELECT review_id, COUNT(*) as count
FROM order_reviews_raw
GROUP BY review_id
HAVING count > 1
ORDER BY count DESC
LIMIT 5;

-- Result:
-- c444278834184f72b1484dfe47de7f97 → 3 orders
-- 308316408775d1600dad81bd3184556d → 3 orders
-- (814 total duplicate review_ids)

-- Affected orders:
SELECT COUNT(DISTINCT order_id) as affected_orders
FROM order_reviews_raw
WHERE review_id IN (
    SELECT review_id FROM order_reviews_raw
    GROUP BY review_id HAVING COUNT(*) > 1
);
-- Result: 1,412 orders affected
```

**Root Cause:**
Source data generation error — review IDs were
not properly generated as unique identifiers
in the original Olist system.

**Resolution:**
Added auto-increment primary key column:
```sql
ALTER TABLE order_reviews_raw
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;
```

**Impact:**
- review_id cannot be used as join key
- Use order_id to join with other tables instead
- All 99,224 reviews remain in analysis

---

### Issue 6 — Unexpected Payment Values
**Severity:** 🟢 Minor
**Status:** ✅ Documented

**Description:**
Three minor payment data anomalies found:

**Anomaly A — not_defined Payment Type**
3 orders with payment_type = 'not_defined'
All 3 have payment_value = R$ 0.00
Likely: system test orders or data entry errors
Action: Documented — too few to impact analysis

**Anomaly B — Zero Installments**

2 orders with payment_installments = 0
Both have valid payment_value (R$58.69, R$129.94)
Both use credit_card payment type
Contradiction: Cannot have credit card with 0 installments
Action: Documented — too few to impact analysis

**Business Impact:**
not_defined orders: 3 / 103,886 = 0.003% of payments
Zero installments:  2 / 103,886 = 0.002% of payments
Combined impact:    Negligible

---

### Issue 7 — Out of Bounds Coordinates
**Severity:** 🟡 Moderate
**Status:** ✅ Resolved

**Description:**
31 coordinate entries in geolocation_raw had
latitude/longitude values outside Brazil's
geographic boundaries.

**Brazil's Geographic Boundaries:**
Latitude:  -33.75°S to +5.27°N
Longitude: -73.99°W to -28.85°W

**Sample Invalid Coordinates:**

| ZIP | Lat | Lng | City | Actually In |
|---|---|---|---|---|
| 28165 | 41.61 | -8.41 | vila nova de campos | Portugal |
| 28155 | 42.43 | 13.82 | santa maria | Italy |
| 95130 | 14.58 | 121.10 | santa lucia | Philippines |
| 29654 | 29.40 | -98.48 | santo antônio | Texas USA |

**Resolution:**
```sql
DELETE FROM geolocation_raw
WHERE geolocation_lat < -33.75
OR geolocation_lat > 5.27
OR geolocation_lng < -73.99
OR geolocation_lng > -28.85;
-- 31 rows deleted

-- Recreated geolocation_clean after deletion
DROP TABLE geolocation_clean;
CREATE TABLE geolocation_clean AS
SELECT ... FROM geolocation_raw GROUP BY ...;
```

**Impact:**

Before deletion: 19,015 unique ZIP codes
After deletion:  19,011 unique ZIP codes
Removed:         4 ZIP codes with invalid coordinates
Impact:          Negligible — 0.02% of ZIP codes

---

### Issue 8 — UTF-8 Encoding in City Names
**Severity:** 🟡 Moderate
**Status:** ⚠️ Documented — Partially Resolved

**Description:**
City name columns in multiple tables show corrupted
Portuguese characters due to mixed UTF-8 encoding
in the original Kaggle source files.

**Affected Tables:**

| Table | Column | Affected Rows | Example |
|---|---|---|---|
| geolocation_raw | geolocation_city | Unknown | `sÃ£o paulo` instead of `são paulo` |
| customer_raw | customer_city | Unknown | `sÃ£o paulo` instead of `são paulo` |
| sellers_raw | seller_city | Unknown | Corrupted characters |
| order_reviews_raw | review_comment_message | Unknown | Corrupted Portuguese text |

**Root Cause Analysis:**

CSV source files: Mixed UTF-8 encoding
MySQL import: Read as Latin-1 in some rows
Result: Corrupted special characters
Specific corruption pattern:
ã → Ã£
ç → Ã§
é → Ã©
ó → Ã³

**Resolution Attempts:**
Attempt 1: ALTER TABLE MODIFY COLUMN with utf8mb4
Result: Failed — encoding already corrupted in storage
Attempt 2: UPDATE with CONVERT(CAST(CONVERT ... USING latin1))
Result: Partially fixed but introduced new corruptions
(sãopaulo, sa£o paulo — mixed results)
Attempt 3: Re-import with CHARACTER SET utf8mb4
Result: Same issue — source file has mixed encoding
Conclusion: Source CSV file has mixed encoding
at the file level — cannot be fixed without
correcting original source data

**Business Impact:**
City-level geographic analysis: Unreliable
State-level analysis: ✅ Not affected (2-char codes)
Revenue analysis: ✅ Not affected
Order analysis: ✅ Not affected
Delivery analysis: ✅ Not affected (uses state code)

**Recommendation:**
For future data collection:

Enforce UTF-8 encoding at data source level
Validate encoding during data ingestion pipeline
Use state codes (SP, RJ) not city names
for geographic analysis — these are reliable


---

### Issue 9 — Missing Categories in product_name_raw
**Severity:** 🟢 Minor
**Status:** ✅ Resolved

**Description:**
3 category names existed in products_raw but
had no corresponding English translation in
product_name_raw. This blocked foreign key creation.

**Missing Categories:**

| Portuguese Name | English Added | Products Affected |
|---|---|---|
| unknown | unknown | 610 products |
| pc_gamer | pc_gamer | 3 products |
| portateis_cozinha_e_preparadores_de_alimentos | portable_kitchen_and_food_preparers | 10 products |

**Resolution:**
```sql
INSERT INTO product_name_raw
(product_category_name, product_category_name_english)
VALUES
('unknown', 'unknown'),
('pc_gamer', 'pc_gamer'),
('portateis_cozinha_e_preparadores_de_alimentos',
 'portable_kitchen_and_food_preparers');
```

---

## ✅ Referential Integrity Verification

All foreign key relationships were verified
using LEFT JOIN checks before adding constraints:

| Relationship | Orphan Records | Status |
|---|---|---|
| order_items → order_raw | 0 | ✅ Clean |
| order_items → products_raw | 0 | ✅ Clean |
| order_items → sellers_raw | 0 | ✅ Clean |
| order_payments → order_raw | 0 | ✅ Clean |
| order_reviews_raw → order_raw | 0 | ✅ Clean |
| order_raw → customer_raw | 0 | ✅ Clean |
| products_raw → product_name_raw | 0 | ✅ Clean* |

*After adding 3 missing categories

---

## ✅ Business Logic Validation

Checked for impossible date combinations:

| Validation | Check | Result |
|---|---|---|
| Approval before purchase | order_approved_at < order_purchase_timestamp | 0 violations ✅ |
| Delivery before shipping | order_delivered_customer_date < order_delivered_carrier_date | 0 violations ✅ |
| Estimated before purchase | order_estimated_delivery_date < order_purchase_timestamp | 0 violations ✅ |

---

## 📊 Statistical Outlier Analysis

| Table | Column | Min | Max | Mean | Std Dev | Outliers |
|---|---|---|---|---|---|---|
| order_items | price | R$0.85 | R$6,735 | R$120.65 | High | 3 items >R$5,000 |
| order_items | freight_value | R$0 | R$409.68 | R$19.99 | Normal | None critical |
| products_raw | product_weight_g | 0g | 40,425g | 2,276g | High | Heavy items valid |
| delivery_analysis | actual_delivery_days | 0 | 210 | 12.50 | High | Remote state orders |

**Outlier Decisions:**

| Outlier | Decision | Reason |
|---|---|---|
| Price R$6,735 | ✅ Kept | Valid high-end product |
| Weight 40,425g | ✅ Kept | Valid heavy furniture item |
| Delivery 210 days | ✅ Kept | Valid remote location order |

---

## 📈 Data Quality Improvement Summary

| Phase | Action | Impact |
|---|---|---|
| Phase 1 | Fixed 5 decimal columns | Restored accurate revenue data |
| Phase 1 | Fixed 8 datetime columns | Enabled delivery time analysis |
| Phase 1 | Optimized 15+ integer columns | Reduced storage by ~40% |
| Phase 1 | Corrected VARCHAR lengths | Improved storage efficiency |
| Phase 2 | Removed 31 invalid coordinates | Improved geographic accuracy |
| Phase 2 | Labeled 610 unknown categories | Maintained data completeness |
| Phase 2 | Added auto-increment to reviews | Fixed primary key issue |
| Phase 2 | Created geolocation_clean | Reduced 1M rows to 19K |
| Phase 3 | Added 7 foreign key constraints | Enforced data integrity |
| Phase 3 | Added 13 performance indexes | Improved query performance |

---

## 🎯 Final Data Quality Assessment

### What Can Be Trusted Fully ✅
- All revenue figures
- All order counts
- All delivery timing analysis
- All payment analysis
- All review score analysis
- State-level geographic analysis
- Product category analysis

### What Should Be Used With Caution ⚠️
- City-level geographic analysis
  (encoding issues in city names)
- review_id based joins
  (use order_id instead)

### What Cannot Be Fixed ❌
- UTF-8 encoding in city names
  (source data limitation)
- Missing product categories (610)
  (source data limitation — labeled unknown)

---

## 📋 Recommendations for Future Data Collection

1. **Enforce UTF-8 encoding** at data source
   before any export or CSV generation

2. **Mandatory product category** selection
   during seller product listing

3. **Unique constraint on review_id**
   at application database level

4. **Coordinate validation** at point of entry —
   reject coordinates outside Brazil boundaries

5. **Payment type validation** — prevent
   'not_defined' from being a valid option

6. **Installment validation** — minimum 1
   installment for credit card payments