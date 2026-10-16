import duckdb
import pandas as pd

con = duckdb.connect('data/warehouse.duckdb')

print("=== MART_BUSINESS_OVERVIEW ===")
df_biz = con.execute("SELECT * FROM analytics_analytics.mart_business_overview ORDER BY year_month").df()
print(df_biz.to_string())

print("\n=== MART_PRODUCTION_PERFORMANCE SUMMARY ===")
df_prod = con.execute("SELECT mushroom_common_name, sum(batches_started) as batches, sum(total_accepted_yield_kg) as yield_kg, avg(avg_biological_efficiency_pct) as be_pct FROM analytics_analytics.mart_production_performance GROUP BY 1").df()
print(df_prod.to_string())

print("\n=== MART_CUSTOMER_ANALYSIS SUMMARY ===")
df_cust = con.execute("SELECT customer_segment, count(*) as customers, sum(lifetime_net_revenue) as segment_rev FROM analytics_analytics.mart_customer_analysis GROUP BY 1").df()
print(df_cust.to_string())

print("\n=== MART_SALES_PROFITABILITY TOP LINES ===")
df_sales = con.execute("SELECT mushroom_common_name, customer_segment, sum(total_final_recognized_revenue) as recognized_rev, sum(total_gross_profit) as gross_profit, avg(gross_margin_pct) as avg_margin FROM analytics_analytics.mart_sales_profitability GROUP BY 1, 2 ORDER BY recognized_rev DESC").df()
print(df_sales.to_string())

print("\n=== MART_INVENTORY_WASTE SUMMARY ===")
df_waste = con.execute("SELECT loss_stage, sum(total_lost_quantity_kg) as lost_kg, sum(total_estimated_loss_amount) as financial_loss FROM analytics_analytics.mart_inventory_waste GROUP BY 1 ORDER BY lost_kg DESC").df()
print(df_waste.to_string())

con.close()
