# 🚑 Emergency Rescue Flow - Rescuer Screens

## 📱 Screen Descriptions

### 1. **rescuer_home_screen.dart**
Màn hình chính của rescuer - hiển thị danh sách các yêu cầu SOS khẩn cấp đang chờ, thông tin rescuer (avatar, rating, số ca cứu hộ), toggle online/offline status, và thống kê thu nhập.

### 2. **rescuer_sos_detail_screen.dart**
Màn hình chi tiết yêu cầu SOS - hiển thị đầy đủ thông tin bệnh nhân (tên, vị trí GPS, khoảng cách), loài rắn đã xác định, mức độ nghiêm trọng, triệu chứng, và nút "Chấp nhận nhiệm vụ".

### 3. **rescuer_navigation_screen.dart**
Màn hình điều hướng đến bệnh nhân - real-time map navigation với vị trí rescuer (blue dot) và bệnh nhân (red pin), countdown distance/time, và nút "Đã đến nơi" khi trong phạm vi 50m.

### 4. **rescuer_arrived_screen.dart**
Màn hình xác nhận đã đến hiện trường - hiển thị thông tin tóm tắt bệnh nhân, checklist chuẩn bị (liên hệ bệnh nhân, thiết bị bảo hộ, hướng dẫn an toàn), thông tin rắn cần bắt, và nút "Bắt đầu hỗ trợ".

### 5. **rescuer_support_screen.dart**
Màn hình hỗ trợ active rescue - hướng dẫn từng bước bắt rắn an toàn, checklist thực hiện, timer đếm thời gian, thông tin sức khỏe bệnh nhân, và 2 nút chính: "Tìm bệnh viện gần nhất" và "Hoàn thành hỗ trợ".

### 6. **find_hospital_screen.dart**
Màn hình tìm bệnh viện gần nhất - map view với các marker bệnh viện có huyết thanh rắn, danh sách bệnh viện với khoảng cách, filter chips (Đang mở cửa, 24/7, Có huyết thanh), nút "Chỉ đường" (Google Maps) và "Gọi BV", photo evidence camera.

### 7. **mission_completion_screen.dart**
Màn hình hoàn thành nhiệm vụ - form chi tiết ghi nhận kết quả: mission summary (thời gian, bệnh nhân, loài rắn), patient outcome (dropdown + notes), snake status (4 radio options + ảnh), evidence photos (horizontal scroll), payment info (300K VNĐ + tip), và rating feedback.

### 8. **rescuer_mission_success_screen.dart**
Màn hình thành công nhiệm vụ - celebration screen với medal icon, today's stats (số ca, giờ làm, thu nhập), mission details (mã nhiệm vụ, thời gian, tiền), payment progress stepper (4 steps), rating display (4.9⭐), online/offline toggle, và nút "Về trang chủ".

---

