# EXPERT DASHBOARD SCREENS - SNAKEAID PLATFORM

## Document Information
- **Module:** Snake Expert
- **Feature Category:** Dashboard & Overview
- **Total Screens:** 4 screens
- **Related Flows:** Entry point for all Expert features
- **Color Scheme:** Purple Primary `#6B46C1`, Purple Light `#9F7AEA`, Purple Dark `#553C9A`

---

## Flow Context

### User Role: Snake Expert
**Primary Goals:**
- Monitor incoming consultation requests (Patient scheduled + Rescuer urgent)
- Track earnings and consultation statistics
- Manage availability status (online/offline)
- Quick access to urgent requests from Rescuers

**Entry Points:**
- App launch → Expert Dashboard (Screen 1)
- Push notification → Navigate to Notification Center (Screen 2)
- Scheduled consultation reminder → Navigate to Schedule Calendar (Screen 3)

**Key Features (Reference: Major-Features-Summary.md):**
- FE-01 to FE-03: Verify identification data
- FE-04 to FE-06: Support AI snake identification
- FE-10 to FE-12: Remote consultation
- FE-13 to FE-16: Consultation revenue management

---

## Design System

### Color Palette
```
Primary Purple:     #6B46C1  (Main CTAs, branding)
Purple Light:       #9F7AEA  (Hover states, secondary elements)
Purple Dark:        #553C9A  (Headers, important text)
Purple Subtle:      #F3EBFF  (Backgrounds, light sections)

Emergency Red:      #DC3545  (Urgent requests from Rescuers)
Warning Amber:      #FFC107  (Pending verifications)
Success Green:      #28A745  (Completed consultations)
Neutral Gray:       #6C757D  (Secondary text)
White:              #FFFFFF
```

### Typography
```
Logo/Branding:      32-36pt, Bold, Purple Primary
Screen Titles:      24pt, Semi-bold, Purple Dark
Card Headers:       20pt, Semi-bold
Body Text:          16-18pt, Regular
Captions:           14pt, Regular, Neutral Gray
Stat Numbers:       28-32pt, Bold
```

### Components
- **Cards:** 16px padding, 12px border radius, subtle shadow
- **Buttons:** 8px border radius, 44x44px minimum touch target
- **Icons:** 24x24px standard, 32x32px for feature buttons
- **Badges:** 6px border radius, 8px padding, bold text
- **Toggle Switch:** 24px height, smooth animation

---

## Screen Designs

### Screen 1: Expert Dashboard (Main Overview)

**Screen Purpose:**  
Central hub displaying earnings overview, availability toggle, urgent requests from Rescuers, upcoming scheduled consultations, and quick access to key features.

**Navigation:**
- Entry: App launch (default screen)
- Exit to: Screen 2 (Notification Center), Screen 3 (Schedule Calendar), Screen 4 (Earnings Detail), Consultation Flow screens, Profile Settings

**Key Components:**

1. **Header Section** (Fixed top):
   - Logo: "SnakeAid Expert" with purple snake icon (32pt, Bold, Purple Primary)
   - Profile avatar (right corner, 40x40px circle) → Navigate to Profile
   - Notification bell icon with badge count → Navigate to Screen 2

2. **Availability Toggle Card** (Below header):
   - Card background: White with purple accent border
   - Left: Status indicator dot (green = online, gray = offline)
   - Center: "Trạng Thái" label + Current status text (16pt, Semi-bold)
     - Online: "Sẵn Sàng Nhận Tư Vấn" (Purple Primary)
     - Offline: "Đang Ngoại Tuyến" (Neutral Gray)
   - Right: Large toggle switch (purple when ON, gray when OFF)
   - Note below: "Bạn sẽ nhận thông báo khi có yêu cầu khẩn cấp từ Rescuer" (14pt, Neutral Gray)

3. **Earnings Summary Card** (Hero section):
   - Card background: Purple gradient (Purple Primary → Purple Light)
   - Card height: 140px, rounded corners 12px
   - Top label: "Thu Nhập Tháng Này" (18pt, White, 70% opacity)
   - Large number: "12.5M VNĐ" (36pt, Bold, White)
   - Bottom row (3 columns, white text with icons):
     - "18 Tư Vấn" (consultation icon)
     - "4.8 ⭐" (star rating icon)
     - "+15% ↑" (growth percentage with up arrow, Success Green)

