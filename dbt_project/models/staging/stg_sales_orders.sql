with source as (
    select * from {{ source('raw', 'raw_sales_orders') }}
),

renamed as (
    select
        cast(order_id as varchar(15)) as order_id,
        cast(customer_id as varchar(10)) as customer_id,
        cast(order_date as date) as order_date,
        cast(requested_delivery_date as date) as requested_delivery_date,
        cast(actual_delivery_date as date) as actual_delivery_date,
        cast(order_status as varchar(20)) as order_status,
        cast(payment_status as varchar(20)) as payment_status,
        cast(sales_channel as varchar(30)) as sales_channel,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
