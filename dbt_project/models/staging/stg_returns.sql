with source as (
    select * from {{ source('raw', 'raw_returns') }}
),

renamed as (
    select
        cast(return_id as varchar(15)) as return_id,
        cast(original_order_line_id as varchar(15)) as original_order_line_id,
        cast(original_order_id as varchar(15)) as original_order_id,
        cast(product_id as varchar(10)) as product_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(lot_id as varchar(15)) as lot_id,
        cast(return_date as date) as return_date,
        cast(return_type as varchar(30)) as return_type,
        cast(return_kg as numeric(10,3)) as return_kg,
        cast(credit_value as numeric(10,2)) as credit_value,
        cast(reason as varchar(150)) as reason,
        cast(disposition as varchar(50)) as disposition,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
