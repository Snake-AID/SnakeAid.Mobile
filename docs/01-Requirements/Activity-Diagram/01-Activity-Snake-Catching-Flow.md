# ACTIVITY DIAGRAM - LUỒNG BẮT RẮN (SNAKE CATCHING)

## Thông tin tài liệu
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** Snake Catching Request
- **Phiên bản:** 2.0
- **Ngày tạo:** 10/03/2026
- **Cập nhật:** 19/03/2026 — Chuyển sang mô hình vận hành tập trung (Operator-based)
- **Mục đích:** Mô tả luồng nghiệp vụ chính của dịch vụ bắt rắn với sự tham gia của các Actor

---

## ACTORS

| Actor | Vai trò |
|---|---|
| **Member** | Người dùng phát hiện rắn, tạo yêu cầu và thanh toán dịch vụ |
| **Operator** | Nhân viên điều phối xác nhận yêu cầu, liên hệ khách và gán cứu hộ viên |
| **Rescuer** | Cứu hộ viên được Operator giao nhiệm vụ, thực hiện bắt rắn |
| **SnakeAid System** | Nền tảng trung gian xử lý thông báo realtime, thanh toán, trạng thái đơn |
| **Payment Gateway (PayOS)** | Cổng thanh toán trực tuyến (kênh thanh toán tùy chọn) |

> **Thay đổi mô hình (v2.0):** Rescuer không còn tự nhận đơn. Operator là đầu mối duy nhất xác nhận và phân công. Mobile chỉ nhận kết quả qua SignalR.

---

## ACTIVITY DIAGRAM TỔNG QUAN

```plantuml
@startuml Snake-Catching-Overall
title ACTIVITY DIAGRAM - LUỒNG BẮT RẮN TỔNG QUAN (v2.0 Operator-based)

|#LightBlue|Member|
|#FFD700|Operator|
|#LightGreen|Rescuer|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway (PayOS)|

|Member|
start
:Phát hiện rắn;
:Mở app SnakeAid;
:Tạo yêu cầu bắt rắn
(chụp ảnh, chọn loài, mô tả vị trí);
:Gửi yêu cầu;

|SnakeAid System|
:Tiếp nhận yêu cầu
**[Status: Pending]**;
:Tính estimatedPrice & distanceKm;
:Trả dữ liệu đơn cho Member;
:Thông báo Operator có đơn mới;

|Member|
:Xem màn hình thành công
(estimatedPrice & distanceKm hiển thị);
:Thanh toán đặt cọc (Round 1)
ở bất kỳ thời điểm:
**Pending / Confirmed / Assigned**;
note right
  Phương thức:
  - PayOS (online)
  - Ví SnakeAidPay
end note

fork
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingDeposit;
  :Xác nhận thanh toán;
fork again
  |SnakeAid System|
  :Xử lý thanh toán qua Ví;
end fork

|SnakeAid System|
:Xác nhận CatchingDeposit thành công;

|Operator|
:Nhận thông báo đơn mới;
:Xem thông tin yêu cầu
(địa điểm, loài rắn, ảnh);
:Gọi xác nhận với khách hàng;
:Cập nhật trạng thái
**[Status: Confirmed]**;
:Chọn cứu hộ viên phù hợp;
:Gán Rescuer vào đơn
**[Status: Assigned]**;

|SnakeAid System|
:Gửi SignalR event đến Rescuer;
:Thông báo Member đã có Rescuer
(thông tin Rescuer, SĐT);

|Rescuer|
:Nhận notification realtime (SignalR)
"Bạn được giao một nhiệm vụ bắt rắn";
:Xem chi tiết nhiệm vụ;
:Bắt đầu di chuyển
**(Mission: EnRoute)**;

|Member|
:Theo dõi trạng thái trên app;

|Rescuer|
:Đến nơi
**(Mission: Arrived)**;
:Khảo sát hiện trường;
:Thực hiện bắt rắn;
:Ghi nhận kết quả
(loài, số lượng, ảnh bằng chứng);
:Đánh dấu hoàn thành nhiệm vụ;

|SnakeAid System|
:Cập nhật trạng thái đơn
**[Status: Finished]**;
:Tính actualCost
= baseFee + snakeFee + envFee;
:Gửi thông báo thanh toán lần 2 đến Member;

|Member|
:Nhận thông báo cần thanh toán;
:Xem chi tiết dịch vụ (loài bắt được, ảnh, chi phí);
:Thanh toán lần 2
(phí dịch vụ thực tế - Round 2);
note right
  Phương thức:
  - PayOS (online)
  - Ví SnakeAidPay
end note

fork
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingPayment;
  :Xác nhận thanh toán;
fork again
  |SnakeAid System|
  :Xử lý thanh toán qua Ví;
end fork

|SnakeAid System|
:Xác nhận CatchingPayment thành công;
:Cập nhật đơn hoàn tất
**[Status: Completed]**;
:Gửi thông báo hoàn tất cho cả hai bên;

|Member|
:Nhận thông báo dịch vụ hoàn tất;
:Đánh giá Rescuer (tùy chọn);

|Rescuer|
:Nhận thông báo nhiệm vụ hoàn tất;

|SnakeAid System|
:Lưu lịch sử đơn hoàn thành;

stop

@enduml
```

