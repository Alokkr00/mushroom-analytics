with source as (
    select * from {{ source('raw', 'raw_production_batches') }}
),

renamed as (
    select
        cast(batch_id as varchar(15)) as batch_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(mushroom_variety as varchar(50)) as mushroom_variety,
        cast(substrate_formula as varchar(150)) as substrate_formula,
        cast(planned_blocks_count as integer) as planned_blocks_count,
        cast(dry_substrate_kg as numeric(10,3)) as dry_substrate_kg,
        cast(water_liters_added as numeric(10,1)) as water_liters_added,
        cast(spawn_kg as numeric(8,3)) as spawn_kg,
        cast(batch_start_date as date) as batch_start_date,
        cast(transfer_to_fruiting_date as date) as transfer_to_fruiting_date,
        cast(growing_room_id as varchar(10)) as growing_room_id,
        cast(expected_first_harvest_date as date) as expected_first_harvest_date,
        cast(target_yield_kg as numeric(10,3)) as target_yield_kg,
        cast(direct_material_cost as numeric(10,2)) as direct_material_cost,
        cast(batch_status as varchar(20)) as batch_status,
        cast(is_stress_event as boolean) as is_stress_event,
        cast(notes as text) as notes,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
    -- Clean out deliberate missing-date DQ test records from downstream production analytics
    where batch_start_date is not null
)

select * from renamed
