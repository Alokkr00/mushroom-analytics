-- Singular test: Verify accepted harvest weight never exceeds gross harvested weight
select
    harvest_id,
    gross_harvested_kg,
    accepted_weight_kg
from {{ ref('fact_harvest') }}
where accepted_weight_kg > gross_harvested_kg