---

## ACTIVITY DIAGRAM CHI TIẾT THEO GIAI ĐOẠN

### Giai đoạn 1: Tạo yêu cầu & Thanh toán đặt cọc

```plantuml
@startuml Phase-1-Request-Deposit
title GIAI ĐOẠN 1 - TẠO YÊU CẦU & THANH TOÁN ĐẶT CỌC

|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#FFD700|Operator|

|Member|
start
:Phát hiện rắn;
:Chụp ảnh / mô tả loài rắn;
:Nhập thông tin yêu cầu
- Địa chỉ cụ thể
- Số lượng / loài rắn
- Mô tả bổ sung;
:Gửi yêu cầu bắt rắn;

|SnakeAid System|
:Tạo đơn mới
**[Status: Pending]**;
:Tính toán estimatedPrice
và distanceKm từ vị trí khách;
:Trả response cho app (có đủ giá ước tính);
:Thông báo Operator có đơn mới cần xử lý;

|Member|
:Xem màn hình xác nhận thành công
(hiển thị mã đơn, estimatedPrice, distanceKm);
note right
  Khách có thể thanh toán đặt cọc
  ngay tại đây để ưu tiên xử lý
end note
:Nhấn "Thanh Toán Đặt Cọc";
:Đến activity_detail_screen;

if (Thanh toán ngay?) then (Có)
  :Chọn phương thức thanh toán;
  if (Phương thức?) then (PayOS)
    :Mở cổng thanh toán PayOS;
    :Xác nhận giao dịch;
    |SnakeAid System|
    :Nhận callback thanh toán thành công;
  else (Ví SnakeAidPay)
    |SnakeAid System|
    :Trừ số dư ví của Member;
  endif
  |SnakeAid System|
  :Ghi nhận CatchingDeposit thành công;
else (Sau)
  note right
    Member có thể thanh toán sau
    ở bất kỳ trạng thái:
    Pending / Confirmed / Assigned
  end note
endif

|Operator|
:Nhận thông báo đơn mới;
:Xem chi tiết đơn
(địa điểm, loài rắn, ảnh, thông tin khách);
:Gọi điện xác nhận với khách hàng;
:Cập nhật
**[Status: Confirmed]**;

|SnakeAid System|
:Thông báo Member đơn đã được xác nhận;

stop

@enduml
```

---

### Giai đoạn 2: Phân công Rescuer & Di chuyển

