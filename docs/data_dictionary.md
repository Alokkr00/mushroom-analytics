# Data Dictionary & Schema Specifications: MycoMetrics

This document defines the complete data dictionary for all operational and generated source tables utilized in the MycoMetrics platform.

Every dataset preserves an explicit lineage indicator (`source_type`) to distinguish real operational records (`'actual_source'`), synthetic simulation data (`'synthetic_demo'`), and controlled test anomalies (`'synthetic_demo_DQ_TEST'`).

---

## 1. Reference & Dimension Source Tables

### 1.1 `mushroom_varieties.csv`
- **Grain**: 1 row per biological mushroom species.
- **Primary Key**: `mushroom_id` (`VARCHAR(10)`)

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Unique biological variety code (e.g. MSH-01). | ID | `MSH-01` |
| `common_name` | String | `VARCHAR(50)` | NO | Commercial common trade name. | Text | `Pearl Oyster` |
| `scientific_name` | String | `VARCHAR(100)` | NO | Binomial botanical taxonomy. | Text | `Pleurotus ostreatus` |
| `substrate_formula` | String | `VARCHAR(150)` | NO | Standard raw substrate recipe. | Text | `Pasteurized Wheat Straw + 10% Wheat Bran` |
| `incubation_days_min` | Integer | `INTEGER` | NO | Minimum expected colonization days. | Days | `18` |
| `incubation_days_max` | Integer | `INTEGER` | NO | Maximum expected colonization days. | Days | `22` |
| `be_min` | Float | `NUMERIC(4,2)` | NO | Minimum biological efficiency ratio. | Decimal | `0.75` |
| `be_max` | Float | `NUMERIC(4,2)` | NO | Maximum biological efficiency ratio. | Decimal | `1.10` |
| `shelf_life_days` | Integer | `INTEGER` | NO | Post-harvest usable cold-storage shelf life. | Days | `5` |
| `source_type` | String | `VARCHAR(30)` | NO | Data provenance tag. | Enum | `synthetic_demo` |
| `created_at` | Timestamp | `TIMESTAMP WITH TIME ZONE` | NO | ISO 8601 record generation timestamp. | UTC | `2024-05-01T00:00:00Z` |

---

### 1.2 `products.csv`
- **Grain**: 1 row per finished goods sellable SKU.
- **Primary Key**: `product_id` (`VARCHAR(10)`)
- **Foreign Key**: `mushroom_id` -> `mushroom_varieties.mushroom_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `product_id` | String | `VARCHAR(10)` | NO | Unique finished product SKU identifier. | ID | `PRD-001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | FK referencing `mushroom_varieties`. | FK | `MSH-01` |
| `sku_code` | String | `VARCHAR(30)` | NO | Human-readable SKU code. | Text | `MSH-01-WHL-01KG` |
| `product_name` | String | `VARCHAR(100)` | NO | Full commercial product title. | Text | `Pearl Oyster Bulk Wholesale Crate 1 kg` |
| `package_format` | String | `VARCHAR(40)` | NO | Container format: Bulk Crate, Clamshell, etc. | Text | `Bulk Crate` |
| `unit_weight_kg` | Float | `NUMERIC(6,3)` | NO | Net fresh weight in kilograms per unit pack. | kg | `1.000` |
| `grade` | String | `VARCHAR(20)` | NO | Quality classification (`Grade A`, `Grade B`). | Text | `Grade A` |
| `standard_selling_price` | Float | `NUMERIC(10,2)` | NO | Standard wholesale/retail list price. | USD ($) | `16.00` |
| `active_status` | Boolean | `BOOLEAN` | NO | Flag indicating SKU is currently available. | Bool | `true` |
| `source_type` | String | `VARCHAR(30)` | NO | Data provenance tag. | Enum | `synthetic_demo` |
| `created_at` | Timestamp | `TIMESTAMP WITH TIME ZONE` | NO | Record creation timestamp. | UTC | `2024-05-01T00:00:00Z` |

---

