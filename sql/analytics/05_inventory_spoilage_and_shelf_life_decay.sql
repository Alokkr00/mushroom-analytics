-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 05_inventory_spoilage_and_shelf_life_decay.sql
-- Purpose: Analyze multi-stage shrinkage (harvest floor vs cold room vs returns),
--          finished product inventory balance, and shelf-life decay velocity.
-- Business Questions Answered:
--   1. How much inventory remains on hand, and what is its shelf-life risk profile?
--   2. Exactly how much crop is lost at each supply chain stage?
--   3. What are the leading physical root causes of spoilage?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Multi-Stage Shrinkage & Loss Decomposition
with total_harvest as (
    select
        sum(gross_harvested_kg) as total_gross_harvest_kg,
        sum(accepted_weight_kg) as total_accepted_harvest_kg
    from fact_harvest
),

loss_summary as (
    select
        loss_stage,
        mushroom_common_name,
        reason_code,
        sum(loss_incidents_count) as total_incidents,
        sum(total_lost_quantity_kg) as total_lost_kg,
        sum(total_estimated_loss_amount) as total_loss_amount
    from mart_inventory_waste
    group by loss_stage, mushroom_common_name, reason_code
)

select
    ls.loss_stage,
    ls.mushroom_common_name,
    ls.reason_code,
    ls.total_incidents,
    ls.total_lost_kg,
    ls.total_loss_amount,
    -- Loss as % of gross harvested crop
    round((ls.total_lost_kg / th.total_gross_harvest_kg) * 100, 2) as loss_pct_of_gross_harvest,
    -- Financial loss rank
    dense_rank() over (partition by ls.loss_stage order by ls.total_loss_amount desc) as stage_loss_rank
from loss_summary ls
cross join total_harvest th
order by ls.total_loss_amount desc;


-- Section 2: Current Inventory Lot Balances & Expiration Proximity
with running_inventory as (
    select
        m.lot_id,
        m.product_id,
        p.product_name,
        p.mushroom_common_name,
        p.package_format,
        m.movement_date,
        m.expiry_date,
        -- Running cumulative stock balance for each lot
        sum(m.signed_quantity_kg) over (
            partition by m.lot_id, m.product_id 
            order by m.movement_date, m.movement_id 
            rows between unbounded preceding and current row
        ) as cumulative_lot_stock_kg,
        -- Snapshot anchor date (max movement date in fact table)
        max(m.movement_date) over () as system_current_date
    from fact_inventory_movements m
    inner join dim_product p on m.product_id = p.product_id
),

latest_lot_status as (
    select
        lot_id,
        product_id,
        product_name,
        mushroom_common_name,
        package_format,
        movement_date as last_movement_date,
        expiry_date,
        cumulative_lot_stock_kg as current_available_stock_kg,
        date_diff('day', system_current_date, expiry_date) as days_until_expiration,
        row_number() over (partition by lot_id, product_id order by movement_date desc) as rn
    from running_inventory
)

select
    lot_id,
    product_name,
    mushroom_common_name,
    package_format,
    last_movement_date,
    expiry_date,
    current_available_stock_kg,
    days_until_expiration,
    case
        when current_available_stock_kg <= 0 then 'Depleted / Fully Dispatched'
        when days_until_expiration < 0 then 'EXPIRED - Condemn & Compost'
        when days_until_expiration between 0 and 3 then 'CRITICAL - Urgent Clearance Discount'
        when days_until_expiration between 4 and 7 then 'MODERATE - High Sales Priority'
        else 'HEALTHY - Fresh Stock'
    end as inventory_risk_status
from latest_lot_status
where rn = 1
order by current_available_stock_kg desc, days_until_expiration asc;
