# 🛒 Brazilian E-Commerce Analysis — Olist Dataset

## 📌 Project Overview

An end-to-end data analysis project on the 
**Olist Brazilian E-Commerce Dataset** from Kaggle.
This project covers the complete data analytics workflow —
from raw data import to interactive Power BI dashboard —
using **MySQL** for data engineering and analysis,
and **Power BI** for visualization.

---

## 🎯 Project Objectives

- Clean and optimize raw ecommerce data using SQL
- Identify data quality issues and fix them
- Build proper relational database with constraints
- Extract business insights using advanced SQL
- Visualize findings in an interactive Power BI dashboard

---

## 📊 Dataset

| Detail | Info |
|---|---|
| Source | Kaggle — Brazilian E-Commerce Dataset |
| Tables | 9 raw tables |
| Total Orders | 99,441 |
| Total Customers | 96,096 |
| Total Products | 32,951 |
| Time Period | 2016 — 2018 |

### Tables
- `customers_raw` — Customer information
- `orders_raw` — Order details and timestamps
- `order_items` — Items within each order
- `order_payments` — Payment information
- `order_reviews_raw` — Customer reviews
- `products_raw` — Product details
- `sellers_raw` — Seller information
- `geolocation_raw` — Geographic coordinates
- `product_name_raw` — Category translations

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| MySQL | Database, data cleaning, analysis |
| MySQL Workbench | Database management |
| Power BI Desktop | Dashboard and visualization |
| GitHub | Version control and portfolio |

---

## 📁 Project Structure

```
olist-ecommerce-sql-analysis/
├── sql/
│   ├── 1_create_table.sql
│   ├── 2_datatype_conversion.sql
│   ├── 3_data_cleaning.sql
│   ├── 4_table_relationship.sql
│   ├── 5_analysis_queries.sql
│   └── 6_create_views.sql
├── csv_exports/
│   ├── sales_summary.csv
│   ├── delivery_analysis.csv
│   ├── customer_analysis.csv
│   ├── product_analysis.csv
│   └── payment_analysis.csv
├── powerbi/
│   ├── olist_dashboard_new.pdf
│   └── olist_dashboard_new.pbix
└── README.md
```

---

## 🔄 Project Phases

### Phase 1 — Data Import & Type Correction
- Created 9 tables with optimized datatypes
- Fixed DECIMAL columns — price, freight, coordinates
- Fixed DATETIME columns — 8 date columns
- Optimized INT to TINYINT/SMALLINT where appropriate
- Converted TEXT to proper VARCHAR lengths
- Re-imported tables that had data loss due to wrong datatypes

### Phase 2 — Data Quality Checks
- Duplicate row detection across all 9 tables
- NULL and empty value identification and handling
- Encoding issue investigation (UTF-8 mixed encoding)
- Unexpected value detection and validation
- Referential integrity checks across all relationships
- Business logic validation (impossible date combinations)
- Statistical outlier detection
- Created `geolocation_clean` table from duplicate-heavy raw table

### Phase 3 — Relational Modeling
- Identified Snowflake Schema structure
- Added Primary Keys to all 9 tables
- Added Foreign Keys with ON DELETE RESTRICT ON UPDATE CASCADE
- Created 13 performance indexes
- Tested all constraints with INSERT and DELETE operations

### Phase 4 — SQL Business Analysis
- **Level 1** — 22 single table queries
- **Level 2** — 17 multi-table JOIN queries
- **Level 3** — 15 GROUP BY and aggregation queries
- **Level 4** — 12 subquery based queries
- **Level 5** — 12 window function queries

### Phase 5 — Dashboard Creation
- Created 5 analytical SQL views
- Exported views as CSV files
- Built 4-page interactive Power BI dashboard

---

## 📈 Key Business Insights

### Revenue
- 💰 Total Revenue → **R$ 13.59 Million**
- 📅 Best Month → **November 2017** (Black Friday — R$ 1.01M)
- 🏆 Top Category by Revenue → **Health & Beauty**
- 🗺️ Top State → **São Paulo (38% of total revenue)**

### Orders & Delivery
- 📦 Total Orders → **99,441**
- ✅ Delivery Success Rate → **97%**
- ⏱️ Average Delivery Time → **12.5 days**
- ⚠️ Late Deliveries → **8.11%**
- 🐌 Slowest States → **AP, RR, AM** (remote North Brazil)

### Customers
- 👥 Total Unique Customers → **96,096**
- 🏙️ Top City → **São Paulo (15,540 customers)**
- 🔄 Repeat Customer Rate → **Nearly 0%** (major business challenge)

### Products
- 📦 Most Sold Category → **Bed/Bath/Table**
- 💎 Most Expensive Category → **Computers (avg R$ 1,098)**
- ⭐ Average Review Score → **4.09 / 5**
- 😊 5-Star Reviews → **57.78% of all reviews**

### Payments
- 💳 Most Used Payment → **Credit Card (74%)**
- 📊 Average Installments → **2.85**
- 💰 Credit Card Revenue → **R$ 10.97M (80% of total)**

---

## 🖥️ Dashboard Pages

### Page 1 — Executive Overview
KPIs: Total Revenue, Orders, Customers, Avg Order Value
Charts: Monthly Revenue Trend, Revenue by State,
Top Categories, Order Status Distribution

### Page 2 — Product Performance
KPIs: Total Revenue, Products Sold, Avg Rating, Avg Price
Charts: Top Categories, Review Scores, Treemap,
Price Analysis, Revenue vs Satisfaction Scatter

### Page 3 — Delivery Analysis
KPIs: Avg Delivery Days, Late %, On-Time %, Avg Delay
Charts: Delivery Trend, Status Distribution,
State Performance, Yearly Comparison

### Page 4 — Customer & Payment
KPIs: Total Customers, Avg Spend, Payment Value, Installments
Charts: Payment Distribution, Customer Growth,
State Revenue, Installment Analysis, Top Customers

---

## 🔍 SQL Concepts Covered

| Concept | Used In |
|---|---|
| SELECT, WHERE, GROUP BY, ORDER BY | All levels |
| INNER JOIN, LEFT JOIN | Level 2+ |
| HAVING | Level 3+ |
| Subqueries in WHERE and FROM | Level 4 |
| EXISTS and NOT EXISTS | Level 4 |
| CASE WHEN | Multiple phases |
| DATEDIFF, YEAR, MONTH, STR_TO_DATE | Phase 1+ |
| NULLIF, COALESCE | Phase 1-2 |
| RANK, ROW_NUMBER, DENSE_RANK | Level 5 |
| LAG, LEAD | Level 5 |
| Running Totals, Moving Averages | Level 5 |
| PARTITION BY | Level 5 |
| ALTER TABLE, CREATE VIEW | Phase 1, 5 |
| PRIMARY KEY, FOREIGN KEY, INDEX | Phase 3 |

---

## 📌 How to Use This Project

### 1. Database Setup
```sql
-- Run scripts in order
1_create_table.sql
2_datatype_conversion.sql
3_data_cleaning.sql
4_table_relationship.sql
5_analysis_queries.sql
6_create_views.sql
```

### 2. Dashboard
- Open `powerbi/olist_dashboard.pbix`
- Refresh data sources if needed
- All 4 pages are interactive with cross-filtering

---

## 👤 Author

**Akhil T V**
- LinkedIn: www.linkedin.com/in/akhil-t-v
- GitHub: https://github.com/AKHIL572

---

## 📄 License
MIT License — feel free to use and modify!
