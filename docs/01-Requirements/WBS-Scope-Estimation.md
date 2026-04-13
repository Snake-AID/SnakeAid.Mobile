# SCOPE & ESTIMATION — SNAKEAID MOBILE APPLICATION

## Thông tin dự án

| Mục | Nội dung |
|-----|----------|
| **Tên dự án** | AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid) |
| **Phiên bản tài liệu** | 1.0 |
| **Ngày tạo** | 12/04/2026 |
| **Nền tảng** | Flutter Mobile (Android & iOS) |
| **Tổng thời gian phát triển** | 10 tuần hiệu quả (Tuần 1–10, hoàn thiện code trước Tuần 11) |

---

## 1. Overview

### 1.1 Scope & Estimation

> **Quy ước mức độ phức tạp:**
> - **Simple** — CRUD cơ bản, hiển thị dữ liệu, UI tĩnh: 2–4 man-days
> - **Medium** — Tích hợp API, quản lý state, form nghiệp vụ: 3–5 man-days
> - **Complex** — Realtime, thanh toán, video call, AI, map: 5–8 man-days

---

| #    | WBS Item                                                                 | Complexity | Est. Effort (man-days) |
|------|--------------------------------------------------------------------------|:----------:|:----------------------:|
| **1**   | **Feature 1 — Xác thực & Quản lý tài khoản**                          |            | **10**                 |
| 1.1  | Đăng nhập / Đăng xuất (Member, Rescuer, Expert, Operator)                | Simple     | 3                      |
| 1.2  | Đăng ký tài khoản Member & xác minh OTP                                  | Simple     | 3                      |
| 1.3  | Quản lý hồ sơ cá nhân, ảnh đại diện & bảo mật                           | Medium     | 4                      |
|      |                                                                           |            |                        |
| **2**   | **Feature 2 — Luồng SOS Khẩn Cấp (Snakebite Emergency)**              |            | **16**                 |
| 2.1  | Gửi yêu cầu SOS: GPS tự động, ảnh rắn, mô tả triệu chứng               | Medium     | 4                      |
| 2.2  | Operator xác minh SOS & gán Rescuer qua SignalR                          | Complex    | 5                      |
| 2.3  | Rescuer nhận nhiệm vụ, cập nhật trạng thái di chuyển (EnRoute → Arrived) | Medium     | 4                      |
| 2.4  | Thanh toán phí dịch vụ SOS (PayOS / Ví SnakeAidPay) & đóng đơn         | Medium     | 3                      |
|      |                                                                           |            |                        |
| **3**   | **Feature 3 — Luồng Bắt Rắn (Snake Catching Request)**                |            | **18**                 |
| 3.1  | Tạo yêu cầu bắt rắn: ảnh, vị trí GPS, mô tả loài & số lượng            | Simple     | 3                      |
| 3.2  | Thanh toán đặt cọc Round 1 — CatchingDeposit (PayOS / Ví SnakeAidPay)  | Medium     | 4                      |
| 3.3  | Operator xác nhận yêu cầu hợp lệ & gán Rescuer phù hợp                  | Medium     | 3                      |
| 3.4  | Rescuer thực hiện nhiệm vụ, ghi nhận kết quả & ảnh bằng chứng           | Medium     | 4                      |
| 3.5  | Thanh toán Round 2 — CatchingPayment (actualCost) & đóng đơn hoàn tất   | Medium     | 4                      |
|      |                                                                           |            |                        |
| **4**   | **Feature 4 — Luồng Tư Vấn Chuyên Gia (Expert Consultation)**         |            | **22**                 |
| 4.1  | Danh sách chuyên gia: tìm kiếm, lọc theo chuyên môn, xem hồ sơ         | Simple     | 3                      |
| 4.2  | Tư vấn ngay lập tức (Instant): màn hình chờ, SignalR Accept/Reject       | Complex    | 6                      |
| 4.3  | Đặt lịch hẹn tư vấn (Scheduled): chọn slot, xác nhận, nhắc nhở          | Medium     | 4                      |
| 4.4  | Phòng chờ & Video Call (WebRTC / LiveKit) + Escrow thanh toán            | Complex    | 7                      |
| 4.5  | Đánh giá, nhận xét Expert & lịch sử tư vấn                              | Simple     | 2                      |
|      |                                                                           |            |                        |
| **5**   | **Feature 5 — AI Nhận Diện Rắn & Đánh Giá Mức Độ**                   |            | **10**                 |
| 5.1  | Chụp ảnh / tải ảnh & gọi API AI nhận diện loài rắn                      | Medium     | 4                      |
| 5.2  | Hiển thị kết quả: tên loài, độc tính, mức độ nguy hiểm, đề xuất sơ cứu  | Simple     | 3                      |
| 5.3  | Đánh giá mức độ nghiêm trọng từ triệu chứng & ảnh vết cắn               | Medium     | 3                      |
|      |                                                                           |            |                        |
| **6**   | **Feature 6 — Ví SnakeAid Pay & Hệ Thống Thanh Toán**                |            | **14**                 |
| 6.1  | Màn hình ví: tổng quan số dư, tóm tắt giao dịch gần nhất                | Simple     | 2                      |
| 6.2  | Nạp tiền vào ví qua PayOS (deep link, callback, xác nhận)               | Complex    | 5                      |
| 6.3  | Rút tiền về tài khoản ngân hàng (nhập thông tin, xác nhận, trạng thái)  | Medium     | 4                      |
| 6.4  | Lịch sử & chi tiết giao dịch (lọc, phân trang)                          | Simple     | 3                      |
|      |                                                                           |            |                        |
| **7**   | **Feature 7 — Kiến Thức Sơ Cứu & Tra Cứu Thông Tin**                 |            | **8**                  |
| 7.1  | Hướng dẫn sơ cứu rắn cắn từng bước (băng ép, cảnh báo, hành động cấm)  | Simple     | 2                      |
| 7.2  | Cơ sở dữ liệu loài rắn: tra cứu thông tin, đặc điểm, vùng phân bố      | Simple     | 2                      |
| 7.3  | Bản đồ định vị bệnh viện / cơ sở điều trị có huyết thanh gần nhất       | Medium     | 4                      |
|      |                                                                           |            |                        |
| **8**   | **Feature 8 — Thông Báo & Realtime**                                   |            | **8**                  |
| 8.1  | Push Notification (FCM) cho toàn bộ role & loại sự kiện                 | Medium     | 4                      |
| 8.2  | SignalR realtime: cập nhật trạng thái đơn, nhiệm vụ, tư vấn             | Complex    | 4                      |
|      |                                                                           |            |                        |
| **9**   | **Feature 9 — Ứng Dụng Rescuer (Snake Rescuer App)**                  |            | **8**                  |
| 9.1  | Danh sách & chi tiết nhiệm vụ được Operator gán                          | Simple     | 2                      |
| 9.2  | Điều hướng bản đồ từ vị trí hiện tại đến hiện trường                    | Medium     | 3                      |
| 9.3  | Cập nhật hành trình (EnRoute → Arrived) & ghi nhận kết quả nhiệm vụ     | Medium     | 3                      |
|      |                                                                           |            |                        |
| **10**  | **Feature 10 — Ứng Dụng Expert (Snake Expert App)**                   |            | **10**                 |
| 10.1 | Lịch tư vấn & quản lý slot làm việc (accept/reject booking)             | Medium     | 4                      |
| 10.2 | Dashboard doanh thu: thống kê tư vấn, thu nhập tháng/ngày               | Medium     | 4                      |
| 10.3 | Xác minh nhận diện loài rắn & thêm ghi chú chuyên môn                   | Simple     | 2                      |
|      |                                                                           |            |                        |
| **11**  | **Feature 11 — Ứng Dụng Operator**                                    |            | **8**                  |
| 11.1 | Dashboard giám sát: danh sách yêu cầu SOS, bắt rắn, tư vấn             | Medium     | 3                      |
| 11.2 | Xác minh yêu cầu hợp lệ & phân công Rescuer / Expert phù hợp            | Medium     | 3                      |
| 11.3 | Theo dõi trạng thái realtime & cập nhật thủ công khi cần can thiệp       | Simple     | 2                      |
|      |                                                                           |            |                        |
| **12**  | **Feature 12 — Ứng Dụng Admin (Admin Web Application)**               |            | **38**                 |
| 12.1 | Bảng điều khiển tổng quan: thống kê hệ thống, biểu đồ sự kiện & doanh thu | Simple   | 3                      |
| 12.2 | Quản lý lịch làm việc (Rescuer & Expert): xem, chỉnh sửa, phê duyệt     | Medium     | 4                      |
| 12.3 | Quản lý người dùng: CRUD Member, Rescuer, Expert, Operator; phân quyền   | Medium     | 4                      |
| 12.4 | Quản lý ca khẩn cấp, bắt rắn, tư vấn: xem, lọc, can thiệp trạng thái   | Complex    | 6                      |
| 12.5 | Quản lý loài rắn: CRUD thông tin loài, ảnh, độc tính, vùng phân bố      | Medium     | 3                      |
| 12.6 | Quản lý huyết thanh: CRUD loại huyết thanh & liên kết cơ sở điều trị    | Simple     | 2                      |
| 12.7 | Quản lý cơ sở điều trị: CRUD bệnh viện, trạm y tế, tọa độ GPS           | Medium     | 3                      |
| 12.8 | Quản lý giao dịch: xem lịch sử, tra cứu, xác nhận thanh toán thủ công   | Medium     | 4                      |
| 12.9 | Quản lý cấu hình động: phí dịch vụ, hệ số phân chia, tham số hệ thống   | Medium     | 3                      |
| 12.10| Quản lý ảnh báo cáo rắn: duyệt, phân loại, xóa ảnh sự cố của Member    | Simple     | 2                      |
| 12.11| Quản lý bài học: CRUD nội dung sơ cứu, video hướng dẫn                  | Simple     | 2                      |
| 12.12| Quản lý bài viết: CRUD tin tức, cảnh báo cộng đồng, kiến thức phòng tránh| Simple    | 2                      |
|      |                                                                           |            |                        |
|      | **Total Estimated Effort (man-days)**                                    |            | **170**                |

