select
    category_id,
    category_name,
    cost_behavior,
    financial_statement_section
from {{ ref('stg_expense_categories') }}
