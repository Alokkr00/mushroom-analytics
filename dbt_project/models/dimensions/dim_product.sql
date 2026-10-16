select
    p.product_id,
    p.sku_code,
    p.product_name,
    p.mushroom_id,
    m.common_name as mushroom_common_name,
    p.package_format,
    p.unit_weight_kg,
    p.quality_grade,
    p.standard_selling_price,
    p.is_active
from {{ ref('stg_products') }} p
left join {{ ref('stg_mushroom_varieties') }} m on p.mushroom_id = m.mushroom_id