---

## 2. Phân bố công việc theo tuần

> Giả định: **3 developer** — 2 dev Mobile, 1 dev Admin — làm việc song song, hiệu suất ~65%.
> - Mobile stream: 2 dev × 5 ngày × 65% ≈ **~13 MD/tuần**
> - Admin stream: 1 dev × 5 ngày × 65% ≈ **~6 MD/tuần** *(Admin bắt đầu từ Tuần 2 sau khi hoàn thiện thiết kế)*

| Tuần | Mobile Dev (Dev 1 & Dev 2)                                              | Admin Dev (Dev 3)                                         | MD Mobile | MD Admin |
|:----:|-------------------------------------------------------------------------|-----------------------------------------------------------|:---------:|:--------:|
| 1    | F1 (Auth & Profile) + F8 (Notif & SignalR Realtime)                     | Thiết kế hệ thống Admin, setup project & routing          | 18        | —        |
| 2    | F7 (Kiến thức & Bản đồ) + F5 (AI — 5.1, 5.2)                           | F12.1 (Dashboard) + F12.3 (Quản lý người dùng)            | 13        | 7        |
| 3    | F5 (AI — 5.3) + F3 (Bắt rắn — 3.1, 3.2, 3.3)                           | F12.4 (Quản lý ca khẩn cấp, bắt rắn, tư vấn)             | 13        | 6        |
| 4    | F3 (Bắt rắn — 3.4, 3.5) + F9 (Rescuer App)                              | F12.2 (Quản lý lịch làm việc) + F12.5 (Quản lý loài rắn) | 16        | 7        |
| 5    | F2 (SOS — 2.1, 2.2, 2.3, 2.4)                                           | F12.6 (Huyết thanh) + F12.7 (Cơ sở điều trị)             | 16        | 5        |
| 6    | F6 (Ví & Thanh toán — 6.1, 6.2, 6.3, 6.4)                               | F12.8 (Quản lý giao dịch) + F12.9 (Cấu hình động)        | 14        | 7        |
| 7    | F4 (Tư vấn — 4.1, 4.2, 4.3)                                             | F12.10 (Ảnh báo cáo rắn) + F12.11 (Bài học)              | 13        | 4        |
| 8    | F4 (Tư vấn — 4.4, 4.5) + F10 (Expert App — 10.1)                        | F12.12 (Bài viết) + Integration Admin ↔ API              | 13        | 2        |
| 9    | F10 (Expert App — 10.2, 10.3) + F11 (Operator App)                       | End-to-end test Admin, bug fixing                         | 10        | —        |
| 10   | Buffer: Integration testing, bug fixing, UI polish toàn hệ thống        | Buffer: Admin bug fixing, UI polish                       | —         | —        |
|      | **Tổng**                                                                |                                                           | **126**   | **38**   |

