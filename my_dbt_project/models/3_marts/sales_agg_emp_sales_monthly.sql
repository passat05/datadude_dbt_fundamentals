select
    year,
    month,
    cashier_employee_id,
    sum(total_price) total_price


from {{ref('fact_sales_items')}} sales
left join {{ref('dim_employees')}} employees
on sales.cashier_employee_id = employees.employee_id
left join {{ref('dim_date')}} dt
on sales.sold_date = dt.date_key
group by 1,2,3