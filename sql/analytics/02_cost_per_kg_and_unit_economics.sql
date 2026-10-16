-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 02_cost_per_kg_and_unit_economics.sql
-- Purpose: Calculate comprehensive unit economics, true production cost per kg,
--          and contribution margin across packaging formats (punnets vs crates).
-- Business Questions Answered:
--   1. How much does each kilogram cost to produce (materials + allocated overhead)?
--   2. Which product formats (200g punnets vs 1kg crates vs 5kg bulk) yield highest profit per kg?
--   3. What is the unit contribution margin after packaging and direct delivery costs?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- CTE 1: Variety-level direct cultivation material cost per accepted kg
with cultivation_costs as (
    select
        b.mushroom_id,
        m.mushroom_common_name,
        sum(b.dry_substrate_kg) as total_substrate_used_kg,
        sum(b.total_accepted_harvest_kg) as total_accepted_kg,
        sum(b.direct_material_cost) as total_direct_materials_cost,
        round(sum(b.direct_material_cost) / nullif(sum(b.total_accepted_harvest_kg), 0), 2) as avg_direct_material_cost_per_kg
    from fact_production_batches b
    inner join dim_mushroom m on b.mushroom_id = m.mushroom_id
    where b.batch_status != 'CONTAMINATED'
    group by b.mushroom_id, m.mushroom_common_name
),

-- CTE 2: Monthly allocated operating overhead (utilities, rent, sanitation) per kg produced
overhead_pool as (
    select
        sum(amount) as total_overhead_opex
    from fact_expenses
    where category_id in ('EXP-CAT-001', 'EXP-CAT-002', 'EXP-CAT-005') -- Utilities, Facility Rent, Maintenance
),

production_pool as (
    select
        sum(total_accepted_harvest_kg) as total_farm_production_kg
    from fact_production_batches
),

overhead_absorption as (
    select
        round(o.total_overhead_opex / nullif(p.total_farm_production_kg, 0), 2) as allocated_overhead_per_kg
    from overhead_pool o, production_pool p
),

-- CTE 3: Sales SKU unit performance and realization per kg
sku_sales_performance as (
    select
        s.product_id,
        p.product_name,
        p.sku_code,
        m.mushroom_common_name,
        p.package_format,
        p.unit_weight_kg,
        count(distinct s.order_id) as total_orders_fulfilled,
        sum(s.quantity_fulfilled_kg) as total_kg_sold,
        round(sum(s.final_recognized_revenue), 2) as total_net_revenue,
        round(sum(s.estimated_cogs_amount), 2) as total_cogs_amount,
        round(sum(s.gross_profit_amount), 2) as total_gross_profit,
        round(sum(s.final_recognized_revenue) / nullif(sum(s.quantity_fulfilled_kg), 0), 2) as realized_asp_per_kg
    from fact_sales s
    inner join dim_product p on s.product_id = p.product_id
    inner join dim_mushroom m on s.mushroom_id = m.mushroom_id
    where s.order_status in ('DELIVERED', 'COMPLETED')
    group by s.product_id, p.product_name, p.sku_code, m.mushroom_common_name, p.package_format, p.unit_weight_kg
)

-- Final Output: Unit Economics & Contribution Matrix
select
    sp.mushroom_common_name,
    sp.sku_code,
    sp.product_name,
    sp.package_format,
    sp.unit_weight_kg,
    sp.total_kg_sold,
    sp.realized_asp_per_kg,
    cc.avg_direct_material_cost_per_kg,
    oa.allocated_overhead_per_kg,
    round(cc.avg_direct_material_cost_per_kg + oa.allocated_overhead_per_kg, 2) as fully_absorbed_cost_per_kg,
    -- Unit Contribution Margin ($/kg) = Realized ASP/kg - Direct Material Cost/kg
    round(sp.realized_asp_per_kg - cc.avg_direct_material_cost_per_kg, 2) as unit_contribution_margin_per_kg,
    -- Fully Absorbed Net Profit Margin ($/kg)
    round(sp.realized_asp_per_kg - (cc.avg_direct_material_cost_per_kg + oa.allocated_overhead_per_kg), 2) as fully_absorbed_profit_per_kg,
    -- Gross Margin % on fulfilled sales
    case 
        when sp.total_net_revenue > 0 
        then round((sp.total_gross_profit / sp.total_net_revenue) * 100, 2)
        else 0.00 
    end as realized_gross_margin_pct
from sku_sales_performance sp
inner join cultivation_costs cc on sp.mushroom_common_name = cc.mushroom_common_name
cross join overhead_absorption oa
order by sp.mushroom_common_name, sp.realized_asp_per_kg desc;
