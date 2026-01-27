# PROFILE & SETTINGS SCREENS - UI DESIGN (RESCUER ROLE) - PART 1

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **RESCUER** (Đội cứu hộ rắn)
- **Flow:** Profile & Settings Management
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 4 screens (Part 1 of 2)
- **Ngày tạo:** December 10, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Profile-Settings-Screens-Part1.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **RESCUER role**.

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange `#FF8A00` (Action, rescue, energy - consistent with all Rescuer flows)
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Info:** Blue `#007BFF`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Danger:** Red `#DC3545`
- **Rating Star:** Gold `#FFD700`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)

### Component Style:
- **Cards:** Rounded corners (12px), subtle shadow
- **Buttons:** Rounded (8px), clear hierarchy (Primary/Secondary)
- **Input Fields:** Outlined style, rounded (8px)
- **Avatar:** Circular with border
- **Stats Cards:** Bold numbers, icon badges

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - đội cứu hộ quản lý profile và hoạt động

---

### Screen 1: Rescuer Profile Overview Screen

#### Thông tin màn hình:
- **Tên:** Màn hình tổng quan profile Rescuer
- **Mục đích:** Hiển thị thông tin cá nhân, stats, rating, và menu quản lý
- **Flow position:** Entry point từ bottom navigation hoặc homepage
- **Priority:** ⭐⭐⭐ (Cao)
- **Related Features:** FE-25, FE-26, FE-28

#### Key Components:
1. **Header:**
   - Title: "Hồ Sơ Cứu Hộ"
   - Settings icon (top-right) → Navigate to Settings Screen
   - Status toggle: "Online/Offline" switch (prominent)

2. **Profile Card (top section):**
   - Large circular avatar (100px) - centered
   - Full name: "Trần Văn Cường" (bold, 20pt)
   - Badge: "Cứu Hộ Viên Chuyên Nghiệp" (green badge)
   - Phone number: "+84 987 654 321" (gray, 16pt)
   - Member since: "Tham gia: 01/2024" (gray, 14pt)
   - Edit profile button (outlined)

3. **Rating & Stats Row:**
   - **Rating:** ⭐ 4.8/5.0 (large, gold stars)
   - **Total Reviews:** "125 đánh giá"
   - **Response Rate:** "98%" (green badge)
   - **Avg Response Time:** "< 3 phút"

4. **Performance Stats (3 columns):**
   - Column 1: "87 ca hoàn thành" (bold number, subtitle)
   - Column 2: "12 ca tháng này" (bold number, subtitle)
   - Column 3: "95% thành công" (bold number with green badge)

5. **Revenue Summary Card:**
   - This month earnings: "4,250,000 VNĐ" (large, bold, green)
   - Total lifetime: "52,800,000 VNĐ" (gray)
   - Button: "Xem Chi Tiết" → Navigate to Revenue Screen

6. **Menu Items (list):**
   Each item has icon left, title, subtitle, chevron right:
   - **Lịch Sử Cứu Hộ** - "87 nhiệm vụ đã hoàn thành"
   - **Quản Lý Thu Nhập** - "Xem báo cáo tài chính"
   - **Đánh Giá & Phản Hồi** - "125 đánh giá từ khách hàng"
   - **Trang Thiết Bị** - "Danh sách dụng cụ cứu hộ"
   - **Chứng Chỉ & Giấy Tờ** - "CMND, Giấy phép, Chứng chỉ"
   - **Khu Vực Hoạt Động** - "Quận 1, 3, 5, 10"

7. **Action Section (bottom):**
   - Secondary button: "Chế Độ Nghỉ" (outlined amber)
   - Text: "Tạm ngừng nhận yêu cầu mới"

#### Stitch Prompt (English):