4. **Urgent Requests Banner** (Conditional display):
   - Only show when there are urgent requests from Rescuers
   - Background: Emergency Red with pulse animation
   - Height: 80px, rounded corners 12px
   - Left: Fire icon (32x32px, White)
   - Center text:
     - "🚨 Yêu Cầu Khẩn Cấp!" (20pt, Bold, White)
     - "Rescuer cần hỗ trợ nhận diện rắn ngay" (14pt, White)
   - Right: "Xem Ngay" button (White background, Red text, 100px width)
   - On tap → Navigate to Urgent Request Detail screen

5. **Quick Stats Section** (Grid 2x2):
   - Label: "Thống Kê Nhanh" (18pt, Semi-bold, Purple Dark)
   - 4 stat cards (equal size, white background, purple accent):
     - **Đang Chờ Xác Nhận**: Number "5" (28pt, Bold, Warning Amber) + icon
     - **Đã Hoàn Thành Hôm Nay**: Number "3" (28pt, Bold, Success Green) + icon
     - **Lịch Hẹn Tuần Này**: Number "12" (28pt, Bold, Purple Primary) + icon
     - **Tỷ Lệ Phản Hồi**: Percentage "95%" (28pt, Bold, Purple Primary) + icon

6. **Upcoming Consultations List** (Scrollable):
   - Section header: "Lịch Tư Vấn Sắp Tới" (18pt, Semi-bold, Purple Dark)
   - "Xem Tất Cả" link (right side) → Navigate to Screen 3
   - Show 3 upcoming consultation cards:
     - Card height: 100px, white background, border-left: 4px purple
     - Row 1: Patient name "Nguyễn Văn A" (16pt, Semi-bold) + Type badge ("Tư Vấn Đặt Lịch" - purple background, white text)
     - Row 2: Date/time "11/12/2025 - 14:00" (14pt, Neutral Gray) + calendar icon
     - Row 3: Snake type "Rắn Hổ Mang Chúa (Dự Đoán)" (14pt, Neutral Gray) + snake icon
     - Right side: "Chi Tiết" button (outlined purple, 80px width)

7. **Bottom Navigation Bar** (Fixed bottom):
   - 4 tabs with icons + labels:
     - "Trang Chủ" (Home, purple when active)
     - "Tư Vấn" (Consultation, gray when inactive)
     - "Thu Nhập" (Revenue, gray when inactive) → Navigate to Screen 4
     - "Hồ Sơ" (Profile, gray when inactive)

**Interactions:**
- Tap Availability Toggle → Change online/offline status with confirmation toast
- Tap Urgent Request Banner → Navigate to urgent Rescuer request detail
- Tap Stat Card → Navigate to filtered view (e.g., "Đang Chờ Xác Nhận" shows pending verifications)
- Tap Consultation Card → Navigate to consultation detail/preparation screen
- Pull to refresh → Reload dashboard data

---

**STITCH PROMPT (English):**

```
Design a professional Expert Dashboard screen for a snake rescue platform mobile app.

LAYOUT:
- Top header: "SnakeAid Expert" logo (purple snake icon, 32pt bold purple #6B46C1), profile avatar (40x40px circle, top-right), notification bell icon with badge number "3" (red dot)
- Below header: Availability Toggle Card (white background, purple border accent):
  * Left: Status dot (green when online)
  * Center: "Trạng Thái" label, current status "Sẵn Sàng Nhận Tư Vấn" (16pt semi-bold purple)
  * Right: Large purple toggle switch (ON state)
  * Bottom note: "Bạn sẽ nhận thông báo khi có yêu cầu khẩn cấp từ Rescuer" (14pt gray)

HERO EARNINGS CARD (purple gradient #6B46C1 to #9F7AEA, 140px height, rounded 12px):
- Top: "Thu Nhập Tháng Này" (18pt white 70% opacity)
- Center: "12.5M VNĐ" (36pt bold white)
- Bottom row (3 items, white text):
  * "18 Tư Vấn" (consultation icon)
  * "4.8 ⭐" (star icon)
  * "+15% ↑" (green text)

URGENT REQUEST BANNER (red background #DC3545 with pulse animation, 80px height):
- Left: Fire icon (32px white)
- Center: "🚨 Yêu Cầu Khẩn Cấp!" (20pt bold white), subtitle "Rescuer cần hỗ trợ nhận diện rắn ngay" (14pt white)
- Right: "Xem Ngay" button (white background, red text)

QUICK STATS GRID (2x2 layout, white cards with purple accent):
- 4 stat cards showing:
  * "Đang Chờ Xác Nhận" - "5" (28pt bold amber)
  * "Đã Hoàn Thành Hôm Nay" - "3" (28pt bold green)
  * "Lịch Hẹn Tuần Này" - "12" (28pt bold purple)
  * "Tỷ Lệ Phản Hồi" - "95%" (28pt bold purple)

UPCOMING CONSULTATIONS SECTION:
- Header: "Lịch Tư Vấn Sắp Tới" (18pt semi-bold purple-dark), "Xem Tất Cả" link (right)
- Show 3 consultation cards (100px height each, white background, 4px purple left border):
  * Card 1: Patient name "Nguyễn Văn A" + purple badge "Tư Vấn Đặt Lịch", date "11/12/2025 - 14:00", snake "Rắn Hổ Mang Chúa (Dự Đoán)", "Chi Tiết" button (outlined purple)
  * Card 2: Similar layout with different data
  * Card 3: Similar layout with different data

BOTTOM NAVIGATION (fixed, 4 tabs):
- "Trang Chủ" (Home icon, purple active state)
- "Tư Vấn" (Consultation icon, gray inactive)
- "Thu Nhập" (Revenue icon, gray inactive)
- "Hồ Sơ" (Profile icon, gray inactive)

DESIGN STYLE: Professional medical interface, purple color scheme (#6B46C1 primary), clean modern design, clear information hierarchy, emphasis on urgent requests and availability status
```

