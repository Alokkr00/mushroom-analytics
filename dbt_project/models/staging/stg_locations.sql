with source as (
    select * from {{ source('raw', 'raw_locations') }}
),

renamed as (
    select
        cast(location_id as varchar(10)) as location_id,
        cast(name as varchar(50)) as location_name,
        cast(capacity_blocks as integer) as max_capacity_blocks,
        cast(temp_controlled as boolean) as is_temperature_controlled,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