```
Mobile app rescuer profile overview screen for snake rescue team in "SnakeAid". Professional rescuer profile interface with orange (#FF8A00) primary theme.

Top navigation bar: Centered title "Hồ Sơ Cứu Hộ" bold dark gray. Settings gear icon top-right. Top-left prominent toggle switch showing "Online" in green (when on) or "Offline" in gray (when off).

Profile section white card centered layout: Large circular avatar (100px) with orange border. Below avatar, bold dark gray name "Trần Văn Cường" (20pt). Small orange badge "Cứu Hộ Viên Chuyên Nghiệp" with shield icon. Gray phone "+84 987 654 321" (16pt). Small gray text "Tham gia: 01/2024". Outlined orange button "Chỉnh Sửa Hồ Sơ".

Rating card white background: Centered large gold star icons (5 stars, 4.8 filled) "4.8/5.0" bold. Below, horizontal 3 columns:
- "125 đánh giá" small gray
- Green badge "98%" with "Tỷ lệ phản hồi"
- "< 3 phút" with "Thời gian phản hồi"

Stats section white card, 3 equal columns with vertical dividers:
- Left: Bold dark gray "87" large, "Ca hoàn thành" gray small
- Center: Bold dark gray "12" large, "Ca tháng này" gray small  
- Right: Bold green "95%" large, small green badge "Thành công" below

Revenue summary white card with green left border (4px): 
- Top: "Thu nhập tháng này" small gray label
- Large bold green "4,250,000 VNĐ" (24pt)
- Below: Small gray "Tổng tích lũy: 52,800,000 VNĐ"
- Right aligned small blue text link "Xem Chi Tiết"

Menu section: Vertically stacked white cards 8px spacing. Each card:
- Left: Orange icon (24px)
- Center: Bold dark gray title (16pt), small gray subtitle (14pt) below
- Right: Gray chevron arrow

Menu items:
1. Clipboard check icon, "Lịch Sử Cứu Hộ", "87 nhiệm vụ đã hoàn thành"
2. Wallet icon, "Quản Lý Thu Nhập", "Xem báo cáo tài chính"
3. Star icon, "Đánh Giá & Phản Hồi", "125 đánh giá từ khách hàng"
4. Toolbox icon, "Trang Thiết Bị", "Danh sách dụng cụ cứu hộ"
5. Certificate icon, "Chứng Chỉ & Giấy Tờ", "CMND, Giấy phép, Chứng chỉ"
6. Map marker icon, "Khu Vực Hoạt Động", "Quận 1, 3, 5, 10"

Bottom section white card: Large outlined orange button "Chế Độ Nghỉ" full width. Below, centered small gray text "Tạm ngừng nhận yêu cầu mới".

Design: Professional rescuer interface, performance metrics prominent, revenue tracking, clear status control.
```

#### Notes for Stitch:
- Online/Offline toggle phải VERY prominent vì control availability
- Rating và stats phải stand out để show credibility
- Revenue summary phải easy to access

---

### Screen 2: Edit Rescuer Profile Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chỉnh sửa profile Rescuer
- **Mục đích:** Cập nhật thông tin cá nhân, chứng chỉ, và khu vực hoạt động
- **Flow position:** Từ Profile Overview → "Chỉnh Sửa Hồ Sơ"
- **Priority:** ⭐⭐⭐
- **Related Features:** FE-25

#### Key Components:
1. **Header:**
   - Back button (left)
   - Title: "Chỉnh Sửa Hồ Sơ"
   - Save button (right, green text)

2. **Avatar Section:**
   - Large circular avatar (120px) - centered
   - Camera icon overlay
   - Text: "Chạm để thay đổi ảnh"
   - Badge display: Professional/Verified status

3. **Personal Info Section:**
   - **Họ và Tên** - Text input, required
   - **Số Điện Thoại** - Phone input, disabled (verified)
   - **Email** - Email input, optional
   - **Ngày Sinh** - Date picker
   - **Giới Tính** - Radio buttons
   - **Địa Chỉ** - Text area
   - **CMND/CCCD** - Number input + Upload photo

4. **Professional Info Section:**
   - **Kinh Nghiệm** - Dropdown (< 1 năm, 1-3 năm, 3-5 năm, > 5 năm)
   - **Chuyên Môn** - Multi-select chips:
     - "Rắn độc"
     - "Rắn cỡ lớn"
     - "Rắn nước"
     - "Tất cả các loài"
   - **Mô Tả Bản Thân** - Text area (max 200 chars)
     - Placeholder: "Giới thiệu ngắn về kinh nghiệm và kỹ năng..."

5. **Service Area Section:**
   - **Tỉnh/Thành Phố** - Dropdown
   - **Quận/Huyện Hoạt Động** - Multi-select checkboxes
   - **Bán Kính Hoạt Động** - Slider (5km - 50km)
   - Map preview showing coverage area

6. **Availability Section:**
   - **Lịch Làm Việc** - Weekly schedule grid
   - Days: Thứ 2 - Chủ Nhật
   - Time slots: Morning/Afternoon/Evening/Night
   - Toggle switches for each slot

