with source as (
    select * from {{ source('raw', 'raw_expenses') }}
),

renamed as (
    select
        cast(expense_id as varchar(15)) as expense_id,
        cast(expense_date as date) as expense_date,
        cast(expense_category_id as varchar(10)) as expense_category_id,
        cast(description as varchar(150)) as description,
        cast(amount as numeric(10,2)) as amount,
        cast(currency as varchar(5)) as currency,
        cast(nullif(supplier_id, '') as varchar(10)) as supplier_id,
        cast(nullif(batch_id, '') as varchar(15)) as batch_id,
        cast(allocation_method as varchar(30)) as allocation_method,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
