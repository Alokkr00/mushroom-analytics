with sales as (
    select * from {{ ref('int_sales_financials') }}
),

customer_orders as (
    select
        customer_id,
        customer_name,
        customer_segment,
        delivery_route_zone,
        count(distinct order_id) as total_completed_orders,
        min(order_date) as first_order_date,
        max(order_date) as latest_order_date,
        sum(net_revenue) as lifetime_net_revenue,
        sum(quantity_fulfilled_kg) as lifetime_fulfilled_kg,
        round(avg(net_revenue), 2) as average_line_revenue
    from sales
    group by customer_id, customer_name, customer_segment, delivery_route_zone
)

select
    customer_id,
    customer_name,
    customer_segment,
    delivery_route_zone,
    total_completed_orders,
    first_order_date,
    latest_order_date,
    round(lifetime_net_revenue, 2) as lifetime_net_revenue,
    round(lifetime_fulfilled_kg, 3) as lifetime_fulfilled_kg,
    round(lifetime_net_revenue / nullif(total_completed_orders, 0), 2) as average_order_value,

    -- Repeat customer indicator: true if >= 2 distinct completed orders
    case 
        when total_completed_orders >= 2 then true
        else false
    end as is_repeat_customer,

    -- Customer tenure in days
    case 
        when latest_order_date >= first_order_date 
        then (latest_order_date - first_order_date)
        else 0 
    end as customer_tenure_days

from customer_orders
