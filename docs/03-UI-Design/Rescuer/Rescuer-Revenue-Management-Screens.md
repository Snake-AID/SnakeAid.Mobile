# REVENUE MANAGEMENT SCREENS - UI DESIGN (RESCUER ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **RESCUER/SUPPORTER** (Đội cứu hộ rắn)
- **Flow:** Revenue Management Flow (Quản lý doanh thu từ dịch vụ cứu hộ)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 6 screens
- **Ngày tạo:** December 11, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Revenue-Management-Screens.md`

> **⚠️ LƯU Ý:** Document này cover màn hình cho **RESCUER role** trong **Revenue Management**.
> Rescuer có thể theo dõi doanh thu, trạng thái thanh toán, lịch sử giao dịch và xem đánh giá từ khách hàng.

---

## 🎯 Flow Context (From Requirements)

### Revenue Management Features for Rescuer:

**From Major Features Summary (FE-24 to FE-27):**
- **FE-24:** Chấp nhận yêu cầu cứu hộ có trả phí từ bệnh nhân
- **FE-25:** Theo dõi doanh thu, trạng thái thanh toán và lịch sử giao dịch
- **FE-26:** Nhận thanh toán qua nền tảng sau khi hoàn thành cứu hộ
- **FE-27:** Xem đánh giá và nhận phản hồi từ khách hàng để cải thiện ưu tiên xếp hạng

**From Main Flow (Flow 2.4):**
```
Thanh toán và đánh giá:
1. Rescuer đánh dấu "Hoàn thành nhiệm vụ"
   ↓
2. Patient thanh toán qua nền tảng
   ↓
3. Hệ thống xử lý: 85% → Rescuer, 5% → Expert (nếu có), 10% → Platform
   ↓
4. Patient đánh giá Rescuer (1-5 sao)
   ↓
5. Rescuer nhận thông báo thanh toán và đánh giá
```

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange `#FF8A00` (Rescuer brand color)
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Pending:** Amber `#FFC107`
- **Accent - Warning:** Red `#DC3545`
- **Accent - Info:** Blue `#007BFF`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)
- **Currency:** Bold (18-24pt)

### Component Style:
- **Cards:** Rounded corners (12px), subtle shadow
- **Buttons:** Rounded (8px), large touch targets (min 50px height)
- **Status Badges:** Rounded pills with color-coded backgrounds
- **Charts:** Simple bar/line charts with orange accent
- **Currency Display:** Large, bold, prominent

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - quản lý doanh thu cứu hộ

---

### Screen 1: Revenue Dashboard (Overview)

#### Thông tin màn hình:
- **Tên:** Màn hình tổng quan doanh thu
- **Mục đích:** Hiển thị tóm tắt thu nhập, thống kê và trạng thái thanh toán
- **Flow position:** Entry point từ bottom nav hoặc Dashboard
- **Priority:** ⭐⭐⭐ (Cao nhất)

#### Key Components:
1. **Header Section:**
   - Back button (if from Dashboard) or Close (if modal)
   - Title: "Doanh Thu" (centered)
   - Filter icon (top-right): Chọn khoảng thời gian

2. **Total Earnings Card (Hero Section):**
   - Large prominent card with gradient background (orange)
   - Label: "Tổng Thu Nhập Tháng Này"
   - Large amount: "8,500,000 VNĐ" (bold, white text)
   - Comparison: "+15% so với tháng trước" (with up arrow)
   - Small text: "Đã hoàn thành 34 nhiệm vụ"

3. **Quick Stats Row (3 Cards):**
   - Card 1: "Chờ Thanh Toán"
     - Amount: "1,200,000 VNĐ"
     - Count: "4 nhiệm vụ"
     - Amber badge
   - Card 2: "Đã Nhận"
     - Amount: "7,300,000 VNĐ"
     - Count: "30 nhiệm vụ"
     - Green badge
   - Card 3: "Đánh Giá Trung Bình"
     - Rating: "4.8 ⭐"
     - Count: "(156 đánh giá)"
     - Blue badge

4. **Earnings Chart Section:**
   - Title: "Thu Nhập 7 Ngày Qua"
   - Simple bar chart showing daily earnings
   - X-axis: Days (T2, T3, T4, T5, T6, T7, CN)
   - Y-axis: Amount in millions
   - Orange bars

5. **Recent Transactions Section:**
   - Title: "Giao Dịch Gần Đây"
   - List of 5 recent transactions (scrollable)
   - Each transaction card shows:
     - Date & Time: "10/12/2025 - 14:30"
     - Mission type: "Cứu hộ rắn hổ mang"
     - Location: "Quận 1, TP.HCM"
     - Amount: "250,000 VNĐ" (green if paid, amber if pending)
     - Status badge: "Đã thanh toán" / "Chờ thanh toán"
   - Button: "Xem tất cả →"