```plantuml
@startuml Phase-2-Assignment-Enroute
title GIAI ĐOẠN 2 - PHÂN CÔNG & DI CHUYỂN ĐẾN HIỆN TRƯỜNG

|#FFD700|Operator|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|
|#LightBlue|Member|

|Operator|
start
note left: Đơn đang ở **[Confirmed]**
:Xem danh sách cứu hộ viên
đang online, gần khu vực;
:Chọn cứu hộ viên phù hợp;
:Gán Rescuer vào đơn;

|SnakeAid System|
:Cập nhật đơn
**[Status: Assigned]**;
:Gửi SignalR event đến Rescuer;
:Thông báo Member
(thông tin Rescuer + SĐT);

|Rescuer|
:Nhận notification realtime
"Bạn được giao nhiệm vụ bắt rắn";
:Xem chi tiết tại rescuer_available_jobs;
:Bắt đầu di chuyển;
:Cập nhật
**(Mission: EnRoute)**;

|Member|
:Nhận thông báo "Đã có cứu hộ viên";
:Xem thông tin Rescuer trên app;

|Rescuer|
:Đến nơi;
:Cập nhật
**(Mission: Arrived)**;

|SnakeAid System|
:Thông báo Member "Cứu hộ viên đã đến nơi";

stop

@enduml
```

---

### Giai đoạn 3: Thực hiện nhiệm vụ & Thanh toán dịch vụ

```plantuml
@startuml Phase-3-Mission-Payment
title GIAI ĐOẠN 3 - THỰC HIỆN NHIỆM VỤ & THANH TOÁN DỊCH VỤ

|#LightGreen|Rescuer|
|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway (PayOS)|

|Rescuer|
start
note left: Mission trạng thái **Arrived**
:Khảo sát hiện trường;
:Thực hiện bắt rắn;
:Ghi nhận kết quả:
- Loài rắn bắt được
- Số lượng
- Chụp ảnh bằng chứng;
:Xác nhận kết quả nhiệm vụ;
:Đánh dấu hoàn thành nhiệm vụ;

|SnakeAid System|
:Cập nhật đơn
**[Status: Finished]**;
:Tính actualCost
= baseFee + snakeFee + envFee;
:Gửi thông báo thanh toán
đến Member;

|Member|
:Nhận thông báo;
:Xem chi tiết dịch vụ đã thực hiện
(loài bắt được, ảnh, chi phí);
:Chọn phương thức thanh toán Round 2;

if (Phương thức?) then (PayOS)
  :Mở cổng thanh toán PayOS;
  |Payment Gateway (PayOS)|
  :Hiển thị trang thanh toán;
  |Member|
  :Xác nhận giao dịch;
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingPayment;
  :Redirect về app;
  |SnakeAid System|
  :Nhận callback từ PayOS;
else (Ví SnakeAidPay)
  |SnakeAid System|
  :Trừ số dư ví của Member;
endif

|SnakeAid System|
:Xác nhận CatchingPayment thành công;
:Cập nhật đơn hoàn tất
**[Status: Completed]**;
:Gửi thông báo hoàn tất cho cả hai bên;

|Member|
:Nhận thông báo dịch vụ hoàn tất;
:Đánh giá Rescuer (tùy chọn);

|Rescuer|
:Nhận thông báo nhiệm vụ hoàn tất;

stop

@enduml
```

---

### Giai đoạn 4: Luồng hủy đơn

```plantuml
@startuml Phase-4-Cancel
title GIAI ĐOẠN 4 - HỦY YÊU CẦU

|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|

|Member|
start
note left
  Điều kiện được phép hủy:
  - Đơn đang **Pending** (bất kỳ lúc nào)
  - Đơn đang **Confirmed** (chưa phân công)
  - Đơn đang **Assigned** với
    mission còn ở trạng thái **Preparing**
end note
:Chọn "Hủy yêu cầu";
:Chọn lý do hủy;
:Xác nhận hủy;

|SnakeAid System|
:Cập nhật đơn
**[Status: Cancelled]**;

if (Đã đặt cọc?) then (Có)
  :Xử lý hoàn tiền đặt cọc;
  |Member|
  :Nhận hoàn tiền vào ví / tài khoản;
else (Chưa đặt cọc)
  |SnakeAid System|
  :Không có giao dịch hoàn trả;
endif

|SnakeAid System|
:Gửi thông báo hủy đến Rescuer
(nếu đã được Assigned);

|Rescuer|
:Nhận thông báo đơn bị hủy;
:Đơn chuyển sang danh sách lịch sử;

stop

@enduml
```

