select
    strftime(b.batch_start_date, '%Y-%m') as year_month,
    m.mushroom_common_name,
    count(distinct b.batch_id) as batches_started,
    sum(case when b.batch_status = 'CONTAMINATED' then 1 else 0 end) as contaminated_batches_count,
    sum(b.planned_blocks_count) as total_blocks_inoculated,
    sum(b.dry_substrate_kg) as total_dry_substrate_kg,
    sum(b.total_gross_harvested_kg) as total_gross_yield_kg,
    sum(b.total_accepted_harvest_kg) as total_accepted_yield_kg,
    sum(b.total_rejected_harvest_kg) as total_rejected_yield_kg,
    round(avg(b.biological_efficiency_pct), 2) as avg_biological_efficiency_pct,
    round(avg(b.rejection_rate_pct), 2) as avg_rejection_rate_pct,
    round(avg(b.cycle_duration_days), 1) as avg_cycle_duration_days,
    round(avg(b.direct_material_cost_per_kg), 2) as avg_direct_cost_per_kg

from {{ ref('fact_production_batches') }} b
inner join {{ ref('dim_mushroom') }} m on b.mushroom_id = m.mushroom_id
group by 1, 2
order by 1, 2
