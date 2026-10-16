with harvests as (
    select * from {{ ref('stg_harvest_records') }}
),

batches as (
    select batch_id, mushroom_id, growing_room_id
    from {{ ref('stg_production_batches') }}
)

select
    h.harvest_id,
    h.batch_id,
    b.mushroom_id,
    b.growing_room_id as location_id,
    h.harvest_date,
    h.flush_number,
    h.gross_harvested_kg,
    h.accepted_weight_kg,
    h.rejected_weight_kg,
    case 
        when h.gross_harvested_kg > 0 
        then round((h.rejected_weight_kg / h.gross_harvested_kg) * 100, 2)
        else 0.00 
    end as rejection_rate_pct,
    h.rejection_reason,
    h.labor_hours
from harvests h
left join batches b on h.batch_id = b.batch_id
