# SAFETY GUIDELINES SCREENS - UI DESIGN (RESCUER ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **RESCUER/SUPPORTER** (Đội cứu hộ rắn)
- **Flow:** Safety Guidelines & Training
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 4 screens
- **Ngày tạo:** December 11, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Safety-Guidelines-Screens.md`

> **⚠️ LƯU Ý:** Document này cover màn hình **Safety Guidelines** cho Rescuer - hướng dẫn bắt rắn an toàn, thiết bị, kỹ thuật xử lý.

---

## 🎯 Context & Purpose

### Safety Guidelines Role in Rescuer Flow

Safety Guidelines là **module quan trọng** giúp Rescuer:
- **Học kỹ thuật bắt rắn an toàn** cho từng loài
- **Chuẩn bị thiết bị** phù hợp trước mỗi nhiệm vụ
- **Xem video hướng dẫn** bắt rắn thực tế
- **Đọc quy trình chuẩn** xử lý rắn độc/không độc

### Key Features Mapped:

From **Major Features Summary**:
- **FE-09:** Quy trình chuẩn để bắt và di dời rắn an toàn
- **FE-10:** Danh sách thiết bị cần thiết và kỹ thuật xử lý từng loài
- **FE-11:** Video hướng dẫn bắt rắn cho từng tình huống

### Access Points:

Safety Guidelines có thể truy cập từ:
1. **Dashboard** → Menu → "Hướng Dẫn An Toàn"
2. **Mission Detail Screen** → Button "Xem hướng dẫn an toàn" (khi xem chi tiết loài rắn)
3. **Equipment Screen** (Profile) → Link "Xem kỹ thuật sử dụng"
4. **Active Support Screen** → Button "Xem hướng dẫn bắt rắn"

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange `#FF8A00` (Action, rescue, energy - consistent with all Rescuer flows)
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Danger:** Red `#DC3545`
- **Accent - Info:** Blue `#007BFF`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)

### Component Style:
- **Cards:** Rounded corners (12px), subtle shadow
- **Buttons:** Rounded (8px), large touch targets
- **Video Thumbnails:** 16:9 aspect ratio with play button overlay
- **Checklist Items:** Checkbox + icon + text
- **Warning Banners:** Red/amber background with icon

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - Hướng dẫn an toàn bắt rắn

---

### Screen 1: Safety Guidelines Home

#### Thông tin màn hình:
- **Tên:** Trang chủ hướng dẫn an toàn
- **Mục đích:** Hub trung tâm cho tất cả resources về safety, equipment, techniques
- **Access from:** Dashboard menu, Mission detail, Profile equipment
- **Priority:** ⭐⭐⭐ (Critical for safety)

#### Key Components:

1. **Header:**
   - Back button (return to previous screen)
   - Title: "Hướng Dẫn An Toàn"
   - Search icon (search guidelines)

2. **Safety Status Banner:**
   - Card showing Rescuer's safety status
   - "Đã hoàn thành đào tạo cơ bản" (green check)
   - Progress bar: "15/20 video đã xem"
   - Link: "Tiếp tục học"

3. **Quick Safety Tips Card:**
   - Rotating carousel of safety tips
   - Icon + short tip (e.g., "Luôn mặc găng tay dày")
   - Button: "Xem tất cả tips"

4. **Main Categories:**
   
   **A. Quy trình chuẩn (FE-09):**
   - Card with clipboard icon
   - "Quy trình bắt rắn từng bước"
   - Subtitle: "Chuẩn bị → Tiếp cận → Bắt → Di dời"
   - Badge: "12 quy trình"
   
   **B. Thiết bị cần thiết (FE-10):**
   - Card with toolbox icon
   - "Danh sách thiết bị & cách sử dụng"
   - Subtitle: "Găng tay, kìm bắt rắn, túi vải, hộp cứu thương..."
   - Badge: "8 loại thiết bị"
   
   **C. Video hướng dẫn (FE-11):**
   - Card with play icon
   - "Video bắt rắn thực tế"
   - Subtitle: "Học từ chuyên gia, tình huống thật"
   - Badge: "20 videos"
   
   **D. Kỹ thuật theo loài:**
   - Card with snake icon
   - "Kỹ thuật xử lý từng loài rắn"
   - Subtitle: "Rắn độc, không độc, lớn, nhỏ..."
   - Badge: "15 loài phổ biến"

5. **Emergency Contacts Card:**
   - Red banner
   - "Liên hệ khẩn cấp"
   - Buttons: "Gọi chuyên gia" / "Gọi cấp cứu 115"

6. **Recent Updates Section:**
   - "Cập nhật gần đây"
   - List of 3 recent guideline updates
   - Each item: Icon, title, date, "NEW" badge

7. **Bottom Navigation Bar:**
   - 4 tabs: "Trang chủ", "Nhiệm vụ", "Bản đồ", "Cá nhân"

