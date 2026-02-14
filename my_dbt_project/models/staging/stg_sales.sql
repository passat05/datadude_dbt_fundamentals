with 
    raw_source as (
        -- Lấy dữ liệu từ nguồn CDC và loại bỏ bản ghi bị xóa
        select 
            *,
            ROW_NUMBER() OVER (PARTITION BY record_id ORDER BY event_time DESC) num_order

        from {{ source('stroopwafel_cdc', 'sales') }}
        where 1 = 1
        and operation NOT IN ('DELETE')
    ),

    sales as (
        --- Parse dữ liệu JSON từ cột json_data và lọc bản ghi mới nhất
        select 
            json_extract_scalar(data, '$.id') as sales_id,
            json_extract_scalar(data, '$.employee_id') as employee_id,
            json_extract_scalar(data, '$.payment_type') as payment_type,
            json_extract_scalar(data, '$.total_price') as total_price,
            json_extract_scalar(data, '$.total_discount') as total_discount,
            json_extract_scalar(data, '$.date') as date,
            json_extract_scalar(data, '$.time') as time,
            json_extract_scalar(data, '$.updated_at') as updated_at

        from raw_source
        where num_order = 1
    )

--- Chuẩn hoá kiểu dữ liệu cho các trường thông tin và thêm trường mới
select
    sales_id,
    cast(employee_id as int64) as employee_id,
    payment_type,
    cast(total_price as numeric) as total_price,
    cast(total_discount as numeric) as total_discount,
    date(date) as sold_date,
    timestamp(date(date) || ' ' || time) as sold_at,
    cast(updated_at as timestamp) as updated_at

from sales