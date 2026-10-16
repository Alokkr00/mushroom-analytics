-- ==============================================================================
-- Case Study 3: Pricing Strategy & Channel Mix
-- Business Question: How can FungiFlow maximize profit by shifting packaging channels?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Contribution Margin by Packaging Format
with sku_performance as (
    select
        p.package_format,
        p.unit_weight_kg,
        count(distinct s.order_id) as orders_count,
        round(sum(s.quantity_fulfilled_kg), 2) as fulfilled_kg,
        round(sum(s.final_recognized_revenue), 2) as recognized_revenue,
        round(sum(s.estimated_cogs_amount), 2) as direct_cogs,
        round(sum(s.gross_profit_amount), 2) as gross_profit,
        round(sum(s.final_recognized_revenue) / nullif(sum(s.quantity_fulfilled_kg), 0), 2) as realized_asp_per_kg,
        round(sum(s.estimated_cogs_amount) / nullif(sum(s.quantity_fulfilled_kg), 0), 2) as direct_cogs_per_kg,
        round(sum(s.gross_profit_amount) / nullif(sum(s.quantity_fulfilled_kg), 0), 2) as contribution_margin_per_kg,
        round((sum(s.gross_profit_amount) / nullif(sum(s.final_recognized_revenue), 0)) * 100, 1) as gross_margin_pct
    from fact_sales s
    inner join dim_product p on s.product_id = p.product_id
    where s.order_status in ('DELIVERED', 'COMPLETED')
    group by p.package_format, p.unit_weight_kg
)

select
    package_format,
    unit_weight_kg,
    orders_count,
    fulfilled_kg,
    recognized_revenue,
    realized_asp_per_kg,
    direct_cogs_per_kg,
    contribution_margin_per_kg,
    gross_margin_pct
from sku_performance
order by contribution_margin_per_kg desc;

-- Section 2: Channel Shift Simulation (Shifting 25% of Bulk Volume into Punnets)
with current_bulk as (
    select
        m.mushroom_common_name,
        sum(s.quantity_fulfilled_kg) as bulk_kg,
        sum(s.final_recognized_revenue) as bulk_revenue,
        round(sum(s.final_recognized_revenue) / sum(s.quantity_fulfilled_kg), 2) as current_asp
    from fact_sales s
    inner join dim_product p on s.product_id = p.product_id
    inner join dim_mushroom m on s.mushroom_id = m.mushroom_id
    where p.package_format = 'Bulk Crate'
    group by m.mushroom_common_name
)

select
    mushroom_common_name,
    bulk_kg,
    current_asp as bulk_asp_per_kg,
    round(bulk_kg * 0.25, 2) as volume_shifted_to_punnets_kg,
    round(bulk_kg * 0.25 * 33.40, 2) as projected_punnet_revenue,
    round(bulk_kg * 0.25 * current_asp, 2) as displaced_bulk_revenue,
    round((bulk_kg * 0.25 * 33.40) - (bulk_kg * 0.25 * current_asp), 2) as net_incremental_revenue_gain
from current_bulk
order by net_incremental_revenue_gain desc;