#### Stitch Prompt (English):

```
Mobile app safety guidelines home screen for snake rescuer in "SnakeAid". Educational hub interface with orange (#FF8A00) theme on white background.

Top navigation: Back arrow left, centered title "Hướng Dẫn An Toàn" bold, search icon right.

Safety status banner white card shadow rounded:
- Left: Green shield checkmark icon
- Center: Bold text "Đã Hoàn Thành Đào Tạo Cơ Bản"
- Below: Progress bar 75% filled green with "15/20 video đã xem"
- Right: Small orange text link "Tiếp Tục Học →"

Quick tips carousel card white shadow:
- Left: Large lightbulb icon in orange circle
- Center: Bold text "Luôn Mặc Găng Tay Dày Khi Bắt Rắn"
- Bottom: Gray text "Mẹo 3/15" and orange link "Xem Tất Cả Tips"

Section title "Danh Mục Chính" bold dark gray.

Four category cards in 2x2 grid, each white card shadow rounded (equal size):

Card 1 (top-left): Orange clipboard icon top, bold "Quy Trình Chuẩn" center, gray "Chuẩn bị → Tiếp cận → Bắt → Di dời" below, small orange badge "12 quy trình" bottom-right.

Card 2 (top-right): Orange toolbox icon top, bold "Thiết Bị Cần Thiết" center, gray "Găng tay, kìm bắt rắn, túi vải..." below, small orange badge "8 loại" bottom-right.

Card 3 (bottom-left): Orange play circle icon top, bold "Video Hướng Dẫn" center, gray "Học từ chuyên gia, tình huống thật" below, small orange badge "20 videos" bottom-right.

Card 4 (bottom-right): Orange snake icon top, bold "Kỹ Thuật Theo Loài" center, gray "Rắn độc, không độc, lớn, nhỏ..." below, small orange badge "15 loài" bottom-right.

Emergency contacts card red border white background:
- Red alert icon left, bold "Liên Hệ Khẩn Cấp" center
- Two buttons horizontal: Red "Gọi Chuyên Gia" | Red outlined "Gọi 115"

Section "Cập Nhật Gần Đây" bold.

Three update items white cards:
- Item 1: Blue info icon, "Kỹ thuật mới: Bắt rắn hổ mang", gray "05/12/2025", red "NEW" badge
- Item 2: Green checkmark, "Video: Sơ cứu khi bị cắn", gray "03/12/2025"
- Item 3: Amber warning, "Cảnh báo: Rắn độc mùa mưa", gray "01/12/2025"

Bottom fixed navigation bar 4 tabs: "Trang Chủ" (orange active), "Nhiệm Vụ", "Bản Đồ", "Cá Nhân" (gray inactive).

Design: Educational hub, clear categorization, safety emphasis, quick access to emergency contacts, progress tracking.
```

#### Notes for Stitch:
- Progress tracking motivates Rescuers to complete training
- Emergency contacts always accessible
- Category cards phải equally sized và grid layout
- Search function cho phép tìm nhanh guidelines
- "NEW" badges highlight recent updates

---

### Screen 2: Standard Procedures (Quy trình chuẩn)

#### Thông tin màn hình:
- **Tên:** Quy trình bắt rắn từng bước
- **Mục đích:** Hiển thị step-by-step procedures cho bắt rắn an toàn
- **Access from:** Screen 1 → Tap "Quy trình chuẩn"
- **Priority:** ⭐⭐⭐ (Core training content)
- **Related Features:** FE-09 (Quy trình chuẩn bắt rắn)

#### Key Components:

1. **Header:**
   - Back button
   - Title: "Quy Trình Bắt Rắn Chuẩn"
   - Bookmark icon (save procedure)

2. **Procedure Type Tabs:**
   - Tab 1: "Rắn độc" (red icon)
   - Tab 2: "Rắn không độc" (green icon)
   - Tab 3: "Rắn lớn" (amber icon)
   - Tab 4: "Trong nhà" (blue icon)

3. **Overview Card:**
   - Procedure summary
   - "4 bước chính"
   - Estimated time: "10-15 phút"
   - Difficulty level: "Trung bình"
   - Warning icon: "Yêu cầu thiết bị đầy đủ"

