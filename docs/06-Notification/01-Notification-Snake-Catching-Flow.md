# KỊCH BẢN THÔNG BÁO — LUỒNG BẮT RẮN (SNAKE CATCHING)

## Thông tin tài liệu

| Trường | Nội dung |
|---|---|
| **Tên dự án** | SnakeAid — AI-Powered Snakebite First Aid & Rescue |
| **Module** | Snake Catching — Notification Scenarios |
| **Phiên bản** | 1.0 |
| **Ngày tạo** | 02/04/2026 |
| **Mô hình** | v2.0 — Operator-based (Rescuer không tự nhận đơn) |
| **Phạm vi** | Toàn bộ các endpoint và sự kiện realtime trong luồng bắt rắn |

---

## TỔNG QUAN

Tài liệu này mô tả **toàn bộ kịch bản thông báo** kèm trên mỗi endpoint / sự kiện trong luồng bắt rắn, bao gồm:
- **Push Notification** (Firebase FCM) — gửi khi app ở nền hoặc đóng
- **In-App Notification** — hiển thị trong app khi đang mở
- **SignalR Realtime Event** — event socket dành cho cập nhật live (bản đồ, trạng thái)
- **Toast / Snackbar** — phản hồi tức thì sau hành động của người dùng

**Actors:**

| Ký hiệu | Vai trò |
|---|---|
| 👤 **Member** | Người dùng phát hiện rắn, tạo yêu cầu |
| 🧑‍💼 **Operator** | Nhân viên điều phối, xác nhận và phân công |
| 🦺 **Rescuer** | Cứu hộ viên được Operator giao nhiệm vụ |

---

## GIAI ĐOẠN 1 — TẠO YÊU CẦU & CHỜ XỬ LÝ

---

### [SC-N-01] Tạo yêu cầu bắt rắn thành công
**Endpoint:** `POST /api/snakecatching/requests`  
**Trigger:** Member nhấn "Gửi yêu cầu"  
**Trạng thái đơn sau:** `Pending`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Toast (in-app) | — | *"Yêu cầu bắt rắn đã được gửi thành công! Đội ngũ SnakeAid đang xử lý."* |
| 👤 Member | In-App Notification | **Yêu cầu đã được tiếp nhận** | *"Yêu cầu #[MÃ ĐƠN] của bạn đã ghi nhận. Chi phí ước tính: [estimatedPrice] VNĐ — khoảng cách: [distanceKm] km. Chúng tôi sẽ liên hệ xác nhận sớm nhất."* |
| 🧑‍💼 Operator | Push Notification | **📋 Đơn bắt rắn mới!** | *"Có yêu cầu bắt rắn mới từ [Tên Member] — [Địa chỉ] — [Loài rắn nếu có]. Vui lòng xem xét và xác nhận."* |
| 🧑‍💼 Operator | In-App Notification | **Đơn mới cần xử lý** | *"[Tên Member] vừa gửi yêu cầu bắt rắn tại [địa chỉ]. Ước tính: [estimatedPrice] VNĐ / [distanceKm] km."* |

> **Ghi chú kỹ thuật:**
> - `estimatedPrice` và `distanceKm` có trong response của endpoint → hiển thị ngay tại màn hình xác nhận thành công phía Member.
> - Operator nhận notification ngay khi backend tạo đơn xong.

---

### [SC-N-02] Tạo yêu cầu thất bại
**Endpoint:** `POST /api/snakecatching/requests`  
**Trigger:** Backend trả về lỗi 400 / 401 / 500

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Toast / Dialog (in-app) | **Gửi yêu cầu thất bại** | *"Không thể gửi yêu cầu lúc này. Vui lòng kiểm tra kết nối mạng và thử lại."* |

---

