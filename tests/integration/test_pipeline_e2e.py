"""
tests/integration/test_pipeline_e2e.py
======================================
Integration and End-to-End test suite for MycoMetrics Pipeline Orchestration.

Tests:
1. test_pipeline_dry_run: Verifies dry-run inspection mode leaves database unaffected.
2. test_pipeline_reconciliation_zero_variance: Asserts multi-tier reconciliation returns zero variance.
3. test_pipeline_export_bi_stage: Asserts staging of all 18 Power BI tables and manifest.
4. test_alert_manager_payload_schemas: Asserts valid Slack Block Kit and Teams Adaptive Card payloads.
5. test_pipeline_cli_invocation_json: Verifies CLI execution with --json flag and exit code 0.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
import pytest
import duckdb

from orchestration.pipeline_runner import PipelineOrchestrator
from orchestration.alerting import PipelineAlertManager


def test_pipeline_dry_run():
    """Verify that dry-run mode succeeds and flags stages as dry-run."""
    orchestrator = PipelineOrchestrator(
        dry_run=True,
        enable_alerts=False,
    )
    result = orchestrator.execute_pipeline(stages=["ingest", "reconcile"])
    assert result["status"] == "SUCCESS"
    assert result["stages"]["ingest"]["dry_run"] is True
    assert result["stages"]["reconcile"]["dry_run"] is True


def test_pipeline_reconciliation_zero_variance():
    """
    Assert that the automated reconciliation stage verifies 0.00 / 0.000 variance
    across Revenue, Harvest Biomass, and Operating Expenses.
    """
    orchestrator = PipelineOrchestrator(
        db_path="data/warehouse.duckdb",
        enable_alerts=False,
    )
    result = orchestrator.execute_pipeline(stages=["reconcile"])
    assert result["status"] == "SUCCESS"

    checks = result["stages"]["reconcile"]["checks"]
    assert "REVENUE_PIPELINE_RECONCILIATION" in checks
    assert "HARVEST_MASS_BALANCE_RECONCILIATION" in checks
    assert "OPEX_FINANCIAL_RECONCILIATION" in checks

    rev_check = checks["REVENUE_PIPELINE_RECONCILIATION"]
    assert "PASS" in rev_check["audit_status"]
    assert rev_check["metrics"]["fact_to_mart_variance"] == 0.0

    harvest_check = checks["HARVEST_MASS_BALANCE_RECONCILIATION"]
    assert "PASS" in harvest_check["audit_status"]
    assert harvest_check["metrics"]["fact_to_mart_variance_kg"] == 0.0

    opex_check = checks["OPEX_FINANCIAL_RECONCILIATION"]
    assert "PASS" in opex_check["audit_status"]
    assert opex_check["metrics"]["fact_to_mart_variance"] == 0.0


def test_pipeline_export_bi_stage(tmp_path):
    """Verify that export stage populates all 18 tables and manifest."""
    orchestrator = PipelineOrchestrator(
        db_path="data/warehouse.duckdb",
        enable_alerts=False,
    )
    result = orchestrator.execute_pipeline(stages=["export"])
    assert result["status"] == "SUCCESS"
    assert result["stages"]["export"]["tables_exported"] == 18

    export_dir = Path("powerbi/data")
    assert export_dir.exists()
    csv_files = list(export_dir.glob("*.csv"))
    assert len(csv_files) >= 18

    manifest_file = export_dir / "tables_manifest.json"
    assert manifest_file.exists()
    with open(manifest_file, "r", encoding="utf-8") as f:
        manifest_data = json.load(f)
    assert len(manifest_data) == 18


def test_alert_manager_payload_schemas(tmp_path):
    """Verify alert manager payload formatting and local audit persistence."""
    alert_mgr = PipelineAlertManager(alert_dir=tmp_path / "alerts")

    # 1. Slack Payload Validation
    slack = alert_mgr.build_slack_payload(
        title="Test Alert",
        status="SUCCESS",
        run_id="RUN-TEST-001",
        stage="RECONCILE",
        duration_seconds=1.23,
        metrics={"variance": 0.0},
    )
    assert "attachments" in slack
    assert len(slack["attachments"]) == 1
    blocks = slack["attachments"][0]["blocks"]
    assert blocks[0]["type"] == "header"
    assert "[PASS]" in blocks[0]["text"]["text"]

    # 2. Teams Payload Validation
    teams = alert_mgr.build_teams_payload(
        title="Test Alert",
        status="CRITICAL",
        run_id="RUN-TEST-002",
        stage="DBT_TEST",
        duration_seconds=5.45,
        error_message="Test failure assertion",
    )
    assert teams["type"] == "message"
    card = teams["attachments"][0]["content"]
    assert card["type"] == "AdaptiveCard"
    assert card["version"] == "1.4"
    fact_set = [b for b in card["body"] if b["type"] == "FactSet"][0]
    facts = {f["title"]: f["value"] for f in fact_set["facts"]}
    assert facts["Pipeline Stage"] == "DBT_TEST"
    assert facts["Execution Status"] == "CRITICAL"

    # 3. Dispatch Persistence Check
    dispatch_res = alert_mgr.dispatch(
        title="Dispatched Test",
        status="SUCCESS",
        run_id="RUN-TEST-003",
        stage="INGEST",
        duration_seconds=2.0,
    )
    saved_file = Path(dispatch_res["persisted_path"])
    assert saved_file.exists()
    with open(saved_file, "r", encoding="utf-8") as f:
        saved_data = json.load(f)
    assert saved_data["metadata"]["run_id"] == "RUN-TEST-003"
    assert "slack" in saved_data
    assert "teams" in saved_data


def test_pipeline_cli_invocation_json():
    """Verify that CLI invocation with --json outputs valid JSON and exits with code 0."""
    res = subprocess.run(
        [sys.executable, "scripts/run_pipeline.py", "--stage", "reconcile", "--no-alerts", "--json"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    assert res.returncode == 0
    stdout = res.stdout
    assert "=== PIPELINE_JSON_OUTPUT_START ===" in stdout
    assert "=== PIPELINE_JSON_OUTPUT_END ===" in stdout

    json_str = stdout.split("=== PIPELINE_JSON_OUTPUT_START ===")[1].split("=== PIPELINE_JSON_OUTPUT_END ===")[0].strip()
    data = json.loads(json_str)
    assert data["status"] == "SUCCESS"
    assert "reconcile" in data["stages"]
    assert data["stages"]["reconcile"]["status"] == "SUCCESS"