4. **Step-by-Step Procedures:**

   **Step 1: Chuẩn bị (Preparation):**
   - Large number "1" in circle
   - Bold heading: "Chuẩn Bị Thiết Bị & Đánh Giá"
   - Checklist:
     - ☑ "Mặc quần áo bảo hộ dày"
     - ☑ "Đeo găng tay chống cắn"
     - ☑ "Chuẩn bị kìm bắt rắn"
     - ☑ "Chuẩn bị túi vải/hộp chứa"
     - ☑ "Đánh giá tình huống & môi trường"
   - Icon illustrations for each item
   - Button: "Xem video minh họa"

   **Step 2: Tiếp cận (Approach):**
   - Number "2"
   - Heading: "Tiếp Cận An Toàn"
   - Instructions:
     - "Giữ khoảng cách tối thiểu 1.5m"
     - "Quan sát hành vi của rắn"
     - "Tránh làm rắn bị kích động"
     - "Tiếp cận từ phía sau hoặc bên hông"
   - Diagram: Top-down view of approach angles
   - Warning box: "KHÔNG tiếp cận từ phía đầu"

   **Step 3: Bắt giữ (Capture):**
   - Number "3"
   - Heading: "Kỹ Thuật Bắt Rắn"
   - Techniques:
     - "Dùng kìm bắt phần đầu/cổ rắn"
     - "Nâng rắn lên khỏi mặt đất"
     - "Giữ chặt nhưng không siết quá"
     - "Tay còn lại kiểm soát thân rắn"
   - Illustration: Hand positions on snake tool
   - Button: "Xem video kỹ thuật bắt"

   **Step 4: Di dời (Relocation):**
   - Number "4"
   - Heading: "Di Dời An Toàn"
   - Instructions:
     - "Đưa rắn vào túi vải/hộp"
     - "Buộc túi chắc chắn"
     - "Vận chuyển đến địa điểm thả"
     - "Thả rắn ở môi trường phù hợp (cách xa khu dân cư)"
   - Map icon: "Xem điểm thả rắn gần nhất"

5. **Important Warnings Section:**
   - Red banner
   - Title: "Các Hành Động CẤM KỴ"
   - List:
     - ✖ "KHÔNG bắt rắn bằng tay không"
     - ✖ "KHÔNG làm rắn bị thương"
     - ✖ "KHÔNG giết rắn"
     - ✖ "KHÔNG tiếp cận khi không có thiết bị"

6. **Related Resources:**
   - "Video liên quan" (3 thumbnails)
   - "Thiết bị cần thiết" (link)
   - "Kỹ thuật nâng cao" (link)

7. **Bottom Action Bar:**
   - Button: "Hoàn thành & đánh dấu đã đọc" (green)
   - Button: "Lưu để đọc sau" (gray)

#### Stitch Prompt (English):

```
Mobile app standard procedure screen for snake rescuer. Step-by-step guide interface with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Quy Trình Bắt Rắn Chuẩn" centered, bookmark icon right.

Horizontal tab bar 4 tabs scrollable:
"Rắn Độc" (active, orange underline, red snake icon) | "Rắn Không Độc" | "Rắn Lớn" | "Trong Nhà"

Overview card white shadow rounded:
- Top row: "4 Bước Chính" bold | "10-15 phút" with clock icon | "Trung Bình" with meter icon
- Bottom: Amber warning icon + "Yêu cầu thiết bị đầy đủ"

Section "Quy Trình Chi Tiết" bold.

Step 1 card white shadow:
- Large orange circle "1" left
- Bold heading "CHUẨN BỊ THIẾT BỊ & ĐÁNH GIÁ"
- Checklist 5 items with green checkboxes:
  - Checkbox + glove icon + "Mặc quần áo bảo hộ dày"
  - Checkbox + glove icon + "Đeo găng tay chống cắn"
  - Checkbox + tool icon + "Chuẩn bị kìm bắt rắn"
  - Checkbox + bag icon + "Chuẩn bị túi vải/hộp chứa"
  - Checkbox + eye icon + "Đánh giá tình huống & môi trường"
- Blue text link "▶ Xem Video Minh Họa"

Step 2 card white shadow:
- Orange circle "2" left
- Bold "TIẾP CẬN AN TOÀN"
- 4 bullet points gray text:
  - "• Giữ khoảng cách tối thiểu 1.5m"
  - "• Quan sát hành vi của rắn"
  - "• Tránh làm rắn bị kích động"
  - "• Tiếp cận từ phía sau hoặc bên hông"
- Simple top-down diagram placeholder (person approaching snake from side, 150px)
- Red warning box: "⚠ KHÔNG tiếp cận từ phía đầu"

Step 3 card white shadow:
- Orange circle "3" left
- Bold "KỸ THUẬT BẮT RẮN"
- Numbered instructions:
  1. "Dùng kìm bắt phần đầu/cổ rắn"
  2. "Nâng rắn lên khỏi mặt đất"
  3. "Giữ chặt nhưng không siết quá"
  4. "Tay còn lại kiểm soát thân rắn"
- Illustration placeholder (hand holding snake tool, 180px)
- Blue link "▶ Xem Video Kỹ Thuật Bắt"

Step 4 card white shadow:
- Orange circle "4" left
- Bold "DI DỜI AN TOÀN"
- 4 steps gray text:
  - "1. Đưa rắn vào túi vải/hộp"
  - "2. Buộc túi chắc chắn"
  - "3. Vận chuyển đến địa điểm thả"
  - "4. Thả rắn ở môi trường phù hợp"
- Green button "📍 Xem Điểm Thả Rắn Gần Nhất"

Red border card:
- Red X icon, bold red "CÁC HÀNH ĐỘNG CẤM KỴ"
- 4 items with red X:
  - "✖ KHÔNG bắt rắn bằng tay không"
  - "✖ KHÔNG làm rắn bị thương"
  - "✖ KHÔNG giết rắn"
  - "✖ KHÔNG tiếp cận khi không có thiết bị"

Section "Tài Liệu Liên Quan" gray.
- 3 video thumbnails horizontal row (play icon overlay)
- 2 text links: "Thiết Bị Cần Thiết →" | "Kỹ Thuật Nâng Cao →"

Bottom sticky bar white shadow:
- Large green button "✓ Hoàn Thành & Đánh Dấu Đã Đọc" (full width, 55px)
- Small gray button "Lưu Để Đọc Sau" below

Design: Step-by-step safety procedure, clear instructions, visual aids, safety warnings, progress tracking.
```

