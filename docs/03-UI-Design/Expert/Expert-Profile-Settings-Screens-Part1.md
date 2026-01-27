# EXPERT PROFILE & SETTINGS - UI DESIGN SCREENS (PART 1)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Expert Mobile Application
- **Role:** 👨‍⚕️ **EXPERT** (Chuyên gia rắn độc)
- **Flow:** Profile & Settings Management
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Part:** 1 of 2 (Screens 1-4: Profile Overview & Management)
- **Ngày tạo:** December 15, 2025
- **Location:** `/02-UI-Design/Expert/Expert-Profile-Settings-Screens-Part1.md`

> **⚠️ LƯU Ý:** Document này là **Part 1** covering 4 screens chính về Profile Overview & Management.
> **Part 2** sẽ cover Settings screen (1 screen).

---

## 🎨 Design System Overview (Expert Module)

### Color Palette:
- **Primary Color:** Purple `#6B46C1` (Expert signature color)
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Info:** Blue `#007BFF`
- **Accent - Error:** Red `#DC3545`

### Typography:
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)

### Component Style:
- **Cards:** Rounded corners (12px), subtle shadow
- **Buttons:** Rounded (8px), clear hierarchy (Primary/Secondary)
- **Input Fields:** Outlined style, rounded (8px)
- **Professional medical interface style**

---

## 📋 FEATURE REFERENCE

### Expert Module Features (Major-Features-Summary.md):

**Xác minh dữ liệu (FE-01 to FE-03):**
- FE-01: Xác nhận loài rắn từ hình ảnh/mô tả
- FE-02: Sửa đổi kết quả AI nếu nhận diện sai
- FE-03: Thêm ghi chú chuyên môn

**Hỗ trợ AI (FE-04 to FE-06):**
- FE-04: Sử dụng AI để rút ngắn thời gian xác minh
- FE-05: Kiểm tra và phê duyệt kết quả AI
- FE-06: Đào tạo và cải thiện mô hình AI

**Cập nhật hướng dẫn (FE-07 to FE-09):**
- FE-07: Cập nhật quy trình xử lý theo loài rắn
- FE-08: Biên soạn hướng dẫn triệu chứng và xử lý nọc
- FE-09: Cung cấp thông tin liều lượng huyết thanh

**Tư vấn từ xa (FE-10 to FE-12):**
- FE-10: Hỗ trợ trực tuyến cho bệnh nhân
- FE-11: Tư vấn cho đội cứu hộ
- FE-12: Đánh giá tình trạng và khuyến nghị

**Quản lý doanh thu (FE-13 to FE-16):**
- FE-13: Thiết lập mức phí tư vấn trực tuyến
- FE-14: Nhận thanh toán qua nền tảng và xuất hóa đơn điện tử
- FE-15: Xem báo cáo doanh thu theo tháng/quý
- FE-16: Theo dõi số lượt tư vấn và đánh giá từ khách hàng

> **Note:** Features FE-13 to FE-16 được cover trong Expert-Revenue-Management-Screens.md và Expert-Dashboard-Screens.md.
> Part 1 này focus vào profile management (FE-01 to FE-12).

---

## 📱 SCREEN DESIGNS & PROMPTS (PART 1)

---

### Screen 1: Expert Profile Overview

#### Thông tin màn hình:
- **Tên:** Màn hình tổng quan hồ sơ chuyên gia
- **Mục đích:** Hiển thị thông tin tổng quan về Expert với các chỉ số công việc và menu điều hướng
- **Flow position:** Entry point từ bottom navigation "Profile"
- **Priority:** ⭐⭐⭐ (Cao nhất)
- **Related Features:** FE-01 to FE-16 (All features accessible from here)

#### Key Components:
1. **Header:**
   - Title: "Hồ Sơ Chuyên Gia"
   - Edit button (top-right) → leads to Screen 2
   - Settings icon (top-right) → leads to Part 2 Screen 5

2. **Profile Card:**
   - Large circular avatar (80px) - editable
   - Expert name (bold, large)
   - Verification badge: "Chuyên Gia Đã Xác Minh" (purple badge with checkmark)
   - Specialization tags: "Rắn Độc", "Huyết Thanh", "Y Khoa" (small purple pills)
   - Star rating: "4.9 ⭐" with review count "(125 đánh giá)"
   - Member since: "Thành viên từ tháng 3/2024"

