# PROFILE & SETTINGS SCREENS - UI DESIGN (PATIENT ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Patient Mobile Application
- **Role:** 🧑 **PATIENT** (Người dùng)
- **Flow:** Profile & Settings Management
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 7 screens
- **Ngày tạo:** December 5, 2025
- **Location:** `/02-UI-Design/Patient/Patient-Profile-Settings-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **PATIENT role**.

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Forest Green `#228B22`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Info:** Blue `#007BFF`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Danger:** Red `#DC3545`

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

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🧑 Tất cả screens dưới đây là cho PATIENT role** - người dùng quản lý thông tin cá nhân và cài đặt

---

### Screen 1: Profile Overview Screen

#### Thông tin màn hình:
- **Tên:** Màn hình tổng quan thông tin cá nhân
- **Mục đích:** Hiển thị thông tin profile và menu quản lý tài khoản
- **Flow position:** Entry point từ bottom navigation hoặc homepage
- **Priority:** ⭐⭐⭐ (Cao)

#### Key Components:
1. **Header:**
   - Title: "Cá Nhân"
   - Settings icon (top-right) → Navigate to Settings Screen

2. **Profile Card (top section):**
   - Large circular avatar (100px) - centered
   - Full name: "Nguyễn Văn A" (bold, 20pt)
   - Phone number: "+84 912 345 678" (gray, 16pt)
   - Edit profile button (outlined)
   - Small badge: "Tài khoản đã xác minh" (green checkmark)

3. **Stats Row (3 columns):**
   - Column 1: "5 ca khẩn cấp" (number of emergency cases)
   - Column 2: "2 lần tư vấn" (consultations)
   - Column 3: "3 cứu hộ" (rescue requests)

4. **Menu Items (list):**
   Each item has icon left, title, subtitle, chevron right:
   - **Lịch Sử Sức Khỏe** - "5 ca rắn cắn đã ghi nhận"
   - **Lịch Sử Thanh Toán** - "8 giao dịch"
   - **Địa Chỉ Đã Lưu** - "2 địa chỉ"
   - **Liên Hệ Khẩn Cấp** - "3 người liên hệ"
   - **Hồ Sơ Y Tế** - "Nhóm máu, dị ứng, tiền sử bệnh"
   - **Chứng Chỉ & Giấy Tờ** - "CMND, BHYT"

5. **Action Buttons (bottom section):**
   - Secondary button: "Chế Độ Cứu Hộ Viên" (outlined green)
   - Text link: "Chuyển sang Expert mode"

#### Stitch Prompt (English):

```
Mobile app profile overview screen for patient in snake emergency app "SnakeAid". Profile management interface with forest green (#228B22) theme.

Top navigation: Centered title "Cá Nhân" in bold dark gray, settings gear icon top-right.

Top section white card with centered layout: Large circular avatar (100px diameter) with light gray border. Below avatar, bold dark gray name "Nguyễn Văn A" (20pt). Below name, gray phone number "+84 912 345 678" (16pt). Below phone, small green badge "Tài khoản đã xác minh" with checkmark icon. Below badge, outlined forest green button "Chỉnh Sửa Hồ Sơ" medium size.

Stats section white card below profile showing 3 equal columns separated by vertical dividers:
- Left: Bold dark gray "5" large, gray text "Ca khẩn cấp" small below
- Center: Bold dark gray "2" large, gray text "Lần tư vấn" small below
- Right: Bold dark gray "3" large, gray text "Cứu hộ" small below

Menu section showing vertically stacked white cards with 8px spacing. Each card has:
- Left: Icon in forest green (24px)
- Center vertical layout: Bold dark gray title (16pt), small gray subtitle (14pt) below
- Right: Gray chevron arrow icon

Menu items:
1. Heart pulse icon, "Lịch Sử Sức Khỏe", "5 ca rắn cắn đã ghi nhận"
2. Wallet icon, "Lịch Sử Thanh Toán", "8 giao dịch"
3. Location pin icon, "Địa Chỉ Đã Lưu", "2 địa chỉ"
4. Phone contact icon, "Liên Hệ Khẩn Cấp", "3 người liên hệ"
5. Medical file icon, "Hồ Sơ Y Tế", "Nhóm máu, dị ứng, tiền sử bệnh"
6. ID card icon, "Chứng Chỉ & Giấy Tờ", "CMND, BHYT"

Bottom section white card with padding:
- Large outlined forest green button "Chế Độ Cứu Hộ Viên" spanning full width
- Below button, centered gray text link "Chuyển sang Expert mode"

Design: Clean profile interface, clear information hierarchy, easy navigation to all account features.
```

