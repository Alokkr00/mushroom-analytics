# MycoMetrics Developer Onboarding & Engineering Setup Guide

**Document Version:** 1.0.0  
**Target Audience:** Analytics Engineers, Data Engineers, BI Developers  
**Platform:** Dual-Engine (PostgreSQL 16+ / Embedded DuckDB 1.1+)  
**Classification:** Internal Engineering Onboarding Standard  

---

## 1. System Requirements & Prerequisites

Before setting up MycoMetrics locally, ensure your workstation meets the following prerequisites:

| Component | Minimum Version | Recommended Version | Verification Command |
| :--- | :--- | :--- | :--- |
| **Operating System** | Windows 10 / Ubuntu 22.04 / macOS 13+ | Windows 11 / Ubuntu 24.04 | `uname -a` or `[System.Environment]::OSVersion` |
| **Python** | 3.11.x | 3.12.x | `python --version` |
| **Git** | 2.35.x | 2.44+ | `git --version` |
| **dbt Core** | 1.8.x | 1.12.6+ | `dbt --version` |
| **Power BI Desktop** | 2.128+ (May 2024) | Latest 2024/2026 Release | Optional (for visual report authoring) |
| **IDE** | VS Code / PyCharm | VS Code with dbt Power User | `code .` |

---

## 2. Five-Minute Rapid Quickstart

Follow these step-by-step instructions to clone, configure, and execute the complete analytics platform from scratch.

### Step 1: Clone Repository
```powershell
git clone https://github.com/fungiflow/mycometrics.git
cd "d:\Mushroom Analytics"
```

### Step 2: Initialize Isolated Virtual Environment
```powershell
# Windows PowerShell
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Linux / macOS Bash
python3 -m venv .venv
source .venv/bin/activate
```

### Step 3: Install Pinned Dependencies
```powershell
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

### Step 4: Execute Full Automated Test Suite
```powershell
# Executes 5 Unit Tests (Loader & SHA-256) + 5 Integration Tests (Pipeline & Alerts)
pytest tests/ -v
```

### Step 5: Execute Complete End-to-End Pipeline
```powershell
# Runs Ingest -> dbt Run -> dbt Test -> Multi-Tier Reconcile -> Power BI Export -> Stats EDA
python scripts/run_pipeline.py
```

---

## 3. Master Pipeline Orchestrator CLI Reference

The master CLI is located at [`scripts/run_pipeline.py`](../scripts/run_pipeline.py). It manages the full lifecycle and provides granular execution switches:

```powershell
# 1. Full Production Execution
python scripts/run_pipeline.py

# 2. Targeted Execution: Run only raw ingestion and multi-tier reconciliation
python scripts/run_pipeline.py --stage ingest --stage reconcile

# 3. Targeted Execution: Compile and run dbt transformation models only
python scripts/run_pipeline.py --stage dbt_run

# 4. Targeted Execution: Run 87 dbt automated data tests only
python scripts/run_pipeline.py --stage dbt_test

# 5. Targeted Execution: Re-stage Power BI CSV extracts
python scripts/run_pipeline.py --stage export

# 6. Full Rebuild: Force raw table truncation and dbt --full-refresh
python scripts/run_pipeline.py --full-refresh

# 7. Non-Mutating Dry Run: Validate schema files and paths without executing SQL
python scripts/run_pipeline.py --dry-run

# 8. Machine-Readable CI Output: Output structured JSON summary
python scripts/run_pipeline.py --json
```

---

## 4. dbt Transformation Development Workflow

All dimensional transformations reside in [`dbt_project/`](../dbt_project).

### Project Layout
```
dbt_project/
├── dbt_project.yml          # Core project configuration & schema naming
├── profiles.yml             # DuckDB / PostgreSQL connection profiles
├── models/
│   ├── staging/             # 15 views: stg_*.sql + schema.yml tests
│   ├── intermediate/        # 5 views: int_*.sql + schema.yml tests
│   ├── dimensions/          # 7 models: dim_*.sql + schema.yml tests
│   ├── facts/               # 6 models: fact_*.sql + schema.yml tests
│   └── marts/               # 5 models: mart_*.sql + schema.yml tests
└── tests/                   # Singular business assertion SQL tests
```

### Common Developer Commands
Always specify `--profiles-dir .` when working inside `dbt_project/`:

```powershell
cd dbt_project