3. **Quick Stats Section (3 columns):**
   - **Card 1: Xác Minh**
     - Large number: "234" (verifications completed)
     - Label: "Xác Minh Hoàn Tất"
     - Icon: Checkmark in circle
   
   - **Card 2: Tư Vấn**
     - Large number: "189" (consultations done)
     - Label: "Ca Tư Vấn"
     - Icon: Message or video icon
   
   - **Card 3: Đóng Góp AI**
     - Large number: "567" (AI training contributions)
     - Label: "Đóng Góp AI"
     - Icon: Brain or robot icon

4. **Revenue Summary Card:**
   - Title: "Doanh Thu Tháng Này"
   - Large amount: "4.26M VNĐ" (purple color)
   - Growth indicator: "+15% so với tháng trước" (green)
   - Small chart/graph preview (optional)
   - Button: "Xem Chi Tiết →" (leads to Revenue Management screens)

5. **Menu Items (List):**
   - "📋 Lịch Sử Tư Vấn" (Consultation history)
   - "💰 Quản Lý Doanh Thu" (Revenue management) → Expert-Revenue-Management
   - "⭐ Đánh Giá & Phản Hồi" (Ratings & reviews)
   - "📜 Chứng Chỉ & Bằng Cấp" → Screen 3
   - "🎯 Chuyên Môn & Lĩnh Vực" → Screen 4
   - "⚙️ Cài Đặt" → Part 2 Screen 5

6. **Availability Toggle:**
   - Large toggle switch at bottom
   - Label: "Sẵn Sàng Nhận Tư Vấn"
   - Status text: "Đang bật - Bạn sẽ nhận được yêu cầu tư vấn" (green text)

#### Stitch Prompt (English):

```
Mobile app profile overview screen for expert in snake rescue app "SnakeAid". Professional medical interface with purple (#6B46C1) primary color on white background.

Top navigation: Centered title "Hồ Sơ Chuyên Gia" in dark gray. Top-right has edit pencil icon and settings gear icon (both purple).

Main content starts with profile card (white background, subtle shadow). Center shows large circular avatar (80px) with small purple camera edit icon on bottom-right. Below avatar, large bold name "TS. Nguyễn Văn A" in dark gray. Next line shows purple badge "Chuyên Gia Đã Xác Minh" with white checkmark icon.

Below badge, row of 3 small purple pill-shaped tags: "Rắn Độc", "Huyết Thanh", "Y Khoa" (8px spacing between).

Below tags, yellow star "4.9 ⭐" followed by gray text "(125 đánh giá)". Bottom line shows small gray text "Thành viên từ tháng 3/2024" with calendar icon.

Below profile card, section titled "Thống Kê Hoạt Động" in dark gray. Three equal-width cards horizontally arranged:

CARD 1: White background, centered layout. Large purple number "234" (28pt). Below, small gray text "Xác Minh Hoàn Tất". Top has purple checkmark circle icon.

CARD 2: White background, centered. Large purple number "189". Below, gray text "Ca Tư Vấn". Top has purple message icon.

CARD 3: White background, centered. Large purple number "567". Below, gray text "Đóng Góp AI". Top has purple brain icon.

Below stats, white card titled "Doanh Thu Tháng Này". Large purple text "4.26M VNĐ" (24pt bold). Below amount, small green text "+15% so với tháng trước" with up arrow. Bottom has purple outlined button "Xem Chi Tiết →".

Next section shows menu list. Each menu item is white card with left icon, text label, and right chevron arrow (all purple accents):
- 📋 Lịch Sử Tư Vấn
- 💰 Quản Lý Doanh Thu
- ⭐ Đánh Giá & Phản Hồi
- 📜 Chứng Chỉ & Bằng Cấp
- 🎯 Chuyên Môn & Lĩnh Vực
- ⚙️ Cài Đặt

Bottom section: White card with left side showing toggle switch (purple when on) and right side text "Sẵn Sàng Nhận Tư Vấn" bold. Below toggle, small green text "Đang bật - Bạn sẽ nhận được yêu cầu tư vấn".

Design: Professional medical profile interface, clear information hierarchy, trust-building credentials display, easy navigation to all features.
```

