# SCOPE & ESTIMATION — SNAKEAID MOBILE APPLICATION

## Thông tin dự án

| Mục | Nội dung |
|-----|----------|
| **Tên dự án** | AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid) |
| **Phiên bản tài liệu** | 1.0 |
| **Ngày tạo** | 12/04/2026 |
| **Nền tảng** | Flutter Mobile (Android & iOS) + Admin Web Application |
| **Nhóm phát triển** | 5 thành viên: Trung (TL) · Khoa · Dưỡng · Nhân · Khiêm |
| **Tổng thời gian phát triển** | 10 tuần (Tuần 1–9 phát triển chính, Tuần 10 buffer/testing; hoàn thiện code trước Tuần 11) |

---

## 1. Overview

### 1.1 Scope & Estimation

> **Quy ước mức độ phức tạp:**
> - **Simple** — CRUD cơ bản, hiển thị dữ liệu, UI tĩnh: 2–4 man-days
> - **Medium** — Tích hợp API, quản lý state, form nghiệp vụ: 3–5 man-days
> - **Complex** — Realtime, thanh toán, video call, AI, map: 5–8 man-days

---

| #     | WBS Item                                                                    | Complexity | Est. Effort (man-days) |
|-------|-----------------------------------------------------------------------------|:----------:|:----------------------:|
| **1** | **Feature 1 — Xác thực & Quản lý tài khoản**                              |            | **5**                  |
| 1.1   | Đăng nhập / Đăng xuất (Member, Rescuer, Expert, Operator)                   | Simple     | 1                      |
| 1.2   | Đăng ký tài khoản Member & xác minh OTP                                     | Simple     | 2                      |
| 1.3   | Quản lý hồ sơ cá nhân, ảnh đại diện & bảo mật                              | Medium     | 2                      |
|       |                                                                             |            |                        |
| **2** | **Feature 2 — Luồng SOS Khẩn Cấp (Snakebite Emergency)**                  |            | **20**                 |
| 2.1   | Gửi yêu cầu SOS: GPS tự động, ảnh rắn, mô tả triệu chứng                  | Medium     | 4                      |
| 2.2   | Operator xác minh SOS & gán Rescuer qua SignalR                             | Complex    | 6                      |
| 2.3   | Rescuer nhận nhiệm vụ, cập nhật trạng thái di chuyển (EnRoute → Arrived)   | Medium     | 4                      |
| 2.4   | Thanh toán phí dịch vụ SOS (PayOS / Ví SnakeAidPay) & đóng đơn            | Medium     | 6                      |
|       |                                                                             |            |                        |
| **3** | **Feature 3 — Luồng Bắt Rắn (Snake Catching Request)**                    |            | **7**                  |
| 3.1   | Tạo yêu cầu bắt rắn: ảnh, vị trí GPS, mô tả loài & số lượng               | Simple     | 1                      |
| 3.2   | Thanh toán đặt cọc Round 1 — CatchingDeposit (PayOS / Ví SnakeAidPay)     | Medium     | 2                      |
| 3.3   | Operator xác nhận yêu cầu hợp lệ & gán Rescuer phù hợp                     | Medium     | 1                      |
| 3.4   | Rescuer thực hiện nhiệm vụ, ghi nhận kết quả & ảnh bằng chứng              | Medium     | 2                      |
| 3.5   | Thanh toán Round 2 — CatchingPayment (actualCost) & đóng đơn hoàn tất      | Medium     | 1                      |
|       |                                                                             |            |                        |
| **4** | **Feature 4 — Luồng Tư Vấn Chuyên Gia (Expert Consultation)**             |            | **7**                  |
| 4.1   | Danh sách chuyên gia: tìm kiếm, lọc theo chuyên môn, xem hồ sơ            | Simple     | 1                      |
| 4.2   | Tư vấn ngay lập tức (Instant): màn hình chờ, SignalR Accept/Reject          | Complex    | 2                      |
| 4.3   | Đặt lịch hẹn tư vấn (Scheduled): chọn slot, xác nhận, nhắc nhở             | Medium     | 2                      |
| 4.4   | Phòng chờ & Video Call (WebRTC / LiveKit) + Giải phóng Escrow              | Complex    | 2                      |
|       |                                                                             |            |                        |
| **5** | **Feature 5 — AI Nhận Diện Rắn & Kiến Thức Sơ Cứu**                      |            | **6**                  |
| 5.1   | Chụp / tải ảnh & gọi API AI nhận diện loài rắn                             | Medium     | 2                      |
| 5.2   | Hiển thị kết quả: tên loài, độc tính, mức độ nguy hiểm                     | Simple     | 1                      |
| 5.3   | Hướng dẫn sơ cứu & tra cứu thông tin loài rắn                              | Medium     | 2                      |
| 5.4   | Bản đồ định vị bệnh viện / cơ sở điều trị có huyết thanh gần nhất         | Medium     | 1                      |
|       |                                                                             |            |                        |
| **6** | **Feature 6 — Ví SnakeAid Pay & Hệ Thống Thanh Toán**                     |            | **8**                  |
| 6.1   | Màn hình ví: tổng quan số dư, tóm tắt giao dịch gần nhất                   | Simple     | 1                      |
| 6.2   | Nạp tiền vào ví qua PayOS (deep link, callback, xác nhận)                  | Complex    | 3                      |
| 6.3   | Rút tiền về tài khoản ngân hàng (nhập thông tin, xác nhận, trạng thái)     | Medium     | 2                      |
| 6.4   | Lịch sử & chi tiết giao dịch (lọc, phân trang)                             | Simple     | 2                      |
|       |                                                                             |            |                        |
| **7** | **Feature 7 — Thông Báo & Realtime**                                       |            | **5**                  |
| 7.1   | Push Notification (FCM) cho toàn bộ role & loại sự kiện                    | Medium     | 2                      |
| 7.2   | SignalR realtime: cập nhật trạng thái đơn, nhiệm vụ, tư vấn                | Complex    | 3                      |
|       |                                                                             |            |                        |
| **8** | **Feature 8 — Ứng Dụng Rescuer & Expert (Mobile)**                        |            | **7**                  |
| 8.1   | Quản lý nhiệm vụ Rescuer (nhận nhiệm vụ, cập nhật trạng thái)              | Medium     | 2                      |
| 8.2   | Quản lý tư vấn Expert (lịch, dashboard doanh thu, xác minh rắn)            | Medium     | 3                      |
| 8.3   | Điều hướng bản đồ & theo dõi vị trí realtime                               | Medium     | 3 (*)                  |
|       | *(* Tổng Feature 8 = 7 MD như kế hoạch; 8.3 thực tế ≈ 2 MD)*             |            |                        |
|       |                                                                             |            |                        |
| **9** | **Feature 9 — Ứng Dụng Operator (Web)**                                    |            | **3**                  |
| 9.1   | Hàng đợi yêu cầu SOS / Bắt rắn / Tư vấn chờ xử lý                        | Medium     | 1                      |
| 9.2   | Phân công Rescuer / Expert phù hợp                                          | Medium     | 1                      |
| 9.3   | Giám sát trạng thái realtime & can thiệp thủ công                          | Medium     | 1                      |
|       |                                                                             |            |                        |
| **10**| **Feature 10 — Ứng Dụng Admin (Web)**                                      |            | **8**                  |
| 10.1  | Bảng điều khiển & thống kê hệ thống (biểu đồ doanh thu, sự kiện)          | Simple     | 1                      |
| 10.2  | Quản lý người dùng & phân quyền (Member, Rescuer, Expert, Operator)        | Medium     | 1                      |
| 10.3  | Quản lý ca khẩn cấp / bắt rắn / tư vấn (xem, lọc, can thiệp trạng thái)  | Complex    | 2                      |
| 10.4  | Quản lý loài rắn (CRUD thông tin, ảnh, độc tính, lịch sử làm việc)        | Medium     | 1                      |
| 10.5  | Quản lý bệnh viện & cơ sở điều trị (CRUD, GPS, huyết thanh)               | Medium     | 1                      |
| 10.6  | Quản lý giao dịch (lịch sử, tra cứu, xác nhận thủ công, cấu hình động)    | Medium     | 1                      |
| 10.7  | Quản lý bài học & bài viết (CRUD nội dung, video, tin tức, cảnh báo)       | Simple     | 1                      |
|       |                                                                             |            |                        |
|       | **Total Estimated Effort (man-days)**                                       |            | **76**                 |