#### Notes for Stitch:
- Avatar phải prominent và có thể tap để change
- Stats numbers phải bold để stand out
- Menu items phải có clear tap targets (44px min height)

---

### Screen 2: Edit Profile Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chỉnh sửa thông tin cá nhân
- **Mục đích:** Cho phép cập nhật thông tin cá nhân của Patient
- **Flow position:** Từ Profile Overview → Tap "Chỉnh Sửa Hồ Sơ"
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button (left)
   - Title: "Chỉnh Sửa Hồ Sơ"
   - Save button (right, green text)

2. **Avatar Section:**
   - Large circular avatar (120px) - centered
   - Camera icon overlay (bottom-right of avatar)
   - Text: "Chạm để thay đổi ảnh"

3. **Form Fields (scrollable):**
   - **Họ và Tên** - Text input, required
   - **Số Điện Thoại** - Phone input, disabled (verified)
   - **Email** - Email input, optional
   - **Ngày Sinh** - Date picker
   - **Giới Tính** - Radio buttons (Nam/Nữ/Khác)
   - **Địa Chỉ** - Text area (2 lines)
   - **Tỉnh/Thành Phố** - Dropdown selector
   - **Quận/Huyện** - Dropdown selector

4. **Action Buttons (sticky bottom):**
   - Primary button: "Lưu Thay Đổi" (green, full width)
   - Text link: "Hủy" (centered below)

#### Stitch Prompt (English):

```
Mobile app edit profile form screen for patient in "SnakeAid". Profile editing interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Chỉnh Sửa Hồ Sơ" bold dark gray, "Lưu" text button right in forest green.

Top section centered: Large circular avatar (120px) with light gray border. Small camera icon (32px) with white background overlaid on bottom-right of avatar. Below avatar, small gray text "Chạm để thay đổi ảnh".

Scrollable form section with white background, each field has label above input:

Field 1: Label "Họ và Tên" bold dark gray with red asterisk. Text input box below with rounded corners (8px), gray border, placeholder "Nguyễn Văn A".

Field 2: Label "Số Điện Thoại" bold dark gray. Phone input box with green checkmark icon right, light gray background (disabled), text "+84 912 345 678".

Field 3: Label "Email" bold dark gray (optional). Email input box with placeholder "example@email.com".

Field 4: Label "Ngày Sinh" bold dark gray. Date input box with calendar icon right, placeholder "DD/MM/YYYY".

Field 5: Label "Giới Tính" bold dark gray. Three horizontal radio buttons: "Nam", "Nữ", "Khác" with forest green selection.

Field 6: Label "Địa Chỉ" bold dark gray. Text area (2 lines height) with placeholder "Số nhà, tên đường...".

Field 7: Label "Tỉnh/Thành Phố" bold dark gray. Dropdown box with down arrow icon right, placeholder "Chọn tỉnh/thành phố".

Field 8: Label "Quận/Huyện" bold dark gray. Dropdown box with down arrow icon right, placeholder "Chọn quận/huyện".

Spacing: 20px between fields vertically.

Bottom sticky section with white background, top shadow: Large solid forest green button "Lưu Thay Đổi" spanning full width. Below button, centered gray text link "Hủy".

Design: Clean form layout, clear labels, accessible input fields, validation-ready.
```

#### Notes for Stitch:
- Phone field phải disabled với verified indicator
- Required fields có red asterisk
- Dropdown fields phải có clear picker UI

---

### Screen 3: Health History Screen

#### Thông tin màn hình:
- **Tên:** Màn hình lịch sử sức khỏe
- **Mục đích:** Hiển thị tất cả ca rắn cắn đã ghi nhận và lịch sử triệu chứng
- **Flow position:** Từ Profile Overview → "Lịch Sử Sức Khỏe"
- **Priority:** ⭐⭐⭐ (Cao - Related to FE-11)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Lịch Sử Sức Khỏe"
   - Filter icon (right) - Filter by date/severity

