# MycoMetrics Consolidated Enterprise Data Dictionary

**Document Version:** 2.0.0  
**Project:** FungiFlow Organics Analytics Warehouse  
**Author:** Alok Kumar (Freelance Data Analyst & Analytics Engineering Consultant)  
**Classification:** Operational Data Dictionary Standard  

---

## 1. Schema Organization & Architectural Tiers

The MycoMetrics Data Warehouse is structured across five distinct schema tiers in a Medallion pattern:

```
[Operational CSVs] ──► [raw] (Bronze) ──► [analytics_staging] (Silver)
                                                    │
                                                    ▼
                                       [analytics_intermediate] (Silver+)
                                                    │
                                                    ▼
                                       [analytics_analytics] (Gold / Marts)
                                       ├── 7 Conformed Dimensions (dim_*)
                                       ├── 6 Operational Facts (fact_*)
                                       └── 5 Analytical Marts (mart_*)
```

- **`raw`**: Immutable raw ingestion tier preserving source fidelity, stamped with technical metadata.
- **`analytics_staging`**: Cleansed, typed, normalized 1-to-1 representations of raw source tables.
- **`analytics_intermediate`**: Business-logic joins, yield aggregations, and financial reconciliations.
- **`analytics_analytics`**: Kimball star schema containing conformed dimensions, transactional facts, and reporting marts.
- **`audit`**: Pipeline operational logs, run timestamps, row watermarks, and data quality issue exceptions.

---

## 2. Conformed Dimensional Model (`analytics_analytics.dim_*`)

All dimensions are modeled under **Slowly Changing Dimension (SCD) Type 1** (overwrite on change) given current early-stage operational scope.

---

### 2.1 `dim_date`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per calendar day.
- **Primary Key:** `date_key` (`INTEGER`)
- **Row Count:** 214 rows (spanning 2024-05-01 to 2024-11-30).
- **Business Purpose:** Central conformed calendar dimension for time intelligence, trend analysis, and cohort aggregation.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `date_key` | `INTEGER` | NO | PK | Integer surrogate key in `YYYYMMDD` format. | `20240501` |
| `calendar_date` | `DATE` | NO | - | Gregorian calendar date (`YYYY-MM-DD`). | `2024-05-01` |
| `day_of_month` | `INTEGER` | NO | - | Numeric day of the month (1–31). | `1` |
| `day_of_week_num` | `INTEGER` | NO | - | ISO day of week index (1 = Monday, 7 = Sunday). | `3` |
| `day_of_week_name`| `VARCHAR(15)` | NO | - | Full English day name. | `Wednesday` |
| `is_weekend` | `BOOLEAN` | NO | - | Boolean flag: true if Saturday or Sunday. | `false` |
| `week_of_year` | `INTEGER` | NO | - | ISO calendar week number (1–53). | `18` |
| `month_number` | `INTEGER` | NO | - | Calendar month integer (1–12). | `5` |
| `month_name` | `VARCHAR(15)` | NO | - | Full English month name. | `May` |
| `year_month` | `VARCHAR(7)` | NO | - | Reporting standard monthly period string (`YYYY-MM`). | `2024-05` |
| `quarter_number` | `INTEGER` | NO | - | Calendar quarter index (1–4). | `2` |
| `year_number` | `INTEGER` | NO | - | Four-digit calendar year. | `2024` |

---

### 2.2 `dim_mushroom`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per cultivated fungal species.
- **Primary Key:** `mushroom_id` (`VARCHAR(10)`)
- **Row Count:** 3 rows (`MSH-01`, `MSH-02`, `MSH-03`).
- **Business Purpose:** Master biological taxonomy and baseline performance parameters.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `mushroom_id` | `VARCHAR(10)` | NO | PK | Unique biological variety code. | `MSH-01` |
| `mushroom_common_name` | `VARCHAR(50)` | NO | - | Commercial trade name. | `Pearl Oyster` |
| `scientific_name` | `VARCHAR(100)` | NO | - | Botanical Latin binomial name. | `Pleurotus ostreatus` |
| `substrate_formula` | `VARCHAR(150)` | NO | - | Standard substrate formulation recipe. | `Pasteurized Wheat Straw + 10% Wheat Bran` |
| `incubation_days_min` | `INTEGER` | NO | - | Minimum expected spawn-run colonization days. | `18` |
| `incubation_days_max` | `INTEGER` | NO | - | Maximum expected spawn-run colonization days. | `22` |
| `biological_efficiency_min` | `NUMERIC(4,2)` | NO | - | Lower bound of expected BE ratio ($\text{yield} / \text{dry substrate}$). | `0.75` |
| `biological_efficiency_max` | `NUMERIC(4,2)` | NO | - | Upper bound of expected BE ratio. | `1.10` |
| `standard_shelf_life_days` | `INTEGER` | NO | - | Post-harvest usable cold-storage shelf life in days. | `5` |
| `spawn_rate_ratio` | `NUMERIC(4,3)` | NO | - | Inoculation ratio by weight ($\text{spawn} / \text{dry substrate}$). | `0.100` |

