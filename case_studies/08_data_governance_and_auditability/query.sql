-- ==============================================================================
-- Case Study 8: Data Governance, Idempotency & Auditability
-- Business Question: How does MycoMetrics prove data trustworthiness and zero duplication?
-- ==============================================================================

-- Section 1: Ingestion Pipeline Audit Log History
select
    run_id,
    target_table,
    ingestion_mode,
    rows_read,
    rows_inserted,
    rows_rejected,
    run_status,
    executed_at
from audit.pipeline_runs
order by executed_at desc
limit 10;

-- Section 2: Data Quality Anomaly Log
select
    issue_id,
    run_id,
    source_table,
    issue_type,
    column_name,
    issue_description,
    detected_at
from audit.data_quality_issues
order by detected_at desc;

-- Section 3: Idempotency Fingerprint Collision Check (Must return 0 records)
select
    _row_fingerprint,
    count(*) as collision_count
from raw.raw_sales_orders
group by _row_fingerprint
having count(*) > 1;