### [SC-N-03] Thanh toán đặt cọc thành công (Round 1 — CatchingDeposit)
**Trigger:** Member thanh toán tại bất kỳ trạng thái `Pending / Confirmed / Assigned`  
**Check API:** `GET /api/transactions/snakecatchingrequest/{id}` → `transactionType == CatchingDeposit`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **✅ Đặt cọc thành công** | *"Bạn đã đặt cọc thành công [estimatedPrice] VNĐ cho đơn #[MÃ ĐƠN]. Đơn của bạn sẽ được ưu tiên xử lý."* |
| 👤 Member | In-App Notification | **Thanh toán đặt cọc** | *"Giao dịch đặt cọc [estimatedPrice] VNĐ đã được xác nhận. Điều phối viên đang phân công cứu hộ viên cho bạn."* |
| 🧑‍💼 Operator | In-App Notification | **Member đã đặt cọc** | *"[Tên Member] đã thanh toán đặt cọc cho đơn #[MÃ ĐƠN]. Ưu tiên xử lý đơn này."* |

---

### [SC-N-04] Đơn hết hạn — Operator không xử lý
**Trigger:** Hệ thống tự động sau khoảng thời gian chờ (`Pending → Expired`)

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **⚠️ Yêu cầu hết hạn** | *"Yêu cầu #[MÃ ĐƠN] của bạn đã hết hạn do không có điều phối viên xử lý kịp thời. Vui lòng tạo yêu cầu mới hoặc gọi hotline hỗ trợ."* |
| 👤 Member | In-App Notification | **Yêu cầu hết hạn** | *"Đơn #[MÃ ĐƠN] đã tự động hết hạn. Nếu rắn vẫn còn hiện diện, hãy tạo yêu cầu mới để được hỗ trợ sớm nhất."* |

---

## GIAI ĐOẠN 2 — OPERATOR XÁC NHẬN & PHÂN CÔNG

---

### [SC-N-05] Operator xác nhận đơn
**Trigger:** Operator cập nhật trạng thái → `Confirmed`  
**Endpoint phía Operator dashboard:** `PATCH .../confirm` (hoặc tương đương)

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **✅ Yêu cầu đã được xác nhận** | *"Yêu cầu #[MÃ ĐƠN] đã được xác nhận! Điều phối viên đang tìm cứu hộ viên phù hợp cho bạn."* |
| 👤 Member | In-App Notification | **Đơn đã xác nhận** | *"SnakeAid đã xác nhận yêu cầu của bạn. Chúng tôi đang phân công cứu hộ viên gần nhất — vui lòng chờ thêm vài phút."* |

---

### [SC-N-06] Operator gán Rescuer — nhiệm vụ được giao
**Trigger:** Operator gán Rescuer vào đơn → `Assigned`  
**Kênh realtime:** SignalR event → Rescuer app

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **🦺 Cứu hộ viên đã được phân công** | *"[Tên Rescuer] sẽ đến hỗ trợ bạn! SĐT liên hệ: [SĐT Rescuer]. Thời gian di chuyển ước tính: ~[X] phút."* |
| 👤 Member | In-App Notification | **Cứu hộ viên đang trên đường** | *"[Tên Rescuer] đã nhận nhiệm vụ và đang chuẩn bị di chuyển đến [địa chỉ] của bạn."* |
| 🦺 Rescuer | **SignalR Event** `SnakeCatchingMissionAssigned` | — | Payload: `{ missionId, requestId, memberName, memberPhone, address, snakeInfo, estimatedDistance }` |
| 🦺 Rescuer | Push Notification | **📋 Bạn được giao nhiệm vụ bắt rắn** | *"Nhiệm vụ mới: [Loài rắn] tại [địa chỉ] — Khách hàng: [Tên Member] ([SĐT]). Mở app để xem chi tiết."* |
| 🦺 Rescuer | In-App (toàn màn hình / modal) | **Nhiệm vụ mới được giao** | Hiển thị card chi tiết: địa chỉ, loài rắn, ảnh, thông tin Member, nút "Bắt đầu di chuyển". |

> **Ghi chú kỹ thuật:**
> - SignalR event là kênh chính để Rescuer app nhận nhiệm vụ realtime.
> - Push Notification là fallback khi Rescuer đang nền / đóng app.

---

