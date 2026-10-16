# Data Profiling & Quality Validation Report: MycoMetrics

## 1. Executive Summary

- **Source Data Directory**: `data\generated`
- **Total Datasets Inspected**: 15
- **Total Issues / Warnings**: 1

## 2. Dataset Volume & Completeness Profile

| Dataset Name | Rows | Columns | Null Cells | Primary Business Key |
| :--- | :---: | :---: | :---: | :--- |
| `customers.csv` | 20 | 10 | 0 | `customer_id` |
| `expense_categories.csv` | 14 | 6 | 0 | `category_id` |
| `expenses.csv` | 51 | 11 | 71 | `expense_id` |
| `harvest_records.csv` | 46 | 11 | 0 | `harvest_id` |
| `inventory_movements.csv` | 176 | 16 | 131 | `movement_id` |
| `locations.csv` | 5 | 6 | 0 | `location_id` |
| `mushroom_varieties.csv` | 3 | 24 | 0 | `mushroom_id` |
| `production_batches.csv` | 32 | 19 | 33 | `batch_id` |
| `products.csv` | 13 | 11 | 0 | `product_id` |
| `purchases.csv` | 37 | 13 | 0 | `purchase_id` |
| `returns.csv` | 3 | 14 | 0 | `return_id` |
| `sales_order_lines.csv` | 113 | 14 | 0 | `order_line_id` |
| `sales_orders.csv` | 75 | 10 | 0 | `order_id` |
| `suppliers.csv` | 10 | 8 | 0 | `supplier_id` |
| `waste_events.csv` | 16 | 14 | 0 | `waste_id` |

## 3. Structural & Relational Integrity Findings

| Severity | Table | Check | Details |
| :--- | :--- | :--- | :--- |
| **INFO** | `purchases` | Controlled DQ Test Detected | Detected 2 intentional duplicate/anomalous rows tagged for Case Study 8 |

## 4. Key Metric Distributions (Preliminary Bounds)

### Production Batches (`production_batches.csv`)
- **Total Batches**: 31
- **Substrate Dry Weight (kg)**: Mean = 39.68 kg, Min = 23.00 kg, Max = 58.00 kg
- **Contaminated Batches**: 0

### Harvest Performance (`harvest_records.csv`)
- **Total Gross Harvested Weight**: 739.03 kg
- **Total Accepted Weight**: 706.16 kg (95.6%)
- **Total Rejected Weight**: 32.87 kg (4.4%)

### Commercial Sales Performance (`sales_order_lines.csv`)
- **Total Net Revenue**: $7,989.76
- **Total Kilograms Fulfilled**: 393.31 kg
- **Average Selling Price**: $20.31 / kg