#### Notes for Stitch:
- Avatar phải có edit icon rõ ràng
- Verification badge phải nổi bật với purple color scheme
- 3 stat cards phải equal width với consistent spacing (8-12px between)
- Revenue card phải có visual hierarchy: amount lớn nhất, growth indicator secondary
- Menu items phải có adequate touch targets (minimum 56px height)
- Availability toggle phải lớn và easy to tap

---

### Screen 2: Edit Expert Profile

#### Thông tin màn hình:
- **Tên:** Màn hình chỉnh sửa hồ sơ chuyên gia
- **Mục đích:** Cho phép Expert cập nhật thông tin cá nhân và chuyên môn
- **Flow position:** Từ Screen 1 (tap Edit button)
- **Priority:** ⭐⭐⭐
- **Related Features:** All profile-related features

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chỉnh Sửa Hồ Sơ"
   - Save button (top-right, purple text)

2. **Avatar Section:**
   - Large circular avatar (100px) centered
   - Upload/change photo button overlay
   - Text: "Thay Đổi Ảnh Đại Diện"

3. **Personal Information Section:**
   - Section title: "Thông Tin Cá Nhân"
   - Input fields (vertically stacked):
     - **Họ và tên** (text input)
       - Placeholder: "Nhập họ và tên đầy đủ"
     - **Số điện thoại** (phone input)
       - Show verified badge if verified
       - Link: "Xác minh" if not verified
     - **Email** (email input)
       - Show verified badge if verified
     - **Ngày sinh** (date picker)
     - **Giới tính** (dropdown: Nam/Nữ/Khác)
     - **Địa chỉ** (multiline text input)
     - **CMND/CCCD** (number input with verified badge)

4. **Professional Information Section:**
   - Section title: "Thông Tin Chuyên Môn"
   - Input fields:
     - **Chức danh** (text input)
       - Placeholder: "Ví dụ: Tiến sĩ, Bác sĩ, Chuyên gia"
     - **Năm kinh nghiệm** (number input)
       - Placeholder: "Số năm làm việc trong lĩnh vực"
     - **Lĩnh vực chuyên môn** (multiselect tags)
       - Options: Rắn độc, Y khoa, Huyết thanh, Cấp cứu, Nghiên cứu
     - **Giới thiệu bản thân** (multiline text, 200 chars max)
       - Placeholder: "Mô tả ngắn về bản thân và kinh nghiệm"
       - Character counter: "0/200"

5. **Additional Information Section:**
   - Section title: "Thông Tin Bổ Sung"
   - **Ngôn ngữ** (multiselect)
     - Options: Tiếng Việt, English, Français
     - At least one required

6. **Action Buttons:**
   - Large purple button: "Lưu Thay Đổi"
   - Text link: "Hủy"

#### Stitch Prompt (English):

```
Mobile app profile edit screen for expert in app "SnakeAid". Form-based interface with purple (#6B46C1) primary color.

Top navigation: Back arrow left, centered title "Chỉnh Sửa Hồ Sơ", right shows purple text button "Lưu".

Top section shows large circular avatar (100px) centered. Small purple camera icon overlay on bottom-right. Below avatar, purple text link "Thay Đổi Ảnh Đại Diện" centered.

First section titled "Thông Tin Cá Nhân" in dark gray bold. White card containing vertically stacked form fields (16px spacing):

- Text input labeled "Họ và tên" with placeholder "Nhập họ và tên đầy đủ"
- Phone input labeled "Số điện thoại" with small green verified badge on right
- Email input labeled "Email" with verified badge
- Date picker labeled "Ngày sinh" showing "01/01/1980"
- Dropdown labeled "Giới tính" showing "Nam"
- Multiline text input labeled "Địa chỉ" (2 lines tall)
- Number input labeled "CMND/CCCD" with verified badge

All inputs have outlined style with purple focus border.

Next section titled "Thông Tin Chuyên Môn" in dark gray bold. White card with form fields:

- Text input labeled "Chức danh" with placeholder "Ví dụ: Tiến sĩ, Bác sĩ, Chuyên gia"
- Number input labeled "Năm kinh nghiệm" with placeholder "Số năm làm việc trong lĩnh vực"
- Multi-select tags labeled "Lĩnh vực chuyên môn". Shows 5 purple pill chips: "Rắn độc" (selected with X), "Y khoa" (selected), "Huyết thanh" (unselected outline), "Cấp cứu" (unselected), "Nghiên cứu" (unselected)
- Multiline text input labeled "Giới thiệu bản thân" (4 lines tall) with character counter "0/200" in bottom-right gray text

Next section titled "Thông Tin Bổ Sung". White card with:
- Multi-select labeled "Ngôn ngữ". Shows 3 checkboxes: "✓ Tiếng Việt" (checked), "✓ English" (checked), "☐ Français" (unchecked)

Bottom section: Large solid purple button "Lưu Thay Đổi" spanning full width. Below button, centered gray text link "Hủy".

Design: Clean form interface, clear field hierarchy, visual feedback for verified fields, mobile-optimized input fields.
```

