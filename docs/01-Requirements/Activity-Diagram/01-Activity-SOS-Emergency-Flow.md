# ACTIVITY DIAGRAM - LUỒNG SOS KHẨN CẤP RẮN CẮN

## Thông tin tài liệu
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** SOS Emergency — Snakebite Response
- **Phiên bản:** 2.0
- **Ngày tạo:** 10/03/2026
- **Cập nhật:** 11/04/2026 — Chuyển sang mô hình vận hành tập trung (Operator-based), tương tự Snake Catching v2.0
- **Mục đích:** Mô tả luồng nghiệp vụ chính khi bệnh nhân bị rắn cắn khẩn cấp với sự tham gia của các Actor

---

## ACTORS

| Actor | Vai trò |
|---|---|
| **Member** | Nạn nhân bị rắn cắn, kích hoạt SOS, nhận hỗ trợ và thanh toán dịch vụ sau khi hoàn thành |
| **Operator** | Nhân viên điều phối xác minh yêu cầu SOS, liên hệ nạn nhân và gán cứu hộ viên |
| **Rescuer** | Cứu hộ viên được Operator giao nhiệm vụ, di chuyển đến hiện trường, hỗ trợ sơ cứu cho Member |
| **SnakeAid System** | Nền tảng trung gian: tiếp nhận SOS, thông báo Operator, tính phí, phân chia doanh thu |
| **Payment Gateway** | Cổng thanh toán xử lý giao dịch dịch vụ từ Member |

> **Thay đổi mô hình (v2.0):** Rescuer không còn tự nhận đơn SOS. Operator là đầu mối duy nhất xác minh và phân công. Mobile nhận kết quả qua SignalR.

---

## ACTIVITY DIAGRAM TỔNG QUAN

```plantuml
@startuml SOS-Emergency-Overall
title ACTIVITY DIAGRAM - SOS SNAKE BITE FLOW (v2.0 Operator-based)

|#FFD5D5|Member|
|#FFD700|Operator|
|#LightGreen|Rescuer|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway|

|Member|
start
:Bị rắn cắn;
:Mở app SnakeAid;
:Gửi yêu cầu SOS
(vị trí GPS, ảnh rắn nếu có, mô tả triệu chứng);

|SnakeAid System|
:Tiếp nhận yêu cầu SOS
**[Status: Pending]**;
:Thông báo Operator có SOS mới;

|Operator|
:Nhận thông báo SOS & xem thông tin;
:Liên hệ xác minh với Member
**[Status: Verified]**;
:Chọn & gán Rescuer phù hợp
**[Status: Assigned]**;

|SnakeAid System|
:Gửi SignalR event đến Rescuer;
:Thông báo Member đã có Rescuer
(thông tin Rescuer, ETA);

|Rescuer|
:Nhận notification realtime (SignalR)
"Bạn được giao nhiệm vụ SOS khẩn cấp";
:Xem chi tiết nhiệm vụ;
:Di chuyển đến Member;
:Đến nơi và hỗ trợ sơ cứu;

:Hoàn thành hỗ trợ;
:Đánh dấu hoàn thành nhiệm vụ;

|SnakeAid System|
:Đóng Emergency Case
**[Status: Finished]**;
:Tính phí Rescuer;

|Member|
:Nhận thông báo thanh toán;
:Thanh toán dịch vụ;

|Payment Gateway|
:Xử lý thanh toán;

|SnakeAid System|
:Nhận kết quả thanh toán
**[Status: Completed]**;
:Phân chia phí dịch vụ cho Rescuer;

stop
@enduml
```

---

## ACTIVITY DIAGRAM CHI TIẾT THEO GIAI ĐOẠN

### Giai đoạn 1: Gửi SOS, Operator xác minh & Gán Rescuer

```plantuml
@startuml Phase-1-SOS-Operator-Assignment
title GIAI ĐOẠN 1 - GỬI SOS, OPERATOR XÁC MINH & GÁN RESCUER

|#FFD5D5|Member|
|#LightYellow|SnakeAid System|
|#FFD700|Operator|
|#LightGreen|Rescuer|

|Member|
start
:Bị rắn cắn;
:Mở app SnakeAid;
:Nhấn nút SOS khẩn cấp;
:Xác nhận vị trí GPS;
:Gửi yêu cầu SOS
(vị trí, mô tả sơ bộ, ảnh rắn nếu có,
triệu chứng);

|SnakeAid System|
:Tiếp nhận yêu cầu SOS;
:Tạo Emergency Case
**[Status: Pending]**;
:Trả về xác nhận cho Member;
:Thông báo Operator có SOS mới cần xử lý ngay;

|Member|
:Xem màn hình xác nhận SOS đã gửi
(đang tìm cứu hộ viên);
:Nhận hướng dẫn sơ cứu ban đầu từ app
trong khi chờ;

|Operator|
:Nhận thông báo SOS khẩn cấp;
:Xem thông tin & liên hệ xác minh Member
**[Status: Verified]**;
:Chọn & gán Rescuer phù hợp
**[Status: Assigned]**;

|SnakeAid System|
:Gửi SignalR event đến Rescuer được gán;
:Thông báo Member
(thông tin Rescuer, SĐT, ETA);

|Rescuer|
:Nhận notification realtime (SignalR)
"Bạn được giao nhiệm vụ SOS khẩn cấp";
:Xem chi tiết
(vị trí Member, ảnh rắn, triệu chứng);
:Bắt đầu di chuyển ngay;

|Member|
:Nhận thông báo "Đã có cứu hộ viên
 đang trên đường đến";

stop

@enduml
```

