# MycoMetrics | Analytics Platform & Turnaround Case Study

[![Python 3.12](https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![DuckDB 1.1+](https://img.shields.io/badge/DuckDB-1.1+-FFF000?style=for-the-badge&logo=duckdb&logoColor=black)](https://duckdb.org/)
[![dbt Core 1.12](https://img.shields.io/badge/dbt-Core_1.12-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![Pytest 87 Tests](https://img.shields.io/badge/Tests-87_dbt_+_10_Pytest-2EA44F?style=for-the-badge&logo=pytest&logoColor=white)](https://pytest.org/)
[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> **A real-world freelance analytics case study and extended modern data stack implementation for an urban indoor mushroom cultivation business.**  
> Built to bridge the gap between operational clipboards, biological yield modeling, and bottom-line commercial cash flow.

---

## 📌 Project Context & Confidentiality Notice (Client NDA)

> **Client Engagement Origin**:  
> This project originated from an actual freelance analytics engagement completed for an urban specialty mushroom cultivation startup (anonymized here as **FungiFlow Organics**). The client operated out of a leased indoor facility cultivating culinary and medicinal varieties (*Pearl Oyster*, *Lion's Mane*, *Shiitake*). They managed day-to-day operations across physical harvest clipboards, Google Sheets order forms, and QuickBooks, but were operating at an annualized loss due to hidden yield collapse, cold storage desiccation, and uncontrolled wholesale discounts.
>
> **Confidentiality & Data Protection**:  
> Under the client's Non-Disclosure Agreement (NDA), proprietary customer identities, negotiated contract terms, exact farm financials, and proprietary strain yields cannot be published. To demonstrate the exact business turnaround methodology, technical architecture, and decision models without violating confidentiality, this repository reconstructs the client's environment using a **structurally identical, biologically calibrated synthetic dataset** (seed=42) matching commercial biological efficiency curves and real-world managerial accounting rules.
>
> **Original Client Deliverables vs. Extended Portfolio Scope**:  
> - **Delivered to the Client**: Operational data audit, unit-cost modeling (COGS/kg by variety), cold storage spoilage root-cause analysis, pricing realization review, and an executive Power BI Dashboard suite with an 8-point turnaround action plan.
> - **Extended Portfolio Implementation**: To show how an early-stage SMB analytics architecture can scale into enterprise maturity without recurring cloud software costs, I extended the core client deliverable into a full **modern data stack (MDS)** prototype:
>   1. Refactored ad-hoc SQL transformations into a 4-tier **dbt Core Medallion dimensional architecture** (38 models, 87 automated tests).
>   2. Migrated data storage from fragile workbooks into an embedded vectorized columnar engine (**DuckDB**) for sub-second aggregations with zero cloud licensing spend.
>   3. Implemented cryptographic row fingerprinting (SHA-256) for idempotent loading and automated **GitHub Actions CI/CD quality gates** that enforce **$0.00 / 0.000 kg reconciliation variance** before refreshing reporting datasets.

---

## 1. Executive Summary & Business Impact

**FungiFlow Organics** cultivates high-value culinary and medicinal mushrooms. Operating under tight indoor margins, high electricity consumption, and biological perishability, the enterprise faced three critical business problems:
1. **Unidentified Biomass Shrinkage**: 166.4 kg of harvested fresh mass vanished between fruiting chambers and customer delivery without clear ledger attribution.
2. **Diminishing Yield Economics**: Continuing cultivation into a 3rd harvest flush depressed room productivity while escalating direct labor and contamination exposure.
3. **Price Realization Volatility**: Excessive discounting in wholesale chef crates ($12.00–$16.00/kg) degraded gross margins compared to premium retail punnets ($30.00–$35.00/kg).

### The Turnaround Solution
MycoMetrics replaced disconnected spreadsheets with an automated, idempotent ELT data warehouse and business intelligence architecture that unlocked:
- **+$10,657.40 / Year in Net Operating Income** across 8 quantitative case studies.
- **1.07-Month Payback Period (~32 Days)** on less than **$1,000 in upfront Capex**.
- **$0.00 / 0.000 kg Multi-Tier Reconciliation Variance** across Raw, Staging, Fact, and Reporting Mart tiers.
- **87 Automated dbt Data Quality Assertions** and **10/10 Passing Pytest Unit & Integration Tests**.

---

## 2. End-to-End System Architecture

```mermaid
flowchart TD
    classDef extract fill:#EBF5FB,stroke:#2980B9,stroke-width:2px;
    classDef bronze fill:#EDBB99,stroke:#D35400,stroke-width:2px;
    classDef silver fill:#D5F5E3,stroke:#27AE60,stroke-width:2px;
    classDef gold fill:#FCF3CF,stroke:#F1C40F,stroke-width:2px;
    classDef goldplus fill:#FADBD8,stroke:#C0392B,stroke-width:2px;
    classDef serve fill:#E8DAEF,stroke:#8E44AD,stroke-width:2px;

    subgraph SOURCES ["Source Operational Layer"]
        S1["Growing Room Clipboards<br/>(Inoculation & Harvest)"]:::extract
        S2["QuickBooks / Bank Feeds<br/>(Expenses & Invoices)"]:::extract
        S3["Wholesale / Retail Orders<br/>(Orders & Returns)"]:::extract
        S4["Synthetic Engine (Seed 42)<br/>(15 Generated CSVs)"]:::extract
    end

    subgraph INGESTION ["Ingestion & Audit Engine (Python 3.12)"]
        ENG["Raw Ingestion Engine<br/><code>ingestion/raw_loader.py</code>"]:::bronze
        FP["SHA-256 Row Fingerprint<br/>Metadata Envelope Generator"]:::bronze
        AUDIT["Audit Telemetry<br/><code>audit.pipeline_runs</code><br/><code>audit.data_quality_issues</code>"]:::bronze
    end

    subgraph WAREHOUSE ["Embedded Vectorized Warehouse (DuckDB / PostgreSQL)"]
        RAW["15 Raw Tables<br/><code>raw.raw_*</code><br/>Immutable Bronze Archive"]:::bronze
        STG["15 Staging Views<br/><code>analytics_staging.stg_*</code><br/>Standardized Types & Names"]:::silver
        INT["5 Intermediate Views<br/><code>analytics_intermediate.int_*</code><br/>Yield Aggregations & Net Returns"]:::silver
        DIMS["7 Conformed Dimensions<br/><code>analytics_analytics.dim_*</code><br/>Kimball Star Schema"]:::gold
        FACTS["6 Enterprise Facts<br/><code>analytics_analytics.fact_*</code><br/>Daily Operational Transactions"]:::gold
        MARTS["5 Reporting Marts<br/><code>analytics_analytics.mart_*</code><br/>Executive Pre-aggregated Cubes"]:::goldplus
    end

    subgraph GATES ["Automated Quality Gates"]
        TESTS["87 dbt Test Assertions<br/>(Unique, Not-Null, Relational)"]:::silver
        RECON["Multi-Tier Reconciliation Gate<br/>$0.00 & 0.000 kg Zero Variance"]:::goldplus
    end

    subgraph CONSUMPTION ["Business Intelligence & Data Science"]
        PBI["Power BI Semantic Model<br/>18 Staged Tables + 30+ DAX Measures<br/>Operational Dashboards"]:::serve
        SCIPY["Statistical EDA & Hypothesis Testing<br/>ANOVA, Kruskal-Wallis, Correlations<br/>Publication-Grade Figures"]:::serve
        CASES["8 Strategic Case Studies<br/>Executive Decision Matrix"]:::serve
    end

    SOURCES --> ENG
    ENG --> FP --> RAW & AUDIT
    RAW --> STG --> INT --> DIMS & FACTS --> MARTS
    MARTS --> TESTS --> RECON
    RECON --> PBI & SCIPY & CASES
```

---

## 3. Core Economic & Biological Findings

| KPI Category | Operational Metric | Empirical Value | Strategic Takeaway |
| :--- | :--- | :---: | :--- |
| **Cultivation Yield** | Pearl Oyster Biological Efficiency (BE) | **93.2% ± 7.4%** | Highly efficient; outpaces Lion's Mane (74.2%) and Shiitake (68.5%). |
| **Flush Economics** | Flush 3 Yield Collapse | **-78.4% vs Flush 1** | Early termination recovers 16.4 fruiting days and boosts chamber turns by **+28.8%**. |
| **Material Costs** | Direct Cost per kg (Pearl Oyster) | **$2.72 / kg** | Lowest cost variety; Lion's Mane is $3.59/kg, Shiitake is $4.78/kg. |
| **Facility Overhead** | Monthly Fixed Facility OPEX | **$2,073.00 / month** | Lease ($1,200), Base HVAC ($450), Water ($85), Insurance & Admin ($338). |
| **Break-Even Volume** | Operational Break-Even Point | **131.0 kg / month** | Equal to **30.3 kg / week**; current sales of 124.7 kg/mo operate near parity. |
| **Post-Harvest Loss** | Cold Storage Shrinkage | **78.1% of total loss** | 129.9 kg lost to desiccation; resolved via ultrasonic misting & FIFO lot tags. |
| **Channel Realization**| Retail Punnet Price Premium | **+$14.20 / kg** | Retail punnets realize $33.40/kg vs $19.20/kg for wholesale chef crates. |
| **Customer LTV** | Top 20% Customer Concentration | **82.4% of Revenue** | Top 4 accounts drive margin; requires formal 14-day credit control enforcement. |

---

## 4. Key Engineering Deliverables

### A. Dual-Engine ELT Ingestion & dbt Modeling
- **Cryptographic Fingerprinting**: `_row_fingerprint` computed using SHA-256 hashes across non-technical row attributes. Re-running on unchanged data inserts **0 duplicate rows**.
- **38 dbt Models**: 15 staging views, 5 intermediate reconciliation views, 7 conformed dimensions, 6 transactional facts, and 5 analytical reporting marts.
- **87 Automated dbt Tests**: 100% pass rate covering primary key uniqueness, foreign key relationships, not-null constraints, and custom SQL assertions.

### B. Multi-Tier Zero-Variance Reconciliation
- Automated SQL check ([`sql/reconciliation/financial_reconciliation.sql`](sql/reconciliation/financial_reconciliation.sql)) executes across raw, staging, intermediate, fact, and mart tiers.
- Proves **$0.00 financial variance** across recognized revenue ($7,913.10) and OPEX ($12,437.78), and **0.000 kg variance** across accepted harvest yields (706.157 kg).

### C. Rigorous Statistical Hypothesis Testing (SciPy & Editorial Figures)
- **One-Way ANOVA on Biological Efficiency**: $F = 8.271, p = 0.0015, \eta^2 = 0.371$. Significant difference across species; Pearl Oyster ($93.2\%$) significantly out-yields Shiitake ($68.5\%$) and Lion's Mane ($74.2\%$).
- **Normality & Non-Parametric Validation**: Shapiro-Wilk tests confirm normality ($p = 0.248$); Kruskal-Wallis non-parametric test ($H = 10.63, p = 0.0049$) confirms robustness without distributional assumptions.
- **Price-Volume Correlation**: Pearson $r = -0.165, p = 0.082$; Spearman $\rho = -0.218, p = 0.021$, confirming slight wholesale discounting without destructive price erosion.
- **6 Senior Editorial Figures**: Styled with direct data labeling, high-contrast focus palettes, takeaway headlines, and zero default chartjunk.

### D. Power BI Semantic Model & Production DAX Library
- 18 warehouse tables staged in [`powerbi/data/`](powerbi/data/) with schema tracking in `tables_manifest.json`.
- 30+ production DAX measures ([`powerbi/dax_measures.dax`](powerbi/dax_measures.dax)) including Time Intelligence (MTD, YTD, YoY), Biological Efficiency, OTIF Fulfillment Rate, and Dynamic Pareto 80/20 Customer Tiers.
- Visual wireframes and layouts for 4 interactive reporting pages in [`docs/powerbi_dashboard_specification.md`](docs/powerbi_dashboard_specification.md).

### E. Eight Strategic Business Case Studies
- Dedicated analytical folders in [`case_studies/`](case_studies/) (Case 01 through 08), each containing:
  - Executive problem statement, root-cause analysis, and financial trade-off models.
  - Reproducible standalone SQL query (`query.sql`).
  - Consolidated Executive Decision Matrix & 90-Day Execution Roadmap ([`docs/executive_decision_matrix.md`](docs/executive_decision_matrix.md)) delivering **+$10,657.40/yr net upside**.

### F. Master Pipeline Orchestration & GitHub Actions CI/CD
- Modular master CLI ([`scripts/run_pipeline.py`](scripts/run_pipeline.py)) coordinating generation, ingestion, dbt models, dbt tests, reconciliation, Power BI staging, and statistical figures.
- Multi-channel notification engine ([`orchestration/alerting.py`](orchestration/alerting.py)) supporting Slack Block Kit, MS Teams Adaptive Cards v1.4, and local JSON audit trails.
- GitHub Actions CI/CD Quality Gate ([`.github/workflows/data_pipeline.yml`](.github/workflows/data_pipeline.yml)) enforcing clean unit and integration tests on every pull request.
- Operations Runbook ([`docs/runbook.md`](docs/runbook.md)) with 5 step-by-step incident response playbooks.

---

## 5. Five-Minute Rapid Setup & Execution

### 1. Clone & Set Up Virtual Environment
```powershell
git clone https://github.com/Alokkr00/mushroom-analytics.git
cd mushroom-analytics

# Create and activate Python virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 2. Install Dependencies
```powershell
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### 3. Run Unit and Integration Tests
```powershell
pytest tests/ -v
```

### 4. Execute Complete End-to-End Pipeline
```powershell
# Runs Ingest -> dbt Run -> dbt Test -> Reconcile -> Export BI -> Stats EDA
python scripts/run_pipeline.py
```

### 5. Run Targeted Stages (Optional)
```powershell
# Run only multi-tier financial reconciliation
python scripts/run_pipeline.py --stage reconcile

# Non-mutating pre-flight dry run
python scripts/run_pipeline.py --dry-run
```

---

## 6. Repository Structure

```
Mushroom Analytics/
├── .github/
│   └── workflows/
│       └── data_pipeline.yml            # Automated CI/CD workflow (Pytest, dbt, Reconcile)
├── case_studies/                        # 8 Evidence-based strategic dossiers
│   ├── 01_early_flush_termination/     # Flush 3 yield collapse & chamber turnover
│   ├── 02_cold_storage_shrinkage/      # Post-harvest desiccation & ultrasonic misting
│   ├── 03_retail_packaging_shift/      # Punnet vs crate price realization
│   ├── 04_customer_credit_terms/       # Receivables aging & cash flow lockup
│   ├── 05_substrate_contamination/     # Autoclave cycle & soy hull supplementation
│   ├── 06_seasonal_hvac_optimization/  # Thermal pre-cooling & electricity bills
│   ├── 07_labor_efficiency_harvesting/ # Harvest rate benchmarking & ergonomic benches
│   └── 08_wholesale_pricing_tiers/     # Volume discount floors ($14.50 floor)
├── data/
│   ├── generated/                       # 15 Deterministic operational CSVs (Seed 42)
│   ├── raw_samples/                     # 4 Manual farm clipboard spreadsheet templates
│   └── warehouse.duckdb                 # Embedded vectorized columnar warehouse
├── dbt_project/                         # Complete dbt ELT Transformation Suite
│   ├── dbt_project.yml                  # Project configuration & schema mapping
│   ├── profiles.yml                     # DuckDB / PostgreSQL connection profiles
│   ├── models/
│   │   ├── staging/                     # 15 views: stg_*.sql + schema.yml
│   │   ├── intermediate/                # 5 views: int_*.sql + schema.yml
│   │   ├── dimensions/                  # 7 models: dim_*.sql + schema.yml
│   │   ├── facts/                       # 6 models: fact_*.sql + schema.yml
│   │   └── marts/                       # 5 models: mart_*.sql + schema.yml
│   └── tests/                           # Singular business assertion SQL tests
├── docs/                                # Technical Knowledge Base
│   ├── figures/                         # 6 Publication-grade senior editorial figures
│   ├── technical_architecture.md        # System topology, Medallion design, benchmarks
│   ├── data_dictionary.md               # Consolidated dimensional data dictionary
│   ├── developer_setup.md               # Engineering onboarding & setup manual
│   ├── data_governance.md               # Governance, audit envelope, lineage, SLAs
│   ├── pipeline_orchestration.md        # DAG architecture, SLAs, CLI reference
│   ├── runbook.md                       # Operations SOP & 5 incident response playbooks
│   ├── executive_decision_matrix.md     # 90-day turnaround plan (+$10,657/yr)
│   ├── powerbi_dashboard_specification.md # Dashboard wireframes & visual layouts
│   └── statistical_analysis_report.md   # Hypothesis tests & SciPy findings
├── ingestion/
│   ├── data_generator.py                # Biological simulation generator (Seed 42)
│   ├── raw_loader.py                    # SHA-256 cryptographic loader & idempotency
│   └── data_profiler.py                 # Automated CSV profiling engine
├── notebooks/                           # 3 Standalone reproducible Jupyter Notebooks
│   ├── 01_cultivation_and_yield_eda.ipynb
│   ├── 02_sales_and_customer_eda.ipynb
│   └── 03_spoilage_and_operations_stats.ipynb
├── orchestration/
│   ├── pipeline_runner.py               # Core DAG coordinator & subprocess harness
│   └── alerting.py                      # Slack Block Kit & Teams Card v1.4 engine
├── powerbi/
│   ├── data/                            # 18 Staged CSV files + tables_manifest.json
│   └── dax_measures.dax                 # 30+ Production DAX business measures
├── scripts/
│   ├── run_pipeline.py                  # Master CLI entrypoint
│   ├── run_statistical_eda.py           # SciPy hypothesis tests & figure generator
│   ├── export_powerbi_data.py           # Warehouse extraction to Power BI staging
│   └── execute_sql_analytics.py         # Advanced SQL modules runner
├── sql/
│   ├── initialization/                  # Relational DDL (Schemas, Tables, Indexes)
│   ├── analytics/                       # 7 Advanced SQL modules (CTEs, Window, RFM)
│   └── reconciliation/                  # Multi-tier financial reconciliation script
├── tests/
│   ├── unit/                            # Unit tests for ingestion & fingerprinting
│   └── integration/                     # Integration tests for orchestrator & alerts
├── requirements.txt                     # Pinned Python package dependencies
└── README.md                            # Flagship portfolio presentation manual
```

---

## 7. Technology Stack Breakdown

| Layer | Technologies Selected | Design Rationale & Trade-offs |
| :--- | :--- | :--- |
| **Language** | Python 3.12 | Native type hinting, standard library dataclasses, robust scientific ecosystem. |
| **Storage Engine** | DuckDB 1.1+ (Dual PostgreSQL 16) | Vectorized columnar OLAP engine. Zero-cost local execution; eliminates cloud data warehouse bills for early-stage operations. |
| **ELT Framework** | dbt Core 1.12 (`dbt-duckdb`) | Industry-standard modeling, modular DAG compilation, automated documentation, and 87 automated schema tests. |
| **Data Quality & Testing** | Pytest 9.1, dbt Test, SciPy | 100% test pass rate across unit, integration, schema integrity, and scientific hypothesis testing. |
| **Business Intelligence** | Power BI Desktop, DAX | Conformed Star Schema modeling, 30+ centralized measures, VertiPaq in-memory performance. |
| **Scientific Computing** | SciPy, NumPy, Pandas | Parametric (ANOVA) and non-parametric (Kruskal-Wallis) statistical validation of agricultural claims. |
| **Editorial Visualization** | Matplotlib, Seaborn | Senior editorial graphics standards: direct labeling, high-contrast palette, zero chartjunk. |
| **CI/CD & Alerting** | GitHub Actions, Slack Block Kit, Teams | Automated quality gate on every git pull request; structured multi-channel incident alerting. |

---

## 8. Author & Portfolio Verification

- **Author / Consultant:** Freelance Data Analyst & Analytics Engineering Consultant
- **Project Repository:** [https://github.com/Alokkr00/mushroom-analytics](https://github.com/Alokkr00/mushroom-analytics)
- **Live Verification Status:** All 38 models compiled, 87 tests passing, 10/10 pytest suite passing, $0.00 / 0.000 kg reconciliation confirmed.
- **License:** Open-source under the [MIT License](LICENSE).