6. **Action Buttons:**
   - Primary button: "Xem Lịch Sử Đầy Đủ"
   - Secondary button: "Rút Tiền"

7. **Bottom Navigation Bar:**
   - 4 tabs: "Trang chủ", "Nhiệm vụ", "Doanh thu" (active), "Cá nhân"

#### Stitch Prompt (English):

```
Mobile app revenue dashboard for snake rescuer. Professional financial interface with orange (#FF8A00) primary color on white background.

Top header: Back arrow left, centered title "Doanh Thu", filter icon (funnel) right.

Hero section: Large card with orange gradient background (#FF8A00 to #F7931E), rounded corners, shadow. Card contains:
- Small white text "Tổng Thu Nhập Tháng Này"
- Extra large white bold text "8,500,000 VNĐ" (28pt)
- Small text "+15% so với tháng trước" with up arrow icon in light green background chip
- Bottom text "Đã hoàn thành 34 nhiệm vụ" in semi-transparent white

Below hero, three equal-width stat cards in horizontal row with light backgrounds:
Card 1 (amber tint #FFF3CD):
- Top: Amber badge "CHỜ THANH TOÁN"
- Large number "1,200,000 VNĐ" in dark text
- Small text "4 nhiệm vụ"

Card 2 (green tint #D4EDDA):
- Top: Green badge "ĐÃ NHẬN"
- Large number "7,300,000 VNĐ" in dark text
- Small text "30 nhiệm vụ"

Card 3 (blue tint #E3F2FD):
- Top: Blue badge "ĐÁNH GIÁ"
- Large text "4.8 ⭐" in dark
- Small text "(156 đánh giá)"

Section titled "Thu Nhập 7 Ngày Qua" with simple bar chart below:
- 7 vertical orange bars of varying heights
- X-axis labels: T2, T3, T4, T5, T6, T7, CN
- Y-axis shows values: 0.5M, 1M, 1.5M
- Clean minimal grid lines

Section titled "Giao Dịch Gần Đây" showing 3 scrollable transaction cards:

Card 1:
- Left: Small calendar icon
- Top text "10/12/2025 - 14:30" in gray
- Bold text "Cứu hộ rắn hổ mang"
- Small text "Quận 1, TP.HCM" with location pin
- Right: Green text "250,000 VNĐ"
- Green badge "Đã thanh toán" below

Card 2:
- Similar structure
- "09/12/2025 - 09:15"
- "Cứu hộ rắn lục"
- "Quận 3, TP.HCM"
- Right: Amber text "180,000 VNĐ"
- Amber badge "Chờ thanh toán"

Card 3:
- Similar structure
- "08/12/2025 - 16:45"
- Green "350,000 VNĐ"
- Green badge "Đã thanh toán"

Small text link "Xem tất cả →" in orange at bottom of transaction section.

Two bottom buttons:
- Large solid orange button "Xem Lịch Sử Đầy Đủ" (60px height)
- Medium outlined button "Rút Tiền"

Bottom navigation bar with 4 tabs: "Trang chủ", "Nhiệm vụ", "Doanh thu" (active, orange), "Cá nhân" (gray).

Design: Professional financial dashboard, clear earnings visualization, transaction history emphasis, rating visibility, clean data presentation.
```

#### Notes for Stitch:
- Currency display phải lớn và bold để dễ đọc
- Chart phải simple và dễ hiểu (không quá phức tạp)
- Status badges phải color-coded rõ ràng (green = paid, amber = pending)
- Bottom nav phải highlight "Doanh thu" tab

---

### Screen 2: Transaction History (Full List)

#### Thông tin màn hình:
- **Tên:** Màn hình lịch sử giao dịch đầy đủ
- **Mục đích:** Hiển thị toàn bộ lịch sử các nhiệm vụ và thanh toán
- **Flow position:** Từ Revenue Dashboard → "Xem tất cả"
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Lịch Sử Giao Dịch"
   - Search icon (top-right)

2. **Filter Bar:**
   - Horizontal scrollable chips:
     - "Tất cả" (selected - orange)
     - "Đã thanh toán" (green outline)
     - "Chờ thanh toán" (amber outline)
     - "Đã hủy" (gray outline)
   - Date range picker: "Tháng này ▼"

3. **Summary Stats (Top Card):**
   - "Kỳ này: 01/12 - 10/12/2025"
   - Two columns:
     - Left: "Tổng thu nhập: 8,500,000 VNĐ"
     - Right: "Số nhiệm vụ: 34"