---

### 2.3 `dim_product`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per finished goods sellable SKU.
- **Primary Key:** `product_id` (`VARCHAR(10)`)
- **Row Count:** 13 rows.
- **Business Purpose:** Commercial packaging catalog, pack weights, grades, and list prices.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `product_id` | `VARCHAR(10)` | NO | PK | Unique finished product SKU identifier. | `PRD-001` |
| `sku_code` | `VARCHAR(30)` | NO | - | Structured alphanumeric code. | `MSH-01-WHL-01KG` |
| `product_name` | `VARCHAR(100)` | NO | - | Full commercial product description. | `Pearl Oyster Bulk Wholesale Crate 1 kg` |
| `mushroom_id` | `VARCHAR(10)` | NO | FK | Foreign key referencing `dim_mushroom`. | `MSH-01` |
| `mushroom_common_name` | `VARCHAR(50)` | NO | - | De-normalized mushroom common name. | `Pearl Oyster` |
| `package_format` | `VARCHAR(40)` | NO | - | Packaging type: `Bulk Crate`, `Brown Bag`, `Clamshell Punnet`. | `Bulk Crate` |
| `unit_weight_kg` | `NUMERIC(6,3)` | NO | - | Nominal packaged weight in kilograms. | `1.000` |
| `quality_grade` | `VARCHAR(20)` | NO | - | Quality tier (`Grade A`, `Grade B`). | `Grade A` |
| `standard_selling_price`| `NUMERIC(10,2)`| NO | - | Standard wholesale/retail list price (USD). | `16.00` |
| `is_active` | `BOOLEAN` | NO | - | Active product availability flag. | `true` |

---

### 2.4 `dim_customer`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per customer account.
- **Primary Key:** `customer_id` (`VARCHAR(10)`)
- **Row Count:** 20 rows.
- **Business Purpose:** Customer master with pre-calculated lifetime value (LTV), order frequency, and tenure attributes.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `customer_id` | `VARCHAR(10)` | NO | PK | Unique customer account number. | `CUS-001` |
| `customer_name` | `VARCHAR(100)` | NO | - | Trading name or commercial moniker. | `Sage & Ember Restaurant` |
| `customer_segment` | `VARCHAR(30)` | NO | - | Channel: `Restaurant`, `Boutique Grocer`, `Farmers Market`, `Direct to Consumer`. | `Restaurant` |
| `delivery_route_zone` | `VARCHAR(30)` | NO | - | Geographic logistics zone (`Downtown`, `North Metro`, `West Suburbs`). | `Downtown Core` |
| `payment_terms_days` | `INTEGER` | NO | - | Standard net payment window (`0`, `7`, `14`, `30`). | `14` |
| `preferred_variety_id` | `VARCHAR(10)` | YES | FK | Primary mushroom variety preferred by customer. | `MSH-01` |
| `acquisition_date` | `DATE` | NO | - | Date of initial commercial onboarding. | `2024-05-01` |
| `is_active` | `BOOLEAN` | NO | - | Account active status flag. | `true` |
| `total_completed_orders`| `INTEGER` | NO | - | Count of completed sales transactions. | `7` |
| `lifetime_net_revenue` | `NUMERIC(12,2)`| NO | - | Total net recognized revenue generated to date. | `1219.00` |
| `lifetime_fulfilled_kg`| `NUMERIC(10,3)`| NO | - | Total product mass delivered in kilograms. | `74.000` |
| `average_order_value` | `NUMERIC(10,2)`| NO | - | Mean revenue per completed order ($\text{LTV} / \text{orders}$). | `174.14` |
| `is_repeat_customer` | `BOOLEAN` | NO | - | True if `total_completed_orders >= 2`. | `true` |
| `customer_tenure_days` | `INTEGER` | NO | - | Elapsed days from acquisition to reference date. | `213` |

