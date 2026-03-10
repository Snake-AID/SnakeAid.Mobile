# ACTIVITY DIAGRAM - LUỒNG SOS KHẨN CẤP RẮN CẮN

## Thông tin tài liệu
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** SOS Emergency — Snakebite Response
- **Phiên bản:** 1.1
- **Ngày tạo:** 10/03/2026
- **Mục đích:** Mô tả luồng nghiệp vụ chính khi bệnh nhân bị rắn cắn khẩn cấp với sự tham gia của các Actor

---

## ACTORS

| Actor | Vai trò |
|---|---|
| **Member** | Nạn nhân bị rắn cắn, kích hoạt SOS, nhận hỗ trợ và thanh toán dịch vụ sau khi hoàn thành |
| **Rescuer** | Cứu hộ viên tiếp nhận SOS, di chuyển đến hiện trường, hỗ trợ sơ cứu cho Member |
| **Expert** | Chuyên gia tư vấn từ xa (tuỳ chọn) khi Rescuer cần xác định loài rắn hoặc hướng xử lý đặc thù |
| **SnakeAid System** | Nền tảng trung gian: tiếp nhận SOS, matching Rescuer, tính phí, phân chia doanh thu |
| **Payment Gateway** | Cổng thanh toán xử lý giao dịch dịch vụ từ Member |

---

## ACTIVITY DIAGRAM TỔNG QUAN

```plantuml
@startuml SOS-Emergency-Overall
title ACTIVITY DIAGRAM - SOS SNAKE BITE FLOW

|#FFD5D5|Member|
|#LightGreen|Rescuer|
|#D5E8FF|Expert|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway|

|Member|
start
:Bị rắn cắn;
:Mở app SnakeAid;
:Gửi yêu cầu SOS;

|SnakeAid System|
:Tiếp nhận yêu cầu;
:Gửi alert đến Rescuer gần nhất;

|Rescuer|
:Nhận SOS và chấp nhận nhiệm vụ;
:Di chuyển đến Member;
:Hỗ trợ sơ cứu;

if (Cần tư vấn Expert?) then (Yes)
  |Expert|
  :Xem thông tin và tư vấn;
  |Rescuer|
  :Nhận tư vấn xử lý;
else (No)
endif

:Hoàn thành hỗ trợ;

|SnakeAid System|
:Đóng Emergency Case;
:Tính phí dịch vụ;

|Member|
:Thanh toán dịch vụ;

|Payment Gateway|
:Xử lý thanh toán;

|SnakeAid System|
:Nhận kết quả thanh toán;
:Phân chia phí dịch vụ cho Rescuer / Expert;

stop
@enduml
```

---

## ACTIVITY DIAGRAM CHI TIẾT THEO GIAI ĐOẠN

### Giai đoạn 1: Gửi SOS & Matching Rescuer

```plantuml
@startuml Phase-1-SOS-Matching
title GIAI ĐOẠN 1 - GỬI SOS & MATCHING RESCUER

|#FFD5D5|Member|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|

|Member|
start
:Bị rắn cắn;
:Mở app SnakeAid;
:Nhấn nút SOS khẩn cấp;
:Xác nhận vị trí GPS;
:Gửi yêu cầu SOS
(vị trí, mô tả sơ bộ, ảnh rắn nếu có);

|SnakeAid System|
:Tiếp nhận yêu cầu SOS;
:Tạo Emergency Case;
:Tìm Rescuer đang online gần nhất;
:Gửi alert đến Rescuer
(vị trí Member, thông tin sơ bộ, khoảng cách);

|Rescuer|
:Nhận alert SOS;
:Xem thông tin yêu cầu;

if (Chấp nhận trong thời gian quy định?) then (Có)
  :Nhấn "Chấp nhận nhiệm vụ";

  |SnakeAid System|
  :Xác nhận matching thành công;
  :Thông báo cho Member
  (thông tin Rescuer, ETA);

  |Member|
  :Nhận thông báo Rescuer đang đến;
  stop

else (Từ chối / Hết hạn)
  |SnakeAid System|
  :Chuyển alert sang Rescuer tiếp theo;
  if (Còn Rescuer khả dụng?) then (Có)
    stop
  else (Không)
    :Thông báo không có Rescuer;
    :Gợi ý gọi đường dây khẩn cấp 115;
    stop
  endif
endif

@enduml
```

---

### Giai đoạn 2: Rescuer đến hiện trường & Hỗ trợ xử lý

