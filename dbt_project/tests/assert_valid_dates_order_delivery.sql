-- Singular test: Verify actual delivery date is not prior to order creation date
select
    order_line_id,
    order_date,
    actual_delivery_date
from {{ ref('fact_sales') }}
where actual_delivery_date is not null and actual_delivery_date < order_date