---

### 2.5 `dim_supplier`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per raw material vendor.
- **Primary Key:** `supplier_id` (`VARCHAR(10)`)
- **Row Count:** 10 rows.
- **Business Purpose:** Vendor master for spawn, substrate ingredients, packaging, and facility consumables.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `supplier_id` | `VARCHAR(10)` | NO | PK | Unique supplier code. | `SUP-001` |
| `supplier_name` | `VARCHAR(100)` | NO | - | Business trading name. | `Cascadia Spawn Laboratories` |
| `material_category` | `VARCHAR(50)` | NO | - | Primary commodity provided (`Spawn`, `Substrate`, `Packaging`, `Equipment`). | `Grain Spawn` |
| `lead_days_min` | `INTEGER` | NO | - | Minimum lead time in days. | `14` |
| `lead_days_max` | `INTEGER` | NO | - | Maximum lead time in days. | `21` |
| `payment_terms_days` | `INTEGER` | NO | - | Credit payment terms (`15`, `30`, `60`). | `30` |

---

### 2.6 `dim_expense_category`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per accounting expense classification.
- **Primary Key:** `category_id` (`VARCHAR(10)`)
- **Row Count:** 14 rows.
- **Business Purpose:** Standardized chart of accounts for managerial accounting.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `category_id` | `VARCHAR(10)` | NO | PK | Unique expense category code. | `EXP-CAT-01` |
| `category_name` | `VARCHAR(80)` | NO | - | Accounting line name. | `Substrate Raw Materials` |
| `cost_behavior` | `VARCHAR(20)` | NO | - | Managerial classification (`Variable`, `Fixed`, `Semi-Variable`). | `Variable` |
| `financial_statement_section` | `VARCHAR(40)` | NO | - | Income statement section: `COGS`, `Facility Overhead`, `SG&A`, `Logistics`. | `Cost of Goods Sold` |

---

### 2.7 `dim_location`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per physical room or zone in the cultivation facility.
- **Primary Key:** `location_id` (`VARCHAR(10)`)
- **Row Count:** 5 rows.
- **Business Purpose:** Physical facility footprint and capacity tracking.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `location_id` | `VARCHAR(10)` | NO | PK | Facility zone identifier. | `LOC-01` |
| `location_name` | `VARCHAR(50)` | NO | - | Descriptive room moniker. | `Incubation Room A` |
| `max_capacity_blocks` | `INTEGER` | NO | - | Maximum substrate blocks accommodating zone. | `400` |
| `is_temperature_controlled` | `BOOLEAN` | NO | - | True if zone features automated HVAC/humidity control. | `true` |

---

## 3. Enterprise Fact Tables (`analytics_analytics.fact_*`)

---

