with monthly_sales as (
    select
        strftime(order_date, '%Y-%m') as year_month,
        sum(net_revenue) as net_revenue,
        sum(final_recognized_revenue) as final_recognized_revenue,
        sum(estimated_cogs_amount) as total_cogs,
        sum(gross_profit_amount) as gross_profit,
        sum(quantity_fulfilled_kg) as total_fulfilled_kg
    from {{ ref('fact_sales') }}
    group by 1
),

monthly_expenses as (
    select
        strftime(expense_date, '%Y-%m') as year_month,
        sum(amount) as total_operating_expenses
    from {{ ref('fact_expenses') }}
    group by 1
),

monthly_harvest as (
    select
        strftime(harvest_date, '%Y-%m') as year_month,
        sum(gross_harvested_kg) as total_gross_harvested_kg,
        sum(accepted_weight_kg) as total_accepted_harvest_kg,
        sum(rejected_weight_kg) as total_rejected_harvest_kg
    from {{ ref('fact_harvest') }}
    group by 1
),

all_months as (
    select year_month from monthly_sales
    union
    select year_month from monthly_expenses
    union
    select year_month from monthly_harvest
)

select
    m.year_month,
    coalesce(s.final_recognized_revenue, 0.00) as net_sales_revenue,
    coalesce(s.total_cogs, 0.00) as cost_of_goods_sold,
    coalesce(s.gross_profit, 0.00) as gross_profit,
    case 
        when coalesce(s.final_recognized_revenue, 0) > 0 
        then round((s.gross_profit / s.final_recognized_revenue) * 100, 2)
        else 0.00 
    end as gross_margin_pct,
    coalesce(e.total_operating_expenses, 0.00) as operating_expenses,
    -- Operating Result (EBITDA Proxy) = Gross Profit - Operating Expenses
    round(coalesce(s.gross_profit, 0) - coalesce(e.total_operating_expenses, 0), 2) as operating_result,
    coalesce(h.total_accepted_harvest_kg, 0.000) as total_accepted_harvest_kg,
    coalesce(s.total_fulfilled_kg, 0.000) as total_sales_fulfilled_kg

from all_months m
left join monthly_sales s on m.year_month = s.year_month
left join monthly_expenses e on m.year_month = e.year_month
left join monthly_harvest h on m.year_month = h.year_month
order by m.year_month