#### Notes for Stitch:
- Avatar upload area phải lớn và clear về functionality
- Verified badges (green checkmark) phải visible next to phone/email fields
- Multi-select tags phải show selected state clearly (filled purple vs outlined)
- Character counter cho bio phải update real-time
- All input fields phải có proper labels và placeholders
- Purple focus borders when input is active

---

### Screen 3: Certificates & Credentials

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý chứng chỉ và bằng cấp
- **Mục đích:** Hiển thị và quản lý các chứng chỉ, bằng cấp của Expert
- **Flow position:** Từ Screen 1 menu hoặc Settings
- **Priority:** ⭐⭐⭐
- **Related Features:** Trust & credibility verification

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chứng Chỉ & Bằng Cấp"
   - Add button (top-right, "+" icon)

2. **Verification Status Banner:**
   - If all verified: Green banner
     - Icon: Checkmark
     - Text: "Tất cả chứng chỉ đã được xác minh"
   - If pending: Amber banner
     - Icon: Clock
     - Text: "Đang chờ xác minh 2 tài liệu"
   - Progress: "4/6 đã xác minh"

3. **Document Categories (Tabs or Sections):**
   
   **Category 1: Giấy Tờ Tùy Thân**
   - CMND/CCCD card
     - Document thumbnail (small image preview)
     - Title: "Căn Cước Công Dân"
     - ID Number: "001234567890"
     - Status badge: "Đã Xác Minh" (green) or "Đang Chờ" (amber) or "Hết Hạn" (red)
     - Expiry: "Hết hạn: 20/12/2030"
     - Action button: "Xem Chi Tiết" or "Tải Lại"

   **Category 2: Bằng Cấp Y Khoa**
   - Medical license card(s)
     - Thumbnail
     - Title: "Bằng Bác Sĩ"
     - Institution: "Đại Học Y Khoa TP.HCM"
     - Year: "Năm tốt nghiệp: 2015"
     - Status badge
     - Action button

   **Category 3: Chứng Chỉ Chuyên Môn**
   - Expert certification cards
     - Thumbnail
     - Title: "Chứng Chỉ Herpetology"
     - Issuer: "Viện Nghiên Cứu Bò Sát Việt Nam"
     - Issue date: "Cấp ngày: 15/03/2020"
     - Status badge
     - Action button

   **Category 4: Giấy Phép Xử Lý Rắn**
   - Snake handler permits
     - Thumbnail
     - Title: "Giấy Phép Xử Lý Động Vật Nguy Hiểm"
     - Issuer: "Sở Tài Nguyên & Môi Trường"
     - Expiry: "Hết hạn: 01/06/2026"
     - Status badge
     - Action button

4. **Add New Document Button:**
   - Large dashed border card
   - Plus icon
   - Text: "Thêm Chứng Chỉ Mới"

5. **Info Box:**
   - Light blue background
   - Icon: Info
   - Text: "Chứng chỉ được xác minh giúp tăng độ tin cậy và nhận được nhiều yêu cầu tư vấn hơn"

#### Stitch Prompt (English):

