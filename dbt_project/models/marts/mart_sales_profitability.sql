select
    strftime(s.order_date, '%Y-%m') as year_month,
    c.customer_segment,
    m.mushroom_common_name,
    s.sales_channel,
    count(distinct s.order_id) as total_orders_count,
    sum(s.quantity_ordered_kg) as total_ordered_kg,
    sum(s.quantity_fulfilled_kg) as total_fulfilled_kg,
    sum(s.returned_kg) as total_returned_kg,
    sum(s.net_retained_quantity_kg) as total_net_retained_kg,
    round(sum(s.gross_revenue), 2) as total_gross_revenue,
    round(sum(s.discount_amount), 2) as total_discount_amount,
    round(sum(s.net_revenue), 2) as total_net_revenue,
    round(sum(s.credit_refund_amount), 2) as total_credit_refund_amount,
    round(sum(s.final_recognized_revenue), 2) as total_final_recognized_revenue,
    round(sum(s.estimated_cogs_amount), 2) as total_cogs_amount,
    round(sum(s.gross_profit_amount), 2) as total_gross_profit,
    case 
        when sum(s.final_recognized_revenue) > 0 
        then round((sum(s.gross_profit_amount) / sum(s.final_recognized_revenue)) * 100, 2)
        else 0.00 
    end as gross_margin_pct,
    case 
        when sum(s.quantity_fulfilled_kg) > 0 
        then round(sum(s.final_recognized_revenue) / sum(s.quantity_fulfilled_kg), 2)
        else 0.00 
    end as effective_asp_per_kg
from {{ ref('fact_sales') }} s
left join {{ ref('dim_customer') }} c on s.customer_id = c.customer_id
left join {{ ref('dim_product') }} p on s.product_id = p.product_id
left join {{ ref('dim_mushroom') }} m on s.mushroom_id = m.mushroom_id
group by 1, 2, 3, 4
order by 1, 2, 3, 4
