with 
    raw_source as (
        -- Lấy dữ liệu từ nguồn CDC và loại bỏ bản ghi bị xóa
        select 
            *,
            ROW_NUMBER() OVER (PARTITION BY record_id ORDER BY event_time DESC) as num_order
        from {{ source('stroopwafel_cdc', 'shifts') }}
        where 1 = 1
        and operation NOT IN ('DELETE')
    ),

    shifts as (
        --- Parse dữ liệu JSON từ cột json_data và lọc bản ghi mới nhất
        select 
            json_extract_scalar(data, '$.id') as shift_id,
            json_extract_scalar(data, '$.employee_id') as employee_id,
            json_extract_scalar(data, '$.date') as shift_date,
            json_extract_scalar(data, '$.hours') as shift_hours,
            json_extract_scalar(data, '$.role') as employee_role,
            json_extract_scalar(data, '$.created_at') as created_at,
            json_extract_scalar(data, '$.updated_at') as updated_at
        from raw_source
        where num_order = 1
    )

--- Chuẩn hoá kiểu dữ liệu cho các trường thông tin
select
    cast(shift_id as int64) as shift_id,
    cast(employee_id as int64) as employee_id,
    cast(timestamp(shift_date) as date) as shift_date, -- Chuyển về kiểu Date để tối ưu truy vấn theo ngày
    cast(shift_hours as string) as shift_hours, -- Giữ nguyên định dạng khung giờ (ví dụ: 10:00-14:00)
    parse_timestamp(
        '%Y-%m-%d %H:%M',
        concat(cast(cast(timestamp(shift_date) as date) as string), ' ', split(shift_hours, '-')[offset(0)])
    ) as shift_start_at,
    parse_timestamp(
        '%Y-%m-%d %H:%M',
        concat(cast(cast(timestamp(shift_date) as date) as string), ' ', split(shift_hours, '-')[offset(1)])
    ) as shift_end_at,
    cast(employee_role as string) as employee_role,
    cast(created_at as timestamp) as created_at,
    cast(updated_at as timestamp) as updated_at
from shifts