2. **Summary Card (top):**
   - Total cases: "5 ca rắn cắn"
   - Last incident: "3 tháng trước"
   - Status: "Không có ca đang theo dõi"

3. **Incident Cards (scrollable list):**
   Each card shows:
   - **Date & Time:** "15 Thg 9, 2025 - 14:30"
   - **Snake Type:** "Rắn Hổ Mang (AI xác định)"
   - **Severity Level:** Badge (Red: Nguy kịch, Amber: Nặng, Green: Nhẹ)
   - **Status:** "Đã hoàn thành điều trị"
   - **Location:** "Quận 1, TP.HCM"
   - **View Details** button (text link)

4. **Each Detail includes:**
   - Photos of snake (if available)
   - Photos of bite progression (timeline)
   - Symptom tracking history
   - Treatment received
   - Hospital visited
   - Notes from doctors/experts

5. **Empty State (if no history):**
   - Icon: Medical file with checkmark
   - Text: "Chưa có lịch sử sức khỏe"
   - Subtitle: "Các ca rắn cắn sẽ được lưu tại đây"

#### Stitch Prompt (English):

```
Mobile app health history screen for patient snakebite records in "SnakeAid". Medical history interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Lịch Sử Sức Khỏe" bold dark gray, filter icon right.

Top summary white card with rounded corners: Three lines centered text:
- Bold dark gray "5 ca rắn cắn" large (20pt)
- Gray "Lần cuối: 3 tháng trước" (16pt)
- Small green badge "Không có ca đang theo dõi" with checkmark

Main content: Scrollable vertical list of incident cards. Each white card has shadow, rounded corners (12px), padding, with following layout:

CARD STRUCTURE:
Top row: Bold dark gray date "15 Thg 9, 2025 - 14:30" left, severity badge right (amber background "Nặng" or red "Nguy kịch" or green "Nhẹ").

Second row: Dark gray text "Loài rắn:" left aligned, bold text "Rắn Hổ Mang" right with small purple badge "(AI)".

Third row: Small gray text "Trạng thái:" left, green text "Đã hoàn thành điều trị" with checkmark right.

Fourth row: Location pin icon gray, small gray text "Quận 1, TP.HCM".

Bottom: Small blue text link "Xem Chi Tiết" right aligned.

Card spacing: 12px between cards vertically.

If empty state: Centered content with large gray medical file icon (80px), bold dark gray text "Chưa có lịch sử sức khỏe", small gray text below "Các ca rắn cắn sẽ được lưu tại đây".

Design: Medical record interface, clear timeline, status indicators, easy access to case details.
```

#### Notes for Stitch:
- Severity badges phải rõ ràng với màu sắc consistent
- Timeline phải sort từ mới nhất xuống cũ nhất
- Detail view phải show full progression với photos

---

### Screen 4: Payment History Screen

#### Thông tin màn hình:
- **Tên:** Màn hình lịch sử thanh toán
- **Mục đích:** Hiển thị tất cả giao dịch thanh toán và hóa đơn
- **Flow position:** Từ Profile Overview → "Lịch Sử Thanh Toán"
- **Priority:** ⭐⭐ (Related to FE-27, FE-28, FE-29, FE-30)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Lịch Sử Thanh Toán"
   - Filter icon (right) - Filter by type/date

2. **Summary Card:**
   - Total spent: "2,450,000 VNĐ"
   - This month: "450,000 VNĐ"
   - Pending payments: "0"

3. **Filter Tabs:**
   - "Tất cả" (default selected)
   - "Cứu hộ"
   - "Tư vấn chuyên gia"
   - "Khác"

4. **Transaction Cards (scrollable list):**
   Each card shows:
   - **Service Icon** (left) - Rescue or Consultation icon
   - **Service Name:** "Cứu Hộ Rắn" / "Tư Vấn Chuyên Gia"
   - **Provider:** "Đội cứu hộ ABC" / "TS. Nguyễn Văn An"
   - **Date:** "15 Thg 9, 2025"
   - **Amount:** "200,000 VNĐ" (bold, right aligned)
   - **Status Badge:** "Đã thanh toán" (green) / "Đang chờ" (amber)
   - **Invoice button:** "Xem hóa đơn" (text link)

5. **Transaction Detail includes:**
   - Service description
   - Time & duration
   - Original price
   - Discount (if any)
   - Platform fee
   - Total paid
   - Payment method
   - Transaction ID
   - Digital invoice (downloadable)

