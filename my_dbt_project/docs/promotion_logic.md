{% docs promotion_logic %}

### Tổng quan
Lưu trữ thông tin các chương trình giảm giá, phục vụ các model **downstream** cho mục đích kinh doanh và vận hành tại Stroopwafel Shop.

### Quy tắc áp dụng (Business Logic)
Hệ thống xác định hiệu lực của chương trình khuyến mãi dựa trên các điều kiện sau:

* **Trường hợp 1 (Ngày lễ):** * Nếu `is_holiday = true`: Chương trình giảm giá **không** được áp dụng.
* **Trường hợp 2 (Ngày thường):** * Nếu `is_holiday = false`: Chương trình chỉ có hiệu lực khi ngày giao dịch nằm trong khoảng thời gian xác định bởi `start_date` và `end_date`.

{% enddocs %}