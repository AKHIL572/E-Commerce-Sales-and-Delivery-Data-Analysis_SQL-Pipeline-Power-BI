# 🛒 E-Commerce Sales & Delivery Data Analysis: SQL Pipeline & Power BI

📖 [Data Dictionary](docs/DATA_DICTIONARY.md) — 
Detailed description of all tables, 
columns and data quality notes
🔍 [Data Quality Report](docs/DATA_QUALITY_REPORT.md) —
Complete assessment of data issues found,
resolutions applied and remaining limitations
📊 [Statistical Analysis](docs/STATISTICAL_ANALYSIS.md) —
Correlation analysis, distribution analysis,
Pareto principle and seasonal patterns
📈 [KPI Framework](docs/KPI_FRAMEWORK.md) —
32 business KPIs with current values,
targets, gaps and monitoring frequency
👥 [RFM Analysis](docs/RFM_ANALYSIS.md) —
Customer segmentation using Recency,
Frequency and Monetary analysis with
11 customer segments and marketing
action recommendations


## 🏢 Business Context

Olist is Brazil's largest e-commerce marketplace 
that connects small and medium businesses to customers 
across Brazil through a single contract. Sellers can 
sell their products through the Olist Store and ship 
them directly to customers using Olist logistics 
partners.

Between 2016 and 2018, Olist experienced rapid growth:
- Order volume grew from 329 orders (2016) 
  to over 54,000 orders (2018)
- Expanded operations to all 27 Brazilian states
- Onboarded 3,095 sellers across the country
- Served over 96,000 unique customers

---

## ❗ Business Problem

Despite strong revenue growth of R$ 13.59 Million,
the business faces three critical challenges:

### Problem 1 — Declining Delivery Performance
On-time delivery rate dropped significantly:
- 2016: 98.53% on time
- 2017: 93.37% on time  
- 2018: 90.63% on time

As order volume grows, logistics quality is declining.
7,827 orders were delivered late — directly impacting
customer satisfaction.

### Problem 2 — Zero Customer Retention
Analysis reveals nearly 0% repeat customer rate.
Every month, the business depends entirely on 
acquiring new customers to generate revenue.
This makes growth expensive and unsustainable 
long term.

### Problem 3 — Geographic Delivery Inequality
Customers in northern Brazilian states (AP, RR, AM)
wait up to 29 days for delivery compared to the
national average of 12.5 days. This creates 
an unfair customer experience based on location.

---

## 🎯 Analysis Objectives

This analysis was conducted to answer the following
business questions:

1. Which states and regions generate most revenue 
   and orders?
   
2. Which product categories perform best in terms 
   of revenue, sales volume and customer satisfaction?
   
3. Where and why is delivery performance failing?
   Which states have the worst on-time rates?
   
4. What payment methods do customers prefer and 
   how does this affect order value?
   
5. Which sellers are top performers and which 
   underperform?
   
6. What is driving the 0% customer retention rate
   and what can be done about it?

7. Is there a relationship between delivery time
   and customer review scores?

---

## 👥 Intended Audience

This analysis is designed for:

| Team | Use Case |
|---|---|
| Operations Team | Identify and fix delivery bottlenecks |
| Marketing Team | Understand customer acquisition patterns |
| Product Team | Identify best performing categories |
| Executive Team | Monitor overall business KPIs |
| Logistics Team | Optimize delivery routes and partners |

---

## 📊 Expected Business Impact

By addressing the identified problems:

| Action | Expected Impact |
|---|---|
| Fix northern state delivery | Recover ~500 negative reviews/month |
| Improve repeat purchase rate by 5% | +R$ 679,582 additional annual revenue |
| Reduce late deliveries by 50% | Improve avg review score from 4.09 to 4.3+ |

---

---

## 💡 Key Findings & Actionable Recommendations

---

### 🔴 Finding 1 — Delivery Performance is Declining

**What the data shows:**
- On-time delivery dropped from 98.53% (2016) 
  to 90.63% (2018)
- 7,827 orders were delivered late
- Average delay for late orders: 10.62 days
- Late delivery directly correlates with 
  lower review scores

**Root Cause:**
- Northern and northeastern states have extremely
  long delivery times
- AP: 27.18 days average | RR: 29.34 days average
  AM: 26.36 days average