4. **Transaction List (Grouped by Date):**
   - Date header: "Hôm nay - 10/12/2025"
   - Transaction cards under each date:
     
     **Card format:**
     - Time: "14:30"
     - Mission ID: "#RES-20251210-001" (small, gray)
     - Mission type: "Cứu hộ rắn hổ mang chúa" (bold)
     - Patient name: "Nguyễn Văn A"
     - Location: "123 Nguyễn Huệ, Q.1"
     - Duration: "45 phút"
     - Amount: "250,000 VNĐ" (large, right-aligned)
     - Status badge: "Đã thanh toán" (green) / "Chờ thanh toán" (amber)
     - Platform fee: "-25,000 VNĐ (10%)" (small, gray)
     - Net amount: "225,000 VNĐ" (green, semi-bold)
     - Rating (if received): "5.0 ⭐" (small)
     - Tap to view details arrow

5. **Load More:**
   - Button at bottom: "Tải thêm" (if more transactions)

6. **Empty State (if no transactions):**
   - Icon: Empty wallet
   - Text: "Chưa có giao dịch nào"
   - Subtext: "Hoàn thành nhiệm vụ để nhận thu nhập"

#### Stitch Prompt (English):

```
Mobile app transaction history screen for snake rescuer. Full transaction list with filtering and date grouping.

Top header: Back arrow left, centered title "Lịch Sử Giao Dịch", search icon right.

Filter bar with horizontal scrollable chips:
"Tất cả" (solid orange background, white text - selected)
"Đã thanh toán" (green outline)
"Chờ thanh toán" (amber outline)
"Đã hủy" (gray outline)
Below chips, dropdown "Tháng này ▼" on right.

Summary card with light gray background showing:
"Kỳ này: 01/12 - 10/12/2025" small gray text on top
Two columns:
Left: "Tổng thu nhập" gray text | "8,500,000 VNĐ" bold orange below
Right: "Số nhiệm vụ" gray text | "34" bold dark gray below

Date section header "Hôm nay - 10/12/2025" in medium gray with bottom border line.

Transaction card 1 (white background, rounded, shadow):
- Top left: "14:30" bold
- Top right: Green badge "ĐÃ THANH TOÁN"
- Small gray text "#RES-20251210-001"
- Bold text "Cứu hộ rắn hổ mang chúa" (18pt)
- Row: Small user icon + "Nguyễn Văn A"
- Row: Location pin + "123 Nguyễn Huệ, Q.1"
- Row: Clock icon + "45 phút"
- Horizontal divider line
- Left: "Phí dịch vụ" gray text | Right: Bold "250,000 VNĐ" orange
- Left: "Phí nền tảng (10%)" small gray | Right: "-25,000 VNĐ" gray
- Bottom row: "Thực nhận" bold | "225,000 VNĐ" large green text
- Small "5.0 ⭐" yellow stars on bottom left
- Right arrow on far right

Transaction card 2 (similar structure):
- "09:15"
- Amber badge "CHỜ THANH TOÁN"
- "#RES-20251210-002"
- "Cứu hộ rắn lục đuôi đỏ"
- "Trần Thị B"
- "456 Lê Lợi, Q.3"
- "30 phút"
- "180,000 VNĐ" amber text
- Status: "Chờ bệnh nhân xác nhận" small amber text

Date header "Hôm qua - 09/12/2025"

Transaction card 3:
- "16:45"
- Green badge "ĐÃ THANH TOÁN"
- Similar structure
- "350,000 VNĐ"
- "4.5 ⭐"

Bottom: Gray outlined button "Tải Thêm" centered.

Design: Comprehensive transaction history, clear date grouping, detailed breakdown showing net earnings after platform fee, visual status indicators, tap for details.
```

#### Notes for Stitch:
- Date grouping giúp dễ scan transactions
- Platform fee breakdown phải transparent (10%)
- Net amount (thực nhận) phải prominent
- Rating display nếu có
- Status badges color-coded

---

### Screen 3: Transaction Detail Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chi tiết giao dịch
- **Mục đích:** Hiển thị thông tin chi tiết về một giao dịch cụ thể
- **Flow position:** Từ Transaction History → Tap vào transaction
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chi Tiết Giao Dịch"
   - Share icon (top-right) - Export receipt

2. **Status Banner:**
   - Full-width banner với màu theo status:
     - Green: "✓ ĐÃ THANH TOÁN"
     - Amber: "⏳ CHỜ THANH TOÁN"
     - Red: "✗ ĐÃ HỦY"
   - Date completed: "10/12/2025 - 14:30"

