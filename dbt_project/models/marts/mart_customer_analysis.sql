with customer_revenue as (
    select
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.delivery_route_zone,
        c.acquisition_date,
        c.is_active,
        c.is_repeat_customer,
        c.customer_tenure_days,
        c.total_completed_orders,
        c.lifetime_fulfilled_kg,
        c.average_order_value,
        c.lifetime_net_revenue,
        sum(c.lifetime_net_revenue) over () as total_portfolio_revenue
    from {{ ref('dim_customer') }} c
),

ranked_customers as (
    select
        *,
        round(lifetime_net_revenue / nullif(total_portfolio_revenue, 0) * 100, 2) as pct_of_total_revenue,
        sum(lifetime_net_revenue) over (
            order by lifetime_net_revenue desc, total_completed_orders desc
            rows between unbounded preceding and current row
        ) as running_cumulative_revenue,
        row_number() over (order by lifetime_net_revenue desc, total_completed_orders desc) as customer_revenue_rank,
        count(*) over () as total_customers_count
    from customer_revenue
),

final as (
    select
        customer_id,
        customer_name,
        customer_segment,
        delivery_route_zone,
        acquisition_date,
        is_active,
        is_repeat_customer,
        customer_tenure_days,
        total_completed_orders,
        lifetime_fulfilled_kg,
        average_order_value,
        lifetime_net_revenue,
        pct_of_total_revenue,
        round((running_cumulative_revenue / nullif(total_portfolio_revenue, 0)) * 100, 2) as cumulative_revenue_pct,
        customer_revenue_rank,
        case
            when (running_cumulative_revenue / nullif(total_portfolio_revenue, 0)) <= 0.80 then 'Tier 1 - Top 80% (Core Pareto)'
            else 'Tier 2 - Bottom 20% (Long Tail)'
        end as pareto_tier
    from ranked_customers
)

select * from final order by customer_revenue_rank