### 3.1 `fact_production_batches`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per inoculated cultivation batch.
- **Primary Key:** `batch_id` (`VARCHAR(10)`)
- **Row Count:** 31 completed batches.
- **Business Purpose:** Comprehensive lifecycle tracking from substrate mixing to final chamber turnover.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `batch_id` | `VARCHAR(10)` | NO | PK | Unique batch tracking number. | `BAT-00001` |
| `mushroom_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_mushroom`. | `MSH-01` |
| `location_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_location` (fruiting room). | `LOC-03` |
| `batch_start_date` | `DATE` | NO | - | Inoculation / substrate preparation date. | `2024-05-01` |
| `transfer_to_fruiting_date`| `DATE` | NO | - | Transfer date from incubation to fruiting chamber. | `2024-05-20` |
| `first_harvest_date` | `DATE` | YES | - | Date of initial Flush 1 harvest. | `2024-05-27` |
| `last_harvest_date` | `DATE` | YES | - | Date of final flush harvest before block dump. | `2024-06-18` |
| `planned_blocks_count` | `INTEGER` | NO | - | Number of substrate blocks inoculated. | `30` |
| `dry_substrate_kg` | `NUMERIC(10,3)`| NO | - | Total dry base material weight in kilograms. | `75.000` |
| `spawn_kg` | `NUMERIC(8,3)` | NO | - | Total grain spawn weight utilized in kilograms. | `7.500` |
| `target_yield_kg` | `NUMERIC(10,3)`| NO | - | Expected fresh harvest yield based on baseline BE. | `67.500` |
| `direct_material_cost` | `NUMERIC(10,2)`| NO | - | Sum of dry substrate and spawn purchase cost. | `72.50` |
| `total_flushes_recorded`| `INTEGER` | NO | - | Total flush harvest cycles logged. | `3` |
| `total_gross_harvested_kg`| `NUMERIC(10,3)`| NO | - | Total fresh weight harvested across all flushes. | `71.200` |
| `total_accepted_harvest_kg`| `NUMERIC(10,3)`| NO | - | Marketable fresh harvest weight (Grade A + B). | `68.500` |
| `total_rejected_harvest_kg`| `NUMERIC(10,3)`| NO | - | Substandard / contaminated harvest discarded. | `2.700` |
| `total_harvest_labor_hours`| `NUMERIC(8,2)` | NO | - | Total hours spent harvesting and trimming. | `9.50` |
| `rejection_rate_pct` | `NUMERIC(5,2)` | NO | - | Rejected harvest as % of gross ($\text{rejected} / \text{gross} \times 100$). | `3.79` |
| `biological_efficiency_pct`| `NUMERIC(6,2)` | NO | - | Realized BE ($\text{accepted kg} / \text{dry substrate kg} \times 100$). | `91.33` |
| `target_achievement_pct`| `NUMERIC(6,2)` | NO | - | Yield attainment ($\text{accepted kg} / \text{target yield kg} \times 100$). | `101.48` |
| `cycle_duration_days` | `INTEGER` | NO | - | Total days elapsed from start to last harvest. | `48` |
| `direct_material_cost_per_kg`| `NUMERIC(8,2)`| NO | - | Material cost per accepted kg ($\text{cost} / \text{accepted kg}$). | `1.06` |
| `batch_status` | `VARCHAR(20)` | NO | - | Operational state: `COMPLETED`, `CONTAMINATED`. | `COMPLETED` |
| `is_stress_event` | `BOOLEAN` | NO | - | True if batch suffered environmental stress or contamination. | `false` |

---

### 3.2 `fact_harvest`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per flush harvest event.
- **Primary Key:** `harvest_id` (`VARCHAR(10)`)
- **Row Count:** 45 records.
- **Business Purpose:** Granular flush-by-flush yield, labor, and rejection tracking.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `harvest_id` | `VARCHAR(10)` | NO | PK | Unique harvest record number. | `HRV-00001` |
| `batch_id` | `VARCHAR(10)` | NO | FK | Reference to parent `fact_production_batches`. | `BAT-00001` |
| `mushroom_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_mushroom`. | `MSH-01` |
| `location_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_location` (fruiting room). | `LOC-03` |
| `harvest_date` | `DATE` | NO | - | Date harvest was pulled from fruiting chamber. | `2024-05-27` |
| `flush_number` | `INTEGER` | NO | - | Sequential flush index (`1`, `2`, `3`). | `1` |
| `gross_harvested_kg` | `NUMERIC(8,3)` | NO | - | Fresh weight harvested before trimming. | `38.200` |
| `accepted_weight_kg` | `NUMERIC(8,3)` | NO | - | Marketable yield graded and moved to cold storage. | `37.000` |
| `rejected_weight_kg` | `NUMERIC(8,3)` | NO | - | Damaged, deformed, or bacterial-blotch mass discarded. | `1.200` |
| `rejection_rate_pct` | `NUMERIC(5,2)` | NO | - | Percentage discarded ($\text{rejected} / \text{gross} \times 100$). | `3.14` |
| `rejection_reason` | `VARCHAR(100)` | YES | - | Primary defect: `Bacterial Blotch`, `Deformed Caps`, `Spore Drop`. | `Minor Cap Cracking` |
| `labor_hours` | `NUMERIC(6,2)` | NO | - | Labor hours dedicated to picking and sorting flush. | `4.50` |

---

