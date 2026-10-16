-- ==============================================================================
-- Case Study 4: True Cost per kg & Break-Even Analysis
-- Business Question: What is the true production cost per kg and break-even monthly volume?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Monthly Cost Absorption per Kilogram
select
    year_month,
    total_accepted_harvest_kg,
    total_sales_fulfilled_kg,
    net_sales_revenue,
    cost_of_goods_sold as direct_material_cogs,
    operating_expenses as fixed_overhead_opex,
    round(cost_of_goods_sold + operating_expenses, 2) as total_operating_costs,
    -- Fully absorbed cost per produced kg
    round((cost_of_goods_sold + operating_expenses) / nullif(total_accepted_harvest_kg, 0), 2) as fully_absorbed_cost_per_produced_kg,
    -- Effective revenue realized per produced kg
    round(net_sales_revenue / nullif(total_accepted_harvest_kg, 0), 2) as realized_revenue_per_produced_kg,
    operating_result
from mart_business_overview
order by year_month;

-- Section 2: Farm Break-Even Volume Calculation
with cost_structure as (
    select
        avg(operating_expenses) as avg_monthly_fixed_opex
    from mart_business_overview
),

margin_structure as (
    select
        sum(gross_profit_amount) / sum(quantity_fulfilled_kg) as weighted_contribution_margin_per_kg
    from fact_sales
    where order_status in ('DELIVERED', 'COMPLETED')
)

select
    round(cs.avg_monthly_fixed_opex, 2) as avg_monthly_fixed_overhead,
    round(ms.weighted_contribution_margin_per_kg, 2) as contribution_margin_per_kg,
    -- Break-Even Volume (kg) = Fixed Overhead / Contribution Margin per kg
    round(cs.avg_monthly_fixed_opex / ms.weighted_contribution_margin_per_kg, 1) as monthly_breakeven_volume_kg,
    -- Weekly Break-Even Target
    round((cs.avg_monthly_fixed_opex / ms.weighted_contribution_margin_per_kg) / 4.33, 1) as weekly_breakeven_volume_kg
from cost_structure cs, margin_structure ms;
