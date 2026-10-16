-- ============================================================================
-- 03_create_audit_tables.sql
-- Database: mycometrics
-- Schema: audit
-- Purpose: Maintain ELT pipeline execution audit logs, row counts, and data quality issues.
-- ============================================================================

DROP TABLE IF EXISTS audit.pipeline_runs CASCADE;
CREATE TABLE audit.pipeline_runs (
    run_id                       VARCHAR(50) PRIMARY KEY,
    pipeline_name                VARCHAR(100) NOT NULL,
    environment                  VARCHAR(20) NOT NULL DEFAULT 'development',
    start_time                   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time                     TIMESTAMP WITH TIME ZONE,
    duration_seconds             NUMERIC(10,2),
    status                       VARCHAR(20) NOT NULL, -- 'RUNNING', 'SUCCESS', 'FAILED', 'PARTIAL'
    total_files_processed        INTEGER DEFAULT 0,
    total_rows_extracted         INTEGER DEFAULT 0,
    total_rows_inserted          INTEGER DEFAULT 0,
    total_rows_rejected          INTEGER DEFAULT 0,
    watermark_timestamp          TIMESTAMP WITH TIME ZONE,
    error_message                TEXT,
    execution_host               VARCHAR(100)
);

COMMENT ON TABLE audit.pipeline_runs IS 'Tracks master execution telemetry for every ingestion and transformation run.';

DROP TABLE IF EXISTS audit.data_quality_issues CASCADE;
CREATE TABLE audit.data_quality_issues (
    issue_id                     VARCHAR(50) PRIMARY KEY,
    run_id                       VARCHAR(50) NOT NULL REFERENCES audit.pipeline_runs(run_id),
    table_name                   VARCHAR(100) NOT NULL,
    check_type                   VARCHAR(50) NOT NULL, -- 'NULL_VIOLATION', 'DUPLICATE_KEY', 'FK_ORPHAN', 'BUSINESS_RULE'
    severity                     VARCHAR(20) NOT NULL, -- 'CRITICAL', 'ERROR', 'WARNING', 'INFO'
    record_identifier            VARCHAR(100),
    column_name                  VARCHAR(100),
    error_details                TEXT NOT NULL,
    recorded_at                  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE audit.data_quality_issues IS 'Stores granular validation failures for triage without dropping bad records silently.';
