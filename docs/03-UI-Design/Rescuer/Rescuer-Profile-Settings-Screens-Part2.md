# PROFILE & SETTINGS SCREENS - UI DESIGN (RESCUER ROLE) - PART 2

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **RESCUER** (Đội cứu hộ rắn)
- **Flow:** Profile & Settings Management (Continued)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 3 screens (Part 2 of 2)
- **Ngày tạo:** December 10, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Profile-Settings-Screens-Part2.md`

> **⚠️ LƯU Ý:** Đây là phần tiếp theo của Part 1. Xem Part 1 cho Profile Overview, Edit Profile, History, và Revenue.

---

## 🎨 Design System Overview

### Color Palette (same as Part 1):
- **Primary Color:** Orange `#FF8A00` (Action, rescue, energy - consistent across all Rescuer flows)
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Danger:** Red `#DC3545`
- **Rating Star:** Gold `#FFD700`

---

## 📱 SCREEN DESIGNS & PROMPTS

---

### Screen 5: Ratings & Reviews Screen

#### Thông tin màn hình:
- **Tên:** Màn hình đánh giá và phản hồi
- **Mục đích:** Xem tất cả đánh giá từ khách hàng và phản hồi
- **Flow position:** Từ Profile Overview → "Đánh Giá & Phản Hồi"
- **Priority:** ⭐⭐⭐ (Cao - Important for reputation)
- **Related Features:** FE-28 (Rating system)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Đánh Giá & Phản Hồi"
   - Filter icon (right) - Filter by rating/date

2. **Overall Rating Card (top):**
   - **Large Rating:** ⭐ 4.8/5.0 (very large, gold)
   - **Total Reviews:** "125 đánh giá"
   - **Distribution Bar Chart:**
     - 5⭐: 85 reviews (green bar, 68%)
     - 4⭐: 30 reviews (light green, 24%)
     - 3⭐: 8 reviews (amber, 6%)
     - 2⭐: 2 reviews (orange, 2%)
     - 1⭐: 0 reviews (red, 0%)

3. **Highlights Section:**
   - **Most Mentioned (tags):**
     - "Nhanh chóng" (95 mentions)
     - "Chuyên nghiệp" (87 mentions)
     - "Thân thiện" (72 mentions)
   - **Response Rate:** "98% đã phản hồi"
   - **Avg Response Time:** "< 2 giờ"

4. **Filter/Sort Tabs:**
   - "Tất cả"
   - "5 sao"
   - "Có bình luận"
   - "Chưa phản hồi"
   - Sort: "Mới nhất" / "Cũ nhất" / "Cao nhất"

5. **Review Cards (scrollable list):**
   Each card shows:
   - **Customer Avatar & Name:** "Nguyễn Văn A"
   - **Rating:** ⭐⭐⭐⭐⭐ (5.0)
   - **Date:** "15 Thg 12, 2025"
   - **Mission ID:** "#RSC-2025-1234" (link to detail)
   - **Review Text:** Full comment from customer
   - **Photos:** (if customer uploaded)
   - **Tags:** "Nhanh chóng", "Chuyên nghiệp"
   - **Rescuer Response:** (if replied)
     - Your avatar + name
     - Response text
     - Response date
   - **Reply Button:** "Phản Hồi" (if not replied yet)

6. **Response Template Suggestions:**
   - Quick replies: "Cảm ơn bạn!", "Rất vui được hỗ trợ", "Hẹn gặp lại"

7. **Stats at Bottom:**
   - Most appreciated quality
   - Improvement suggestions count
   - Repeat customer rate

#### Stitch Prompt (English):

