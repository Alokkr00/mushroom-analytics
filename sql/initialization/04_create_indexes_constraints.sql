-- ============================================================================
-- 04_create_indexes_constraints.sql
-- Database: mycometrics
-- Purpose: Add foreign keys, business constraints, and indexes justified by query patterns.
-- ============================================================================

-- Indexes on Dates for Time-Series Queries
CREATE INDEX IF NOT EXISTS idx_batches_start_date ON raw.raw_production_batches(batch_start_date);
CREATE INDEX IF NOT EXISTS idx_harvest_date ON raw.raw_harvest_records(harvest_date);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON raw.raw_sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_movements_date ON raw.raw_inventory_movements(movement_date);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON raw.raw_expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON raw.raw_purchases(purchase_date);

-- Foreign Key Lookups & Join Indexes
CREATE INDEX IF NOT EXISTS idx_harvest_batch_id ON raw.raw_harvest_records(batch_id);
CREATE INDEX IF NOT EXISTS idx_order_lines_order_id ON raw.raw_sales_order_lines(order_id);
CREATE INDEX IF NOT EXISTS idx_order_lines_product_id ON raw.raw_sales_order_lines(product_id);
CREATE INDEX IF NOT EXISTS idx_movements_lot_id ON raw.raw_inventory_movements(lot_id);
CREATE INDEX IF NOT EXISTS idx_movements_product_id ON raw.raw_inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_returns_order_line_id ON raw.raw_returns(original_order_line_id);

-- Ingestion Fingerprint Indexes for Fast Idempotency Lookup
CREATE INDEX IF NOT EXISTS idx_batches_fingerprint ON raw.raw_production_batches(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_harvest_fingerprint ON raw.raw_harvest_records(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_orders_fingerprint ON raw.raw_sales_orders(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_order_lines_fingerprint ON raw.raw_sales_order_lines(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_movements_fingerprint ON raw.raw_inventory_movements(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_expenses_fingerprint ON raw.raw_expenses(_row_fingerprint);
CREATE INDEX IF NOT EXISTS idx_purchases_fingerprint ON raw.raw_purchases(_row_fingerprint);