---

## 2. Phân bố công việc theo tuần

> **5 thành viên** với vai trò kết hợp FE-Mobile / FE-Web / BE / AI / DevOps.
> Năng lực FE hiệu quả ≈ **8–10 MD/tuần** (Trung + Khoa làm FE chủ lực; Dưỡng cover FE Emergency & Operator; Nhân + Khiêm hỗ trợ BE/API).

| Tuần | Phần việc chính (FE/Mobile/Web)                                                   | Trung | Khoa | Dưỡng | Nhân | Khiêm | MD |
|:----:|-----------------------------------------------------------------------------------|:-----:|:----:|:-----:|:----:|:-----:|:--:|
| 1    | F1 Auth (Login, Register/OTP, Profile) · F7.1 FCM Push Notification · F10.1 Admin Dashboard | ✓ | ✓ | ✓ | BE | BE/DevOps | 8 |
| 2    | F5 AI Snake ID + First-Aid + Hospital Map · F3.1 Tạo yêu cầu bắt rắn · F10.2–10.3 User Mgmt & Case Mgmt (Admin) | ✓ | ✓ | ✓ | BE | AI | 10 |
| 3    | F2.1 Gửi SOS · F3.2 Đặt cọc · F3.3 Operator validate Catching · F10.4–10.5 Snake Species & Hospital (Admin) | ✓ | ✓ | ✓ | BE | BE | 9 |
| 4    | F2.2 Operator SOS + SignalR assign · F3.4 Rescuer nhiệm vụ · F10.6–10.7 Transactions & Content (Admin) | ✓ | ✓ | ✓ | BE | BE | 10 |
| 5    | F2.3 Rescuer di chuyển · F3.5 Catching Round 2 · F2.4 SOS Payment (partial)      | ✓ | ✓ | ✓ | BE | BE | 8 |
| 6    | F2.4 SOS Payment (cont.) · F6.1 Wallet overview · F6.2 Nạp tiền PayOS            | ✓ | ✓ | —  | BE | DevOps | 7 |
| 7    | F6.3 Rút tiền · F6.4 Lịch sử giao dịch · F4.1 Danh sách Expert · F4.3 Đặt lịch hẹn | ✓ | ✓ | — | BE | BE | 7 |
| 8    | F4.2 Tư vấn Instant (SignalR) · F4.4 Video Call + Escrow · F7.2 SignalR Realtime · F9 Operator Web | ✓ | ✓ | ✓ | BE | BE | 10 |
| 9    | F8 Rescuer App · Expert App · Map navigation · Integration testing toàn hệ thống  | ✓ | ✓ | ✓ | Test | Test | 7 |
| 10   | Buffer: kiểm thử tích hợp, sửa lỗi, polish UI, chuẩn bị deployment               | ✓ | ✓ | ✓ | ✓ | CI/CD | — |
|      | **Tổng**                                                                          |   |   |   |   |   | **76** |