```
Mobile app ratings and reviews screen for rescuer in "SnakeAid". Customer feedback interface with orange (#FF8A00) and gold (#FFD700) accents.

Top navigation: Back arrow left, "Đánh Giá & Phản Hồi" centered bold, filter icon right.

Overall rating card white rounded shadow: Centered large gold star icons (5 stars mostly filled) "4.8" huge bold (36pt) with "/5.0" gray. Below, "125 đánh giá" gray text.

Rating distribution bars: 5 rows, each showing:
- Left: "5⭐" text
- Center: Horizontal bar, green fill 68% width, "85" count inside bar
- Right: "68%" gray
(Repeat for 4⭐ light green 24%, 3⭐ amber 6%, 2⭐ orange 2%, 1⭐ red 0%)

Highlights section white card: Three orange badge chips horizontal: "Nhanh chóng (95)", "Chuyên nghiệp (87)", "Thân thiện (72)". Below, two columns: "98% đã phản hồi" left, "< 2 giờ phản hồi" right, both gray.

Filter tabs horizontal scrollable: "Tất cả" orange underline, "5 sao", "Có bình luận", "Chưa phản hồi" gray. Right aligned dropdown "Mới nhất".

Review cards scrollable: Each white card shadow rounded 12px padding:

CARD LAYOUT:
Top row: Small circular avatar (40px) left, bold dark gray name "Nguyễn Văn A", 5 gold stars right, small gray date "15 Thg 12".

Second row: Small gray link "#RSC-2025-1234" with arrow icon.

Third row: Dark gray review text paragraph "Đội cứu hộ đến rất nhanh, chuyên nghiệp và cẩn thận. Rất hài lòng với dịch vụ!"

Fourth row (if photos): 2-3 small photo thumbnails 80px rounded.

Fifth row: Two orange badge chips "Nhanh chóng" "Chuyên nghiệp".

Divider line light gray.

Response section (if exists): Light blue background rounded padding:
- Small avatar left, bold "Trần Văn Cường" (rescuer), small gray "Đã phản hồi 16 Thg 12"
- Gray text "Cảm ơn anh đã tin tưởng! Rất vui được hỗ trợ."

OR if no response: Outlined orange button "Phản Hồi" right aligned.

Card spacing 12px vertical.

Bottom stats white card: Three columns icons:
- Star icon "Điểm mạnh: Nhanh chóng"
- Comment icon "2 góp ý cải thiện"
- Repeat icon "15% khách quay lại"

Design: Customer feedback management, rating analysis, response tracking, reputation building.
```

#### Notes for Stitch:
- Overall rating VERY prominent với gold stars
- Distribution chart shows strength clearly
- Unanswered reviews highlighted để encourage response
- Quick reply templates save time
- Tags help identify strengths/weaknesses

---

### Screen 6: Equipment & Certification Screen

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý trang thiết bị và chứng chỉ
- **Mục đích:** Quản lý dụng cụ cứu hộ và giấy tờ chứng nhận
- **Flow position:** Từ Profile Overview → "Trang Thiết Bị" / "Chứng Chỉ & Giấy Tờ"
- **Priority:** ⭐⭐⭐ (Important for safety & credibility)
- **Related Features:** FE-25 (Safety guidance)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Trang Thiết Bị & Chứng Chỉ"
   - Add button (top-right, "+" icon)

2. **Tab Selector:**
   - "Trang Thiết Bị" (default)
   - "Chứng Chỉ & Giấy Tờ"

3. **Equipment Section (Tab 1):**

   **Safety Status Banner:**
   - Icon: Shield checkmark (green) / Warning (amber)
   - Text: "Trang thiết bị đầy đủ" / "Cần bổ sung thiết bị"
   - Last updated: "Cập nhật: 10/12/2025"

   **Essential Equipment Checklist:**
   Each item card shows:
   - **Item Name:** "Kìm bắt rắn chuyên dụng"
   - **Status:** Checkbox (green check = have, gray = missing)
   - **Condition:** "Tốt" (green) / "Cần thay" (amber) / "Hỏng" (red)
   - **Last Checked:** "Kiểm tra: 05/12/2025"
   - **Photo:** Optional equipment photo
   - **Notes:** Text area for notes
   - **Actions:** Edit, Replace

   **Equipment Categories:**
   - **Dụng cụ bắt giữ:**
     - Kìm bắt rắn dài (120cm)
     - Móc bắt rắn (90cm)
     - Túi đựng rắn vải bố
     - Hộp nhựa cứng có khóa
   
   - **Bảo hộ cá nhân:**
     - Găng tay da dày chống cắn
     - Ủng cao su cổ cao
     - Kính bảo hộ
     - Áo bảo hộ dài tay
   
   - **Hỗ trợ:**
     - Đèn pin siêu sáng
     - Bình xịt nước (làm mát rắn)
     - Dụng cụ sơ cứu cơ bản
     - Máy ảnh/điện thoại

   **Maintenance Schedule:**
   - Next inspection: "20/12/2025"
   - Maintenance reminders toggle

