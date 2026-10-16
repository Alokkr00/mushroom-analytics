select
    movement_id,
    lot_id,
    product_id,
    mushroom_id,
    batch_id,
    harvest_id,
    movement_date,
    movement_type,
    signed_quantity_kg,
    unit_cost,
    total_movement_value,
    expiry_date,
    reason,
    reference_transaction_id
from {{ ref('stg_inventory_movements') }}
