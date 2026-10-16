with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

renamed as (
    select
        cast(customer_id as varchar(10)) as customer_id,
        cast(customer_name as varchar(100)) as customer_name,
        cast(customer_segment as varchar(30)) as customer_segment,
        cast(delivery_route_zone as varchar(20)) as delivery_route_zone,
        cast(payment_terms_days as integer) as payment_terms_days,
        cast(preferred_variety as varchar(10)) as preferred_variety_id,
        cast(acquisition_date as date) as acquisition_date,
        cast(is_active as boolean) as is_active,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
