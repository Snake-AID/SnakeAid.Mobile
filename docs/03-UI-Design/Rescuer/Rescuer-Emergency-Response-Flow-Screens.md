# EMERGENCY RESPONSE FLOW - UI DESIGN SCREENS (RESCUER ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **RESCUER/SUPPORTER** (Đội cứu hộ khẩn cấp cho sự cố rắn cắn)
- **Flow:** Emergency Response Flow (Phản hồi khẩn cấp cho sự cố rắn cắn)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 8 screens
- **Ngày tạo:** December 5, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Emergency-Response-Flow-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **RESCUER role** trong **Emergency Flow** (Swimlane 1 - Giai đoạn 1.3).
> Đây là flow khi Rescuer nhận yêu cầu SOS từ Patient bị rắn cắn khẩn cấp.

---

## 🎯 Flow Context (From Swimlane Diagram)

### Giai đoạn 1.3: KÍCH HOẠT SOS VÀ KẾT NỐI ĐỘI CỨU HỘ

**Rescuer's Journey trong Emergency Flow:**

```
1. Rescuer đang ONLINE và sẵn sàng nhận yêu cầu
   ↓
2. Backend match Rescuer gần nhất với yêu cầu SOS
   ↓
3. Rescuer nhận PUSH NOTIFICATION về sự cố khẩn cấp
   ↓
4. Rescuer xem chi tiết sự cố (loài rắn, mức độ, ảnh, GPS)
   ↓
5. Rescuer CHẤP NHẬN hoặc TỪ CHỐI yêu cầu
   ↓
6. Nếu CHẤP NHẬN → Bắt đầu di chuyển đến vị trí
   ↓
7. Cập nhật trạng thái: "Đang trên đường"
   ↓
8. Hệ thống tracking GPS real-time
   ↓
9. Rescuer đến nơi → Cập nhật: "Đã đến"
   ↓
10. Rescuer hỗ trợ sơ cứu cho Patient
    ↓
11. Hoàn thành nhiệm vụ
```

### Key Features for Rescuer in Emergency Flow:
- **FE-01:** Nhận và xem chi tiết yêu cầu SOS khẩn cấp
- **FE-02:** Xem thông tin loài rắn, mức độ nghiêm trọng, ảnh vết cắn
- **FE-06:** Chấp nhận/Từ chối yêu cầu
- **FE-07:** Cập nhật trạng thái (Đang đến / Đã đến / Đang xử lý / Hoàn thành)
- **FE-18:** GPS tracking real-time
- **FE-20:** Navigation đến vị trí Patient
- **FE-21:** Xem lại ảnh rắn và kết quả AI nhận diện
- **FE-09, FE-10:** Hướng dẫn an toàn xử lý rắn
- **FE-12:** Liên hệ Expert nếu cần hỗ trợ

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange-Red (Emergency) `#FF6B35`
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Emergency:** Red `#DC3545`
- **Accent - Warning:** Amber `#FFC107`
- **Status Online:** Green `#00C853`
- **Status Offline:** Gray `#9E9E9E`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)
- **Emergency Alert:** Bold (18-20pt)

### Component Style:
- **Cards:** Rounded corners (12px), prominent shadows for alerts
- **Buttons:** Rounded (8px), large touch targets (min 50px height)
- **Status Badges:** Rounded pills with color-coded backgrounds
- **Map View:** Full-screen with overlay controls
- **Emergency Indicators:** Pulsing animations, high contrast

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - đội cứu hộ phản hồi SOS khẩn cấp

---

### Screen 1: Rescuer Dashboard (Online/Ready State)

#### Thông tin màn hình:
- **Tên:** Màn hình chính của Rescuer - Dashboard
- **Mục đích:** Hiển thị trạng thái sẵn sàng, thống kê, và cho phép bật/tắt chế độ nhận yêu cầu
- **Flow position:** Điểm bắt đầu - Rescuer đang online chờ nhận yêu cầu
- **Priority:** ⭐⭐⭐ (Cao nhất)

#### Key Components:
1. **Header Section:**
   - Logo text "SnakeAid Rescuer" (bold, orange-red)
   - User avatar (top-right)
   - Notification bell with badge (if any pending)

2. **Status Toggle Card (Prominent):**
   - Large toggle switch: "Sẵn sàng nhận yêu cầu"
   - Current status: "ĐANG ONLINE" (green) / "OFFLINE" (gray)
   - Location indicator: "Quận 1, TP.HCM"
   - Last active time

3. **Today's Stats Dashboard:**
   - 3 stat cards in horizontal row:
     - "Yêu cầu hôm nay" (số lượng)
     - "Đã hoàn thành" (số lượng)
     - "Thu nhập hôm nay" (VNĐ)

4. **Active Mission Card (if any):**
   - Shows current ongoing mission
   - Status: "Đang trên đường" / "Đang xử lý"
   - Timer showing elapsed time
   - Button: "Tiếp tục"

5. **Recent Emergency Requests Section:**
   - Title: "Yêu cầu gần đây"
   - List of past missions (scrollable)
   - Each item shows: Date, Location, Status badge, Rating

6. **Quick Actions:**
   - "Hướng Dẫn An Toàn"
   - "Lịch sử cứu hộ"
   - "Thu nhập"
   - "Cài đặt"

7. **Bottom Navigation Bar:**
   - 4 tabs: "Trang chủ" (active), "Nhiệm vụ", "Bản đồ", "Cá nhân"

#### Stitch Prompt (English):