#### Notes for Stitch:
- Each step phải có clear numbering và visual separation
- Diagrams/illustrations essential cho technical instructions
- Video links phải prominent cho visual learners
- Warning section phải highly visible (red)
- Checklist format helps Rescuers follow steps methodically

---

### Screen 3: Equipment Guide (Thiết bị & Kỹ thuật)

#### Thông tin màn hình:
- **Tên:** Hướng dẫn thiết bị bắt rắn
- **Mục đích:** Chi tiết về từng loại thiết bị, cách sử dụng, bảo quản
- **Access from:** Screen 1 → Tap "Thiết bị cần thiết"
- **Priority:** ⭐⭐⭐ (Essential for safety)
- **Related Features:** FE-10 (Danh sách thiết bị và kỹ thuật xử lý)

#### Key Components:

1. **Header:**
   - Back button
   - Title: "Thiết Bị Bắt Rắn"
   - Shopping cart icon (link to equipment shop - optional)

2. **Equipment Checklist Status:**
   - Card showing: "6/8 thiết bị đã sở hữu"
   - Progress circle: 75%
   - Button: "Cập nhật danh sách của tôi"

3. **Equipment Categories:**

   **A. Essential Equipment (Bắt buộc):**
   
   **Equipment 1: Snake Hook / Kìm Bắt Rắn:**
   - Card with photo/illustration
   - Name: "Kìm Bắt Rắn Chuyên Dụng"
   - Badge: "BẮT BUỘC" (red)
   - Status: "✓ Đã sở hữu" (green) / "⚠ Chưa có" (red)
   - Description: "Dụng cụ chính để bắt và kiểm soát đầu rắn"
   - Expandable sections:
     - **Cách sử dụng:** Step-by-step với hình minh họa
     - **Kỹ thuật:** "Kẹp vào phần cổ, giữ chặt nhưng không siết"
     - **Bảo quản:** "Lau sạch sau mỗi lần dùng, bảo quản khô ráo"
     - **Kiểm tra:** "Kiểm tra độ bền khớp nối trước mỗi nhiệm vụ"
   - Button: "▶ Xem video sử dụng"
   - Link: "Mua thiết bị này"

   **Equipment 2: Snake Bag / Túi Vải:**
   - Name: "Túi Vải Chuyên Dụng"
   - Badge: "BẮT BUỘC"
   - Status indicator
   - Description: "Túi vải dày, thở khí, để chứa rắn an toàn"
   - Specs:
     - "Kích thước: 60cm x 40cm"
     - "Chất liệu: Vải cotton dày"
     - "Dây buộc: Dây dù chắc chắn"
   - Instructions: "Cách buộc túi an toàn" (diagram)

   **Equipment 3: Protective Gloves / Găng Tay:**
   - Name: "Găng Tay Chống Cắn"
   - Badge: "BẮT BUỘC"
   - Description: "Găng da dày, chống thủng, bảo vệ đến cổ tay"
   - Warning: "Không bảo vệ 100% khỏi rắn độc lớn"
   - Care instructions: "Thay găng khi xuống cấp"

   **Equipment 4: Protective Boots / Giày Bảo Hộ:**
   - Name: "Ủng Cao Cổ Chống Cắn"
   - Badge: "BẮT BUỘC"
   - Height: "Tối thiểu 30cm"
   - Material: "Da hoặc cao su dày"

   **B. Recommended Equipment (Nên có):**

   **Equipment 5: Snake Stick / Gậy Bẫy Rắn:**
   - Badge: "NÊN CÓ" (amber)
   - Use case: "Kiểm soát rắn lớn, giữ khoảng cách"

   **Equipment 6: First Aid Kit / Hộp Cứu Thương:**
   - Badge: "NÊN CÓ"
   - Contents checklist:
     - ☑ Băng ép (compression bandage)
     - ☑ Khăn vô trùng
     - ☑ Kéo y tế
     - ☑ Băng dính y tế
     - ☑ Thuốc sát trùng
   - Button: "Xem hướng dẫn sơ cứu khi bị cắn"

   **Equipment 7: Flashlight / Đèn Pin:**
   - Badge: "NÊN CÓ"
   - Use: "Chiếu sáng khi bắt rắn ban đêm hoặc nơi tối"
   - Spec: "Độ sáng tối thiểu 500 lumen"

   **Equipment 8: Snake Container / Hộp Chứa:**
   - Badge: "OPTIONAL" (gray)
   - Use: "Thay thế túi vải, dùng cho rắn độc nguy hiểm"
   - Type: "Hộp nhựa cứng có lỗ thông khí"

