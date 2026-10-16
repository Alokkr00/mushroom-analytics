-- ==============================================================================
-- Case Study 7: Demand Planning & Inoculation Scheduling
-- Business Question: How many substrate blocks should FungiFlow inoculate weekly?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Weekly Historical Customer Fulfilled Demand (kg)
with weekly_sales as (
    select
        strftime(order_date, '%Y-W%W') as sales_week,
        m.mushroom_common_name,
        round(sum(quantity_fulfilled_kg), 2) as weekly_fulfilled_kg
    from fact_sales s
    inner join dim_mushroom m on s.mushroom_id = m.mushroom_id
    where order_status in ('DELIVERED', 'COMPLETED')
    group by 1, 2
),

-- Section 2: Average Biological Yield per Block across Varieties
variety_block_yield as (
    select
        m.mushroom_common_name,
        round(avg(b.total_accepted_harvest_kg / b.planned_blocks_count), 3) as avg_yield_kg_per_block,
        round(avg(b.cycle_duration_days), 0) as avg_cycle_days
    from fact_production_batches b
    inner join dim_mushroom m on b.mushroom_id = m.mushroom_id
    where b.batch_status = 'COMPLETED'
    group by m.mushroom_common_name
)

select
    ws.sales_week,
    ws.mushroom_common_name,
    ws.weekly_fulfilled_kg,
    vby.avg_yield_kg_per_block,
    vby.avg_cycle_days as gestation_lead_time_days,
    -- Blocks required = Weekly Demand kg / Yield per block kg
    ceil(ws.weekly_fulfilled_kg / nullif(vby.avg_yield_kg_per_block, 0)) as blocks_required_to_meet_demand
from weekly_sales ws
inner join variety_block_yield vby on ws.mushroom_common_name = vby.mushroom_common_name
order by ws.sales_week desc, ws.mushroom_common_name;
