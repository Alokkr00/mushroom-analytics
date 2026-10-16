-- Generates a continuous calendar date dimension table
with recursive date_spine as (
    select cast('2024-05-01' as date) as date_day
    union all
    select cast(date_day + interval 1 day as date)
    from date_spine
    where date_day < cast('2024-11-30' as date)
)

select
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    date_day as calendar_date,
    extract('day' from date_day) as day_of_month,
    extract('dow' from date_day) as day_of_week_num,
    strftime(date_day, '%A') as day_of_week_name,
    case when extract('dow' from date_day) in (0, 6) then true else false end as is_weekend,
    extract('week' from date_day) as week_of_year,
    extract('month' from date_day) as month_number,
    strftime(date_day, '%B') as month_name,
    strftime(date_day, '%Y-%m') as year_month,
    extract('quarter' from date_day) as quarter_number,
    extract('year' from date_day) as year_number
from date_spine
