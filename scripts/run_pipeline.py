"""
scripts/run_pipeline.py
=======================
Master CLI entry point for the MycoMetrics Data Pipeline Orchestrator.

Usage Examples:
    # Run full end-to-end pipeline (Ingest -> dbt Run -> dbt Test -> Reconcile -> Export -> Stats)
    python scripts/run_pipeline.py

    # Run only raw ingestion and multi-tier reconciliation
    python scripts/run_pipeline.py --stage ingest --stage reconcile

    # Run full refresh of raw data and dbt models
    python scripts/run_pipeline.py --full-refresh

    # Dry-run validation check
    python scripts/run_pipeline.py --dry-run

    # Output JSON summary for automated CI/CD parsing
    python scripts/run_pipeline.py --json
"""

import argparse
import json
import sys
from pathlib import Path

# Add project root to sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from orchestration.pipeline_runner import PipelineOrchestrator


def parse_args():
    parser = argparse.ArgumentParser(
        description="MycoMetrics Data Pipeline & Reconciliation Orchestrator",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--stage",
        action="append",
        choices=["all", "generate", "ingest", "dbt_run", "dbt_test", "dbt", "reconcile", "export", "stats"],
        help="Pipeline stage(s) to execute. Can be passed multiple times (e.g. --stage ingest --stage reconcile).",
    )
    parser.add_argument(
        "--db-path",
        default="data/warehouse.duckdb",
        help="Path to persistent DuckDB database file.",
    )
    parser.add_argument(
        "--dbt-dir",
        default="dbt_project",
        help="Directory containing dbt project models and configuration.",
    )
    parser.add_argument(
        "--full-refresh",
        action="store_true",
        help="Execute full raw data truncation/reload and dbt --full-refresh.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform dry-run validation without modifying data warehouse.",
    )
    parser.add_argument(
        "--no-alerts",
        action="store_true",
        help="Disable webhook alert notifications.",
    )
    parser.add_argument(
        "--no-fail-fast",
        action="store_true",
        help="Continue running downstream stages even if a stage fails.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print final run summary in JSON format to stdout.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    stages = args.stage or ["all"]

    orchestrator = PipelineOrchestrator(
        db_path=args.db_path,
        dbt_dir=args.dbt_dir,
        full_refresh=args.full_refresh,
        dry_run=args.dry_run,
        fail_fast=not args.no_fail_fast,
        enable_alerts=not args.no_alerts,
    )

    result = orchestrator.execute_pipeline(stages=stages)

    if args.json:
        print("\n=== PIPELINE_JSON_OUTPUT_START ===")
        print(json.dumps(result, indent=2))
        print("=== PIPELINE_JSON_OUTPUT_END ===")

    # Exit code: 0 if SUCCESS, 1 if FAILED
    sys.exit(0 if result["status"] == "SUCCESS" else 1)


if __name__ == "__main__":
    main()