---

## TỔNG HỢP CÁC TRẠNG THÁI ĐƠN

```plantuml
@startuml Status-Flow
title LUỒNG TRẠNG THÁI ĐƠN BẮT RẮN (v2.0)

[*] --> Pending : Member tạo yêu cầu\n(có estimatedPrice & distanceKm)

Pending --> Confirmed : Operator xác nhận\n(đã gọi kiểm tra với khách)
Pending --> Expired : Hết thời gian chờ\nOperator không xử lý
Pending --> Cancelled : Member hủy

Confirmed --> Assigned : Operator gán Rescuer\n(SignalR → Rescuer app)
Confirmed --> Cancelled : Member hủy\n(chưa phân công)

Assigned --> Finished : Rescuer hoàn thành nhiệm vụ\n(đã ghi nhận kết quả)
Assigned --> Cancelled : Member hủy\n(Mission còn Preparing)

Finished --> Completed : Member thanh toán Round 2\n(CatchingPayment)

note right of Pending
  CatchingDeposit có thể thanh toán
  ở Pending / Confirmed / Assigned
end note

note right of Assigned
  Mission sub-statuses:
  Preparing → EnRoute → Arrived → MissionCompleted
end note

@enduml
```

---

## GHI CHÚ NGHIỆP VỤ

### Thay đổi mô hình v2.0 (Operator-based)
| Tính năng | v1.0 (cũ) | v2.0 (hiện tại) |
|---|---|---|
| Phân công Rescuer | Rescuer tự nhận đơn (Accept/Reject) | Operator gán trực tiếp |
| Thông báo Rescuer | Push notification broadcast | SignalR event chỉ định |
| Trạng thái trung gian | Không có | `Confirmed` (Operator xác nhận với khách) |
| Transfer tiền cho Rescuer | `POST /api/v1/payos/transfer-to-rescuer` | Đã bỏ — mô hình trung tâm |
| Trạng thái `Paid` | Có | Đã bỏ — chuyển thẳng sang `Completed` |

### Quy tắc thanh toán 2 vòng
| Vòng | Thời điểm | Loại giao dịch | Nội dung |
|---|---|---|---|
| Round 1 | Ngay sau tạo đơn (Pending / Confirmed / Assigned) | `CatchingDeposit` | Phí di chuyển ước tính (estimatedPrice) |
| Round 2 | Sau khi Rescuer hoàn thành (Finished) | `CatchingPayment` | Phí dịch vụ thực tế (baseFee + snakeFee + envFee) |

### Luồng thanh toán Round 1 (Deposit)
- API kiểm tra: `GET /api/transactions/snakecatchingrequest/{id}` → `transactionType == CatchingDeposit`
- Cho phép thanh toán tại: `Pending`, `Confirmed`, `Assigned`
- `estimatedPrice` và `distanceKm` được trả ngay từ response tạo đơn → hiển thị ngay trên màn hình thành công

### Quyền hủy đơn
- Trạng thái `Pending`: Member được hủy tự do
- Trạng thái `Confirmed`: Member được hủy (Operator chưa phân công Rescuer)
- Trạng thái `Assigned` & Mission = `Preparing`: Member được hủy (Rescuer chưa di chuyển)
- Trạng thái `Assigned` & Mission = `EnRoute/Arrived`: **Không** được hủy


---

## ACTIVITY DIAGRAM TỔNG QUAN