### 1.3 `customers.csv`
- **Grain**: 1 row per customer account.
- **Primary Key**: `customer_id` (`VARCHAR(10)`)

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `customer_id` | String | `VARCHAR(10)` | NO | Unique customer account number. | ID | `CUS-001` |
| `customer_name` | String | `VARCHAR(100)` | NO | Commercial name or anonymized moniker. | Text | `Sage & Ember Restaurant` |
| `customer_segment` | String | `VARCHAR(30)` | NO | Segment: Restaurant, Boutique Grocer, Market, D2C. | Text | `Restaurant` |
| `delivery_route_zone` | String | `VARCHAR(20)` | NO | Logistical delivery cluster (Zone A, B, C). | Text | `Zone A` |
| `payment_terms_days` | Integer | `INTEGER` | NO | Net credit payment window in days. | Days | `14` |
| `acquisition_date` | Date | `DATE` | NO | Date customer placed first order or registered. | YYYY-MM-DD | `2024-05-05` |
| `is_active` | Boolean | `BOOLEAN` | NO | Account active status flag. | Bool | `true` |
| `source_type` | String | `VARCHAR(30)` | NO | Data provenance tag. | Enum | `synthetic_demo` |

---

### 1.4 `suppliers.csv`
- **Grain**: 1 row per vendor.
- **Primary Key**: `supplier_id` (`VARCHAR(10)`)

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `supplier_id` | String | `VARCHAR(10)` | NO | Unique vendor identifier. | ID | `SUP-01` |
| `name` | String | `VARCHAR(100)` | NO | Vendor trading name. | Text | `MycoSpawn Labs` |
| `category` | String | `VARCHAR(50)` | NO | Primary supply category (Spawn, Substrate, Rent). | Text | `Grain Spawn` |
| `lead_days_min` | Integer | `INTEGER` | NO | Minimum historical delivery lead time. | Days | `3` |
| `lead_days_max` | Integer | `INTEGER` | NO | Maximum historical delivery lead time. | Days | `6` |
| `payment_terms` | Integer | `INTEGER` | NO | Standard credit terms in days. | Days | `30` |

---

### 1.5 `locations.csv`
- **Grain**: 1 row per physical room or zone within the facility.
- **Primary Key**: `location_id` (`VARCHAR(10)`)

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `location_id` | String | `VARCHAR(10)` | NO | Unique zone code. | ID | `LOC-01` |
| `name` | String | `VARCHAR(50)` | NO | Descriptive room name. | Text | `Grow Room A` |
| `capacity_blocks` | Integer | `INTEGER` | NO | Maximum block capacity on shelving racks. | Count | `200` |
| `temp_controlled` | Boolean | `BOOLEAN` | NO | Indicates HVAC / environmental cooling. | Bool | `true` |

---

### 1.6 `expense_categories.csv`
- **Grain**: 1 row per financial expense classification.
- **Primary Key**: `category_id` (`VARCHAR(10)`)

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `category_id` | String | `VARCHAR(10)` | NO | Unique expense classification code. | ID | `EXP-01` |
| `name` | String | `VARCHAR(60)` | NO | Descriptive category title. | Text | `Grain Spawn Purchase` |
| `behavior` | String | `VARCHAR(30)` | NO | Direct Production, Variable Operating, Fixed Overhead. | Enum | `Direct Production` |
| `fs_section` | String | `VARCHAR(30)` | NO | Financial statement category: COGS or Operating Expense. | Enum | `COGS` |

---

## 2. Operational & Transactional Fact Tables