## 🔄 Complete Rescue Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RESCUER HOME SCREEN (Toggle: ONLINE)                      │
│                       - Danh sách SOS requests                               │
│                       - Stats: Missions, Rating, Income                      │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Nhận yêu cầu SOS mới)
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. RESCUER SOS DETAIL SCREEN                                               │
│     - Thông tin bệnh nhân (Nguyễn Văn A)                                    │
│     - Vị trí GPS: 123 Nguyễn Huệ, Q1                                        │
│     - Khoảng cách: 2.1 km (8 phút)                                          │
│     - Loài rắn: Rắn hổ mang - CỰC ĐỘC                                       │
│     - Mức độ: NGUY KỊCH (85/100)                                            │
│     - Triệu chứng: Đau dữ dội, sưng nhanh, khó thở                          │
│     - Thời gian cắn: 12 phút trước                                          │
│     Button Options:                                                         │
│     • "Gọi điện" (outline green)                                            │
│     • "Từ chối" (outline red)                                               │
│     • "CHẤP NHẬN NHIỆM VỤ" (solid orange #FF8800)                           │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Chấp nhận)
┌─────────────────────────────────────────────────────────────────────────────┐
│  2. RESCUER NAVIGATION SCREEN                                               │
│     [MAP VIEW]                                                              │
│     - Blue dot với pulse effect (Rescuer vị trí)                            │
│     - Red pin với pulse effect (Bệnh nhân)                                  │
│     - Live distance: 1.8 km → 1.5 km → ... → 0.05 km                       │
│     - Estimated time: 6 phút → 5 phút → ... → 0 phút                        │
│                                                                             │
│     [TOP BAR]                                                               │
│     - Back button + SOS badge (red)                                         │
│     - Info: "123 Nguyễn Huệ • 1.8 km • 6 phút"                             │
│                                                                             │
│     [BOTTOM SHEET]                                                          │
│     - Avatar + Name: Nguyễn Văn A                                           │
│     - Status: "⚠️ NGUY KỊCH • Rắn hổ mang"                                  │
│     - Call button (orange circle)                                           │
│     - Info button → Back to SOS Detail                                      │
│     - Cancel button (red) → [CANCEL DIALOG]                                 │
│     - "Đã đến nơi" button (orange) → [ARRIVED DIALOG]                       │
│                                                                             │
│     [CANCEL DIALOG]                                                         │
│     - Radio options: Không thể đến / Không liên lạc / Việc khẩn /           │
│       Không nghiêm trọng / Lý do khác                                       │
│     - "Quay lại" / "Xác nhận hủy"                                           │
│                                                                             │
│     [ARRIVED DIALOG - when <50m]                                            │
│     - Icon: check_circle (orange)                                           │
│     - Title: "Xác Nhận Đã Đến Nơi?"                                         │
│     - Description: "Bệnh nhân sẽ được thông báo..."                         │
│     - Warning box (yellow): "Đảm bảo đúng vị trí"                           │
│     - "Chưa đến" / "Xác nhận" (orange)                                      │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Xác nhận đã đến)
┌─────────────────────────────────────────────────────────────────────────────┐
│  3. RESCUER ARRIVED SCREEN                                                  │
│     [SUCCESS BANNER]                                                        │
│     - Green background (#D4EDDA)                                            │
│     - Check icon + "Bạn đang ở trong phạm vi 50m"                           │
│                                                                             │
│     [CONTACT PATIENT CARD]                                                  │
│     - Phone masked: 090***1234                                              │
│     - "Gọi Điện" (orange) + "Nhắn Tin" (blue outline)                       │
│                                                                             │
│     [PREPARATION CHECKLIST]                                                 │
│     ☑ Đã liên hệ với bệnh nhân                                              │
│     ☑ Đã mang đủ thiết bị bảo hộ                                            │
│     ☑ Đã đọc hướng dẫn an toàn                                              │
│     ☐ Sẵn sàng hỗ trợ                                                       │
│                                                                             │
│     [SNAKE INFO REMINDER]                                                   │
│     - Image: Rắn hổ mang chúa                                               │
│     - Badge: "CỰC ĐỘC" (red)                                                │
│     - Link: "Xem Lại Hướng Dẫn An Toàn" (blue)                              │
│                                                                             │
│     [EXPERT SUPPORT CARD - Purple]                                          │
│     - "Cần Hỗ Trợ Chuyên Gia?"                                              │
│     - "Miễn phí trong tình huống khẩn cấp"                                  │
│     - "Gọi Chuyên Gia Rắn" (purple outline)                                 │
│                                                                             │
│     [ARRIVAL STATUS]                                                        │
│     - Badge: "ĐÃ ĐẾN NƠI" (orange)                                          │
│     - Checkmark: "Bệnh nhân đã được thông báo"                              │
│                                                                             │
│     [BOTTOM BUTTON]                                                         │
│     - "BẮT ĐẦU HỖ TRỢ" (solid orange #FF8800)                               │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Bắt đầu hỗ trợ)
┌─────────────────────────────────────────────────────────────────────────────┐
│  4. RESCUER SUPPORT SCREEN                                                  │
│     [TOP BAR]                                                               │
│     - Back + Live Timer: "25:30" (counting up)                              │
│     - Warning badge: "CỰC ĐỘC" (red pulsing)                                │
│                                                                             │
│     [MISSION INFO CARD - Orange accent]                                     │
│     - Code: #RES-2025120501                                                 │
│     - Patient: Nguyễn Văn A                                                 │
│     - Snake: Rắn hổ mang - CỰC ĐỘC                                          │
│     - Time started: 14:23                                                   │
│                                                                             │
│     [PATIENT HEALTH STATUS - Green checks]                                  │
│     - Ý thức: Tỉnh táo ✓                                                    │
│     - Hô hấp: Bình thường ✓                                                 │
│     - Vết cắn: Đã băng ép ✓                                                 │
│     - First aid: Đã sơ cứu ✓                                                │
│                                                                             │
│     [RESCUE STEPS CHECKLIST - Expandable sections]                          │
│     1. An toàn cá nhân (4 items)                                            │
│        ☑ Mang găng tay dày                                                  │
│        ☑ Đeo kính bảo hộ                                                    │
│        ☑ Giữ khoảng cách 2m                                                 │
│        ☐ Chuẩn bị dụng cụ bắt                                               │
│                                                                             │
│     2. Đánh giá tình huống (3 items)                                        │
│     3. Tiếp cận an toàn (4 items)                                           │
│     4. Bắt và kiểm soát (3 items)                                           │
│     5. Chuyển rắn an toàn (2 items)                                         │
│                                                                             │
│     [EXPERT HOTLINE - Purple]                                               │
│     - "Cần hỗ trợ từ chuyên gia rắn?"                                       │
│     - "1900-SNAKE" + Call button                                            │
│                                                                             │
│     [BOTTOM ACTIONS]                                                        │
│     • "Tìm bệnh viện gần nhất" (blue outline) → Find Hospital               │
│     • "HOÀN THÀNH HỖ TRỢ" (solid orange) → Completion                       │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Tìm bệnh viện)
┌─────────────────────────────────────────────────────────────────────────────┐
│  5. FIND HOSPITAL SCREEN (Optional)                                         │
│     [MAP VIEW]                                                              │
│     - Red circular pins với số (1, 2, 3)                                    │
│     - Blue dot: Your location                                               │
│                                                                             │
│     [SEARCH BAR]                                                            │
│     - "Tìm bệnh viện..."                                                    │
│     - Chip: "Dùng vị trí của tôi" (green)                                   │
│                                                                             │
│     [FILTER CHIPS]                                                          │
│     - Đang mở cửa                                                           │
│     - 24/7                                                                  │
│     - Có huyết thanh                                                        │
│     - Gần nhất                                                              │
│                                                                             │
│     [HOSPITAL CARDS LIST]                                                   │
│     1. BV Chợ Rẫy (2.3 km)                                                  │
│        • 24/7 • Huyết thanh đầy đủ • 4.8⭐                                   │
│        [Chỉ đường] [Gọi BV]                                                 │
│                                                                             │
│     2. BV Quận 10 (5.1 km)                                                  │
│     3. BV Nguyễn Tri Phương (6.8 km)                                        │
│                                                                             │
│     [PHOTO EVIDENCE SECTION]                                                │
│     - Grid: Ảnh 1, Ảnh 2, + Camera icon                                     │
│     - "Chụp ảnh bằng chứng di chuyển"                                       │
│                                                                             │
│     [BOTTOM BUTTON]                                                         │
│     - "HOÀN THÀNH HỖ TRỢ" (orange) → [CONFIRMATION DIALOG]                  │
│                                                                             │
│     [CONFIRMATION DIALOG]                                                   │
│     - Icon: check_circle (orange)                                           │
│     - "Xác nhận hoàn thành?"                                                │
│     - "Bệnh nhân đã an toàn?"                                               │
│     - Warning: "Không thể hoàn tác"                                         │
│     - "Quay lại" / "Xác nhận" → Completion Screen                           │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Hoàn thành hỗ trợ)
┌─────────────────────────────────────────────────────────────────────────────┐
│  6. MISSION COMPLETION SCREEN                                               │
│     [SUCCESS BANNER - Green]                                                │
│     - "Cảm ơn bạn đã cứu giúp thành công!"                                  │
│                                                                             │
│     [MISSION SUMMARY CARD]                                                  │
│     - Underline bar (orange)                                                │
│     - Gray container with icons:                                            │
│       🕐 Thời gian: 25 phút                                                 │
│       👤 Bệnh nhân: Nguyễn Văn A                                            │
│       📍 Địa điểm: 123 Nguyễn Huệ                                           │
│       🐍 Loài rắn: Rắn hổ mang - Badge: "CỰC ĐỘC" (red)                    │
│     - Status badge: "HOÀN THÀNH" (orange)                                   │
│                                                                             │
│     [PATIENT OUTCOME SECTION]                                               │
│     - Underline bar (orange)                                                │
│     - Dropdown: "Chọn kết quả..." (Ổn định/Cần cấp cứu)                     │
│     - Textarea: "Ghi chú thêm về tình trạng..."                             │
│                                                                             │
│     [SNAKE STATUS SECTION]                                                  │
│     - Underline bar (orange)                                                │
│     - Radio options (orange when selected):                                 │
│       ○ Đã bắt và thả về môi trường tự nhiên                                │
│       ○ Đã bắt và giao nộp cho cơ quan chức năng                            │
│       ○ Rắn đã rời đi, không bắt được                                       │
│       ○ Không tìm thấy rắn tại hiện trường                                  │
│     - "Thêm ảnh rắn" + Camera icon                                          │
│     - Horizontal scroll: [Image 1] [Image 2] [+]                            │
│                                                                             │
│     [EVIDENCE PHOTOS SECTION]                                               │
│     - "Ảnh bằng chứng hiện trường"                                          │
│     - Horizontal scroll gallery                                             │
│     - Camera button to add more                                             │
│                                                                             │
│     [PAYMENT INFORMATION CARD]                                              │
│     - Gradient orange background                                            │
│     - Prominent: "300,000 VNĐ" (large, orange)                              │
│     - "Thời gian: 25 phút • Khoảng cách: 2.1 km"                           │
│     - Tip box (yellow):                                                     │
│       "💡 Hoàn thành trước 24h nhận thêm 50,000đ tiền thưởng!"             │
│                                                                             │
│     [FEEDBACK SECTION]                                                      │
│     - "Đánh giá trải nghiệm"                                                │
│     - 5 stars rating (tap to select)                                        │
│     - Textarea: "Chia sẻ thêm về ca cứu hộ này..."                          │
│                                                                             │
│     [BOTTOM BUTTON]                                                         │
│     - "XÁC NHẬN HOÀN THÀNH" (orange) → [FINAL DIALOG]                       │
│                                                                             │
│     [FINAL CONFIRMATION DIALOG]                                             │
│     - Icon: check_circle (orange)                                           │
│     - "Gửi báo cáo hoàn thành?"                                             │
│     - "Tất cả thông tin đã chính xác?"                                      │
│     - "Quay lại kiểm tra" / "Xác nhận" → Success Screen                     │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓ (Xác nhận)
┌─────────────────────────────────────────────────────────────────────────────┐
│  7. RESCUER MISSION SUCCESS SCREEN                                          │
│     [HERO SECTION]                                                          │
│     - Medal icon (yellow #FFC107) in circle                                 │
│     - "Bạn Đã Cứu Giúp Thành Công!"                                         │
│     - "Cảm ơn vì sự dũng cảm và tận tâm"                                    │
│                                                                             │
│     [TODAY'S STATS - 3 columns with dividers]                               │
│     - 9 | 2h 15m | 1.2M VNĐ (orange)                                        │
│       Nhiệm vụ | Thời gian | Thu nhập                                       │
│                                                                             │
│     [MISSION DETAILS CARD]                                                  │
│     - Code: #RES-2025120501                                                 │
│     - Datetime: 28/01/2026 • 14:23                                          │
│     - Duration: 25 phút                                                     │
│     - Amount: 300,000 VNĐ (large, orange)                                   │
│     - Status badge: "ĐANG XỬ LÝ" (yellow)                                   │
│                                                                             │
│     [PAYMENT PROGRESS - Vertical Stepper]                                   │
│     - Title: "Tiến Trình Thanh Toán"                                        │
│     1. ✓ Hoàn thành nhiệm vụ (orange circle + check)                        │
│     2. ○ Xác nhận bởi bệnh nhân (~1h)                                       │
│     3. ○ Xử lý thanh toán (~2h)                                             │
│     4. ○ Nhận tiền vào tài khoản (~24h)                                     │
│     - Connecting lines: 2px orange                                          │
│                                                                             │
│     [RATING CARD]                                                           │
│     - "Đánh Giá Của Bạn"                                                    │
│     - 4.9 ⭐ (128 đánh giá)                                                  │
│     - Text: "Điểm đánh giá cao giúp nhận nhiều yêu cầu hơn"                 │
│                                                                             │
│     [AVAILABILITY SECTION]                                                  │
│     - "Tiếp tục nhận yêu cầu?"                                              │
│     - Online indicator: Dot (orange) + "Đang hoạt động"                     │
│     - Switch toggle: ONLINE/OFFLINE (orange when active)                    │
│                                                                             │
│     [SUPPORT SECTION]                                                       │
│     - Row of 2 outlined buttons:                                            │
│       • "Báo Cáo Sự Cố" (red outline)                                       │
│       • "Liên Hệ Hỗ Trợ" (blue outline)                                     │
│                                                                             │
│     [BOTTOM ACTIONS]                                                        │
│     • "VỀ TRANG CHỦ" (solid orange) → Rescuer Home                          │
│     • "Xem Chi Tiết Thu Nhập" (yellow outline) → Income Screen              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features by Screen

### 🟠 Main Flow (Happy Path)
**Home** → **SOS Detail** → **Navigation** → **Arrived** → **Support** → **Completion** → **Success**

### 🔵 Alternative Paths

**Path A: Với Hospital Transfer**
- Support → Find Hospital → (Google Maps) → Completion → Success

**Path B: Emergency Expert Support**
- Arrived Screen → Call Expert (purple button)
- Support Screen → Expert Hotline (1900-SNAKE)

**Path C: Mission Cancellation**
- Navigation → Cancel button → Select reason → Confirm → Back to Home

**Path D: Photo Evidence**
- Find Hospital → Camera → Take photos → Completion
- Completion → Snake photos + Evidence photos

---

## 📊 Navigation Decision Tree

```
Rescuer Home (ONLINE)
└─ New SOS Request → SOS Detail
   ├─ "Từ chối" → Back to Home
   ├─ "Gọi điện" → Phone call
   └─ "CHẤP NHẬN" → Navigation Screen
      ├─ "Hủy nhiệm vụ" → [Reason Dialog] → Home
      ├─ "Info" → Back to SOS Detail
      └─ "Đã đến nơi" (<50m) → [Confirm Dialog] → Arrived
         └─ "Bắt đầu hỗ trợ" → Support Screen
            ├─ "Gọi chuyên gia" → Expert call
            ├─ "Tìm bệnh viện" → Find Hospital
            │  ├─ "Chỉ đường" → Google Maps
            │  ├─ "Gọi BV" → Phone call
            │  └─ "Hoàn thành" → [Confirm] → Completion
            └─ "Hoàn thành hỗ trợ" → [Confirm] → Completion
               └─ Fill form → "Xác nhận" → [Final Dialog] → Success
                  ├─ "Về trang chủ" → Rescuer Home
                  └─ "Xem thu nhập" → Income Screen
```

---

## 🎨 Design System - Rescuer Brand

### Colors (UPDATED - Orange Theme)
- **Primary Orange**: `#FF8800` - All action buttons, rescuer branding
- **Success Green**: `#28A745` - Health status indicators ONLY (not buttons)
- **Danger Red**: `#DC3545` - Poisonous snakes, critical alerts, cancel
- **Warning Yellow**: `#FFC107` - Tips, processing status, medals
- **Expert Purple**: `#8A2BE2` - Expert support features
- **Info Blue**: `#007AFF` - Information, maps, hospital links
- **Background**: `#F8F7F5` - App background
- **Card White**: `#FFFFFF` - Content cards

### Color Usage Guidelines
#### ✅ Orange (#FF8800) - Action Buttons
- "Chấp nhận nhiệm vụ"
- "Đã đến nơi" confirmation
- "Bắt đầu hỗ trợ"
- "Hoàn thành hỗ trợ"
- "Xác nhận hoàn thành"
- All primary CTA buttons
- Progress indicators (completed steps)
- Payment amounts, earnings
- Online/active states

#### ✅ Green (#28A745) - Status Indicators ONLY
- Health check icons (Ý thức ✓, Hô hấp ✓)
- Checklist completions (semantic meaning)
- Proximity confirmation ("Trong phạm vi 50m")
- Status: "Đang hoạt động"

#### 🚫 Green NOT used for:
- Action buttons
- Dialog backgrounds
- Primary interactions

### Typography
- **Headings**: 16-28px, Bold (w700-w800)
- **Body**: 12-16px, Regular/Medium (w400-w600)
- **Stats/Numbers**: 24-56px, ExtraBold (w800)
- **Captions**: 10-12px, Medium (w500-w600)

### Components
- **Cards**: White bg, rounded 12-20px, shadow 0.04-0.06 opacity
- **Buttons**: 
  - Primary: Orange #FF8800, rounded 12px, bold text
  - Outlined: Border color matches purpose (red/blue/purple)
  - Height: 48-56px for main actions
- **Badges**: 
  - Rounded pill, colored bg + border
  - "CỰC ĐỘC" (red), "HOÀN THÀNH" (orange), "ĐANG XỬ LÝ" (yellow)
- **Dialogs**: CustomDialog widget with icon circle
- **Progress**: Vertical stepper with orange circles + checks
- **Underline bars**: 40px width, 4px height, orange accent

---

## 🔧 Technical Notes

### State Management
- **Timers**: Countdown in Navigation, Count-up in Support
- **Checklists**: StatefulWidget with List<bool> for checkboxes
- **Expansion**: Sections collapse/expand in Support screen
- **Toggle**: Online/Offline switch with orange active color

### Navigation
- `context.pushNamed()` - Forward (preserves stack)
- `context.pop()` - Go back
- `context.goNamed()` - Replace (for Home return)

### Key Widgets
- **Maps**: Google Maps for navigation and hospital finder
- **Camera**: `image_picker` for photo evidence
- **Phone**: `url_launcher` for calls and Google Maps directions
- **Stepper**: Custom vertical stepper for payment progress
- **Chips**: Filter chips in hospital finder

### External Integrations
```dart
// Phone call
await launch('tel:${phoneNumber}');

// Google Maps directions
final url = 'https://maps.google.com/?q=$latitude,$longitude';
await launch(url);

// Camera
final image = await ImagePicker().pickImage(source: ImageSource.camera);
```

### Data Models
```dart
// Mission data
- missionId: String
- patientName: String
- location: LatLng
- snakeType: String
- severity: int (0-100)
- symptoms: List<String>
- startTime: DateTime
- duration: Duration
- payment: double

// Checklist items
- step: String
- isCompleted: bool
- isRequired: bool
```

---

## 📝 Notes for Developers

### Critical Features
1. **Real-time location tracking** - Update every 3s in Navigation
2. **Distance calculation** - Trigger "Đã đến nơi" when <50m
3. **Timer accuracy** - Use `Timer.periodic` for consistent updates
4. **Photo compression** - Reduce image size before upload
5. **Offline handling** - Cache mission data locally

### Safety Checks
- ✅ Confirm before accepting mission (distance, snake type)
- ✅ Checklist must complete before "Bắt đầu hỗ trợ"
- ✅ Double confirmation for completion
- ✅ Expert hotline always visible in danger situations
- ✅ Cancel with reason tracking

### UX Patterns
- **Progressive disclosure**: Expandable sections in Support
- **Visual hierarchy**: Orange for primary actions, outlines for secondary
- **Status indicators**: Color-coded badges, icons with meaning
- **Feedback loops**: Success banners, confirmation dialogs
- **Accessibility**: Large touch targets (48x48), high contrast

---

## 🚀 Future Enhancements

- [ ] Voice commands for hands-free operation
- [ ] AR overlay for snake identification in field
- [ ] Live video call with expert during rescue
- [ ] Auto-route optimization based on traffic
- [ ] Offline mode with sync when online
- [ ] Team rescue coordination (multiple rescuers)
- [ ] Equipment checklist with smart alerts
- [ ] Weather warnings for safety
- [ ] Snake behavior predictions (time/location)
- [ ] Automated report generation
- [ ] Integration with hospital ERs
- [ ] Insurance claim automation
- [ ] Training module for new rescuers
- [ ] Gamification: Badges, leaderboards

---

## 🔗 Integration Points

### Backend APIs
```
POST /api/rescuer/accept-mission
GET  /api/rescuer/mission-details/:id
POST /api/rescuer/update-location
POST /api/rescuer/arrived-confirmation
POST /api/rescuer/complete-mission
POST /api/rescuer/upload-evidence
GET  /api/hospitals/nearby
POST /api/rescuer/toggle-online
```

### Third-party Services
- **Google Maps API**: Navigation, directions, hospital search
- **Twilio**: Phone calls, SMS
- **Firebase Cloud Messaging**: Push notifications for new SOS
- **Cloudinary**: Image upload and optimization
- **Stripe**: Payment processing

---

## 📊 Metrics & Analytics

### Track These Events
1. **Mission funnel**:
   - SOS received → Viewed → Accepted → Started → Completed
2. **Time metrics**:
   - Response time (SOS → Accept)
   - Arrival time (Accept → On-site)
   - Mission duration (Start → Complete)
3. **Success rates**:
   - Completion rate
   - Patient safety rate
   - Snake capture rate
4. **Quality scores**:
   - Average rating
   - Expert call frequency
   - Photo evidence quality

---

## 🎯 Business Rules

### Payment Calculation
```
Base fee: 300,000 VNĐ
+ Distance bonus: 10,000 VNĐ per km > 5km
+ Urgency bonus: 50,000 VNĐ if completed <24h from bite
+ Danger bonus: 100,000 VNĐ if "CỰC ĐỘC" snake
+ Rating bonus: 20,000 VNĐ if rescuer rating > 4.5⭐
- Penalty: -50,000 VNĐ if >30min response time
```

### Online Status
- Auto-offline after 12h continuous online
- Auto-offline after 3 rejected missions
- Manual toggle available anytime
- Notifications only when online

### Mission Assignment
- Nearest available rescuer gets priority
- Rating >4.0 required for "CỰC ĐỘC" missions
- Max 3 active missions per rescuer
- Auto-reassign if no response in 2 minutes

---

**Last Updated**: January 29, 2026  
**Version**: 1.0.0  
**Team**: SnakeAid Rescuer Development Team  
**Design**: Orange Brand Identity (#FF8800)