7. **Action Buttons (sticky bottom):**
   - Primary button: "Lưu Thay Đổi" (green)
   - Text link: "Hủy"

#### Stitch Prompt (English):

```
Mobile app edit rescuer profile form in "SnakeAid". Professional rescuer profile editing with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Chỉnh Sửa Hồ Sơ" centered bold, orange "Lưu" text button right.

Avatar section centered: Large circular avatar (120px) orange border. Camera icon overlay bottom-right. Small gray text "Chạm để thay đổi ảnh". Small orange verified badge top-right of avatar.

Scrollable form with section headers bold dark gray (18pt):

SECTION: "Thông Tin Cá Nhân"
- Field "Họ và Tên" with red asterisk, text input
- Field "Số Điện Thoại" disabled gray background, green checkmark right
- Field "Email", optional, text input
- Field "Ngày Sinh", date picker with calendar icon
- Field "Giới Tính", three radio buttons horizontal
- Field "Địa Chỉ", text area 2 lines
- Field "CMND/CCCD", number input with "Upload ảnh" button right

SECTION: "Thông Tin Chuyên Môn"
- Field "Kinh Nghiệm", dropdown with "3-5 năm" selected
- Field "Chuyên Môn", multi-select showing 4 orange chips: "Rắn độc", "Rắn cỡ lớn", "Rắn nước", "Tất cả các loài"
- Field "Mô Tả Bản Thân", text area 3 lines, character counter "0/200" gray right

SECTION: "Khu Vực Hoạt Động"
- Field "Tỉnh/Thành Phố", dropdown "TP. Hồ Chí Minh"
- Field "Quận/Huyện", checkbox grid showing checked: "Quận 1", "Quận 3", "Quận 5", "Quận 10"
- Field "Bán Kính Hoạt Động", slider 5-50km, current "20km" shown, orange fill
- Small map preview showing orange circle coverage area

SECTION: "Lịch Làm Việc"
Weekly grid: 7 columns (Mon-Sun), 4 rows (Morning/Afternoon/Evening/Night). Each cell has small toggle switch, some green (on), some gray (off).

Bottom sticky white background, shadow: Large solid orange button "Lưu Thay Đổi" full width. Centered gray text link "Hủy" below.

Design: Professional rescuer profile form, comprehensive information, service area mapping, flexible scheduling.
```

#### Notes for Stitch:
- Service area map phải show real coverage
- Weekly schedule grid phải easy to toggle
- Specialty tags phải multi-select
- CMND upload important for verification

---

### Screen 3: Rescue History Screen

#### Thông tin màn hình:
- **Tên:** Màn hình lịch sử cứu hộ
- **Mục đích:** Hiển thị tất cả nhiệm vụ cứu hộ đã thực hiện
- **Flow position:** Từ Profile Overview → "Lịch Sử Cứu Hộ"
- **Priority:** ⭐⭐⭐ (Cao)
- **Related Features:** FE-15, FE-25

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Lịch Sử Cứu Hộ"
   - Filter icon (right) - Filter by status/date/type

2. **Summary Card (top):**
   - Total missions: "87 nhiệm vụ"
   - Success rate: "95% thành công"
   - Total earnings: "52,800,000 VNĐ"

3. **Filter Tabs:**
   - "Tất cả" (default)
   - "Hoàn thành"
   - "Đã hủy"
   - "Tháng này"

4. **Mission Cards (scrollable list):**
   Each card shows:
   - **Mission ID:** "#RSC-2025-1234"
   - **Date & Time:** "15 Thg 12, 2025 - 14:30"
   - **Snake Type:** "Rắn Hổ Mang" (with photo thumbnail)
   - **Status Badge:** "Hoàn thành" (green) / "Đã hủy" (red)
   - **Location:** "123 Nguyễn Huệ, Q.1"
   - **Distance:** "5.2 km"
   - **Duration:** "45 phút"
   - **Earnings:** "200,000 VNĐ" (bold, right aligned)
   - **Customer Rating:** ⭐⭐⭐⭐⭐ (5.0)
   - **View Details** button

5. **Mission Detail includes:**
   - Customer info (name, phone)
   - Photos: Snake before/after capture
   - Timeline: Request → Accept → En route → Arrived → Completed
   - GPS route map
   - Payment breakdown
   - Customer feedback
   - Expert consultation (if any)

