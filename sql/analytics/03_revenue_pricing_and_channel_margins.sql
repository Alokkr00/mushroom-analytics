-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 03_revenue_pricing_and_channel_margins.sql
-- Purpose: Analyze revenue waterfalls, pricing realizations, channel profitability,
--          and rolling moving average selling prices across market segments.
-- Business Questions Answered:
--   1. What is the revenue waterfall from Gross Invoiced to Net Recognized Revenue?
--   2. Which sales channels (Wholesale/Restaurant vs Grocer vs Direct) are most lucrative?
--   3. What is the 30-day rolling average selling price trend by variety?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Query A: Revenue Waterfall & Discount/Return Leakage by Channel
with channel_waterfall as (
    select
        s.sales_channel,
        c.customer_segment,
        count(distinct s.order_id) as total_orders,
        sum(s.quantity_ordered_kg) as ordered_kg,
        sum(s.quantity_fulfilled_kg) as fulfilled_kg,
        sum(s.returned_kg) as returned_kg,
        round(sum(s.gross_revenue), 2) as gross_invoiced_revenue,
        round(sum(s.discount_amount), 2) as promotional_discounts,
        round(sum(s.net_revenue), 2) as net_invoiced_revenue,
        round(sum(s.credit_refund_amount), 2) as quality_credit_refunds,
        round(sum(s.final_recognized_revenue), 2) as final_recognized_revenue,
        round(sum(s.estimated_cogs_amount), 2) as total_cogs,
        round(sum(s.gross_profit_amount), 2) as gross_profit
    from fact_sales s
    inner join dim_customer c on s.customer_id = c.customer_id
    group by s.sales_channel, c.customer_segment
)

select
    sales_channel,
    customer_segment,
    total_orders,
    fulfilled_kg,
    gross_invoiced_revenue,
    promotional_discounts,
    round((promotional_discounts / nullif(gross_invoiced_revenue, 0)) * 100, 2) as discount_rate_pct,
    quality_credit_refunds,
    round((quality_credit_refunds / nullif(gross_invoiced_revenue, 0)) * 100, 2) as return_credit_rate_pct,
    final_recognized_revenue,
    gross_profit,
    case 
        when final_recognized_revenue > 0 
        then round((gross_profit / final_recognized_revenue) * 100, 2)
        else 0.00 
    end as gross_margin_pct,
    round(final_recognized_revenue / nullif(fulfilled_kg, 0), 2) as net_effective_asp_per_kg
from channel_waterfall
order by final_recognized_revenue desc;


-- Query B: Variety Realized Pricing and Rolling 7-Order Moving Average ASP
with order_grain_asp as (
    select
        s.order_id,
        s.order_date,
        m.mushroom_common_name,
        s.quantity_fulfilled_kg,
        s.final_recognized_revenue,
        round(s.final_recognized_revenue / nullif(s.quantity_fulfilled_kg, 0), 2) as order_asp_per_kg
    from fact_sales s
    inner join dim_mushroom m on s.mushroom_id = m.mushroom_id
    where s.quantity_fulfilled_kg > 0
),

rolling_asp as (
    select
        order_id,
        order_date,
        mushroom_common_name,
        quantity_fulfilled_kg,
        final_recognized_revenue,
        order_asp_per_kg,
        -- 7-order rolling average selling price per kg
        round(avg(order_asp_per_kg) over (
            partition by mushroom_common_name 
            order by order_date, order_id 
            rows between 6 preceding and current row
        ), 2) as rolling_7_order_avg_asp
    from order_grain_asp
)

select
    order_date,
    mushroom_common_name,
    count(order_id) as transactions_count,
    round(sum(quantity_fulfilled_kg), 2) as total_kg_delivered,
    round(sum(final_recognized_revenue), 2) as day_revenue,
    round(avg(order_asp_per_kg), 2) as day_avg_asp_per_kg,
    round(avg(rolling_7_order_avg_asp), 2) as smoothed_trend_asp_per_kg
from rolling_asp
group by order_date, mushroom_common_name
order by order_date desc, mushroom_common_name;
