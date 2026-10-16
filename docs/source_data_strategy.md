# Source Data Strategy & Generation Framework: MycoMetrics

## 1. Hybrid Data Strategy

To fulfill both goals—building a practical solution for a real-world early-stage business while demonstrating comprehensive data analyst competencies across complex patterns—MycoMetrics uses a **hybrid data strategy**:

```
                       DATA SOURCES
                            │
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
[Category A:         [Category B:         [Category C:
 Operational Data]    Synthetic Demo Data] Public Reference Data]
- Small real batch   - Parametric seed    - USDA wholesale mushroom
  logs (Month 1)       generator            price benchmarks
- Seed invoices      - 6 months scaling   - Food safety shelf-life
- Google Sheets      - Edge cases &         guidelines
                       stress tests
       │                    │                    │
       └────────────────────┼────────────────────┘
                            │
                            ▼
              [Provenance Tagging Engine]
           Every row tagged with `source_type`:
           - 'actual_source'
           - 'synthetic_demo'
           - 'public_dataset'
```

---

## 2. Provenance & Attribution Integrity

A core tenet of this project is **never to present simulated figures as verified financial performance of a real business**.

Every source dataset and transformed table preserves an explicit metadata lineage:
1. `source_type`: Enum string (`'actual_source'`, `'synthetic_demo'`, `'public_reference'`).
2. `created_at`: Timestamp of generation or original record entry.
3. `record_provenance_notes`: Explanatory note for synthetic injected edge cases (e.g., `"Injected contamination anomaly for Case Study 1 testing"`).

---

## 3. Parametric Synthetic Data Generator Architecture

The synthetic engine (`ingestion/data_generator.py`) is written in standard Python using NumPy and Pandas with a deterministic random seed (`seed=42`) for 100% reproducibility.

### Business Rules Enforced in the Generator:

1. **Chronological Plausibility**:
   - `purchase_date` < `batch_start_date`
   - `batch_start_date` < `transfer_to_fruiting_date` < `flush_1_harvest_date` < `flush_2_harvest_date`
   - `flush_1_harvest_date` <= `inventory_receipt_date` <= `order_date` <= `delivery_date`
   - `expiry_date` = `harvest_date` + `shelf_life_days` (Oyster: 5 days, Lion's Mane: 7 days, Shiitake: 10 days).
2. **Biological & Physical Bounds**:
   - Dry substrate weight per bag: 1.0 kg dry sawdust/straw + 1.5 kg water = 2.5 kg wet block.
   - Spawn inoculation rate: 8% - 12% of dry substrate weight.
   - Biological Efficiency:
     - Oyster: 70% to 110% over two flushes (Flush 1 = ~65%, Flush 2 = ~35%).
     - Lion's Mane: 55% to 80% over two flushes.
     - Shiitake: 45% to 65% over two flushes.
   - Rejection rate: 2% to 6% under normal conditions; spiked to 18-25% in specific controlled batches (e.g., humidity spike event) for case study testing.
3. **Referential Integrity**:
   - No harvest without a valid `batch_id`.
   - No order line without a valid `product_id` and existing `order_id`.
   - Inventory movements link to actual harvested `lot_id` and `batch_id`.
   - Waste write-offs reference eligible inventory batches and cannot exceed available stock.
   - Customer returns reference historical completed sales order lines.
4. **Economic Calibration**:
   - Realistic wholesale and retail pricing:
     - Oyster: \$14.00 - \$18.00 / kg wholesale; \$5.00 / 250g retail punnet (\$20.00 / kg equiv).
     - Lion's Mane: \$24.00 - \$30.00 / kg wholesale; \$8.00 / 200g retail punnet (\$40.00 / kg equiv).
     - Shiitake: \$22.00 - \$28.00 / kg wholesale; \$7.00 / 200g retail punnet (\$35.00 / kg equiv).
   - Realistic expense structure: Monthly rent (\$1,200), electricity (\$350-\$550 depending on cooling season), water (\$60), spawn purchases, substrate inputs, packaging, and commercial liability insurance.

---

## 4. Configurable Volume Scales

The generator provides two operational scales:
- **`scale="small"` (Default Development Mode)**:
  - 6 months of historical activity (e.g., May 1 to October 31).
  - ~35 production batches (~1,800 substrate blocks total).
  - ~65 harvest events across Flush 1 and 2.
  - ~150 sales orders and ~350 order lines.
  - ~20 active B2B & B2C customers.
  - Runs in under 3 seconds; perfect for fast CI/CD and local development.
- **`scale="full"` (Advanced Stress-Testing Mode)**:
  - 18 months of history, ~180 batches, ~1,500 orders, ~4,000 order lines.
  - Used for final comprehensive time-series and cohort analysis.
