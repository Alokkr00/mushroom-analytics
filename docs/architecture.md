# System Architecture & Technical Design: MycoMetrics

## 1. Architectural Philosophy for an Early-Stage Agricultural Venture

Small agricultural startups run on thin margins and volatile cash flows. They do not have dedicated data engineering teams, 24/7 SREs, or budgets for recurring cloud data platform bills (Snowflake/BigQuery/Databricks) or streaming clusters (Kafka/Flink).

The **MycoMetrics Architecture** adopts a **Local-First, Cloud-Ready Modern Data Stack (MDS)** pattern:

```
[Operational Sources]
- CSV/Excel Batch Logs
- Google Sheets Order Forms
- Bank Statement / Expense Exports
- Synthetic Expansion Engine
         │
         ▼ (Python 3.12 Ingestion Engine + Schema Validation + Audit Run Log)
┌────────────────────────────────────────────────────────────────────────┐
│                        POSTGRESQL DATA PLATFORM                        │
│                                                                        │
│  ┌───────────────────────┐                                             │
│  │     `raw` Schema      │  Full fidelity immutable source tables      │
│  │  (raw_batches, etc.)  │  with _ingested_at, _source_file, _run_id   │
│  └───────────┬───────────┘                                             │
│              │                                                         │
│              ▼ (dbt Core PostgreSQL Adapter)                           │
│  ┌───────────────────────┐                                             │
│  │   `staging` Layer     │  Type casting, renaming, null handling      │
│  └───────────┬───────────┘                                             │
│              │                                                         │
│              ▼                                                         │
│  ┌───────────────────────┐                                             │
│  │ `intermediate` Layer  │  Yield rollups, balance logic, allocations  │
│  └───────────┬───────────┘                                             │
│              │                                                         │
│              ▼                                                         │
│  ┌───────────────────────┐                                             │
│  │  `analytics` Schema   │  Star Schema Dimensional Models             │
│  │   (Marts / Facts)     │  dim_*, fact_*, aggregated reporting views  │
│  └───────────┬───────────┘                                             │
│              │                                                         │
│  ┌───────────┴───────────┐                                             │
│  │     `audit` Schema    │  Pipeline run logs, row counts, exceptions  │
│  └───────────────────────┘                                             │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
         ┌─────────────────────────┴─────────────────────────┐
         ▼                                                   ▼
[Business Intelligence]                             [Advanced Analytics]
- Power BI Desktop (Direct/Import)                  - Jupyter Notebooks (EDA)
- Star Schema Modeling (Kimball)                    - Statistical Tests (SciPy)
- Centralized DAX Measures                          - Demand Forecasting
- Management Action Dashboards                      - Business Case Studies (1 - 8)
```

---

## 2. Why This Architecture Fits a Startup vs. Enterprise Alternatives

| Dimension | Enterprise Pattern (Avoided for Startup) | MycoMetrics Architecture (Selected) | Rationale for Startup Context |
| :--- | :--- | :--- | :--- |
| **Warehouse Engine** | Snowflake / Databricks / BigQuery | **PostgreSQL (Local / Lightweight)** | Free, open-source, robust ACID transactions, runs locally on Windows 11 with zero monthly cloud cost. |
| **Transformation** | Spark / Complex Data Pipelines | **dbt Core (SQL + Jinja)** | Version-controlled, declarative, self-documenting, automated DAG dependencies, easy testing. |
| **Ingestion** | Fivetran / Airbyte Cloud / Kafka | **Modular Python Scripts (Pandas / SQLAlchemy)** | Total control over edge-case data cleaning, custom schema validation, low memory overhead. |
| **Dashboarding** | Tableau Server / Looker Enterprise | **Power BI Desktop** | Industry standard, powerful DAX engine, free local desktop authoring, native relational modeling. |
| **Orchestration** | Complex Airflow Kubernetes Cluster | **Python CLI / Lightweight Scheduler** | Simple execution, easily reproducible via Windows PowerShell scripts or GitHub Actions CI. |

---

## 3. Storage & Schema Separation

To ensure strict separation of concerns, the database is partitioned into four logical namespaces:

1. **`raw`**:
   - Contains 1:1 mirrors of the source operational files.
   - All columns loaded with defensive types (or text where formatting varies) to prevent ingestion failures.
   - Metadata envelope columns appended to every table:
     - `_source_file VARCHAR(255)`
     - `_ingested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP`
     - `_ingestion_run_id UUID`
     - `_row_fingerprint VARCHAR(64)` (SHA-256 hash of business keys to ensure idempotency)
2. **`staging` (`stg_*`)**:
   - dbt view or ephemeral layer that enforces strict typing, clean column naming conventions (`snake_case`), unit standardization (grams to kg), and basic surrogate key generation.
3. **`intermediate` (`int_*`)**:
   - dbt view or table layer performing business logic reconciliations:
     - Rolling inventory balances using window functions.
     - Aggregating flush harvests to batch-level total yield.
     - Allocating indirect expenses to active batches.
4. **`analytics` (`dim_*`, `fact_*`, `mart_*`)**:
   - Production consumption layer structured as a Kimball Star Schema.
   - Fact tables store granular atomic events (e.g., individual harvest event, line-item sale).
   - Conformed dimensions store attributes (e.g., customer, product, mushroom variety, date).
   - Reporting marts aggregate pre-joined metrics for Power BI and executive queries.
5. **`audit`**:
   - System catalog recording every ingestion job: status (`SUCCESS`, `FAILED`, `PARTIAL`), start/end timestamps, records read, inserted, rejected, and error messages.

---

## 4. Pipeline Execution & Idempotency Rules

1. **Idempotency**: Running an ingestion job multiple times on the same input file will **never** create duplicate rows in `raw` or downstream tables. This is achieved via SHA-256 record hashing and upsert / delete-before-insert strategies within transactional blocks.
2. **Atomic Commits**: Loading a batch is wrapped in a database transaction (`BEGIN ... COMMIT`). If a fatal schema violation occurs midway, changes roll back, and the audit log records the failure.
3. **No Unsafe Watermarks**: In incremental mode, the watermark timestamp is only updated **after** the transaction has committed successfully.