4. **Certification Section (Tab 2):**

   **Verification Status:**
   - Overall: "Đã xác minh" (green badge) / "Chờ xác minh" (amber)
   - Verified by admin date

   **Document Cards:**
   Each document shows:
   - **Document Type Icon** (ID card, certificate, license)
   - **Document Name:** "CMND/CCCD"
   - **Status Badge:** "Đã xác minh" (green) / "Chờ xác minh" (amber) / "Hết hạn" (red)
   - **ID/Number:** "001234567890"
   - **Issue Date:** "01/01/2020"
   - **Expiry Date:** "01/01/2030" (or "Vô thời hạn")
   - **Thumbnail:** Photo of document
   - **Actions:** View full image, Re-upload, Delete

   **Required Documents:**
   - **CMND/CCCD:** National ID (required)
   - **Giấy phép lao động:** Work permit (optional)
   - **Chứng chỉ sơ cứu:** First aid certificate (recommended)
   - **Chứng chỉ xử lý động vật:** Animal handling cert (recommended)
   - **Giấy khám sức khỏe:** Health certificate (recommended)
   - **Bảo hiểm trách nhiệm:** Liability insurance (optional)

   **Upload Section:**
   - Drag & drop area
   - Camera button: "Chụp ảnh"
   - Gallery button: "Chọn từ thư viện"
   - Guidelines: "Ảnh rõ nét, đầy đủ 4 góc"

5. **Expiry Alerts:**
   - Banner: "2 giấy tờ sắp hết hạn" (amber)
   - Notifications 30 days before expiry

#### Stitch Prompt (English):

```
Mobile app equipment and certification management screen for rescuer in "SnakeAid". Safety and credibility interface with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Trang Thiết Bị & Chứng Chỉ" centered bold, plus icon right.

Tab selector: Two tabs "Trang Thiết Bị" (orange underline selected), "Chứng Chỉ & Giấy Tờ" gray.

TAB 1 - EQUIPMENT:

Safety banner white card: Green shield checkmark icon left, "Trang thiết bị đầy đủ" bold dark gray center, small gray "Cập nhật: 10/12/2025" right.

Section header "Dụng cụ bắt giữ" bold dark gray (18pt).

Equipment cards: Each white card shadow rounded:
- Left: Green checkmark circle (24px) or gray empty circle if missing
- Center vertical: Bold dark gray "Kìm bắt rắn chuyên dụng", small gray "Kiểm tra: 05/12/2025", small green badge "Tốt"
- Right: Small equipment photo thumbnail (60px) rounded

Repeat for 4 items under "Dụng cụ bắt giữ", 4 under "Bảo hộ cá nhân", 4 under "Hỗ trợ".

Bottom card: Calendar icon, "Bảo dưỡng tiếp theo: 20/12/2025" with toggle switch "Nhắc nhở" right.

TAB 2 - CERTIFICATION:

Verification banner: Green verified badge left, "Đã xác minh" bold, "Bởi Admin - 01/12/2025" small gray.

Document cards: Each white card shadow rounded:

CARD LAYOUT:
Left: Large document type icon (48px) - ID card icon orange background.
Center vertical:
- Bold dark gray "CMND/CCCD"
- Small gray "Số: 001234567890"
- Small gray "Cấp: 01/01/2020 • HH: 01/01/2030"
- Small green badge "Đã xác minh"
Right: Document photo thumbnail (80px) rounded, blue "Xem" link below.

Repeat for 6 document types, some with amber "Chờ xác minh" or red "Hết hạn" badges.

Upload section white card dashed border: Cloud upload icon center, "Kéo thả ảnh hoặc" gray text, two buttons horizontal: outlined orange "Chụp ảnh" with camera icon, outlined orange "Chọn từ thư viện" with gallery icon. Below, small gray "Ảnh rõ nét, đầy đủ 4 góc".

Alert banner amber background top (if applicable): Warning icon, "2 giấy tờ sắp hết hạn trong 30 ngày".

Design: Equipment safety tracking, certification verification, document management, expiry monitoring.
```

