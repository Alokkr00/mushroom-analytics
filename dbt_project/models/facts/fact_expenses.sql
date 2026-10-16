select
    expense_id,
    expense_date,
    expense_category_id as category_id,
    supplier_id,
    batch_id,
    description,
    amount,
    currency,
    allocation_method
from {{ ref('stg_expenses') }}