## GIAI ĐOẠN 3 — RESCUER DI CHUYỂN & ĐẾN NƠI

---

### [SC-N-07] Rescuer bắt đầu di chuyển
**Trigger:** Rescuer nhấn "Bắt đầu di chuyển" trên app  
**Mission status:** `Preparing → EnRoute`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | **SignalR Event** `RescuerEnRoute` | — | Payload: `{ missionId, rescuerLocation, estimatedArrivalMinutes }` — cập nhật live trên bản đồ |
| 👤 Member | Push Notification | **🚗 Cứu hộ viên đang di chuyển** | *"[Tên Rescuer] đang trên đường đến vị trí của bạn. Dự kiến đến nơi sau khoảng [X] phút."* |
| 👤 Member | In-App Notification | **Cứu hộ viên đang trên đường** | *"[Tên Rescuer] đã bắt đầu di chuyển. Theo dõi vị trí thời gian thực trên bản đồ."* |

---

### [SC-N-08] Rescuer đến nơi
**Endpoint:** `PATCH /api/snakecatching/missions/{missionId}/arrived`  
**Mission status:** `EnRoute → Arrived`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **📍 Cứu hộ viên đã đến!** | *"[Tên Rescuer] đã đến nơi và bắt đầu khảo sát hiện trường. Vui lòng ra đón hoặc chỉ dẫn vị trí."* |
| 👤 Member | In-App Notification | **Cứu hộ viên đã đến** | *"[Tên Rescuer] đã có mặt tại [địa chỉ]. Họ đang chuẩn bị thực hiện nhiệm vụ bắt rắn."* |
| 👤 Member | **SignalR Event** `RescuerArrived` | — | Payload: `{ missionId }` — cập nhật UI trạng thái |
| 🦺 Rescuer | Toast (in-app) | — | *"Đã cập nhật: Bạn đã đến nơi. Hãy khảo sát hiện trường và bắt đầu nhiệm vụ."* |

---

### [SC-N-09] Rescuer bắt đầu nhiệm vụ
**Endpoint:** `PATCH /api/snakecatching/missions/{missionId}/start`  
**Mission status:** `Arrived → InProgress` (nếu có sub-status này)

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | In-App Notification | **🐍 Đang bắt rắn** | *"[Tên Rescuer] đã bắt đầu thực hiện nhiệm vụ bắt rắn. Vui lòng ở xa khu vực nguy hiểm và chờ kết quả."* |
| 🦺 Rescuer | Toast (in-app) | — | *"Nhiệm vụ đã bắt đầu. Ghi nhận kết quả sau khi hoàn thành."* |

---

## GIAI ĐOẠN 4 — HOÀN THÀNH NHIỆM VỤ & THANH TOÁN

---

### [SC-N-10] Rescuer ghi nhận chi tiết rắn bắt được
**Endpoint:** `POST /api/catchingmission/details`  
**Trigger:** Rescuer thêm từng loài rắn bắt được vào đơn

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 🦺 Rescuer | Toast (in-app) | — | *"Đã thêm: [Số lượng] con [Tên loài]. Tiếp tục thêm nếu còn rắn khác."* |

> Không gửi thông báo đến Member ở bước này — đợi đến khi Rescuer hoàn thành toàn bộ.

---

### [SC-N-11] Rescuer xóa chi tiết rắn (sửa lại)
**Endpoint:** `DELETE /api/catchingmission/details/{id}`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 🦺 Rescuer | Toast (in-app) | — | *"Đã xóa mục rắn khỏi danh sách."* |

---

