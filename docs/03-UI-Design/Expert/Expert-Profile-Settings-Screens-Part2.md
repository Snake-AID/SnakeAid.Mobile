# EXPERT PROFILE & SETTINGS - UI DESIGN SCREENS (PART 2)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Expert Mobile Application
- **Role:** 👨‍⚕️ **EXPERT** (Chuyên gia rắn độc)
- **Flow:** Profile & Settings Management
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Part:** 2 of 2 (Screen 5: Settings)
- **Ngày tạo:** December 15, 2025
- **Location:** `/02-UI-Design/Expert/Expert-Profile-Settings-Screens-Part2.md`

> **⚠️ LƯU Ý:** Document này là **Part 2** covering Settings screen only.
> **Part 1** covers Profile Overview, Edit Profile, Certificates, và Specialization (Screens 1-4).

---

## 🎨 Design System Overview (Expert Module)

### Color Palette:
- **Primary Color:** Purple `#6B46C1` (Expert signature color)
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Danger:** Red `#DC3545`

### Typography:
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)

---

## 📱 SCREEN DESIGN (PART 2)

---

### Screen 5: Expert Settings

#### Thông tin màn hình:
- **Tên:** Màn hình cài đặt chuyên gia (comprehensive)
- **Mục đích:** Tập hợp tất cả settings cho Expert: account, availability, fees, notifications, payment, privacy, support
- **Flow position:** Từ Screen 1 (Profile Overview) menu hoặc settings icon
- **Priority:** ⭐⭐⭐ (Cao nhất)
- **Related Features:** FE-13 (Set consultation fees), All app preferences

#### Key Components:

1. **Header:**
   - Back button
   - Title: "Cài Đặt"
   - No additional actions

2. **Account Section:**
   - Section title: "Tài Khoản"
   - Items (each is tappable row):
     - **Số điện thoại**
       - Display: "0912 345 678"
       - Right side: Green verified badge + chevron
     - **Email**
       - Display: "expert@example.com"
       - Right side: Green verified badge + chevron
     - **Mật khẩu**
       - Display: "••••••••"
       - Right side: Chevron
     - **Trạng thái xác minh**
       - Display: "Đã xác minh đầy đủ"
       - Right side: Green checkmark + chevron

3. **Availability Schedule Section:**
   - Section title: "Lịch Làm Việc"
   - Subtitle: "Đặt thời gian sẵn sàng nhận tư vấn đặt lịch"
   - **Weekly Schedule Grid:**
     - 7 rows (Mon-Sun)
     - Each row:
       - Day name: "Thứ 2"
       - Toggle switch (on/off)
       - Time slots: "8:00 - 17:00" (tappable to edit)
     - Example:
       - ✓ Thứ 2: **8:00 - 17:00** (toggle on, purple)
       - ✓ Thứ 3: **8:00 - 17:00**
       - ✓ Thứ 4: **9:00 - 18:00**
       - ✗ Thứ 5: (toggle off, gray)
       - ✓ Thứ 6: **8:00 - 12:00**
       - ✗ Thứ 7: (off)
       - ✗ Chủ Nhật: (off)
   - Note: "Thời gian theo múi giờ ICT (GMT+7)"

4. **Consultation Fees Section (FE-13):**
   - Section title: "Phí Tư Vấn"
   - Items:
     - **Tư vấn đặt lịch (Patient)**
       - Display: "300,000 VNĐ" (editable)
       - Subtitle: "Bạn nhận: 270,000 VNĐ (90%)"
       - Right side: Edit icon + chevron
     - **Tư vấn khẩn cấp (SOS Patient)**
       - Display: "500,000 VNĐ" (fixed by platform)
       - Subtitle: "Bạn nhận: 450,000 VNĐ (90%)"
       - Right side: Info icon (non-editable)
     - **Hỗ trợ Rescuer**
       - Display: "50,000 VNĐ" (fixed by platform)
       - Subtitle: "Từ phần chia sẻ của Rescuer"
       - Right side: Info icon
   - Info box: "Phí nền tảng 10% áp dụng cho tất cả dịch vụ"

