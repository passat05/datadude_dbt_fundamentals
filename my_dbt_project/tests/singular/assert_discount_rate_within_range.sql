{{ config(limit=100,severity='error',store_failures=true) }}
select *
from {{ref('fct_sales_items')}}
where discount_rate < 0 or  discount_rate > 50