```
Mobile app dashboard for snake rescue emergency responder. Professional emergency service interface with orange-red (#FF6B35) primary color on white background.

Top header: Bold text logo "SnakeAid Rescuer" in orange-red on left. Circular user avatar top-right. Notification bell icon with small red badge "2" next to avatar.

Main content starts with prominent status card with subtle shadow. Card has large toggle switch on right side (in ON position, green). Left side shows large text "ĐANG ONLINE" in green (#00C853) with small green pulsing dot icon. Below status, location pin icon with gray text "Quận 1, TP.HCM". Bottom of card shows small gray text "Hoạt động lần cuối: 2 phút trước".

Below status card, section title "Thống Kê Hôm Nay" in dark gray. Three equal-width stat cards in horizontal row with light background:
- Card 1: Large number "12" in dark gray, small text "Yêu cầu" below
- Card 2: Large number "8" in green, small text "Đã hoàn thành" below  
- Card 3: Large number "1.2M VNĐ" in orange-red, small text "Thu nhập" below

Section titled "Nhiệm Vụ Hiện Tại" with white card showing:
- Red badge "ĐANG XỬ LÝ" on top-left
- Bold text "Cứu hộ rắn hổ mang"
- Gray text "123 Nguyễn Huệ, Q.1" with location pin icon
- Small gray text "Thời gian: 18 phút" with clock icon
- Orange-red button "Tiếp Tục" on bottom-right

Section "Yêu cầu Gần Đây" with 3 scrollable history cards. Each card shows:
- Date "15:30 - 05/12/2025" on top-left
- Location text "456 Lê Lợi, Q.1" with pin icon
- Green rounded badge "HOÀN THÀNH" on right
- Small yellow stars "5.0 ⭐" below badge

Section titled "Truy Cập Nhanh" with 4 horizontally arranged icon buttons (equal width):
- Button 1: Shield icon with "Hướng Dẫn An Toàn" text below (orange-red color)
- Button 2: History/clock icon with "Lịch Sử Cứu Hộ" text below
- Button 3: Money/wallet icon with "Thu Nhập" text below
- Button 4: Settings/gear icon with "Cài Đặt" text below

Bottom fixed navigation bar with 4 equally spaced tabs with icons and text:
"Trang Chủ" (active, orange-red), "Nhiệm Vụ", "Bản Đồ", "Cá Nhân" (inactive tabs in gray)

Design: Emergency service professional interface, clear status visibility, quick stats overview, emphasis on availability and current missions.
```

#### Notes for Stitch:
- Toggle switch phải rất prominent và dễ tap (min 60px height)
- Status ONLINE phải có pulsing dot animation để thu hút attention
- Stats cards phải dễ đọc nhanh trong tình huống emergency
- Current mission card (nếu có) phải nổi bật hơn các phần khác

---

### Screen 2: Emergency SOS Alert (Incoming Request)

#### Thông tin màn hình:
- **Tên:** Màn hình thông báo yêu cầu SOS khẩn cấp
- **Mục đích:** Alert Rescuer về yêu cầu khẩn cấp mới, hiển thị thông tin cơ bản
- **Flow position:** Bước 3 - Rescuer nhận push notification và mở alert
- **Priority:** ⭐⭐⭐ (Critical - Emergency Alert)

