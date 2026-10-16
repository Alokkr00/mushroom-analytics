-- ==============================================================================
-- Portfolio Project: MycoMetrics - FungiFlow Organics
-- Script: 04_customer_cohort_retention_and_rfm.sql
-- Purpose: Analyze customer cohort retention, RFM segmentation with NTILE,
--          and Pareto customer concentration distribution.
-- Business Questions Answered:
--   1. What is the month-over-month order retention rate for customer cohorts?
--   2. Which customers fall into Champions, Loyal, At-Risk, and Hibernating RFM tiers?
--   3. What percentage of total business revenue is controlled by the top 20% of accounts?
-- ==============================================================================

SET search_path = 'analytics_analytics';

-- Section 1: Customer Cohort Retention Analysis
with customer_first_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        strftime(min(order_date), '%Y-%m') as cohort_month
    from fact_sales
    where order_status in ('DELIVERED', 'COMPLETED')
    group by customer_id
),

order_activity as (
    select distinct
        s.customer_id,
        cfo.cohort_month,
        strftime(s.order_date, '%Y-%m') as activity_month,
        -- Month index offset between activity month and cohort acquisition month
        (cast(strftime(s.order_date, '%Y') as integer) - cast(substr(cfo.cohort_month, 1, 4) as integer)) * 12 +
        (cast(strftime(s.order_date, '%m') as integer) - cast(substr(cfo.cohort_month, 6, 2) as integer)) as month_number
    from fact_sales s
    inner join customer_first_orders cfo on s.customer_id = cfo.customer_id
    where s.order_status in ('DELIVERED', 'COMPLETED')
),

cohort_sizes as (
    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from customer_first_orders
    group by cohort_month
),

cohort_retention as (
    select
        oa.cohort_month,
        cs.cohort_size,
        oa.month_number,
        count(distinct oa.customer_id) as active_customers,
        round((count(distinct oa.customer_id) * 100.0) / cs.cohort_size, 1) as retention_rate_pct
    from order_activity oa
    inner join cohort_sizes cs on oa.cohort_month = cs.cohort_month
    group by oa.cohort_month, cs.cohort_size, oa.month_number
)

select
    cohort_month,
    cohort_size,
    month_number as months_since_acquisition,
    active_customers,
    retention_rate_pct
from cohort_retention
order by cohort_month, month_number;


-- Section 2: RFM Customer Scoring and Segmentation
with reference_date as (
    -- Anchor date: maximum order date in the fact table
    select max(order_date) as max_date from fact_sales
),

customer_raw_rfm as (
    select
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        c.delivery_route_zone,
        date_diff('day', max(s.order_date), rd.max_date) as recency_days,
        count(distinct s.order_id) as frequency_orders,
        round(sum(s.final_recognized_revenue), 2) as monetary_revenue
    from dim_customer c
    inner join fact_sales s on c.customer_id = s.customer_id
    cross join reference_date rd
    where s.order_status in ('DELIVERED', 'COMPLETED')
    group by c.customer_id, c.customer_name, c.customer_segment, c.delivery_route_zone, rd.max_date
),

rfm_quartiles as (
    select
        *,
        -- R_Score: 4 is best (lowest recency days), 1 is worst (longest time since order)
        ntile(4) over (order by recency_days desc) as r_score,
        -- F_Score: 4 is highest order frequency
        ntile(4) over (order by frequency_orders asc) as f_score,
        -- M_Score: 4 is highest monetary spending
        ntile(4) over (order by monetary_revenue asc) as m_score
    from customer_raw_rfm
),

segmented_customers as (
    select
        *,
        cast(r_score as varchar) || cast(f_score as varchar) || cast(m_score as varchar) as rfm_cell,
        case
            when r_score >= 3 and f_score >= 3 and m_score >= 3 then 'Champions (Top Accounts)'
            when r_score >= 3 and f_score >= 2 then 'Loyal Regulars'
            when r_score >= 3 and f_score = 1 then 'Recent First-Time Buyers'
            when r_score <= 2 and f_score >= 3 then 'At Risk (High Value, Lapsing)'
            when r_score <= 2 and f_score <= 2 and m_score >= 3 then 'Hibernating Big Spenders'
            else 'Low Engagement / Occasional'
        end as customer_rfm_segment
    from rfm_quartiles
)

select
    customer_id,
    customer_name,
    customer_segment,
    customer_rfm_segment,
    recency_days,
    frequency_orders,
    monetary_revenue,
    r_score,
    f_score,
    m_score
from segmented_customers
order by monetary_revenue desc;
