with movements as (
    select * from {{ ref('stg_inventory_movements') }}
),

lot_summary as (
    select
        lot_id,
        product_id,
        mushroom_id,
        batch_id,
        min(movement_date) as lot_receipt_date,
        max(expiry_date) as expiry_date,
        avg(unit_cost) as unit_cost,
        sum(case when movement_type = 'HARVEST_IN' then signed_quantity_kg else 0 end) as total_harvest_in_kg,
        sum(case when movement_type = 'SALE_OUT' then abs(signed_quantity_kg) else 0 end) as total_sold_out_kg,
        sum(case when movement_type = 'WASTE_OUT' then abs(signed_quantity_kg) else 0 end) as total_wasted_out_kg,
        sum(signed_quantity_kg) as current_balance_kg
    from movements
    group by lot_id, product_id, mushroom_id, batch_id
)

select
    lot_id,
    product_id,
    mushroom_id,
    batch_id,
    lot_receipt_date,
    expiry_date,
    unit_cost,
    round(total_harvest_in_kg, 3) as total_harvest_in_kg,
    round(total_sold_out_kg, 3) as total_sold_out_kg,
    round(total_wasted_out_kg, 3) as total_wasted_out_kg,
    round(greatest(0, current_balance_kg), 3) as current_balance_kg,
    round(greatest(0, current_balance_kg) * unit_cost, 2) as current_balance_valuation,

    -- Expiry Risk Flag: true if balance > 0 and expiry date is within 2 days
    case 
        when greatest(0, current_balance_kg) > 0 and expiry_date is not null
        then (expiry_date - current_date)
        else null 
    end as days_until_expiry,

    case 
        when greatest(0, current_balance_kg) > 0 and expiry_date is not null and (expiry_date - current_date) <= 2
        then true
        else false
    end as is_at_expiry_risk

from lot_summary