4. **Equipment Maintenance Schedule:**
   - Card: "Lịch Bảo Trì Thiết Bị"
   - Table showing:
     - Equipment name
     - Last check date
     - Next check due
     - Status (OK / Cần kiểm tra / Hỏng)
   - Button: "Cập nhật kiểm tra"

5. **Safety Tips Section:**
   - "Lưu Ý An Toàn"
   - List of 5 key tips:
     - "Luôn kiểm tra thiết bị trước mỗi nhiệm vụ"
     - "Thay thế thiết bị hư hỏng ngay lập tức"
     - "Không dùng chung thiết bị cá nhân"
     - "Bảo quản thiết bị khô ráo, sạch sẽ"
     - "Học cách sử dụng đúng mỗi dụng cụ"

6. **Related Videos Section:**
   - "Video Hướng Dẫn Thiết Bị"
   - 3 video thumbnails:
     - "Cách dùng kìm bắt rắn đúng cách" (5:30)
     - "Bảo quản thiết bị bắt rắn" (3:15)
     - "Sơ cứu khi bị rắn cắn trong nhiệm vụ" (8:00)

#### Stitch Prompt (English):

```
Mobile app equipment guide screen for snake rescuer. Detailed equipment list interface with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Thiết Bị Bắt Rắn" centered, shopping cart icon right.

Equipment status card white shadow:
- Left: Large circular progress 75% filled orange, "6/8" bold in center
- Right: Text "6/8 thiết bị đã sở hữu" bold, small gray "Cập nhật: 10/12/2025"
- Bottom: Orange text link "Cập Nhật Danh Sách Của Tôi →"

Section "THIẾT BỊ BẮT BUỘC" bold dark gray, red underline.

Equipment card 1 white shadow rounded expandable:
- Top row: Equipment photo thumbnail (80px square) left, right section:
  - Bold "Kìm Bắt Rắn Chuyên Dụng"
  - Red badge "BẮT BUỘC"
  - Green checkmark "✓ Đã Sở Hữu"
- Gray text "Dụng cụ chính để bắt và kiểm soát đầu rắn"
- Expandable accordion (collapsed state shown):
  - "Cách Sử Dụng" with down chevron
  - "Kỹ Thuật" with down chevron
  - "Bảo Quản" with down chevron
- Bottom row two buttons:
  - Blue outlined "▶ Xem Video Sử Dụng"
  - Gray outlined "Mua Thiết Bị Này"

Equipment card 2 similar structure:
- Bag icon thumbnail
- "Túi Vải Chuyên Dụng"
- Red "BẮT BUỘC" badge
- Green "✓ Đã Sở Hữu"
- Specs section visible (expanded):
  - "Kích thước: 60cm x 40cm"
  - "Chất liệu: Vải cotton dày"
  - "Dây buộc: Dây dù chắc chắn"
- Small diagram placeholder showing bag tying method (120px)

Equipment card 3:
- Gloves icon
- "Găng Tay Chống Cắn"
- Red "BẮT BUỘC"
- Red warning icon "⚠ Chưa Có" (not owned)
- Amber warning box: "Không bảo vệ 100% khỏi rắn độc lớn"

Equipment card 4:
- Boots icon
- "Ủng Cao Cổ Chống Cắn"
- Red "BẮT BUỘC"
- Green "✓ Đã Sở Hữu"
- Gray text "Tối thiểu 30cm, Da hoặc cao su dày"

Section "THIẾT BỊ NÊN CÓ" bold, amber underline.

Equipment card 5:
- Snake stick icon
- "Gậy Bẫy Rắn"
- Amber badge "NÊN CÓ"
- Gray "Chưa Có"
- Use case text

Equipment card 6:
- First aid icon
- "Hộp Cứu Thương"
- Amber "NÊN CÓ"
- Green "✓ Đã Sở Hữu"
- Checklist 5 items with green checks:
  - "✓ Băng ép"
  - "✓ Khăn vô trùng"
  - etc.
- Blue link "Xem Hướng Dẫn Sơ Cứu Khi Bị Cắn →"

Maintenance schedule card white:
- Title "Lịch Bảo Trì Thiết Bị" bold
- Simple table:
  | Thiết bị | Kiểm tra cuối | Kiểm tra tiếp | Trạng thái |
  | Kìm bắt | 05/12/2025 | 05/01/2026 | ✓ OK |
  | Găng tay | 01/12/2025 | 01/01/2026 | ⚠ Cần kiểm tra |
- Orange button "Cập Nhật Kiểm Tra"

Safety tips card light blue background:
- Blue info icon, bold "Lưu Ý An Toàn"
- 5 bullet points gray text

Section "Video Hướng Dẫn Thiết Bị" bold.
- 3 video cards horizontal scrollable:
  - Thumbnail 16:9 with play overlay
  - "Cách dùng kìm bắt rắn đúng cách"
  - Gray "5:30" with clock icon

Design: Comprehensive equipment catalog, ownership tracking, maintenance scheduling, usage instructions, safety emphasis.
```