#### Stitch Prompt (English):

```
Mobile app payment history screen for patient transactions in "SnakeAid". Financial history interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Lịch Sử Thanh Toán" bold dark gray, filter icon right.

Top summary white card: Three columns with vertical dividers:
- Left: "2,450,000 VNĐ" bold dark gray large, "Tổng chi tiêu" small gray below
- Center: "450,000 VNĐ" bold, "Tháng này" gray below
- Right: "0" bold, "Chờ thanh toán" gray below

Below summary, horizontal scrollable tab bar with 4 tabs: "Tất cả" (forest green underline, selected), "Cứu hộ", "Tư vấn chuyên gia", "Khác" (gray text).

Main content: Scrollable vertical list of transaction cards. Each white card has shadow, rounded corners (12px), padding:

CARD STRUCTURE:
Left side: Circular icon (48px) - ambulance icon for rescue, chat icon for consultation, green background.

Right side (vertical layout):
- Top row: Bold dark gray "Cứu Hộ Rắn" left, bold forest green "200,000 VNĐ" right
- Second row: Small gray text "Đội cứu hộ ABC"
- Third row: Small gray text "15 Thg 9, 2025" left, small green badge "Đã thanh toán" right
- Bottom row: Small blue text link "Xem hóa đơn"

Card spacing: 12px between cards.

Design: Clean transaction list, clear amounts, status indicators, easy invoice access.
```

#### Notes for Stitch:
- Amount phải right-aligned và bold để dễ scan
- Status badges phải consistent với app (green = success, amber = pending, red = failed)
- Invoice button phải easy to tap

---

### Screen 5: Emergency Contacts Screen

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý liên hệ khẩn cấp
- **Mục đích:** Quản lý danh sách người thân/bạn bè được thông báo khi khẩn cấp
- **Flow position:** Từ Profile Overview → "Liên Hệ Khẩn Cấp"
- **Priority:** ⭐⭐⭐ (Related to emergency flow)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Liên Hệ Khẩn Cấp"
   - Add button (top-right, "+" icon)

2. **Info Banner (top):**
   - Icon: Info circle (blue)
   - Text: "Những người này sẽ nhận thông báo khi bạn kích hoạt SOS"

3. **Contact Cards (list):**
   Each card shows:
   - **Avatar** (circular, left) - with initial if no photo
   - **Name:** "Nguyễn Thị B" (bold)
   - **Relationship:** "Vợ" / "Bố" / "Bạn" (gray text)
   - **Phone:** "+84 912 345 678"
   - **Primary Badge:** "Liên hệ chính" (green, if marked as primary)
   - **Actions:** Edit icon, Delete icon (right)

4. **Priority Order:**
   - Drag handle icon (left) to reorder
   - Text: "Thứ tự ưu tiên: 1, 2, 3..."

5. **Add Contact Button (bottom):**
   - Large outlined green button: "+ Thêm Liên Hệ Khẩn Cấp"

6. **Recommended Limit:**
   - Text: "Khuyến nghị: 2-4 người" (gray)
   - Current: "3/5 contacts" (gray)

#### Stitch Prompt (English):

```
Mobile app emergency contacts management screen in "SnakeAid". Contact list interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Liên Hệ Khẩn Cấp" bold dark gray, plus icon button right.

Top info banner: Light blue background (#E3F2FD), rounded corners, horizontal layout with blue info circle icon left, text "Những người này sẽ nhận thông báo khi bạn kích hoạt SOS" dark gray right.

Main content: Scrollable vertical list of contact cards. Each white card has shadow, rounded corners (12px), padding:

CARD STRUCTURE:
Far left: Small drag handle icon (three horizontal lines) gray for reordering.

Left: Circular avatar (60px) with light gray border. If no photo, shows initial letter "B" centered on green background.

Center vertical layout:
- Bold dark gray name "Nguyễn Thị B" (18pt)
- Small gray badge "Vợ" rounded
- Gray phone number "+84 912 345 678" with phone icon left
- Small green badge "Liên hệ chính" if primary contact

Far right: Two small icon buttons vertically stacked - pencil edit icon top, trash delete icon bottom, both gray.

Card spacing: 12px between cards.

Bottom section white background, padding: Text "3/5 contacts" centered gray small. Below, large outlined forest green button "+ Thêm Liên Hệ Khẩn Cấp" spanning full width. Below button, centered small gray text "Khuyến nghị: 2-4 người".

Design: Emergency contact management, clear contact info, easy reordering, quick add/edit/delete actions.
```

