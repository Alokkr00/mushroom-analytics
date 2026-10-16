select
    supplier_id,
    supplier_name,
    material_category,
    lead_days_min,
    lead_days_max,
    payment_terms_days
from {{ ref('stg_suppliers') }}