3. **Mission Information Card:**
   - Section title: "Thông Tin Nhiệm Vụ"
   - Mission ID: "#RES-20251210-001"
   - Mission type: "Cứu hộ rắn hổ mang chúa"
   - Snake danger level: "CỰC ĐỘC" (red badge)
   - Start time: "14:30"
   - Completion time: "15:15"
   - Total duration: "45 phút"
   - Distance traveled: "3.2 km"

4. **Patient Information Card:**
   - Section title: "Thông Tin Khách Hàng"
   - Patient name: "Nguyễn Văn A"
   - Phone: "090***1234" (masked)
   - Location: "123 Nguyễn Huệ, Quận 1, TP.HCM"
   - Button: "Xem vị trí trên bản đồ"

5. **Payment Breakdown Card:**
   - Section title: "Chi Tiết Thanh Toán"
   - Base rate: "Phí cứu hộ cơ bản: 200,000 VNĐ"
   - Distance fee: "Phí di chuyển (3.2km): 32,000 VNĐ"
   - Time fee: "Phí thời gian (45 phút): 18,000 VNĐ"
   - Subtotal: "Tổng cộng: 250,000 VNĐ"
   - Platform fee: "Phí nền tảng (10%): -25,000 VNĐ"
   - Divider line (bold)
   - Net amount: "Bạn nhận được: 225,000 VNĐ" (large, green)
   - Payment method: "Thanh toán qua ví SnakeAid"
   - Payment date: "10/12/2025 - 15:30"
   - Transaction ID: "PAY-20251210-001"

6. **Rating & Review Card:**
   - Section title: "Đánh Giá Của Khách Hàng"
   - Star rating: "5.0 ⭐⭐⭐⭐⭐"
   - Review text: "Đội cứu hộ rất chuyên nghiệp, đến nhanh và xử lý rắn an toàn. Rất hài lòng!"
   - Date: "10/12/2025 - 15:20"

7. **Documents Section:**
   - "Tài Liệu Đính Kèm"
   - Photos taken: "3 ảnh" (thumbnail preview)
   - Mission report: "Báo cáo.pdf"
   - Button: "Xem tất cả tài liệu"

8. **Action Buttons:**
   - If status = "Chờ thanh toán":
     - Button: "Nhắc khách hàng thanh toán"
   - If status = "Đã thanh toán":
     - Primary button: "Xuất Hóa Đơn"
     - Secondary button: "Báo Cáo Sự Cố"

#### Stitch Prompt (English):

```
Mobile app transaction detail screen for snake rescuer. Comprehensive receipt-style interface with payment breakdown.

Top header: Back arrow left, centered title "Chi Tiết Giao Dịch", share icon right.

Full-width green status banner (#28A745) with white text "✓ ĐÃ THANH TOÁN" centered, below in smaller text "10/12/2025 - 14:30".

White card titled "Thông Tin Nhiệm Vụ":
- Gray label "Mã nhiệm vụ" | Bold "#RES-20251210-001" right
- Bold "Cứu hộ rắn hổ mang chúa" with red badge "CỰC ĐỘC" inline
- Row: "Bắt đầu" gray | "14:30" right
- Row: "Hoàn thành" gray | "15:15" right
- Row: "Thời gian" gray | "45 phút" bold orange right
- Row: "Khoảng cách" gray | "3.2 km" right

White card titled "Thông Tin Khách Hàng":
- Small user icon left
- "Nguyễn Văn A" bold
- "090***1234" gray below
- Location pin + "123 Nguyễn Huệ, Quận 1, TP.HCM"
- Blue text link "Xem vị trí trên bản đồ →"

White card titled "Chi Tiết Thanh Toán":
- Row: "Phí cứu hộ cơ bản" | "200,000 VNĐ" right
- Row: "Phí di chuyển (3.2km)" | "32,000 VNĐ" right
- Row: "Phí thời gian (45 phút)" | "18,000 VNĐ" right
- Thin gray divider
- Row: "Tổng cộng" bold | "250,000 VNĐ" bold right
- Row: "Phí nền tảng (10%)" red | "-25,000 VNĐ" red right
- Thick divider line
- Row: "Bạn nhận được" extra bold | "225,000 VNĐ" large green text (24pt)
- Small section below:
  - "Phương thức: Ví SnakeAid"
  - "Ngày thanh toán: 10/12/2025 - 15:30"
  - "Mã giao dịch: PAY-20251210-001" small gray

White card titled "Đánh Giá Của Khách Hàng":
- Large "5.0" number with 5 yellow star icons
- Review text in quotes: "Đội cứu hộ rất chuyên nghiệp, đến nhanh và xử lý rắn an toàn. Rất hài lòng!"
- Small gray "10/12/2025 - 15:20" timestamp

White card titled "Tài Liệu Đính Kèm":
- Row of 3 small square image thumbnails (80x80px each)
- Text "Báo cáo.pdf" with file icon
- Blue link "Xem tất cả tài liệu →"

Two bottom buttons:
- Large solid orange button "Xuất Hóa Đơn" (60px)
- Medium outlined gray button "Báo Cáo Sự Cố"

Design: Receipt-style detailed breakdown, transparent fee structure, customer feedback display, professional documentation, export capability.
```

