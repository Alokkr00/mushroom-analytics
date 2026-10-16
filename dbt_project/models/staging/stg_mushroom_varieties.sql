with source as (
    select * from {{ source('raw', 'raw_mushroom_varieties') }}
),

renamed as (
    select
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(common_name as varchar(50)) as common_name,
        cast(scientific_name as varchar(100)) as scientific_name,
        cast(substrate_formula as varchar(150)) as substrate_formula,
        cast(incubation_days_min as integer) as incubation_days_min,
        cast(incubation_days_max as integer) as incubation_days_max,
        cast(days_to_flush1_min as integer) as days_to_flush1_min,
        cast(days_to_flush1_max as integer) as days_to_flush1_max,
        cast(days_between_flushes_min as integer) as days_between_flushes_min,
        cast(days_between_flushes_max as integer) as days_between_flushes_max,
        cast(be_min as numeric(5,2)) as biological_efficiency_min,
        cast(be_max as numeric(5,2)) as biological_efficiency_max,
        cast(flush1_share_min as numeric(5,2)) as flush1_share_min,
        cast(flush1_share_max as numeric(5,2)) as flush1_share_max,
        cast(shelf_life_days as integer) as standard_shelf_life_days,
        cast(rejection_rate_normal_min as numeric(5,3)) as rejection_rate_normal_min,
        cast(rejection_rate_normal_max as numeric(5,3)) as rejection_rate_normal_max,
        cast(spawn_rate as numeric(5,3)) as spawn_rate_ratio,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
