select
    c.customer_id,
    c.customer_name,
    c.customer_segment,
    c.delivery_route_zone,
    c.payment_terms_days,
    c.preferred_variety_id,
    c.acquisition_date,
    c.is_active,
    coalesce(h.total_completed_orders, 0) as total_completed_orders,
    coalesce(h.lifetime_net_revenue, 0.00) as lifetime_net_revenue,
    coalesce(h.lifetime_fulfilled_kg, 0.000) as lifetime_fulfilled_kg,
    coalesce(h.average_order_value, 0.00) as average_order_value,
    coalesce(h.is_repeat_customer, false) as is_repeat_customer,
    coalesce(h.customer_tenure_days, 0) as customer_tenure_days
from {{ ref('stg_customers') }} c
left join {{ ref('int_customer_order_history') }} h on c.customer_id = h.customer_id