> **Ghi chú phân công:**
> - **Trung** (TL): FE-MB Snake Catching, Wallet, Payment, Knowledge; FE-Web Admin Dashboard/Lessons/Blogs; UI/UX
> - **Khoa**: FE-MB Auth, Expert Consultation (Video Call, Instant, Booking); FE-Web Admin (User, Case, Species, Transactions...)
> - **Dưỡng**: FE-MB Emergency/SOS, Notification; FE-Web Operator Module; BE Emergency/Auth/AI
> - **Nhân**: BE (Account, Catching, Payment, Wallet, Blog, Lesson, Transaction, Dashboard) — BE support xuyên suốt
> - **Khiêm**: AI fine-tuning, DevOps CI/CD (Jenkins + CodeMagic), BE Expert Consultation & Payment

---

## 3. Tổng hợp theo mức độ phức tạp

| Mức độ   | Số lượng function | Tổng man-days | Tỷ lệ |
|:--------:|:-----------------:|:-------------:|:-----:|
| Simple   | 9                 | 11            | 14%   |
| Medium   | 24                | 47            | 62%   |
| Complex  | 6                 | 18            | 24%   |
| **Tổng** | **39**            | **76**        | 100%  |

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
> - **Simple** — Basic CRUD, data display, static UI: 1–2 man-days
> - **Medium** — API integration, state management, business forms: 1–4 man-days
> - **Complex** — Realtime, payment, video call, AI, maps: 2–6 man-days

