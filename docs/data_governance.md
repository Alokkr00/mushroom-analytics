# MycoMetrics Data Governance, Lineage & Quality Policy

**Document Version:** 1.0.0  
**Target Audience:** Analytics Engineers, Farm Operations Managers, Financial Auditors  
**Classification:** Enterprise Data Governance Standard  

---

## 1. Governance Principles & Data Quality Framework

Data integrity in early-stage agricultural operations directly impacts biological yields, commercial cash flow, and regulatory traceability. The **MycoMetrics Data Governance Framework** rests on four core pillars:

```mermaid
flowchart LR
    classDef pillar fill:#EBF5FB,stroke:#2980B9,stroke-width:2px;

    P1["1. ACCURACY<br/>Exact Mass & Dollar Accounting<br/>$0.00 / 0.000 kg Tolerance"]:::pillar
    P2["2. COMPLETENESS<br/>100% Mandatory Foreign Keys<br/>Zero Orphan Transactions"]:::pillar
    P3["3. CONSISTENCY<br/>Conformed Dimensions<br/>Single Source of Truth"]:::pillar
    P4["4. TIMELINESS<br/>Daily Automated Refresh<br/>Instant Anomaly Alerting"]:::pillar
```

1. **Accuracy**: Every dollar recognized and every gram harvested must reconcile end-to-end between farm weigh-scales, invoices, and executive reporting marts.
2. **Completeness**: No transaction reaches reporting marts without mandatory foreign key linkages to conformed dimensions (`dim_date`, `dim_mushroom`, `dim_product`, `dim_customer`).
3. **Consistency**: KPIs such as Biological Efficiency (BE %), Effective ASP ($/kg), and Gross Margin (%) are defined once in centralized dbt models and DAX libraries to prevent divergent business logic.
4. **Timeliness**: Ingestion and transformation run on a scheduled automated cadence with automated alerts dispatched within 5 seconds of failure.

---

## 2. Cryptographic Audit Envelope Standard

To ensure forensic traceability and complete idempotency, every physical record in the `raw` schema must be enriched with an immutable technical metadata envelope:

$$\text{Envelope} = \{\text{\_source\_file}, \text{\_ingested\_at}, \text{\_ingestion\_run\_id}, \text{\_row\_fingerprint}\}$$

### Technical Field Specifications
- **`_source_file` (`VARCHAR(100)`)**: The exact filename from which the record was extracted (e.g. `harvest_records.csv`).
- **`_ingested_at` (`TIMESTAMPTZ`)**: The UTC timestamp at which the row was written into the physical warehouse table.
- **`_ingestion_run_id` (`VARCHAR(50)`)**: Unique execution batch ID in `RUN-YYYYMMDDHHMMSS-<hex>` format.
- **`_row_fingerprint` (`CHAR(64)`)**: A deterministic SHA-256 hash calculated across all natural non-technical attributes of the record:

$$\text{\_row\_fingerprint} = \text{SHA-256}(v_1 \mid v_2 \mid \dots \mid v_k)$$

### Idempotency Guarantee:
If the ingestion pipeline is executed repeatedly against unchanged source CSVs, existing fingerprints match 100%, and the loader inserts **exactly zero duplicate rows**, eliminating accidental double-counting of yield or sales.

---

## 3. Automated Anomaly Logging & Quarantine Protocol