6. **Stats at Bottom:**
   - Average rating received
   - Most rescued snake type
   - Busiest time/area

#### Stitch Prompt (English):

```
Mobile app rescue mission history screen for rescuer in "SnakeAid". Professional mission tracking interface with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Lịch Sử Cứu Hộ" centered bold, filter icon right.

Summary card white rounded corners: Three columns equal width, vertical dividers:
- "87 nhiệm vụ" bold dark gray large, "Tổng số" small gray
- "95%" bold green large, "Thành công" small gray
- "52,8M VNĐ" bold green large, "Tổng thu" small gray

Filter tabs below: Horizontal scrollable tabs, "Tất cả" orange underline (selected), "Hoàn thành", "Đã hủy", "Tháng này" gray text.

Scrollable mission cards: Each white card shadow, rounded 12px:

CARD LAYOUT:
Top row: Small gray "#RSC-2025-1234" left, green badge "Hoàn thành" right.

Second row: Bold dark gray "15 Thg 12, 2025 - 14:30" with clock icon left.

Third row: Small snake photo thumbnail (60px) rounded left. Right of photo vertical layout:
- Bold "Rắn Hổ Mang" dark gray
- Small gray "123 Nguyễn Huệ, Q.1" with pin icon
- Small gray "5.2 km • 45 phút"

Fourth row: Left shows 5 gold stars "5.0" rating. Right shows bold green "200,000 VNĐ".

Bottom row: Small blue text link "Xem Chi Tiết" right aligned.

Card spacing 12px vertical.

Bottom stats section white card: Three horizontal items with icons:
- Star icon, "Đánh giá TB: 4.8/5.0"
- Snake icon, "Loài hay gặp: Rắn Hổ Mang"  
- Clock icon, "Giờ cao điểm: 14h-18h"

Design: Mission history tracking, earnings visible, customer feedback, detailed mission records.
```

#### Notes for Stitch:
- Snake photo thumbnail helps recall missions
- Earnings prominent for quick reference
- Status badges clear and colorful
- Timeline in detail view shows professionalism

---

### Screen 4: Revenue Management Screen

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý thu nhập
- **Mục đích:** Theo dõi thu nhập, thanh toán, và báo cáo tài chính
- **Flow position:** Từ Profile Overview → "Quản Lý Thu Nhập"
- **Priority:** ⭐⭐⭐ (Cao)
- **Related Features:** FE-26, FE-27

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Quản Lý Thu Nhập"
   - Download report icon (right)

2. **Balance Card (prominent top):**
   - **Available Balance:** "3,200,000 VNĐ" (very large, bold, green)
   - **Pending:** "850,000 VNĐ" (amber)
   - **Total Earned (lifetime):** "52,800,000 VNĐ" (gray)
   - Primary button: "Rút Tiền" (green, prominent)

3. **Time Filter Tabs:**
   - "Tuần này"
   - "Tháng này" (selected)
   - "Tháng trước"
   - "Năm nay"
   - Custom date range picker

4. **Revenue Chart:**
   - Bar chart showing daily/weekly earnings
   - X-axis: Days/Weeks
   - Y-axis: Amount in VNĐ
   - Color: Green bars
   - Trend line overlay

5. **Breakdown Section:**
   - **Total Income:** "4,250,000 VNĐ" (100%)
   - **Platform Fee (10%):** "-425,000 VNĐ" (red)
   - **Expert Consultation (if shared):** "-212,500 VNĐ" (amber)
   - **Net Income:** "3,612,500 VNĐ" (bold, green)

6. **Transaction List:**
   Each transaction card:
   - **Date:** "15 Thg 12, 2025"
   - **Type:** "Cứu hộ rắn" / "Rút tiền" / "Hoàn tiền"
   - **Mission ID:** "#RSC-2025-1234" (if applicable)
   - **Amount:** "+200,000 VNĐ" (green) / "-50,000 VNĐ" (red)
   - **Status:** "Đã thanh toán" (green) / "Đang xử lý" (amber)
   - **View Receipt** link

7. **Withdrawal History:**
   - Date, Amount, Bank account, Status
   - Processing time: "1-3 ngày làm việc"

8. **Payment Method Section:**
   - Bank account details
   - "Thêm/Sửa Tài Khoản" button
   - Verified badge if connected