| #     | WBS Item                                                                          | Complexity | Est. Effort (man-days) |
|-------|-----------------------------------------------------------------------------------|:----------:|:----------------------:|
| **1** | **Feature 1 — Authentication & Account Management**                               |            | **5**                  |
| 1.1   | Login / Logout (Member, Rescuer, Expert, Operator)                                | Simple     | 1                      |
| 1.2   | Member registration & OTP verification                                            | Simple     | 2                      |
| 1.3   | Personal profile, avatar & security management                                    | Medium     | 2                      |
|       |                                                                                   |            |                        |
| **2** | **Feature 2 — SOS Emergency Response (Snakebite)**                               |            | **20**                 |
| 2.1   | Send SOS request: auto GPS, snake photo, symptom description                      | Medium     | 4                      |
| 2.2   | Operator verifies SOS & assigns Rescuer via SignalR                               | Complex    | 6                      |
| 2.3   | Rescuer receives mission, updates movement status (EnRoute → Arrived)             | Medium     | 4                      |
| 2.4   | SOS service payment (PayOS / SnakeAid Wallet) & case closure                      | Medium     | 6                      |
|       |                                                                                   |            |                        |
| **3** | **Feature 3 — Snake Catching Request**                                            |            | **7**                  |
| 3.1   | Create snake catching request: photo, GPS, species & quantity description         | Simple     | 1                      |
| 3.2   | Round 1 deposit payment — CatchingDeposit (PayOS / SnakeAid Wallet)              | Medium     | 2                      |
| 3.3   | Operator validates request & assigns suitable Rescuer                             | Medium     | 1                      |
| 3.4   | Rescuer completes mission, records results & photo evidence                       | Medium     | 2                      |
| 3.5   | Round 2 payment — CatchingPayment (actualCost) & order completion                 | Medium     | 1                      |
|       |                                                                                   |            |                        |
| **4** | **Feature 4 — Expert Consultation**                                               |            | **7**                  |
| 4.1   | Expert listing & profile view                                                     | Simple     | 1                      |
| 4.2   | Instant consultation (SignalR Accept/Reject waiting screen)                       | Complex    | 2                      |
| 4.3   | Scheduled consultation (slot selection, confirmation, reminders)                  | Medium     | 2                      |
| 4.4   | Video call & escrow payment (WebRTC / LiveKit)                                    | Complex    | 2                      |
|       |                                                                                   |            |                        |
| **5** | **Feature 5 — AI Snake Identification & First-Aid Knowledge**                    |            | **6**                  |
| 5.1   | Upload photo & AI snake identification                                            | Medium     | 2                      |
| 5.2   | Display toxicity & danger level                                                   | Simple     | 1                      |
| 5.3   | First-aid guideline & snake information lookup                                    | Medium     | 2                      |
| 5.4   | Nearest hospital / treatment center map                                           | Medium     | 1                      |
|       |                                                                                   |            |                        |
| **6** | **Feature 6 — SnakeAid Wallet & Payment System**                                 |            | **8**                  |
| 6.1   | Wallet overview & balance                                                         | Simple     | 1                      |
| 6.2   | Top-up via PayOS (deep link, callback, confirmation)                              | Complex    | 3                      |
| 6.3   | Withdraw to bank account (input, confirm, status tracking)                        | Medium     | 2                      |
| 6.4   | Transaction history & detail (filter, pagination)                                 | Simple     | 2                      |
|       |                                                                                   |            |                        |
| **7** | **Feature 7 — Notifications & Realtime System**                                  |            | **5**                  |
| 7.1   | Push Notification (FCM) for all roles & event types                               | Medium     | 2                      |
| 7.2   | SignalR realtime updates (order status, missions, consultations)                  | Complex    | 3                      |
|       |                                                                                   |            |                        |
| **8** | **Feature 8 — Rescuer & Expert Mobile Applications**                             |            | **7**                  |
| 8.1   | Rescuer mission management (receive, update status, record results)               | Medium     | 2                      |
| 8.2   | Expert consultation management (schedule, revenue dashboard, snake verify)        | Medium     | 3                      |
| 8.3   | Map navigation & realtime location tracking                                       | Medium     | 3 (*)                  |
|       | *(* Feature 8 total = 7 MD as planned)*                                          |            |                        |
|       |                                                                                   |            |                        |
| **9** | **Feature 9 — Operator Web Application**                                         |            | **3**                  |
| 9.1   | SOS / Snake catching / consultation queue management                              | Medium     | 1                      |
| 9.2   | Assign rescuer / expert to cases                                                  | Medium     | 1                      |
| 9.3   | Realtime status monitoring & manual override                                      | Medium     | 1                      |
|       |                                                                                   |            |                        |
| **10**| **Feature 10 — Admin Web Application**                                           |            | **8**                  |
| 10.1  | Dashboard & system statistics (revenue charts, event overview)                    | Simple     | 1                      |
| 10.2  | User & role management (CRUD Member, Rescuer, Expert, Operator)                   | Medium     | 1                      |
| 10.3  | Case management — SOS / Snake Catching / Consultation (view, filter, override)    | Complex    | 2                      |
| 10.4  | Snake species management (CRUD species, photo, toxicity, work history)            | Medium     | 1                      |
| 10.5  | Hospital & treatment center management (CRUD, GPS, antivenom)                     | Medium     | 1                      |
| 10.6  | Transaction management (history, lookup, manual confirm, dynamic config)          | Medium     | 1                      |
| 10.7  | Lesson & Article management (CRUD first-aid content, news, community alerts)      | Simple     | 1                      |
|       |                                                                                   |            |                        |
|       | **Total Estimated Effort (man-days)**                                             |            | **76**                 |

