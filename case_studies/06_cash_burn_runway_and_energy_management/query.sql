-- ==============================================================================
-- Case Study 6: Cash Burn, Runway & Energy Management
-- Business Question: What is the monthly cash burn rate, and how can FungiFlow optimize energy costs?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Monthly Operating Cash Burn Trajectory
with cashflow as (
    select
        strftime(order_date, '%Y-%m') as year_month,
        sum(final_recognized_revenue) as cash_inflow
    from fact_sales
    where order_status in ('DELIVERED', 'COMPLETED')
    group by 1
),

outflows as (
    select
        strftime(expense_date, '%Y-%m') as year_month,
        sum(amount) as cash_outflow
    from fact_expenses
    group by 1
)

select
    c.year_month,
    round(c.cash_inflow, 2) as cash_inflow_sales,
    round(o.cash_outflow, 2) as cash_outflow_opex,
    round(c.cash_inflow - o.cash_outflow, 2) as net_cash_burn,
    round(sum(c.cash_inflow - o.cash_outflow) over (order by c.year_month rows between unbounded preceding and current row), 2) as cumulative_cash_deficit
from cashflow c
inner join outflows o on c.year_month = o.year_month
order by c.year_month;

-- Section 2: Electricity OPEX Volatility & Peak Summer Analysis
select
    strftime(e.expense_date, '%Y-%m') as year_month,
    c.category_name,
    round(sum(e.amount), 2) as monthly_electricity_cost,
    lag(round(sum(e.amount), 2), 1) over (order by strftime(e.expense_date, '%Y-%m')) as prior_month_cost,
    round((sum(e.amount) - lag(sum(e.amount), 1) over (order by strftime(e.expense_date, '%Y-%m'))) / 
          nullif(lag(sum(e.amount), 1) over (order by strftime(e.expense_date, '%Y-%m')), 0) * 100, 1) as mom_increase_pct
from fact_expenses e
inner join dim_expense_category c on e.category_id = c.category_id
where c.category_name = 'Electricity'
group by 1, 2
order by 1;
