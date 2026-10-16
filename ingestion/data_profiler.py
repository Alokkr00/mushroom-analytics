"""
mycometrics/ingestion/data_profiler.py
======================================
Automated data profiling and validation utility for raw and generated datasets.

Checks performed:
1. Schema & Column presence.
2. Row counts & Null / Completeness profiling.
3. Primary key & Duplicate checks.
4. Referential integrity across foreign keys.
5. Numerical distributions & Outlier bounds.
6. Business logic sanity assertions (yields, order lines, inventory balance).
7. Exports formal Markdown validation report to `docs/data_profiling_report.md`.

USAGE:
    python ingestion/data_profiler.py --data-dir data/generated --report docs/data_profiling_report.md
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

# Ensure UTF-8 output on Windows consoles
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

import numpy as np
import pandas as pd
from rich.console import Console
from rich.table import Table

console = Console(highlight=False, emoji=False)


class MycoDataProfiler:
    def __init__(self, data_dir: str | Path, report_path: str | Path):
        self.data_dir = Path(data_dir)
        self.report_path = Path(report_path)
        self.tables: dict[str, pd.DataFrame] = {}
        self.issues: list[dict] = []
        self.table_stats: list[dict] = []

    def load_data(self) -> None:
        console.print(f"[bold cyan]Loading CSV datasets from {self.data_dir}...[/bold cyan]")
        for csv_file in sorted(self.data_dir.glob("*.csv")):
            name = csv_file.stem
            df = pd.read_csv(csv_file)
            self.tables[name] = df
            null_count = int(df.isnull().sum().sum())
            self.table_stats.append({
                "table": name,
                "rows": len(df),
                "columns": len(df.columns),
                "null_cells": null_count,
            })
        console.print(f"Loaded {len(self.tables)} datasets.")

    def run_checks(self) -> None:
        console.print("[bold cyan]Running structural & relational integrity checks...[/bold cyan]")
        self._check_primary_keys()
        self._check_foreign_keys()
        self._check_business_rules()

    def _check_primary_keys(self) -> None:
        pk_map = {
            "mushroom_varieties": "mushroom_id",
            "locations": "location_id",
            "expense_categories": "category_id",
            "products": "product_id",
            "suppliers": "supplier_id",
            "customers": "customer_id",
            "production_batches": "batch_id",
            "harvest_records": "harvest_id",
            "sales_orders": "order_id",
            "sales_order_lines": "order_line_id",
            "expenses": "expense_id",
            "purchases": "purchase_id",
            "waste_events": "waste_id",
            "returns": "return_id",
        }
        for table_name, pk_col in pk_map.items():
            if table_name not in self.tables:
                continue
            df = self.tables[table_name]
            if pk_col not in df.columns:
                self.issues.append({
                    "severity": "CRITICAL",
                    "table": table_name,
                    "check": "PK Column Missing",
                    "details": f"Column '{pk_col}' not found in {table_name}",
                })
                continue
            # Check for duplicates (excluding DQ anomalies intentionally injected)
            clean_df = df[df["source_type"] != "synthetic_demo_DQ_TEST"] if "source_type" in df.columns else df
            dupes = clean_df[clean_df.duplicated(subset=[pk_col], keep=False)]
            if len(dupes) > 0:
                self.issues.append({
                    "severity": "ERROR",
                    "table": table_name,
                    "check": "Duplicate Primary Key",
                    "details": f"Found {len(dupes)} rows with duplicated {pk_col}",
                })

            # Check DQ-tagged anomalies if present
            dq_df = df[df["source_type"] == "synthetic_demo_DQ_TEST"] if "source_type" in df.columns else pd.DataFrame()
            if len(dq_df) > 0 and table_name == "purchases":
                self.issues.append({
                    "severity": "INFO",
                    "table": table_name,
                    "check": "Controlled DQ Test Detected",
                    "details": f"Detected {len(dq_df)} intentional duplicate/anomalous rows tagged for Case Study 8",
                })

    def _check_foreign_keys(self) -> None:
        fk_rules = [
            ("harvest_records", "batch_id", "production_batches", "batch_id"),
            ("sales_order_lines", "order_id", "sales_orders", "order_id"),
            ("sales_order_lines", "product_id", "products", "product_id"),
            ("sales_orders", "customer_id", "customers", "customer_id"),
            ("returns", "original_order_line_id", "sales_order_lines", "order_line_id"),
            ("inventory_movements", "product_id", "products", "product_id"),
            ("purchases", "supplier_id", "suppliers", "supplier_id"),
        ]
        for child_tbl, child_col, parent_tbl, parent_col in fk_rules:
            if child_tbl not in self.tables or parent_tbl not in self.tables:
                continue
            c_df = self.tables[child_tbl]
            p_df = self.tables[parent_tbl]
            if child_col not in c_df.columns or parent_col not in p_df.columns:
                continue

            # Exclude deliberate DQ anomalies
            if "source_type" in c_df.columns:
                valid_c_df = c_df[c_df["source_type"] != "synthetic_demo_DQ_TEST"]
            else:
                valid_c_df = c_df

            parent_keys = set(p_df[parent_col].dropna().unique())
            child_keys = valid_c_df[child_col].dropna()
            orphans = valid_c_df[~child_keys.isin(parent_keys)]
            if len(orphans) > 0:
                self.issues.append({
                    "severity": "ERROR",
                    "table": child_tbl,
                    "check": "Orphaned Foreign Key",
                    "details": f"{len(orphans)} rows reference non-existent {parent_tbl}.{parent_col}",
                })

    def _check_business_rules(self) -> None:
        # 1. Harvest weight reconciliation
        if "harvest_records" in self.tables:
            hrv = self.tables["harvest_records"]
            clean_hrv = hrv[hrv["source_type"] != "synthetic_demo_DQ_TEST"] if "source_type" in hrv.columns else hrv
            mismatches = clean_hrv[
                np.abs(clean_hrv["gross_harvested_kg"] - (clean_hrv["accepted_weight_kg"] + clean_hrv["rejected_weight_kg"])) > 0.005
            ]
            if len(mismatches) > 0:
                self.issues.append({
                    "severity": "ERROR",
                    "table": "harvest_records",
                    "check": "Harvest Weight Reconciliation",
                    "details": f"{len(mismatches)} rows fail: gross = accepted + rejected",
                })

        # 2. Fulfilled quantity <= Ordered quantity
        if "sales_order_lines" in self.tables:
            sol = self.tables["sales_order_lines"]
            clean_sol = sol[sol["source_type"] != "synthetic_demo_DQ_TEST"] if "source_type" in sol.columns else sol
            overfills = clean_sol[clean_sol["quantity_fulfilled_kg"] > (clean_sol["quantity_ordered_kg"] + 0.001)]
            if len(overfills) > 0:
                self.issues.append({
                    "severity": "ERROR",
                    "table": "sales_order_lines",
                    "check": "Over-fulfillment Anomaly",
                    "details": f"{len(overfills)} rows have fulfilled > ordered quantity",
                })

        # 3. Inventory signed movement direction
        if "inventory_movements" in self.tables:
            inv = self.tables["inventory_movements"]
            bad_in = inv[(inv["movement_type"] == "HARVEST_IN") & (inv["signed_quantity_kg"] <= 0)]
            bad_out = inv[(inv["movement_type"].isin(["SALE_OUT", "WASTE_OUT"])) & (inv["signed_quantity_kg"] >= 0)]
            if len(bad_in) > 0 or len(bad_out) > 0:
                self.issues.append({
                    "severity": "ERROR",
                    "table": "inventory_movements",
                    "check": "Movement Sign Convention",
                    "details": f"Found {len(bad_in)} non-positive IN or {len(bad_out)} non-negative OUT movements",
                })

    def generate_report(self) -> None:
        self.report_path.parent.mkdir(parents=True, exist_ok=True)
        report_lines = [
            "# Data Profiling & Quality Validation Report: MycoMetrics",
            "",
            "## 1. Executive Summary",
            "",
            f"- **Source Data Directory**: `{self.data_dir}`",
            f"- **Total Datasets Inspected**: {len(self.tables)}",
            f"- **Total Issues / Warnings**: {len(self.issues)}",
            "",
            "## 2. Dataset Volume & Completeness Profile",
            "",
            "| Dataset Name | Rows | Columns | Null Cells | Primary Business Key |",
            "| :--- | :---: | :---: | :---: | :--- |",
        ]

        pk_map = {
            "mushroom_varieties": "mushroom_id",
            "locations": "location_id",
            "expense_categories": "category_id",
            "products": "product_id",
            "suppliers": "supplier_id",
            "customers": "customer_id",
            "production_batches": "batch_id",
            "harvest_records": "harvest_id",
            "sales_orders": "order_id",
            "sales_order_lines": "order_line_id",
            "expenses": "expense_id",
            "purchases": "purchase_id",
            "waste_events": "waste_id",
            "returns": "return_id",
            "inventory_movements": "movement_id",
        }

        for s in self.table_stats:
            tbl = s["table"]
            pk = pk_map.get(tbl, "N/A")
            report_lines.append(f"| `{tbl}.csv` | {s['rows']} | {s['columns']} | {s['null_cells']} | `{pk}` |")

        report_lines.extend([
            "",
            "## 3. Structural & Relational Integrity Findings",
            "",
        ])

        if not self.issues:
            report_lines.append("> [!NOTE]\n> All structural and relational validation checks passed with zero errors.")
        else:
            report_lines.append("| Severity | Table | Check | Details |")
            report_lines.append("| :--- | :--- | :--- | :--- |")
            for iss in self.issues:
                sev_badge = f"**{iss['severity']}**"
                report_lines.append(f"| {sev_badge} | `{iss['table']}` | {iss['check']} | {iss['details']} |")

        report_lines.extend([
            "",
            "## 4. Key Metric Distributions (Preliminary Bounds)",
            "",
        ])

        # Add metric stats for production batches
        if "production_batches" in self.tables:
            batches = self.tables["production_batches"]
            clean_batches = batches[batches["source_type"] != "synthetic_demo_DQ_TEST"]
            dry_sub = clean_batches["dry_substrate_kg"].describe()
            report_lines.extend([
                "### Production Batches (`production_batches.csv`)",
                f"- **Total Batches**: {len(clean_batches)}",
                f"- **Substrate Dry Weight (kg)**: Mean = {dry_sub['mean']:.2f} kg, Min = {dry_sub['min']:.2f} kg, Max = {dry_sub['max']:.2f} kg",
                f"- **Contaminated Batches**: {(clean_batches['batch_status'] == 'CONTAMINATED').sum()}",
                "",
            ])

        # Add metric stats for harvest records
        if "harvest_records" in self.tables:
            hrv = self.tables["harvest_records"]
            clean_hrv = hrv[hrv["source_type"] != "synthetic_demo_DQ_TEST"]
            tot_gross = clean_hrv["gross_harvested_kg"].sum()
            tot_accepted = clean_hrv["accepted_weight_kg"].sum()
            tot_rejected = clean_hrv["rejected_weight_kg"].sum()
            rej_pct = (tot_rejected / tot_gross * 100) if tot_gross > 0 else 0.0
            report_lines.extend([
                "### Harvest Performance (`harvest_records.csv`)",
                f"- **Total Gross Harvested Weight**: {tot_gross:.2f} kg",
                f"- **Total Accepted Weight**: {tot_accepted:.2f} kg ({tot_accepted/tot_gross*100:.1f}%)",
                f"- **Total Rejected Weight**: {tot_rejected:.2f} kg ({rej_pct:.1f}%)",
                "",
            ])

        # Add sales stats
        if "sales_order_lines" in self.tables:
            lines = self.tables["sales_order_lines"]
            clean_lines = lines[lines["source_type"] != "synthetic_demo_DQ_TEST"]
            tot_net = clean_lines["net_revenue"].sum()
            tot_kg = clean_lines["quantity_fulfilled_kg"].sum()
            avg_price_per_kg = tot_net / tot_kg if tot_kg > 0 else 0.0
            report_lines.extend([
                "### Commercial Sales Performance (`sales_order_lines.csv`)",
                f"- **Total Net Revenue**: ${tot_net:,.2f}",
                f"- **Total Kilograms Fulfilled**: {tot_kg:,.2f} kg",
                f"- **Average Selling Price**: ${avg_price_per_kg:.2f} / kg",
                "",
            ])

        with open(self.report_path, "w", encoding="utf-8") as f:
            f.write("\n".join(report_lines))

        console.print(f"[bold green][OK] Profiling report generated -> {self.report_path}[/bold green]")


def main():
    parser = argparse.ArgumentParser(description="Profile MycoMetrics datasets.")
    parser.add_argument("--data-dir", default="data/generated", help="Directory of CSV files")
    parser.add_argument("--report", default="docs/data_profiling_report.md", help="Output Markdown report path")
    args = parser.parse_args()

    profiler = MycoDataProfiler(data_dir=args.data_dir, report_path=args.report)
    profiler.load_data()
    profiler.run_checks()
    profiler.generate_report()


if __name__ == "__main__":
    main()