#### Stitch Prompt (English):

```
Mobile app revenue management screen for rescuer in "SnakeAid". Financial tracking interface with orange (#FF8A00) primary theme.

Top navigation: Back arrow left, "Quản Lý Thu Nhập" centered bold, download icon right.

Balance card prominent: White background, orange top border 4px, rounded, shadow:
- Small gray label "Số dư khả dụng"
- Very large bold green "3,200,000 VNĐ" (28pt)
- Below, two columns: "Chờ xử lý" amber "850,000 VNĐ" left, "Tổng tích lũy" gray "52,8M VNĐ" right
- Large solid green button "Rút Tiền" full width at bottom

Time filter tabs: Horizontal "Tuần này", "Tháng này" (orange underline selected), "Tháng trước", "Năm nay", calendar icon.

Chart section white card: Bar chart orange bars showing daily earnings, highest bar labeled. Gray grid lines. X-axis dates, Y-axis "VNĐ".

Breakdown section white card, each row:
- "Tổng thu nhập" left, "4,250,000 VNĐ" bold right, small "100%" gray
- "Phí nền tảng (10%)" left, red "-425,000 VNĐ" right
- "Chia sẻ Expert" left, amber "-212,500 VNĐ" right
- Divider line
- "Thu nhập ròng" bold left, large bold green "3,612,500 VNĐ" right

Transaction list: Scrollable cards, each white rounded shadow:

CARD LAYOUT:
Left vertical: Bold dark gray date "15 Thg 12", small gray time "14:30".
Center vertical: Bold "Cứu hộ rắn", small gray "#RSC-2025-1234", small green badge "Đã thanh toán".
Right vertical: Bold green "+200,000 VNĐ" large, small blue link "Xem HĐ".

Withdrawal history section white card: Table rows showing date, amount, bank name, green "Hoàn tất" status.

Payment method card: Bank icon left, "Vietcombank ****3456" center, green verified checkmark right. Small blue link "Thay đổi".

Design: Financial management, clear balance display, detailed breakdown, transaction tracking, easy withdrawal.
```

#### Notes for Stitch:
- Available balance phải VERY prominent
- Chart helps visualize earnings trend
- Fee breakdown transparent
- Withdrawal process clear and fast

---

## 🔗 NAVIGATION FLOW (Part 1)

```
Rescuer Profile Overview (Screen 1)
    │
    ├─→ Edit Profile (Screen 2)
    │   └─→ Save → Back to Overview
    │
    ├─→ Rescue History (Screen 3)
    │   └─→ Mission Detail → View timeline, photos, payment
    │
    └─→ Revenue Management (Screen 4)
        ├─→ Withdraw Money → Bank details → Confirm
        ├─→ View Receipt → Download PDF
        └─→ Edit Payment Method → Update bank info
```

---

## 📋 FEATURE MAPPING (Part 1)

| Screen | Related Major Features | Priority |
|--------|------------------------|----------|
| Profile Overview | FE-25, FE-26, FE-28 | ⭐⭐⭐ |
| Edit Profile | FE-25 (Task management) | ⭐⭐⭐ |
| Rescue History | FE-15, FE-25 (Record activities) | ⭐⭐⭐ |
| Revenue Management | FE-26, FE-27 (Income tracking) | ⭐⭐⭐ |

---

## ✅ DESIGN CHECKLIST (Part 1)

- [ ] Online/Offline toggle prominent and functional
- [ ] Rating and stats clearly displayed
- [ ] Revenue information easy to access
- [ ] Service area map shows coverage accurately
- [ ] Weekly schedule grid easy to toggle
- [ ] Mission history shows key details
- [ ] Earnings visible on each mission card
- [ ] Balance and withdrawal process clear
- [ ] Transaction list chronological
- [ ] Chart visualizes earnings trend

---

## 🔗 RELATED DOCUMENTATION

- **Main Flow:** `/01-Requirements/Main-Flow/Main-Flow.md`
- **Major Features:** `/01-Requirements/Major-Features/Major-Features-Summary.md`
- **Part 2:** `/02-UI-Design/Rescuer/Rescuer-Profile-Settings-Screens-Part2.md`

---

**Last Updated:** December 10, 2025  
**Status:** ✅ Complete  
**Total Screens in Part 1:** 4 screens  
**Continue to Part 2 for:** Ratings & Reviews, Equipment, Settings
