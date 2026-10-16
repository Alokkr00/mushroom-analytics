select
    mushroom_id,
    common_name as mushroom_common_name,
    scientific_name,
    substrate_formula,
    incubation_days_min,
    incubation_days_max,
    biological_efficiency_min,
    biological_efficiency_max,
    standard_shelf_life_days,
    spawn_rate_ratio
from {{ ref('stg_mushroom_varieties') }}