#### Notes for Stitch:
- Primary contact phải có clear indicator
- Drag handles phải functional để reorder
- Maximum 5 contacts recommended

---

### Screen 6: Medical Profile Screen

#### Thông tin màn hình:
- **Tên:** Màn hình hồ sơ y tế
- **Mục đích:** Lưu trữ thông tin y tế quan trọng để hỗ trợ cấp cứu
- **Flow position:** Từ Profile Overview → "Hồ Sơ Y Tế"
- **Priority:** ⭐⭐⭐ (Critical for emergency treatment)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Hồ Sơ Y Tế"
   - Edit button (top-right)

2. **Critical Info Card (red border):**
   - **Nhóm Máu:** "A+" (large, bold)
   - **Dị Ứng:** "Penicillin, Hải sản" (red text if any, green "Không" if none)
   - **Bệnh Mãn Tính:** "Không" (green) / List diseases (red if any)

3. **Medical History Section:**
   - **Tiền Sử Bệnh:**
     - Free text area showing past conditions
   - **Thuốc Đang Dùng:**
     - List of current medications with dosage
   - **Tiền Sử Phẫu Thuật:**
     - List of past surgeries with dates
   - **Tiền Sử Rắn Cắn:**
     - Number of previous snakebites
     - Types of snakes involved
     - Reactions to antivenom (if any)

4. **Insurance Section:**
   - **Bảo Hiểm Y Tế:**
     - Card number
     - Valid until date
     - Photo of insurance card

5. **Emergency Notes:**
   - Text area: "Thông tin bổ sung cho đội cấp cứu"
   - Examples: "Sống tầng 5 không thang máy", "Sợ chó"

6. **Visibility Toggle:**
   - Switch: "Chia sẻ với đội cứu hộ khi khẩn cấp"
   - Info: "Giúp đội cứu hộ chuẩn bị tốt hơn"

#### Stitch Prompt (English):

```
Mobile app medical profile screen for patient health records in "SnakeAid". Medical information interface with forest green (#228B22) primary, red (#DC3545) for critical alerts.

Top navigation: Back arrow left, centered title "Hồ Sơ Y Tế" bold dark gray, "Sửa" text button right forest green.

Top critical info card: White background, red left border (4px thick), rounded corners, shadow. Three sections:
- Left: "Nhóm Máu" small gray label, "A+" very large bold red (32pt) below
- Center: "Dị Ứng" small gray label, "Penicillin, Hải sản" red text (16pt) below (or green "Không" if none)
- Right: "Bệnh Mãn Tính" small gray label, green "Không" below (or red disease list if any)

Section titled "Tiền Sử Bệnh" bold dark gray (18pt):
White card with gray text paragraph showing medical history conditions.

Section titled "Thuốc Đang Dùng" bold dark gray:
White card with list showing:
• Medication name bold, dosage gray, frequency gray (one per line)

Section titled "Tiền Sử Phẫu Thuật" bold dark gray:
White card with list showing:
• Surgery type bold, date gray (one per line)

Section titled "Tiền Sử Rắn Cắn" bold dark gray:
White card showing:
- "Số lần: 1" gray
- "Loài rắn: Rắn Hổ Mang" gray
- "Phản ứng huyết thanh: Không" green

Section titled "Bảo Hiểm Y Tế" bold dark gray:
White card showing:
- "Số thẻ: DN1234567890" gray
- "Hiệu lực: 31/12/2025" gray
- Small thumbnail image of insurance card

Section titled "Ghi Chú Khẩn Cấp" bold dark gray:
White card with light gray text area showing notes for emergency teams.

Bottom section white card: Toggle switch right aligned with forest green when on, gray when off. Label left "Chia sẻ với đội cứu hộ khi khẩn cấp" bold dark gray. Small blue info icon right. Below toggle, small gray text "Giúp đội cứu hộ chuẩn bị tốt hơn".

Design: Medical information interface, critical data prominent, comprehensive health history, emergency-ready.
```

