{{ 
    config(
        materialized = 'incremental',
        unique_key = 'sales_item_id',
        incremental_strategy = 'merge'
    ) 
}}

with
    stg_sales as (
        select * 
        from {{ ref("stg_sales") }}
        where 1 = 1
        {% if is_incremental() %}
        -- chỉ lấy dữ liệu mới hơn lần chạy trước
        and sold_at >= (select max(sold_at) from {{ this }})
        {% endif %}
    ),

    stg_sales_lines as (
        select * 
        from {{ ref("stg_sales_lines") }}
        where 1 = 1

    ),

    fct_sales_items as (
        select
            -- ids
            sales_line.sales_line_id as sales_item_id,
            sale.sales_id as sales_id,
            sale.employee_id as cashier_employee_id,
            sales_line.product_id,
            sales_line.promotion_id,
            -- strings
            sale.payment_type,
            -- numerics
            sales_line.quantity_sold,
            sales_line.discount_rate,
            sales_line.unit_price,
            sales_line.unit_discount,
            sales_line.total_price,
            sales_line.total_discount,
            -- dates
            sale.sold_date,
            -- timestamps
            sale.sold_at,
            -- booleans
            if(sales_line.promotion_id is null, false, true) as has_promotion

        from stg_sales sale
        inner join stg_sales_lines sales_line using (sales_id)
    )

select *
from fct_sales_items