-- Singular test: Verify that all production batches have a positive dry substrate weight
select
    batch_id,
    dry_substrate_kg
from {{ ref('fact_production_batches') }}
where dry_substrate_kg <= 0
