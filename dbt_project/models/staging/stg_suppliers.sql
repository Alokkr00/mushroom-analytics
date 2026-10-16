with source as (
    select * from {{ source('raw', 'raw_suppliers') }}
),

renamed as (
    select
        cast(supplier_id as varchar(10)) as supplier_id,
        cast(name as varchar(100)) as supplier_name,
        cast(category as varchar(50)) as material_category,
        cast(lead_days_min as integer) as lead_days_min,
        cast(lead_days_max as integer) as lead_days_max,
        cast(payment_terms as integer) as payment_terms_days,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
