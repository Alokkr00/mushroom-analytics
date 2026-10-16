with source as (
    select * from {{ source('raw', 'raw_inventory_movements') }}
),

renamed as (
    select
        cast(movement_id as varchar(15)) as movement_id,
        cast(lot_id as varchar(15)) as lot_id,
        cast(product_id as varchar(10)) as product_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(nullif(batch_id, '') as varchar(15)) as batch_id,
        cast(nullif(harvest_id, '') as varchar(15)) as harvest_id,
        cast(movement_date as date) as movement_date,
        cast(movement_type as varchar(30)) as movement_type,
        cast(signed_quantity_kg as numeric(10,3)) as signed_quantity_kg,
        cast(unit_cost as numeric(10,4)) as unit_cost,
        cast(total_movement_value as numeric(10,2)) as total_movement_value,
        cast(expiry_date as date) as expiry_date,
        cast(reason as varchar(150)) as reason,
        cast(nullif(reference_transaction_id, '') as varchar(20)) as reference_transaction_id,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