#### Notes for Stitch:
- Payment breakdown phải rất chi tiết và transparent
- Platform fee (10%) phải clearly shown
- Net amount phải là số lớn nhất và prominent
- Rating & review tạo trust và motivation

---

### Screen 4: Withdrawal Screen

#### Thông tin màn hình:
- **Tên:** Màn hình rút tiền về tài khoản ngân hàng
- **Mục đích:** Cho phép Rescuer rút tiền từ ví SnakeAid về ngân hàng
- **Flow position:** Từ Revenue Dashboard → "Rút tiền"
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Rút Tiền"
   - Help icon (?)

2. **Available Balance Card:**
   - Large card with gradient background (orange)
   - Label: "Số dư khả dụng"
   - Amount: "7,300,000 VNĐ" (large, white, bold)
   - Subtext: "Đã trừ phí nền tảng" (small, semi-transparent)
   - Info note: "💡 Tiền sẽ về tài khoản trong 1-2 ngày làm việc"

3. **Withdrawal Amount Section:**
   - Title: "Số tiền muốn rút"
   - Large input field with VNĐ suffix
   - Placeholder: "Nhập số tiền"
   - Quick amount buttons:
     - "500K" "1M" "2M" "5M" "Tất cả"
   - Helper text: "Số tiền tối thiểu: 100,000 VNĐ"

4. **Bank Account Selection:**
   - Title: "Tài khoản nhận tiền"
   - Selected bank card:
     - Bank logo + Bank name: "Vietcombank"
     - Account number: "**** **** **** 1234"
     - Account holder: "NGUYEN VAN A"
     - Checkmark icon (if selected)
   - Button: "Thay đổi tài khoản" (outlined)
   - Or: "Thêm tài khoản mới" (if no bank linked)

5. **Fee Information Card:**
   - Light background info card
   - Title: "Phí giao dịch"
   - "Rút dưới 1 triệu: 5,000 VNĐ"
   - "Rút từ 1 triệu trở lên: Miễn phí"
   - "Thời gian xử lý: 1-2 ngày làm việc"

6. **Summary Section:**
   - "Tóm tắt giao dịch:"
   - Row: "Số tiền rút" | "1,000,000 VNĐ"
   - Row: "Phí giao dịch" | "Miễn phí" (green)
   - Divider
   - Row: "Bạn sẽ nhận" (bold) | "1,000,000 VNĐ" (large, orange)

7. **Terms & Conditions:**
   - Checkbox: "Tôi đồng ý với điều khoản rút tiền"
   - Link: "Xem điều khoản"

8. **Action Buttons:**
   - Primary button: "Xác Nhận Rút Tiền" (large, orange)
   - Secondary text link: "Hủy"

#### Stitch Prompt (English):

```
Mobile app withdrawal screen for snake rescuer. Clean financial transaction interface with orange theme.

Top header: Back arrow left, centered title "Rút Tiền", help icon (?) right.

Hero balance card with orange gradient background, rounded corners:
- Small white text "Số dư khả dụng"
- Extra large white bold text "7,300,000 VNĐ" (28pt)
- Small semi-transparent white text "Đã trừ phí nền tảng"
- Light bulb icon + white text "Tiền sẽ về tài khoản trong 1-2 ngày làm việc" in light yellow background strip at bottom of card

Section titled "Số tiền muốn rút":
- Large input field with border, "VNĐ" suffix on right
- Placeholder "Nhập số tiền"
- Below input, horizontal row of 5 chips:
  "500K" "1M" "2M" "5M" "Tất cả" (outlined, tappable)
- Small gray helper text "Số tiền tối thiểu: 100,000 VNĐ"

Section titled "Tài khoản nhận tiền":
White card showing selected bank:
- Left: Bank logo placeholder (square, 40x40px)
- Center: "Vietcombank" bold
         "**** **** **** 1234" gray
         "NGUYEN VAN A" smaller gray
- Right: Green checkmark icon
Below card: Blue outlined button "Thay đổi tài khoản"

Light blue info card (#E3F2FD) with info icon:
Title "Phí giao dịch"
- "Rút dưới 1 triệu: 5,000 VNĐ"
- "Rút từ 1 triệu trở lên: Miễn phí"
- "Thời gian xử lý: 1-2 ngày làm việc"

White card titled "Tóm tắt giao dịch":
- Row: "Số tiền rút" | "1,000,000 VNĐ" right
- Row: "Phí giao dịch" | "Miễn phí" green text right
- Thick divider line
- Row: "Bạn sẽ nhận" bold | "1,000,000 VNĐ" large orange text (22pt)

Checkbox with text "Tôi đồng ý với điều khoản rút tiền" and blue link "Xem điều khoản"

Bottom section:
- Large solid orange button "Xác Nhận Rút Tiền" (60px height)
- Small gray text link "Hủy" centered below

Design: Professional banking interface, clear amount display, fee transparency, bank account verification, summary before confirm.
```