#### Key Components:
1. **Full-Screen Alert Overlay:**
   - Semi-transparent dark background
   - Alert card in center (can't be dismissed easily)

2. **Alert Card:**
   - Red pulsing border animation
   - Emergency icon (siren/alert)
   - Large bold text: "YÊU CẦU CỨU HỘ KHẨN CẤP"
   - Severity badge: "NGUY KỊCH" (red) / "NẶNG" (orange)

3. **Patient Info Preview:**
   - Patient name (or "Bệnh nhân ẩn danh")
   - Location with distance: "2.1 km từ bạn"
   - Time since incident: "Vừa xảy ra 3 phút trước"

4. **Snake Info Preview:**
   - AI-identified snake: "Rắn hổ mang chúa"
   - Risk level: "RẤT NGUY HIỂM" (red badge)
   - Thumbnail of snake photo

5. **Urgency Indicators:**
   - Countdown timer: "Phản hồi trong: 00:58" (1 minute countdown)
   - Text: "Bệnh nhân đang chờ"

6. **Action Buttons:**
   - Large primary button (green): "CHẤP NHẬN" (60px height)
   - Secondary button (gray): "Xem chi tiết"
   - Small text link: "Từ chối"

7. **Quick Info Icons:**
   - Distance icon
   - Time icon
   - Severity icon

#### Stitch Prompt (English):

```
Mobile app full-screen emergency alert overlay for snake rescuer. Critical incident notification with red (#DC3545) accents.

Dark semi-transparent overlay background (#000000 60% opacity) covering entire screen.

Center white card (90% screen width) with animated red pulsing border (3px). Card has rounded corners (16px) and strong shadow.

Top of card: Red circular icon with siren/bell symbol. Below icon, large bold red text "YÊU CẦU CỨU HỘ KHẨN CẤP" (20pt).

Below title, red rounded badge "NGUY KỊCH" with white text, prominent positioning.

Main info section in white card area:
- Bold dark text "Bệnh nhân ẩn danh" with small user icon
- Location line: pin icon + text "123 Nguyễn Huệ, Quận 1" in gray
- Distance line: ruler icon + bold orange text "2.1 km từ bạn"  
- Time line: clock icon + gray text "Vừa xảy ra 3 phút trước"

Horizontal divider line.

Snake info section:
- Small text "Loài rắn:" in gray
- Bold text "Rắn hổ mang chúa" with small red badge "RẤT NGUY HIỂM" next to it
- Small rounded rectangular thumbnail image placeholder (80x60px) on right side

Horizontal divider line.

Urgency section with amber background (#FFF3CD):
- Large countdown text "00:58" in red (bold, 24pt)
- Small text "Phản hồi trong:" above countdown
- Gray text "Bệnh nhân đang chờ" below

Bottom action section with 3 buttons vertically stacked:
- Extra large solid green button "CHẤP NHẬN" (60px height, bold text)
- Medium outlined gray button "Xem Chi Tiết" (50px height)
- Small text link "Từ chối" in gray, centered

Design: High-urgency alert interface, maximum visibility, clear call-to-action, time pressure emphasis, critical information hierarchy.
```

#### Notes for Stitch:
- Alert phải có pulsing animation để tạo urgency
- Countdown timer phải rõ ràng và lớn
- Button "CHẤP NHẬN" phải dominant nhất trong screen
- Không cho phép swipe-to-dismiss - user phải action
- Nếu countdown hết thời gian → Auto dismiss và gửi cho Rescuer khác

---

### Screen 3: Emergency Request Detail Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chi tiết yêu cầu cứu hộ khẩn cấp
- **Mục đích:** Hiển thị đầy đủ thông tin về sự cố để Rescuer đánh giá trước khi chấp nhận
- **Flow position:** Bước 4 - Rescuer tap "Xem chi tiết" từ alert
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button (quay lại alert)
   - Title: "Chi Tiết Yêu Cầu"
   - Countdown timer (top-right): "00:42"

2. **Severity Banner:**
   - Full-width colored banner based on severity
   - "NGUY KỊCH" (red) / "NẶNG" (orange) / "TRUNG BÌNH" (amber)
   - Icon indicating emergency level

3. **Patient Information Card:**
   - Patient name/ID
   - Contact button: "Gọi bệnh nhân"
   - Location with GPS coordinates
   - Time since incident
   - Current symptoms description (if any)

4. **Snake Identification Section:**
   - Large snake photo (swipeable gallery if multiple)
   - AI identification result:
     - Snake name: "Rắn hổ mang chúa"
     - Confidence: "95% chắc chắn"
     - Venomous status: "CỰC ĐỘC" badge
   - Button: "Xem hướng dẫn an toàn"

5. **Bite Information Section:**
   - Photo of bite wound (if uploaded)
   - Bite location on body: "Cẳng chân trái"
   - Visible symptoms from AI analysis
   - First aid status: "Đã băng ép" (green check) / "Chưa sơ cứu" (red)

6. **Location & Navigation Card:**
   - Mini map preview with pin
   - Full address
   - Distance: "2.1 km"
   - Estimated time: "8 phút (xe máy)"
   - Button: "Xem bản đồ đầy đủ"

7. **Safety Guidelines Section:**
   - Expandable accordion
   - "Hướng dẫn an toàn xử lý rắn hổ mang"
   - Equipment needed checklist
   - Warning signs

8. **Expert Support Option:**
   - Card showing: "Không chắc chắn?"
   - Button: "Liên hệ chuyên gia" (FE-12)

9. **Action Buttons (sticky bottom):**
   - Primary button (large, green): "CHẤP NHẬN NHIỆM VỤ"
   - Secondary button (outlined, gray): "TỪ CHỐI"

#### Stitch Prompt (English):

```
Mobile app emergency request detail screen for snake rescuer. Comprehensive incident information interface with orange-red theme.

Top navigation: Back arrow left, centered title "Chi Tiết Yêu Cầu", top-right red countdown timer "00:42" in bold.

Full-width red severity banner below header with white text "⚠️ NGUY KỊCH - CẦN PHẢN HỒI NGAY" centered (bold, 18pt).

Content area starts with white card titled "Thông Tin Bệnh Nhân" (bold, dark gray):
- Bold text "Nguyễn Văn A" with small user icon
- Gray text "Nam, 35 tuổi"
- Green outlined button "📞 Gọi Bệnh Nhân" (small, inline)
- Location pin icon + "123 Nguyễn Huệ, Quận 1, TP.HCM"  
- Clock icon + gray text "Bị cắn 8 phút trước"
- Small section "Triệu chứng:" with gray text "Đau dữ dội, sưng nhanh, khó thở"

Card titled "Nhận Diện Rắn - AI" with snake emoji icon:
- Large rectangular image placeholder showing snake photo (full width, 200px height)
- Small text row "1 / 3" on bottom-right of image (gallery indicator)
- Below image: Bold large text "Rắn hổ mang chúa" in dark gray
- Subtext: Green text "Độ tin cậy: 95%" with checkmark icon
- Prominent red rounded badge "CỰC ĐỘC" with skull icon
- Blue text link "Xem hướng dẫn an toàn xử lý rắn này →"

Card titled "Thông Tin Vết Cắn":
- Small rectangular image placeholder (120x90px) on left showing bite wound
- Right side text:
  - "Vị trí: Cẳng chân trái"
  - "Triệu chứng: Sưng nhanh, đỏ tím"
  - Green text with checkmark "✓ Đã băng ép"

Card titled "Vị Trí & Điều Hướng":
- Small map preview (full width, 120px height) with red pin marker
- Below map: Address text "123 Nguyễn Huệ, Quận 1"
- Two columns below:
  - Left: "📍 2.1 km" in bold orange
  - Right: "⏱️ 8 phút (xe máy)" in gray
- Blue outlined button "Xem Bản Đồ Đầy Đủ" (full width)

Expandable accordion section "Hướng Dẫn An Toàn" (collapsed state):
- Gray text "Xem hướng dẫn xử lý an toàn cho loài này"
- Down chevron icon on right

Light blue card with info icon:
- Text "Không chắc chắn về loài rắn?"
- Purple outlined button "Liên Hệ Chuyên Gia"

Bottom sticky section (white background with top shadow):
- Large solid green button "CHẤP NHẬN NHIỆM VỤ" (60px height)
- Medium outlined gray button "TỪ CHỐI" (50px height)

Design: Comprehensive emergency briefing, clear risk indicators, actionable intelligence, safety-first approach, prominent CTAs.
```

#### Notes for Stitch:
- Snake photo gallery phải swipeable nếu có nhiều ảnh
- Severity và venom level phải color-coded rõ ràng
- Safety guidelines có thể expandable để không quá dài
- Map preview phải interactive (tap để xem full)
- Nếu AI confidence < 70% → Show warning "Cần xác nhận với chuyên gia"

---

### Screen 4: Mission Accepted - Navigation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình điều hướng đến vị trí Patient
- **Mục đích:** Cung cấp navigation real-time và cho phép cập nhật trạng thái
- **Flow position:** Bước 6-7 - Sau khi Rescuer chấp nhận, bắt đầu di chuyển
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Full-Screen Map View:**
   - Real-time map (Google Maps/Apple Maps style)
   - Rescuer's current location (blue dot with accuracy circle)
   - Patient's location (red pulsing pin)
   - Suggested route (blue line)
   - Traffic indicators (if available)

2. **Status Bar (top overlay on map):**
   - Small white card with shadow
   - Current status: "ĐANG TRÊN ĐƯỜNG" (orange badge)
   - Change status button (tap to update)

3. **Mission Info Card (bottom overlay):**
   - Slide-up panel (can collapse/expand)
   - Collapsed state shows:
     - Patient name
     - Distance remaining: "1.8 km"
     - ETA: "6 phút"
     - Snake type: "Rắn hổ mang chúa"
   - Expanded state shows full details

4. **Navigation Controls:**
   - Re-center button (to center map on rescuer)
   - Zoom controls
   - 3D/2D view toggle
   - Traffic layer toggle

5. **Quick Actions Bar (overlay):**
   - Button: "Gọi bệnh nhân" (phone icon)
   - Button: "Nhắn tin" (message icon)
   - Button: "Xem chi tiết" (info icon)

6. **Status Update Menu (popup):**
   - "Đang trên đường" (default)
   - "Gặp trở ngại - Chậm hơn dự kiến"
   - "Đã đến gần - Đang tìm địa chỉ"
   - "Đã đến nơi"

7. **Emergency Options:**
   - Small floating button: "Cần hỗ trợ"
   - Options: Call 115, Contact Expert, Cancel mission

#### Stitch Prompt (English):

```
Mobile app navigation screen for emergency snake rescuer en route to patient. Full-screen map interface with overlay controls.

Full screen shows map view (light style similar to Google Maps). Map displays:
- Blue pulsing dot with accuracy circle representing rescuer's current location (center-bottom)
- Red pulsing pin marker showing patient destination (top area)
- Blue route line connecting the two points with directional arrow
- Street names and landmarks visible

Top status bar (white rounded card with shadow, floating over map):
- Left side: Orange rounded badge "ĐANG TRÊN ĐƯỜNG" with navigation icon
- Right side: Small gray text "Nhấn để cập nhật" with chevron down

Right side floating controls (vertically stacked on map):
- Small circular white button with crosshair icon (re-center)
- Small circular white button with plus icon (zoom in)
- Small circular white button with minus icon (zoom out)

Bottom of screen: Slide-up panel (white card with top rounded corners, shadow). Panel in collapsed state shows:
- Drag handle (gray bar) centered at top
- Left section:
  - Small text "Bệnh nhân:" in gray
  - Bold text "Nguyễn Văn A"
  - Small red badge "NGUY KỊCH"
- Center section:
  - Large bold orange text "1.8 km"
  - Small gray text "Còn lại" below
- Right section:
  - Large bold text "6 phút"
  - Small gray text "Thời gian ước tính" below

Above slide-up panel, horizontal row of 3 floating circular buttons (white background, shadow):
- Button 1: Green phone icon with text "Gọi" below
- Button 2: Blue message icon with text "Nhắn tin" below  
- Button 3: Gray info icon with text "Chi tiết" below

Bottom-right corner: Small red circular floating button with "SOS" text (emergency support).

Design: GPS navigation focused interface, real-time tracking, clear distance and ETA, quick communication access, emergency backup options.
```

#### Notes for Stitch:
- Map phải full-screen để maximize visibility
- Route line phải rõ ràng và có directional arrows
- ETA phải update real-time dựa trên GPS và traffic
- Slide-up panel phải smooth và có drag gesture
- Nếu Rescuer stop moving > 2 mins → Alert: "Bạn có gặp vấn đề gì không?"

---

### Screen 5: Arrival Confirmation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận đã đến nơi
- **Mục đích:** Xác nhận Rescuer đã đến location và sẵn sàng bắt đầu hỗ trợ
- **Flow position:** Bước 9 - Rescuer đến vị trí Patient
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận Đến Nơi"
   - Timer showing total travel time: "7 phút"

2. **Location Verification:**
   - Small map showing Rescuer at Patient's location
   - Text: "Bạn đang ở trong phạm vi 50m"
   - GPS accuracy indicator

3. **Patient Contact Card:**
   - "Liên hệ với bệnh nhân"
   - Phone number (masked): "090***1234"
   - Buttons: "Gọi điện" / "Nhắn tin"
   - Note: "Cho bệnh nhân biết bạn đã đến"

4. **Mission Preparation Checklist:**
   - Title: "Chuẩn Bị Trước Khi Vào"
   - Checkboxes:
     - ☑ "Đã liên hệ với bệnh nhân"
     - ☑ "Đã mang đủ thiết bị bảo hộ"
     - ☑ "Đã đọc hướng dẫn an toàn"
     - ☐ "Sẵn sàng hỗ trợ"

5. **Snake Info Reminder:**
   - Quick card showing:
     - Snake photo thumbnail
     - "Rắn hổ mang chúa - CỰC ĐỘC"
     - Button: "Xem lại hướng dẫn"

6. **Emergency Support:**
   - Card: "Cần hỗ trợ chuyên gia?"
   - Button: "Gọi chuyên gia rắn"
   - Text: "Miễn phí trong tình huống khẩn cấp"

7. **Status Update Section:**
   - Current status: "Đã đến nơi"
   - Auto-notification: "Bệnh nhân đã được thông báo"

8. **Action Button:**
   - Large primary button (green): "BẮT ĐẦU HỖ TRỢ"

#### Stitch Prompt (English):

```
Mobile app arrival confirmation screen for snake rescuer. Pre-mission checklist interface with orange-red theme.

Top navigation: Back arrow left, centered title "Xác Nhận Đến Nơi", top-right gray text "Thời gian di chuyển: 7 phút".

Top section: Small map preview (full width, 100px height) showing rescuer location with blue dot and patient location with red pin marker, both very close together. Below map, green success message with checkmark icon: "✓ Bạn đang ở trong phạm vi 50m".

White card titled "Liên Hệ Bệnh Nhân":
- Text "Cho bệnh nhân biết bạn đã đến" in gray
- Text "Số điện thoại: 090***1234" with phone icon
- Two equal-width buttons horizontally:
  - Green button "📞 Gọi Điện"
  - Blue outlined button "💬 Nhắn Tin"

White card titled "Chuẩn Bị" with checklist:
- Row 1: Green checkbox checked + text "Đã liên hệ với bệnh nhân"
- Row 2: Green checkbox checked + text "Đã mang đủ thiết bị bảo hộ"  
- Row 3: Green checkbox checked + text "Đã đọc hướng dẫn an toàn"
- Row 4: Empty checkbox + text "Sẵn sàng hỗ trợ"

White card titled "Nhắc Nhở - Thông Tin Rắn":
- Horizontal layout: Small snake thumbnail (60x60px) on left
- Right side text:
  - Bold "Rắn hổ mang chúa"
  - Red badge "CỰC ĐỘC" with skull icon
- Blue text link "Xem Lại Hướng Dẫn An Toàn →" below

Light purple card with info icon:
- Bold text "Cần Hỗ Trợ Chuyên Gia?"
- Gray text "Miễn phí trong tình huống khẩn cấp"
- Purple outlined button "Gọi Chuyên Gia Rắn"

White card with success styling:
- Green badge "ĐÃ ĐẾN NỖI"
- Gray text "Bệnh nhân đã được thông báo" with checkmark

Bottom section: Large solid green button "BẮT ĐẦU HỖ TRỢ" (60px height, bold text).

Design: Professional pre-mission protocol, safety verification, clear communication channels, expert backup access, confidence building.
```

#### Notes for Stitch:
- Location verification phải accurate (GPS threshold: 50m)
- Checklist phải require completion trước khi proceed
- Contact buttons phải functional và prominent
- Snake info reminder rất quan trọng cho safety
- Nếu Rescuer ở xa > 100m → Không cho phép "Bắt đầu hỗ trợ"

---

### Screen 6: Active Support Screen

#### Thông tin màn hình:
- **Tên:** Màn hình đang thực hiện hỗ trợ sơ cứu
- **Mục đích:** Cung cấp hướng dẫn sơ cứu và tracking thời gian hỗ trợ
- **Flow position:** Bước 10 - Rescuer đang hỗ trợ Patient tại chỗ
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button (confirm before exit)
   - Title: "Đang Hỗ Trợ Bệnh Nhân"
   - Live timer: "12:34" (elapsed time)

2. **Status Banner:**
   - Orange banner: "ĐANG XỬ LÝ"
   - Auto-update to Patient: "Đội cứu hộ đang hỗ trợ bạn"

3. **Patient Vital Monitoring (Optional):**
   - Quick input fields:
     - Consciousness level (Alert/Drowsy/Unconscious)
     - Breathing status
     - Pain level (1-10)
   - Button: "Lưu tình trạng"

4. **First Aid Guidance Tabs:**
   - Tab 1: "Sơ cứu ban đầu" (active)
   - Tab 2: "Xử lý vết cắn"
   - Tab 3: "Giảm đau"
   - Tab 4: "Chuẩn bị di chuyển"

5. **Current Step Card:**
   - Step indicator: "Bước 2/5"
   - Large instruction text with icon
   - Illustration/diagram (if applicable)
   - Checkbox: "Hoàn thành bước này"
   - Navigation: "Bước trước" / "Bước tiếp"

6. **Snake Handling Section (if snake still present):**
   - Title: "Xử Lý Rắn Tại Chỗ"
   - Status: "Rắn còn ở hiện trường" / "Rắn đã rời đi"
   - If present:
     - Button: "Bắt đầu bắt rắn"
     - Safety checklist
     - Equipment verification

7. **Emergency Escalation:**
   - Red card: "Tình trạng xấu đi?"
   - Button: "GỌI 115 NGAY" (large, red)
   - Button: "Liên hệ bác sĩ trực tuyến"

8. **Expert Consultation:**
   - "Cần tư vấn chuyên gia?"
   - Button: "Kết nối với chuyên gia" (FE-12)
   - Status: "Chuyên gia đang online"

9. **Documentation:**
   - Button: "Chụp ảnh vết cắn (sau xử lý)"
   - Button: "Ghi chú quan trọng"
   - Auto-save to case file

10. **Action Buttons (bottom):**
    - Primary: "HOÀN THÀNH HỖ TRỢ"
    - Secondary: "Cần xe cứu thương"

#### Stitch Prompt (English):

```
Mobile app active support screen for snake rescuer providing on-site emergency care. Medical assistance interface with orange-red theme.

Top navigation: Back arrow left with (X) icon, centered title "Đang Hỗ Trợ Bệnh Nhân", top-right orange timer "12:34" in bold with running clock icon.

Full-width orange banner below header: "⚕️ ĐANG XỬ LÝ" white text centered.

White card titled "Theo Dõi Tình Trạng Bệnh Nhân":
- Three horizontal status chips with dropdown arrows:
  - "Ý thức: Tỉnh táo" (green background)
  - "Hô hấp: Bình thường" (green background)
  - "Đau: 7/10" (amber background)
- Small blue text link "Cập nhật tình trạng" on right

Horizontal tab bar with 4 tabs (first active):
"Sơ Cứu Ban Đầu" (orange underline, bold) | "Xử Lý Vết Cắn" | "Giảm Đau" | "Di Chuyển"

Large white card showing current step:
- Top: Small gray badge "BƯỚC 2 / 5"
- Large icon: Bandage symbol
- Bold heading "Kiểm Tra Băng Ép"
- Body text in dark gray: "Đảm bảo băng không quá chặt. Kiểm tra tuần hoàn bằng cách nhấn nhẹ vào ngón tay/chân - phải hồng lại trong 2 giây."
- Small illustration placeholder (simple diagram, 150px height)
- Green checkbox (checked) + text "Hoàn thành bước này"
- Bottom: Two equal buttons:
  - Gray outlined "← Bước Trước"
  - Orange solid "Bước Tiếp →"

White card with amber border:
- Yellow warning icon left
- Bold text "Rắn Còn Ở Hiện Trường"
- Gray text "Hướng dẫn bắt rắn an toàn"
- Orange outlined button "Xem Hướng Dẫn Bắt Rắn"

Red outlined card:
- Red alert icon left
- Bold red text "Tình Trạng Xấu Đi?"
- Two buttons stacked:
  - Large red button "☎️ GỌI 115 NGAY"
  - Smaller outlined button "Liên Hệ Bác Sĩ Trực Tuyến"

Purple card with info icon:
- Text "Cần tư vấn chuyên gia rắn?"
- Small green dot + "2 chuyên gia đang online"
- Purple button "Kết Nối Với Chuyên Gia"

Bottom section with 3 action buttons:
- Small icon button "📷 Chụp Ảnh" (gray outlined)
- Small icon button "📝 Ghi Chú" (gray outlined)  
- Large solid green button "HOÀN THÀNH HỖ TRỢ" (full width, 60px height)

Design: Active medical support interface, step-by-step guidance, real-time monitoring, emergency escalation options, expert backup, documentation support.
```

#### Notes for Stitch:
- Timer phải rõ ràng để track thời gian hỗ trợ
- First aid steps phải có illustrations để dễ follow
- Emergency escalation (115) phải luôn accessible
- Vital signs monitoring giúp document case
- Expert consultation button phải prominent nếu Rescuer uncertain
- Photo documentation rất quan trọng cho báo cáo sau

---

### Screen 7: Mission Completion Screen

#### Thông tin màn hình:
- **Tên:** Màn hình hoàn thành nhiệm vụ
- **Mục đích:** Ghi nhận kết quả, documentation, và prepare cho next steps
- **Flow position:** Bước 11 - Sau khi hoàn thành hỗ trợ
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Hoàn Thành Nhiệm Vụ"
   - Success icon (checkmark)

2. **Mission Summary Card:**
   - Total time: "25 phút"
   - Status: "HOÀN THÀNH" (green badge)
   - Patient name
   - Location
   - Snake identified: "Rắn hổ mang chúa"

3. **Outcome Documentation:**
   - Section: "Kết Quả Hỗ Trợ"
   - Dropdown: "Tình trạng sau hỗ trợ"
     - "Ổn định - Không cần cấp cứu"
     - "Cần đưa đến bệnh viện"
     - "Đã gọi 115"
     - "Đã tự đi bệnh viện"
   - Text area: "Ghi chú bổ sung" (optional)

4. **Snake Status Section:**
   - "Tình trạng rắn:"
   - Options:
     - "Đã bắt và thả về môi trường"
     - "Đã bắt và giao nộp"
     - "Rắn đã rời đi"
     - "Không tìm thấy rắn"
   - If captured:
     - Button: "Upload ảnh rắn đã bắt"
     - Species confirmation

5. **Photo Gallery:**
   - Title: "Ảnh Chứng Từ"
   - Thumbnails of photos taken during mission
   - Button: "Thêm ảnh"

6. **Hospital Referral (if needed):**
   - "Bệnh nhân cần đến bệnh viện?"
   - Button: "Gợi ý bệnh viện gần nhất"
   - Option: "Tôi sẽ đưa bệnh nhân đi"

7. **Payment Information:**
   - Card showing:
     - "Phí dịch vụ: 300,000 VNĐ"
     - "Thời gian: 25 phút"
     - "Bệnh nhân sẽ thanh toán sau"
   - Note: "Thu nhập sẽ được chuyển sau 24h"

8. **Rating Request (optional):**
   - "Đánh giá mức độ hợp tác của bệnh nhân"
   - 5-star rating
   - Comment box (optional)

9. **Action Buttons:**
   - Primary: "XÁC NHẬN HOÀN THÀNH"
   - Secondary: "Lưu nháp" (if need more time)

#### Stitch Prompt (English):

```
Mobile app mission completion screen for snake rescuer. Post-mission documentation interface with green success theme.

Top navigation: Back arrow left, centered title "Hoàn Thành Nhiệm Vụ", large green checkmark icon on right.

Success banner: Light green background (#D4EDDA) with green checkmark icon and bold text "Nhiệm Vụ Hoàn Thành Thành Công".

White card titled "Tóm Tắt Nhiệm Vụ":
- Row 1: "Thời gian:" gray text | "25 phút" bold orange right-aligned
- Row 2: "Bệnh nhân:" gray | "Nguyễn Văn A" bold right
- Row 3: "Địa điểm:" gray | "123 Nguyễn Huệ, Q.1" right
- Row 4: "Loài rắn:" gray | "Rắn hổ mang chúa" bold with red badge "CỰC ĐỘC" right
- Green rounded badge "HOÀN THÀNH" at bottom-right

White card titled "Kết Quả Hỗ Trợ":
- Dropdown select (outlined, rounded) showing "Ổn định - Không cần cấp cứu" with down arrow
- Text area placeholder "Ghi chú bổ sung (không bắt buộc)" with light gray border, 3 lines height

White card titled "Tình Trạng Rắn":
- Radio button group (vertical):
  - ⦿ "Đã bắt và thả về môi trường" (selected, orange)
  - ○ "Đã bắt và giao nộp"
  - ○ "Rắn đã rời đi"
  - ○ "Không tìm thấy rắn"
- Since first option selected, show below:
  - Small text "Upload ảnh xác nhận:"
  - Horizontal row of 2 image thumbnails (80x80px each) with camera icon
  - Dashed border empty slot for "Thêm ảnh +"

White card titled "Ảnh Chứng Từ":
- Horizontal scrollable row of 4 image thumbnails (100x100px each)
- Plus button card at end "➕ Thêm Ảnh"

White card with blue border "Giới Thiệu Bệnh Viện":
- Text "Bệnh nhân cần đến bệnh viện?" in gray
- Blue outlined button "Gợi Ý Bệnh Viện Gần Nhất"
- Small checkbox + text "Tôi sẽ đưa bệnh nhân đi"

White card titled "Thông Tin Thanh Toán":
- Row 1: "Phí dịch vụ:" | bold green "300,000 VNĐ" right
- Row 2: "Thời gian thực hiện:" | "25 phút" right
- Small gray text "💡 Thu nhập sẽ được chuyển vào tài khoản sau 24h"

White card titled "Đánh Giá" (optional):
- Text "Đánh giá mức độ hợp tác của bệnh nhân"
- 5 large star outlines (clickable) horizontally centered
- Small text input "Nhận xét (không bắt buộc)"

Bottom section: Large solid green button "XÁC NHẬN HOÀN THÀNH" (60px height).

Design: Comprehensive mission documentation, outcome recording, evidence collection, payment transparency, quality feedback, professional closure.
```

#### Notes for Stitch:
- Documentation phải complete trước khi submit
- Photo evidence rất quan trọng cho dispute resolution
- Patient outcome phải track để phân tích hiệu quả
- Snake status giúp wildlife management
- Payment info phải transparent
- Nếu chọn "Cần đến bệnh viện" → Auto suggest hospitals và có thể share với Patient

---

### Screen 8: Post-Mission Summary Screen

#### Thông tin màn hình:
- **Tên:** Màn hình tóm tắt sau nhiệm vụ và feedback
- **Mục đích:** Hiển thị kết quả cuối cùng, payment status, và request rating từ Patient
- **Flow position:** Sau khi xác nhận hoàn thành - Screen cuối của flow
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Close button (X) - return to dashboard
   - Title: "Cảm Ơn Bạn"
   - Celebration icon/animation

2. **Success Message:**
   - Large icon: Trophy or medal
   - Text: "Bạn Đã Cứu Giúp Thành Công"
   - Subtext: "Nhiệm vụ đã được hoàn thành xuất sắc"

3. **Mission Stats Card:**
   - Total missions completed today: "9"
   - Total time in field today: "2 giờ 15 phút"
   - Today's earnings: "1,200,000 VNĐ"

4. **This Mission Details:**
   - Mission ID: "#RES-2025120501"
   - Date/Time completed
   - Duration: "25 phút"
   - Earnings: "300,000 VNĐ (Đang xử lý)"
   - Status: "Chờ thanh toán từ bệnh nhân"

5. **Payment Timeline:**
   - Step indicator:
     - ✓ "Hoàn thành nhiệm vụ"
     - ○ "Bệnh nhân xác nhận" (pending)
     - ○ "Thanh toán" (pending)
     - ○ "Nhận tiền" (24h)

6. **Rating Request:**
   - "Bệnh nhân sẽ đánh giá bạn"
   - Text: "Đánh giá tốt giúp bạn nhận nhiều yêu cầu hơn"
   - Current rating display: "4.9 ⭐ (128 đánh giá)"

7. **Share Achievement (Optional):**
   - "Chia sẻ thành tích"
   - Button: Share to social media
   - Text: "Hôm nay tôi đã cứu giúp 9 ca rắn cắn với SnakeAid"

8. **Next Steps:**
   - Card: "Tiếp tục nhận yêu cầu?"
   - Status toggle: Online/Offline
   - Button: "Sẵn sàng cho nhiệm vụ tiếp theo"

9. **Feedback & Support:**
   - "Gặp vấn đề với nhiệm vụ này?"
   - Button: "Báo cáo sự cố"
   - Button: "Liên hệ hỗ trợ"

10. **Action Buttons:**
    - Primary: "Về Trang Chủ"
    - Secondary: "Xem Chi Tiết Thu Nhập"

#### Stitch Prompt (English):

```
Mobile app post-mission summary screen for snake rescuer. Success celebration and earnings interface with green theme.

Top navigation: X close button left, centered title "Cảm Ơn Bạn!", small trophy icon right.

Hero section: Large gold trophy/medal icon centered. Below icon, large bold text "Bạn Đã Cứu Giúp Thành Công!" in dark gray. Smaller gray text "Nhiệm vụ đã được hoàn thành xuất sắc" below.

White card titled "Thống Kê Hôm Nay":
- Three columns equal width:
  - Column 1: Large bold "9" | small "Nhiệm vụ" gray text
  - Column 2: Large bold "2h 15m" | small "Thời gian" gray  
  - Column 3: Large bold green "1.2M VNĐ" | small "Thu nhập" gray

White card titled "Chi Tiết Nhiệm Vụ Này":
- Row 1: "Mã nhiệm vụ:" gray | "#RES-2025120501" bold right
- Row 2: "Thời gian:" gray | "05/12/2025 - 15:30" right
- Row 3: "Thời lượng:" gray | "25 phút" right
- Row 4: "Thu nhập:" gray | bold green "300,000 VNĐ" right
- Row 5: Small amber badge "ĐANG XỬ LÝ" with text "Chờ thanh toán từ bệnh nhân" right

White card titled "Tiến Trình Thanh Toán":
- Vertical stepper with 4 steps:
  - Step 1: Green checkmark + "Hoàn thành nhiệm vụ" (done)
  - Step 2: Gray circle + "Bệnh nhân xác nhận" (pending, gray text)
  - Step 3: Gray circle + "Thanh toán" (pending, gray text)
  - Step 4: Gray circle + "Nhận tiền (~24h)" (pending, gray text)
- Connecting line between steps (green for completed, gray for pending)

White card with star icon:
- Text "Bệnh nhân sẽ đánh giá bạn" in bold
- Gray text "Đánh giá tốt giúp bạn nhận nhiều yêu cầu hơn"
- Large display: "4.9 ⭐" with "(128 đánh giá)" gray text

Light blue card:
- Text "Tiếp tục nhận yêu cầu?"
- Toggle switch "Sẵn sàng nhận yêu cầu" (ON state, green)
- Small text "Bạn đang ONLINE" with green dot

White card with help icon:
- Text "Gặp vấn đề với nhiệm vụ này?"
- Two small outlined buttons horizontally:
  - Gray "Báo Cáo Sự Cố"
  - Gray "Liên Hệ Hỗ Trợ"

Bottom section with 2 buttons:
- Large solid green button "VỀ TRANG CHỦ" (60px height)
- Medium outlined orange button "Xem Chi Tiết Thu Nhập"

Design: Positive reinforcement, earnings transparency, clear payment timeline, encouragement for continued service, support access, smooth return to active duty.
```

#### Notes for Stitch:
- Success celebration tạo positive experience
- Stats cards motivate Rescuer với achievements
- Payment timeline giúp set expectations
- Rating reminder encourage quality service
- Quick return to online status để continue working
- Support options accessible nếu có issues

---

## 📊 SCREEN FLOW SUMMARY

### Complete Emergency Response Flow for Rescuer:

```
Screen 1: Dashboard (ONLINE)
    ↓ (Backend matches Rescuer with emergency SOS)
Screen 2: Emergency SOS Alert
    ↓ (Tap "Xem chi tiết" or countdown expires)
Screen 3: Emergency Request Detail
    ↓ (Tap "CHẤP NHẬN NHIỆM VỤ")
Screen 4: Mission Accepted - Navigation
    ↓ (GPS tracking while en route)
Screen 5: Arrival Confirmation
    ↓ (Tap "BẮT ĐẦU HỖ TRỢ")
Screen 6: Active Support Screen
    ↓ (Provide first aid, follow guidance)
Screen 7: Mission Completion
    ↓ (Document outcome, upload photos)
Screen 8: Post-Mission Summary
    ↓ (Return to Dashboard or Go Offline)
```

### Timing Breakdown:

| Screen | Typical Time Spent | Priority |
|--------|-------------------|----------|
| **Screen 1: Dashboard** | Continuous (while online) | ⭐⭐⭐ |
| **Screen 2: Alert** | 10-30 seconds (countdown) | ⭐⭐⭐ |
| **Screen 3: Detail** | 30-60 seconds (review) | ⭐⭐⭐ |
| **Screen 4: Navigation** | 5-15 minutes (travel time) | ⭐⭐⭐ |
| **Screen 5: Arrival** | 1-2 minutes (preparation) | ⭐⭐ |
| **Screen 6: Active Support** | 15-30 minutes (on-site) | ⭐⭐⭐ |
| **Screen 7: Completion** | 2-5 minutes (documentation) | ⭐⭐ |
| **Screen 8: Summary** | 1-2 minutes (review) | ⭐⭐ |

---

## 🔗 Integration Points

### Backend APIs Required:

1. **Mission Matching System:**
   - GET `/api/rescuer/available-missions` - Poll for new emergency requests
   - POST `/api/rescuer/missions/{id}/accept` - Accept mission
   - POST `/api/rescuer/missions/{id}/decline` - Decline mission

2. **GPS Tracking:**
   - POST `/api/rescuer/location` - Update real-time location
   - GET `/api/missions/{id}/route` - Get navigation route
   - WebSocket: Real-time location streaming

3. **Status Updates:**
   - PATCH `/api/missions/{id}/status` - Update mission status
   - POST `/api/missions/{id}/arrival` - Confirm arrival
   - POST `/api/missions/{id}/complete` - Complete mission

4. **Communication:**
   - POST `/api/missions/{id}/call-patient` - Initiate call
   - POST `/api/missions/{id}/message` - Send message
   - POST `/api/experts/request-consultation` - Request expert help (FE-12)

5. **Documentation:**
   - POST `/api/missions/{id}/photos` - Upload photos
   - POST `/api/missions/{id}/notes` - Add notes
   - POST `/api/missions/{id}/outcome` - Document outcome

6. **Payment:**
   - GET `/api/rescuer/earnings/today` - Get today's earnings
   - GET `/api/missions/{id}/payment-status` - Check payment status

---

## 🎯 Key Design Principles for Rescuer Emergency Flow

1. **Speed & Clarity:**
   - Large buttons (min 50px height) for quick tapping
   - High contrast colors for outdoor visibility
   - Minimal text, maximum icons

2. **Safety First:**
   - Always show snake identification and danger level
   - Easy access to expert consultation (FE-12)
   - Quick access to 115 emergency services

3. **Real-Time Updates:**
   - GPS tracking visible to Patient
   - Status changes auto-notify Patient
   - ETA updates based on traffic

4. **Professional Documentation:**
   - Photo evidence requirements
   - Outcome documentation
   - Time tracking for payment

5. **Trust & Transparency:**
   - Clear payment information
   - Rating system visibility
   - Support access at all times

---

## 📝 Notes for Development Team

### Critical Features:

1. **Background GPS Tracking:**
   - Must work even when app is in background
   - Battery optimization important
   - Accuracy within 10-20 meters

2. **Push Notifications:**
   - High-priority notifications for emergency alerts
   - Sound/vibration even in silent mode
   - Cannot be dismissed accidentally

3. **Offline Capability:**
   - Cache snake identification data
   - Store first aid guidelines offline
   - Queue API calls when no connection

4. **Emergency Fallbacks:**
   - Always provide way to call 115 directly
   - Expert consultation as backup
   - Manual status update if GPS fails

5. **Testing Scenarios:**
   - Test with poor GPS signal
   - Test with slow network
   - Test alert during ongoing mission (should reject)
   - Test timeout scenarios

---

## ✅ Completion Checklist

- [x] Analyzed Swimlane Diagram (Emergency Flow - Giai đoạn 1.3)
- [x] Reviewed Main Flow requirements
- [x] Created folder structure `/02-UI-Design/Rescuer/`
- [x] Designed 8 screens for Emergency Response Flow
- [x] Written detailed Stitch prompts for each screen
- [x] Documented flow integration points
- [x] Specified API requirements
- [x] Added design principles and development notes

---

**END OF DOCUMENT**

*Tài liệu này cover đầy đủ UI Design cho Rescuer role trong Emergency Response Flow (Swimlane 1 - Giai đoạn 1.3). Format và structure tương tự như Patient-Rescue-Request-Flow-Screens.md.*