#### Notes for Stitch:
- Blood type phải VERY prominent với red color
- Allergies phải stand out để avoid medication errors
- Toggle phải default ON để share với emergency teams

---

### Screen 7: Settings Screen

#### Thông tin màn hình:
- **Tên:** Màn hình cài đặt ứng dụng
- **Mục đích:** Cấu hình preferences và app settings
- **Flow position:** Từ Profile Overview → Settings icon
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Cài Đặt"

2. **Account Section:**
   - **Số Điện Thoại:** "+84 912 345 678" (verified)
   - **Email:** "user@example.com" (tap to verify if not verified)
   - **Mật Khẩu:** "********" → "Đổi mật khẩu" link

3. **Notification Settings:**
   - Toggle: "Thông báo đẩy"
   - Toggle: "Cảnh báo khẩn cấp" (always ON, disabled)
   - Toggle: "Cảnh báo khu vực"
   - Toggle: "Thông báo tư vấn"
   - Toggle: "Khuyến mãi & tin tức"

4. **Location Settings:**
   - Toggle: "Chia sẻ vị trí tự động khi SOS"
   - Toggle: "Lưu lịch sử vị trí"
   - Button: "Xóa dữ liệu vị trí" (destructive)

5. **Privacy Settings:**
   - Toggle: "Hiển thị profile công khai"
   - Toggle: "Cho phép chuyên gia xem lịch sử"
   - Link: "Điều khoản sử dụng"
   - Link: "Chính sách bảo mật"

6. **App Preferences:**
   - Language: "Tiếng Việt" (dropdown)
   - Theme: "Sáng" / "Tối" / "Tự động" (segmented control)
   - Map provider: "Google Maps" / "Apple Maps"

7. **Data Management:**
   - Button: "Xuất dữ liệu của tôi"
   - Button: "Xóa bộ nhớ cache"
   - Text: "Cache size: 45 MB"

8. **Account Actions:**
   - Button: "Đăng xuất" (outlined, amber)
   - Button: "Xóa tài khoản" (text, red)

9. **App Info (bottom):**
   - Version: "SnakeAid v1.0.2"
   - Build: "Build 2025.12.05"
   - Link: "Báo lỗi"
   - Link: "Đánh giá ứng dụng"

#### Stitch Prompt (English):

```
Mobile app settings screen for patient in "SnakeAid". Comprehensive settings interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Cài Đặt" bold dark gray.

Settings organized in sections with section headers bold dark gray (16pt), each section in white card with 16px vertical spacing:

SECTION: "Tài Khoản"
- Row: "Số Điện Thoại" left gray, "+84 912 345 678" right dark gray with small green checkmark
- Row: "Email" left gray, "user@example.com" right dark gray with blue "Xác thực" link
- Row: "Mật Khẩu" left gray, "********" right gray with blue "Đổi" link

SECTION: "Thông Báo"
Each row has label left dark gray, toggle switch right (forest green when on):
- "Thông báo đẩy" - toggle
- "Cảnh báo khẩn cấp" - toggle ON and disabled (light gray) with lock icon
- "Cảnh báo khu vực" - toggle
- "Thông báo tư vấn" - toggle
- "Khuyến mãi & tin tức" - toggle

SECTION: "Vị Trí"
- "Chia sẻ vị trí tự động khi SOS" - toggle
- "Lưu lịch sử vị trí" - toggle
- Button full width outlined red "Xóa dữ liệu vị trí"

SECTION: "Quyền Riêng Tư"
- "Hiển thị profile công khai" - toggle
- "Cho phép chuyên gia xem lịch sử" - toggle
- "Điều khoản sử dụng" - chevron right, gray
- "Chính sách bảo mật" - chevron right, gray

SECTION: "Tùy Chọn Ứng Dụng"
- Row: "Ngôn ngữ" left, "Tiếng Việt" right with down arrow
- Row: "Giao diện" left, three segment buttons right "Sáng"|"Tối"|"Tự động" (green selection)
- Row: "Bản đồ" left, "Google Maps" right with down arrow

SECTION: "Quản Lý Dữ Liệu"
- Button outlined gray "Xuất dữ liệu của tôi" full width
- Button outlined gray "Xóa bộ nhớ cache" full width
- Small gray text centered "Kích thước cache: 45 MB"

SECTION: "Tài Khoản"
- Large outlined amber button "Đăng Xuất" full width
- Centered red text link "Xóa tài khoản"

Bottom section light gray background, centered small gray text:
- "SnakeAid v1.0.2"
- "Build 2025.12.05"
- Blue text links horizontal: "Báo lỗi" | "Đánh giá ứng dụng"

Design: Comprehensive settings, clear sections, toggle switches, safe destructive actions confirmation.
```

