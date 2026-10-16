"""
==============================================================================
MycoMetrics - Power BI Data Staging & Export Engine
Purpose: Exports conformed dimensions, fact tables, and reporting marts from
         DuckDB warehouse into clean CSV files formatted for Power BI Desktop.
==============================================================================
"""

import os
import sys
import duckdb
import pandas as pd

# Enforce UTF-8 stdout encoding for Windows console
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

DB_PATH = 'data/warehouse.duckdb'
EXPORT_DIR = 'powerbi/data'

TABLES = [
    # Dimensions
    'dim_date',
    'dim_mushroom',
    'dim_product',
    'dim_customer',
    'dim_supplier',
    'dim_expense_category',
    'dim_location',
    # Facts
    'fact_production_batches',
    'fact_harvest',
    'fact_sales',
    'fact_inventory_movements',
    'fact_expenses',
    'fact_procurement',
    # Reporting Marts
    'mart_business_overview',
    'mart_production_performance',
    'mart_sales_profitability',
    'mart_inventory_waste',
    'mart_customer_analysis'
]

def main():
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] Database file {DB_PATH} not found.")
        sys.exit(1)

    os.makedirs(EXPORT_DIR, exist_ok=True)
    con = duckdb.connect(DB_PATH)
    con.execute("SET search_path = 'analytics_analytics'")
    
    print(f"Exporting {len(TABLES)} tables to {EXPORT_DIR}...")
    manifest = []
    
    for tbl in TABLES:
        df = con.execute(f"SELECT * FROM analytics_analytics.{tbl}").df()
        out_csv = os.path.join(EXPORT_DIR, f"{tbl}.csv")
        df.to_csv(out_csv, index=False, encoding='utf-8')
        file_size_kb = os.path.getsize(out_csv) / 1024
        print(f"  [OK] Exported {tbl:30s}: {len(df):4d} rows ({file_size_kb:.1f} KB)")
        manifest.append({
            "table_name": tbl,
            "row_count": len(df),
            "columns": list(df.columns),
            "file_path": out_csv
        })
        
    con.close()
    
    # Save manifest for Power BI documentation
    manifest_path = os.path.join(EXPORT_DIR, 'tables_manifest.json')
    import json
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2)
        
    print(f"\n[OK] Successfully staged {len(TABLES)} tables for Power BI Desktop in: {EXPORT_DIR}")

if __name__ == '__main__':
    main()