---

## 6. Team Contribution

| Roll Number | Full Name              | Role        | Contribution | Scope                                                                 |
|-------------|------------------------|:-----------:|:------------:|-----------------------------------------------------------------------|
| SE183494    | Đoàn Ngọc Trung        | Team Leader | 21%          | FE-MB: Snake Catching, Payment, Wallet, Blogs, Lessons, Snake Library, AI Verify (Expert) · FE-Web: Admin Dashboard, Lessons, Blogs · UI/UX (Figma) · BA · Tester · Docs |
| SE183495    | Phan Anh Khoa          | Member      | 18%          | FE-MB: Auth, Expert Consultation (Booking, Instant, Payment, Video Call) · FE-Web: Auth, User Mgmt, Incident/Mission, Workshift, Species, Antivenom, Treatment, Transactions · UI/UX · Docs |
| SE181515    | Nguyễn Mạnh Dưỡng      | Member      | 22%          | AI: Fine-tuning & inference · BE: Emergency, Notification, Auth, SnakeSpecies, Workshift, AI Verify · FE-Web: Operator Module, Admin Emergency · FE-MB: Emergency, Notification |
| SE184696    | Nguyễn Phúc Nhân       | Member      | 19%          | BE: Account, Emergency, Catching, Payment, Wallet, Snake, Blog, Lesson, Community Report, Transaction, Dashboard · BA · Tester · Docs |
| SE180168    | Nguyễn Văn Duy Khiêm   | Member      | 20%          | AI: Fine-tuning & inference · DevOps: CI/CD (Jenkins + CodeMagic), server networking, self-hosted Linux · BE: Expert Consultation (Discovery, Scheduling, Video Call, Review), Payment, Wallet Top-up · Testing · Docs |
