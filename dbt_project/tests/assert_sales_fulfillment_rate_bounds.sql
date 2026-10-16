-- Singular test: Verify fulfillment rate is within logical percentage bounds [0, 100]
select
    order_line_id,
    fulfillment_rate_pct
from {{ ref('fact_sales') }}
where fulfillment_rate_pct < 0 or fulfillment_rate_pct > 100.01
