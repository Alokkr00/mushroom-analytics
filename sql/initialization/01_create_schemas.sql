-- ============================================================================
-- 01_create_schemas.sql
-- Database: mycometrics
-- Purpose: Initialize logical schema namespaces for the Modern Data Stack.
-- ============================================================================

-- 1. Raw Schema: Immutable source mirrors with technical metadata envelope
CREATE SCHEMA IF NOT EXISTS raw;
COMMENT ON SCHEMA raw IS 'Full fidelity raw source ingestion tables with ingestion metadata envelope.';

-- 2. Staging Schema: Cleaned, cast, and standardized views (dbt staging layer)
CREATE SCHEMA IF NOT EXISTS staging;
COMMENT ON SCHEMA staging IS 'Type-cast, standardized, and lightly transformed intermediate models.';

-- 3. Analytics Schema: Kimball Star Schema dimensional models and business marts
CREATE SCHEMA IF NOT EXISTS analytics;
COMMENT ON SCHEMA analytics IS 'Production dimensional star schema (dim_*, fact_*, mart_*) for Power BI and BI queries.';

-- 4. Audit Schema: Pipeline execution telemetry, run logs, and data quality metrics
CREATE SCHEMA IF NOT EXISTS audit;
COMMENT ON SCHEMA audit IS 'Operational pipeline audit logs, row counts, incremental watermarks, and run exceptions.';
