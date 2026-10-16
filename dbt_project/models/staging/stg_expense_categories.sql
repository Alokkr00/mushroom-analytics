with source as (
    select * from {{ source('raw', 'raw_expense_categories') }}
),

renamed as (
    select
        cast(category_id as varchar(10)) as category_id,
        cast(name as varchar(60)) as category_name,
        cast(behavior as varchar(30)) as cost_behavior,
        cast(fs_section as varchar(30)) as financial_statement_section,
        cast(source_type as varchar(30)) as source_type,
        cast(created_at as timestamp) as created_at
    from source
)

select * from renamed