### [SC-N-12] Rescuer hoàn thành nhiệm vụ
**Endpoint:** `PATCH /api/snakecatching/missions/{missionId}/complete`  
**Body:** `{ catchingEnvironmentId }`  
**Trạng thái đơn sau:** `Finished`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **🎉 Nhiệm vụ hoàn thành — Cần thanh toán** | *"[Tên Rescuer] đã hoàn thành việc bắt rắn tại nhà bạn! Phí dịch vụ thực tế: [actualCost] VNĐ. Vui lòng thanh toán để hoàn tất."* |
| 👤 Member | In-App Notification (có nút CTA) | **Hoàn thành — Thanh toán ngay** | *"Kết quả: Bắt được [X] con rắn ([danh sách loài]). Tổng phí: [actualCost] VNĐ (gồm phí cơ bản + phí theo loài + phí môi trường). Thanh toán để kết thúc đơn."* |
| 👤 Member | **SignalR Event** `MissionCompleted` | — | Payload: `{ missionId, requestId, actualCost, snakeDetails: [{species, quantity}], evidencePhotos }` |
| 🦺 Rescuer | Toast (in-app) | — | *"Nhiệm vụ đã được ghi nhận hoàn thành. Chờ khách hàng thanh toán để kết thúc đơn."* |

> **Ghi chú kỹ thuật:**
> - `actualCost = baseFee + snakeFee + envFee` — hiển thị chi tiết từng khoản trong notification/màn hình.
> - Member app tự động chuyển sang màn hình thanh toán Round 2 khi nhận `MissionCompleted` event.

---

### [SC-N-13] Thanh toán dịch vụ thành công (Round 2 — CatchingPayment)
**Trigger:** Member thanh toán Round 2 thành công (PayOS hoặc Ví SnakeAidPay)  
**Trạng thái đơn sau:** `Completed`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Push Notification | **✅ Đơn hoàn tất** | *"Cảm ơn bạn đã sử dụng SnakeAid! Đơn #[MÃ ĐƠN] đã hoàn tất. Đừng quên đánh giá dịch vụ để giúp chúng tôi cải thiện."* |
| 👤 Member | In-App Notification | **Dịch vụ hoàn tất** | *"Đơn bắt rắn #[MÃ ĐƠN] đã kết thúc thành công. Bạn có thể xem lại lịch sử trong mục 'Thanh toán & lịch sử'."* |
| 🦺 Rescuer | Push Notification | **💰 Thanh toán xác nhận** | *"Khách hàng đã thanh toán cho nhiệm vụ #[MÃ NHIỆM VỤ]. Nhiệm vụ đã kết thúc chính thức. Cảm ơn bạn!"* |
| 🦺 Rescuer | In-App Notification | **Nhiệm vụ hoàn tất chính thức** | *"Đơn #[MÃ ĐƠN] đã hoàn tất. Thu nhập từ đơn này sẽ được cập nhật trong mục quản lý thu nhập."* |
| 🧑‍💼 Operator | In-App Notification | **Đơn hoàn tất** | *"Đơn #[MÃ ĐƠN] — [Tên Member] → [Tên Rescuer] — đã kết thúc thành công. Tổng doanh thu: [actualCost] VNĐ."* |

---

### [SC-N-14] Thanh toán Round 2 thất bại
**Trigger:** PayOS callback lỗi / Ví không đủ số dư

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Toast / Dialog (in-app) | **Thanh toán thất bại** | *"Thanh toán không thành công. Vui lòng kiểm tra số dư hoặc thử phương thức khác."* |
| 👤 Member | Push Notification | **⚠️ Chưa hoàn tất thanh toán** | *"Bạn còn [actualCost] VNĐ cần thanh toán cho đơn #[MÃ ĐƠN]. Vui lòng mở app và hoàn tất để kết thúc dịch vụ."* |

---

## GIAI ĐOẠN 5 — HỦY ĐƠN

---

### [SC-N-15] Member hủy đơn khi `Pending` hoặc `Confirmed`
**Endpoint:** `PATCH /api/snakecatching/requests/cancel/{requestId}`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Toast (in-app) | — | *"Yêu cầu #[MÃ ĐƠN] đã được hủy thành công."* |
| 👤 Member | In-App Notification | **Đơn đã hủy** | *"Đơn #[MÃ ĐƠN] đã hủy. Nếu bạn đã thanh toán đặt cọc, số tiền sẽ hoàn trả về ví trong vòng 1–3 ngày làm việc."* |
| 🧑‍💼 Operator | In-App Notification | **Đơn bị hủy** | *"[Tên Member] đã hủy yêu cầu #[MÃ ĐƠN]. Lý do: [Lý do hủy]."* |

