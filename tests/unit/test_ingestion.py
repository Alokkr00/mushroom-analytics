"""
tests/unit/test_ingestion.py
============================
Unit test suite for the MycoMetrics ingestion engine and raw loader.

Tests:
1. test_row_fingerprint_deterministic: Verifies SHA-256 hash consistency.
2. test_row_fingerprint_different_values: Verifies different rows produce different hashes.
3. test_metadata_columns_appended: Verifies technical metadata envelope.
4. test_full_ingestion_creates_records: Verifies full load into raw tables.
5. test_idempotent_incremental_ingestion: Verifies rerun inserts 0 duplicates.
6. test_audit_run_logged: Verifies audit.pipeline_runs entry.
7. test_audit_issues_logged: Verifies anomaly detection in audit.data_quality_issues.
"""

from __future__ import annotations

import tempfile
from pathlib import Path
import pytest
import pandas as pd
import duckdb

from ingestion.raw_loader import compute_row_fingerprint, RawIngestionEngine


def test_row_fingerprint_deterministic():
    """Verify that identical row values generate the exact same SHA-256 hash."""
    row1 = pd.Series({"batch_id": "BAT-00001", "mushroom_id": "MSH-01", "qty": 45.0})
    row2 = pd.Series({"batch_id": "BAT-00001", "mushroom_id": "MSH-01", "qty": 45.0})
    hash1 = compute_row_fingerprint(row1)
    hash2 = compute_row_fingerprint(row2)
    assert hash1 == hash2
    assert len(hash1) == 64  # SHA-256 hex string


def test_row_fingerprint_different_values():
    """Verify that different row values produce different fingerprints."""
    row1 = pd.Series({"batch_id": "BAT-00001", "qty": 45.0})
    row2 = pd.Series({"batch_id": "BAT-00002", "qty": 45.0})
    assert compute_row_fingerprint(row1) != compute_row_fingerprint(row2)


def test_full_and_incremental_idempotency(tmp_path):
    """
    Test that running full load inserts records, and running incremental
    load immediately afterward on identical data inserts exactly 0 duplicates.
    """
    db_file = str(tmp_path / "test_warehouse.duckdb")

    # 1. Full Load Run
    engine_full = RawIngestionEngine(
        source_dir="data/generated",
        mode="full",
        target="duckdb",
        db_path=db_file,
    )
    result_full = engine_full.run()
    assert result_full["status"] == "SUCCESS"
    assert result_full["rows_extracted"] > 0
    assert result_full["rows_inserted"] == result_full["rows_extracted"]

    # 2. Incremental Run (Idempotency Assertion)
    engine_incr = RawIngestionEngine(
        source_dir="data/generated",
        mode="incremental",
        target="duckdb",
        db_path=db_file,
    )
    result_incr = engine_incr.run()
    assert result_incr["status"] == "SUCCESS"
    assert result_incr["rows_extracted"] == result_full["rows_extracted"]
    assert result_incr["rows_inserted"] == 0  # Zero duplicate records inserted!


def test_audit_pipeline_runs_logged(tmp_path):
    """Verify that audit.pipeline_runs records execution status, duration, and counts."""
    db_file = str(tmp_path / "test_warehouse.duckdb")
    engine = RawIngestionEngine(
        source_dir="data/generated",
        mode="full",
        target="duckdb",
        db_path=db_file,
    )
    res = engine.run()

    con = duckdb.connect(db_file)
    runs = con.execute("SELECT run_id, status, total_files_processed, total_rows_inserted FROM audit.pipeline_runs;").fetchall()
    assert len(runs) >= 1
    run_id, status, files, inserted = runs[0]
    assert status == "SUCCESS"
    assert files == 15
    assert inserted == res["rows_inserted"]
    con.close()


def test_audit_data_quality_issues_logged(tmp_path):
    """Verify that intentional duplicate anomalies are captured in audit.data_quality_issues."""
    db_file = str(tmp_path / "test_warehouse.duckdb")
    engine = RawIngestionEngine(
        source_dir="data/generated",
        mode="full",
        target="duckdb",
        db_path=db_file,
    )
    engine.run()

    con = duckdb.connect(db_file)
    issues = con.execute("SELECT check_type, severity, count(*) FROM audit.data_quality_issues GROUP BY 1, 2;").fetchall()
    assert len(issues) >= 1
    # Check that DUPLICATE_PRIMARY_KEY was detected
    check_types = [iss[0] for iss in issues]
    assert "DUPLICATE_PRIMARY_KEY" in check_types
    con.close()
