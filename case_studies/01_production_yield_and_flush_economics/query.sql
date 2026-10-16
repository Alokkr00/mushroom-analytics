-- ==============================================================================
-- Case Study 1: Production Yield & Flush Economics
-- Business Question: Should FungiFlow Organics terminate fruiting blocks after Flush 2?
-- ==============================================================================

SET search_path = 'analytics_analytics';

with flush_performance as (
    select
        h.flush_number,
        count(distinct h.harvest_id) as total_harvest_sessions,
        count(distinct h.batch_id) as total_batches_flushed,
        round(sum(h.gross_harvested_kg), 2) as gross_yield_kg,
        round(sum(h.accepted_weight_kg), 2) as accepted_yield_kg,
        round(sum(h.rejected_weight_kg), 2) as rejected_yield_kg,
        round(avg(h.accepted_weight_kg), 2) as avg_accepted_kg_per_session,
        round(avg(h.rejection_rate_pct), 2) as avg_rejection_rate_pct,
        round(sum(h.labor_hours), 1) as total_labor_hours,
        round(sum(h.accepted_weight_kg) / sum(sum(h.accepted_weight_kg)) over () * 100, 1) as pct_of_total_farm_yield
    from fact_harvest h
    group by h.flush_number
),

flush_economics as (
    select
        fp.*,
        -- Wholesale realization assumption: $18.50/kg
        round(fp.accepted_yield_kg * 18.50, 2) as gross_revenue_generated,
        -- Direct harvesting labor at $18.00/hour
        round(fp.total_labor_hours * 18.00, 2) as direct_harvest_labor_cost,
        -- Room occupancy cost: estimated 12 days per flush at $4.50/day climate overhead
        round(fp.total_batches_flushed * 12 * 4.50, 2) as estimated_room_climate_cost
    from flush_performance fp
)

select
    flush_number,
    total_harvest_sessions,
    accepted_yield_kg,
    pct_of_total_farm_yield,
    avg_accepted_kg_per_session,
    avg_rejection_rate_pct,
    gross_revenue_generated,
    direct_harvest_labor_cost,
    estimated_room_climate_cost,
    round(gross_revenue_generated - (direct_harvest_labor_cost + estimated_room_climate_cost), 2) as net_marginal_flush_profit
from flush_economics
order by flush_number;