#### Notes for Stitch:
- Equipment checklist ensures safety compliance
- Condition status prevents using damaged tools
- Document verification builds trust
- Expiry alerts prevent working with invalid docs
- Photo upload easy với camera access

---

### Screen 7: Rescuer Settings Screen

#### Thông tin màn hình:
- **Tên:** Màn hình cài đặt cho Rescuer
- **Mục đích:** Cấu hình preferences, notifications, và app settings
- **Flow position:** Từ Profile Overview → Settings icon
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Cài Đặt"

2. **Account Section:**
   - **Số Điện Thoại:** "+84 987 654 321" (verified)
   - **Email:** "rescuer@example.com"
   - **Mật Khẩu:** "********" → "Đổi mật khẩu" link
   - **Trạng thái tài khoản:** "Đã xác minh" (green badge)

3. **Work Mode Settings:**
   - Toggle: "Chế độ Online tự động khi mở app"
   - Toggle: "Tự động chấp nhận yêu cầu gần" (< 1km)
   - **Bán kính nhận yêu cầu:** Slider (5-50km, current: 20km)
   - **Số yêu cầu tối đa cùng lúc:** Number picker (1-5)
   - Toggle: "Chỉ nhận yêu cầu trong giờ làm việc"

4. **Notification Settings:**
   - Toggle: "Thông báo đẩy" (master switch)
   - Toggle: "Yêu cầu cứu hộ mới" (always ON, disabled)
   - Toggle: "SOS khẩn cấp" (always ON, disabled, red indicator)
   - Toggle: "Tin nhắn từ khách hàng"
   - Toggle: "Tin nhắn từ chuyên gia"
   - Toggle: "Thanh toán & thu nhập"
   - Toggle: "Nhắc nhở bảo dưỡng thiết bị"
   - Toggle: "Đánh giá mới từ khách hàng"
   - **Âm thanh thông báo:** Dropdown (Default / Urgent / Gentle / Silent)
   - **Rung:** Toggle

5. **Navigation & Map Settings:**
   - **Map Provider:** "Google Maps" / "Apple Maps" dropdown
   - Toggle: "Hiển thị giao thông real-time"
   - Toggle: "Tránh đường cao tốc"
   - Toggle: "Tránh đường thu phí"
   - **Giọng nói chỉ đường:** Dropdown (Vietnamese / English)

6. **Privacy & Safety:**
   - Toggle: "Chia sẻ vị trí với khách hàng khi nhận nhiệm vụ"
   - Toggle: "Chia sẻ vị trí với admin"
   - Toggle: "Hiển thị profile công khai"
   - Toggle: "Cho phép khách hàng gọi trực tiếp"
   - Link: "Điều khoản sử dụng"
   - Link: "Chính sách bảo mật"

7. **Financial Settings:**
   - **Phương thức thanh toán:** "Vietcombank ****3456" → "Thay đổi"
   - Toggle: "Tự động rút tiền khi đạt 5,000,000 VNĐ"
   - **Email hóa đơn:** Text input
   - Link: "Chính sách thanh toán"

8. **App Preferences:**
   - **Ngôn ngữ:** "Tiếng Việt" dropdown
   - **Theme:** Segmented control (Sáng / Tối / Tự động)
   - **Đơn vị khoảng cách:** "Kilômét" / "Dặm"
   - **Định dạng tiền tệ:** "VNĐ" / "USD"