```plantuml
@startuml Phase-2-OnSite-Support
title GIAI ĐOẠN 2 - RESCUER ĐẾN HIỆN TRƯỜNG & HỖ TRỢ XỬ LÝ

|#LightGreen|Rescuer|
|#FFD5D5|Member|
|#D5E8FF|Expert|
|#LightYellow|SnakeAid System|

|Rescuer|
start
note left: Đã chấp nhận nhiệm vụ
:Di chuyển đến vị trí Member;

|Member|
:Nhận hướng dẫn sơ cứu ban đầu từ app
trong khi chờ Rescuer;
:Thực hiện sơ cứu theo hướng dẫn;

|Rescuer|
:Đến nơi;
:Đánh giá tình trạng Member;
:Hỗ trợ sơ cứu chuyên nghiệp;

if (Cần tư vấn Expert để xử lý đặc thù?) then (Yes)
  :Gọi tư vấn Expert từ app;

  |Expert|
  :Nhận yêu cầu tư vấn khẩn cấp;
  :Xem thông tin: ảnh rắn, triệu chứng,
  mức độ nghiêm trọng của Member;
  :Tư vấn qua chat hoặc call
  (xác nhận loài rắn, hướng xử lý đặc thù);

  |Rescuer|
  :Nhận tư vấn từ Expert;
  :Áp dụng hướng xử lý được tư vấn;

else (No)
  |Rescuer|
endif

:Hoàn thành hỗ trợ tại hiện trường;
:Đánh dấu hoàn thành nhiệm vụ trên app;

|SnakeAid System|
:Nhận xác nhận hoàn thành từ Rescuer;
:Đóng Emergency Case;
:Tính phí dịch vụ
(phí Rescuer + phí Expert nếu có tư vấn);

stop

@enduml
```

---

### Giai đoạn 3: Thanh toán & Phân chia doanh thu

```plantuml
@startuml Phase-3-Payment-Distribution
title GIAI ĐOẠN 3 - THANH TOÁN & PHÂN CHIA DOANH THU

|#FFD5D5|Member|
|#FFE0CC|Payment Gateway|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|
|#D5E8FF|Expert|

|Member|
start
note left: Emergency Case đã đóng\nPhí dịch vụ đã được tính
:Nhận thông báo thanh toán;
:Xem chi tiết phí dịch vụ
(phí Rescuer + phí Expert nếu có);
:Chọn phương thức thanh toán;
note right
  Phương thức:
  - PayOS (online)
  - Ví SnakeAidPay
end note
:Xác nhận thanh toán;

|Payment Gateway|
:Tiếp nhận yêu cầu giao dịch;
:Xử lý thanh toán;

if (Thanh toán thành công?) then (Có)
  :Xác nhận giao dịch;
  :Trả kết quả về SnakeAid System;

  |SnakeAid System|
  :Nhận kết quả thanh toán thành công;
  :Phân chia phí dịch vụ;

  fork
    :Chuyển phần Rescuer cho Rescuer;
  fork again
    :Chuyển phần Expert cho Expert
    (nếu đã tư vấn trong ca);
  end fork

  |Rescuer|
  :Nhận thanh toán vào tài khoản;

  |Expert|
  :Nhận thanh toán vào tài khoản
  (nếu đã tư vấn);

  |Member|
  :Nhận xác nhận thanh toán thành công;
  :Đánh giá Rescuer / Expert (tùy chọn);
  stop

else (Thất bại)
  :Trả kết quả lỗi;

  |SnakeAid System|
  :Thông báo cho Member thử lại;

  |Member|
  :Thử lại thanh toán;
  stop
endif

@enduml
```

---

## TỔNG HỢP TRẠNG THÁI EMERGENCY CASE

```plantuml
@startuml Emergency-Status-Flow
title LUỒNG TRẠNG THÁI EMERGENCY CASE

[*] --> Created : Member gửi SOS

Created --> Matching : Hệ thống tìm Rescuer
Matching --> Assigned : Rescuer chấp nhận
Matching --> Failed : Không có Rescuer khả dụng

Assigned --> InProgress : Rescuer đang di chuyển / hỗ trợ
InProgress --> Completed : Rescuer hoàn thành hỗ trợ

Completed --> PendingPayment : Hệ thống tính phí
PendingPayment --> Paid : Member thanh toán thành công
Paid --> Closed : Phân chia doanh thu xong

Failed --> [*] : Member tự xử lý / gọi 115
Closed --> [*]

note right of InProgress
  Expert có thể được gọi
  tư vấn bất kỳ lúc nào
  trong giai đoạn này
end note

note right of Paid
  SnakeAid System chuyển tiền
  cho Rescuer và Expert
  (nếu Expert đã tham gia)
end note

@enduml
```

---

## GHI CHÚ NGHIỆP VỤ

### Quy tắc thanh toán SOS
| Yếu tố | Chi tiết |
|---|---|
| **Thời điểm thanh toán** | Sau khi Rescuer hoàn thành hỗ trợ (post-service, 100%) |
| **Thành phần phí** | Phí Rescuer + Phí Expert (nếu có tư vấn trong ca) |
| **Phương thức** | PayOS hoặc Ví SnakeAidPay |
| **Phân chia** | SnakeAid System phân chia tự động sau khi nhận thanh toán từ Payment Gateway |

### Vai trò Expert trong SOS
- Expert **không** tham gia mặc định — chỉ khi Rescuer chủ động gọi trong lúc thực hiện nhiệm vụ
- Tư vấn **từ xa** (không đến hiện trường)
- Phí tư vấn Expert **gộp chung** vào hóa đơn cuối của Member
- Phí Expert được **SnakeAid System phân chia** sau khi nhận thanh toán thành công
