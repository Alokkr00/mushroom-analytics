select
    location_id,
    location_name,
    max_capacity_blocks,
    is_temperature_controlled
from {{ ref('stg_locations') }}