**Notes for Stitch:**
- The urgent request banner should use pulse animation to draw attention
- Ensure the toggle switch has smooth ON/OFF animation
- All touch targets must be minimum 44x44px
- Use consistent 16px spacing between sections
- Icons should be Material Design or similar professional iconography

---

### Screen 2: Notification Center (Consultation Requests)

**Screen Purpose:**  
Centralized view of all consultation requests from Patients (scheduled) and Rescuers (urgent), pending verifications, and system notifications.

**Navigation:**
- Entry: Tap notification bell icon from Screen 1, or push notification
- Exit: Back to Screen 1, or navigate to specific request detail

**Key Components:**

1. **Header Section** (Fixed top):
   - Back arrow button (left) → Navigate to Screen 1
   - Title: "Thông Báo" (24pt, Semi-bold, Purple Dark)
   - Filter icon (right) → Open filter bottom sheet (All, Urgent, Scheduled, Verifications)

2. **Tab Navigation** (Horizontal scroll):
   - Tabs: "Tất Cả" (All), "Khẩn Cấp" (Urgent - red badge count), "Đã Đặt Lịch" (Scheduled), "Xác Minh" (Verifications)
   - Active tab: Purple underline (4px thick), bold text
   - Badge count on each tab showing unread count

3. **Request List** (Scrollable, grouped by priority):
   
   **Priority 1: Urgent Rescuer Requests** (Red section):
   - Section header: "🚨 Khẩn Cấp Từ Rescuer" (18pt, Semi-bold, Emergency Red)
   - Card design (each 140px height):
     - Background: Light red tint (#FFF5F5), red accent border-left (6px)
     - Top row: "KHẨN CẤP" badge (red background, white text, bold) + timestamp "5 phút trước"
     - Row 2: Rescuer avatar (40x40px) + name "Đội Cứu Hộ Sài Gòn" (16pt, Semi-bold)
     - Row 3: Message preview "Cần xác nhận loài rắn ngay, đang ở hiện trường" (14pt, Neutral Gray)
     - Row 4: Snake image thumbnail (60x60px, rounded 8px) + "Rắn độc không rõ loài" tag
     - Right side: "Hỗ Trợ Ngay" button (red background, white text, 120px width)
     - On tap → Navigate to Urgent Consultation Flow
   
   **Priority 2: Scheduled Patient Consultations** (Purple section):
   - Section header: "📅 Tư Vấn Đặt Lịch" (18pt, Semi-bold, Purple Primary)
   - Card design (each 120px height):
     - Background: White, purple accent border-left (4px)
     - Top row: "ĐẶT LỊCH" badge (purple background, white text) + date/time "12/12 - 14:00"
     - Row 2: Patient avatar (40x40px) + name "Nguyễn Thị B" (16pt, Semi-bold)
     - Row 3: Reason "Bị rắn cắn, cần tư vấn xử lý" (14pt, Neutral Gray)
     - Row 4: Snake type "Rắn Hổ Mang (AI dự đoán: 85%)" + snake image thumbnail (50x50px)
     - Right side: "Chuẩn Bị" button (outlined purple, 100px width)
     - On tap → Navigate to Consultation Preparation screen
   
   **Priority 3: Verification Requests** (Amber section):
   - Section header: "✓ Yêu Cầu Xác Minh" (18pt, Semi-bold, Warning Amber)
   - Card design (each 100px height):
     - Background: White, amber accent border-left (4px)
     - Top row: "XÁC MINH" badge (amber background, white text) + timestamp "2 giờ trước"
     - Row 2: Source "Từ AI nhận diện" (14pt, Neutral Gray) + accuracy "78% độ chính xác"
     - Row 3: Snake image thumbnail (60x60px) + predicted species "Rắn Ráo Trâu"
     - Right side: "Xem & Xác Nhận" button (outlined amber, 120px width)
     - On tap → Navigate to Verification Flow

4. **Empty State** (When no notifications):
   - Center icon: Purple bell with checkmark (80x80px)
   - Text: "Không Có Thông Báo Mới" (20pt, Semi-bold, Neutral Gray)
   - Subtext: "Bạn đã xem tất cả thông báo" (14pt, Neutral Gray)

5. **Bottom Action Bar** (Fixed bottom, conditional):
   - Show when user selects multiple notifications (checkbox mode)
   - "Đánh Dấu Đã Đọc" button (left, gray)
   - "Xóa" button (right, red text)

**Interactions:**
- Swipe left on notification card → Show "Đánh Dấu Đã Đọc" and "Xóa" actions
- Tap filter icon → Open bottom sheet with filter options
- Pull to refresh → Reload notification list
- Long press on card → Enable multi-select mode

---

**STITCH PROMPT (English):**

```
Design a Notification Center screen for Snake Expert mobile app showing consultation requests and verifications.

HEADER:
- Back arrow (left), title "Thông Báo" (24pt semi-bold purple-dark #553C9A), filter icon (right)

TAB NAVIGATION (horizontal scroll):
- Tabs: "Tất Cả", "Khẩn Cấp" (red badge "2"), "Đã Đặt Lịch" (badge "5"), "Xác Minh" (amber badge "3")
- Active tab "Tất Cả" with purple underline (4px thick)

CONTENT (scrollable list, grouped by priority):

SECTION 1 - URGENT RESCUER REQUESTS (red section):
- Header: "🚨 Khẩn Cấp Từ Rescuer" (18pt semi-bold red #DC3545)
- Card 1 (140px height, light red background #FFF5F5, 6px red left border):
  * Top: "KHẨN CẤP" badge (red), timestamp "5 phút trước"
  * Row 2: Rescuer avatar (40px circle) + name "Đội Cứu Hộ Sài Gòn" (16pt semi-bold)
  * Row 3: Message "Cần xác nhận loài rắn ngay, đang ở hiện trường" (14pt gray)
  * Row 4: Snake thumbnail image (60px, rounded 8px) + tag "Rắn độc không rõ loài"
  * Right: "Hỗ Trợ Ngay" button (red background, white text, 120px)

SECTION 2 - SCHEDULED PATIENT CONSULTATIONS (purple section):
- Header: "📅 Tư Vấn Đặt Lịch" (18pt semi-bold purple #6B46C1)
- Card 2 (120px height, white background, 4px purple left border):
  * Top: "ĐẶT LỊCH" badge (purple), date "12/12 - 14:00"
  * Row 2: Patient avatar (40px) + name "Nguyễn Thị B" (16pt semi-bold)
  * Row 3: Reason "Bị rắn cắn, cần tư vấn xử lý" (14pt gray)
  * Row 4: "Rắn Hổ Mang (AI dự đoán: 85%)" + snake thumbnail (50px)
  * Right: "Chuẩn Bị" button (outlined purple, 100px)
- Card 3: Similar layout with different patient data

SECTION 3 - VERIFICATION REQUESTS (amber section):
- Header: "✓ Yêu Cầu Xác Minh" (18pt semi-bold amber #FFC107)
- Card 4 (100px height, white background, 4px amber left border):
  * Top: "XÁC MINH" badge (amber), timestamp "2 giờ trước"
  * Row 2: Source "Từ AI nhận diện" + "78% độ chính xác" (14pt gray)
  * Row 3: Snake thumbnail (60px) + "Rắn Ráo Trâu"
  * Right: "Xem & Xác Nhận" button (outlined amber, 120px)

DESIGN STYLE: Professional medical interface, priority-based color coding (red=urgent, purple=scheduled, amber=verification), clear visual hierarchy, easy-to-scan card layout
```

**Notes for Stitch:**
- Use different background tints for each priority level to aid quick scanning
- Ensure urgent requests are always at the top regardless of timestamp
- Badge counts should update in real-time
- Swipe gestures should reveal action buttons smoothly

---

### Screen 3: Schedule Calendar (Upcoming Consultations)

**Screen Purpose:**  
Calendar view showing all scheduled consultations with Patients, allowing Expert to plan their day and prepare for upcoming sessions.

**Navigation:**
- Entry: Tap "Xem Tất Cả" from Screen 1, or navigate from bottom nav "Tư Vấn" tab
- Exit: Back to Screen 1, or navigate to specific consultation detail

**Key Components:**

1. **Header Section** (Fixed top):
   - Back arrow button (left) → Navigate to Screen 1
   - Title: "Lịch Tư Vấn" (24pt, Semi-bold, Purple Dark)
   - Calendar icon with date picker (right) → Open date picker dialog

2. **Week View Calendar** (Horizontal scroll):
   - Display 7 days (scrollable horizontally)
   - Each day column (80px width):
     - Day name "T2" (Monday) (14pt, gray)
     - Date number "11" (24pt, bold)
     - Dot indicators below date showing consultation count (purple dots, max 3 visible)
   - Current day: Purple background, white text
   - Selected day: Purple outline, purple text
   - Days with consultations: Purple dots below date

3. **Date Summary Bar** (Below calendar):
   - Selected date: "Thứ Hai, 11 Tháng 12, 2025" (16pt, Semi-bold, Purple Dark)
   - Consultation count: "5 Tư Vấn Hôm Nay" (14pt, Purple Primary) + consultation icon

4. **Time Slot List** (Scrollable, grouped by time):
   - Show consultations chronologically for selected date
   
   **Morning Section** (08:00 - 12:00):
   - Section header: "Buổi Sáng" (18pt, Semi-bold, Neutral Gray)
   - Time slot card design (each 140px height):
     - Left vertical bar: Time indicator "09:00" (20pt, Bold, Purple Primary)
     - Card content:
       - Row 1: Patient name "Trần Văn C" (18pt, Semi-bold) + Status badge
         - Status options: "Sắp Tới" (purple), "Đang Diễn Ra" (green), "Hoàn Thành" (gray)
       - Row 2: Snake type "Rắn Hổ Mang Chúa" (16pt, Regular) + snake icon
       - Row 3: Duration "45 phút" + Method badge "Video Call" (purple background, white text)
       - Row 4: Snake image thumbnail (70x70px, rounded 8px, right side)
       - Row 5: Button group (left side):
         - "Chi Tiết" button (outlined purple, 100px)
         - "Bắt Đầu" button (filled purple, 100px) - only show if within 15min before scheduled time
   
   **Afternoon Section** (12:00 - 18:00):
   - Section header: "Buổi Chiều" (18pt, Semi-bold, Neutral Gray)
   - Similar time slot cards as morning
   
   **Evening Section** (18:00 - 24:00):
   - Section header: "Buổi Tối" (18pt, Semi-bold, Neutral Gray)
   - Similar time slot cards

5. **Empty State** (When no consultations for selected date):
   - Center icon: Purple calendar with checkmark (80x80px)
   - Text: "Không Có Lịch Hẹn" (20pt, Semi-bold, Neutral Gray)
   - Subtext: "Bạn chưa có tư vấn nào trong ngày này" (14pt, Neutral Gray)

6. **Floating Action Button** (Bottom-right):
   - Purple circle button (56x56px) with "+" icon
   - On tap → Open "Tạo Lịch Rảnh" (block out unavailable time) dialog

**Interactions:**
- Tap on any day in week view → Load consultations for that date
- Swipe left/right on week calendar → Load previous/next week
- Tap "Bắt Đầu" button → Navigate to Video Call/Chat consultation screen
- Tap "Chi Tiết" button → Navigate to consultation detail/preparation screen
- Long press on time slot → Show quick actions (Cancel, Reschedule, Add Notes)

---

**STITCH PROMPT (English):**

```
Design a Schedule Calendar screen for Snake Expert mobile app showing daily consultation appointments.

HEADER:
- Back arrow (left), title "Lịch Tư Vấn" (24pt semi-bold purple-dark #553C9A), calendar icon (right)

WEEK VIEW CALENDAR (horizontal scroll, 7 days visible):
- Each day: Day name "T2" (14pt gray), date "11" (24pt bold)
- Current day (Dec 11): Purple background (#6B46C1), white text, 3 purple dots below (indicating 3 consultations)
- Other days: White background, gray text, purple dots indicating consultation count
- Days: T2(11)●●●, T3(12)●●, T4(13)●, T5(14), T6(15), T7(16)●, CN(17)

DATE SUMMARY BAR:
- "Thứ Hai, 11 Tháng 12, 2025" (16pt semi-bold purple-dark)
- "5 Tư Vấn Hôm Nay" (14pt purple) + consultation icon

TIME SLOT LIST (scrollable, grouped by time of day):

MORNING SECTION:
- Header: "Buổi Sáng" (18pt semi-bold gray)
- Time Slot 1 (140px height card):
  * Left bar: "09:00" (20pt bold purple vertical text)
  * Content: 
    - Patient name "Trần Văn C" (18pt semi-bold) + "Sắp Tới" badge (purple)
    - Snake type "Rắn Hổ Mang Chúa" (16pt) + snake icon
    - "45 phút" + "Video Call" badge (purple background, white text)
    - Snake thumbnail image (70px, rounded 8px, positioned right)
    - Buttons: "Chi Tiết" (outlined purple) + "Bắt Đầu" (filled purple)

- Time Slot 2 (11:00):
  * Similar layout, patient "Nguyễn Thị D", snake "Rắn Ráo Trâu", status "Sắp Tới"

AFTERNOON SECTION:
- Header: "Buổi Chiều" (18pt semi-bold gray)
- Time Slot 3 (14:00):
  * Patient "Lê Văn E", snake "Rắn Lục", status "Sắp Tới", method "Chat"
  * Snake thumbnail image on right
  * Only "Chi Tiết" button (too early to start)

- Time Slot 4 (16:30):
  * Patient "Phạm Thị F", snake "Rắn Hổ Mang", status "Sắp Tới"

EVENING SECTION:
- Header: "Buổi Tối" (18pt semi-bold gray)
- Time Slot 5 (19:00):
  * Patient "Hoàng Văn G", snake "Rắn Đất", status "Sắp Tới", method "Video Call"

FLOATING ACTION BUTTON:
- Purple circle (56px diameter, bottom-right), white "+" icon

DESIGN STYLE: Professional calendar interface, purple color scheme, clear time-based layout, easy navigation between days, visual separation between morning/afternoon/evening
```

**Notes for Stitch:**
- Week calendar should have smooth horizontal scroll
- Current day should be visually prominent with purple background
- Time slots should be vertically aligned with clear time indicators
- "Bắt Đầu" button only appears 15 minutes before scheduled time
- Status badges use different colors: purple (upcoming), green (in progress), gray (completed)

---

### Screen 4: Earnings Detail (Monthly Revenue Breakdown)

**Screen Purpose:**  
Detailed view of Expert's monthly earnings from consultations, showing breakdown by consultation type, revenue trends, and payment status.

**Navigation:**
- Entry: Tap earnings card from Screen 1, or tap "Thu Nhập" tab in bottom navigation
- Exit: Back to Screen 1, or navigate to Transaction History or Withdrawal screens

**Key Components:**

1. **Header Section** (Fixed top):
   - Back arrow button (left) → Navigate to Screen 1
   - Title: "Thu Nhập" (24pt, Semi-bold, Purple Dark)
   - Month selector dropdown (right): "Tháng 12/2025" → Open month picker

2. **Hero Earnings Card** (Top section):
   - Card background: Purple gradient (Purple Primary → Purple Light), 180px height, rounded 16px
   - Top label: "Tổng Thu Nhập Tháng 12" (18pt, White, 70% opacity)
   - Large number: "12.5M VNĐ" (40pt, Bold, White)
   - Growth indicator: "+15% so với tháng trước" (16pt, Success Green background chip, white text)
   - Bottom row (3 quick stats, white text with dividers):
     - "Đã Nhận: 10.2M" (left)
     - "Đang Chờ: 2.3M" (center)
     - "18 Tư Vấn" (right)

3. **Action Buttons Row** (Below hero card):
   - 2 buttons (equal width, 16px gap):
     - "Rút Tiền" button (filled purple, 48px height) + wallet icon → Navigate to Withdrawal screen
     - "Lịch Sử" button (outlined purple, 48px height) + history icon → Navigate to Transaction History

4. **Revenue Breakdown Section**:
   - Section header: "Phân Loại Thu Nhập" (18pt, Semi-bold, Purple Dark)
   - Donut chart (center, 200px diameter):
     - Segments:
       - Patient Consultations (scheduled): 70% (Purple Primary)
       - Rescuer Support (urgent): 25% (Emergency Red)
       - Verifications: 5% (Warning Amber)
     - Center text: "18 Tư Vấn" (total count)
   - Legend below chart:
     - Each legend item (row with color dot + label + amount):
       - "Tư Vấn Patient (12)" → "8.75M VNĐ" (Purple dot)
       - "Hỗ Trợ Rescuer (5)" → "3.12M VNĐ" (Red dot)
       - "Xác Minh AI (1)" → "625K VNĐ" (Amber dot)

5. **7-Day Earnings Trend Chart**:
   - Section header: "Xu Hướng 7 Ngày" (18pt, Semi-bold, Purple Dark)
   - Bar chart (horizontal scroll if needed):
     - X-axis: Days "T2, T3, T4, T5, T6, T7, CN"
     - Y-axis: Revenue (0 - 2M VNĐ scale)
     - Bars: Purple gradient, rounded tops
     - Peak day highlighted: "T5" with 1.8M VNĐ label above bar
     - Average line: Dashed horizontal line at average value (1.2M)

6. **Recent Transactions Section** (Scrollable):
   - Section header: "Giao Dịch Gần Đây" (18pt, Semi-bold, Purple Dark)
   - "Xem Tất Cả" link (right) → Navigate to Transaction History
   - Transaction cards (show 5 recent, each 80px height):
     - Card design:
       - Left: Transaction icon (consultation, verification, withdrawal)
       - Center:
         - Row 1: Type "Tư Vấn Video Call" (16pt, Semi-bold)
         - Row 2: Patient name "Nguyễn Văn A" (14pt, Neutral Gray)
         - Row 3: Date/time "11/12/2025 - 09:00" (12pt, Neutral Gray)
       - Right:
         - Amount "+270K VNĐ" (18pt, Bold, Success Green for income, Red for withdrawal)
         - Status badge: "Đã Nhận" (green background), "Đang Chờ" (amber), "Đã Rút" (gray)

7. **Payment Method Card** (Bottom):
   - Section header: "Phương Thức Thanh Toán" (18pt, Semi-bold, Purple Dark)
   - Bank card display (horizontal scroll if multiple):
     - Card design (180px width, 100px height, rounded 12px):
       - Background: Purple gradient
       - Bank logo (top-left, 40x40px)
       - Bank name: "Vietcombank" (16pt, White)
       - Account number: "**** **** **** 8234" (14pt, White, 70% opacity)
       - Label: "Tài Khoản Chính" badge (white background, purple text)
     - "Thêm Tài Khoản" button (outlined purple, 48px height, full width below cards)

**Interactions:**
- Tap month selector → Open month picker to view historical data
- Tap "Rút Tiền" button → Navigate to withdrawal screen with pre-filled available balance
- Tap donut chart segment → Filter recent transactions by that type
- Tap transaction card → Show transaction detail with invoice option
- Tap bank card → Navigate to bank account management
- Pull to refresh → Reload earnings data

---

**STITCH PROMPT (English):**

```
Design an Earnings Detail screen for Snake Expert mobile app showing monthly revenue breakdown and trends.

HEADER:
- Back arrow (left), title "Thu Nhập" (24pt semi-bold purple-dark #553C9A), month dropdown "Tháng 12/2025" (right)

HERO EARNINGS CARD (purple gradient #6B46C1 to #9F7AEA, 180px height, rounded 16px):
- Top: "Tổng Thu Nhập Tháng 12" (18pt white 70% opacity)
- Center: "12.5M VNĐ" (40pt bold white)
- Growth chip: "+15% so với tháng trước" (green background #28A745, white text)
- Bottom row (3 stats with dividers, white text):
  * "Đã Nhận: 10.2M"
  * "Đang Chờ: 2.3M"
  * "18 Tư Vấn"

ACTION BUTTONS (2 equal-width buttons, 16px gap):
- "Rút Tiền" (filled purple, 48px height, wallet icon)
- "Lịch Sử" (outlined purple, 48px height, history icon)

REVENUE BREAKDOWN SECTION:
- Header: "Phân Loại Thu Nhập" (18pt semi-bold purple-dark)
- Donut chart (200px diameter):
  * Purple segment (60%): Patient Consultations (Scheduled + SOS)
  * Green segment (15%): Rescuer Support
  * Amber segment (25%): Verifications
  * Center: "18 Tư Vấn" (total count)
- Legend (4 rows):
  * Purple dot + "Tư Vấn Patient Scheduled (8)" → "2.16M VNĐ" (8 × 270K)
  * Purple dot + "Tư Vấn SOS Patient (4)" → "1.80M VNĐ" (4 × 450K)
  * Green dot + "Hỗ Trợ Rescuer (6)" → "300K VNĐ" (6 × 50K)
  * Amber dot + "Xác Minh AI (varies)" → "625K VNĐ"

7-DAY EARNINGS TREND:
- Header: "Xu Hướng 7 Ngày" (18pt semi-bold purple-dark)
- Bar chart (7 days: T2, T3, T4, T5, T6, T7, CN):
  * Purple gradient bars with rounded tops
  * T5 is highest (1.8M) with label above
  * Dashed horizontal line at average (1.2M)
  * Y-axis scale: 0 - 2M VNĐ

RECENT TRANSACTIONS:
- Header: "Giao Dịch Gần Đây" (18pt semi-bold), "Xem Tất Cả" link (right)
- 5 transaction cards (80px height each):
  * Card 1: Consultation icon, "Tư Vấn Patient (Scheduled)", "Nguyễn Văn A", "11/12/2025 - 09:00", "+270K VNĐ" (green), "Đã Nhận" badge (green)
  * Card 2: Consultation icon, "Tư Vấn SOS (Patient)", "Trần Văn B", "10/12/2025 - 16:30", "+450K VNĐ" (green), "Đã Nhận" badge
  * Card 3: Consultation icon, "Hỗ Trợ Rescuer", "Đội Cứu Hộ SG", "10/12/2025 - 14:00", "+50K VNĐ" (green), "Đang Chờ" badge (amber)
  * Card 4: Verification icon, "Xác Minh AI", "Hệ Thống", "09/12/2025 - 11:00", "+75K VNĐ" (green), "Đã Nhận" badge
  * Card 5: Withdrawal icon, "Rút Tiền", "Vietcombank", "08/12/2025 - 10:00", "-5.0M VNĐ" (red), "Đã Rút" badge (gray)

PAYMENT METHOD SECTION:
- Header: "Phương Thức Thanh Toán" (18pt semi-bold purple-dark)
- Bank card (180px width, 100px height, purple gradient, rounded 12px):
  * Vietcombank logo (40px, top-left)
  * "Vietcombank" (16pt white)
  * "**** **** **** 8234" (14pt white 70% opacity)
  * "Tài Khoản Chính" badge (white background, purple text)
- "Thêm Tài Khoản" button (outlined purple, full-width, 48px height)

DESIGN STYLE: Professional financial interface, purple color scheme, clear data visualization with donut chart and bar chart, easy-to-read transaction list
```

**Notes for Stitch:**
- Donut chart should have smooth animations when loading
- Bar chart should show smooth bar growth animation
- Transaction amounts use color coding: green for income, red for withdrawals
- Month selector should support past 12 months of data
- All financial numbers use VNĐ currency format with thousands separators

---

## Integration Points

### Data Requirements:
- **Expert Profile Data:** ID, name, specialization, rating, availability status, verified status
- **Consultation Requests:** Patient/Rescuer requests with priority levels, timestamps, snake data
- **Earnings Data:** Monthly revenue, consultation counts, payment status, transaction history
- **Calendar Data:** Scheduled consultations with date/time, patient info, snake species
- **Notification Data:** Unread counts, request types, urgency levels

### API Endpoints (Assumed):
- `GET /expert/dashboard/summary` - Get dashboard overview data
- `GET /expert/notifications` - Get all consultation requests and verifications
- `GET /expert/schedule?date={date}` - Get consultations for specific date
- `GET /expert/earnings?month={month}` - Get earnings breakdown for month
- `POST /expert/availability` - Update online/offline status
- `POST /expert/consultation/accept` - Accept consultation request
- `GET /expert/transactions` - Get transaction history

### Navigation Flow:
```
Screen 1 (Dashboard)
  ├─→ Screen 2 (Notification Center)
  │     ├─→ Urgent Consultation Flow
  │     ├─→ Scheduled Consultation Flow
  │     └─→ Verification Flow
  ├─→ Screen 3 (Schedule Calendar)
  │     ├─→ Consultation Detail/Preparation
  │     └─→ Video Call/Chat Screen
  ├─→ Screen 4 (Earnings Detail)
  │     ├─→ Withdrawal Screen
  │     ├─→ Transaction History
  │     └─→ Bank Account Management
  └─→ Profile Settings
```

### Real-time Updates:
- Urgent request notifications (push + in-app)
- Consultation reminders (15 minutes before scheduled time)
- Payment received notifications
- Availability status sync across devices

---

## Version History
- **v1.0** - December 11, 2025: Initial dashboard screens design (4 screens)
- **Repository:** SnakeAidDocs, Owner: Zun1702, Branch: main

---

## Design Review Checklist
- [x] All screens follow purple color scheme (#6B46C1 primary)
- [x] Urgent requests prominently displayed with red badges and pulse animations
- [x] Availability toggle easily accessible
- [x] Earnings data clearly visualized with charts
- [x] Calendar view supports day/week navigation
- [x] All touch targets minimum 44x44px
- [x] Consistent typography and spacing (16px base)
- [x] Empty states designed for all list views
- [x] Real-time notification badges implemented
- [x] Integration with consultation flows planned

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Expert-Consultation-Flow-Screens.md, Expert-Revenue-Management-Screens.md*
