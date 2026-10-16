with source as (
    select * from {{ source('raw', 'raw_waste_events') }}
),

renamed as (
    select
        cast(waste_id as varchar(15)) as waste_id,
        cast(lot_id as varchar(15)) as lot_id,
        cast(product_id as varchar(10)) as product_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(nullif(batch_id, '') as varchar(15)) as batch_id,
        cast(waste_date as date) as waste_date,
        cast(waste_type as varchar(30)) as waste_type,
        cast(waste_kg as numeric(10,3)) as waste_kg,
        cast(estimated_unit_cost as numeric(10,4)) as estimated_unit_cost,
        cast(estimated_waste_value as numeric(10,2)) as estimated_waste_value,
        cast(reason_code as varchar(150)) as reason_code,
        cast(disposition as varchar(30)) as disposition,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
