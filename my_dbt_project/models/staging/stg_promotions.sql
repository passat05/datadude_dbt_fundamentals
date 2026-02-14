with 
    raw_source as (
        -- Lấy dữ liệu từ nguồn CDC và loại bỏ bản ghi bị xóa
        select 
            *,
            ROW_NUMBER() OVER (PARTITION BY record_id ORDER BY event_time DESC) num_order
        from {{ source('stroopwafel_cdc', 'promotions') }}
        where 1 = 1
        and operation NOT IN ('DELETE')
    ),

    employees as (
        --- Parse dữ liệu JSON từ cột json_data và lọc bản ghi mới nhất
        select 
            json_extract_scalar(data, '$.id') as promotion_id,
            json_extract_scalar(data, '$.name') as promotion_name,
            json_extract_scalar(data, '$.description') as description,
            json_extract_scalar(data, '$.discount_rate') as discount_rate,
            json_extract_scalar(data, '$.product_id') as product_id,
            json_extract_scalar(data, '$.is_holiday') as is_holiday,
            json_extract_scalar(data, '$.start_date') as start_date,
            json_extract_scalar(data, '$.end_date') as end_date,
            json_extract_scalar(data, '$.created_at') as created_at,
            json_extract_scalar(data, '$.updated_at') as updated_at
        from raw_source
        where num_order = 1
    )

--- Chuẩn hoá tên cột và kiểu dữ liệu
select
    cast(promotion_id as int64) as promotion_id,
    cast(promotion_name as string) as promotion_name,
    cast(description as string) as description,
    cast(discount_rate as numeric) as discount_rate,
    cast(product_id as int64) as product_id,
    cast(is_holiday as bool) as is_holiday,
    cast(start_date as timestamp) as promotion_start_date,
    cast(end_date as timestamp) as promotion_end_date,
    cast(created_at as timestamp) as created_at,
    cast(updated_at as timestamp) as updated_at
from employees