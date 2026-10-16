# Case Studies Portfolio Architecture: MycoMetrics

This document defines the analytical blueprint for the eight end-to-end business case studies. Each case study represents an investigation addressing an operational or commercial challenge faced by the mushroom enterprise.

---

## Portfolio Summary Matrix

| # | Case Study Title | Core Business Problem | Primary Tables Required | Key Analytical Techniques | Target Decision Supported |
| :- | :--- | :--- | :--- | :--- | :--- |
| **1** | **Production Yield & Batch Performance** | High variance in biological efficiency across batches and substrate mixes. | `fact_production_batches`, `fact_harvest`, `dim_mushroom` | Window ranking (`DENSE_RANK`), grouped aggregations, BE % calculation, cycle duration analysis. | Optimize substrate formulation and eliminate underperforming batches. |
| **2** | **Spoilage, Expiry & Waste Reduction** | Highly perishable produce spoiling in cold storage before dispatch. | `fact_inventory_movements`, `fact_inventory_daily_snapshot`, `fact_sales` | Cumulative running totals, inventory aging buckets, days-to-expiry risk modeling, financial waste valuation. | Calibrate harvest-to-pack timing and discount aging lots prior to spoilage. |
| **3** | **Sales Performance & Demand Dynamics** | Unclear SKU profitability, channel mix, and missed sales due to stockouts. | `fact_sales`, `dim_customer`, `dim_product`, `dim_mushroom` | Order fulfillment rates, Average Selling Price (ASP) yield per kg, channel contribution, unfulfilled demand analysis. | Prioritize high-margin restaurant and grocer channels over low-margin bulk drops. |
| **4** | **Cost per Kilogram & Financial Viability** | Inability to tell whether revenue covers true operating overhead and cultivation costs. | `fact_production_batches`, `fact_harvest`, `fact_expenses`, `fact_sales` | Cost classification (Direct vs Overhead), activity-based cost allocation, gross margin %, breakeven volume analysis. | Re-price low-margin SKUs and establish minimum batch sizes. |
| **5** | **Production Planning & Demand Forecasting** | Risk of planting too many or too few blocks due to lack of forward visibility. | `fact_sales`, `dim_date`, `fact_inventory_daily_snapshot`, `dim_mushroom` | Chronological train/test split, moving average & baseline forecasting, WAPE/MAE evaluation, biological lead-time scheduling. | Establish weekly inoculation schedule matched to forecasted demand. |
| **6** | **Customer Retention & Sales Concentration** | Over-reliance on 2-3 key restaurant clients and customer churn. | `fact_sales`, `dim_customer`, `dim_date` | Pareto analysis (80/20 rule), customer concentration ratio, RFM metrics (Recency, Frequency, Monetary), inter-order latency. | Diversify customer portfolio and launch automated re-order reminders. |
| **7** | **Procurement & Working Capital** | Cash tied up in excessive grain spawn or substrate bags subject to supply delays. | `fact_procurement`, `dim_supplier`, `fact_production_batches`, `fact_expenses` | Supplier lead-time variance, material price volatility, order-to-receipt fill rates, working capital tied in stock. | Negotiate supplier contracts and set optimal re-order points (ROP). |
| **8** | **Data Quality, Idempotency & Automated Auditing** | Manual spreadsheets plagued with missing fields, duplicate entries, and broken links. | `raw.*`, `audit.pipeline_runs`, `dbt_project.tests`, `staging.*` | Controlled bad-data injection, dbt test assertions, schema validation in Python, idempotency rerun verification, audit logging. | Guarantee trustworthy executive dashboards with zero duplicate data. |

---

## Detailed Investigation Framework for Each Case Study

Each dedicated case study directory (`case_studies/case_study_0X_.../`) contains:
1. `README.md`: Formal business case report written for executive leadership.
   - Background, problem statement, stakeholders, and hypothesis.
   - SQL queries and step-by-step logic.
   - Empirical findings calculated directly from the data.
   - Actionable recommendations with defensible financial impact models.
   - Disclosed limitations, follow-up measurement plans, and data analyst interview scripts.
2. `query.sql`: Clean, well-commented, production-grade SQL script answering the business questions.
3. `results.csv` / `visuals/`: Documented analytical outputs and charts.
