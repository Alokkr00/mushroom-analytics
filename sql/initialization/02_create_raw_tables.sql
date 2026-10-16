-- ============================================================================
-- 02_create_raw_tables.sql
-- Database: mycometrics
-- Schema: raw
-- Purpose: Define immutable raw source tables with technical metadata envelope.
-- Financial values use NUMERIC for precise currency math (no floating point errors).
-- ============================================================================

-- 1. Mushroom Varieties
DROP TABLE IF EXISTS raw.raw_mushroom_varieties CASCADE;
CREATE TABLE raw.raw_mushroom_varieties (
    mushroom_id                  VARCHAR(10) PRIMARY KEY,
    common_name                  VARCHAR(50) NOT NULL,
    scientific_name              VARCHAR(100) NOT NULL,
    substrate_formula            VARCHAR(150) NOT NULL,
    incubation_days_min          INTEGER NOT NULL,
    incubation_days_max          INTEGER NOT NULL,
    days_to_flush1_min           INTEGER NOT NULL,
    days_to_flush1_max           INTEGER NOT NULL,
    days_between_flushes_min     INTEGER NOT NULL,
    days_between_flushes_max     INTEGER NOT NULL,
    be_min                       NUMERIC(5,2) NOT NULL,
    be_max                       NUMERIC(5,2) NOT NULL,
    flush1_share_min             NUMERIC(5,2) NOT NULL,
    flush1_share_max             NUMERIC(5,2) NOT NULL,
    shelf_life_days              INTEGER NOT NULL,
    rejection_rate_normal_min    NUMERIC(5,3) NOT NULL,
    rejection_rate_normal_max    NUMERIC(5,3) NOT NULL,
    rejection_rate_stress_min    NUMERIC(5,3) NOT NULL,
    rejection_rate_stress_max    NUMERIC(5,3) NOT NULL,
    spawn_rate                   NUMERIC(5,3) NOT NULL,
    contamination_rate           NUMERIC(5,3) NOT NULL,
    introduced_month_offset      INTEGER NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    -- Audit Envelope
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 2. Locations
DROP TABLE IF EXISTS raw.raw_locations CASCADE;
CREATE TABLE raw.raw_locations (
    location_id                  VARCHAR(10) PRIMARY KEY,
    name                         VARCHAR(50) NOT NULL,
    capacity_blocks              INTEGER NOT NULL,
    temp_controlled              BOOLEAN NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 3. Expense Categories
DROP TABLE IF EXISTS raw.raw_expense_categories CASCADE;
CREATE TABLE raw.raw_expense_categories (
    category_id                  VARCHAR(10) PRIMARY KEY,
    name                         VARCHAR(60) NOT NULL,
    behavior                     VARCHAR(30) NOT NULL,
    fs_section                   VARCHAR(30) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 4. Products / SKUs
DROP TABLE IF EXISTS raw.raw_products CASCADE;
CREATE TABLE raw.raw_products (
    product_id                   VARCHAR(10) PRIMARY KEY,
    mushroom_id                  VARCHAR(10) NOT NULL,
    sku_code                     VARCHAR(30) NOT NULL,
    product_name                 VARCHAR(100) NOT NULL,
    package_format               VARCHAR(40) NOT NULL,
    unit_weight_kg               NUMERIC(6,3) NOT NULL,
    grade                        VARCHAR(20) NOT NULL,
    standard_selling_price       NUMERIC(10,2) NOT NULL,
    active_status                BOOLEAN NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 5. Suppliers
DROP TABLE IF EXISTS raw.raw_suppliers CASCADE;
CREATE TABLE raw.raw_suppliers (
    supplier_id                  VARCHAR(10) PRIMARY KEY,
    name                         VARCHAR(100) NOT NULL,
    category                     VARCHAR(50) NOT NULL,
    lead_days_min                INTEGER NOT NULL,
    lead_days_max                INTEGER NOT NULL,
    payment_terms                INTEGER NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 6. Customers
DROP TABLE IF EXISTS raw.raw_customers CASCADE;
CREATE TABLE raw.raw_customers (
    customer_id                  VARCHAR(10) PRIMARY KEY,
    customer_name                VARCHAR(100) NOT NULL,
    customer_segment             VARCHAR(30) NOT NULL,
    delivery_route_zone          VARCHAR(20) NOT NULL,
    payment_terms_days           INTEGER NOT NULL,
    preferred_variety            VARCHAR(10),
    acquisition_date             DATE NOT NULL,
    is_active                    BOOLEAN NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 7. Production Batches
DROP TABLE IF EXISTS raw.raw_production_batches CASCADE;
CREATE TABLE raw.raw_production_batches (
    batch_id                     VARCHAR(15) PRIMARY KEY,
    mushroom_id                  VARCHAR(10) NOT NULL,
    mushroom_variety             VARCHAR(50) NOT NULL,
    substrate_formula            VARCHAR(150) NOT NULL,
    planned_blocks_count         INTEGER NOT NULL,
    dry_substrate_kg             NUMERIC(10,3) NOT NULL,
    water_liters_added           NUMERIC(10,1) NOT NULL,
    spawn_kg                     NUMERIC(8,3) NOT NULL,
    batch_start_date             DATE, -- Nullable to allow validation test cases
    transfer_to_fruiting_date    DATE,
    growing_room_id              VARCHAR(10) NOT NULL,
    expected_first_harvest_date  DATE,
    target_yield_kg              NUMERIC(10,3) NOT NULL,
    direct_material_cost         NUMERIC(10,2) NOT NULL,
    batch_status                 VARCHAR(20) NOT NULL,
    is_stress_event              BOOLEAN NOT NULL,
    notes                        TEXT,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 8. Harvest Records
DROP TABLE IF EXISTS raw.raw_harvest_records CASCADE;
CREATE TABLE raw.raw_harvest_records (
    harvest_id                   VARCHAR(15) PRIMARY KEY,
    batch_id                     VARCHAR(15) NOT NULL,
    harvest_date                 DATE NOT NULL,
    flush_number                 INTEGER NOT NULL,
    gross_harvested_kg           NUMERIC(10,3) NOT NULL,
    accepted_weight_kg           NUMERIC(10,3) NOT NULL,
    rejected_weight_kg           NUMERIC(10,3) NOT NULL,
    rejection_reason             VARCHAR(100),
    labor_hours                  NUMERIC(6,2) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    recorded_at                  TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 9. Inventory Movements
DROP TABLE IF EXISTS raw.raw_inventory_movements CASCADE;
CREATE TABLE raw.raw_inventory_movements (
    movement_id                  VARCHAR(15) PRIMARY KEY,
    lot_id                       VARCHAR(15) NOT NULL,
    product_id                   VARCHAR(10) NOT NULL,
    mushroom_id                  VARCHAR(10) NOT NULL,
    batch_id                     VARCHAR(15),
    harvest_id                   VARCHAR(15),
    movement_date                DATE NOT NULL,
    movement_type                VARCHAR(30) NOT NULL,
    signed_quantity_kg           NUMERIC(10,3) NOT NULL,
    unit_cost                    NUMERIC(10,4) NOT NULL,
    total_movement_value         NUMERIC(10,2) NOT NULL,
    expiry_date                  DATE,
    reason                       VARCHAR(150),
    reference_transaction_id     VARCHAR(20),
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 10. Sales Orders
DROP TABLE IF EXISTS raw.raw_sales_orders CASCADE;
CREATE TABLE raw.raw_sales_orders (
    order_id                     VARCHAR(15) PRIMARY KEY,
    customer_id                  VARCHAR(10) NOT NULL,
    order_date                   DATE NOT NULL,
    requested_delivery_date      DATE NOT NULL,
    actual_delivery_date         DATE,
    order_status                 VARCHAR(20) NOT NULL,
    payment_status               VARCHAR(20) NOT NULL,
    sales_channel                VARCHAR(30) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 11. Sales Order Lines
DROP TABLE IF EXISTS raw.raw_sales_order_lines CASCADE;
CREATE TABLE raw.raw_sales_order_lines (
    order_line_id                VARCHAR(15) PRIMARY KEY,
    order_id                     VARCHAR(15) NOT NULL,
    product_id                   VARCHAR(10) NOT NULL,
    mushroom_id                  VARCHAR(10) NOT NULL,
    lot_id                       VARCHAR(15) NOT NULL,
    quantity_ordered_kg          NUMERIC(10,3) NOT NULL,
    quantity_fulfilled_kg        NUMERIC(10,3) NOT NULL,
    unit_of_measure              VARCHAR(10) NOT NULL,
    unit_selling_price           NUMERIC(10,2) NOT NULL,
    discount_amount              NUMERIC(10,2) NOT NULL,
    gross_revenue                NUMERIC(10,2) NOT NULL,
    net_revenue                  NUMERIC(10,2) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 12. Expenses
DROP TABLE IF EXISTS raw.raw_expenses CASCADE;
CREATE TABLE raw.raw_expenses (
    expense_id                   VARCHAR(15) PRIMARY KEY,
    expense_date                 DATE NOT NULL,
    expense_category_id          VARCHAR(10) NOT NULL,
    description                  VARCHAR(150) NOT NULL,
    amount                       NUMERIC(10,2) NOT NULL,
    currency                     VARCHAR(5) NOT NULL,
    supplier_id                  VARCHAR(10),
    batch_id                     VARCHAR(15),
    allocation_method            VARCHAR(30) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 13. Purchases
DROP TABLE IF EXISTS raw.raw_purchases CASCADE;
CREATE TABLE raw.raw_purchases (
    purchase_id                  VARCHAR(15) NOT NULL, -- Not unique in raw because of intentional duplicate injection test
    supplier_id                  VARCHAR(10) NOT NULL,
    purchase_date                DATE NOT NULL,
    material_name                VARCHAR(100) NOT NULL,
    unit_of_measure              VARCHAR(20) NOT NULL,
    quantity_ordered             NUMERIC(10,2) NOT NULL,
    quantity_received            NUMERIC(10,2) NOT NULL,
    unit_price                   NUMERIC(10,4) NOT NULL,
    total_cost                   NUMERIC(10,2) NOT NULL,
    delivery_date                DATE,
    payment_status               VARCHAR(20) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 14. Waste Events
DROP TABLE IF EXISTS raw.raw_waste_events CASCADE;
CREATE TABLE raw.raw_waste_events (
    waste_id                     VARCHAR(15) PRIMARY KEY,
    lot_id                       VARCHAR(15) NOT NULL,
    product_id                   VARCHAR(10) NOT NULL,
    mushroom_id                  VARCHAR(10) NOT NULL,
    batch_id                     VARCHAR(15),
    waste_date                   DATE NOT NULL,
    waste_type                   VARCHAR(30) NOT NULL,
    waste_kg                     NUMERIC(10,3) NOT NULL,
    estimated_unit_cost          NUMERIC(10,4) NOT NULL,
    estimated_waste_value        NUMERIC(10,2) NOT NULL,
    reason_code                  VARCHAR(150) NOT NULL,
    disposition                  VARCHAR(30) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);

-- 15. Returns
DROP TABLE IF EXISTS raw.raw_returns CASCADE;
CREATE TABLE raw.raw_returns (
    return_id                    VARCHAR(15) PRIMARY KEY,
    original_order_line_id       VARCHAR(15) NOT NULL,
    original_order_id            VARCHAR(15) NOT NULL,
    product_id                   VARCHAR(10) NOT NULL,
    mushroom_id                  VARCHAR(10) NOT NULL,
    lot_id                       VARCHAR(15) NOT NULL,
    return_date                  DATE NOT NULL,
    return_type                  VARCHAR(30) NOT NULL,
    return_kg                    NUMERIC(10,3) NOT NULL,
    credit_value                 NUMERIC(10,2) NOT NULL,
    reason                       VARCHAR(150) NOT NULL,
    disposition                  VARCHAR(50) NOT NULL,
    source_type                  VARCHAR(30) NOT NULL,
    created_at                   TIMESTAMP WITH TIME ZONE NOT NULL,
    _source_file                 VARCHAR(255),
    _ingested_at                 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    _ingestion_run_id            VARCHAR(50),
    _row_fingerprint             VARCHAR(64)
);