---

## 3. Tổng hợp theo mức độ phức tạp

| Mức độ  | Số lượng function | Tổng man-days | Tỷ lệ |
|:-------:|:-----------------:|:-------------:|:-----:|
| Simple  | 19                | 48            | 28%   |
| Medium  | 23                | 80            | 47%   |
| Complex | 8                 | 42            | 25%   |
| **Tổng**| **50**            | **170**       | 100%  |

---

## 4. Ghi chú rủi ro & phụ thuộc

| # | Rủi ro / Phụ thuộc | Mức độ ảnh hưởng | Biện pháp |
|---|---------------------|:----------------:|-----------|
| R1 | Tích hợp LiveKit / WebRTC cho Video Call phức tạp, phụ thuộc server cấu hình | Cao | Ưu tiên POC sớm ở Tuần 1–2 |
| R2 | PayOS deep link callback trên iOS (Universal Link) dễ gặp lỗi | Trung bình | Test thiết bị thật từ sớm |
| R3 | AI API nhận diện rắn có thể thay đổi response format | Thấp | Đóng gói trong service riêng, dễ swap |
| R4 | SignalR connection không ổn định trên mạng yếu | Trung bình | Thêm reconnect logic & fallback UI |
| R5 | BE chưa có endpoint GET trạng thái tức thời cho một số flow | Trung bình | Xác nhận API contract với BE team trước Tuần 2 |
| R6 | Admin Web: phân quyền role-based phức tạp (Member / Rescuer / Expert / Operator / Admin) | Cao | Thiết kế middleware auth + guard routes ngay từ đầu |
| R7 | Quản lý cấu hình động (phí, phân chia) ảnh hưởng trực tiếp đến business logic | Cao | Yêu cầu review kỹ với PO & BE trước khi implement |