### 3.3 `fact_sales`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per ordered line item on a customer invoice.
- **Primary Key:** `order_line_id` (`VARCHAR(15)`)
- **Row Count:** 112 lines.
- **Business Purpose:** Commercial revenue recognition, volume fulfillment, returns, and gross profit.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `order_line_id` | `VARCHAR(15)` | NO | PK | Unique order line item number. | `ORD-00001-01` |
| `order_id` | `VARCHAR(10)` | NO | - | Parent sales order number. | `ORD-00001` |
| `customer_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_customer`. | `CUS-001` |
| `product_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_product`. | `PRD-001` |
| `mushroom_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_mushroom`. | `MSH-01` |
| `lot_id` | `VARCHAR(15)` | NO | - | Inventory batch tracking lot code. | `LOT-20240527-01` |
| `order_date` | `DATE` | NO | - | Date order was placed by customer. | `2024-05-28` |
| `requested_delivery_date`| `DATE` | NO | - | Date customer requested fulfillment. | `2024-05-29` |
| `actual_delivery_date` | `DATE` | YES | - | Actual delivery completion timestamp. | `2024-05-29` |
| `sales_channel` | `VARCHAR(30)` | NO | - | Channel: `Wholesale Direct`, `Farmers Market`, `Online Store`. | `Wholesale Direct` |
| `order_status` | `VARCHAR(20)` | NO | - | State: `DELIVERED`, `CANCELLED`, `PARTIAL`. | `DELIVERED` |
| `payment_status` | `VARCHAR(20)` | NO | - | Financial state: `PAID`, `PENDING`, `OVERDUE`. | `PAID` |
| `quantity_ordered_kg` | `NUMERIC(8,3)` | NO | - | Mass requested on initial purchase order. | `15.000` |
| `quantity_fulfilled_kg`| `NUMERIC(8,3)` | NO | - | Mass physically delivered to customer. | `15.000` |
| `returned_kg` | `NUMERIC(8,3)` | NO | - | Mass returned post-delivery due to quality/spoilage. | `0.000` |
| `net_retained_quantity_kg`| `NUMERIC(8,3)`| NO | - | Mass retained by customer ($\text{fulfilled} - \text{returned}$). | `15.000` |
| `fulfillment_rate_pct` | `NUMERIC(5,2)` | NO | - | OTIF fulfillment ratio ($\text{fulfilled} / \text{ordered} \times 100$). | `100.00` |
| `unit_selling_price` | `NUMERIC(10,2)`| NO | - | Invoiced price per kilogram. | `16.00` |
| `gross_revenue` | `NUMERIC(10,2)`| NO | - | Total invoice before discounts ($\text{ordered} \times \text{price}$). | `240.00` |
| `discount_amount` | `NUMERIC(10,2)`| NO | - | Contractual wholesale or promotional deduction. | `0.00` |
| `net_revenue` | `NUMERIC(10,2)`| NO | - | Invoiced net revenue ($\text{gross} - \text{discount}$). | `240.00` |
| `credit_refund_amount` | `NUMERIC(10,2)`| NO | - | Credit memo issued for returned product. | `0.00` |
| `final_recognized_revenue`| `NUMERIC(10,2)`| NO | - | GAAP net revenue recognized ($\text{net revenue} - \text{credit refunds}$). | `240.00` |
| `estimated_cogs_amount`| `NUMERIC(10,2)`| NO | - | Estimated direct material and packing cost. | `40.80` |
| `gross_profit_amount` | `NUMERIC(10,2)`| NO | - | Recognized revenue minus estimated COGS. | `199.20` |
| `gross_margin_pct` | `NUMERIC(5,2)` | NO | - | Gross margin ratio ($\text{gross profit} / \text{recognized revenue} \times 100$). | `83.00` |

---