9. **Data Management:**
   - Button: "Xuất dữ liệu của tôi"
   - Button: "Xóa bộ nhớ cache" 
   - Text: "Cache: 78 MB"
   - Button: "Đồng bộ dữ liệu offline"

10. **Support & Help:**
    - Link: "Hướng dẫn sử dụng"
    - Link: "Liên hệ hỗ trợ"
    - Link: "Báo cáo sự cố"
    - Link: "Câu hỏi thường gặp"

11. **Account Actions:**
    - Button: "Đăng xuất" (outlined, amber)
    - Button: "Tạm ngừng hoạt động" (outlined, gray)
    - Button: "Xóa tài khoản" (text, red)

12. **App Info (bottom):**
    - Version: "SnakeAid Rescuer v1.0.2"
    - Build: "Build 2025.12.10"
    - Link: "Đánh giá ứng dụng"
    - Link: "Chia sẻ với đồng nghiệp"

#### Stitch Prompt (English):

```
Mobile app comprehensive settings screen for rescuer in "SnakeAid". Professional settings interface with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Cài Đặt" centered bold dark gray.

Scrollable sections with bold dark gray headers (18pt), white cards 16px spacing:

SECTION "Tài Khoản":
- Row: "Số Điện Thoại" gray left, "+84 987 654 321" dark gray right with green checkmark
- Row: "Email" gray left, "rescuer@example.com" dark gray right
- Row: "Mật Khẩu" gray left, "********" gray right, blue "Đổi" link
- Row: "Trạng thái" gray left, green badge "Đã xác minh" right

SECTION "Chế độ Làm Việc":
- "Chế độ Online tự động khi mở app" - green toggle switch right
- "Tự động chấp nhận yêu cầu gần (<1km)" - toggle
- "Bán kính nhận yêu cầu" label, slider below 5-50km with "20km" shown, green fill
- "Số yêu cầu tối đa cùng lúc" label, number picker showing "3"
- "Chỉ nhận yêu cầu trong giờ làm việc" - toggle

SECTION "Thông Báo":
Each row: label left, toggle switch right (orange when on):
- "Thông báo đẩy" - toggle
- "Yêu cầu cứu hộ mới" - toggle ON disabled with lock icon
- "SOS khẩn cấp" - toggle ON disabled with red indicator
- "Tin nhắn từ khách hàng" - toggle
- "Tin nhắn từ chuyên gia" - toggle
- "Thanh toán & thu nhập" - toggle
- "Nhắc nhở bảo dưỡng thiết bị" - toggle
- "Đánh giá mới" - toggle
- Row: "Âm thanh" left, "Urgent" right with dropdown arrow
- "Rung" - toggle

SECTION "Bản Đồ & Điều Hướng":
- Row: "Bản đồ" left, "Google Maps" right dropdown
- "Hiển thị giao thông real-time" - toggle
- "Tránh đường cao tốc" - toggle
- "Tránh đường thu phí" - toggle
- Row: "Giọng nói" left, "Tiếng Việt" right dropdown

SECTION "Quyền Riêng Tư":
- "Chia sẻ vị trí với khách hàng khi nhận nhiệm vụ" - toggle
- "Chia sẻ vị trí với admin" - toggle
- "Hiển thị profile công khai" - toggle
- "Cho phép khách hàng gọi trực tiếp" - toggle
- "Điều khoản sử dụng" - chevron right
- "Chính sách bảo mật" - chevron right

SECTION "Tài Chính":
- Row: "Tài khoản ngân hàng" left, "Vietcombank ****3456" right, blue "Sửa" link
- "Tự động rút tiền khi đạt 5,000,000 VNĐ" - toggle
- Row: "Email hóa đơn" left, text input right
- "Chính sách thanh toán" - chevron right

SECTION "Tùy Chọn":
- Row: "Ngôn ngữ" left, "Tiếng Việt" right dropdown
- Row: "Giao diện" left, three segment buttons "Sáng"|"Tối"|"Tự động" (orange selected)
- Row: "Đơn vị khoảng cách" left, "Kilômét" right dropdown
- Row: "Định dạng tiền" left, "VNĐ" right dropdown

SECTION "Quản Lý Dữ Liệu":
- Outlined gray button "Xuất dữ liệu của tôi" full width
- Outlined gray button "Xóa bộ nhớ cache" full width
- Small gray text "Kích thước: 78 MB" centered
- Outlined gray button "Đồng bộ dữ liệu offline" full width

SECTION "Hỗ Trợ":
- "Hướng dẫn sử dụng" - chevron right
- "Liên hệ hỗ trợ" - chevron right
- "Báo cáo sự cố" - chevron right
- "Câu hỏi thường gặp" - chevron right

SECTION "Tài Khoản":
- Large outlined amber button "Đăng Xuất" full width
- Large outlined gray button "Tạm ngừng hoạt động" full width
- Centered red text link "Xóa tài khoản"

Bottom light gray background: Centered small gray text "SnakeAid Rescuer v1.0.2", "Build 2025.12.10", blue links "Đánh giá ứng dụng" | "Chia sẻ".

Design: Comprehensive rescuer settings, work mode control, notification management, privacy control, financial setup.
```

