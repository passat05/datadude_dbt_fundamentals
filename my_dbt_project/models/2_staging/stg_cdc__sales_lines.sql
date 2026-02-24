with
    raw_source as (select * from {{ source("stroopwafel_cdc", "sales_lines") }}),

    sales_lines as (
        select
            json_extract_scalar(data, '$.id') as sales_line_id,
            json_extract_scalar(data, '$.sales_id') as sales_id,
            json_extract_scalar(data, '$.product_id') as product_id,
            json_extract_scalar(data, '$.promotion_id') as promotion_id,
            json_extract_scalar(data, '$.quantity_sold') as quantity_sold,
            json_extract_scalar(data, '$.discount_rate') as discount_rate,
            json_extract_scalar(data, '$.unit_price') as unit_price,
            json_extract_scalar(data, '$.unit_discount') as unit_discount,
            json_extract_scalar(data, '$.total_price') as total_price,
            json_extract_scalar(data, '$.total_discount') as total_discount,
            json_extract_scalar(data, '$.updated_at') as updated_at

        from raw_source
    )

--- Chuẩn hoá kiểu dữ liệu cho các trường thông tin
select
    sales_line_id,
    sales_id,
    product_id,
    promotion_id,
    cast(quantity_sold as integer) as quantity_sold,
    cast(discount_rate as numeric) as discount_rate,
    cast(unit_price as numeric) as unit_price,
    cast(unit_discount as numeric) as unit_discount,
    cast(total_price as numeric) as total_price,
    cast(total_discount as numeric) as total_discount,
    cast(updated_at as timestamp) as updated_at

from sales_lines