### 2.1 `production_batches.csv`
- **Grain**: 1 row per formulated substrate batch.
- **Primary Key**: `batch_id` (`VARCHAR(15)`)
- **Foreign Keys**: `mushroom_id` -> `mushroom_varieties.mushroom_id`, `growing_room_id` -> `locations.location_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `batch_id` | String | `VARCHAR(15)` | NO | Unique batch serial number. | ID | `BAT-00001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Cultivated variety key. | FK | `MSH-01` |
| `mushroom_variety` | String | `VARCHAR(50)` | NO | Denormalized variety trade name. | Text | `Pearl Oyster` |
| `substrate_formula` | String | `VARCHAR(150)` | NO | Textual description of substrate recipe. | Text | `Pasteurized Wheat Straw + 10% Wheat Bran` |
| `planned_blocks_count`| Integer | `INTEGER` | NO | Total fruiting bags/blocks inoculated. | Count | `40` |
| `dry_substrate_kg` | Float | `NUMERIC(10,3)` | NO | Dry weight of substrate prior to hydration. | kg | `40.000` |
| `water_liters_added` | Float | `NUMERIC(10,1)` | NO | Hydration liquid volume added. | Liters | `60.0` |
| `spawn_kg` | Float | `NUMERIC(8,3)` | NO | Mass of sterilized grain spawn inoculated. | kg | `4.000` |
| `batch_start_date` | Date | `DATE` | NO* | Inoculation start date (nullable only in DQ test anomaly). | YYYY-MM-DD | `2024-05-02` |
| `transfer_to_fruiting_date`| Date | `DATE` | YES | Date transferred to fruiting room upon colonization. | YYYY-MM-DD | `2024-05-22` |
| `growing_room_id` | String | `VARCHAR(10)` | NO | Assigned fruiting room location. | FK | `LOC-01` |
| `expected_first_harvest_date`| Date | `DATE` | YES | Planned target date for Flush 1. | YYYY-MM-DD | `2024-05-28` |
| `target_yield_kg` | Float | `NUMERIC(10,3)` | NO | Theoretical planned target yield. | kg | `37.000` |
| `direct_material_cost` | Float | `NUMERIC(10,2)` | NO | Substrate + spawn + bag consumable cost. | USD ($) | `88.50` |
| `batch_status` | String | `VARCHAR(20)` | NO | Status: `COMPLETED`, `CONTAMINATED`, `IN_PROGRESS`. | Text | `COMPLETED` |
| `is_stress_event` | Boolean | `BOOLEAN` | NO | Flag indicating intentional environmental stress test. | Bool | `false` |
| `notes` | String | `TEXT` | YES | Operational clipboard log observations. | Text | `Normal incubation run` |
| `source_type` | String | `VARCHAR(30)` | NO | Lineage tag (`synthetic_demo` or `synthetic_demo_DQ_TEST`). | Enum | `synthetic_demo` |

---

