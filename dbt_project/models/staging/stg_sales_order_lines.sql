with source as (
    select * from {{ source('raw', 'raw_sales_order_lines') }}
),

renamed as (
    select
        cast(order_line_id as varchar(15)) as order_line_id,
        cast(order_id as varchar(15)) as order_id,
        cast(product_id as varchar(10)) as product_id,
        cast(mushroom_id as varchar(10)) as mushroom_id,
        cast(lot_id as varchar(15)) as lot_id,
        cast(quantity_ordered_kg as numeric(10,3)) as quantity_ordered_kg,
        cast(quantity_fulfilled_kg as numeric(10,3)) as quantity_fulfilled_kg,
        cast(unit_of_measure as varchar(10)) as unit_of_measure,
        cast(unit_selling_price as numeric(10,2)) as unit_selling_price,
        cast(discount_amount as numeric(10,2)) as discount_amount,
        cast(gross_revenue as numeric(10,2)) as gross_revenue,
        cast(net_revenue as numeric(10,2)) as net_revenue,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
    -- Filter out impossible DQ test records where fulfilled > ordered
    where quantity_fulfilled_kg <= (quantity_ordered_kg + 0.001)
)

select * from renamed
