{% docs promotion_logic %}
### Quy tắc áp dụng khuyến mãi
Hệ thống áp dụng các quy tắc sau:
1. Nếu `is_holiday = true`, chương trình giảm giá không áp dụng.
2. Nếu `is_holiday = false`, chương trình chỉ áp dụng khi ngày giao dịch nằm trong thời gian khuyến mãi (start_date, end_date)
{% enddocs %}