### 2.2 `harvest_records.csv`
- **Grain**: 1 row per harvest flush event per batch.
- **Primary Key**: `harvest_id` (`VARCHAR(15)`)
- **Foreign Key**: `batch_id` -> `production_batches.batch_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `harvest_id` | String | `VARCHAR(15)` | NO | Unique harvest event number. | ID | `HRV-00001` |
| `batch_id` | String | `VARCHAR(15)` | NO | Parent production batch. | FK | `BAT-00001` |
| `harvest_date` | Date | `DATE` | NO | Date mushrooms were cut from blocks. | YYYY-MM-DD | `2024-05-28` |
| `flush_number` | Integer | `INTEGER` | NO | Production wave number (`1` or `2`). | Integer | `1` |
| `gross_harvested_kg` | Float | `NUMERIC(10,3)` | NO | Total unsorted cut weight. | kg | `25.500` |
| `accepted_weight_kg` | Float | `NUMERIC(10,3)` | NO | Marketable weight meeting quality specs. | kg | `24.400` |
| `rejected_weight_kg` | Float | `NUMERIC(10,3)` | NO | Discarded harvest floor defects. | kg | `1.100` |
| `rejection_reason` | String | `VARCHAR(100)` | YES | Reason code for harvest floor rejection. | Text | `Bacterial blotch` |
| `labor_hours` | Float | `NUMERIC(6,2)` | NO | Man-hours expended picking and grading. | Hours | `2.50` |
| `source_type` | String | `VARCHAR(30)` | NO | Lineage tag. | Enum | `synthetic_demo` |

*Reconciliation Invariant*: `gross_harvested_kg = accepted_weight_kg + rejected_weight_kg`.

---

### 2.3 `inventory_movements.csv`
- **Grain**: 1 row per stock change transaction.
- **Primary Key**: `movement_id` (`VARCHAR(15)`)
- **Foreign Keys**: `lot_id` -> `lot_id`, `product_id` -> `products.product_id`, `batch_id` -> `production_batches.batch_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `movement_id` | String | `VARCHAR(15)` | NO | Unique stock transaction identifier. | ID | `MOV-00001` |
| `lot_id` | String | `VARCHAR(15)` | NO | Cold-storage tracking lot number. | ID | `LOT-00001` |
| `product_id` | String | `VARCHAR(10)` | NO | Finished goods SKU identifier. | FK | `PRD-001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Biological variety key. | FK | `MSH-01` |
| `batch_id` | String | `VARCHAR(15)` | YES | Parent batch (if traceable). | FK | `BAT-00001` |
| `harvest_id` | String | `VARCHAR(15)` | YES | Inbound harvest event (for receipts). | FK | `HRV-00001` |
| `movement_date` | Date | `DATE` | NO | Date transaction physically occurred. | YYYY-MM-DD | `2024-05-28` |
| `movement_type` | String | `VARCHAR(30)` | NO | `HARVEST_IN`, `SALE_OUT`, `WASTE_OUT`, `RETURN_DISCARDED`. | Enum | `HARVEST_IN` |
| `signed_quantity_kg` | Float | `NUMERIC(10,3)` | NO | Signed mass (+ for IN, - for OUT). | kg | `+24.400` |
| `unit_cost` | Float | `NUMERIC(10,4)` | NO | Unit valuation per kilogram. | USD / kg | `3.6270` |
| `total_movement_value`| Float | `NUMERIC(10,2)` | NO | Financial valuation of transaction (`signed_qty * unit_cost`). | USD ($) | `88.50` |
| `expiry_date` | Date | `DATE` | YES | Lot shelf-life expiry limit. | YYYY-MM-DD | `2024-06-02` |
| `reason` | String | `VARCHAR(150)` | YES | Context note or sales reference. | Text | `Fresh harvest receipt into cold storage` |
| `reference_transaction_id`| String | `VARCHAR(20)` | YES | Originating document ID (`harvest_id`, `line_id`, `waste_id`).| Ref | `HRV-00001` |

---

### 2.4 `sales_orders.csv`
- **Grain**: 1 row per commercial order header.
- **Primary Key**: `order_id` (`VARCHAR(15)`)
- **Foreign Key**: `customer_id` -> `customers.customer_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `order_id` | String | `VARCHAR(15)` | NO | Unique order reference code. | ID | `ORD-00001` |
| `customer_id` | String | `VARCHAR(10)` | NO | Purchasing customer account key. | FK | `CUS-001` |
| `order_date` | Date | `DATE` | NO | Inbound order booking date. | YYYY-MM-DD | `2024-05-29` |
| `requested_delivery_date`| Date | `DATE` | NO | Customer requested drop date. | YYYY-MM-DD | `2024-05-31` |
| `actual_delivery_date` | Date | `DATE` | YES | Actual confirmed drop-off date. | YYYY-MM-DD | `2024-05-31` |
| `order_status` | String | `VARCHAR(20)` | NO | `COMPLETED`, `CANCELLED`, `PENDING`. | Enum | `COMPLETED` |
| `payment_status` | String | `VARCHAR(20)` | NO | `PAID`, `OUTSTANDING`. | Enum | `PAID` |
| `sales_channel` | String | `VARCHAR(30)` | NO | Channel: Wholesale Direct, Market Direct, D2C. | Text | `Wholesale Direct` |

---

### 2.5 `sales_order_lines.csv`
- **Grain**: 1 row per product SKU line item on an order.
- **Primary Key**: `order_line_id` (`VARCHAR(15)`)
- **Foreign Keys**: `order_id` -> `sales_orders.order_id`, `product_id` -> `products.product_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `order_line_id` | String | `VARCHAR(15)` | NO | Unique line item identifier. | ID | `LIN-00001` |
| `order_id` | String | `VARCHAR(15)` | NO | Parent order key. | FK | `ORD-00001` |
| `product_id` | String | `VARCHAR(10)` | NO | SKU delivered. | FK | `PRD-001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Biological variety key. | FK | `MSH-01` |
| `lot_id` | String | `VARCHAR(15)` | NO | Originating inventory lot drained. | FK | `LOT-00001` |
| `quantity_ordered_kg`| Float | `NUMERIC(10,3)` | NO | Quantity requested by customer in kg. | kg | `5.000` |
| `quantity_fulfilled_kg`| Float | `NUMERIC(10,3)` | NO | Actual quantity dispatched and invoiced. | kg | `5.000` |
| `unit_of_measure` | String | `VARCHAR(10)` | NO | Standardized unit (`kg`). | Text | `kg` |
| `unit_selling_price`| Float | `NUMERIC(10,2)` | NO | Unit list price per kilogram. | USD ($) | `16.00` |
| `discount_amount` | Float | `NUMERIC(10,2)` | NO | Promotional or volume price concession. | USD ($) | `4.00` |
| `gross_revenue` | Float | `NUMERIC(10,2)` | NO | `quantity_fulfilled_kg * unit_selling_price`. | USD ($) | `80.00` |
| `net_revenue` | Float | `NUMERIC(10,2)` | NO | `gross_revenue - discount_amount`. | USD ($) | `76.00` |