```plantuml
@startuml Snake-Catching-Overall
title ACTIVITY DIAGRAM - LUỒNG BẮT RẮN TỔNG QUAN

|#LightBlue|Member|
|#LightGreen|Rescuer|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway (PayOS)|

|Member|
start
:Phát hiện rắn;
:Mở app SnakeAid;
:Tạo yêu cầu bắt rắn
(chụp ảnh, chọn loài, mô tả vị trí);
:Gửi yêu cầu;

|SnakeAid System|
:Tiếp nhận yêu cầu
**[Status: Pending]**;
:Phân phối thông báo
đến các Rescuer trong khu vực;

|Rescuer|
:Nhận thông báo đơn mới;
:Xem thông tin yêu cầu
(địa điểm, loài rắn, khoảng cách);
if (Chấp nhận?) then (Có)
  :Nhấn "Chấp nhận yêu cầu";
else (Không / Bỏ qua)
  stop
endif

|SnakeAid System|
:Gán Rescuer vào đơn
**[Status: Assigned]**;
:Gửi thông báo đến Member;

|Member|
:Nhận thông báo đã có Rescuer;
:Thanh toán đặt cọc lần 1
(phí di chuyển - Round 1);
note right
  Phương thức:
  - PayOS (online)
  - Ví SnakeAidPay
end note

fork
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingDeposit;
  :Xác nhận thanh toán;
fork again
  |SnakeAid System|
  :Xử lý thanh toán qua Ví;
end fork

|SnakeAid System|
:Xác nhận đặt cọc thành công;
:Thông báo cho Rescuer;

|Rescuer|
:Nhận xác nhận đặt cọc;
:Bắt đầu di chuyển đến hiện trường
**(Mission: EnRoute)**;

|Member|
:Theo dõi trạng thái trên app;

|Rescuer|
:Đến nơi
**(Mission: Arrived)**;
:Khảo sát hiện trường;
:Thực hiện bắt rắn;
:Ghi nhận kết quả nhiệm vụ
(loài bắt được, số lượng, ảnh bằng chứng);
:Đánh dấu hoàn thành nhiệm vụ;

|SnakeAid System|
:Cập nhật trạng thái đơn
**[Status: Finished]**;
:Tính toán chi phí dịch vụ thực tế
(actualCost = baseFee + snakeFee + envFee);
:Gửi thông báo thanh toán đến Member;

|Member|
:Nhận thông báo cần thanh toán;
:Xem chi tiết chi phí dịch vụ;
:Thanh toán lần 2
(phí dịch vụ thực tế - Round 2);
note right
  Phương thức:
  - PayOS (online)
  - Ví SnakeAidPay
end note

fork
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingPayment;
  :Xác nhận thanh toán;
fork again
  |SnakeAid System|
  :Xử lý thanh toán qua Ví;
end fork

|SnakeAid System|
:Xác nhận thanh toán Round 2
**[Status: Paid]**;
:Gọi API thanh khoản
POST /api/v1/payos/transfer-to-rescuer;
:Chuyển tiền cho Rescuer;
:Cập nhật trạng thái hoàn tất
**[Status: Completed]**;

|Member|
:Nhận thông báo dịch vụ hoàn tất;
:Đánh giá Rescuer (tuỳ chọn);

|Rescuer|
:Nhận tiền thanh toán;

|SnakeAid System|
:Lưu lịch sử đơn hoàn thành;

stop

@enduml
```

---

## ACTIVITY DIAGRAM CHI TIẾT THEO GIAI ĐOẠN

### Giai đoạn 1: Tạo yêu cầu & Matching

```plantuml
@startuml Phase-1-Request-Matching
title GIAI ĐOẠN 1 - TẠO YÊU CẦU & MATCHING

|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|

|Member|
start
:Phát hiện rắn;
:Chụp ảnh / mô tả loài rắn;
:Nhập thông tin yêu cầu
- Địa chỉ cụ thể
- Số lượng rắn
- Mô tả bổ sung;
:Gửi yêu cầu bắt rắn;

|SnakeAid System|
:Tạo đơn mới
**[Status: Pending]**;
:Xác định các Rescuer
đang online trong bán kính phù hợp;
:Gửi push notification
đến Rescuer phù hợp;

|Rescuer|
:Nhận thông báo có đơn mới;
:Xem chi tiết đơn
(loài rắn, địa điểm, khoảng cách, mức giá ước tính);

if (Quyết định nhận đơn?) then (Chấp nhận)
  :Nhấn "Chấp nhận yêu cầu";

  |SnakeAid System|
  :Gán Rescuer vào đơn
  **[Status: Assigned]**;
  :Thông báo cho Member
  (thông tin Rescuer, SĐT);
  :Thông báo cho các Rescuer khác
  (đơn đã được nhận);
  stop

else (Từ chối / Hết hạn)
  |SnakeAid System|
  :Tiếp tục tìm Rescuer khác;
  :Hết thời gian chờ?;
  if (Có Rescuer nhận?) then (Không)
    :Đơn hết hạn
    **[Status: Expired]**;
    |Member|
    :Nhận thông báo không có Rescuer;
    stop
  else (Có)
    stop
  endif
endif

@enduml
```

