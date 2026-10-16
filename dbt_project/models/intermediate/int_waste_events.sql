with harvest_rejections as (
    select
        'HARVEST-' || harvest_id as loss_event_id,
        harvest_date as event_date,
        'HARVEST_FLOOR_REJECTION' as loss_stage,
        batch_id,
        cast(null as varchar(15)) as lot_id,
        cast(null as varchar(10)) as product_id,
        rejected_weight_kg as lost_quantity_kg,
        rejection_reason as reason_code,
        -- Standard direct cultivation cost per kg (~$3.50/kg)
        round(rejected_weight_kg * 3.50, 2) as estimated_financial_loss,
        'Composted' as disposition
    from {{ ref('stg_harvest_records') }}
    where rejected_weight_kg > 0
),

cold_storage_waste as (
    select
        'SPOILAGE-' || waste_id as loss_event_id,
        waste_date as event_date,
        'COLD_STORAGE_SPOILAGE' as loss_stage,
        batch_id,
        lot_id,
        product_id,
        waste_kg as lost_quantity_kg,
        reason_code,
        estimated_waste_value as estimated_financial_loss,
        disposition
    from {{ ref('stg_waste_events') }}
),

customer_returns as (
    select
        'RETURN-' || return_id as loss_event_id,
        return_date as event_date,
        'CUSTOMER_DELIVERY_RETURN' as loss_stage,
        cast(null as varchar(15)) as batch_id,
        lot_id,
        product_id,
        return_kg as lost_quantity_kg,
        reason as reason_code,
        credit_value as estimated_financial_loss,
        disposition
    from {{ ref('stg_returns') }}
),

unioned as (
    select * from harvest_rejections
    union all
    select * from cold_storage_waste
    union all
    select * from customer_returns
)

select * from unioned
