-- ==============================================================================
-- Case Study 5: Customer Concentration & Retention
-- Business Question: How concentrated is revenue, and which accounts are at risk?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Customer Revenue Concentration & Pareto Tiering
with customer_spending as (
    select
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.delivery_route_zone,
        count(distinct s.order_id) as total_orders,
        round(sum(s.final_recognized_revenue), 2) as lifetime_revenue,
        round(avg(s.final_recognized_revenue), 2) as avg_order_value,
        max(s.order_date) as last_order_date
    from dim_customer c
    inner join fact_sales s on c.customer_id = s.customer_id
    where s.order_status in ('DELIVERED', 'COMPLETED')
    group by c.customer_id, c.customer_name, c.customer_segment, c.delivery_route_zone
),

ranked_spending as (
    select
        *,
        sum(lifetime_revenue) over () as portfolio_revenue,
        sum(lifetime_revenue) over (order by lifetime_revenue desc rows between unbounded preceding and current row) as running_rev,
        row_number() over (order by lifetime_revenue desc) as customer_rank,
        count(*) over () as total_customers
    from customer_spending
)

select
    customer_rank,
    customer_name,
    customer_segment,
    delivery_route_zone,
    total_orders,
    lifetime_revenue,
    round(lifetime_revenue / portfolio_revenue * 100, 2) as pct_of_total_revenue,
    round(running_rev / portfolio_revenue * 100, 2) as cumulative_revenue_pct,
    case
        when (running_rev / portfolio_revenue) <= 0.80 then 'Tier 1 - Core 80% (High Exposure)'
        else 'Tier 2 - Long Tail (Diversified)'
    end as pareto_risk_tier
from ranked_spending
order by customer_rank;