#### Notes for Stitch:
- Equipment cards phải expandable để show detailed info
- Status tracking (owned/not owned) helps Rescuers prepare
- Maintenance schedule prevents equipment failure
- Video links essential cho practical demonstrations
- "BẮT BUỘC" vs "NÊN CÓ" vs "OPTIONAL" badges prioritize equipment

---

### Screen 4: Video Library (Thư viện video)

#### Thông tin màn hình:
- **Tên:** Thư viện video hướng dẫn
- **Mục đích:** Video tutorials cho các tình huống bắt rắn khác nhau
- **Access from:** Screen 1 → Tap "Video hướng dẫn"
- **Priority:** ⭐⭐⭐ (Visual learning essential)
- **Related Features:** FE-11 (Video hướng dẫn bắt rắn)

#### Key Components:

1. **Header:**
   - Back button
   - Title: "Video Hướng Dẫn"
   - Filter icon (sort/filter videos)

2. **Search & Filter Bar:**
   - Search box: "Tìm video..."
   - Filter chips (scrollable):
     - "Tất cả" (active)
     - "Rắn độc"
     - "Rắn không độc"
     - "Trong nhà"
     - "Ngoài trời"
     - "Ban đêm"
     - "Rắn lớn"

3. **Learning Progress:**
   - Card showing: "12/20 videos đã xem"
   - Progress bar: 60%
   - Text: "Hoàn thành thêm 8 videos để nhận chứng chỉ"

4. **Featured Video:**
   - Large video card at top
   - Thumbnail (16:9 aspect ratio)
   - "NỔI BẬT" badge
   - Play button overlay (large)
   - Video info:
     - Title: "Kỹ thuật bắt rắn hổ mang an toàn"
     - Expert: "Chuyên gia Nguyễn Văn A"
     - Duration: "12:30"
     - Views: "1.2K lượt xem"
     - Rating: "4.9 ⭐"
   - Tags: "Rắn độc", "Nâng cao"

5. **Video Categories:**

   **A. Cơ bản (Beginner Level):**
   - Section title with "6 videos" count
   
   **Video 1: "Giới thiệu thiết bị bắt rắn"**
   - Thumbnail with play button
   - Duration: "5:30"
   - Status: "✓ Đã xem" (green check)
   - Date watched: "05/12/2025"

   **Video 2: "Quy trình 4 bước bắt rắn không độc"**
   - Duration: "8:15"
   - Status: "Chưa xem"
   - Views: "850"

   **Video 3: "Cách tiếp cận rắn an toàn"**
   - Duration: "6:45"
   - Status: "✓ Đã xem"
   - Quiz badge: "✓ Đã làm bài test"

   **B. Trung cấp (Intermediate Level):**
   - Section title with "8 videos"
   
   **Video 4: "Bắt rắn hổ mang trong nhà"**
   - Thumbnail
   - Duration: "10:20"
   - Tags: "Rắn độc", "Trong nhà"
   - Views: "1.5K"
   - "NEW" badge (red)

   **Video 5: "Xử lý rắn lớn (>2m)"**
   - Duration: "12:00"
   - Tags: "Rắn lớn", "Nâng cao"
   - Lock icon: "Cần hoàn thành 3 videos cơ bản" (grayed out)

   **Video 6: "Bắt rắn ban đêm với đèn pin"**
   - Duration: "9:30"
   - Tags: "Ban đêm", "Kỹ thuật"
   - Status: "▶ Đang xem" (orange)
   - Progress bar: 45%

   **C. Nâng cao (Advanced Level):**
   - Section title with "6 videos"
   
   **Video 7: "Bắt rắn hổ mang chúa - Chuyên gia"**
   - Duration: "15:45"
   - Tags: "Rắn độc", "Nâng cao"
   - Warning badge: "Chỉ dành cho Rescuer có kinh nghiệm"

   **Video 8: "Sơ cứu khi bị rắn độc cắn"**
   - Duration: "8:00"
   - Tags: "Sơ cứu", "Khẩn cấp"
   - "QUAN TRỌNG" badge (red)