#### Notes for Stitch:
- SOS và rescue request notifications MUST stay ON
- Auto-accept feature risky, needs confirmation
- Work radius critical for matching algorithm
- Location sharing important for customer tracking
- Auto-withdrawal convenient for busy rescuers

---

## 🔗 COMPLETE NAVIGATION FLOW (Part 1 + Part 2)

```
Rescuer Profile Overview (Part 1, Screen 1)
    │
    ├─→ Edit Profile (Part 1, Screen 2)
    │   └─→ Save → Back
    │
    ├─→ Rescue History (Part 1, Screen 3)
    │   └─→ Mission Detail
    │
    ├─→ Revenue Management (Part 1, Screen 4)
    │   ├─→ Withdraw Money
    │   └─→ View Transactions
    │
    ├─→ Ratings & Reviews (Part 2, Screen 5)
    │   ├─→ Reply to Review
    │   └─→ View Customer Profile
    │
    ├─→ Equipment & Certification (Part 2, Screen 6)
    │   ├─→ Add Equipment
    │   ├─→ Upload Document
    │   └─→ View Full Image
    │
    └─→ Settings (Part 2, Screen 7)
        ├─→ Change Password
        ├─→ Edit Bank Account
        ├─→ Privacy Policy
        └─→ Logout / Suspend / Delete Account
```

---

## 📋 COMPLETE FEATURE MAPPING

| Screen | Related Major Features | Priority |
|--------|------------------------|----------|
| **Part 1:** | | |
| Profile Overview | FE-25, FE-26, FE-28 | ⭐⭐⭐ |
| Edit Profile | FE-25 | ⭐⭐⭐ |
| Rescue History | FE-15, FE-25 | ⭐⭐⭐ |
| Revenue Management | FE-26, FE-27 | ⭐⭐⭐ |
| **Part 2:** | | |
| Ratings & Reviews | FE-28 | ⭐⭐⭐ |
| Equipment & Certification | FE-25 (Safety) | ⭐⭐⭐ |
| Settings | App preferences | ⭐⭐⭐ |

---

## ✅ COMPLETE DESIGN CHECKLIST

### Part 1 Screens:
- [x] Online/Offline toggle prominent
- [x] Rating and stats displayed
- [x] Revenue tracking clear
- [x] Service area mapping
- [x] Mission history detailed
- [x] Earnings visible per mission

### Part 2 Screens:
- [ ] Rating distribution chart clear
- [ ] Response to reviews easy
- [ ] Equipment checklist comprehensive
- [ ] Document verification status clear
- [ ] Expiry alerts functional
- [ ] Work mode settings flexible
- [ ] Critical notifications always ON
- [ ] Privacy controls accessible
- [ ] Auto-withdrawal configurable
- [ ] Support resources easy to find

---

## 🔧 IMPLEMENTATION NOTES

### Security Considerations:
1. **Documents** must be encrypted and verified by admin
2. **Bank account details** require authentication to change
3. **Auto-accept** feature needs safety limits (distance, time)
4. **Location sharing** only when on active mission
5. **Password change** requires current password

