with waste_enhanced as (
    select
        w.loss_event_id,
        w.event_date,
        strftime(w.event_date, '%Y-%m') as year_month,
        w.loss_stage,
        coalesce(w.product_id, 'UNPACKAGED') as product_id,
        coalesce(p.product_name, 'Bulk / Pre-packaging Crop') as product_name,
        coalesce(p.mushroom_common_name, m.mushroom_common_name, 'Unknown') as mushroom_common_name,
        w.lost_quantity_kg,
        w.reason_code,
        w.estimated_financial_loss,
        w.disposition
    from {{ ref('int_waste_events') }} w
    left join {{ ref('dim_product') }} p on w.product_id = p.product_id
    left join {{ ref('fact_production_batches') }} b on w.batch_id = b.batch_id
    left join {{ ref('dim_mushroom') }} m on b.mushroom_id = m.mushroom_id
)

select
    year_month,
    loss_stage,
    mushroom_common_name,
    reason_code,
    count(loss_event_id) as loss_incidents_count,
    round(sum(lost_quantity_kg), 3) as total_lost_quantity_kg,
    round(sum(estimated_financial_loss), 2) as total_estimated_loss_amount
from waste_enhanced
group by 1, 2, 3, 4
order by 1, 2, 3, 4