- These states are geographically remote with
  limited logistics infrastructure

**Business Impact:**
- Every 1% drop in on-time delivery = 
  approximately 965 unhappy customers
- Late deliveries generate negative reviews
  pulling average score down from potential 4.5+
  to current 4.09
- Customer trust erodes with repeated late deliveries

**Recommendations:**
1. Partner with regional logistics carriers
   specifically operating in North Brazil
   (Amazonas, Amapá, Roraima)
   
2. Set realistic and honest delivery estimates
   for remote states instead of using national
   average estimates — currently promising 
   12.5 days but delivering in 27-29 days
   
3. Consider establishing regional micro-warehouses
   in Manaus (AM) to serve northern states faster
   
4. Implement a delivery monitoring alert system —
   flag orders that are 3+ days past estimate
   for proactive customer communication

**Expected Outcome:**
- Improving northern states to 90% on-time
  could recover ~500 negative reviews per month
- Average review score could improve 
  from 4.09 to 4.3+

---

### 🔴 Finding 2 — Zero Customer Retention Rate

**What the data shows:**
- Nearly 0% of customers placed a second order
- Every single month depends entirely on 
  acquiring brand new customers
- 96,096 customers — almost all one-time buyers
- Customer Lifetime Value is effectively 
  limited to single purchase: R$ 148.90

**Root Cause:**
- No loyalty or rewards program identified
- No personalized re-engagement campaigns
- Possible post-purchase experience issues
  (late delivery, product quality)
- Marketplace model — customers may return
  but through different seller accounts

**Business Impact:**
- Customer Acquisition Cost (CAC) must be
  recovered from single purchase only
- Unsustainable long-term growth model
- Missing R$ 679,582+ in potential annual
  revenue if only 5% of customers returned
  (96,096 × 5% × R$141 avg spend)
- Business is a treadmill — must constantly
  find new customers just to maintain revenue

**Recommendations:**
1. Implement a customer loyalty program —
   reward points for repeat purchases
   
2. Launch post-purchase email campaigns —
   personalized product recommendations
   based on previous purchase category
   
3. Offer first-time repeat purchase discount —
   even 5-10% off second order could 
   significantly improve retention
   
4. Investigate post-purchase experience —
   survey customers who gave low scores
   on whether they would buy again
   
5. Track customer cohorts monthly —
   measure if retention rate improves
   after implementing loyalty programs

**Expected Outcome:**
- Even 5% repeat customer rate would generate
  R$ 679,582 additional annual revenue
- 10% repeat rate = R$ 1.36M additional revenue
- Reducing dependency on constant 
  new customer acquisition

---

### 🟡 Finding 3 — Geographic Revenue Concentration

**What the data shows:**
- São Paulo state alone generates 38% 
  of total revenue (R$ 5.20M)
- Top 3 states (SP, RJ, MG) = 68% of revenue
- Southern states have very few sellers
  but significant customer base
- Many northern states have only 1-2 sellers

**Root Cause:**
- Sellers are concentrated in Southeast Brazil
- SP has 59.74% of all sellers
- Limited seller presence in 
  North and Northeast regions

**Business Impact:**
- Over-dependence on single region 
  creates business risk
- Underserved markets in North/Northeast
  represent untapped revenue opportunity
- Long delivery times in North partly caused
  by lack of local sellers

**Recommendations:**
1. Launch targeted seller recruitment campaign
   in North and Northeast Brazil
   (AM, PA, CE, BA regions)
   
2. Offer reduced commission rates for 
   new sellers in underserved states
   to incentivize marketplace expansion
   
3. Create regional seller training programs
   to onboard local businesses faster
   
4. Identify top 5 underserved states and
   set quarterly seller growth targets

**Expected Outcome:**
- Adding 100 sellers in northern states
  could reduce delivery times by 30-40%
- Unlocking ~15% untapped revenue potential
  from currently underserved markets

---

### 🟡 Finding 4 — Product Category Opportunity Gap

**What the data shows:**
- Bed/Bath/Table is most sold (11,115 items)
  but only 3rd in revenue (R$ 1.03M)
- Health/Beauty is #1 in revenue (R$ 1.26M)
  despite being #2 in sales volume
- Watches/Gifts is #2 in revenue (R$ 1.20M)
  but #7 in sales volume
