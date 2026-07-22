# 📈 KPI Framework & Business Metrics
# Olist E-Commerce Analysis

**Project:** Brazilian E-Commerce Analysis
**Author:** Your Name
**Date:** 2024
**Purpose:** Define, measure and evaluate key
business performance indicators for Olist platform

---

## 📋 Table of Contents

1. [KPI Framework Overview](#1-kpi-framework-overview)
2. [Revenue KPIs](#2-revenue-kpis)
3. [Order KPIs](#3-order-kpis)
4. [Delivery KPIs](#4-delivery-kpis)
5. [Customer KPIs](#5-customer-kpis)
6. [Product KPIs](#6-product-kpis)
7. [Seller KPIs](#7-seller-kpis)
8. [Payment KPIs](#8-payment-kpis)
9. [KPI Dashboard Summary](#9-kpi-dashboard-summary)
10. [KPI Targets and Gaps](#10-kpi-targets-and-gaps)

---

## 1. KPI Framework Overview

### What is a KPI?
A Key Performance Indicator (KPI) is a measurable
value that demonstrates how effectively a company
is achieving its key business objectives.

### KPI Categories Used

| Category | Number of KPIs | Business Area |
|---|---|---|
| Revenue | 5 | Finance |
| Orders | 4 | Operations |
| Delivery | 6 | Logistics |
| Customer | 5 | Marketing |
| Product | 4 | Merchandising |
| Seller | 4 | Partner Success |
| Payment | 4 | Finance |
| **Total** | **32 KPIs** | **All Areas** |

### KPI Status Legend

| Status | Symbol | Meaning |
|---|---|---|
| On Target | 🟢 | Meeting or exceeding benchmark |
| Watch | 🟡 | Close to threshold — monitor closely |
| Critical | 🔴 | Below acceptable threshold — action needed |
| No Benchmark | ⚪ | Baseline established — no industry benchmark |

---

## 2. Revenue KPIs

---

### KPI R1 — Total Revenue

| Field | Value |
|---|---|
| **KPI Name** | Total Revenue |
| **Definition** | Sum of all product prices from completed orders |
| **Formula** | SUM(price) from order_items |
| **Current Value** | R$ 13,591,643.70 |
| **Time Period** | September 2016 — August 2018 |
| **Unit** | Brazilian Reais (R$) |
| **Status** | ⚪ Baseline established |

```sql
-- SQL to calculate
SELECT ROUND(SUM(price), 2) AS total_revenue
FROM order_items;
```

**Trend:**

2016 (partial): R$ 46,654
2017 (full):    R$ 6,921,535
2018 (partial): R$ 6,623,454
Growth 2016→2017: +14,738%
Growth 2017→2018: -4.3% (partial year)

**Business Note:**
Revenue growth is exceptional but 2018 data only
covers January to August — full year 2018 would
likely exceed 2017.

---

### KPI R2 — Average Order Value (AOV)

| Field | Value |
|---|---|
| **KPI Name** | Average Order Value |
| **Definition** | Average revenue generated per unique order |
| **Formula** | SUM(price) / DISTINCTCOUNT(order_id) |
| **Current Value** | R$ 140.68 |
| **Industry Benchmark** | R$ 120 — R$ 180 for Brazilian ecommerce |
| **Status** | 🟢 On Target |

```sql
-- SQL to calculate
SELECT
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)
        AS avg_order_value
FROM order_items oi
JOIN order_raw o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';
```

**Trend:**

Average stays relatively stable at R$130-R$150
No significant growth in basket size
Opportunity: Upselling and cross-selling strategy

---

### KPI R3 — Revenue Growth Rate (Month over Month)

| Field | Value |
|---|---|
| **KPI Name** | Monthly Revenue Growth Rate |
| **Definition** | Percentage change in revenue vs previous month |
| **Formula** | (Current Month - Previous Month) / Previous Month × 100 |
| **2017 Average** | +18.3% per month |
| **2018 Average** | +2.1% per month |
| **Target** | 10%+ monthly growth |
| **Status** | 🟡 Watch — Growth slowing in 2018 |

```sql
-- SQL to calculate
WITH monthly AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS yr,
        MONTH(o.order_purchase_timestamp) AS mo,
        SUM(oi.price) AS revenue
    FROM order_raw o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY yr, mo
)
SELECT
    yr, mo, revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY yr, mo))
        * 100.0
        / LAG(revenue) OVER (ORDER BY yr, mo)
    , 2) AS growth_rate_pct
FROM monthly
ORDER BY yr, mo;
```

**Key Observation:**
Growth rate dropped from 18.3% average in 2017
to 2.1% in 2018 — strong signal that the business
is maturing and needs new growth strategies.

---

### KPI R4 — Revenue Concentration Risk

| Field | Value |
|---|---|
| **KPI Name** | Top State Revenue Concentration |
| **Definition** | Percentage of revenue from top 1 state |
| **Current Value** | SP = 38.3% of total revenue |
| **Risk Threshold** | Above 40% = high concentration risk |
| **Status** | 🟡 Watch — approaching risk threshold |

**State Revenue Share:**

SP:  38.3% ← approaching risk threshold
RJ:  13.4%
MG:  11.7%
Top 3: 63.4% of all revenue

**Business Risk:**
Any disruption in São Paulo operations
(logistics strike, natural disaster, regulations)
would impact 38.3% of total revenue immediately.

---

### KPI R5 — Revenue per Seller

| Field | Value |
|---|---|
| **KPI Name** | Average Revenue per Seller |
| **Definition** | Total revenue divided by number of active sellers |
| **Formula** | SUM(price) / COUNT(DISTINCT seller_id) |
| **Current Value** | R$ 4,391.37 per seller |
| **Top Seller** | R$ 229,472 |
| **Bottom 50%** | Under R$ 500 |
| **Status** | ⚪ Baseline established |

```sql
SELECT
    ROUND(SUM(price) /
        COUNT(DISTINCT seller_id), 2) AS avg_revenue_per_seller,
    MAX(seller_revenue) AS top_seller_revenue,
    MIN(seller_revenue) AS min_seller_revenue
FROM (
    SELECT seller_id, SUM(price) AS seller_revenue
    FROM order_items
    GROUP BY seller_id
) seller_totals;
```

---

## 3. Order KPIs

---

### KPI O1 — Total Orders

| Field | Value |
|---|---|
| **KPI Name** | Total Orders |
| **Current Value** | 99,441 orders |
| **2016** | 329 orders |
| **2017** | 45,101 orders |
| **2018** | 54,011 orders (Jan-Aug only) |
| **Status** | ⚪ Baseline — strong growth |

---

### KPI O2 — Order Success Rate

| Field | Value |
|---|---|
| **KPI Name** | Order Success Rate |
| **Definition** | Percentage of orders successfully delivered |
| **Formula** | Delivered Orders / Total Orders × 100 |
| **Current Value** | 97.0% |
| **Industry Benchmark** | 95%+ |
| **Status** | 🟢 On Target |

```sql
SELECT
    ROUND(
        SUM(CASE WHEN order_status = 'delivered'
            THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) AS success_rate
FROM order_raw;
```

---

### KPI O3 — Cancellation Rate

| Field | Value |
|---|---|
| **KPI Name** | Order Cancellation Rate |
| **Definition** | Percentage of orders canceled |
| **Current Value** | 0.63% |
| **Industry Benchmark** | Under 2% |
| **Status** | 🟢 On Target — excellent |

```sql
SELECT
    ROUND(
        SUM(CASE WHEN order_status = 'canceled'
            THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) AS cancellation_rate
FROM order_raw;
```

---

### KPI O4 — Average Items per Order

| Field | Value |
|---|---|
| **KPI Name** | Average Items per Order |
| **Definition** | Average number of items in each order |
| **Current Value** | 1.13 items per order |
| **Industry Benchmark** | 1.5 — 2.0 for ecommerce |
| **Gap** | -0.37 to -0.87 items |
| **Status** | 🔴 Below benchmark |

```sql
SELECT
    ROUND(COUNT(order_item_id) * 1.0
        / COUNT(DISTINCT order_id), 2)
        AS avg_items_per_order
FROM order_items;
```

**Business Opportunity:**
Low items per order = missed cross-selling opportunity
Implementing product recommendations at checkout
could increase this from 1.13 to 1.5+
= 32% more revenue without new customers

---

## 4. Delivery KPIs

---

### KPI D1 — On-Time Delivery Rate

| Field | Value |
|---|---|
| **KPI Name** | On-Time Delivery Rate |
| **Definition** | Orders delivered on or before estimated date |
| **Current Value** | 91.89% |
| **2016 Value** | 98.53% |
| **2017 Value** | 93.37% |
| **2018 Value** | 90.63% |
| **Industry Benchmark** | 95%+ |
| **Target** | 95% |
| **Gap** | -3.11% |
| **Status** | 🔴 Critical — declining trend |

```sql
SELECT
    ROUND(
        SUM(CASE WHEN delivery_status = 'On Time'
            THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2) AS on_time_rate
FROM delivery_analysis;
```

**Trend Analysis:**

2016: 98.53% ██████████ Excellent
2017: 93.37% █████████░ Good
2018: 90.63% █████████░ Below Target
Trend: Declining 2.6% per year
Projection 2019: ~88% if not addressed

---

### KPI D2 — Average Delivery Days

| Field | Value |
|---|---|
| **KPI Name** | Average Delivery Days |
| **Definition** | Average days from purchase to delivery |
| **Current Value** | 12.50 days |
| **Median Value** | 10 days |
| **Industry Benchmark** | 7-10 days |
| **Gap** | +2.5 to +5.5 days |
| **Status** | 🔴 Below benchmark |

---

### KPI D3 — Late Delivery Rate

| Field | Value |
|---|---|
| **KPI Name** | Late Delivery Rate |
| **Definition** | Percentage of orders delivered after estimate |
| **Current Value** | 8.11% |
| **Total Late Orders** | 7,827 |
| **Target** | Under 5% |
| **Status** | 🔴 Critical |

---

### KPI D4 — Average Delay Days (Late Orders Only)

| Field | Value |
|---|---|
| **KPI Name** | Average Delay for Late Orders |
| **Definition** | Average days past estimate for late orders |
| **Current Value** | 10.62 days |
| **Target** | Under 5 days |
| **Status** | 🔴 Critical |

**Business Impact:**
Late orders average 10.62 days past estimate
Customer expecting delivery on day 12
Actually receives on day 22-23
This is a terrible customer experience!

---

### KPI D5 — Worst Performing States

| Rank | State | Avg Delivery Days | On-Time Rate |
|---|---|---|---|
| 1 | RR | 29.34 days | 87.80% |
| 2 | AP | 27.18 days | 95.52% |
| 3 | AM | 26.36 days | 95.86% |
| 4 | AL | 24.50 days | 76.07% |
| 5 | PA | 23.73 days | 87.63% |

**Status:** 🔴 Critical for AL and RR

---

### KPI D6 — Best Performing States

| Rank | State | Avg Delivery Days | On-Time Rate |
|---|---|---|---|
| 1 | RO | 15.2 days | 97.12% |
| 2 | AC | 21.0 days | 96.25% |
| 3 | AM | 26.4 days | 95.86% |
| 4 | AP | 27.2 days | 95.52% |
| 5 | PR | 10.5 days | 95.00% |

---

## 5. Customer KPIs

---

### KPI C1 — Total Unique Customers

| Field | Value |
|---|---|
| **KPI Name** | Total Unique Customers |
| **Current Value** | 96,096 |
| **Growth Rate** | Consistent monthly growth |
| **Status** | ⚪ Baseline — growing |

---

### KPI C2 — Customer Retention Rate

| Field | Value |
|---|---|
| **KPI Name** | Customer Retention Rate |
| **Definition** | Percentage of customers who made repeat purchase |
| **Current Value** | ~0% |
| **Industry Benchmark** | 20-30% for ecommerce |
| **Gap** | -20 to -30% |
| **Status** | 🔴 Critical — most important KPI to fix |

```sql
-- Calculate repeat customers
SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2) AS retention_rate
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customer_raw c
    JOIN order_raw o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) customer_orders;
```

**Business Impact:**

Current: ~0% retention
Target: 10% retention
Impact of reaching 10%:
= 9,610 returning customers
× R$148.90 average spend
= R$1,430,969 additional annual revenue

---

### KPI C3 — Average Customer Lifetime Value (CLV)

| Field | Value |
|---|---|
| **KPI Name** | Customer Lifetime Value |
| **Definition** | Average total revenue per unique customer |
| **Current Value** | R$ 148.90 |
| **Potential with 10% retention** | R$ 297.80 |
| **Industry Benchmark** | 3-5x average order value |
| **Current Multiple** | 1.06x (very low) |
| **Status** | 🔴 Critical |

**Explanation:**
CLV should ideally be 3-5x the average order value.
Currently CLV (R$148.90) is only 1.06x AOV (R$140.68)
meaning almost every customer buys only once.

---

### KPI C4 — Geographic Customer Concentration

| Field | Value |
|---|---|
| **KPI Name** | Customer Geographic Concentration |
| **Top State** | SP = 43.4% of customers |
| **Top 3 States** | SP+RJ+MG = 68.0% |
| **Risk Level** | Moderate |
| **Status** | 🟡 Watch |

---

### KPI C5 — Customer Satisfaction Score

| Field | Value |
|---|---|
| **KPI Name** | Average Customer Satisfaction Score |
| **Definition** | Average review score from all reviews |
| **Current Value** | 4.09 / 5.00 |
| **Industry Benchmark** | 4.2+ for top ecommerce |
| **Gap** | -0.11 points |
| **Status** | 🟡 Watch |

**Score Distribution:**

5 stars: 57.78% ████████████
4 stars: 19.29% ████
3 stars:  8.24% ██
2 stars:  3.18% █
1 star:  11.51% ███

**Note:** Bimodal distribution — customers either
love it (5 stars) or hate it (1 star).
1-star reviews are likely late delivery related.

---

## 6. Product KPIs

---

### KPI P1 — Top Revenue Category

| Field | Value |
|---|---|
| **KPI Name** | Top Revenue Generating Category |
| **Current Leader** | health_beauty |
| **Revenue** | R$ 1,258,681 |
| **Share of Total** | 9.3% |
| **Status** | ⚪ Monitoring |

---

### KPI P2 — Category Revenue Concentration

| Field | Value |
|---|---|
| **KPI Name** | Top Category Revenue Share |
| **Top 5 Categories** | 39.8% of total revenue |
| **Top 10 Categories** | 55.2% of total revenue |
| **Top 15 Categories** | 80.4% of total revenue |
| **Total Categories** | 73 active categories |
| **Status** | ⚪ Acceptable concentration |

---

### KPI P3 — Average Product Rating

| Field | Value |
|---|---|
| **KPI Name** | Average Product Rating |
| **Current Value** | 4.09 / 5.00 |
| **Highest Category** | cds_dvds_musicais — 4.64 |
| **Lowest Category** | security_and_services — 2.50 |
| **Target** | 4.2+ |
| **Status** | 🟡 Watch |

---

### KPI P4 — Product Category Coverage

| Field | Value |
|---|---|
| **KPI Name** | Active Product Categories |
| **Total Categories** | 73 |
| **Unknown Category** | 1 (610 products) |
| **Categories with Sales** | 72 |
| **Status** | 🟢 Good coverage |

---

## 7. Seller KPIs

---

### KPI S1 — Total Active Sellers

| Field | Value |
|---|---|
| **KPI Name** | Total Active Sellers |
| **Current Value** | 3,095 sellers |
| **Geographic Spread** | 23 states covered |
| **Status** | ⚪ Baseline |

---

### KPI S2 — Seller Revenue Concentration (Pareto)

| Field | Value |
|---|---|
| **KPI Name** | Top Seller Revenue Concentration |
| **Top 10% sellers** | Generate 68.3% of revenue |
| **Top 20% sellers** | Generate 82.7% of revenue |
| **Risk Level** | High — Pareto distribution confirmed |
| **Status** | 🔴 High concentration risk |

---

### KPI S3 — Average Orders per Seller

| Field | Value |
|---|---|
| **KPI Name** | Average Orders per Seller |
| **Current Value** | 36.4 orders per seller |
| **Top Seller** | Thousands of orders |
| **Bottom 50%** | Under 10 orders |
| **Status** | ⚪ Baseline |

---

### KPI S4 — Seller Geographic Distribution

| Field | Value |
|---|---|
| **KPI Name** | Seller Geographic Concentration |
| **SP Sellers** | 59.74% of all sellers |
| **Top 3 States** | SP+PR+MG = 78.9% of sellers |
| **States with 1 Seller** | 8 states |
| **Status** | 🔴 High concentration risk |

---

## 8. Payment KPIs

---

### KPI Pay1 — Payment Method Distribution

| Payment Type | Orders | Share |
|---|---|---|
| Credit Card | 76,795 | 73.78% |
| Boleto | 19,784 | 19.44% |
| Voucher | 5,775 | 5.33% |
| Debit Card | 1,529 | 1.41% |
| Not Defined | 3 | 0.003% |

**Status:** 🟢 Healthy — diverse payment options

---

### KPI Pay2 — Average Installments

| Field | Value |
|---|---|
| **KPI Name** | Average Payment Installments |
| **Current Value** | 2.85 installments |
| **Single Payment (1x)** | 50.5% of orders |
| **High Installments (7+)** | 12.5% of orders |
| **Status** | ⚪ Typical for Brazilian market |

---

### KPI Pay3 — Credit Card Revenue Share

| Field | Value |
|---|---|
| **KPI Name** | Credit Card Revenue Contribution |
| **Current Value** | 80.7% of total payment value |
| **2016 Share** | 54.8% |
| **2017 Share** | 52.1% |
| **2018 Share** | 51.9% |
| **Status** | ⚪ Monitoring trend |

**Note:** Credit card share by value is higher than
by order count (73.78%) because credit card users
place larger orders on average.

---

### KPI Pay4 — Payment Error Rate

| Field | Value |
|---|---|
| **KPI Name** | Payment Error Rate |
| **Not Defined Payments** | 3 orders |
| **Zero Installment Payments** | 2 orders |
| **Error Rate** | 0.005% |
| **Status** | 🟢 Excellent |

---

## 9. KPI Dashboard Summary

### Complete KPI Scorecard

| KPI | Current | Target | Gap | Status |
|---|---|---|---|---|
| **REVENUE** | | | | |
| Total Revenue | R$13.59M | R$20M | -R$6.41M | ⚪ |
| Average Order Value | R$140.68 | R$160 | -R$19.32 | 🟡 |
| Revenue Growth Rate | 2.1%/mo | 10%/mo | -7.9% | 🟡 |
| Revenue Concentration | 38.3% SP | Under 35% | +3.3% | 🟡 |
| Revenue per Seller | R$4,391 | R$6,000 | -R$1,609 | 🟡 |
| **ORDERS** | | | | |
| Order Success Rate | 97.0% | 95%+ | +2% | 🟢 |
| Cancellation Rate | 0.63% | Under 2% | -1.37% | 🟢 |
| Items per Order | 1.13 | 1.5+ | -0.37 | 🔴 |
| **DELIVERY** | | | | |
| On-Time Rate | 91.89% | 95%+ | -3.11% | 🔴 |
| Avg Delivery Days | 12.50 | Under 10 | +2.5 days | 🔴 |
| Late Delivery Rate | 8.11% | Under 5% | +3.11% | 🔴 |
| Avg Delay (Late) | 10.62 days | Under 5 | +5.62 days | 🔴 |
| **CUSTOMER** | | | | |
| Retention Rate | ~0% | 10%+ | -10% | 🔴 |
| Customer CLV | R$148.90 | R$400+ | -R$251 | 🔴 |
| Satisfaction Score | 4.09/5 | 4.2+ | -0.11 | 🟡 |
| **PRODUCT** | | | | |
| Avg Product Rating | 4.09/5 | 4.2+ | -0.11 | 🟡 |
| **SELLER** | | | | |
| Top 20% Revenue Share | 82.7% | Under 70% | +12.7% | 🔴 |
| Seller Geographic Spread | 59.7% SP | Under 40% | +19.7% | 🔴 |
| **PAYMENT** | | | | |
| Payment Error Rate | 0.005% | Under 1% | -0.995% | 🟢 |

---

## 10. KPI Targets and Gaps

### Priority 1 — Critical KPIs (Must Fix)

| KPI | Current | Target | How to Achieve |
|---|---|---|---|
| Customer Retention | ~0% | 10% | Loyalty program + email campaigns |
| On-Time Delivery | 91.89% | 95% | Regional carrier partnerships |
| Items per Order | 1.13 | 1.5 | Product recommendation engine |
| Seller Concentration | 82.7% top 20% | 70% | Mid-tier seller growth program |

### Priority 2 — Watch KPIs (Monitor Closely)

| KPI | Current | Target | How to Achieve |
|---|---|---|---|
| Revenue Growth | 2.1%/mo | 10%/mo | New market expansion |
| Avg Order Value | R$140.68 | R$160 | Upselling strategy |
| Satisfaction Score | 4.09/5 | 4.2/5 | Fix delivery → fix scores |
| Revenue Concentration | 38.3% SP | 35% | Geographic expansion |

### Priority 3 — Strong KPIs (Maintain)

| KPI | Current | Target | Action |
|---|---|---|---|
| Order Success Rate | 97.0% | 95%+ | Maintain current operations |
| Cancellation Rate | 0.63% | Under 2% | Continue monitoring |
| Payment Error Rate | 0.005% | Under 1% | No action needed |

---

## 📊 KPI Monitoring Recommended Frequency

| KPI Category | Review Frequency | Responsible Team |
|---|---|---|
| Revenue KPIs | Weekly | Finance Team |
| Order KPIs | Daily | Operations Team |
| Delivery KPIs | Daily | Logistics Team |
| Customer KPIs | Monthly | Marketing Team |
| Product KPIs | Monthly | Merchandising Team |
| Seller KPIs | Monthly | Partner Success Team |
| Payment KPIs | Weekly | Finance Team |

---

## 🔍 KPI Calculation Reference

All KPIs can be monitored using the following
SQL queries against the analytical views:

```sql
-- Quick KPI Dashboard Query
SELECT
    -- Revenue KPIs
    ROUND(SUM(ss.price), 2) AS total_revenue,
    ROUND(SUM(ss.price) /
        COUNT(DISTINCT ss.order_id), 2) AS avg_order_value,

    -- Order KPIs
    COUNT(DISTINCT ss.order_id) AS total_orders,
    COUNT(DISTINCT ss.customer_unique_id) AS total_customers,

    -- Delivery KPIs
    ROUND(AVG(da.actual_delivery_days), 2)
        AS avg_delivery_days,
    ROUND(SUM(CASE WHEN da.delivery_status = 'On Time'
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(da.order_id), 2) AS on_time_rate,

    -- Customer KPIs
    ROUND(AVG(orr.review_score), 2) AS avg_review_score,

    -- Payment KPIs
    ROUND(AVG(pa.payment_installments), 2)
        AS avg_installments

FROM sales_summary ss
LEFT JOIN delivery_analysis da
    ON ss.order_id = da.order_id
LEFT JOIN order_reviews_raw orr
    ON ss.order_id = orr.order_id
LEFT JOIN payment_analysis pa
    ON ss.order_id = pa.order_id;
    
```