---

### 2.6 `expenses.csv`
- **Grain**: 1 row per operational expenditure payment.
- **Primary Key**: `expense_id` (`VARCHAR(15)`)
- **Foreign Keys**: `expense_category_id` -> `expense_categories.category_id`, `supplier_id` -> `suppliers.supplier_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `expense_id` | String | `VARCHAR(15)` | NO | Unique expense voucher number. | ID | `EXP-00001` |
| `expense_date` | Date | `DATE` | NO | Incurred transaction date. | YYYY-MM-DD | `2024-05-01` |
| `expense_category_id`| String | `VARCHAR(10)` | NO | Chart-of-accounts classification key. | FK | `EXP-10` |
| `description` | String | `VARCHAR(150)` | NO | Explanatory note or invoice line description. | Text | `Facility lease - monthly rent` |
| `amount` | Float | `NUMERIC(10,2)` | NO | Outflow monetary value. | USD ($) | `1200.00` |
| `currency` | String | `VARCHAR(5)` | NO | Currency denomination. | ISO Code | `USD` |
| `supplier_id` | String | `VARCHAR(10)` | YES | Paid vendor (if applicable). | FK | `SUP-08` |
| `batch_id` | String | `VARCHAR(15)` | YES | Direct batch attribution (if applicable). | FK | `""` |
| `allocation_method` | String | `VARCHAR(30)` | NO | Fixed Monthly, Variable Period, Direct Batch. | Text | `Fixed Monthly` |

---

### 2.7 `purchases.csv`
- **Grain**: 1 row per procurement purchase order receipt.
- **Primary Key**: `purchase_id` (`VARCHAR(15)`)
- **Foreign Key**: `supplier_id` -> `suppliers.supplier_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `purchase_id` | String | `VARCHAR(15)` | NO | Purchase receipt serial number. | ID | `PUR-00001` |
| `supplier_id` | String | `VARCHAR(10)` | NO | Sourced vendor account key. | FK | `SUP-01` |
| `purchase_date` | Date | `DATE` | NO | Purchase order placement date. | YYYY-MM-DD | `2024-05-04` |
| `material_name` | String | `VARCHAR(100)` | NO | Material description. | Text | `Grain Spawn (Rye Berries, Sterilized)` |
| `unit_of_measure` | String | `VARCHAR(20)` | NO | Metric unit (kg, units, bales). | Text | `kg` |
| `quantity_ordered` | Float | `NUMERIC(10,2)` | NO | Quantity requested on PO. | Number | `4.50` |
| `quantity_received`| Float | `NUMERIC(10,2)` | NO | Quantity delivered and accepted. | Number | `4.50` |
| `unit_price` | Float | `NUMERIC(10,4)` | NO | Price per purchase unit. | USD ($) | `10.8500` |
| `total_cost` | Float | `NUMERIC(10,2)` | NO | Total invoiced purchase amount (`qty_received * unit_price`). | USD ($) | `48.83` |
| `delivery_date` | Date | `DATE` | YES | Date stock arrived on site. | YYYY-MM-DD | `2024-05-08` |
| `payment_status` | String | `VARCHAR(20)` | NO | `PAID` or `OUTSTANDING`. | Text | `PAID` |

---

