select
    purchase_id,
    supplier_id,
    purchase_date,
    delivery_date,
    material_name,
    unit_of_measure,
    quantity_ordered,
    quantity_received,
    unit_price,
    total_cost,
    payment_status,
    case 
        when delivery_date is not null and purchase_date is not null
        then (delivery_date - purchase_date)
        else null 
    end as supplier_lead_time_days
from {{ ref('stg_purchases') }}