#### Notes for Stitch:
- Available balance phải prominent
- Quick amount buttons giúp UX tốt hơn
- Fee information phải transparent
- Bank account verification visual
- Summary trước khi confirm rất quan trọng

---

### Screen 5: Bank Account Management

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý tài khoản ngân hàng
- **Mục đích:** Thêm, xóa, chỉnh sửa tài khoản ngân hàng nhận tiền
- **Flow position:** Từ Withdrawal Screen → "Thay đổi tài khoản"
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Tài Khoản Ngân Hàng"
   - Add button (+) - top-right

2. **Saved Bank Accounts List:**
   - Title: "Tài khoản đã lưu"
   - Bank account cards (scrollable):
     
     **Card 1 (Primary):**
     - Bank logo + Name: "Vietcombank"
     - Account number: "**** **** **** 1234"
     - Account holder: "NGUYEN VAN A"
     - Branch: "Chi nhánh Quận 1"
     - Badge: "MẶC ĐỊNH" (orange)
     - Three-dot menu: Edit / Delete / Set as default
     
     **Card 2:**
     - Similar structure
     - "Techcombank"
     - "**** **** **** 5678"
     - No default badge
     - Three-dot menu

3. **Add New Account Section:**
   - Large dashed border card
   - Plus icon (large, orange)
   - Text: "Thêm tài khoản mới"
   - Tap to open form

4. **Info Banner:**
   - Light blue background
   - "💡 Tài khoản ngân hàng phải trùng với tên đã đăng ký"
   - "Chỉ hỗ trợ các ngân hàng tại Việt Nam"

5. **Empty State (if no banks):**
   - Icon: Bank building
   - Text: "Chưa có tài khoản ngân hàng"
   - Subtext: "Thêm tài khoản để nhận tiền từ dịch vụ cứu hộ"
   - Button: "Thêm Tài Khoản Ngân Hàng"

#### Stitch Prompt (English):

```
Mobile app bank account management screen for snake rescuer. Financial account list interface.

Top header: Back arrow left, centered title "Tài Khoản Ngân Hàng", plus icon (+) right in orange.

Section titled "Tài khoản đã lưu" (2 saved accounts shown).

Bank card 1 (white background, rounded, shadow):
- Top left: Small bank logo placeholder (40x40px)
- Top right: Small orange badge "MẶC ĐỊNH"
- Bold text "Vietcombank" (18pt)
- Gray text "**** **** **** 1234"
- Gray text "NGUYEN VAN A"
- Small text "Chi nhánh Quận 1"
- Three-dot menu icon on far right

Bank card 2 (similar structure):
- Bank logo
- "Techcombank" bold
- "**** **** **** 5678"
- "NGUYEN VAN A"
- "Chi nhánh Tân Bình"
- Three-dot menu (no default badge)

Dashed border card (add new):
- Center: Large orange plus icon in circle
- Text "Thêm tài khoản mới" in orange below icon
- Tappable card

Light blue info banner (#E3F2FD) at bottom:
- Info icon left
- "💡 Tài khoản ngân hàng phải trùng với tên đã đăng ký"
- "Chỉ hỗ trợ các ngân hàng tại Việt Nam"

Design: Bank account management interface, default account indicator, easy add/edit/delete actions, verification requirements displayed.
```

#### Notes for Stitch:
- Primary/default account phải có badge rõ ràng
- Three-dot menu cho actions (edit, delete, set default)
- Security: mask account number
- Info banner về verification requirements

---

### Screen 6: Add Bank Account Form

#### Thông tin màn hình:
- **Tên:** Màn hình form thêm tài khoản ngân hàng mới
- **Mục đích:** Nhập thông tin tài khoản ngân hàng để nhận tiền
- **Flow position:** Từ Bank Account Management → "Thêm tài khoản"
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Thêm Tài Khoản"
   - Close button (X) - cancel