---

## 5. Scope & Estimation (English Version)

> **Complexity legend:**
> - **Simple** — Basic CRUD, data display, static UI: 2–4 man-days
> - **Medium** — API integration, state management, business forms: 3–5 man-days
> - **Complex** — Realtime, payment, video call, AI, maps: 5–8 man-days

| #     | WBS Item                                                                          | Complexity | Est. Effort (man-days) |
|-------|-----------------------------------------------------------------------------------|:----------:|:----------------------:|
| **1**    | **Feature 1 — Authentication & Account Management**                            |            | **10**                 |
| 1.1   | Login / Logout (Member, Rescuer, Expert, Operator)                                | Simple     | 3                      |
| 1.2   | Member registration & OTP verification                                            | Simple     | 3                      |
| 1.3   | Personal profile, avatar & security management                                    | Medium     | 4                      |
|       |                                                                                   |            |                        |
| **2**    | **Feature 2 — SOS Emergency Response (Snakebite)**                             |            | **16**                 |
| 2.1   | Send SOS request: auto GPS, snake photo, symptom description                      | Medium     | 4                      |
| 2.2   | Operator verifies SOS & assigns Rescuer via SignalR                               | Complex    | 5                      |
| 2.3   | Rescuer receives mission, updates movement status (EnRoute → Arrived)             | Medium     | 4                      |
| 2.4   | SOS service payment (PayOS / SnakeAid Wallet) & case closure                     | Medium     | 3                      |
|       |                                                                                   |            |                        |
| **3**    | **Feature 3 — Snake Catching Request**                                         |            | **18**                 |
| 3.1   | Create snake catching request: photo, GPS, species & quantity description         | Simple     | 3                      |
| 3.2   | Round 1 deposit payment — CatchingDeposit (PayOS / SnakeAid Wallet)              | Medium     | 4                      |
| 3.3   | Operator validates request & assigns suitable Rescuer                             | Medium     | 3                      |
| 3.4   | Rescuer completes mission, records results & photo evidence                       | Medium     | 4                      |
| 3.5   | Round 2 payment — CatchingPayment (actualCost) & order completion                | Medium     | 4                      |
|       |                                                                                   |            |                        |
| **4**    | **Feature 4 — Expert Consultation**                                            |            | **22**                 |
| 4.1   | Expert listing: search, filter by specialty, view profile                         | Simple     | 3                      |
| 4.2   | Instant consultation: waiting screen, SignalR Accept/Reject                       | Complex    | 6                      |
| 4.3   | Scheduled consultation: slot selection, confirmation, reminders                   | Medium     | 4                      |
| 4.4   | Waiting room & Video Call (WebRTC / LiveKit) + Escrow payment release             | Complex    | 7                      |
| 4.5   | Expert rating, review & consultation history                                      | Simple     | 2                      |
|       |                                                                                   |            |                        |
| **5**    | **Feature 5 — AI Snake Identification & Severity Assessment**                  |            | **10**                 |
| 5.1   | Capture / upload photo & call AI snake identification API                         | Medium     | 4                      |
| 5.2   | Display results: species name, toxicity, danger level, first-aid suggestion       | Simple     | 3                      |
| 5.3   | Severity assessment from symptoms & bite wound photo                              | Medium     | 3                      |
|       |                                                                                   |            |                        |
| **6**    | **Feature 6 — SnakeAid Wallet & Payment System**                               |            | **14**                 |
| 6.1   | Wallet screen: balance overview & recent transaction summary                      | Simple     | 2                      |
| 6.2   | Top-up via PayOS (deep link, callback, confirmation)                              | Complex    | 5                      |
| 6.3   | Withdrawal to bank account (input, confirm, status tracking)                      | Medium     | 4                      |
| 6.4   | Transaction history & detail (filter, pagination)                                 | Simple     | 3                      |
|       |                                                                                   |            |                        |
| **7**    | **Feature 7 — First-Aid Knowledge & Information Lookup**                       |            | **8**                  |
| 7.1   | Step-by-step snakebite first-aid guide (pressure immobilization, warnings, forbidden actions) | Simple | 2             |
| 7.2   | Snake species database: species info, characteristics, distribution               | Simple     | 2                      |
| 7.3   | Map: locate nearest hospital / treatment center with antivenom                    | Medium     | 4                      |
|       |                                                                                   |            |                        |
| **8**    | **Feature 8 — Notifications & Realtime**                                       |            | **8**                  |
| 8.1   | Push Notification (FCM) for all roles & event types                               | Medium     | 4                      |
| 8.2   | SignalR realtime: order status, mission & consultation updates                    | Complex    | 4                      |
|       |                                                                                   |            |                        |
| **9**    | **Feature 9 — Snake Rescuer App**                                              |            | **8**                  |
| 9.1   | Mission list & detail for Operator-assigned tasks                                 | Simple     | 2                      |
| 9.2   | Map navigation from current location to incident scene                            | Medium     | 3                      |
| 9.3   | Update route progress (EnRoute → Arrived) & record mission results                | Medium     | 3                      |
|       |                                                                                   |            |                        |
| **10**   | **Feature 10 — Snake Expert App**                                              |            | **10**                 |
| 10.1  | Consultation schedule & working slot management (accept/reject booking)           | Medium     | 4                      |
| 10.2  | Revenue dashboard: consultation stats, daily/monthly income                       | Medium     | 4                      |
| 10.3  | Snake species verification & specialist annotation                                | Simple     | 2                      |
|       |                                                                                   |            |                        |
| **11**   | **Feature 11 — Operator App**                                                  |            | **8**                  |
| 11.1  | Monitoring dashboard: SOS, snake catching & consultation queue                    | Medium     | 3                      |
| 11.2  | Validate requests & assign suitable Rescuer / Expert                              | Medium     | 3                      |
| 11.3  | Realtime status tracking & manual override when needed                            | Simple     | 2                      |
|       |                                                                                   |            |                        |
| **12**   | **Feature 12 — Admin Web Application (Admin Management Modules)**              |            | **38**                 |
| 12.1  | Overview dashboard: system statistics, event & revenue charts                     | Simple     | 3                      |
| 12.2  | Schedule management (Rescuer & Expert): view, edit, approve                       | Medium     | 4                      |
| 12.3  | User management: CRUD Member, Rescuer, Expert, Operator; role assignment          | Medium     | 4                      |
| 12.4  | Case management: SOS, snake catching, consultation — view, filter, status override | Complex   | 6                      |
| 12.5  | Snake species management: CRUD species info, photo, toxicity, distribution        | Medium     | 3                      |
| 12.6  | Antivenom management: CRUD antivenom types & treatment center mapping             | Simple     | 2                      |
| 12.7  | Treatment center management: CRUD hospitals, clinics, GPS coordinates             | Medium     | 3                      |
| 12.8  | Transaction management: history view, lookup, manual payment confirmation         | Medium     | 4                      |
| 12.9  | Dynamic configuration: service fees, revenue split factors, system parameters     | Medium     | 3                      |
| 12.10 | Snake report image management: review, classify, delete Member-submitted photos   | Simple     | 2                      |
| 12.11 | Lesson management: CRUD first-aid content, instructional videos                   | Simple     | 2                      |
| 12.12 | Article management: CRUD news, community alerts, prevention knowledge             | Simple     | 2                      |
|       |                                                                                   |            |                        |
|       | **Total Estimated Effort (man-days)**                                             |            | **170**                |