```
Mobile app certificates management screen for expert in app "SnakeAid". Document management interface with purple (#6B46C1) primary color.

Top navigation: Back arrow left, centered title "Chứng Chỉ & Bằng Cấp", right has purple "+" add button.

Top shows full-width green banner (#D4EDDA background, #28A745 left border). Left has green checkmark icon. Main text "Tất cả chứng chỉ đã được xác minh" in dark green. Right shows "4/6 đã xác minh" in medium green.

First section titled "Giấy Tờ Tùy Thân" in dark gray bold. White card showing document:
- Left side: Small rectangular thumbnail (60px width) showing document preview placeholder
- Right side content:
  - Bold text "Căn Cước Công Dân"
  - Gray text "Số: 001234567890"
  - Small green badge "Đã Xác Minh" with checkmark
  - Gray text "Hết hạn: 20/12/2030"
- Far right: Purple text button "Xem"

Second section titled "Bằng Cấp Y Khoa". Similar card layout:
- Thumbnail left
- Right content:
  - Bold "Bằng Bác Sĩ"
  - Gray "Đại Học Y Khoa TP.HCM"
  - Green badge "Đã Xác Minh"
  - Gray "Năm tốt nghiệp: 2015"
- Purple "Xem" button right

Third section titled "Chứng Chỉ Chuyên Môn". Card layout:
- Thumbnail left
- Right content:
  - Bold "Chứng Chỉ Herpetology"
  - Gray "Viện Nghiên Cứu Bò Sát Việt Nam"
  - Amber badge "Đang Chờ" with clock icon
  - Gray "Cấp ngày: 15/03/2020"
- Purple "Xem" button right

Fourth section titled "Giấy Phép Xử Lý Rắn". Card layout:
- Thumbnail left
- Right content:
  - Bold "Giấy Phép Xử Lý Động Vật Nguy Hiểm"
  - Gray "Sở Tài Nguyên & Môi Trường"
  - Green badge "Đã Xác Minh"
  - Gray "Hết hạn: 01/06/2026"
- Purple "Xem" button right

Next card has dashed purple border, centered layout:
- Large purple "+" icon (48px)
- Purple text "Thêm Chứng Chỉ Mới"

Bottom info box with light blue background (#E7F3FF):
- Left has blue info icon
- Text "Chứng chỉ được xác minh giúp tăng độ tin cậy và nhận được nhiều yêu cầu tư vấn hơn" in dark gray

Design: Document management interface, clear status indicators, thumbnail previews for trust, easy add new document functionality.
```

#### Notes for Stitch:
- Document thumbnails phải có border và shadow nhẹ
- Status badges phải color-coded rõ ràng: green (verified), amber (pending), red (expired)
- "Add new" card với dashed border phải distinguishable
- Info box không được quá bright - dùng light blue subtle
- Each document card phải có adequate touch target (minimum 72px height)

---

### Screen 4: Specialization Management

#### Thông tin màn hình:
- **Tên:** Màn hình quản lý chuyên môn và lĩnh vực
- **Mục đích:** Cho phép Expert chọn và quản lý các loài rắn và lĩnh vực chuyên môn
- **Flow position:** Từ Screen 1 menu
- **Priority:** ⭐⭐⭐
- **Related Features:** FE-01, FE-07, FE-10, FE-11 (Verification, Guidelines, Consultation)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chuyên Môn & Lĩnh Vực"
   - Save button (top-right)

2. **Introduction Card:**
   - Light purple background
   - Icon: Target or star
   - Text: "Chọn các loài rắn và lĩnh vực bạn có chuyên môn. Điều này giúp hệ thống phân công công việc phù hợp."

