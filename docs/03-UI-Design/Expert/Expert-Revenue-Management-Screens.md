# EXPERT REVENUE MANAGEMENT SCREENS - SNAKEAID PLATFORM

## Document Information
- **Module:** Snake Expert
- **Feature Category:** Revenue & Payment Management
- **Total Screens:** 5 screens
- **Related Features:** FE-13 to FE-16 (Set consultation fees, Receive payments, Issue invoices, View revenue reports)
- **Color Scheme:** Purple Primary `#6B46C1`, Green `#28A745` for earnings

---

## Flow Context

### Revenue Management Workflow

**Purpose:**
- Track consultation earnings (Patient scheduled + Rescuer urgent)
- Manage verification rewards
- Withdraw funds to bank accounts
- View transaction history and analytics
- Issue invoices and receipts
- Set consultation fees

**Revenue Sources:**
1. **Patient Consultations (Scheduled):** 300,000 VNĐ per session (Expert receives 90% = 270K after 10% platform fee)
2. **SOS Emergency Consultations (Patient):** 500,000 VNĐ per session (Expert receives 90% = 450K after 10% platform fee)
3. **Rescuer Support (Emergency):** Expert receives 50,000 VNĐ (10% shared from Rescuer's 500K order)
4. **AI Verification (Confirm):** 50,000 VNĐ per case
5. **AI Verification (Correction):** 75,000 VNĐ per case
6. **Complex Verification with Notes:** 100,000 VNĐ per case

**Key Features (Reference: Major-Features-Summary.md):**
- FE-13: Set consultation fees for different services
- FE-14: Receive payments after completing consultations
- FE-15: Issue invoices and receipts for consultations
- FE-16: View revenue reports and statistics

**Payment Processing:**
- Payment held in escrow during consultation
- Released to Expert wallet within 24 hours after completion
- Expert can withdraw to bank account anytime (minimum 500K VNĐ)
- Withdrawal processing: 1-3 business days

---

## Design System

### Color Palette
```
Primary Purple:     #6B46C1  (Expert branding)
Success Green:      #28A745  (Earnings, positive balance)
Warning Amber:      #FFC107  (Pending payments)
Error Red:          #DC3545  (Withdrawals, expenses)
Info Blue:          #007BFF  (Transaction info)
Neutral Gray:       #6C757D  (Past transactions)
```

### Revenue Status Colors
```
Completed:          Green background (#D4EDDA), green text
Pending:            Amber background (#FFF3CD), amber text
Processing:         Blue background (#E3F2FD), blue text
Failed:             Red background (#FFE5E5), red text
```

---

## Screen Designs

### Screen 1: Revenue Dashboard (Overview)

**Screen Purpose:**  
Comprehensive overview of Expert's earnings, upcoming payments, withdrawal status, and revenue analytics.

**Navigation:**
- Entry: Tap "Doanh Thu" from Main Dashboard, or Earnings card
- Exit: Tap item → Screen 2 (History), Withdraw button → Screen 4 (Withdrawal), Back → Dashboard

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Quản Lý Doanh Thu"
   - Filter icon (date range)
   - Help icon (?)

2. **Total Balance Card (Hero Section):**
   - Large purple gradient background
   - Icon: Wallet (white)
   - Label: "Tổng Số Dư Khả Dụng"
   - Amount: "12,500,000 VNĐ" (48pt, bold, white)
   - Growth indicator: "+2,350,000 (↑ 23%)" (16pt, light green)
   - Period: "So với tháng trước"
   - Two action buttons (white outlined):
     - "Rút Tiền" (primary, larger)
     - "Lịch Sử" (secondary)

3. **Pending Payments Section:**
   - "Đang Chờ Thanh Toán" header
   - Amber badge with count: "5 giao dịch"
   - Expandable card:
     - Amount: "1,875,000 VNĐ" (amber, large)
     - Breakdown:
       * "3 tư vấn Patient" → 2,025,000 VNĐ
       * "2 xác minh AI" → 125,000 VNĐ
       * "Platform fee -10%" → -275,000 VNĐ
     - Status: "Sẽ được cộng vào ví sau 24h"
     - Countdown: "Còn 18 giờ"

4. **This Month Stats (Grid - 2x2):**
   - **Card 1: Total Earned**
     - Icon: Money bag (green)
     - "Tổng Thu Nhập"
     - "8,750,000 VNĐ" (28pt, green, bold)
     - "+15% vs tháng trước" (small, green)

   - **Card 2: Consultations**
     - Icon: Video call (purple)
     - "Tư Vấn Hoàn Thành"
     - "24 buổi" (28pt, purple, bold)
     - "18 Patient + 6 Rescuer" (small, gray)

   - **Card 3: Verifications**
     - Icon: Checkmark badge (amber)
     - "Xác Minh AI"
     - "47 ca" (28pt, amber, bold)
     - "32 đúng + 15 sửa" (small, gray)

   - **Card 4: Withdrawn**
     - Icon: Bank transfer (red)
     - "Đã Rút"
     - "5,000,000 VNĐ" (28pt, red, bold)
     - "2 lần rút" (small, gray)

5. **Revenue Chart:**
   - "Xu Hướng Doanh Thu (30 ngày)"
   - Toggle: "Theo ngày" / "Theo tuần" / "Theo tháng"
   - Line chart showing:
     - Green line: Total earnings
     - Purple line: Consultations
     - Amber line: Verifications
   - Y-axis: Amount (millions VNĐ)
   - X-axis: Dates
   - Interactive: Tap data point to see details

6. **Quick Actions:**
   - "Thao Tác Nhanh"
   - Button chips (horizontal scroll):
     - "Đặt Giá Tư Vấn"
     - "Xuất Báo Cáo"
     - "Tải Hóa Đơn"
     - "Cài Đặt Ngân Hàng"

7. **Recent Transactions Preview:**
   - "Giao Dịch Gần Đây (5)"
   - List of 5 most recent:
     - Each row: Icon + Type + Amount + Date + Status badge
     - Example: "Tư vấn Patient - Nguyễn Văn A" | "+270,000 VNĐ" | "10/12" | "Hoàn thành" (green)
   - Link: "Xem Tất Cả →" → Screen 2

**Stitch Prompt (English):**

```
Revenue dashboard for snake expert earnings overview.

HEADER:
- Back arrow, "Quản Lý Doanh Thu" (24pt semi-bold purple), filter icon, help icon

HERO BALANCE CARD (purple gradient background, rounded 16px):
- Wallet icon (white, 48px)
- "Tổng Số Dư Khả Dụng" (16pt white)
- "12,500,000 VNĐ" (48pt bold white)
- "+2,350,000 (↑ 23%)" (16pt light green) + "So với tháng trước" (14pt white)
- Two white outlined buttons (side by side):
  * "Rút Tiền" (larger, 48px)
  * "Lịch Sử" (smaller, 44px)

PENDING PAYMENTS (expandable):
- "Đang Chờ Thanh Toán" header + "5 giao dịch" amber badge
- "1,875,000 VNĐ" (32pt amber bold)
- Breakdown list:
  * "3 tư vấn Patient → 2,025,000 VNĐ"
  * "2 xác minh AI → 125,000 VNĐ"
  * "Platform fee -10% → -275,000 VNĐ" (red)
- "Sẽ được cộng vào ví sau 24h" (12pt gray)
- "Còn 18 giờ" countdown (amber)

THIS MONTH STATS (2x2 grid, cards with shadows):
CARD 1 (green accent):
- Money bag icon (green, 36px)
- "Tổng Thu Nhập" (14pt gray)
- "8,750,000 VNĐ" (28pt green bold)
- "+15% vs tháng trước" (12pt green)

CARD 2 (purple accent):
- Video icon (purple, 36px)
- "Tư Vấn Hoàn Thành"
- "24 buổi" (28pt purple bold)
- "18 Patient + 6 Rescuer" (12pt gray)

CARD 3 (amber accent):
- Checkmark icon (amber, 36px)
- "Xác Minh AI"
- "47 ca" (28pt amber bold)
- "32 đúng + 15 sửa" (12pt gray)

CARD 4 (red accent):
- Bank icon (red, 36px)
- "Đã Rút"
- "5,000,000 VNĐ" (28pt red bold)
- "2 lần rút" (12pt gray)

REVENUE CHART:
- "Xu Hướng Doanh Thu (30 ngày)" header
- Toggle chips: "Theo ngày" (selected) | "Theo tuần" | "Theo tháng"
- Line chart with 3 lines:
  * Green line (Total earnings) - highest
  * Purple line (Consultations) - middle
  * Amber line (Verifications) - lowest
- Y-axis: "0M" to "10M"
- X-axis: "1/12" to "10/12"
- Grid background, smooth curves

QUICK ACTIONS (horizontal scroll):
- "Thao Tác Nhanh" header
- 4 chip buttons:
  * "Đặt Giá Tư Vấn" (purple outlined)
  * "Xuất Báo Cáo" (purple outlined)
  * "Tải Hóa Đơn" (purple outlined)
  * "Cài Đặt Ngân Hàng" (purple outlined)

RECENT TRANSACTIONS (preview list):
- "Giao Dịch Gần Đây (5)" header
- 5 rows:
  * Row 1: Video icon + "Tư vấn Patient - Nguyễn Văn A" + "+270,000 VNĐ" (green) + "10/12" + "Hoàn thành" green badge
  * Row 2: Video icon + "Tư vấn SOS - Trần Văn B" + "+450,000 VNĐ" (green) + "10/12" + "Hoàn thành" green badge
  * Row 2: Checkmark icon + "Xác minh AI - Rắn Hổ Mang" + "+75,000 VNĐ" (green) + "10/12" + "Hoàn thành"
  * Row 3: Video icon + "Hỗ trợ Rescuer - Đội SG" + "+50,000 VNĐ" (green) + "9/12" + "Hoàn thành"
  * Row 4: Checkmark + "Xác minh AI" + "+50,000 VNĐ" (amber) + "9/12" + "Đang chờ" amber badge
  * Row 5: Bank icon + "Rút tiền về ngân hàng" + "-2,000,000 VNĐ" (red) + "8/12" + "Hoàn thành"
- "Xem Tất Cả →" blue link

DESIGN: Financial dashboard, clear hierarchy, color-coded revenue streams, visual analytics, quick access to key actions.
```

---

### Screen 2: Transaction History (Detailed List)

**Screen Purpose:**  
Complete transaction history with advanced filtering, search, and export capabilities.

**Navigation:**
- Entry: Tap "Lịch Sử" from Screen 1, or "Xem Tất Cả" from recent transactions
- Exit: Tap transaction → Screen 3 (Transaction Detail), Back → Screen 1

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Lịch Sử Giao Dịch"
   - Export icon (download) → Export options (PDF/Excel)

2. **Summary Bar (Top):**
   - Selected period: "Tháng 12/2025" (tap to change)
   - Quick stats:
     - "Thu nhập: +8,750,000 VNĐ" (green)
     - "Chi: -5,000,000 VNĐ" (red)
     - "Ròng: +3,750,000 VNĐ" (purple, bold)

3. **Filter & Search Section:**
   - Search bar: "Tìm giao dịch..." (with search icon)
   - Filter chips (horizontal scroll):
     - "Tất Cả" (selected)
     - "Tư Vấn" (purple badge)
     - "Xác Minh" (amber badge)
     - "Rút Tiền" (red badge)
     - "Hoàn Tiền" (gray badge)
   - Advanced filters button: "Bộ Lọc" → Opens filter sheet

4. **Advanced Filter Sheet:**
   - Date range picker: "Từ ngày" - "Đến ngày"
   - Transaction type (multi-select):
     - ☐ Patient consultation
     - ☐ Rescuer consultation
     - ☐ AI verification
     - ☐ Withdrawal
     - ☐ Refund
   - Amount range: Min - Max (VNĐ)
   - Status:
     - ☐ Completed
     - ☐ Pending
     - ☐ Processing
     - ☐ Failed
   - Buttons: "Áp Dụng" (primary), "Đặt Lại" (secondary)

5. **Transaction List (Grouped by Date):**
   
   **Date Header:** "Hôm Nay - 10/12/2025" (sticky)
   
   **Transaction Card 1 (Completed Consultation):**
   - Left: Video call icon (purple circle background)
   - Main content:
     - Type: "Tư Vấn Patient" (bold, 18pt)
     - Details: "Nguyễn Văn A - #TVC20251210001"
     - Time: "14:30 - 15:17 (47 phút)"
   - Right:
     - Amount: "+270,000 VNĐ" (24pt, green, bold)
     - Net: "300K - 30K phí" (12pt, gray)
     - Status: "Hoàn thành" (green badge)
   - Tap for details arrow

   **Transaction Card 2 (AI Verification):**
   - Left: Checkmark icon (amber circle)
   - Main content:
     - Type: "Xác Minh AI - Chỉnh Sửa"
     - Details: "Rắn Hổ Mang - #XM20251210015"
     - Time: "13:15"
   - Right:
     - Amount: "+75,000 VNĐ" (24pt, green)
     - Status: "Hoàn thành" (green badge)

   **Transaction Card 3 (Pending Payment):**
   - Left: Video icon (purple circle, with clock overlay)
   - Main content:
     - Type: "Hỗ Trợ Rescuer" (Emergency support, not full consultation)
     - Details: "Đội Cứu Hộ SG - #HT20251210003"
     - Time: "11:45 - 12:08 (23 phút)"
   - Right:
     - Amount: "+50,000 VNĐ" (24pt, amber)
     - Status: "Đang chờ" (amber badge)
     - Countdown: "Còn 18h"

   **Date Header:** "Hôm Qua - 9/12/2025"

   **Transaction Card 4 (Withdrawal):**
   - Left: Bank icon (red circle)
   - Main content:
     - Type: "Rút Tiền Về Ngân Hàng"
     - Details: "VCB ****1234 - #RUT20251209001"
     - Time: "16:20"
   - Right:
     - Amount: "-2,000,000 VNĐ" (24pt, red, bold)
     - Status: "Đang xử lý" (blue badge)
     - ETA: "1-3 ngày"

   **Transaction Card 5 (Refund):**
   - Left: Undo icon (gray circle)
   - Main content:
     - Type: "Hoàn Tiền - Hủy Tư Vấn"
     - Details: "Patient hủy - #TVC20251209012"
     - Time: "09:30"
   - Right:
     - Amount: "-270,000 VNĐ" (24pt, red)
     - Status: "Hoàn tất" (gray badge)

6. **Load More:**
   - Bottom: "Tải Thêm Giao Dịch" button (when scrolled to end)
   - Or: Infinite scroll

7. **Empty State** (No transactions):
   - Icon: Empty wallet (gray, 80px)
   - "Chưa Có Giao Dịch"
   - "Lịch sử giao dịch của bạn sẽ hiển thị ở đây"

**Stitch Prompt (English):**

```
Transaction history screen for snake expert with filtering.

HEADER:
- Back arrow, "Lịch Sử Giao Dịch" (24pt semi-bold purple), export icon

SUMMARY BAR (light purple background):
- "Tháng 12/2025" dropdown (tap to change period)
- Stats: "Thu nhập: +8,750,000 VNĐ" (green) | "Chi: -5,000,000 VNĐ" (red) | "Ròng: +3,750,000 VNĐ" (purple bold)

SEARCH & FILTERS:
- Search bar "Tìm giao dịch..." (full-width, 48px)
- Chip filters (horizontal scroll):
  * "Tất Cả" (purple filled, selected)
  * "Tư Vấn" (purple outlined) + badge "24"
  * "Xác Minh" (amber outlined) + badge "47"
  * "Rút Tiền" (red outlined) + badge "2"
  * "Hoàn Tiền" (gray outlined)
- "Bộ Lọc" button (filter icon)

TRANSACTION LIST:

DATE HEADER: "Hôm Nay - 10/12/2025" (sticky, 16pt bold, gray background)

CARD 1 (white, rounded, shadow):
- Left: Purple circle (48px) + video icon (white)
- Middle:
  * "Tư Vấn Patient" (18pt bold)
  * "Nguyễn Văn A - #TVC20251210001" (14pt gray)
  * "14:30 - 15:17 (47 phút)" (12pt gray)
- Right:
  * "+270,000 VNĐ" (24pt green bold)
  * "300K - 30K phí" (12pt gray)
  * "Hoàn thành" green badge
- Arrow icon (far right)

CARD 2:
- Left: Amber circle + checkmark icon
- Middle:
  * "Xác Minh AI - Chỉnh Sửa"
  * "Rắn Hổ Mang - #XM20251210015"
  * "13:15"
- Right:
  * "+75,000 VNĐ" (24pt green)
  * "Hoàn thành" green badge
- Arrow

CARD 3:
- Left: Purple circle + video icon + clock overlay
- Middle:
  * "Hỗ Trợ Rescuer"
  * "Đội Cứu Hộ SG - #HT20251210003"
  * "11:45 - 12:08 (23 phút)"
- Right:
  * "+50,000 VNĐ" (24pt amber)
  * "Đang chờ" amber badge
  * "Còn 18h" (12pt amber)
- Arrow

DATE HEADER: "Hôm Qua - 9/12/2025"

CARD 4:
- Left: Red circle + bank icon
- Middle:
  * "Rút Tiền Về Ngân Hàng"
  * "VCB ****1234 - #RUT20251209001"
  * "16:20"
- Right:
  * "-2,000,000 VNĐ" (24pt red bold)
  * "Đang xử lý" blue badge
  * "1-3 ngày" (12pt blue)
- Arrow

CARD 5:
- Left: Gray circle + undo icon
- Middle:
  * "Hoàn Tiền - Hủy Tư Vấn"
  * "Patient hủy - #TVC20251209012"
  * "09:30"
- Right:
  * "-270,000 VNĐ" (24pt red)
  * "Hoàn tất" gray badge
- Arrow

BOTTOM:
- "Tải Thêm Giao Dịch" button (outlined purple)

DESIGN: Comprehensive transaction log, date grouping, clear visual hierarchy, color-coded amounts, status indicators, advanced filtering.
```

---

### Screen 3: Transaction Detail (Receipt View)

**Screen Purpose:**  
Detailed information about a specific transaction with receipt/invoice download option.

**Navigation:**
- Entry: Tap transaction card from Screen 2
- Exit: Back → Screen 2, Download → Save receipt

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Chi Tiết Giao Dịch"
   - Share icon → Share receipt
   - Download icon → Download PDF

2. **Status Banner:**
   - Full-width colored banner based on status:
     - Green: "✓ Giao Dịch Hoàn Tất"
     - Amber: "⏳ Đang Chờ Xử Lý"
     - Blue: "⚙️ Đang Xử Lý"
     - Red: "✗ Giao Dịch Thất Bại"

3. **Transaction Summary Card:**
   - Large transaction type icon (80px)
   - Type: "Tư Vấn Patient" (24pt, bold)
   - Transaction ID: "#TVC20251210001" (gray, monospace)
   - Amount: "+270,000 VNĐ" (40pt, green, bold)
   - Date & Time: "10 Tháng 12, 2025 - 14:30"

4. **Consultation Details** (For consultation transactions):
   - "Thông Tin Tư Vấn"
   - Patient info:
     - Avatar + Name: "Nguyễn Văn A"
     - Phone: "090 123 4567" (tap to call)
     - Location: "Quận 1, TP.HCM"
   - Consultation details:
     - Type: "Tư Vấn Trực Tuyến - Patient"
     - Start time: "14:30 - 10/12/2025"
     - End time: "15:17 - 10/12/2025"
     - Duration: "47 phút" (longer than scheduled 45min)
     - Method: "Video Call"
   - Case summary:
     - Snake identified: "Rắn Hổ Mang (Naja kaouthia)"
     - Severity: "Trung Bình" (amber badge)
     - Treatment: "Chuyển viện + Antivenom"

5. **Payment Breakdown:**
   - "Chi Tiết Thanh Toán"
   - Line items:
     - "Phí tư vấn cơ bản (45 phút)" → 300,000 VNĐ
     - "Thời gian vượt quá (2 phút)" → +0 VNĐ (free)
     - "Tổng phí dịch vụ" → 300,000 VNĐ (subtotal, bold)
     - "Platform phí (10%)" → -30,000 VNĐ (red)
     - Divider line
     - "Bạn nhận được" → +270,000 VNĐ (large, green, bold)
   - Payment method: "Ví SnakeAid" (icon)
   - Payment status: "Đã thanh toán" (green badge)

6. **Timeline (For pending/processing):**
   - "Trạng Thái Giao Dịch"
   - Vertical timeline:
     - ✓ "Tư vấn hoàn tất" - 10/12 15:17 (green)
     - ✓ "Patient đánh giá" - 10/12 15:20 (green)
     - ⏳ "Đang chờ thanh toán" - Còn 18 giờ (amber, current)
     - ○ "Cộng vào ví Expert" - Dự kiến 11/12 15:17 (gray)

7. **Receipt Information:**
   - "Thông Tin Hóa Đơn"
   - Issued to: "Expert [Your Name]"
   - Tax ID: "123456789" (if provided)
   - Address: "Your registered address"
   - Receipt number: "HD-2025-12-10-001"

8. **Action Buttons:**
   - Primary: "Tải Hóa Đơn PDF" (large, purple, 56px)
   - Secondary: "Báo Cáo Vấn Đề" (outlined red)
   - Link: "Chia Sẻ" (gray)

9. **Related Information:**
   - "Giao Dịch Liên Quan"
   - Show related transactions (e.g., refund, dispute)

**Stitch Prompt (English):**

```
Transaction detail receipt screen for snake expert.

HEADER:
- Back arrow, "Chi Tiết Giao Dịch" (24pt), share icon, download icon

STATUS BANNER (full-width green):
- "✓ Giao Dịch Hoàn Tất" (20pt white bold, centered)

SUMMARY CARD (white, centered):
- Large video icon (80px, purple circle background)
- "Tư Vấn Patient" (24pt bold)
- "#TVC20251210001" (16pt gray monospace)
- "+270,000 VNĐ" (40pt green bold)
- "10 Tháng 12, 2025 - 14:30" (14pt gray)

CONSULTATION DETAILS:
- "Thông Tin Tư Vấn" header (18pt bold)
- Patient card:
  * Avatar (48px) + "Nguyễn Văn A" (16pt bold)
  * "090 123 4567" (blue, tap to call) + phone icon
  * "Quận 1, TP.HCM" + location icon
- Details grid:
  * "Loại: Tư Vấn Trực Tuyến - Patient"
  * "Bắt đầu: 14:30 - 10/12/2025"
  * "Kết thúc: 15:17 - 10/12/2025"
  * "Thời lượng: 47 phút" (amber text, longer than 45min scheduled)
  * "Phương thức: Video Call"
- Case summary:
  * "Rắn: Rắn Hổ Mang (Naja kaouthia)" + snake icon
  * "Mức độ: Trung Bình" (amber badge)
  * "Điều trị: Chuyển viện + Antivenom"

PAYMENT BREAKDOWN:
- "Chi Tiết Thanh Toán" header
- Line items:
  * "Phí tư vấn cơ bản (45 phút)" → "300,000 VNĐ"
  * "Thời gian vượt quá (2 phút)" → "+0 VNĐ" (gray, strikethrough)
  * "Tổng phí dịch vụ" → "300,000 VNĐ" (bold)
  * "Platform phí (10%)" → "-30,000 VNĐ" (red)
  * Dashed divider
  * "Bạn nhận được" → "+270,000 VNĐ" (28pt green bold)
- "Ví SnakeAid" payment method + wallet icon
- "Đã thanh toán" green badge

TIMELINE:
- "Trạng Thái Giao Dịch" header
- Vertical timeline (left line connector):
  * ✓ "Tư vấn hoàn tất" | "10/12 15:17" (green)
  * ✓ "Patient đánh giá" | "10/12 15:20" (green)
  * ⏳ "Đang chờ thanh toán" | "Còn 18 giờ" (amber, bold, current step)
  * ○ "Cộng vào ví Expert" | "Dự kiến 11/12 15:17" (gray)

RECEIPT INFO:
- "Thông Tin Hóa Đơn" header
- "Xuất cho: Expert [Your Name]"
- "Mã số thuế: 123456789"
- "Địa chỉ: Your registered address"
- "Số hóa đơn: HD-2025-12-10-001"

BUTTONS:
- Large purple "Tải Hóa Đơn PDF" (56px, full-width, download icon)
- Medium outlined red "Báo Cáo Vấn Đề" (44px)
- Small gray link "Chia Sẻ"

DESIGN: Comprehensive receipt, clear payment breakdown, timeline visualization, professional invoice information, easy download.
```

---

### Screen 4: Withdrawal Request (Transfer to Bank)

**Screen Purpose:**  
Expert withdraws available balance to their registered bank account.

**Navigation:**
- Entry: Tap "Rút Tiền" from Screen 1 (Revenue Dashboard)
- Exit: Submit → Screen 5 (Withdrawal Confirmation), Cancel → Screen 1

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Rút Tiền Về Ngân Hàng"
   - Help icon (?)

2. **Available Balance Display:**
   - "Số Dư Khả Dụng"
   - Amount: "12,500,000 VNĐ" (36pt, green, bold)
   - Note: "Bạn có thể rút toàn bộ hoặc một phần" (small, gray)

3. **Withdrawal Amount Input:**
   - "Số Tiền Muốn Rút *"
   - Large input field (VNĐ suffix)
   - Placeholder: "Nhập số tiền (tối thiểu 500,000 VNĐ)"
   - Current input: "2,000,000 VNĐ"
   - Quick amount buttons below:
     - "500K", "1M", "2M", "5M", "Tất Cả" (12,500,000)
   - Validation:
     - Minimum: 500,000 VNĐ
     - Maximum: Available balance
     - Error message if invalid

4. **Bank Account Selection:**
   - "Chọn Tài Khoản Ngân Hàng *"
   - Radio button cards:
     
     **Card 1 (Selected):**
     - Radio button (checked, purple)
     - Bank logo: Vietcombank (32px)
     - Bank name: "Vietcombank (VCB)"
     - Account holder: "NGUYEN VAN EXPERT"
     - Account number: "**** **** **** 1234"
     - Status: "Đã xác minh" (green badge)
     
     **Card 2:**
     - Radio button (unchecked)
     - Bank logo: Techcombank (32px)
     - Bank name: "Techcombank (TCB)"
     - Account holder: "NGUYEN VAN EXPERT"
     - Account number: "**** **** **** 5678"
     - Status: "Đã xác minh" (green badge)

   - Link: "+ Thêm Tài Khoản Mới" (blue) → Bank account management

5. **Fee Information:**
   - "Phí Giao Dịch"
   - Line items:
     - "Số tiền rút" → 2,000,000 VNĐ
     - "Phí rút tiền (0%)" → 0 VNĐ (free, green text)
     - "Phí ngân hàng (0%)" → 0 VNĐ (free)
     - Divider
     - "Bạn nhận được" → 2,000,000 VNĐ (large, bold)

6. **Processing Time Info:**
   - "Thời Gian Xử Lý"
   - Icon: Clock
   - "1-3 ngày làm việc"
   - "Tiền sẽ được chuyển đến tài khoản ngân hàng của bạn"

7. **OTP Verification (If enabled):**
   - "Xác Nhận OTP"
   - Info: "Chúng tôi sẽ gửi mã OTP đến số điện thoại đã đăng ký"
   - Phone: "090 123 *567" (masked)

8. **Terms & Conditions:**
   - Checkbox: "Tôi đồng ý với điều khoản rút tiền"
   - Link: "Xem điều khoản" (blue, opens terms modal)

9. **Important Notes:**
   - Yellow info box:
   - "⚠️ Lưu Ý Quan Trọng:"
   - • Kiểm tra kỹ thông tin tài khoản trước khi xác nhận
   - • Giao dịch không thể hoàn tác sau khi xử lý
   - • Liên hệ support nếu tiền chưa về sau 5 ngày

10. **Action Buttons:**
    - Primary: "Xác Nhận Rút Tiền" (large, red, 56px)
      - Disabled if: amount < 500K, no bank selected, terms not accepted
    - Secondary: "Hủy" (outlined gray)

**Stitch Prompt (English):**

```
Withdrawal request screen for snake expert.

HEADER:
- Back arrow, "Rút Tiền Về Ngân Hàng" (24pt semi-bold purple), help icon

AVAILABLE BALANCE (light green background, centered):
- "Số Dư Khả Dụng" (14pt gray)
- "12,500,000 VNĐ" (36pt green bold)
- "Bạn có thể rút toàn bộ hoặc một phần" (12pt gray)

AMOUNT INPUT:
- "Số Tiền Muốn Rút *" label
- Large input field (56px height, purple border when focused)
- Placeholder "Nhập số tiền (tối thiểu 500,000 VNĐ)"
- Value "2,000,000 VNĐ" (24pt bold)
- Quick amount chips (below):
  * "500K" | "1M" | "2M" (selected, purple) | "5M" | "Tất Cả"

BANK SELECTION:
- "Chọn Tài Khoản Ngân Hàng *" label

CARD 1 (white, rounded, border purple when selected):
- Radio button (checked, purple circle)
- VCB logo (32px)
- "Vietcombank (VCB)" (16pt bold)
- "NGUYEN VAN EXPERT" (14pt gray)
- "**** **** **** 1234" (14pt monospace)
- "Đã xác minh" green badge

CARD 2 (white, rounded, border gray):
- Radio button (unchecked, gray circle)
- TCB logo (32px)
- "Techcombank (TCB)" (16pt bold)
- "NGUYEN VAN EXPERT" (14pt gray)
- "**** **** **** 5678" (14pt monospace)
- "Đã xác minh" green badge

LINK: "+ Thêm Tài Khoản Mới" (blue, 14pt)

FEE INFO:
- "Phí Giao Dịch" header
- "Số tiền rút → 2,000,000 VNĐ"
- "Phí rút tiền (0%) → 0 VNĐ" (green text "MIỄN PHÍ")
- "Phí ngân hàng (0%) → 0 VNĐ"
- Dashed divider
- "Bạn nhận được → 2,000,000 VNĐ" (24pt bold)

PROCESSING TIME (light blue background):
- Clock icon + "Thời Gian Xử Lý"
- "1-3 ngày làm việc" (16pt bold)
- "Tiền sẽ được chuyển đến tài khoản ngân hàng của bạn"

TERMS:
- Checkbox (unchecked) "Tôi đồng ý với điều khoản rút tiền"
- "Xem điều khoản" blue link

IMPORTANT NOTES (yellow background):
- Warning icon "⚠️ Lưu Ý Quan Trọng:"
- • "Kiểm tra kỹ thông tin tài khoản trước khi xác nhận"
- • "Giao dịch không thể hoàn tác sau khi xử lý"
- • "Liên hệ support nếu tiền chưa về sau 5 ngày"

BUTTONS:
- Large red "Xác Nhận Rút Tiền" (56px, full-width)
- Medium outlined gray "Hủy" (44px)

DESIGN: Clear amount input, bank selection with verification status, transparent fee structure, processing time expectations, important warnings.
```

---

### Screen 5: Withdrawal Confirmation (Success)

**Screen Purpose:**  
Confirmation that withdrawal request has been submitted successfully.

**Navigation:**
- Entry: Submit withdrawal from Screen 4
- Exit: Auto-redirect to Dashboard after 5s, or tap buttons

**Key Components:**

1. **Success Animation:**
   - Bank transfer icon with checkmark (120px)
   - Success animation (green expanding circle)

2. **Confirmation Message:**
   - "✓ Yêu Cầu Rút Tiền Thành Công!"
   - Subtext: "Tiền sẽ được chuyển đến tài khoản ngân hàng của bạn"

3. **Withdrawal Summary Card:**
   - "Thông Tin Rút Tiền"
   - Amount: "2,000,000 VNĐ" (36pt, red, bold)
   - Transaction ID: "#RUT20251210001" (gray, monospace)
   - Date & Time: "10 Tháng 12, 2025 - 16:45"
   - Bank destination:
     - Bank logo (VCB)
     - "Vietcombank (VCB)"
     - "**** **** **** 1234"
     - "NGUYEN VAN EXPERT"

4. **Timeline (Processing Status):**
   - "Trạng Thái Xử Lý"
   - Vertical timeline:
     - ✓ "Yêu cầu đã gửi" - 10/12 16:45 (green, current)
     - ⏳ "Đang xử lý" - Dự kiến trong 24h (blue)
     - ○ "Chuyển đến ngân hàng" - 1-3 ngày (gray)
     - ○ "Hoàn tất" - 11-13/12/2025 (gray)

5. **Updated Balance:**
   - "Số Dư Mới"
   - Old balance: "12,500,000 VNĐ" (strikethrough, gray)
   - Arrow down
   - New balance: "10,500,000 VNĐ" (28pt, purple, bold)
   - Change: "-2,000,000 VNĐ" (red)

6. **What's Next Section:**
   - "Tiếp Theo"
   - Info cards:
     - 📧 "Email xác nhận đã được gửi"
     - 🔔 "Bạn sẽ nhận thông báo khi hoàn tất"
     - 📱 "Kiểm tra SMS từ ngân hàng khi tiền về"
     - 📞 "Liên hệ support nếu có vấn đề"

7. **Action Buttons:**
   - Primary: "Xem Lịch Sử Giao Dịch" (purple, 56px) → Screen 2
   - Secondary: "Về Trang Chủ" (outlined purple) → Dashboard
   - Link: "Rút Tiền Tiếp" (gray) → Screen 4

8. **Auto-redirect:**
   - "Tự động về trang chủ sau 5s..." (small, gray, bottom)

**Stitch Prompt (English):**

```
Withdrawal confirmation success screen for snake expert.

SUCCESS ANIMATION:
- Large bank transfer icon with checkmark (120px, green circle background)
- Success animation (expanding green circle)

MESSAGE:
- "✓ Yêu Cầu Rút Tiền Thành Công!" (26pt bold green)
- "Tiền sẽ được chuyển đến tài khoản ngân hàng của bạn" (16pt gray)

SUMMARY CARD (white, rounded):
- "Thông Tin Rút Tiền" header
- "2,000,000 VNĐ" (36pt red bold)
- "#RUT20251210001" (14pt gray monospace)
- "10 Tháng 12, 2025 - 16:45" (14pt gray)
- Divider
- Bank destination:
  * VCB logo (32px) + "Vietcombank (VCB)" (16pt)
  * "**** **** **** 1234" (14pt monospace)
  * "NGUYEN VAN EXPERT" (14pt gray)

TIMELINE:
- "Trạng Thái Xử Lý" header
- Vertical timeline (left connector):
  * ✓ "Yêu cầu đã gửi" | "10/12 16:45" (green, bold, current)
  * ⏳ "Đang xử lý" | "Dự kiến trong 24h" (blue)
  * ○ "Chuyển đến ngân hàng" | "1-3 ngày" (gray)
  * ○ "Hoàn tất" | "11-13/12/2025" (gray)

BALANCE UPDATE (light purple background):
- "Số Dư Mới" header
- "12,500,000 VNĐ" (20pt gray strikethrough)
- Down arrow icon
- "10,500,000 VNĐ" (28pt purple bold)
- "-2,000,000 VNĐ" (16pt red)

WHAT'S NEXT:
- "Tiếp Theo" header
- 4 info cards (light blue background):
  * 📧 "Email xác nhận đã được gửi"
  * 🔔 "Bạn sẽ nhận thông báo khi hoàn tất"
  * 📱 "Kiểm tra SMS từ ngân hàng khi tiền về"
  * 📞 "Liên hệ support nếu có vấn đề"

BUTTONS:
- Large purple "Xem Lịch Sử Giao Dịch" (56px, full-width)
- Medium outlined purple "Về Trang Chủ" (44px)
- Small gray link "Rút Tiền Tiếp"

COUNTDOWN:
- "Tự động về trang chủ sau 5s..." (bottom, 12pt gray)

DESIGN: Clear success confirmation, detailed transaction info, processing timeline, balance update visualization, next steps guidance, smooth navigation.
```

---

## Integration Points

### API Endpoints:
- `GET /expert/revenue/dashboard` - Get revenue overview and stats
- `GET /expert/revenue/transactions` - Get transaction history with filters
- `GET /expert/revenue/transaction/{id}` - Get detailed transaction info
- `POST /expert/revenue/withdraw` - Create withdrawal request
- `GET /expert/revenue/bank-accounts` - Get registered bank accounts
- `POST /expert/revenue/bank-accounts` - Add new bank account
- `GET /expert/revenue/reports` - Generate revenue reports (PDF/Excel)
- `PUT /expert/settings/consultation-fees` - Set consultation pricing
- `GET /expert/revenue/invoices/{id}` - Download invoice/receipt

### Real-time Features:
- Live balance updates when payments clear
- Push notifications for completed transactions
- Withdrawal status updates
- Pending payment countdown timers

### Payment Processing:
- Escrow system: Payments held for 24h after consultation
- Platform fee: 10% deducted automatically
- Withdrawal minimum: 500,000 VNĐ
- Withdrawal processing: 1-3 business days
- Bank verification required before first withdrawal

### Data Analytics:
- Revenue trends (daily/weekly/monthly)
- Consultation vs verification earnings breakdown
- Peak earning hours/days
- Average consultation value
- Withdrawal patterns

---

## Version History
- **v1.0** - December 11, 2025: Initial revenue management screens design (5 screens)

---

## Design Review Checklist
- [x] Comprehensive revenue dashboard with stats
- [x] Detailed transaction history with filtering
- [x] Complete transaction detail with receipt
- [x] Secure withdrawal process with bank selection
- [x] Success confirmation with timeline
- [x] Payment breakdown transparency
- [x] Bank account verification indicators
- [x] Fee structure clearly displayed
- [x] Processing time expectations set
- [x] Purple color scheme consistent

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Expert-Dashboard-Screens.md, Expert-Consultation-Flow-Screens.md, Expert-Snake-Verification-Screens.md*