5. **Notifications Section:**
   - Section title: "Thông Báo"
   - Items (each has toggle switch):
     - ✓ **Yêu cầu tư vấn mới** (on, purple)
       - Subtitle: "Thông báo khi có yêu cầu tư vấn đặt lịch"
     - ✓ **Tư vấn SOS khẩn cấp** (on)
       - Subtitle: "Thông báo ưu tiên cao từ Patient"
     - ✓ **Hỗ trợ Rescuer** (on)
       - Subtitle: "Yêu cầu hỗ trợ từ đội cứu hộ"
     - ✓ **Tin nhắn mới** (on)
       - Subtitle: "Tin nhắn từ Patient và Rescuer"
     - ✓ **Thanh toán** (on)
       - Subtitle: "Thông báo về doanh thu và rút tiền"
     - ✓ **Đánh giá mới** (on)
       - Subtitle: "Khi nhận được đánh giá từ khách hàng"
     - ✗ **Email marketing** (off)
       - Subtitle: "Tin tức và khuyến mãi từ SnakeAid"

6. **Payment Methods Section:**
   - Section title: "Phương Thức Thanh Toán"
   - Subtitle: "Để nhận doanh thu từ tư vấn"
   - Items:
     - **Tài khoản ngân hàng**
       - Display: "Vietcombank - •••• 6789"
       - Right side: Primary badge + chevron
     - Button: "+ Thêm Tài Khoản Ngân Hàng"

7. **Privacy & Security Section:**
   - Section title: "Quyền Riêng Tư & Bảo Mật"
   - Items (each tappable or toggle):
     - ✓ **Hiển thị hồ sơ công khai** (toggle on)
       - Subtitle: "Cho phép Patient xem hồ sơ và rating"
     - ✗ **Cho phép gọi trực tiếp** (toggle off)
       - Subtitle: "Patient có thể gọi số điện thoại của bạn"
     - **Điều khoản sử dụng** (chevron)
     - **Chính sách quyền riêng tư** (chevron)

8. **Preferences Section:**
   - Section title: "Tùy Chọn"
   - Items:
     - **Ngôn ngữ**
       - Display: "Tiếng Việt"
       - Right side: Chevron
     - **Giao diện**
       - Display: "Sáng (Light)"
       - Right side: Chevron
     - **Múi giờ**
       - Display: "ICT (GMT+7)"
       - Right side: Chevron

9. **Data Management Section:**
   - Section title: "Quản Lý Dữ Liệu"
   - Items:
     - **Xuất dữ liệu** (chevron)
       - Subtitle: "Tải xuống dữ liệu cá nhân"
     - **Xóa bộ nhớ đệm** (chevron)
       - Subtitle: "Giải phóng 234 MB"
     - **Đồng bộ offline** (toggle)
       - Subtitle: "Cho phép truy cập một số dữ liệu offline"

10. **Support & Help Section:**
    - Section title: "Hỗ Trợ"
    - Items:
      - **Hướng dẫn sử dụng** (chevron)
      - **Liên hệ hỗ trợ** (chevron)
        - Subtitle: "Email hoặc chat với team support"
      - **Báo cáo sự cố** (chevron)
      - **Câu hỏi thường gặp (FAQ)** (chevron)

11. **About Section:**
    - Section title: "Thông Tin Ứng Dụng"
    - Items:
      - **Phiên bản**
        - Display: "1.2.5 (Build 125)"
        - Right side: "Mới nhất" badge (green)
      - **Đánh giá ứng dụng** (chevron with star icon)
      - **Chia sẻ ứng dụng** (chevron with share icon)

12. **Account Actions Section:**
    - Section title: "Hành Động Tài Khoản"
    - Items:
      - **Đăng xuất** (purple text, chevron)
      - **Tạm ngưng hoạt động** (amber text, chevron)
        - Subtitle: "Tạm thời không nhận yêu cầu tư vấn"
      - **Xóa tài khoản** (red text, chevron)
        - Subtitle: "Xóa vĩnh viễn tất cả dữ liệu"