### 2.8 `waste_events.csv`
- **Grain**: 1 row per post-harvest inventory loss or disposal incident.
- **Primary Key**: `waste_id` (`VARCHAR(15)`)
- **Foreign Keys**: `lot_id` -> `inventory_movements.lot_id`, `product_id` -> `products.product_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `waste_id` | String | `VARCHAR(15)` | NO | Unique disposal event identifier. | ID | `WST-00001` |
| `lot_id` | String | `VARCHAR(15)` | NO | Cold-storage lot written off. | FK | `LOT-00002` |
| `product_id` | String | `VARCHAR(10)` | NO | Product SKU written off. | FK | `PRD-001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Biological variety key. | FK | `MSH-01` |
| `waste_date` | Date | `DATE` | NO | Date stock was discarded/composted. | YYYY-MM-DD | `2024-06-03` |
| `waste_type` | String | `VARCHAR(30)` | NO | `COLD_STORAGE_SPOILAGE`, `PHYSICAL_DAMAGE`. | Enum | `COLD_STORAGE_SPOILAGE` |
| `waste_kg` | Float | `NUMERIC(10,3)` | NO | Mass discarded in kilograms. | kg | `2.400` |
| `estimated_unit_cost`| Float | `NUMERIC(10,4)`| NO | Cost valuation per kg. | USD / kg | `3.6270` |
| `estimated_waste_value`| Float | `NUMERIC(10,2)`| NO | Dollar write-off amount (`waste_kg * unit_cost`). | USD ($) | `8.70` |
| `reason_code` | String | `VARCHAR(150)` | NO | Operational investigation reason code. | Text | `Cold storage spoilage - shelf life exceeded` |
| `disposition` | String | `VARCHAR(30)` | NO | Physical outcome: `Composted`, `Discarded`. | Text | `Composted` |

---

### 2.9 `returns.csv`
- **Grain**: 1 row per customer delivery return / credit note.
- **Primary Key**: `return_id` (`VARCHAR(15)`)
- **Foreign Keys**: `original_order_line_id` -> `sales_order_lines.order_line_id`, `customer_id` -> `customers.customer_id`

| Column Name | Data Type | Physical DB Type | Nullable | Description / Business Rules | Unit / Format | Example Value |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| `return_id` | String | `VARCHAR(15)` | NO | Return credit note reference. | ID | `RET-00001` |
| `original_order_line_id`| String | `VARCHAR(15)` | NO | Originating sales order line returned. | FK | `LIN-00014` |
| `original_order_id`| String | `VARCHAR(15)` | NO | Originating sales order header. | FK | `ORD-00008` |
| `product_id` | String | `VARCHAR(10)` | NO | Product SKU returned. | FK | `PRD-001` |
| `mushroom_id` | String | `VARCHAR(10)` | NO | Biological variety key. | FK | `MSH-01` |
| `return_date` | Date | `DATE` | NO | Date return was reported/processed. | YYYY-MM-DD | `2024-06-18` |
| `return_type` | String | `VARCHAR(30)` | NO | `CUSTOMER_RETURN`. | Enum | `CUSTOMER_RETURN` |
| `return_kg` | Float | `NUMERIC(10,3)` | NO | Physical quantity returned in kg. | kg | `1.500` |
| `credit_value` | Float | `NUMERIC(10,2)` | NO | Dollar amount refunded/credited to customer. | USD ($) | `24.00` |
| `reason` | String | `VARCHAR(150)` | NO | Explanation for customer rejection. | Text | `Mushrooms degraded in transit - heat exposure` |
| `disposition` | String | `VARCHAR(50)` | NO | Disposition: Perishable goods immediately discarded. | Text | `Discarded - perishable goods` |

---

## 3. Data Warehouse Audit Envelope (`raw.*` metadata)

When raw files are loaded into PostgreSQL by the Python ingestion engine, four technical metadata columns are appended to every table:

| Technical Metadata Column | Physical DB Type | Description / Integrity Purpose |
| :--- | :--- | :--- |
| `_source_file` | `VARCHAR(255)` | Relative or absolute path of the source file from which the row was extracted. |
| `_ingested_at` | `TIMESTAMP WITH TIME ZONE` | System timestamp when the row was committed to the raw table. |
| `_ingestion_run_id` | `UUID` | Foreign key referencing the master execution batch in `audit.pipeline_runs`. |
| `_row_fingerprint` | `VARCHAR(64)` | SHA-256 hash computed across business key columns to guarantee idempotent loading. |