6. **Download Offline Card:**
   - "Tải về xem offline"
   - Text: "Tải 5 videos quan trọng nhất để xem khi không có mạng"
   - Button: "Chọn videos để tải"
   - Storage: "256MB trống"

7. **Test Your Knowledge:**
   - Card with quiz icon
   - "Kiểm tra kiến thức"
   - Text: "Làm bài test sau khi xem videos để nhận chứng chỉ"
   - Button: "Bắt đầu bài test"

8. **Bottom Action:**
   - Floating button (bottom-right): "Đề xuất video cho tôi" (orange)

#### Stitch Prompt (English):

```
Mobile app video library screen for snake rescuer training. Educational video catalog with orange (#FF8A00) theme.

Top navigation: Back arrow left, "Video Hướng Dẫn" centered, filter sliders icon right.

Search bar white rounded shadow: magnifying glass icon left, placeholder "Tìm video..." gray text.

Filter chips horizontal scrollable:
"Tất Cả" (orange filled active) | "Rắn Độc" (outlined) | "Rắn Không Độc" | "Trong Nhà" | "Ngoài Trời" | "Ban Đêm"

Progress card white shadow:
- Orange progress bar 60% filled, "12/20 videos đã xem" bold
- Small gray "Hoàn thành thêm 8 videos để nhận chứng chỉ"

Featured video card white shadow rounded large:
- Video thumbnail 16:9 aspect ratio (full width, 200px height) with large white play circle overlay
- Top-left corner: Red "NỔI BẬT" badge
- Below thumbnail:
  - Bold title "Kỹ thuật Bắt Rắn Hổ Mang An Toàn"
  - Gray "Chuyên gia Nguyễn Văn A" with expert icon
  - Bottom row: "12:30" duration | "1.2K lượt xem" | "4.9 ⭐"
  - Two orange chips: "Rắn Độc" | "Nâng Cao"

Section "CƠ BẢN" bold with gray "6 videos".

Video item 1 horizontal card:
- Left: Thumbnail 120x90px with small play icon overlay
- Right section:
  - Bold "Giới Thiệu Thiết Bị Bắt Rắn"
  - Green "✓ Đã Xem" badge
  - Gray "5:30" with clock icon | "Xem: 05/12/2025"

Video item 2:
- Thumbnail left
- "Quy Trình 4 Bước Bắt Rắn Không Độc"
- Gray "Chưa Xem" badge
- "8:15" | "850 lượt xem"

Video item 3:
- Thumbnail
- "Cách Tiếp Cận Rắn An Toàn"
- Green "✓ Đã Xem"
- Green quiz badge "✓ Đã Làm Bài Test"

Section "TRUNG CẤP" bold with "8 videos".

Video item 4:
- Thumbnail with red "NEW" badge top-right
- "Bắt Rắn Hổ Mang Trong Nhà"
- "10:20" | "1.5K views"
- Two tags: "Rắn Độc" | "Trong Nhà"

Video item 5:
- Grayed out thumbnail with lock icon overlay
- "Xử Lý Rắn Lớn (>2m)"
- Gray text "Cần hoàn thành 3 videos cơ bản"
- "12:00"

Video item 6:
- Thumbnail
- "Bắt Rắn Ban Đêm Với Đèn Pin"
- Orange badge "▶ Đang Xem"
- Orange progress bar 45% below title
- "9:30"

Section "NÂNG CAO" bold with "6 videos".

Video item 7:
- Thumbnail
- "Bắt Rắn Hổ Mang Chúa - Chuyên Gia"
- Amber warning badge "Chỉ dành cho Rescuer có kinh nghiệm"
- "15:45"

Video item 8:
- Thumbnail
- "Sơ Cứu Khi Bị Rắn Độc Cắn"
- Red "QUAN TRỌNG" badge
- "8:00"

Download card light gray background:
- Download icon left, "Tải Về Xem Offline" bold
- Gray text "Tải 5 videos quan trọng nhất để xem khi không có mạng"
- Blue button "Chọn Videos Để Tải"
- Small text "256MB trống"

Test card blue border:
- Quiz icon left
- Bold "Kiểm Tra Kiến Thức"
- Gray "Làm bài test sau khi xem videos để nhận chứng chỉ"
- Green button "Bắt Đầu Bài Test"

Floating action button bottom-right: Orange circular button with lightbulb icon, "Đề Xuất Video Cho Tôi" on hover.

Design: Video learning platform, progress tracking, difficulty levels, offline capability, assessment integration.
```