---

### [SC-N-16] Member hủy đơn khi `Assigned` (Mission còn `Preparing`)
**Endpoint:** `PATCH /api/snakecatching/requests/cancel/{requestId}`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 👤 Member | Toast (in-app) | — | *"Đơn đã được hủy."* |
| 👤 Member | In-App Notification | **Đơn đã hủy** | *"Đơn #[MÃ ĐƠN] đã hủy thành công. Cứu hộ viên đã được thông báo hủy nhiệm vụ."* |
| 🦺 Rescuer | Push Notification | **❌ Nhiệm vụ bị hủy** | *"Khách hàng [Tên Member] đã hủy yêu cầu #[MÃ ĐƠN]. Nhiệm vụ của bạn được hủy — không cần di chuyển."* |
| 🦺 Rescuer | In-App Notification | **Nhiệm vụ hủy** | *"Đơn #[MÃ ĐƠN] đã bị hủy bởi khách hàng. Lý do: [Lý do hủy]. Đơn này đã chuyển vào lịch sử."* |
| 🧑‍💼 Operator | In-App Notification | **Đơn đã được gán bị hủy** | *"[Tên Member] hủy đơn #[MÃ ĐƠN] — Rescuer [Tên Rescuer] đã được thông báo. Kiểm tra tình trạng Rescuer."* |

---

### [SC-N-17] Rescuer hủy nhiệm vụ (Abort)
**Endpoint:** `PATCH /api/snakecatching/missions/{missionId}/abort`

| Actor | Kênh | Tiêu đề | Nội dung thông báo |
|---|---|---|---|
| 🦺 Rescuer | Toast (in-app) | — | *"Nhiệm vụ đã được hủy."* |
| 👤 Member | Push Notification | **⚠️ Cứu hộ viên không thể thực hiện** | *"Rất tiếc! [Tên Rescuer] không thể hoàn thành nhiệm vụ do [Lý do]. Đội SnakeAid đang tìm cứu hộ viên thay thế cho bạn."* |
| 👤 Member | In-App Notification | **Đang tìm cứu hộ viên thay thế** | *"Điều phối viên đã nhận được thông báo và sẽ phân công cứu hộ viên mới sớm nhất có thể. Đơn của bạn vẫn còn hiệu lực."* |
| 🧑‍💼 Operator | Push Notification | **🚨 Cần phân công lại ngay** | *"Rescuer [Tên Rescuer] đã hủy nhiệm vụ cho đơn #[MÃ ĐƠN]. Cần phân công cứu hộ viên thay thế ngay!"* |
| 🧑‍💼 Operator | In-App Notification | **Rescuer hủy — Cần phân công lại** | *"[Tên Rescuer] hủy đơn #[MÃ ĐƠN]. Lý do: [Lý do]. Đơn đang chờ phân công lại — ưu tiên xử lý!"* |

---

## TỔNG HỢP THEO ENDPOINT

| STT | Endpoint | Trigger | Member | Rescuer | Operator |
|---|---|---|---|---|---|
| 1 | `POST /api/snakecatching/requests` | Tạo đơn | In-App + Toast | — | Push + In-App |
| 2 | `GET /api/transactions/...` | Đặt cọc Round 1 | Push + In-App | — | In-App |
| 3 | Operator confirm | Xác nhận đơn | Push + In-App | — | — |
| 4 | Operator assign | Gán Rescuer | Push + In-App | **SignalR** + Push + Modal | — |
| 5 | `PATCH .../arrived` | Rescuer đến nơi | Push + In-App + **SignalR** | Toast | — |
| 6 | `PATCH .../start` | Bắt đầu bắt rắn | In-App | Toast | — |
| 7 | `POST /api/catchingmission/details` | Thêm rắn | — | Toast | — |
| 8 | `DELETE /api/catchingmission/details/{id}` | Xóa rắn | — | Toast | — |
| 9 | `PATCH .../complete` | Hoàn thành NV | Push + In-App + **SignalR** | Toast | — |
| 10 | Thanh toán Round 2 OK | Đơn Completed | Push + In-App | Push + In-App | In-App |
| 11 | Thanh toán Round 2 lỗi | Thanh toán thất bại | Toast + Push | — | — |
| 12 | `PATCH .../cancel` (Pending/Confirmed) | Hủy đơn sớm | Toast + In-App | — | In-App |
| 13 | `PATCH .../cancel` (Assigned) | Hủy có Rescuer | Toast + In-App | Push + In-App | In-App |
| 14 | `PATCH .../abort` | Rescuer hủy NV | Push + In-App | Toast | Push + In-App |
| 15 | Hệ thống (timeout) | Đơn Expired | Push + In-App | — | — |

