with source as (
    select * from {{ source('raw', 'raw_harvest_records') }}
),

renamed as (
    select
        cast(harvest_id as varchar(15)) as harvest_id,
        cast(batch_id as varchar(15)) as batch_id,
        cast(harvest_date as date) as harvest_date,
        cast(flush_number as integer) as flush_number,
        cast(gross_harvested_kg as numeric(10,3)) as gross_harvested_kg,
        cast(accepted_weight_kg as numeric(10,3)) as accepted_weight_kg,
        cast(rejected_weight_kg as numeric(10,3)) as rejected_weight_kg,
        cast(rejection_reason as varchar(100)) as rejection_reason,
        cast(labor_hours as numeric(6,2)) as labor_hours,
        cast(source_type as varchar(30)) as source_type,
        cast(recorded_at as timestamp) as recorded_at
    from source
    -- Filter out impossible DQ test records where accepted > gross
    where accepted_weight_kg <= gross_harvested_kg
)

select * from renamed