#### Notes for Stitch:
- Emergency notifications toggle phải ALWAYS ON và disabled
- Destructive actions (delete data, delete account) phải confirm
- Version info helpful for bug reports

---

## 🔗 NAVIGATION FLOW

```
Profile Overview (Screen 1)
    │
    ├─→ Edit Profile (Screen 2)
    │   └─→ Save → Back to Profile Overview
    │
    ├─→ Health History (Screen 3)
    │   └─→ Incident Detail → View photos, symptoms, timeline
    │
    ├─→ Payment History (Screen 4)
    │   └─→ Transaction Detail → View/Download Invoice
    │
    ├─→ Emergency Contacts (Screen 5)
    │   ├─→ Add Contact → Form → Save
    │   └─→ Edit Contact → Form → Save
    │
    ├─→ Medical Profile (Screen 6)
    │   └─→ Edit Medical Info → Form → Save
    │
    └─→ Settings (Screen 7)
        ├─→ Change Password
        ├─→ Privacy Policy
        ├─→ Terms of Service
        └─→ Logout / Delete Account
```

---

## 📋 FEATURE MAPPING

| Screen | Related Major Features | Priority |
|--------|------------------------|----------|
| Profile Overview | Account management | ⭐⭐⭐ |
| Edit Profile | User profile CRUD | ⭐⭐⭐ |
| Health History | FE-11 (Track history) | ⭐⭐⭐ |
| Payment History | FE-27, FE-28, FE-29, FE-30 | ⭐⭐ |
| Emergency Contacts | Emergency notification system | ⭐⭐⭐ |
| Medical Profile | Emergency treatment support | ⭐⭐⭐ |
| Settings | App preferences & privacy | ⭐⭐ |

---

## ✅ DESIGN CHECKLIST

Before implementation:

- [ ] All screens follow design system (colors, typography, spacing)
- [ ] Touch targets minimum 44x44px
- [ ] Critical medical info is prominent (blood type, allergies)
- [ ] Emergency contacts easy to add/edit/reorder
- [ ] Payment history shows clear transaction details
- [ ] Health history timeline is chronological
- [ ] Settings organized in logical sections
- [ ] Destructive actions require confirmation
- [ ] Privacy toggles clear and accessible
- [ ] Form validation and error states designed
- [ ] Loading states for async operations
- [ ] Empty states for all list screens

---

## 🔗 RELATED DOCUMENTATION

- **Main Flow:** `/01-Requirements/Main-Flow/Main-Flow.md`
- **Major Features:** `/01-Requirements/Major-Features/Major-Features-Summary.md`
- **Swimlane Diagrams:** `/01-Requirements/Swimlane-Diagram/`
- **Homepage:** `/02-UI-Design/Patient/Patient-Homepage-Enhanced.md`
- **Emergency Flow:** `/02-UI-Design/Patient/Patient-Emergency-Flow-Screens.md`

---

**Last Updated:** December 5, 2025  
**Status:** ✅ Complete  
**Total Screens:** 7 screens

---

## 📊 IMPLEMENTATION NOTES

### Security Considerations:
1. **Medical data** phải encrypted at rest và in transit
2. **Emergency contacts** chỉ accessible khi SOS activated
3. **Payment history** requires authentication
4. **Password change** requires current password verification
5. **Account deletion** requires confirmation + email verification

### Performance Considerations:
1. **Health history** lazy load với pagination
2. **Payment history** cache recent transactions
3. **Profile images** compress before upload
4. **Settings** persist locally for offline access

### Accessibility:
1. All text minimum 16pt for readability
2. High contrast for critical medical info
3. Screen reader support for all form fields
4. Voice input support for emergency contacts

### Analytics Events:
- `profile_viewed`
- `profile_edited`
- `health_history_viewed`
- `payment_history_viewed`
- `emergency_contact_added`
- `emergency_contact_edited`
- `medical_profile_updated`
- `settings_changed`
- `account_deleted`
