-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 01_production_biological_efficiency.sql
-- Purpose: Evaluate cultivation productivity, Biological Efficiency (BE %), 
--          flush degradation dynamics, and batch performance rankings.
-- Business Questions Answered:
--   1. How many kilograms of mushrooms are being produced?
--   2. Which production batches perform best, and what drives their success?
--   3. What is the yield contribution of Flush 1 vs Flush 2 vs Flush 3?
--   4. How does actual BE % compare to biological variety targets?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- CTE 1: Batch-level performance metrics with biological target benchmarks
with batch_metrics as (
    select
        b.batch_id,
        m.mushroom_common_name,
        m.scientific_name,
        l.location_name as growing_room,
        b.batch_start_date,
        b.batch_status,
        b.cycle_duration_days,
        b.planned_blocks_count,
        b.dry_substrate_kg,
        b.target_yield_kg,
        b.total_gross_harvested_kg,
        b.total_accepted_harvest_kg,
        b.total_rejected_harvest_kg,
        b.biological_efficiency_pct,
        b.rejection_rate_pct,
        b.direct_material_cost_per_kg,
        -- Variety target benchmarks from biological literature
        case 
            when m.mushroom_common_name = 'Pearl Oyster' then 75.0
            when m.mushroom_common_name like '%Lion%' then 50.0
            when m.mushroom_common_name = 'Shiitake' then 35.0
            else 50.0
        end as target_biological_efficiency_pct
    from fact_production_batches b
    inner join dim_mushroom m on b.mushroom_id = m.mushroom_id
    inner join dim_location l on b.location_id = l.location_id
),

-- CTE 2: Flush-level distribution to analyze yield drop-off over flushes
flush_analysis as (
    select
        h.batch_id,
        h.flush_number,
        count(h.harvest_id) as harvest_sessions_count,
        sum(h.gross_harvested_kg) as flush_gross_kg,
        sum(h.accepted_weight_kg) as flush_accepted_kg,
        sum(h.rejected_weight_kg) as flush_rejected_kg,
        round(avg(h.rejection_rate_pct), 2) as flush_avg_rejection_pct,
        -- Running harvest total across flushes for each batch
        sum(sum(h.accepted_weight_kg)) over (
            partition by h.batch_id 
            order by h.flush_number 
            rows between unbounded preceding and current row
        ) as running_batch_accepted_kg
    from fact_harvest h
    group by h.batch_id, h.flush_number
),

-- CTE 3: Batch ranking within each mushroom variety
ranked_batches as (
    select
        bm.*,
        dense_rank() over (
            partition by bm.mushroom_common_name 
            order by bm.biological_efficiency_pct desc
        ) as variety_efficiency_rank,
        round(bm.biological_efficiency_pct - bm.target_biological_efficiency_pct, 2) as be_variance_from_target,
        case
            when bm.batch_status = 'CONTAMINATED' then 'Contaminated - Terminated'
            when bm.biological_efficiency_pct >= bm.target_biological_efficiency_pct then 'High Yield Performer'
            when bm.biological_efficiency_pct >= (bm.target_biological_efficiency_pct * 0.8) then 'Acceptable Yield'
            else 'Underperforming Batch'
        end as yield_performance_tier
    from batch_metrics bm
)

-- Final Output: Executive Batch League Table
select
    rb.mushroom_common_name,
    rb.variety_efficiency_rank,
    rb.batch_id,
    rb.growing_room,
    rb.batch_status,
    rb.yield_performance_tier,
    rb.cycle_duration_days,
    rb.planned_blocks_count,
    rb.dry_substrate_kg,
    rb.total_accepted_harvest_kg,
    rb.biological_efficiency_pct,
    rb.target_biological_efficiency_pct,
    rb.be_variance_from_target,
    rb.rejection_rate_pct,
    rb.direct_material_cost_per_kg
from ranked_batches rb
order by rb.mushroom_common_name, rb.variety_efficiency_rank;
