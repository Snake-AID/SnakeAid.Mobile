# SNAKEAID - SYSTEM TEST MODULES (TEST PLAN)

Tài liệu này định nghĩa danh sách các Module Code (Cụm Test Case) cho toàn bộ hệ thống SnakeAid. Khung test này đảm bảo độ phủ (coverage) 100% cho:
- **3 luồng chính:** Snake Catching, SOS Emergency, Expert Consultation.
- **Các luồng phụ:** Xác thực (Auth), Ví (Wallet), Lịch sử (History), Knowledge Base.
- **Tương tác cộng đồng/Blog:** Community Alerts, Blog Posts, Lessons.
- **Core system:** Real-time (SignalR), Thanh toán (Payment), GPS Tracking.

---

| No | Module code | Passed | Failed | Pending | N/A | Number of test cases |
|----|-------------|--------|--------|---------|-----|----------------------|
| **A** | **Authentication & Identity Management** | | | | | |
| 1 | Sign Up & Role Registration (Member, Rescuer)  | 0 | 0 | 0 | 0 | 0 |
| 2 | Sign In With Password (All Roles)  | 0 | 0 | 0 | 0 | 0 |
| 3 | Forgot & Reset Password Flow  | 0 | 0 | 0 | 0 | 0 |
| 4 | Manage User Profile, Avatar & Settings  | 0 | 0 | 0 | 0 | 0 |
| 5 | Identity Document Verification (Rescuer/Expert)  | 0 | 0 | 0 | 0 | 0 |
| **B** | **Snake Catching Flow (Luồng Bắt Rắn)** | | | | | |
| 6 | Create Snake Catching Request (Images, GPS, Species)  | 0 | 0 | 0 | 0 | 0 |
| 7 | Process Catching Deposit (Round 1)  | 0 | 0 | 0 | 0 | 0 |
| 8 | Operator Verification & Assignment  | 0 | 0 | 0 | 0 | 0 |
| 9 | Rescuer EnRoute & Arrived Tracking  | 0 | 0 | 0 | 0 | 0 |
| 10 | Rescuer Mission Execution & Evidence Upload  | 0 | 0 | 0 | 0 | 0 |
| 11 | Process Actual Service Payment (Round 2)  | 0 | 0 | 0 | 0 | 0 |
| 12 | Cancel Catching Request & Deposit Refund  | 0 | 0 | 0 | 0 | 0 |
| **C** | **SOS Emergency Flow (Luồng Khẩn Cấp)** | | | | | |
| 13 | Trigger SOS Alarm (GPS, Symptoms, AI check)  | 0 | 0 | 0 | 0 | 0 |
| 14 | Operator Fast-Track Verification & Assignment  | 0 | 0 | 0 | 0 | 0 |
| 15 | Rescuer On-Scene Navigation & AI Triage  | 0 | 0 | 0 | 0 | 0 |
| 16 | SOS Find Nearest Hospital (Navigation)  | 0 | 0 | 0 | 0 | 0 |
| 17 | Process SOS Post-Service Payment  | 0 | 0 | 0 | 0 | 0 |
| **D** | **Expert Consultation Flow (Luồng Tư Vấn)** | | | | | |
| 18 | View & Filter Expert Directory  | 0 | 0 | 0 | 0 | 0 |
| 19 | Book Instant Consultation (On-call)  | 0 | 0 | 0 | 0 | 0 |
| 20 | Book Scheduled Consultation (Calendar, Time Slot)  | 0 | 0 | 0 | 0 | 0 |
| 21 | Process Consultation Escrow Payment  | 0 | 0 | 0 | 0 | 0 |
| 22 | WebRTC Video Room & Waiting Room Logic  | 0 | 0 | 0 | 0 | 0 |
| 23 | Cancellation & Escrow Refund (Expert-only cancel rule)  | 0 | 0 | 0 | 0 | 0 |
| **E** | **Community, Blog & Knowledge Base (Luồng Phụ)** | | | | | |
| 24 | Read Community Blog & Safety Alerts  | 0 | 0 | 0 | 0 | 0 |
| 25 | Manage Blog Posts (Admin/Operator)  | 0 | 0 | 0 | 0 | 0 |
| 26 | Search & View Snake Library (Encyclopedia)  | 0 | 0 | 0 | 0 | 0 |
| 27 | Search & View First Aid Protocol Guides  | 0 | 0 | 0 | 0 | 0 |
| 28 | Access Rescuer Training Lessons  | 0 | 0 | 0 | 0 | 0 |
| **F** | **System, Wallet & Utilities** | | | | | |
| 29 | Manage SnakeAidPay Wallet (Top-up, History, Withdraw)  | 0 | 0 | 0 | 0 | 0 |
| 30 | External Payment Interface (PayOS Callback)  | 0 | 0 | 0 | 0 | 0 |
| 31 | Notification Tab & SignalR Broadcasts  | 0 | 0 | 0 | 0 | 0 |
| 32 | Submit Ratings & Read Feedback  | 0 | 0 | 0 | 0 | 0 |
| 33 | View Mission & Consultation History (Filtering, Detail)  | 0 | 0 | 0 | 0 | 0 |
| | **TOTAL** | **0** | **0** | **0** | **0** | **0** |

---

### Ghi Chú Cover:
- **Core Flows (B, C, D):** Đã phân theo từng bước (Tạo request -> Assign -> Thực thi -> Thanh toán -> Hủy). Đặc biệt luồng Escrow của Consultation và rule hoàn tiền do "Expert Hủy" đã được tạo Module riêng (Module 23).
- **Payment & Wallet (F):** Tách rõ luồng thanh toán qua cổng ngoài (PayOS) và ví nội bộ (Module 29, 30).
- **Blog & Knowledge Base (E):** Đã bao gồm các luồng phụ như đọc Blog Community, Quản lý Blog, Thư viện Rắn (Snake Library) và Sơ cứu (First Aid). 
- **System Stability (F):** Thêm các test case cho WebRTC (gọi video), SignalR (socket realtime) và Push Notification để đảm bảo UI cập nhật ngay khi trạng thái đổi.