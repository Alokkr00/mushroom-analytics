with source as (
    select * from {{ source('raw', 'raw_purchases') }}
),

deduped as (
    select
        *,
        row_number() over (
            partition by purchase_id
            order by _ingested_at desc, created_at desc
        ) as rn
    from source
),

renamed as (
    select
        cast(purchase_id as varchar(15)) as purchase_id,
        cast(supplier_id as varchar(10)) as supplier_id,
        cast(purchase_date as date) as purchase_date,
        cast(material_name as varchar(100)) as material_name,
        cast(unit_of_measure as varchar(20)) as unit_of_measure,
        cast(quantity_ordered as numeric(10,2)) as quantity_ordered,
        cast(quantity_received as numeric(10,2)) as quantity_received,
        cast(unit_price as numeric(10,4)) as unit_price,
        cast(total_cost as numeric(10,2)) as total_cost,
        cast(delivery_date as date) as delivery_date,
        cast(payment_status as varchar(20)) as payment_status,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from deduped
    where rn = 1
)

select * from renamed