### 3.4 `fact_inventory_movements`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per physical stock movement (inbound, outbound, waste adjustment).
- **Primary Key:** `movement_id` (`VARCHAR(15)`)
- **Row Count:** 176 ledger entries.
- **Business Purpose:** Double-entry inventory balance tracking, FIFO shrinkage, and lot tracking.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `movement_id` | `VARCHAR(15)` | NO | PK | Unique inventory movement ledger entry. | `MOV-000001` |
| `lot_id` | `VARCHAR(15)` | NO | - | Traceability lot identifier. | `LOT-20240527-01` |
| `product_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_product`. | `PRD-001` |
| `mushroom_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_mushroom`. | `MSH-01` |
| `batch_id` | `VARCHAR(10)` | NO | FK | Originating production batch number. | `BAT-00001` |
| `harvest_id` | `VARCHAR(10)` | YES | FK | Reference to originating harvest event. | `HRV-00001` |
| `movement_date` | `DATE` | NO | - | Date movement was logged in warehouse. | `2024-05-27` |
| `movement_type` | `VARCHAR(30)` | NO | - | Action: `HARVEST_INBOUND`, `SALE_OUTBOUND`, `SPOILAGE_DISCARD`, `ADJUSTMENT`. | `HARVEST_INBOUND` |
| `signed_quantity_kg` | `NUMERIC(10,3)`| NO | - | Net change in stock mass (positive = in, negative = out). | `37.000` |
| `unit_cost` | `NUMERIC(10,2)`| NO | - | Valuation cost per kilogram. | `2.72` |
| `total_movement_value` | `NUMERIC(10,2)`| NO | - | Financial value ($\text{quantity} \times \text{unit cost}$). | `100.64` |
| `expiry_date` | `DATE` | YES | - | Shelf life expiration limit. | `2024-06-01` |
| `reason` | `VARCHAR(100)` | YES | - | Explanation for loss or adjustment. | `Initial packing from harvest` |
| `reference_transaction_id`| `VARCHAR(20)`| YES | - | Associated Order Line ID or Waste Event ID. | `HRV-00001` |

---

### 3.5 `fact_expenses`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per cash expenditure or operational invoice.
- **Primary Key:** `expense_id` (`VARCHAR(15)`)
- **Row Count:** 51 expense vouchers.
- **Business Purpose:** Facility overhead, utility bills, consumable purchases, and managerial OPEX.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `expense_id` | `VARCHAR(15)` | NO | PK | Unique expense transaction voucher number. | `EXP-00001` |
| `expense_date` | `DATE` | NO | - | Date invoice was incurred or payment cleared. | `2024-05-01` |
| `category_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_expense_category`. | `EXP-CAT-06` |
| `supplier_id` | `VARCHAR(10)` | YES | FK | Reference to `dim_supplier` if vendor transaction. | `SUP-007` |
| `batch_id` | `VARCHAR(10)` | YES | FK | Reference to `fact_production_batches` if direct cost. | `null` |
| `description` | `VARCHAR(200)` | NO | - | Accounting memo describing purchase. | `Facility Lease - Warehouse Zone May 2024` |
| `amount` | `NUMERIC(10,2)`| NO | - | Total dollar amount disbursed (USD). | `1200.00` |
| `currency` | `VARCHAR(5)` | NO | - | Transaction currency (ISO standard). | `USD` |
| `allocation_method` | `VARCHAR(30)` | NO | - | Allocation: `Direct Batch`, `Square Footage`, `Equal Monthly`. | `Facility Overhead` |

---

### 3.6 `fact_procurement`
- **Schema:** `analytics_analytics`
- **Granularity:** 1 row per purchase order placed with an external supplier.
- **Primary Key:** `purchase_id` (`VARCHAR(15)`)
- **Row Count:** 35 purchase orders.
- **Business Purpose:** Inbound raw material logistics, supplier OTIF tracking, and material unit costs.

| Column Name | Data Type | Nullable | PK / FK | Description & Business Definition | Example Value |
| :--- | :--- | :---: | :---: | :--- | :--- |
| `purchase_id` | `VARCHAR(15)` | NO | PK | Purchase order tracking number. | `PUR-00001` |
| `supplier_id` | `VARCHAR(10)` | NO | FK | Reference to `dim_supplier`. | `SUP-001` |
| `purchase_date` | `DATE` | NO | - | Date purchase order was submitted to vendor. | `2024-05-02` |
| `delivery_date` | `DATE` | YES | - | Date delivery was physically received at dock. | `2024-05-18` |
| `material_name` | `VARCHAR(100)` | NO | - | Description of commodity procured. | `M10-Pleurotus-Spawn-Bag-2.5kg` |
| `unit_of_measure` | `VARCHAR(20)` | NO | - | Packaging unit: `Bag`, `Bale`, `Pack`, `Pallet`. | `Bag` |
| `quantity_ordered` | `NUMERIC(10,2)`| NO | - | Units specified on purchase order. | `10.00` |
| `quantity_received` | `NUMERIC(10,2)`| NO | - | Units physically inspected and accepted. | `10.00` |
| `unit_price` | `NUMERIC(10,2)`| NO | - | Cost per unit pack. | `18.50` |
| `total_cost` | `NUMERIC(10,2)`| NO | - | Net invoice cost ($\text{quantity} \times \text{unit price}$). | `185.00` |
| `payment_status` | `VARCHAR(20)` | NO | - | Settlement status: `PAID`, `PENDING`. | `PAID` |
| `supplier_lead_time_days`| `INTEGER` | YES | - | Days elapsed from order submission to dock receipt. | `16` |