---

### Giai đoạn 2: Thanh toán đặt cọc & Di chuyển

```plantuml
@startuml Phase-2-Deposit-Enroute
title GIAI ĐOẠN 2 - ĐẶT CỌC & DI CHUYỂN ĐẾN HIỆN TRƯỜNG

|#LightBlue|Member|
|#LightGreen|Rescuer|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway (PayOS)|

|Member|
start
note left: Đơn đang ở **[Assigned]**
:Xem thông tin chi tiết
phí di chuyển ước tính;
:Chọn phương thức thanh toán;

if (Phương thức?) then (PayOS)
  :Mở cổng thanh toán PayOS;
  |Payment Gateway (PayOS)|
  :Hiển thị trang thanh toán;
  |Member|
  :Xác nhận giao dịch;
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch;
  :Redirect về app;
  |SnakeAid System|
  :Nhận callback từ PayOS;
else (Ví SnakeAidPay)
  |SnakeAid System|
  :Trừ số dư ví của Member;
endif

|SnakeAid System|
:Xác nhận CatchingDeposit thành công;
:Cập nhật trạng thái thanh toán đặt cọc;
:Gửi thông báo cho Rescuer;

|Rescuer|
:Nhận xác nhận đặt cọc;
:Bắt đầu di chuyển;
:Cập nhật trạng thái
**(Mission: EnRoute)**;

|SnakeAid System|
:Thông báo cho Member
"Rescuer đang trên đường đến";

|Member|
:Theo dõi trạng thái;

|Rescuer|
:Đến nơi;
:Cập nhật trạng thái
**(Mission: Arrived)**;

|SnakeAid System|
:Thông báo cho Member
"Rescuer đã đến nơi";

stop

@enduml
```

---

### Giai đoạn 3: Thực hiện nhiệm vụ & Thanh toán dịch vụ

```plantuml
@startuml Phase-3-Mission-Payment
title GIAI ĐOẠN 3 - THỰC HIỆN NHIỆM VỤ & THANH TOÁN DỊCH VỤ

|#LightGreen|Rescuer|
|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#FFE0CC|Payment Gateway (PayOS)|

|Rescuer|
start
note left: Mission trạng thái **Arrived**
:Khảo sát hiện trường;
:Thực hiện bắt rắn;
:Ghi nhận kết quả:
- Loài rắn bắt được
- Số lượng
- Chụp ảnh bằng chứng;
:Nhập chi phí thực tế
(nếu khác ước tính);
:Đánh dấu hoàn thành nhiệm vụ;

|SnakeAid System|
:Cập nhật đơn
**[Status: Finished]**;
:Tính actualCost
= baseFee + snakeFee + envFee;
:Gửi thông báo thanh toán
đến Member;

|Member|
:Nhận thông báo;
:Xem chi tiết dịch vụ đã thực hiện
(loài bắt được, ảnh, chi phí);
:Chọn phương thức thanh toán Round 2;

if (Phương thức?) then (PayOS)
  :Mở cổng thanh toán PayOS;
  |Payment Gateway (PayOS)|
  :Hiển thị trang thanh toán;
  |Member|
  :Xác nhận giao dịch;
  |Payment Gateway (PayOS)|
  :Xử lý giao dịch CatchingPayment;
  :Redirect về app;
  |SnakeAid System|
  :Nhận callback từ PayOS;
else (Ví SnakeAidPay)
  |SnakeAid System|
  :Trừ số dư ví của Member;
endif

|SnakeAid System|
:Xác nhận CatchingPayment thành công
**[Status: Paid]**;
:Gọi API thanh khoản
**POST /api/v1/payos/transfer-to-rescuer**;
:Chuyển tiền dịch vụ cho Rescuer;
:Cập nhật đơn hoàn tất
**[Status: Completed]**;
:Gửi thông báo hoàn tất cho cả hai bên;

|Member|
:Nhận thông báo dịch vụ hoàn tất;
:Đánh giá Rescuer (tùy chọn);

|Rescuer|
:Nhận thông báo thanh toán thành công;
:Tiền được chuyển vào tài khoản;

stop

@enduml
```

