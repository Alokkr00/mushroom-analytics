-- ==============================================================================
-- Case Study 2: Spoilage & Cold-Chain Shrinkage
-- Business Question: Where does physical loss occur, and how can FungiFlow prevent it?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: 3-Stage Shrinkage Breakdown
with total_harvest as (
    select sum(gross_harvested_kg) as total_gross_harvest_kg from fact_harvest
),

loss_stages as (
    select
        loss_stage,
        sum(loss_incidents_count) as incident_count,
        round(sum(total_lost_quantity_kg), 2) as lost_kg,
        round(sum(total_estimated_loss_amount), 2) as financial_sunk_loss
    from mart_inventory_waste
    group by loss_stage
)

select
    ls.loss_stage,
    ls.incident_count,
    ls.lost_kg,
    round(ls.lost_kg / sum(ls.lost_kg) over () * 100, 1) as pct_of_total_shrinkage,
    round(ls.lost_kg / th.total_gross_harvest_kg * 100, 2) as pct_of_farm_gross_harvest,
    ls.financial_sunk_loss,
    round(ls.lost_kg * 18.50, 2) as foregone_sales_revenue_potential
from loss_stages ls
cross join total_harvest th
order by ls.lost_kg desc;

-- Section 2: Root Cause Analysis within Cold Storage Spoilage
select
    mushroom_common_name,
    reason_code,
    sum(loss_incidents_count) as incident_count,
    round(sum(total_lost_quantity_kg), 2) as lost_kg,
    round(sum(total_estimated_loss_amount), 2) as financial_loss
from mart_inventory_waste
where loss_stage = 'COLD_STORAGE_SPOILAGE'
group by mushroom_common_name, reason_code
order by lost_kg desc;