#### Stitch Prompt (English):

```
Mobile app comprehensive settings screen for expert in app "SnakeAid". Long scrollable settings interface with purple (#6B46C1) primary color.

Top navigation: Back arrow left, centered title "Cài Đặt".

SECTION 1 - "Tài Khoản" header in dark gray bold:
White card with 4 rows (divider lines between):
- Row 1: "Số điện thoại" left, "0912 345 678" gray center, green verified badge + chevron right
- Row 2: "Email" left, "expert@example.com" gray center, green badge + chevron right
- Row 3: "Mật khẩu" left, "••••••••" gray center, chevron right
- Row 4: "Trạng thái xác minh" left, "Đã xác minh đầy đủ" gray center, green checkmark + chevron right

SECTION 2 - "Lịch Làm Việc" header. Subtitle "Đặt thời gian sẵn sàng nhận tư vấn đặt lịch" gray.
White card with 7 rows (day schedule):
- Row 1: "Thứ 2" left, purple toggle ON, "8:00 - 17:00" purple text right
- Row 2: "Thứ 3" left, purple toggle ON, "8:00 - 17:00" right
- Row 3: "Thứ 4" left, purple toggle ON, "9:00 - 18:00" right
- Row 4: "Thứ 5" left, gray toggle OFF, no time shown
- Row 5: "Thứ 6" left, purple toggle ON, "8:00 - 12:00" right
- Row 6: "Thứ 7" left, gray toggle OFF
- Row 7: "Chủ Nhật" left, gray toggle OFF
Small gray text below card: "Thời gian theo múi giờ ICT (GMT+7)"

SECTION 3 - "Phí Tư Vấn" header:
White card with 3 rows:
- Row 1: "Tư vấn đặt lịch (Patient)" left bold, "300,000 VNĐ" purple right. Below left, gray text "Bạn nhận: 270,000 VNĐ (90%)". Edit icon + chevron far right.
- Row 2: "Tư vấn khẩn cấp (SOS Patient)" bold, "500,000 VNĐ" purple. Below, gray "Bạn nhận: 450,000 VNĐ (90%)". Info icon right (no edit).
- Row 3: "Hỗ trợ Rescuer" bold, "50,000 VNĐ" purple. Below, gray "Từ phần chia sẻ của Rescuer". Info icon right.
Light purple info box below: "Phí nền tảng 10% áp dụng cho tất cả dịch vụ"

SECTION 4 - "Thông Báo" header:
White card with 7 toggle rows:
- Row 1: "Yêu cầu tư vấn mới" bold, purple toggle ON right. Below, gray subtitle.
- Row 2: "Tư vấn SOS khẩn cấp" bold, purple toggle ON. Below, gray subtitle.
- Row 3: "Hỗ trợ Rescuer" bold, purple toggle ON. Below, gray subtitle.
- Row 4: "Tin nhắn mới" bold, purple toggle ON. Below, gray subtitle.
- Row 5: "Thanh toán" bold, purple toggle ON. Below, gray subtitle.
- Row 6: "Đánh giá mới" bold, purple toggle ON. Below, gray subtitle.
- Row 7: "Email marketing" bold, gray toggle OFF. Below, gray subtitle.

SECTION 5 - "Phương Thức Thanh Toán" header. Subtitle gray.
White card with 1 row:
- "Tài khoản ngân hàng" left bold, "Vietcombank - •••• 6789" gray center, small purple badge "Chính" + chevron right.
Below card: Purple outlined button "+ Thêm Tài Khoản Ngân Hàng"

SECTION 6 - "Quyền Riêng Tư & Bảo Mật" header:
White card with 4 rows:
- Row 1: "Hiển thị hồ sơ công khai" bold, purple toggle ON right. Subtitle below.
- Row 2: "Cho phép gọi trực tiếp" bold, gray toggle OFF right. Subtitle below.
- Row 3: "Điều khoản sử dụng" bold, chevron right.
- Row 4: "Chính sách quyền riêng tư" bold, chevron right.

SECTION 7 - "Tùy Chọn" header:
White card with 3 rows:
- Row 1: "Ngôn ngữ" left, "Tiếng Việt" gray right, chevron
- Row 2: "Giao diện" left, "Sáng (Light)" gray right, chevron
- Row 3: "Múi giờ" left, "ICT (GMT+7)" gray right, chevron

SECTION 8 - "Quản Lý Dữ Liệu" header:
White card with 3 rows:
- Row 1: "Xuất dữ liệu" bold, chevron right. Gray subtitle below.
- Row 2: "Xóa bộ nhớ đệm" bold, chevron right. Gray "Giải phóng 234 MB" below.
- Row 3: "Đồng bộ offline" bold, purple toggle ON right. Subtitle below.

SECTION 9 - "Hỗ Trợ" header:
White card with 4 rows:
- Row 1: "Hướng dẫn sử dụng" bold, chevron right
- Row 2: "Liên hệ hỗ trợ" bold, chevron right. Gray subtitle below.
- Row 3: "Báo cáo sự cố" bold, chevron right
- Row 4: "Câu hỏi thường gặp (FAQ)" bold, chevron right

SECTION 10 - "Thông Tin Ứng Dụng" header:
White card with 3 rows:
- Row 1: "Phiên bản" left, "1.2.5 (Build 125)" gray center, small green badge "Mới nhất" right
- Row 2: "Đánh giá ứng dụng" bold, star icon + chevron right
- Row 3: "Chia sẻ ứng dụng" bold, share icon + chevron right

SECTION 11 - "Hành Động Tài Khoản" header:
White card with 3 rows (more spacing between):
- Row 1: "Đăng xuất" in purple text bold, chevron right
- Row 2: "Tạm ngưng hoạt động" in amber text bold, chevron right. Gray subtitle below.
- Row 3: "Xóa tài khoản" in red text bold, chevron right. Gray subtitle below.

Design: Comprehensive settings interface, grouped sections with clear headers, toggle switches for quick actions, chevrons for navigation, color-coded account actions.
```