Rather than silently dropping corrupt data or crashing ungracefully, the ingestion engine isolates anomalies into the [`audit.data_quality_issues`](file:///d:/Mushroom%20Analytics/sql/initialization/03_create_audit_tables.sql) table:

```
[Incoming Operational Row]
          │
          ├──► Passes Validation ────────► Insert into `raw.raw_*` Table
          │
          └──► Fails Rule ────────────────► Log into `audit.data_quality_issues`
                                          ├── Severity: WARNING (Log & Ingest)
                                          ├── Severity: ERROR (Exclude from Marts)
                                          └── Severity: CRITICAL (Halt Pipeline)
```

### Anomaly Classification Taxonomy

| Severity | Check Type | Trigger Condition | System Action | Notification |
| :--- | :--- | :--- | :--- | :--- |
| **WARNING** | `DUPLICATE_PRIMARY_KEY` | Primary key appears multiple times in source file with identical values. | Deduplicate deterministically, record anomaly, continue ingestion. | Logged to audit table. |
| **ERROR** | `NEGATIVE_WEIGHT_VALUE` | Harvest weight or ordered quantity $\le 0.00$. | Exclude from staging views via where filters; retain in raw for audit. | Included in daily run summary. |
| **CRITICAL** | `SCHEMA_DRIFT` | Expected mandatory column missing from incoming spreadsheet. | Halt pipeline immediately (`--fail-fast`). | Dispatches Critical Alert to Slack/Teams. |
| **CRITICAL** | `RECONCILIATION_BREACH`| Multi-tier variance exceeds $\$0.00$ or $0.000\text{ kg}$. | Abort pipeline before refreshing Power BI datasets. | Dispatches Critical Alert to Slack/Teams. |

---

## 4. End-to-End Data Lineage Architecture

The lineage below details how raw operational records flow through transformations into consumed business intelligence:

```mermaid
flowchart LR
    classDef raw fill:#EDBB99,stroke:#D35400,stroke-width:1px;
    classDef stg fill:#D5F5E3,stroke:#27AE60,stroke-width:1px;
    classDef int fill:#A9DFBF,stroke:#1E8449,stroke-width:1px;
    classDef gold fill:#FCF3CF,stroke:#F1C40F,stroke-width:1px;
    classDef mart fill:#FADBD8,stroke:#C0392B,stroke-width:1px;
    classDef bi fill:#E8DAEF,stroke:#8E44AD,stroke-width:1px;

    R_HARV["raw_harvest_records"]:::raw --> STG_HARV["stg_harvest_records"]:::stg
    R_BAT["raw_production_batches"]:::raw --> STG_BAT["stg_production_batches"]:::stg
    STG_HARV --> INT_BATCH_YIELD["int_batch_yield_summary"]:::int
    STG_BAT --> INT_BATCH_YIELD
    INT_BATCH_YIELD --> FACT_BAT["fact_production_batches"]:::gold
    STG_HARV --> FACT_HARV["fact_harvest"]:::gold
    FACT_BAT --> MART_PROD["mart_production_performance"]:::mart
    MART_PROD --> PBI_YIELD["Power BI: Yield & Efficiency Dashboard"]:::bi

    R_ORD["raw_sales_orders"]:::raw --> STG_ORD["stg_sales_orders"]:::stg
    R_LINES["raw_sales_order_lines"]:::raw --> STG_LINES["stg_sales_order_lines"]:::stg
    R_RET["raw_returns"]:::raw --> STG_RET["stg_returns"]:::stg
    STG_ORD --> INT_FIN["int_sales_financials"]:::int
    STG_LINES --> INT_FIN
    STG_RET --> INT_FIN
    INT_FIN --> FACT_SALES["fact_sales"]:::gold
    FACT_SALES --> MART_SALES["mart_sales_profitability"]:::mart
    FACT_SALES --> MART_CUST["mart_customer_analysis"]:::mart
    MART_SALES --> PBI_COMM["Power BI: Commercial Revenue Dashboard"]:::bi

    R_EXP["raw_expenses"]:::raw --> STG_EXP["stg_expenses"]:::stg
    STG_EXP --> FACT_EXP["fact_expenses"]:::gold
    FACT_SALES --> MART_OVERVIEW["mart_business_overview"]:::mart
    FACT_EXP --> MART_OVERVIEW
    MART_OVERVIEW --> PBI_EXEC["Power BI: Executive Overview Dashboard"]:::bi
```

---

## 5. Retention, Archiving & Disaster Recovery SLAs

| Data Asset | Tier | Retention Period | Archival Storage | Backup Cadence |
| :--- | :--- | :--- | :--- | :--- |
| **Operational CSVs** | Source | Permanent (7 Years) | Encrypted Cold Object Storage (S3 / GCS Glacier) | Daily incremental |
| **Raw Warehouse Schema** | Bronze | Permanent (7 Years) | Append-Only DuckDB / PostgreSQL Tables | Daily snapshot |
| **Staging & Intermediate Views** | Silver | Ephemeral | Code-defined in dbt (Version Controlled in Git) | On every git commit |
| **Facts & Conformed Dimensions**| Gold | Operational Lifetime | Materialized DuckDB / PostgreSQL Tables | Daily snapshot |
| **Power BI Staging CSVs** | Gold+ | Rolling 12 Months | Local workspace `powerbi/data/` | Re-staged on every ETL run |
| **Pipeline & Audit Logs** | Audit | 90 Days Hot, 1 Year Cold | `audit.pipeline_runs` & `logs/pipeline_runs/` | Daily incremental |

### Disaster Recovery Service Level Agreements (SLAs):
- **Recovery Point Objective (RPO):** **0 seconds** (Exact Zero Data Loss). All transformations are 100% deterministic and reproducible from raw CSV archives via `python scripts/run_pipeline.py --full-refresh`.
- **Recovery Time Objective (RTO):** **< 3 minutes**. Complete rebuild from raw CSVs to fully materialized marts, passed dbt tests, and staged Power BI files executes in ~76 seconds on standard developer hardware.
