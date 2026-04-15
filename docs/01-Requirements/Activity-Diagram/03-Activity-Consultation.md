# ACTIVITY DIAGRAM - LUỒNG TƯ VẤN CHUYÊN GIA (CONSULTATION)

## Thông tin tài liệu
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** Expert Consultation — Tư vấn trực tiếp & Đặt lịch hẹn
- **Phiên bản:** 1.0
- **Ngày tạo:** 11/04/2026
- **Mục đích:** Mô tả luồng nghiệp vụ chính của dịch vụ tư vấn chuyên gia (ngay lập tức và đặt lịch hẹn) với sự tham gia của các Actor

---

## ACTORS

| Actor | Vai trò |
|---|---|
| **Member** | Người dùng tìm kiếm tư vấn, đặt lịch / tư vấn ngay và thanh toán phí dịch vụ |
| **Expert** | Chuyên gia thực hiện tư vấn qua video call, nhận phí sau khi phiên hoàn thành |
| **SnakeAid System** | Nền tảng trung gian quản lý booking, phòng chờ, trạng thái và phân chia doanh thu |
| **Payment Gateway** | Cổng thanh toán xử lý giao dịch và giữ tiền Escrow đến khi tư vấn hoàn thành |

---

## ACTIVITY DIAGRAM TỔNG QUAN

```plantuml
@startuml Consultation-Overall
title ACTIVITY DIAGRAM - LUỒNG TƯ VẤN CHUYÊN GIA TỔNG QUAN

|#FFD5D5|Member|
|#D5E8FF|Expert|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway|

|Member|
start
:Xem danh sách chuyên gia;
:Chọn chuyên gia phù hợp;

if (Loại tư vấn?) then (Ngay lập tức)
  |SnakeAid System|
  :Kiểm tra Expert đang online & khả dụng;
  |Member|
else (Đặt lịch hẹn)
  |Member|
  :Chọn ngày & khung giờ trống;
endif

:Xác nhận & thanh toán phí tư vấn;

|Payment Gateway|
:Xử lý giao dịch ConsultationFee;
:Giữ tiền Escrow;

|SnakeAid System|
:Tạo Booking
**[Status: Confirmed]**;
:Tạo Waiting Room (ngay / đúng giờ hẹn);
:Thông báo cho Member & Expert;

|Expert|
:Nhận thông báo & vào Waiting Room;

|Member|
:Vào Waiting Room;

|SnakeAid System|
:Bắt đầu phiên Video Consultation
**[Status: InProgress]**;

|Member|
:Thực hiện tư vấn qua video;

|Expert|
:Tư vấn cho Member;

|Member|
:Kết thúc phiên tư vấn;
:Đánh giá & nhận xét Expert;

|SnakeAid System|
:Kết thúc Booking
**[Status: Completed]**;

|Payment Gateway|
:Giải phóng tiền Escrow → Expert;

stop
@enduml
```

---

## ACTIVITY DIAGRAM CHI TIẾT THEO GIAI ĐOẠN

### Giai đoạn 1A: Tư vấn ngay lập tức

```plantuml
@startuml Phase-1A-Instant-Consultation
title GIAI ĐOẠN 1A - TƯ VẤN NGAY LẬP TỨC

|#FFD5D5|Member|
|#LightYellow|SnakeAid System|
|#D5E8FF|Expert|
|#FFE0CC|Payment Gateway|

|Member|
start
:Xem danh sách chuyên gia;
:Lọc theo chuyên môn / đánh giá;
:Chọn Expert đang online;
:Nhấn "Tư Vấn Ngay";

|SnakeAid System|
:Kiểm tra trạng thái Expert;
if (Expert đang khả dụng?) then (Không)
  :Thông báo "Expert hiện không khả dụng";
  |Member|
  :Chọn Expert khác hoặc đặt lịch hẹn;
  stop
else (Có)
endif
:Tạo Booking tạm thời
**[Status: Pending]**;
:Khóa slot của Expert;

|Member|
:Xem màn hình xác nhận
(tên Expert, phí tư vấn, thời lượng);
:Chọn phương thức & xác nhận thanh toán;

|Payment Gateway|
:Xử lý giao dịch ConsultationFee;
:Giữ tiền Escrow;

|SnakeAid System|
:Xác nhận thanh toán thành công;
:Cập nhật Booking
**[Status: Confirmed]**;
:Tạo Waiting Room;
:Thông báo Expert có tư vấn ngay;

|Expert|
:Nhận notification realtime;
:Vào Waiting Room;

|Member|
:Nhận thông báo "Expert đã sẵn sàng";
:Vào Waiting Room;

|SnakeAid System|
:Bắt đầu phiên tư vấn
**[Status: InProgress]**;

stop
@enduml
```

---

### Giai đoạn 1B: Đặt lịch hẹn