3. **Snake Species Section:**
   - Section title: "Các Loài Rắn Chuyên Môn"
   - Subtitle: "Chọn các loài rắn bạn có thể nhận diện và tư vấn (tối thiểu 3 loài)"
   - Grid layout of snake species cards (2 columns):
     
     Each card shows:
     - Snake icon or small illustration
     - Vietnamese name (bold)
     - Scientific name (italic, small)
     - Checkbox for selection
     - Proficiency level dropdown (when selected):
       - "Chuyên Gia" (Expert)
       - "Thành Thạo" (Advanced)
       - "Cơ Bản" (Basic)
     
     Examples:
     - ✓ **Rắn Hổ Mang Chúa** _(Ophiophagus hannah)_ → Chuyên Gia
     - ✓ **Rắn Hổ Mang** _(Naja naja)_ → Chuyên Gia
     - ✓ **Rắn Lục Đuôi Đỏ** _(Trimeresurus albolabris)_ → Thành Thạo
     - ☐ **Rắn Krait** _(Bungarus)_
     - ☐ **Trăn Gấm** _(Python reticulatus)_
     - ☐ **Rắn Ráo Trúc** _(Ptyas korros)_
     - ☐ **Rắn Cạp Nong** _(Daboia siamensis)_
     - ☐ **Rắn Ri Cá** _(Enhydris bocourti)_

4. **Geographic Regions Section:**
   - Section title: "Khu Vực Địa Lý"
   - Subtitle: "Chọn các vùng miền bạn có kinh nghiệm về rắn địa phương"
   - Checkbox list:
     - ☐ Miền Bắc
     - ☐ Miền Trung
     - ☐ Miền Nam
     - ☐ Tây Nguyên
     - ☐ Đồng Bằng Sông Cửu Long

5. **Treatment Protocols Section:**
   - Section title: "Các Giao Thức Điều Trị"
   - Subtitle: "Chọn các phương pháp điều trị bạn có thể tư vấn"
   - Checkbox list with icons:
     - ☐ Sơ cứu tại chỗ (First aid)
     - ☐ Liều lượng huyết thanh (Antivenom dosage)
     - ☐ Xử lý triệu chứng (Symptom management)
     - ☐ Chăm sóc hậu phẫu (Post-treatment care)
     - ☐ Phục hồi chức năng (Rehabilitation)

6. **Selection Summary:**
   - Small card showing:
     - "Đã chọn: 3 loài rắn, 2 khu vực, 4 giao thức"
     - Validation message if requirements not met

7. **Action Buttons:**
   - Large purple button: "Lưu Thay Đổi"
   - Text link: "Hủy"

#### Stitch Prompt (English):

```
Mobile app specialization management screen for expert in app "SnakeAid". Selection-based interface with purple (#6B46C1) primary color.

Top navigation: Back arrow left, centered title "Chuyên Môn & Lĩnh Vực", right has purple text button "Lưu".

Top shows light purple info card (#F3E8FF background) with purple target icon left. Text "Chọn các loài rắn và lĩnh vực bạn có chuyên môn. Điều này giúp hệ thống phân công công việc phù hợp." in dark gray.

First section titled "Các Loài Rắn Chuyên Môn" bold. Subtitle "Chọn các loài rắn bạn có thể nhận diện và tư vấn (tối thiểu 3 loài)" in gray.

Grid layout with 2 columns, 4 rows of snake cards (8px spacing). Each card is white with subtle shadow:

ROW 1:
CARD 1 (selected): Purple border, checkbox checked. Small snake icon top. Bold text "Rắn Hổ Mang Chúa". Italic gray text "(Ophiophagus hannah)". Dropdown showing "Chuyên Gia" in purple.

CARD 2 (selected): Purple border, checked. Icon. "Rắn Hổ Mang". "(Naja naja)". Dropdown "Chuyên Gia".

ROW 2:
CARD 3 (selected): Purple border, checked. Icon. "Rắn Lục Đuôi Đỏ". "(Trimeresurus albolabris)". Dropdown "Thành Thạo".

CARD 4 (unselected): Gray border, unchecked. Icon. "Rắn Krait". "(Bungarus)". No dropdown.

ROW 3:
CARD 5 (unselected): "Trăn Gấm" "(Python reticulatus)"
CARD 6 (unselected): "Rắn Ráo Trúc" "(Ptyas korros)"

ROW 4:
CARD 7 (unselected): "Rắn Cạp Nong" "(Daboia siamensis)"
CARD 8 (unselected): "Rắn Ri Cá" "(Enhydris bocourti)"

Next section titled "Khu Vực Địa Lý" bold. Subtitle in gray. White card with checkbox list (vertically stacked):
☑ Miền Bắc (purple checkbox)
☑ Miền Nam (purple checkbox)
☐ Miền Trung
☐ Tây Nguyên
☐ Đồng Bằng Sông Cửu Long

Next section titled "Các Giao Thức Điều Trị" bold. White card with icon checkboxes:
☑ 💊 Sơ cứu tại chỗ (purple)
☑ 💉 Liều lượng huyết thanh (purple)
☑ 🏥 Xử lý triệu chứng (purple)
☑ 🩹 Chăm sóc hậu phẫu (purple)
☐ ♿ Phục hồi chức năng

Bottom shows small purple card with summary text "Đã chọn: 3 loài rắn, 2 khu vực, 4 giao thức" centered.

Bottom section: Large solid purple button "Lưu Thay Đổi". Below, centered gray text link "Hủy".

Design: Selection-based interface, clear visual indicators for selected items, hierarchical information display, validation feedback.
```

