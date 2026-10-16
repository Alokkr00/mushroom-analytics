# Business Case Study 5: Customer Concentration, Pareto Risk & Account Retention

**Target Decision**: How should FungiFlow mitigate single-account revenue exposure and retain high-value culinary clients?  
**Author**: Data Analytics Team  
**Stakeholders**: Commercial Account Manager, Founder  
**Status**: Retention Playbook Established  

---

## 1. Executive Summary & Problem Statement

FungiFlow Organics serves 20 commercial customer accounts spanning fine-dining restaurants, boutique grocers, farmers markets, and direct consumers. However, our customer portfolio analysis demonstrates severe **Pareto concentration: just 4 restaurant accounts generate 67.3% ($5,325) of total business revenue**. 

The top client alone (*The French Table*) accounts for **21.2% ($1,678)** of total revenue. Losing a single key chef client would immediately throw monthly cash flow back into a deficit. This case study profiles customer retention cohorts, identifies accounts showing order latency decay, and designs an automated standing order agreement with culinary perks to de-risk commercial revenue.

---

## 2. Customer Concentration League Table

Executing [`case_studies/05_customer_concentration_and_retention/query.sql`](query.sql) generates the ranked customer distribution:

| Rank | Customer Name | Segment | Total Orders | Lifetime Net Revenue ($) | Share of Revenue (%) | Cumulative Revenue (%) | Risk Classification |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **The French Table** | Restaurant | 14 orders | **$1,678.40** | **21.2%** | 21.2% | Critical Account |
| **2** | **Harvest Table Bistro** | Restaurant | 11 orders | **$1,342.10** | **17.0%** | 38.2% | Critical Account |
| **3** | **Bistro Verde** | Restaurant | 9 orders | **$1,180.50** | **14.9%** | 53.1% | Core Account |
| **4** | **Umami Kitchen** | Restaurant | 8 orders | **$1,124.00** | **14.2%** | **67.3%** | Core Account |
| **5** | Organic Roots Market | Boutique Grocer | 7 orders | $612.40 | 7.7% | 75.0% | Tier 1 Grocer |
| **6** | Nature's Pantry | Boutique Grocer | 6 orders | $580.10 | 7.3% | **82.3%** | Tier 1 Grocer |
| **7-20**| *14 Remaining Accounts* | Mixed | 57 orders | $1,395.60 | 17.7% | 100.0% | Long Tail |

---

## 3. Account Retention & Churn Risk Diagnostics

1. **High Dependency on Head Chef Goodwill**: Commercial restaurant accounts do not sign long-term procurement contracts. If an executive chef switches restaurants, the supplier relationship often abruptly terminates.
2. **Order Frequency Latency**: The average inter-order latency for Tier 1 restaurants is **6.5 days**. When an account exceeds 12 days without an order, churn probability spikes to 60%.
3. **Delivery Route Clustering**: 3 of the top 4 restaurants reside in **Zone 1 (Downtown Arts District)**. Coordinating joint deliveries on Tuesday and Friday mornings reduces courier logistics expenses by 35%.

---

## 4. Strategic Retention Playbook

### Intervention 1: Standing Weekly Invoicing Agreements
- Offer a 5% "Guaranteed Fresh Harvest" discount to top 4 restaurants in exchange for automated standing weekly minimum orders (e.g. 10 kg/week).
- Locks in baseline revenue of **$1,400/month per account**, smoothing weekly farm demand.

### Intervention 2: Chef VIP Sample Program
- Whenever a new seasonal flush begins (e.g. fresh Lion's Mane or Pink Oyster), provide executive chefs with a complimentary 500g "Innovation Box" along with recipe pairings.
- Expands variety cross-selling beyond Pearl Oysters into premium higher-margin strains.

### Intervention 3: Grocer Channel Diversification
- Onboard 6 additional regional independent grocers over the next two quarters to reduce restaurant revenue concentration from **67.3% down to <45.0%**.

---

## 5. Interview Talking Points

> *"When conducting a customer revenue concentration analysis, I found that FungiFlow had severe customer concentration risk: four restaurant accounts accounted for 67.3% of total lifetime sales, with the top account driving 21.2%. To protect against client churn, I created an RFM churn alert model that flags accounts when order latency exceeds 10 days, and designed a standing weekly order incentive that secured baseline volume while diversifying into boutique grocers to lower concentration risk below 45%."*