# Run specific model and its downstream dependents
dbt run --select stg_harvest_records+ --profiles-dir .

# Run all tests on the sales domain
dbt test --select fact_sales --profiles-dir .

# Compile a model to inspect raw SQL dialect output
dbt compile --select mart_business_overview --profiles-dir .
# View compiled output in target/compiled/mycometrics/models/...

cd ..
```

### Adding a New Model Checklist
1. Create SQL file in appropriate layer (`staging/`, `intermediate/`, `facts/`, `marts/`).
2. Add table/view documentation and column descriptions in the matching `schema.yml`.
3. Add required generic tests: `unique`, `not_null`, `relationships` (foreign keys).
4. Run locally: `dbt run --select <model_name> --profiles-dir .`
5. Test locally: `dbt test --select <model_name> --profiles-dir .`
6. Verify financial reconciliation: `python scripts/run_pipeline.py --stage reconcile`

---

## 5. Power BI Desktop Data Modeling Workflow

To develop or update interactive Power BI dashboards:

### Direct File Import Pattern (Recommended)
1. Launch **Power BI Desktop**.
2. Select **Get Data** -> **Folder** or **CSV Text**.
3. Point to [`powerbi/data/`](../powerbi/data).
4. Load the 18 pre-staged CSV files (7 dimensions, 6 facts, 5 reporting marts).
5. Establish relationships matching the Star Schema defined in [`docs/dimensional_model.md`](dimensional_model.md).
6. Copy standard measures from the production DAX library: [`powerbi/dax_measures.dax`](../powerbi/dax_measures.dax).

### Benefits of Staged CSV Pattern:
- **Zero Lock Contention**: Power BI Desktop will not conflict with background DuckDB write transactions.
- **Git Version Control**: All staged datasets are tracked with explicit schemas in [`tables_manifest.json`](../powerbi/data/tables_manifest.json).
- **Fast Rendering**: Pre-aggregated marts load instantaneously into VertiPaq in-memory storage.

---

## 6. Scientific Analytics & Jupyter Notebook Workflow

To inspect statistical hypothesis tests, ANOVA models, or editorial figures:

```powershell
# Launch Jupyter Notebook server
jupyter notebook notebooks/
```

Available Notebooks:
- [`notebooks/01_cultivation_and_yield_eda.ipynb`](../notebooks/01_cultivation_and_yield_eda.ipynb): Biological efficiency distributions, One-Way ANOVA across varieties, incubation cycle analysis.
- [`notebooks/02_sales_and_customer_eda.ipynb`](../notebooks/02_sales_and_customer_eda.ipynb): Customer segment profitability, volume-discount correlation, Pareto LTV distribution.
- [`notebooks/03_spoilage_and_operations_stats.ipynb`](../notebooks/03_spoilage_and_operations_stats.ipynb): Cold storage shrinkage breakdown, flush yield decay curve, fixed overhead break-even modeling.

To regenerate publication-grade figures programmatically:
```powershell
python scripts/run_statistical_eda.py
# Outputs 6 high-resolution figures to docs/figures/fig1_*.png through fig6_*.png
```

---

## 7. Code Formatting & Quality Standards

- **Python Formatting**: Format code using `black` with 120 character line length:
  ```powershell
  black --line-length 120 ingestion/ orchestration/ scripts/ tests/
  ```
- **Linting**: Enforce clean code via `flake8`:
  ```powershell
  flake8 --max-line-length 120 --exclude .venv,target,dbt_packages
  ```
- **SQL Standards**:
  - Always use lowercase keywords for SQL syntax (`select`, `from`, `where`, `left join`, `group by`).
  - Strict ANSI single quotes for string literals (`'Lion''s Mane'`).
  - Leading commas for multi-line SELECT clauses.
  - Trailing semicolons on standalone script files.
