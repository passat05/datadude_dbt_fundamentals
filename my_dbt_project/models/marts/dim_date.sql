{{ config(materialized='table') }}

with date_spine as (

    -- tạo dải ngày
    SELECT date_day
    FROM unnest(
        generate_date_array(
            DATE('2026-01-01'),
            CURRENT_DATE,
            INTERVAL 1 DAY
        )
    ) AS date_day

),

holidays as (

    select *
    from {{ ref('us_holidays') }}

),

final as (

    select
        d.date_day as date_key,
        extract(year from d.date_day) as year,
        extract(month from d.date_day) as month,
        extract(day from d.date_day) as day,
        extract(quarter from d.date_day) as quarter,
        format_date('%A', d.date_day) as day_name,
        case 
            when extract(dayofweek from d.date_day) in (1,7) then true
            else false
        end as is_weekend,

        h.holiday_name,
        case 
            when h.holiday_date is not null then true
            else false
        end as is_holiday

    from date_spine d
    left join holidays h
        on d.date_day = h.holiday_date

)

select *
from final 