---

### Giai đoạn 4: Luồng hủy đơn

```plantuml
@startuml Phase-4-Cancel
title GIAI ĐOẠN 4 - HỦY YÊU CẦU

|#LightBlue|Member|
|#LightYellow|SnakeAid System|
|#LightGreen|Rescuer|

|Member|
start
note left
  Điều kiện được phép hủy:
  - Đơn đang **Pending** (bất kỳ lúc nào)
  - Đơn đang **Assigned** với
    mission còn ở trạng thái **Preparing**
end note
:Chọn "Hủy yêu cầu";
:Chọn lý do hủy;
:Xác nhận hủy;

|SnakeAid System|
:Cập nhật đơn
**[Status: Cancelled]**;

if (Đã đặt cọc?) then (Có)
  :Xử lý hoàn tiền đặt cọc;
  |Member|
  :Nhận hoàn tiền vào ví / tài khoản;
else (Chưa đặt cọc)
  |SnakeAid System|
  :Không có giao dịch hoàn trả;
endif

|SnakeAid System|
:Gửi thông báo hủy đến Rescuer
(nếu đã được Assigned);

|Rescuer|
:Nhận thông báo đơn bị hủy;
:Đơn chuyển sang danh sách lịch sử;

stop

@enduml
```

---

## TỔNG HỢP CÁC TRẠNG THÁI ĐƠN

```plantuml
@startuml Status-Flow
title LUỒNG TRẠNG THÁI ĐƠN BẮT RẮN

[*] --> Pending : Member tạo yêu cầu

Pending --> Assigned : Rescuer chấp nhận
Pending --> Expired : Hết thời gian chờ
Pending --> Cancelled : Member hủy

Assigned --> Finished : Rescuer hoàn thành nhiệm vụ
Assigned --> Cancelled : Member hủy\n(Mission còn Preparing)

Finished --> Paid : Member thanh toán Round 2\n(CatchingPayment)

Paid --> Completed : System transfer-to-rescuer\n(POST /api/v1/payos/transfer-to-rescuer)

note right of Assigned
  Mission sub-statuses:
  Preparing → EnRoute → Arrived → MissionCompleted
end note

@enduml
```

---

## GHI CHÚ NGHIỆP VỤ

### Quy tắc thanh toán 2 vòng
| Vòng | Thời điểm | Loại giao dịch | Nội dung |
|---|---|---|---|
| Round 1 | Sau khi Rescuer nhận đơn (Assigned) | `CatchingDeposit` | Phí di chuyển ước tính |
| Round 2 | Sau khi Rescuer hoàn thành (Finished) | `CatchingPayment` | Phí dịch vụ thực tế (baseFee + snakeFee + envFee) |

### Thanh khoản cho Rescuer
- Sau khi Member thanh toán Round 2 thành công → đơn chuyển sang `[Paid]`
- System tự động gọi `POST /api/v1/payos/transfer-to-rescuer`
- Rescuer nhận toàn bộ phí dịch vụ → đơn chuyển sang `[Completed]`

### Quyền hủy đơn
- Trạng thái `Pending`: Member được hủy tự do
- Trạng thái `Assigned` & Mission = `Preparing`: Member được hủy (Rescuer chưa di chuyển)
- Trạng thái `Assigned` & Mission = `EnRoute/Arrived`: **Không** được hủy
