{{ 
    config(
    schema='dbt_staging',
    materialized='view'
    ) 
}}
    
with 
    raw_source as (
        -- Lấy dữ liệu từ nguồn CDC và loại bỏ bản ghi bị xóa
        select 
            *,
            ROW_NUMBER() OVER (PARTITION BY record_id ORDER BY event_time DESC) num_order
        from {{ source('stroopwafel_cdc', 'products') }}
        where 1 = 1
        and operation NOT IN ('DELETE')
    ),

    products as (
        --- Parse dữ liệu JSON từ cột json_data và lọc bản ghi mới nhất
        select 
            json_extract_scalar(data, '$.id') as product_id,
            json_extract_scalar(data, '$.product_name') as product_name,
            json_extract_scalar(data, '$.unit_cost') as unit_cost,
            json_extract_scalar(data, '$.unit_price') as unit_price,
            json_extract_scalar(data, '$.created_at') as created_at,
            json_extract_scalar(data, '$.updated_at') as updated_at
        from raw_source
        where num_order = 1
    )

--- Chuẩn hoá tên cột và kiểu dữ liệu
select
    cast(product_id as int64) as product_id,
    cast(product_name as string) as product_name,
    cast(unit_cost as numeric) as unit_cost,
    cast(unit_price as numeric) as unit_price,
    cast(created_at as timestamp) as created_at,
    cast(updated_at as timestamp) as updated_at
from products