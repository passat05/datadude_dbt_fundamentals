select *
from {{ref('fct_sales_items')}}
where total_price != unit_price * quantity_sold