#### Notes for Stitch:
- Snake cards trong grid phải equal size và aligned properly
- Selected cards phải có purple border và checked state rõ ràng
- Proficiency dropdown chỉ show khi card được selected
- Scientific names (italic) phải smaller và gray để hierarchy clear
- Checkbox lists phải có adequate spacing (minimum 48px height per item)
- Summary card ở bottom giúp user track progress
- Validation message nếu chưa đủ minimum requirements (3 snakes)

---

## 📋 SUMMARY - PART 1

### Screens đã thiết kế trong Part 1:

✅ **Profile Overview & Management (4 screens):**
1. **Expert Profile Overview** - Entry point with stats, revenue summary, and navigation menu
2. **Edit Expert Profile** - Personal and professional information editing
3. **Certificates & Credentials** - Document management with verification status
4. **Specialization Management** - Snake species, regions, and treatment protocols selection

### Key Features Covered:
- Trust building through credentials and verification (Green badges)
- Performance statistics (Verifications, Consultations, AI Contributions)
- Revenue summary with link to detailed management
- Professional profile editing with multi-language support
- Document verification system (CMND, Medical licenses, Expert certifications, Permits)
- Specialization selection with proficiency levels
- Geographic region and treatment protocol management

### Design Principles Applied:
1. **Professional Medical Interface** - Purple theme (#6B46C1) for Expert authority
2. **Trust & Credibility** - Verification badges, credentials display, status indicators
3. **Clear Information Hierarchy** - Stats cards, menu items, form sections
4. **Visual Feedback** - Color-coded status (green verified, amber pending, red expired)
5. **Easy Navigation** - Menu-driven access to all features

---

## 🔗 NEXT DOCUMENT

**Part 2: Expert-Profile-Settings-Screens-Part2.md** will cover:
- Screen 5: Expert Settings (comprehensive settings screen)
  - Account management
  - Availability schedule (time slots for consultations)
  - Consultation fee setting (FE-13)
  - Notifications preferences
  - Payment methods
  - Privacy settings
  - Data management
  - Support & help

---

## 📝 IMPLEMENTATION NOTES FOR DEVELOPERS

### API Integration Points:
- `GET /api/expert/profile` - Retrieve expert profile data
- `PUT /api/expert/profile` - Update profile information
- `GET /api/expert/stats` - Get verification/consultation/AI contribution stats
- `GET /api/expert/revenue/summary` - Get monthly revenue summary
- `POST /api/expert/documents` - Upload new certificates/documents
- `GET /api/expert/documents` - List all documents with status
- `PUT /api/expert/specialization` - Update snake species and treatment protocols
- `PUT /api/expert/availability` - Toggle availability status

### Image Handling:
- Profile avatar: Max 5MB, formats: JPG, PNG
- Document uploads: Max 10MB per document, formats: PDF, JPG, PNG
- Thumbnail generation for document previews

### Validation Rules:
- Profile: Name (required), Phone (required, verified), Email (required, verified)
- Specialization: Minimum 3 snake species required
- Documents: CMND/CCCD required for verification
- Bio: Maximum 200 characters

---

**Document Status:** ✅ Complete - Part 1 of 2  
**Role Coverage:** 👨‍⚕️ **EXPERT** (Profile Overview & Management)
**Screens Covered:** 4 screens (Profile, Edit, Certificates, Specialization)
**Next:** Part 2 will cover Settings screen
**Last Updated:** December 15, 2025
