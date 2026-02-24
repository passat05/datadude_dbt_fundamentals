with 
    raw_source as (select * from {{ source("stroopwafel_sns", "employees") }}),

    employees as (
        select
            employee_id,
            contact_number,
            first_name,
            last_name,
            concat(first_name, ' ', last_name) as full_name,
            hourly_rate,
            dob as birth_date,
            created_at,
            updated_at

        from raw_source
    )

select *
from employees