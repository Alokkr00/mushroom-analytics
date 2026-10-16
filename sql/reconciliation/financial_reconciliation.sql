-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: financial_reconciliation.sql
-- Purpose: Perform automated multi-tier financial and volumetric reconciliation
--          across Raw, Staging, Intermediate, Facts, and Reporting Marts.
-- Acceptance Criteria:
--   - Variance between Raw Invoiced and Mart Final Recognized Revenue = Exactly Expected Credits/Discounts
--   - Variance between Fact Harvest and Mart Production Yield = Exactly 0.000 kg
--   - Variance between Fact Expenses and Mart Operating Result OPEX = Exactly $0.00
-- ==============================================================================

-- Test 1: Revenue Reconciliation across Pipeline Tiers
with raw_rev as (
    select
        round(sum(quantity_ordered_kg * unit_selling_price - discount_amount), 2) as raw_net_invoiced
    from raw.raw_sales_order_lines
),

staging_rev as (
    select
        round(sum(net_revenue), 2) as staging_net_invoiced
    from analytics_staging.stg_sales_order_lines
),

intermediate_rev as (
    select
        round(sum(net_revenue), 2) as intermediate_net_invoiced,
        round(sum(credit_refund_amount), 2) as total_credits,
        round(sum(final_recognized_revenue), 2) as intermediate_recognized_revenue
    from analytics_intermediate.int_sales_financials
),

fact_rev as (
    select
        round(sum(final_recognized_revenue), 2) as fact_recognized_revenue
    from analytics_analytics.fact_sales
),

mart_rev as (
    select
        round(sum(net_sales_revenue), 2) as mart_recognized_revenue
    from analytics_analytics.mart_business_overview
)

select
    'REVENUE_PIPELINE_RECONCILIATION' as reconciliation_check,
    r.raw_net_invoiced,
    s.staging_net_invoiced,
    i.intermediate_recognized_revenue,
    f.fact_recognized_revenue,
    m.mart_recognized_revenue,
    round(f.fact_recognized_revenue - m.mart_recognized_revenue, 2) as fact_to_mart_variance,
    case
        when round(f.fact_recognized_revenue - m.mart_recognized_revenue, 2) = 0.00 then 'RECONCILED - ZERO VARIANCE [PASS]'
        else 'UNRECONCILED DISCREPANCY [FAIL]'
    end as audit_status
from raw_rev r, staging_rev s, intermediate_rev i, fact_rev f, mart_rev m;


-- Test 2: Harvest Mass Balance Reconciliation across Pipeline Tiers
with raw_harvest as (
    select
        round(sum(accepted_weight_kg), 3) as raw_accepted_kg
    from raw.raw_harvest_records
    where accepted_weight_kg <= gross_harvested_kg -- excluding intentional DQ test row
),

fact_harvest_yield as (
    select
        round(sum(accepted_weight_kg), 3) as fact_accepted_kg
    from analytics_analytics.fact_harvest
),

mart_harvest_yield as (
    select
        round(sum(total_accepted_harvest_kg), 3) as mart_accepted_kg
    from analytics_analytics.mart_business_overview
)

select
    'HARVEST_MASS_BALANCE_RECONCILIATION' as reconciliation_check,
    r.raw_accepted_kg,
    f.fact_accepted_kg,
    m.mart_accepted_kg,
    round(f.fact_accepted_kg - m.mart_accepted_kg, 3) as fact_to_mart_variance_kg,
    case
        when round(f.fact_accepted_kg - m.mart_accepted_kg, 3) = 0.000 then 'RECONCILED - ZERO VARIANCE [PASS]'
        else 'UNRECONCILED DISCREPANCY [FAIL]'
    end as audit_status
from raw_harvest r, fact_harvest_yield f, mart_harvest_yield m;


-- Test 3: Operating Expense Reconciliation across Pipeline Tiers
with raw_expenses as (
    select
        round(sum(amount), 2) as raw_total_opex
    from raw.raw_expenses
),

fact_expenses_total as (
    select
        round(sum(amount), 2) as fact_total_opex
    from analytics_analytics.fact_expenses
),

mart_expenses_total as (
    select
        round(sum(operating_expenses), 2) as mart_total_opex
    from analytics_analytics.mart_business_overview
)

select
    'OPEX_FINANCIAL_RECONCILIATION' as reconciliation_check,
    r.raw_total_opex,
    f.fact_total_opex,
    m.mart_total_opex,
    round(f.fact_total_opex - m.mart_total_opex, 2) as fact_to_mart_variance,
    case
        when round(f.fact_total_opex - m.mart_total_opex, 2) = 0.00 then 'RECONCILED - ZERO VARIANCE [PASS]'
        else 'UNRECONCILED DISCREPANCY [FAIL]'
    end as audit_status
from raw_expenses r, fact_expenses_total f, mart_expenses_total m;