### Performance Considerations:
1. **Rescue history** paginated (20 per page)
2. **Reviews** lazy load with infinite scroll
3. **Equipment photos** compressed before upload
4. **Document images** OCR for auto-fill data
5. **Settings** cached locally

### Safety Features:
1. **Equipment expiry reminders** via push notification
2. **Document expiry alerts** 30 days before
3. **Auto-suspend** if critical docs expire
4. **SOS notifications** cannot be disabled
5. **Emergency contacts** for rescuer (if injured on job)

### Business Logic:
1. **Auto-accept radius** max 5km for safety
2. **Max concurrent missions** = 3 to ensure quality
3. **Response time** tracked for ranking
4. **Review response** improves ranking
5. **Equipment verification** required every 3 months

### Analytics Events:
- `rescuer_profile_viewed`
- `rescuer_profile_edited`
- `rescue_history_viewed`
- `revenue_viewed`
- `withdrawal_requested`
- `rating_viewed`
- `review_responded`
- `equipment_updated`
- `document_uploaded`
- `settings_changed`
- `work_mode_toggled`
- `auto_accept_enabled`

---

## 🎯 KEY DIFFERENCES FROM PATIENT ROLE

| Aspect | Patient | Rescuer |
|--------|---------|---------|
| **Primary Focus** | Safety & Health | Income & Performance |
| **Critical Toggle** | Emergency Contacts | Online/Offline Status |
| **Financial** | Payment History (spending) | Revenue Management (earning) |
| **Documents** | Medical Profile + Insurance | Equipment + Certifications |
| **Ratings** | View experts/rescuers | Receive from patients |
| **Location** | Share when emergency | Share when on mission |
| **Notifications** | Health alerts | Job requests (cannot disable) |
| **Work Schedule** | N/A | Required for availability |
| **Service Area** | N/A | Critical for job matching |

---

## 🔗 RELATED DOCUMENTATION

- **Part 1:** `/02-UI-Design/Rescuer/Rescuer-Profile-Settings-Screens-Part1.md`
- **Main Flow:** `/01-Requirements/Main-Flow/Main-Flow.md` (Flow 2.2, 2.3, 2.4)
- **Major Features:** `/01-Requirements/Major-Features/Major-Features-Summary.md`
- **Swimlane Diagrams:** `/01-Requirements/Swimlane-Diagram/02-Swimlane-Rescue-Request-Flow.md`
- **Patient Profile:** `/02-UI-Design/Patient/Patient-Profile-Settings-Screens.md`

---

**Last Updated:** December 10, 2025  
**Status:** ✅ Complete  
**Total Screens in Part 2:** 3 screens  
**Total Screens (Part 1 + Part 2):** 7 screens

---

## 📊 SUMMARY

### Complete Rescuer Profile & Settings Module:
1. ✅ **Profile Overview** - Stats, rating, revenue summary
2. ✅ **Edit Profile** - Personal info, expertise, service area
3. ✅ **Rescue History** - Mission records, earnings, timeline
4. ✅ **Revenue Management** - Balance, withdrawals, transactions
5. ✅ **Ratings & Reviews** - Customer feedback, response tracking
6. ✅ **Equipment & Certification** - Safety tools, documents verification
7. ✅ **Settings** - Work mode, notifications, privacy, preferences

### Design Philosophy:
- **Professional First:** Clean, credible interface for service providers
- **Income Focused:** Revenue tracking prominent throughout
- **Safety Critical:** Equipment and certification management essential
- **Performance Driven:** Stats and ratings build reputation
- **Availability Control:** Online/offline toggle with smart automation
- **Customer Trust:** Reviews and response management key to success

### Technical Priorities:
1. Real-time status updates (online/offline)
2. GPS accuracy for service area
3. Fast document verification flow
4. Secure payment processing
5. Push notifications reliability
6. Offline mode for settings

---

**🎉 Document hoàn tất! Rescuer Profile & Settings UI Design đã cover đầy đủ 7 màn hình.**
