with batches as (
    select * from {{ ref('stg_production_batches') }}
),

harvests as (
    select * from {{ ref('stg_harvest_records') }}
),

harvest_rollups as (
    select
        batch_id,
        count(distinct harvest_id) as total_flushes_recorded,
        min(harvest_date) as first_harvest_date,
        max(harvest_date) as last_harvest_date,
        sum(gross_harvested_kg) as total_gross_harvested_kg,
        sum(accepted_weight_kg) as total_accepted_harvest_kg,
        sum(rejected_weight_kg) as total_rejected_harvest_kg,
        sum(labor_hours) as total_harvest_labor_hours
    from harvests
    group by batch_id
)

select
    b.batch_id,
    b.mushroom_id,
    b.mushroom_variety,
    b.substrate_formula,
    b.growing_room_id,
    b.planned_blocks_count,
    b.dry_substrate_kg,
    b.spawn_kg,
    b.batch_start_date,
    b.transfer_to_fruiting_date,
    b.expected_first_harvest_date,
    b.target_yield_kg,
    b.direct_material_cost,
    b.batch_status,
    b.is_stress_event,
    
    -- Harvest Rollup Measures
    coalesce(h.total_flushes_recorded, 0) as total_flushes_recorded,
    h.first_harvest_date,
    h.last_harvest_date,
    coalesce(h.total_gross_harvested_kg, 0) as total_gross_harvested_kg,
    coalesce(h.total_accepted_harvest_kg, 0) as total_accepted_harvest_kg,
    coalesce(h.total_rejected_harvest_kg, 0) as total_rejected_harvest_kg,
    coalesce(h.total_harvest_labor_hours, 0) as total_harvest_labor_hours,

    -- Rejection Rate (%)
    case 
        when coalesce(h.total_gross_harvested_kg, 0) > 0 
        then round((h.total_rejected_harvest_kg / h.total_gross_harvested_kg) * 100, 2)
        else 0.00 
    end as rejection_rate_pct,

    -- Biological Efficiency (BE %) = (Accepted Fresh Yield / Dry Substrate Mass) * 100
    case 
        when b.dry_substrate_kg > 0 
        then round((coalesce(h.total_accepted_harvest_kg, 0) / b.dry_substrate_kg) * 100, 2)
        else 0.00 
    end as biological_efficiency_pct,

    -- Target Achievement (%)
    case 
        when b.target_yield_kg > 0 
        then round((coalesce(h.total_accepted_harvest_kg, 0) / b.target_yield_kg) * 100, 2)
        else 0.00 
    end as target_achievement_pct,

    -- Production Cycle Duration (Days from Inoculation to Last Harvest)
    case 
        when h.last_harvest_date is not null and b.batch_start_date is not null
        then (h.last_harvest_date - b.batch_start_date)
        else null 
    end as cycle_duration_days,

    -- Direct Material Cost per Accepted Kilogram
    case 
        when coalesce(h.total_accepted_harvest_kg, 0) > 0 
        then round(b.direct_material_cost / h.total_accepted_harvest_kg, 4)
        else null 
    end as direct_material_cost_per_kg

from batches b
left join harvest_rollups h on b.batch_id = h.batch_id