#### Notes for Stitch:
- Video thumbnails phải clear với play button prominent
- Progress tracking (watched/not watched) essential
- Lock advanced videos until basics completed (gamification)
- Offline download feature critical cho areas với poor network
- Quiz integration validates learning
- "Currently watching" status với progress bar helps resume
- Expert badges và difficulty levels guide learning path

---

## 📊 SCREEN FLOW SUMMARY

### Safety Guidelines Navigation Flow:

```
Screen 1: Safety Guidelines Home
    ↓ (Tap "Quy trình chuẩn")
Screen 2: Standard Procedures
    ← (Back) → (Tap "Thiết bị cần thiết")
Screen 3: Equipment Guide
    ← (Back) → (Tap "Video hướng dẫn")
Screen 4: Video Library
    ↓ (Tap video)
Video Player Screen (not in scope)
    ↓ (Complete)
Screen 4: Video Library (mark as watched)
```

### Access Points from Other Flows:

```
Dashboard → Menu → Safety Guidelines → Screen 1

Mission Detail → "Xem hướng dẫn an toàn" → Screen 2 (filtered by snake species)

Profile Equipment → "Xem kỹ thuật sử dụng" → Screen 3 (specific equipment)

Active Support → "Xem hướng dẫn bắt rắn" → Screen 2 or Screen 4
```

---

## 🔗 Integration Points

### Backend APIs Required:

1. **Content Management:**
   - GET `/api/safety-guidelines/procedures` - Get all procedures
   - GET `/api/safety-guidelines/equipment` - Get equipment list
   - GET `/api/safety-guidelines/videos` - Get video library
   - GET `/api/videos/{id}/stream` - Stream video content

2. **Progress Tracking:**
   - GET `/api/rescuer/training-progress` - Get learning progress
   - POST `/api/rescuer/videos/{id}/watched` - Mark video as watched
   - POST `/api/rescuer/procedures/{id}/completed` - Mark procedure as read
   - POST `/api/rescuer/equipment/owned` - Update owned equipment list

3. **Offline Support:**
   - POST `/api/videos/download` - Download videos for offline
   - GET `/api/safety-guidelines/offline-content` - Get cached content

4. **Assessment:**
   - GET `/api/training/quizzes` - Get quiz questions
   - POST `/api/training/quizzes/{id}/submit` - Submit quiz answers
   - GET `/api/rescuer/certifications` - Get earned certificates

---

## 🎯 Key Design Principles

1. **Safety First:**
   - Warnings và prohibited actions phải highly visible
   - Red color cho danger, amber cho warnings
   - Step-by-step instructions để tránh mistakes

2. **Visual Learning:**
   - Video content prioritized
   - Diagrams và illustrations cho mỗi technique
   - Photo examples của equipment

3. **Progress Motivation:**
   - Track videos watched, procedures read
   - Gamification với locked advanced content
   - Certificates upon completion

4. **Offline Support:**
   - Download critical videos
   - Cache procedures và equipment guides
   - Work in low/no connectivity environments

5. **Practical Focus:**
   - Real-world scenarios
   - Expert demonstrations
   - Equipment maintenance schedules

---

## 📝 Notes for Development Team

### Critical Features:

1. **Video Streaming:**
   - Support multiple resolutions (720p, 480p, 360p)
   - Adaptive bitrate based on connection
   - Resume playback từ last position
   - Picture-in-picture support

2. **Offline Downloads:**
   - Limit downloads based on storage
   - Auto-delete old downloaded content
   - Sync watched status when online

3. **Content Updates:**
   - Push notifications cho new videos/procedures
   - "NEW" badges for recent content
   - Version control cho guidelines

4. **Learning Analytics:**
   - Track watch time, completion rate
   - Quiz scores và attempts
   - Recommend videos based on performance

5. **Accessibility:**
   - Subtitles cho videos
   - Text-to-speech cho procedures
   - High contrast mode option

---

## ✅ Completion Checklist

- [x] Analyzed Major Features (FE-09, FE-10, FE-11)
- [x] Reviewed Main Flow requirements
- [x] Designed 4 screens for Safety Guidelines
- [x] Written detailed Stitch prompts for each screen
- [x] Documented navigation flows
- [x] Specified API requirements
- [x] Added design principles and development notes
- [x] Included offline support considerations
- [x] Integrated progress tracking
- [x] Mapped access points from other flows

---

**END OF DOCUMENT**

*Tài liệu này cover đầy đủ UI Design cho Safety Guidelines module của Rescuer role. Format và màu sắc (Orange `#FF8A00`) đồng nhất với các flow khác của Rescuer (Emergency, Rescue Request, Expert Consultation, Profile).*
