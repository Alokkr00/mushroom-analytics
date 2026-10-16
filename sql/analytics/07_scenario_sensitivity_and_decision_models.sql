-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 07_scenario_sensitivity_and_decision_models.sql
-- Purpose: Perform what-if sensitivity simulations and evidence-based decision
--          modeling in pure SQL to support executive operational planning.
-- Business Questions Answered:
--   1. What is the financial upside of cutting harvest floor rejections and cold storage spoilage by 50%?
--   2. What is the margin impact of shifting 25% of wholesale Bulk Crate volume into retail Clamshell Punnets?
--   3. What happens if Lion's Mane prices increase by 10% under -5% demand elasticity?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Simulation 1: Spoilage & Waste Reduction Financial Upside Model
with waste_impact as (
    select
        loss_stage,
        sum(total_lost_quantity_kg) as total_lost_kg,
        sum(total_estimated_loss_amount) as total_financial_loss,
        sum(loss_incidents_count) as total_incidents
    from mart_inventory_waste
    group by loss_stage
),

consolidated as (
    select
        sum(total_lost_kg) as total_annual_lost_kg,
        sum(total_financial_loss) as total_sunk_cost_loss,
        -- Foregone retail revenue if salvaged and sold at wholesale ASP ($18.00/kg)
        sum(total_lost_kg) * 18.00 as foregone_gross_revenue_potential
    from waste_impact
)

select
    round(total_annual_lost_kg, 2) as historical_lost_crop_kg,
    round(total_sunk_cost_loss, 2) as historical_direct_waste_loss,
    round(foregone_gross_revenue_potential, 2) as foregone_revenue_potential,
    -- Scenario: 50% Spoilage Reduction via Improved Cold-Room Humidity & Harvesting SOP
    round(total_annual_lost_kg * 0.50, 2) as saved_marketable_crop_kg_50pct,
    round(total_sunk_cost_loss * 0.50, 2) as direct_cash_savings_50pct,
    round(foregone_gross_revenue_potential * 0.50, 2) as incremental_revenue_unlocked_50pct,
    round((total_sunk_cost_loss * 0.50) + (foregone_gross_revenue_potential * 0.50 * 0.75), 2) as net_annual_economic_gain_est
from consolidated;


-- Simulation 2: Packaging Channel Shift (Bulk Crate -> Clamshell Punnet)
-- Comparing Bulk Crate wholesale pricing vs Clamshell Punnet retail pricing
with bulk_crate_volume as (
    select
        m.mushroom_common_name,
        sum(s.quantity_fulfilled_kg) as current_bulk_kg,
        sum(s.final_recognized_revenue) as current_bulk_rev,
        round(sum(s.final_recognized_revenue) / sum(s.quantity_fulfilled_kg), 2) as bulk_asp_per_kg
    from fact_sales s
    inner join dim_product p on s.product_id = p.product_id
    inner join dim_mushroom m on s.mushroom_id = m.mushroom_id
    where p.package_format = 'Bulk Crate'
    group by m.mushroom_common_name
)

select
    mushroom_common_name,
    current_bulk_kg,
    current_bulk_rev,
    bulk_asp_per_kg,
    -- 25% volume shifted to premium clamshell punnets
    round(current_bulk_kg * 0.25, 2) as shifted_volume_kg,
    -- Clamshell punnet pricing ($32.00/kg realized = $6.40 per 200g punnet)
    round(current_bulk_kg * 0.25 * 32.00, 2) as new_retail_punnet_revenue,
    round(current_bulk_kg * 0.25 * bulk_asp_per_kg, 2) as displaced_bulk_revenue,
    -- Net revenue expansion from channel optimization
    round((current_bulk_kg * 0.25 * 32.00) - (current_bulk_kg * 0.25 * bulk_asp_per_kg), 2) as incremental_revenue_gain
from bulk_crate_volume
order by incremental_revenue_gain desc;