---

## 4. Reporting Marts (`analytics_analytics.mart_*`)

---

### 4.1 `mart_business_overview`
- **Granularity:** 1 row per calendar month (`year_month`).
- **Primary Audience:** Executive Leadership, Investors, Board of Directors.
- **Key Metrics:** Net Recognized Sales Revenue, Cost of Goods Sold (COGS), Gross Profit, Operating Expenses (OPEX), Operating Result (Net Income), Total Harvest Biomass (kg), Total Sales Biomass (kg).

### 4.2 `mart_production_performance`
- **Granularity:** 1 row per month per mushroom variety (`year_month`, `mushroom_common_name`).
- **Primary Audience:** Head of Cultivation, Farm Operations Manager.
- **Key Metrics:** Batches Started, Contaminated Batches Count, Blocks Inoculated, Gross Yield (kg), Accepted Yield (kg), Biological Efficiency (BE %), Rejection Rate (%), Mean Cycle Duration (days), Mean Material Cost per kg.

### 4.3 `mart_sales_profitability`
- **Granularity:** 1 row per month per customer segment per mushroom variety per channel (`year_month`, `customer_segment`, `mushroom_common_name`, `sales_channel`).
- **Primary Audience:** VP of Sales, Revenue Operations, Account Executives.
- **Key Metrics:** Orders Count, Mass Ordered (kg), Mass Fulfilled (kg), Mass Returned (kg), Net Retained (kg), Gross Invoiced Revenue, Net Revenue, Final Recognized Revenue, Realized Gross Margin (%), Effective ASP per kg ($/kg).

### 4.4 `mart_inventory_waste`
- **Granularity:** 1 row per month per loss stage per mushroom variety per reason code (`year_month`, `loss_stage`, `mushroom_common_name`, `reason_code`).
- **Primary Audience:** Inventory Controller, Quality Assurance Lead.
- **Key Metrics:** Loss Incidents Count, Total Lost Mass (kg), Total Financial Valuation of Loss ($).

### 4.5 `mart_customer_analysis`
- **Granularity:** 1 row per customer account (`customer_id`).
- **Primary Audience:** Customer Success Manager, Marketing Lead.
- **Key Metrics:** Completed Orders Count, Lifetime Delivered Mass (kg), Lifetime Net Revenue ($), Average Order Value (AOV), Revenue Share (% of Total), Cumulative Revenue Share (%), Revenue Rank, Pareto Tier (`Tier A: Top 80%`, `Tier B: Next 15%`, `Tier C: Bottom 5%`).

---

## 5. Technical Audit & Metadata Schema (`audit.*`)

Every table in the `raw` schema preserves an immutable technical audit metadata envelope:
- `_source_file`: Originating CSV file name.
- `_ingested_at`: UTC timestamp of extraction and loading.
- `_ingestion_run_id`: Unique batch execution ID (`RUN-YYYYMMDDHHMMSS-<hex>`).
- `_row_fingerprint`: Cryptographic SHA-256 hash of all non-technical row attributes.

### 5.1 `audit.pipeline_runs`
Records high-level pipeline execution telemetry:
`run_id`, `start_time`, `end_time`, `duration_seconds`, `status` (`SUCCESS` / `FAILED`), `total_files_processed`, `total_rows_extracted`, `total_rows_inserted`, `watermark_timestamp`, `error_message`.

### 5.2 `audit.data_quality_issues`
Captures pre-flight validation anomalies without breaking downstream processing unless critical:
`issue_id`, `run_id`, `detected_at`, `source_file`, `source_row_index`, `column_name`, `check_type` (`DUPLICATE_PRIMARY_KEY`, `NULL_VIOLATION`, `RANGE_VIOLATION`, `FOREIGN_KEY_ORPHAN`), `severity` (`WARNING`, `ERROR`, `CRITICAL`), `issue_description`, `bad_value`.