#### Notes for Stitch:
- Long scrollable screen - nhiều sections
- Section headers phải có consistent typography (bold, dark gray)
- Toggle switches phải purple when ON, gray when OFF
- Availability schedule: days with toggle ON show purple time slots, OFF shows gray
- Fee section: editable items có edit icon, fixed items có info icon
- Account actions phải color-coded: purple (logout), amber (pause), red (delete)
- Each row trong card phải có minimum 56px height cho touch target
- Divider lines between rows phải subtle (light gray)
- Info boxes phải light purple background (#F3E8FF)
- Verified badges phải green với checkmark
- Primary badge cho payment method phải purple

---

## 📋 SUMMARY - PART 2

### Screen đã thiết kế trong Part 2:

✅ **Settings Screen (1 comprehensive screen):**
- **Screen 5: Expert Settings** - All-in-one settings covering:
  - Account management (phone, email, password, verification)
  - Availability schedule (7-day weekly time slots)
  - Consultation fees (FE-13: Scheduled 300K, SOS 500K, Rescuer Support 50K)
  - Notifications (7 types with toggles)
  - Payment methods (bank account management)
  - Privacy & security (profile visibility, call permission, terms)
  - Preferences (language, theme, timezone)
  - Data management (export, cache, offline sync)
  - Support & help (guide, contact, FAQ, report)
  - App info (version, rate, share)
  - Account actions (logout, pause, delete)

### Key Features Covered:
- **FE-13:** Thiết lập mức phí tư vấn trực tuyến (editable for scheduled, display-only for SOS/Rescuer)
- **Availability Management:** Weekly schedule grid với toggle per day và time range
- **Notification Control:** Granular control cho 7 notification types
- **Payment Integration:** Bank account management cho revenue withdrawal
- **Privacy Controls:** Profile visibility và direct call permission
- **Account Safety:** Clear separation của logout (purple), pause (amber), delete (red)

### Design Principles Applied:
1. **Grouped Organization** - 11 logical sections với clear headers
2. **Action Clarity** - Toggle switches cho quick actions, chevrons cho navigation
3. **Visual Hierarchy** - Section titles bold, row items clear, subtitles gray
4. **Color Coding** - Purple (primary), Green (verified/success), Amber (warning), Red (danger)
5. **Touch Optimization** - Minimum 56px height cho all tappable items
6. **Safety First** - Destructive actions (delete) ở bottom với red color warning

---

## 📋 COMPLETE EXPERT PROFILE & SETTINGS DOCUMENTATION

### All 5 Screens (Part 1 + Part 2):

✅ **Part 1 - Profile Overview & Management:**
1. Expert Profile Overview - Entry point với stats, revenue, menu
2. Edit Expert Profile - Personal and professional info editing
3. Certificates & Credentials - Document management with verification
4. Specialization Management - Snake species, regions, protocols

✅ **Part 2 - Settings:**
5. Expert Settings - Comprehensive all-in-one settings screen

### Complete Feature Coverage:

**Profile Management:**
- ✅ Personal info (name, phone, email, DOB, gender, address, ID)
- ✅ Professional info (title, experience, specialization, bio, languages)
- ✅ Avatar management
- ✅ Verification status display

**Credentials & Trust:**
- ✅ Document upload và verification (CMND, Medical licenses, Certifications, Permits)
- ✅ Status tracking (Verified/Pending/Expired)
- ✅ Expiry date management

**Specialization:**
- ✅ Snake species selection với proficiency levels (Expert/Advanced/Basic)
- ✅ Geographic regions selection
- ✅ Treatment protocols selection
- ✅ Minimum requirements validation (3 snakes)

**Consultation Management:**
- ✅ FE-13: Set consultation fees (scheduled consultations)
- ✅ Display fixed fees (SOS, Rescuer Support)
- ✅ Availability schedule (7-day weekly grid với time slots)
- ✅ Availability toggle (on/off instantly)

**Revenue & Payment:**
- ✅ Revenue summary (monthly, growth indicator)
- ✅ Link to detailed revenue management
- ✅ Bank account management
- ✅ Platform fee transparency (10%)

**Notifications:**
- ✅ Granular control (7 types)
- ✅ Priority notifications (SOS consultations)
- ✅ Marketing opt-out

**Privacy & Security:**
- ✅ Profile visibility control
- ✅ Direct call permission
- ✅ Terms and privacy policy access

**App Preferences:**
- ✅ Language selection
- ✅ Theme (Light/Dark)
- ✅ Timezone

**Data & Support:**
- ✅ Data export
- ✅ Cache management
- ✅ Offline sync
- ✅ User guide và FAQ
- ✅ Support contact
- ✅ Issue reporting

**Account Actions:**
- ✅ Logout (safe, purple)
- ✅ Pause activity (temporary, amber)
- ✅ Delete account (permanent, red)

---

## 🔗 RELATED DOCUMENTATION

**Expert UI Complete Suite:**
- ✅ Expert-Dashboard-Screens.md (4 screens) - Revenue overview, stats, charts
- ✅ Expert-Consultation-Flow-Screens.md (8 screens) - SOS, Rescuer Support, Scheduled consultations
- ✅ Expert-Revenue-Management-Screens.md (5 screens) - Revenue tracking, transactions, withdrawals
- ✅ Expert-Profile-Settings-Screens-Part1.md (4 screens) - Profile, Edit, Certificates, Specialization
- ✅ Expert-Profile-Settings-Screens-Part2.md (1 screen) - Settings

**Total Expert Screens:** 22 screens covering all Expert module features (FE-01 to FE-16)

**Payment Flow Documentation:**
- Payment-Flow-Detail.md - 4 payment flows including Expert consultation (270K/450K/50K)
- Payment-Flow-Summary.md - Quick reference
- Service-Pricing-Strategy.md - Market-validated pricing

**Feature Reference:**
- Major-Features-Summary.md - Expert features FE-01 to FE-16
- Main-Flow.md - Expert role in overall system
- Swimlane diagrams - Expert consultation flows

---

## 📝 IMPLEMENTATION NOTES FOR DEVELOPERS

### API Integration Points:
- `GET /api/expert/settings` - Retrieve all settings
- `PUT /api/expert/settings/account` - Update account info
- `PUT /api/expert/settings/availability` - Update weekly schedule
- `PUT /api/expert/settings/fees` - Update consultation fees (scheduled only)
- `PUT /api/expert/settings/notifications` - Update notification preferences
- `POST /api/expert/settings/payment-method` - Add bank account
- `PUT /api/expert/settings/privacy` - Update privacy settings
- `PUT /api/expert/settings/preferences` - Update language/theme/timezone
- `POST /api/expert/data/export` - Request data export
- `DELETE /api/expert/cache` - Clear cache
- `POST /api/expert/account/logout` - Logout
- `PUT /api/expert/account/pause` - Pause activity
- `DELETE /api/expert/account` - Delete account (requires confirmation)

### Settings Validation Rules:
- **Availability:** At least one day must be enabled
- **Time slots:** Valid format HH:MM, start time < end time
- **Consultation fees:** Scheduled fee can be edited (min 200K, max 500K), others are display-only
- **Bank account:** Valid account number, bank name required
- **Notifications:** At least "Consultation requests" must be enabled
- **Language:** At least one language required

### Data Persistence:
- Settings saved immediately on toggle switches
- Text inputs save on "Lưu" button
- Availability schedule saves immediately per day toggle or time change
- Payment method requires explicit save action

### Security Considerations:
- Password change requires current password verification
- Delete account requires email/SMS confirmation
- Pause activity is reversible, delete is permanent
- Data export includes 7-day processing time
- Bank account info encrypted at rest

### Notification System:
- **Consultation requests:** High priority, sound + vibration
- **SOS Patient:** Highest priority, persistent alert until acknowledged
- **Rescuer Support:** High priority, 2-minute timeout
- **Messages:** Normal priority
- **Payment/Rating:** Low priority, silent
- **Marketing:** Opt-out respected system-wide

---

## ✅ CHECKLIST FOR STITCH IMPLEMENTATION

### Before generating with Stitch:

- [x] Review all 5 screen prompts (4 from Part 1 + 1 from Part 2)
- [x] Confirm purple color scheme (#6B46C1) throughout
- [x] Verify all text content accurate (Vietnamese)
- [x] Check consultation fees: 300K (editable), 500K (fixed), 50K (fixed)
- [x] Ensure weekly schedule grid is clear (7 days với toggles và times)
- [x] Validate all toggle switches have ON/OFF states
- [x] Confirm account actions color-coded: purple (logout), amber (pause), red (delete)

### After Stitch generates designs:

- [ ] Verify purple color consistency (#6B46C1)
- [ ] Check toggle switches: purple (ON), gray (OFF)
- [ ] Validate weekly schedule: enabled days show purple times
- [ ] Verify consultation fees section: edit icon (scheduled), info icon (SOS/Rescuer)
- [ ] Check divider lines between rows are subtle
- [ ] Validate touch targets minimum 56px height
- [ ] Verify section headers bold and consistent
- [ ] Check account actions properly color-coded
- [ ] Validate verified badges are green with checkmarks
- [ ] Ensure info boxes have light purple background

---

**Document Status:** ✅ Complete - Part 2 of 2  
**Role Coverage:** 👨‍⚕️ **EXPERT** (Settings)
**Screens Covered:** 1 comprehensive settings screen
**Complete Suite:** 5 screens total (Part 1: 4 screens + Part 2: 1 screen)
**Last Updated:** December 15, 2025

---

**🎉 EXPERT PROFILE & SETTINGS DOCUMENTATION COMPLETE!**

All 5 screens designed and documented with full Stitch prompts ready for implementation. Expert UI documentation suite is now complete with 22 total screens covering all features from FE-01 to FE-16.