- High value categories 
  (Computers avg R$1,098) have low volume

**Root Cause:**
- High volume categories have low unit prices
- High revenue categories have low volume
  indicating premium pricing opportunity

**Business Impact:**
- Promoting high-margin categories 
  (Watches, Computers) could significantly
  increase revenue without needing more orders
- Current mix heavily weighted toward 
  low-margin, high-volume products

**Recommendations:**
1. Increase marketing investment for
   high-margin categories:
   Watches/Gifts, Computers, Health/Beauty
   
2. Create premium product collections or
   bundles in high-margin categories
   
3. Use review score data to promote 
   highest-rated categories:
   CDs/DVDs (4.64), Books (4.44), Flowers (4.42)
   
4. Analyze why Computers category has
   high prices but low review correlation —
   potential quality or expectation issue

**Expected Outcome:**
- 10% shift from low-margin to high-margin
  categories could increase revenue by 
  R$ 500K+ without additional order volume

---

### 🟢 Finding 5 — Payment Method Insights

**What the data shows:**
- Credit card dominates: 73.78% of orders
- Boleto: 19.44% — significant in Brazil
- Average installments: 2.85
- Single payment (1 installment): 52,546 orders
- High installments (7+) are rare but exist

**Root Cause:**
- Brazilian market preference for installment
  payments is well established
- Boleto usage indicates significant 
  unbanked or credit-limited customer segment

**Business Impact:**
- Boleto customers represent 19.44% of orders
  that could be lost if payment method removed
- Installment availability enables higher
  value purchases for credit-limited customers

**Recommendations:**
1. Maintain and promote Boleto payment option —
   removing it would risk losing 19% of orders
   
2. Offer extended installment plans (up to 12x)
   for high-value categories like Computers
   and Furniture to increase conversion
   
3. Consider PIX payment integration —
   Brazil's instant payment system launched
   after this dataset period but now dominant
   
4. Promote installment options in marketing
   for high-value products to reduce 
   price barrier for customers

**Expected Outcome:**
- Extended installments for high-value items
  could increase Computers and Electronics
  conversion rate by estimated 15-20%

---

### 🟢 Finding 6 — Seller Performance Concentration

**What the data shows:**
- Top seller generated R$ 229,472
- Average seller handles only 36 orders
- SP state sellers generate R$ 8.75M
  (64% of total seller revenue)
- Many states have only 1-2 sellers

**Root Cause:**
- Platform growth driven by few top performers
- Long tail of small sellers with minimal impact
- Geographic concentration mirrors customer base

**Business Impact:**
- Over-reliance on top 10 sellers creates risk
- If top seller leaves platform → significant
  revenue impact
- Many sellers not reaching their potential

**Recommendations:**
1. Create seller success program for 
   mid-tier sellers (R$ 10K-50K revenue)
   to help them reach next level
   
2. Identify and reward top sellers with
   premium placement and reduced fees
   
3. Provide analytics dashboard to sellers
   showing their performance vs category average
   
4. Create seller mentorship program pairing
   top performers with new sellers

**Expected Outcome:**
- Moving 100 mid-tier sellers from 
  R$ 10K to R$ 20K average revenue
  = R$ 1M additional platform revenue

---

## 📋 Recommendations Priority Matrix

| Finding | Priority | Effort | Impact | Action Owner |
|---|---|---|---|---|
| Declining delivery | 🔴 Critical | High | Very High | Operations |
| Zero retention | 🔴 Critical | Medium | Very High | Marketing |
| Geographic concentration | 🟡 High | Medium | High | Business Dev |
| Category mix optimization | 🟡 High | Low | High | Marketing |
| Payment optimization | 🟢 Medium | Low | Medium | Product |
| Seller performance | 🟢 Medium | Medium | Medium | Seller Success |

---

## 📊 Summary Dashboard of Recommendations

| Metric | Current | Target | Gap |
|---|---|---|---|
| On-time delivery rate | 90.63% | 95%+ | -4.37% |
| Repeat customer rate | ~0% | 10% | -10% |
| Northern state delivery | 27-29 days | 15 days | -12-14 days |
| Average review score | 4.09/5 | 4.3/5 | -0.21 |
| Revenue from top 3 states | 68% | 55% | -13% |
| Seller geographic spread | 60% in SP | 40% in SP | -20% |