2. **Progress Indicator:**
   - Step 1/2: "Thông tin tài khoản"
   - Step 2/2: "Xác thực" (will come next)

3. **Form Fields:**
   
   **Bank Selection:**
   - Label: "Ngân hàng *"
   - Dropdown select field
   - Placeholder: "Chọn ngân hàng"
   - Shows list of Vietnamese banks with logos
   
   **Account Number:**
   - Label: "Số tài khoản *"
   - Input field (numeric)
   - Placeholder: "Nhập số tài khoản"
   - Helper text: "Nhập đầy đủ số tài khoản không có khoảng trắng"
   
   **Account Holder Name:**
   - Label: "Tên chủ tài khoản *"
   - Input field (read-only or auto-filled from profile)
   - Pre-filled: "NGUYEN VAN A"
   - Helper text: "Phải trùng với tên đăng ký"
   
   **Branch (Optional):**
   - Label: "Chi nhánh"
   - Input field
   - Placeholder: "VD: Chi nhánh Quận 1"

4. **Verification Note Card:**
   - Light yellow background (#FFFBF0)
   - Warning icon
   - Text: "Lưu ý:"
   - "Tài khoản sẽ được xác minh bằng giao dịch thử 10,000 VNĐ"
   - "Số tiền sẽ được hoàn lại ngay sau khi xác minh"

5. **Set as Default Checkbox:**
   - Checkbox: "Đặt làm tài khoản mặc định"

6. **Action Buttons:**
   - Primary button: "Tiếp Theo" (large, orange)
   - Secondary button: "Hủy" (outlined, gray)

7. **Help Section:**
   - Expandable accordion: "Cần trợ giúp?"
   - Content:
     - "Làm sao để biết số tài khoản?"
     - "Tại sao cần xác minh?"
     - Link: "Liên hệ hỗ trợ"

#### Stitch Prompt (English):

```
Mobile app add bank account form screen for snake rescuer. Clean form input interface with validation.

Top header: Back arrow left, centered title "Thêm Tài Khoản", X close icon right.

Progress indicator bar: Two steps shown
- Step 1 (orange filled circle, bold): "Thông tin tài khoản"
- Step 2 (gray outline circle): "Xác thực"
Connected by horizontal line.

Form section with white background:

Field 1:
- Label "Ngân hàng *" with asterisk in red
- Dropdown select field with down arrow
- Placeholder "Chọn ngân hàng"
- Light gray border, rounded corners

Field 2:
- Label "Số tài khoản *" with asterisk
- Input field with numeric keyboard indicator
- Placeholder "Nhập số tài khoản"
- Small gray helper text below "Nhập đầy đủ số tài khoản không có khoảng trắng"

Field 3:
- Label "Tên chủ tài khoản *" with asterisk
- Input field (light gray background indicating read-only)
- Pre-filled value "NGUYEN VAN A" in uppercase
- Lock icon on right
- Small gray helper text "Phải trùng với tên đăng ký"

Field 4:
- Label "Chi nhánh" (no asterisk)
- Input field
- Placeholder "VD: Chi nhánh Quận 1"

Light yellow info card (#FFFBF0) with amber border:
- Warning icon left
- Bold "Lưu ý:"
- "Tài khoản sẽ được xác minh bằng giao dịch thử 10,000 VNĐ"
- "Số tiền sẽ được hoàn lại ngay sau khi xác minh"

Checkbox with text "Đặt làm tài khoản mặc định"

Two bottom buttons:
- Large solid orange button "Tiếp Theo" (60px height)
- Medium outlined gray button "Hủy"

Expandable section at bottom:
- Gray text "Cần trợ giúp?" with down arrow
- (Collapsed state shown)

Design: Professional banking form, clear required field indicators, validation helpers, verification process explanation, default account option.
```

#### Notes for Stitch:
- Required fields phải có asterisk (*)
- Account holder name should match registered name
- Verification process phải được explain rõ ràng
- Form validation real-time nếu có thể
- Helper text cho mỗi field

---

## 📊 SCREEN FLOW SUMMARY

### Complete Revenue Management Flow for Rescuer:

```
Screen 1: Revenue Dashboard
    ↓ (Tap "Xem tất cả")
Screen 2: Transaction History
    ↓ (Tap on a transaction)
Screen 3: Transaction Detail
    ↓ (Back to dashboard or history)
    
Dashboard → "Rút tiền"
    ↓
Screen 4: Withdrawal Screen
    ↓ (If no bank account → "Thêm tài khoản")
    ↓ (If have account → "Thay đổi tài khoản")
Screen 5: Bank Account Management
    ↓ (Tap "+" or "Thêm tài khoản mới")
Screen 6: Add Bank Account Form
    ↓ (Submit → Verification → Back to Withdrawal)
```

### Timing Breakdown:

| Screen | Typical Time Spent | Priority |
|--------|-------------------|----------|
| **Screen 1: Revenue Dashboard** | 30-60 seconds (overview) | ⭐⭐⭐ |
| **Screen 2: Transaction History** | 1-2 minutes (browse) | ⭐⭐⭐ |
| **Screen 3: Transaction Detail** | 1-2 minutes (review) | ⭐⭐ |
| **Screen 4: Withdrawal** | 2-3 minutes (input amount) | ⭐⭐⭐ |
| **Screen 5: Bank Management** | 1-2 minutes (select bank) | ⭐⭐ |
| **Screen 6: Add Bank Form** | 3-5 minutes (input details) | ⭐⭐ |

---

## 🔗 Integration Points

### Backend APIs Required:

1. **Revenue & Earnings:**
   - GET `/api/rescuer/earnings/summary` - Get overview stats
   - GET `/api/rescuer/earnings/chart?period=7days` - Get chart data
   - GET `/api/rescuer/transactions?status=all` - Get transaction list
   - GET `/api/rescuer/transactions/{id}` - Get transaction detail

2. **Withdrawal:**
   - POST `/api/rescuer/withdrawal/request` - Request withdrawal
   - GET `/api/rescuer/withdrawal/fee?amount=1000000` - Calculate fee
   - GET `/api/rescuer/withdrawal/history` - Get withdrawal history

3. **Bank Account Management:**
   - GET `/api/rescuer/bank-accounts` - List saved accounts
   - POST `/api/rescuer/bank-accounts` - Add new account
   - PUT `/api/rescuer/bank-accounts/{id}` - Update account
   - DELETE `/api/rescuer/bank-accounts/{id}` - Remove account
   - POST `/api/rescuer/bank-accounts/{id}/verify` - Verify account
   - PUT `/api/rescuer/bank-accounts/{id}/set-default` - Set as default

4. **Payment Processing:**
   - GET `/api/rescuer/wallet/balance` - Get available balance
   - GET `/api/banks/list` - Get supported banks with logos

5. **Documents & Receipts:**
   - GET `/api/rescuer/transactions/{id}/receipt.pdf` - Export receipt
   - GET `/api/rescuer/transactions/{id}/documents` - Get attached files

---

## 🎯 Key Design Principles for Rescuer Revenue Management

1. **Transparency:**
   - Always show platform fee (10%)
   - Clear breakdown of earnings
   - Fee structure visible before withdrawal

2. **Trust & Security:**
   - Bank account verification required
   - Masked account numbers
   - Transaction IDs for tracking

3. **Financial Clarity:**
   - Large, bold currency displays
   - Color-coded statuses (green = paid, amber = pending)
   - Net earnings after fees prominent

4. **Easy Access:**
   - Quick stats on dashboard
   - Recent transactions at a glance
   - One-tap withdrawal

5. **Professional Documentation:**
   - Export receipts
   - Transaction history
   - Payment status tracking

---

## 📝 Notes for Development Team

### Critical Features:

1. **Real-time Balance Updates:**
   - Balance updates immediately after mission completion
   - Push notifications for payments received

2. **Payment Status Tracking:**
   - "Chờ thanh toán" → Patient hasn't paid yet
   - "Đang xử lý" → Payment in progress
   - "Đã thanh toán" → Money in wallet
   - "Đã rút" → Transferred to bank

3. **Fee Calculation:**
   - Platform fee: 10% of gross amount
   - Withdrawal fee: 5,000 VNĐ if < 1M, Free if ≥ 1M
   - Expert consultation fee: 5% if expert was involved

4. **Bank Verification:**
   - Send 10,000 VNĐ test transaction
   - User enters verification code
   - Refund immediately after verification

5. **Security:**
   - Require PIN/biometric for withdrawal
   - Mask bank account numbers
   - Secure API calls with tokens

---

## ✅ Completion Checklist

- [x] Analyzed Major Features Summary (FE-24 to FE-27)
- [x] Reviewed Main Flow (Flow 2.4 - Thanh toán)
- [x] Created 6 screens for Revenue Management
- [x] Written detailed Stitch prompts for each screen
- [x] Documented flow integration points
- [x] Specified API requirements
- [x] Added design principles and development notes
- [x] Included fee structure and payment breakdown

---

**END OF DOCUMENT**

*Tài liệu này cover đầy đủ UI Design cho Rescuer role trong Revenue Management. Rescuer có thể theo dõi doanh thu, xem lịch sử giao dịch, rút tiền và quản lý tài khoản ngân hàng.*
