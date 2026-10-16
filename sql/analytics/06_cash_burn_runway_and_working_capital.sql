-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 06_cash_burn_runway_and_working_capital.sql
-- Purpose: Analyze monthly cash burn, operating margin trajectory, working capital
--          tied up in inventory, and startup financial runway.
-- Business Questions Answered:
--   1. Is the business generating true cash profit or just revenue?
--   2. Which expenses (labor, rent, utilities, substrate) are increasing fastest?
--   3. What is the net monthly cash burn and estimated runway in months?
--   4. How much capital is tied up in substrate materials vs finished inventory?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Monthly Cash Inflow vs Outflow & Burn Rate Trajectory
with cash_inflow as (
    select
        strftime(order_date, '%Y-%m') as year_month,
        sum(final_recognized_revenue) as sales_cash_collected
    from fact_sales
    where order_status in ('DELIVERED', 'COMPLETED')
    group by 1
),

operating_expenses as (
    select
        strftime(expense_date, '%Y-%m') as year_month,
        sum(amount) as opex_cash_spent
    from fact_expenses
    group by 1
),

procurement_expenses as (
    select
        strftime(purchase_date, '%Y-%m') as year_month,
        sum(total_cost) as procurement_cash_spent
    from fact_procurement
    group by 1
),

all_periods as (
    select year_month from cash_inflow
    union
    select year_month from operating_expenses
    union
    select year_month from procurement_expenses
),

monthly_cashflow as (
    select
        p.year_month,
        coalesce(ci.sales_cash_collected, 0.00) as cash_inflow_sales,
        coalesce(oe.opex_cash_spent, 0.00) as cash_outflow_opex,
        coalesce(pe.procurement_cash_spent, 0.00) as cash_outflow_procurement,
        round(coalesce(oe.opex_cash_spent, 0.00) + coalesce(pe.procurement_cash_spent, 0.00), 2) as total_cash_outflow,
        round(coalesce(ci.sales_cash_collected, 0.00) - (coalesce(oe.opex_cash_spent, 0.00) + coalesce(pe.procurement_cash_spent, 0.00)), 2) as net_cash_burn
    from all_periods p
    left join cash_inflow ci on p.year_month = ci.year_month
    left join operating_expenses oe on p.year_month = oe.year_month
    left join procurement_expenses pe on p.year_month = pe.year_month
),

cashflow_metrics as (
    select
        year_month,
        cash_inflow_sales,
        total_cash_outflow,
        net_cash_burn,
        -- Running cumulative cash deficit since inception
        sum(net_cash_burn) over (order by year_month rows between unbounded preceding and current row) as cumulative_cash_position,
        -- 3-month trailing average burn rate
        round(avg(net_cash_burn) over (order by year_month rows between 2 preceding and current row), 2) as trailing_3m_avg_burn
    from monthly_cashflow
)

select
    year_month,
    cash_inflow_sales,
    total_cash_outflow,
    net_cash_burn,
    cumulative_cash_position,
    trailing_3m_avg_burn,
    case
        when net_cash_burn > 0 then 'Cash Flow Positive (+)'
        else 'Cash Burning (-)'
    end as cash_flow_status
from cashflow_metrics
order by year_month;


-- Section 2: Expense Category Breakdown and Trajectory
with expense_category_monthly as (
    select
        strftime(e.expense_date, '%Y-%m') as year_month,
        c.category_name,
        c.cost_behavior,
        sum(e.amount) as category_spend
    from fact_expenses e
    inner join dim_expense_category c on e.category_id = c.category_id
    group by 1, 2, 3
)

select
    year_month,
    category_name,
    cost_behavior,
    round(category_spend, 2) as monthly_spend,
    -- Prior month spend using LAG
    lag(category_spend, 1) over (partition by category_name order by year_month) as prior_month_spend,
    -- Month-over-Month percentage change
    round((category_spend - lag(category_spend, 1) over (partition by category_name order by year_month)) / 
          nullif(lag(category_spend, 1) over (partition by category_name order by year_month), 0) * 100, 1) as mom_change_pct
from expense_category_monthly
order by category_name, year_month;