```plantuml
@startuml Phase-1B-Scheduled-Consultation
title GIAI ĐOẠN 1B - ĐẶT LỊCH HẸN TƯ VẤN

|#FFD5D5|Member|
|#LightYellow|SnakeAid System|
|#D5E8FF|Expert|
|#FFE0CC|Payment Gateway|

|Member|
start
:Xem danh sách chuyên gia;
:Chọn Expert;
:Nhấn "Đặt Lịch Hẹn";
:Xem lịch trống của Expert;
:Chọn ngày & khung giờ;
:Xem tóm tắt xác nhận
(ngày giờ, phí tư vấn, thời lượng);
:Chọn phương thức & xác nhận thanh toán;

|Payment Gateway|
:Xử lý giao dịch ConsultationFee;
:Giữ tiền Escrow;

|SnakeAid System|
:Tạo Booking
**[Status: Confirmed]**;
:Khóa slot trong lịch của Expert;
:Gửi xác nhận lịch hẹn cho Member & Expert;

|Expert|
:Nhận thông báo có lịch hẹn mới
(ngày giờ, thông tin Member);

|Member|
:Nhận xác nhận lịch hẹn;
note right
  Trước giờ hẹn ~15 phút:
  SnakeAid System gửi reminder
  cho cả Member và Expert
end note

|SnakeAid System|
:Đến giờ hẹn → Tạo Waiting Room;
:Gửi thông báo "Đã đến giờ tư vấn";

|Expert|
:Nhận thông báo & vào Waiting Room;

|Member|
:Nhận thông báo & vào Waiting Room;

|SnakeAid System|
:Bắt đầu phiên tư vấn
**[Status: InProgress]**;

stop
@enduml
```

---

### Giai đoạn 2: Diễn ra phiên tư vấn & Hoàn thành

```plantuml
@startuml Phase-2-Consultation-Session
title GIAI ĐOẠN 2 - PHIÊN TƯ VẤN & HOÀN THÀNH

|#FFD5D5|Member|
|#D5E8FF|Expert|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway|

|Member|
start
note left: Booking **[InProgress]**
:Thực hiện tư vấn qua Video Call;

|Expert|
:Tư vấn cho Member
(nhận diện loài rắn, hướng xử lý,
hướng dẫn y tế đặc thù);

|Member|
:Đặt câu hỏi, chia sẻ ảnh rắn nếu cần;

|Expert|
:Trả lời và hướng dẫn xử lý;

|Member|
:Kết thúc phiên tư vấn;

|SnakeAid System|
:Kết thúc Waiting Room & Video Call;
:Cập nhật Booking
**[Status: Completed]**;

|Payment Gateway|
:Giải phóng tiền Escrow → Expert;

|Expert|
:Nhận thông báo thanh toán thành công;

|Member|
:Nhận thông báo phiên tư vấn hoàn tất;
:Đánh giá & nhận xét Expert (tùy chọn);

|SnakeAid System|
:Lưu lịch sử tư vấn;
:Phân chia doanh thu (nếu áp dụng);

stop
@enduml
```

---

### Giai đoạn 3: Hủy lịch hẹn

```plantuml
@startuml Phase-3-Cancel-Booking
title GIAI ĐOẠN 3 - HỦY LỊCH HẸN

|#FFD5D5|Member|
|#D5E8FF|Expert|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway|

|Expert|
start
note right
  Điều kiện được phép hủy:
  - Booking đang **Confirmed**
  - Lưu ý: Chỉ Expert mới có quyền hủy
end note
:Chọn "Hủy lịch hẹn";
:Chọn lý do hủy;
:Xác nhận hủy;

|SnakeAid System|
:Cập nhật Booking
**[Status: Cancelled]**;

|Payment Gateway|
:Hoàn tiền Escrow 100% về Member;

|SnakeAid System|
:Gửi thông báo hủy đến Member;

|Member|
:Nhận thông báo & nhận hoàn tiền;

stop
@enduml
```

---

## TỔNG HỢP CÁC TRẠNG THÁI BOOKING

```plantuml
@startuml Consultation-Status-Flow
title LUỒNG TRẠNG THÁI BOOKING TƯ VẤN

[*] --> Pending : Member tạo booking\n(đang xử lý thanh toán)

Pending --> Confirmed : Thanh toán Escrow thành công
Pending --> Cancelled : Thanh toán thất bại

Confirmed --> InProgress : Cả hai vào Waiting Room\n(đúng giờ / ngay lập tức)
Confirmed --> Cancelled : Expert hủy lịch hẹn

InProgress --> Completed : Phiên tư vấn kết thúc\n(Escrow giải phóng cho Expert)
InProgress --> Disputed : Có tranh chấp\n(xử lý thủ công)

Disputed --> Completed : Giải quyết xong

Cancelled --> [*]
Completed --> [*]

note right of Confirmed
  Scheduled: chờ đến giờ hẹn
  Instant: vào Waiting Room ngay
end note

@enduml
```

---

## GHI CHÚ NGHIỆP VỤ

### So sánh 2 loại tư vấn
| Tiêu chí | Tư vấn ngay (Instant) | Đặt lịch hẹn (Scheduled) |
|---|---|---|
| Điều kiện | Expert đang online & khả dụng | Expert có slot trống |
| Thời gian bắt đầu | Ngay lập tức | Theo lịch đã đặt |
| Thanh toán | Trước khi vào Waiting Room | Khi xác nhận đặt lịch |
| Hủy | Chỉ Expert được hủy (Member không có quyền) | Chỉ Expert được hủy (Member không có quyền) |

### Cơ chế thanh toán Escrow
| Bước | Thời điểm | Hành động |
|---|---|---|
| Giữ tiền | Khi Booking `Confirmed` | Payment Gateway khóa tiền của Member |
| Giải phóng | Khi Booking `Completed` | Chuyển cho Expert sau khi tư vấn xong |
| Hoàn trả | Khi Booking `Cancelled` (do Expert hủy) | Hoàn 100% về ví / tài khoản Member |

### Quy tắc hủy & hoàn tiền
- **Member không được phép hủy lịch hẹn** (trên UI Member không có tính năng Hủy).
- **Expert hủy lịch**: Hoàn tiền **100%** cho Member.
- Không được hủy khi Booking đang `InProgress`

---