---

## PHÂN LOẠI KÊNH THÔNG BÁO

```
┌─────────────────────────────────────────────────────────────────┐
│                     KÊNH THÔNG BÁO                             │
├─────────────────┬───────────────────────────────────────────────┤
│  SignalR Event  │ Ưu tiên cao nhất — cập nhật realtime khi      │
│  (Realtime)     │ app đang mở: vị trí Rescuer, trạng thái đơn,  │
│                 │ yêu cầu thanh toán                            │
├─────────────────┼───────────────────────────────────────────────┤
│  Push           │ Fallback khi app ở nền hoặc đóng — các sự     │
│  Notification   │ kiện quan trọng cần user biết ngay            │
│  (FCM)          │                                               │
├─────────────────┼───────────────────────────────────────────────┤
│  In-App         │ Hiển thị trong notification center của app —  │
│  Notification   │ lưu lịch sử thông báo, có thể xem lại         │
├─────────────────┼───────────────────────────────────────────────┤
│  Toast /        │ Phản hồi tức thì ngay sau action của user —   │
│  Snackbar       │ không lưu lại, chỉ xác nhận hành động         │
└─────────────────┴───────────────────────────────────────────────┘
```

---

## GHI CHÚ TRIỂN KHAI

### Ưu tiên thực thi (Priority Order)

1. **[P0 — Bắt buộc]** SignalR events: `SnakeCatchingMissionAssigned`, `RescuerEnRoute`, `RescuerArrived`, `MissionCompleted`
2. **[P0 — Bắt buộc]** Push Notification cho các milestone chính: tạo đơn, phân công Rescuer, đến nơi, hoàn thành, hủy đơn
3. **[P1 — Quan trọng]** In-App Notification với thông tin chi tiết và nút CTA (thanh toán, xem chi tiết)
4. **[P2 — Bổ sung]** Toast/Snackbar cho mọi action thành công trong flow

### Dữ liệu cần trong payload notification

| Trường | Mục đích |
|---|---|
| `requestId` | Điều hướng đến màn hình chi tiết đơn |
| `missionId` | Điều hướng đến màn hình nhiệm vụ cho Rescuer |
| `memberName` / `rescuerName` | Cá nhân hóa nội dung thông báo |
| `actualCost` / `estimatedPrice` | Hiển thị số tiền trực tiếp trong notification |
| `notificationType` | Phân biệt loại: `ORDER_CREATED`, `ASSIGNED`, `ARRIVED`, `COMPLETED`, `CANCELLED` |

### Deep Link khi tap vào notification

| notificationType | Member điều hướng đến | Rescuer điều hướng đến |
|---|---|---|
| `ORDER_CREATED` | `activity_detail_screen` | — |
| `ASSIGNED` | `rescuer_tracking_screen` | `rescuer_available_jobs` (chi tiết nhiệm vụ) |
| `ARRIVED` | `rescuer_tracking_screen` | — |
| `MISSION_COMPLETED` | `payment_screen` (Round 2) | — |
| `ORDER_COMPLETED` | `history_detail_screen` | `history_detail_screen` |
| `CANCELLED` | `home_screen` | `home_screen` |
| `ABORT` | `waiting / home_screen` | — |
