with order_lines as (
    select * from {{ ref('stg_sales_order_lines') }}
),

orders as (
    select * from {{ ref('stg_sales_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

returns as (
    select
        original_order_line_id,
        sum(return_kg) as returned_kg,
        sum(credit_value) as credit_refund_amount
    from {{ ref('stg_returns') }}
    group by original_order_line_id
)

select
    -- Primary Keys & Identifiers
    l.order_line_id,
    l.order_id,
    o.customer_id,
    c.customer_name,
    c.customer_segment,
    c.delivery_route_zone,
    l.product_id,
    p.sku_code,
    p.product_name,
    p.package_format,
    p.quality_grade,
    l.mushroom_id,
    l.lot_id,

    -- Dates & Channels
    o.order_date,
    o.requested_delivery_date,
    o.actual_delivery_date,
    o.sales_channel,
    o.order_status,
    o.payment_status,

    -- Quantities
    l.quantity_ordered_kg,
    l.quantity_fulfilled_kg,
    coalesce(r.returned_kg, 0) as returned_kg,
    greatest(0, l.quantity_fulfilled_kg - coalesce(r.returned_kg, 0)) as net_retained_quantity_kg,

    -- Fulfillment Rate (%)
    case 
        when l.quantity_ordered_kg > 0 
        then round((l.quantity_fulfilled_kg / l.quantity_ordered_kg) * 100, 2)
        else 0.00 
    end as fulfillment_rate_pct,

    -- Pricing & Financials
    l.unit_selling_price,
    l.gross_revenue,
    l.discount_amount,
    l.net_revenue,
    coalesce(r.credit_refund_amount, 0) as credit_refund_amount,
    round(l.net_revenue - coalesce(r.credit_refund_amount, 0), 2) as final_recognized_revenue,

    -- Estimated Unit Cost & COGS
    -- Assume standard cost basis from lot inventory receipt (~$3.60-$4.50/kg)
    round(l.quantity_fulfilled_kg * 4.10, 2) as estimated_cogs_amount,

    -- Gross Profit = Final Recognized Revenue - Estimated COGS
    round((l.net_revenue - coalesce(r.credit_refund_amount, 0)) - (l.quantity_fulfilled_kg * 4.10), 2) as gross_profit_amount,

    -- Gross Margin (%)
    case 
        when (l.net_revenue - coalesce(r.credit_refund_amount, 0)) > 0 
        then round(
            (((l.net_revenue - coalesce(r.credit_refund_amount, 0)) - (l.quantity_fulfilled_kg * 4.10)) / 
             (l.net_revenue - coalesce(r.credit_refund_amount, 0))) * 100, 
            2
        )
        else 0.00 
    end as gross_margin_pct

from order_lines l
inner join orders o on l.order_id = o.order_id
inner join products p on l.product_id = p.product_id
inner join customers c on o.customer_id = c.customer_id
left join returns r on l.order_line_id = r.original_order_line_id
