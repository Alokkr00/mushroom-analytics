with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        cast(product_id as varchar(10)) as product_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(sku_code as varchar(30)) as sku_code,
        cast(product_name as varchar(100)) as product_name,
        cast(package_format as varchar(40)) as package_format,
        cast(unit_weight_kg as numeric(6,3)) as unit_weight_kg,
        cast(grade as varchar(20)) as quality_grade,
        cast(standard_selling_price as numeric(10,2)) as standard_selling_price,
        cast(active_status as boolean) as is_active,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