---

### Giai đoạn 2: Rescuer đến hiện trường & Hỗ trợ xử lý

```plantuml
@startuml Phase-2-OnSite-Support
title GIAI ĐOẠN 2 - RESCUER ĐẾN HIỆN TRƯỜNG & HỖ TRỢ XỬ LÝ

|#LightGreen|Rescuer|
|#FFD5D5|Member|
|#LightYellow|SnakeAid System|

|Rescuer|
start
note left: Đã được Operator gán — **[Assigned]**
:Di chuyển đến vị trí Member;

|Member|
:Theo dõi trạng thái trên app;
:Thực hiện sơ cứu theo hướng dẫn của app
trong khi chờ Rescuer;

|Rescuer|
:Đến nơi;
:Đánh giá tình trạng Member;
:Hỗ trợ sơ cứu chuyên nghiệp;
:Hoàn thành hỗ trợ tại hiện trường;
:Đánh dấu hoàn thành nhiệm vụ trên app;

|SnakeAid System|
:Nhận xác nhận hoàn thành từ Rescuer;
:Đóng Emergency Case
**[Status: Finished]**;
:Tính phí Rescuer;
:Gửi thông báo thanh toán đến Member;

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

|Member|
start
note left: Emergency Case đã đóng\nPhí dịch vụ đã được tính
:Nhận thông báo thanh toán;
:Xem chi tiết phí dịch vụ;
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
  :Phân chia phí dịch vụ cho Rescuer;

  |Rescuer|
  :Nhận thanh toán vào tài khoản;

  |Member|
  :Nhận xác nhận thanh toán thành công;
  :Đánh giá Rescuer (tùy chọn);
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
title LUỒNG TRẠNG THÁI EMERGENCY CASE (v2.0)

[*] --> Pending : Member gửi SOS

Pending --> Verified : Operator xác minh
(đã liên hệ nạn nhân)
Pending --> Cancelled : Hủy (sai / giả)

Verified --> Assigned : Operator gán Rescuer
(SignalR → Rescuer app)
Verified --> Cancelled : Không tìm được Rescuer

Assigned --> InProgress : Rescuer đang di chuyển
/ đang hỗ trợ tại hiện trường
InProgress --> Finished : Rescuer hoàn thành hỗ trợ

Finished --> Completed : Member thanh toán thành công

Cancelled --> [*]
Completed --> [*]

note right of Assigned
  Mission sub-statuses:
  Preparing → EnRoute → Arrived → MissionCompleted
end note

note right of InProgress
  Rescuer đang hỗ trợ
  tại hiện trường
end note

note right of Finished
  SnakeAid System tính phí Rescuer
  → Gửi thông báo thanh toán cho Member
end note

@enduml
```

---

## GHI CHÚ NGHIỆP VỤ

### Thay đổi mô hình v2.0 (Operator-based)
| Tính năng | v1.1 (cũ) | v2.0 (hiện tại) |
|---|---|---|
| Phân công Rescuer | Hệ thống broadcast alert, Rescuer tự nhận | Operator xác minh và gán trực tiếp |
| Trạng thái trung gian | Không có | `Verified` (Operator xác minh với nạn nhân) |
| Thông báo Rescuer | Push notification broadcast | SignalR event chỉ định |
| Khả năng hủy broadcast | Không có | Operator có thể hủy nếu SOS giả |

### Quy tắc thanh toán SOS
| Yếu tố | Chi tiết |
|---|---|
| **Thời điểm thanh toán** | Sau khi Rescuer hoàn thành hỗ trợ (`Finished`) — post-service, 100% |
| **Thành phần phí** | Phí Rescuer |
| **Phương thức** | PayOS hoặc Ví SnakeAidPay |
| **Phân chia** | SnakeAid System phân chia tự động sau khi nhận thanh toán |

### Vai trò Operator trong SOS
- Operator nhận thông báo ưu tiên cao ngay khi có SOS mới
- Operator **liên hệ xác minh** với Member (loại trừ SOS giả)
- Operator cập nhật trạng thái `Verified` rồi **chọn và gán** Rescuer phù hợp
- Rescuer nhận nhiệm vụ qua **SignalR event chỉ định** — không tự nhận
