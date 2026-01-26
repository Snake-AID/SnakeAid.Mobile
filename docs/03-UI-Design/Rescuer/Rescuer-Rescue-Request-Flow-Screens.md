# RESCUE REQUEST FLOW - UI DESIGN SCREENS (RESCUER ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **SNAKE RESCUER** (Đội cứu hộ rắn chuyên nghiệp)
- **Flow:** Rescue Request Flow (Luồng yêu cầu cứu hộ rắn)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 10 screens
- **Ngày tạo:** December 8, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Rescue-Request-Flow-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **RESCUER role** trong **Rescue Request Flow** (Swimlane 2).
> Đây là flow khi Patient phát hiện rắn (chưa bị cắn) và yêu cầu đội cứu hộ đến bắt rắn.

---

## 🎯 Flow Context (From Swimlane Diagram)

### Rescuer's Journey trong Rescue Request Flow:

> **🎯 FIRST COME, FIRST SERVED MODEL:** Rescue Request sử dụng mô hình ai nhận trước người đó làm (giống Grab/Uber)
> Patient đăng yêu cầu → Rescuers trong bán kính nhìn thấy → Rescuer nhanh nhất NHẬN ĐƠN → Bắt đầu làm việc

```
1. Rescuer đang ONLINE sẵn sàng nhận yêu cầu cứu hộ
   ↓
2. Patient đăng yêu cầu cứu hộ lên hệ thống
   ↓
3. Backend tìm rescuers theo logic RADAR BÁN KÍNH:
   • Ưu tiên: Tìm trong bán kính 10km
   • Nếu < 3 rescuers trong 10km → Mở rộng 20km
   • Nếu vẫn < 3 rescuers → Tối đa 30km
   • Thông báo cho patient về việc mở rộng bán kính
   ↓
4. Rescuer nhận PUSH NOTIFICATION: "Yêu cầu mới gần bạn (X.X km)"
   - Tap notification → Mở app → Tab "Đơn Có Thể Nhận" (Job Board)
   ↓
5. Rescuer xem DANH SÁCH các yêu cầu trong bán kính (JOB BOARD)
   - Hiển thị tất cả requests đang chờ trong 10km/20km/30km
   - Mỗi request card: Ảnh rắn, loài, khoảng cách, giá cố định, thời gian đăng
   - Status: "Đang chờ Rescuer" (hiển thị số người đang xem)
   - Filter: Khoảng cách / Loài rắn / Độ nguy hiểm
   - Sort: Gần nhất / Mới nhất / Giá cao
   ↓
6. Rescuer tap vào request → Xem chi tiết đầy đủ
   - Ảnh rắn (nhiều góc độ)
   - Kết quả AI nhận diện loài rắn (FE-21)
   - Mức độ nguy hiểm và hướng dẫn an toàn
   - Vị trí GPS chính xác + khoảng cách
   - Giá CỐ ĐỊNH theo hệ thống (575K/con - sẽ tính lại sau)
   - Thông tin patient (tên, địa chỉ, ghi chú)
   ↓
7. Rescuer NHẬN ĐƠN NGAY (FIRST COME, FIRST SERVED)
   - Button: "NHẬN ĐƠN NGAY" - không cần chờ duyệt
   - Hệ thống check: Nếu đơn còn trống → Nhận thành công
   - Nếu đã có rescuer khác nhận trước → Hiển thị "Đơn đã có người nhận"
   ↓
8. NHẬN ĐƠN THÀNH CÔNG:
   - Hiển thị: "Đã nhận đơn thành công!"
   - Thông tin patient đầy đủ (tên, sđt, địa chỉ)
   - Map và navigation
   - Button: "Bắt Đầu Di Chuyển"
   - Patient nhận thông báo: "Rescuer [Tên] đã nhận đơn!"
   ↓
9. Xem lại thông tin rắn và hướng dẫn an toàn (FE-09, FE-10, FE-21)
   - Chuẩn bị thiết bị cần thiết (FE-23)
   ↓
10. [Optional] Nếu không chắc về loài rắn → Liên hệ Expert (FE-12)
    ↓
11. Bắt đầu di chuyển
    - Cập nhật trạng thái: "Đang trên đường" (FE-07)
    - Bật GPS tracking real-time (FE-18)
    - Navigation đến vị trí (FE-19)
    ↓
12. Patient theo dõi vị trí Rescuer trên bản đồ (FE-24, FE-25, FE-26)
    ↓
15. Rescuer đến nơi
    - Cập nhật trạng thái: "Đã đến" (FE-20)
    - Gặp Patient, khảo sát vị trí rắn
    ↓
14. Thực hiện bắt rắn
    - Cập nhật trạng thái: "Đang xử lý" (FE-07)
    - Áp dụng quy trình an toàn
    ↓
15. Sau khi bắt xong
    - Chụp ảnh rắn đã bắt (FE-16)
    - Xác nhận lại loài rắn
    - NHẬP THÔNG TIN HOÀN THÀNH:
      • Số lượng rắn bắt được
      • Độ khó (Dễ/Trung bình/Khó)
      • Thời gian thực tế
      • Upload ảnh minh chứng
    - HỆ THỐNG TỰ ĐỘNG TÍNH GIÁ CUỐI dựa trên:
      • Số lượng rắn
      • Độ độc của rắn
      • Difficulty level
      • Khoảng cách di chuyển
      • Thời gian xử lý
    - Hiển thị giá cuối: "Giá cuối cùng: 650,000 VNĐ" (ví dụ)
    - Cập nhật trạng thái: "Hoàn thành" (FE-07)
    - Ghi nhận chi tiết vào database (FE-15)
    ↓
16. Thanh toán SAU KHI HOÀN THÀNH (Giai đoạn 2.4)
    - Rescuer đợi patient thanh toán (giá đã được hệ thống tính)
    - Patient thanh toán TOÀN BỘ giá cuối (KHÔNG có đặt cọc trước)
    - Rescuer nhận thanh toán (FE-26)
    - Patient đánh giá Rescuer
    - Rescuer xem đánh giá (FE-27)
```

### Key Features for Rescuer in Rescue Request Flow:
- **FE-01:** Nhận thông báo yêu cầu cứu hộ rắn với ảnh và vị trí
- **FE-02:** Xem chi tiết yêu cầu: loài rắn dự đoán, mức độ nguy hiểm
- **FE-03:** Xác nhận loại rắn (có độc/không độc) từ hình ảnh
- **FE-04:** Cập nhật kết quả xác minh lên hệ thống
- **FE-06:** Chấp nhận hoặc từ chối yêu cầu cứu hộ
- **FE-07:** Cập nhật tiến độ (Đang đến / Đã đến / Đang xử lý / Hoàn thành)
- **FE-09, FE-10:** Quy trình chuẩn bắt rắn an toàn, thiết bị cần thiết
- **FE-12:** Liên lạc với chuyên gia để nhận diện chính xác
- **FE-15:** Ghi nhận chi tiết cứu hộ (vị trí, thời gian, loài rắn, kết quả)
- **FE-16:** Chụp ảnh rắn sau khi bắt
- **FE-18:** Cập nhật vị trí real-time
- **FE-19:** Điều hướng đến vị trí Patient
- **FE-20:** Gửi thông báo trạng thái cho Patient
- **FE-21:** Sử dụng AI nhận diện rắn, nhận cảnh báo mức độ nguy hiểm
- **FE-23:** Chuẩn bị thiết bị và biện pháp an toàn
- **FE-24, FE-25, FE-26:** Revenue management
- **FE-27:** Xem đánh giá từ khách hàng

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange-Red (Emergency) `#FF6B35`
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Danger (Venomous):** Red `#DC3545`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Info:** Blue `#007BFF`
- **Status Active:** Orange `#FF6B35`
- **Status Completed:** Green `#28A745`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)
- **Alert Text:** Bold (18-20pt)

### Component Style:
- **Cards:** Rounded corners (12px), prominent shadows for requests
- **Buttons:** Rounded (8px), large touch targets (min 50px height)
- **Status Badges:** Rounded pills with color-coded backgrounds
- **Image Gallery:** Swipeable horizontal carousel
- **Timer:** Countdown with pulsing animation
- **Map View:** Full-screen with overlay controls

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - đội cứu hộ nhận và xử lý yêu cầu bắt rắn

---

### Screen 1: Available Rescue Requests (Job Board)

#### Thông tin màn hình:
- **Tên:** Danh sách đơn có thể nhận (Job Board - First Come First Served)
- **Mục đích:** Hiển thị tất cả requests đang chờ, rescuer nhận đơn trực tiếp (không cần chờ duyệt)
- **Entry:** Homepage → Tab "Đơn Có Thể Nhận" HOẶC Push notification → Open app
- **Flow position:** Entry point của Rescue Request Flow (First Come First Served)
- **Priority:** ⭐⭐⭐ (Cao nhất - Main working screen)

#### Key Components:

1. **Header Bar:**
   - Title: "Đơn Có Thể Nhận" (24pt, bold)
   - Online status toggle: "ĐANG HOẠT ĐỘNG" (green badge) / "OFFLINE" (gray)
   - Filter icon (top-right)
   - Notification badge: "3" (if has new requests)

2. **Stats Summary Card:**
   - Horizontal scrolling info cards:
     - "Trong 10km": "5 yêu cầu" (green badge)
     - "Trong 20km": "+3 yêu cầu" (amber badge)
     - "Trong 30km": "+2 yêu cầu" (orange badge)
   - Tap to filter by distance

3. **Active Filters Bar** (if filters applied):
   - Chips: "< 10km" (with X to remove)
   - Chips: "Rắn độc" (with X)
   - "Xóa tất cả" link (right)

4. **Sort Options:**
   - Horizontal chips (selected = orange background):
     - "Gần nhất"
     - "Mới nhất"
     - "Giá cao"
   - Default: "Gần nhất"

5. **Request Cards** (Vertical scrolling list):

**Card Structure (for each request):**

- **Top Badge Row:**
  - LEFT: Distance badge "2.3 km" (green if <10km, amber if 10-20km, orange if >30km)
  - RIGHT: Time posted "5 phút trước" (gray text)

- **Snake Photo** (200px height, rounded 12px):
  - Square/landscape snake image
  - Overlay badges (top-right):
    - Danger: "ĐỘC MẠNH" (red) / "ĐỘC TB" (amber) / "KHÔNG ĐỘC" (green)

- **Snake Info:**
  - Species: "Rắn hổ mang chúa" (18pt bold, dark gray)
  - AI confidence: "AI: 92% chính xác" (14pt, blue text with robot icon)
  - Quantity: "1 con rắn" (16pt, gray)

- **Location Preview:**
  - Pin icon + "Quận 1, TP.HCM" (16pt, gray)
  - Small map thumbnail preview (80×60px, optional)

- **Price Info:**
  - "Giá dự kiến: 575,000 VNĐ" (20pt, forest green, bold)
  - Note: "Giá cuối sau khi hoàn thành" (12pt, light gray, italic)

- **Competition Indicator:**
  - Icon: Users icon + "3 rescuers đang xem" (14pt, amber)
  - Note: "Ai nhận trước người đó làm" (small, gray italic)

- **Primary Action Button:**
  - "XEM CHI TIẾT" (full width, orange-red #FF6B35, 52px height)
  - White text, bold, 16pt

**Card States:**
- Default: White background, subtle shadow
- Just viewed: Light blue background tint (#F0F8FF)
- Proposal sent: Green tint background + "Đã gửi đề xuất" badge

6. **Empty State** (if no requests):
   - Illustration: Sleeping snake (friendly)
   - Text: "Chưa có yêu cầu nào gần bạn"
   - Subtext: "Hệ thống tìm trong bán kính 30km"
   - Suggestion: "Thử mở rộng bộ lọc"

7. **Pull-to-Refresh:**
   - Swipe down to refresh list
   - Loading spinner with text "Đang cập nhật..."

8. **Filter Bottom Sheet** (when tap filter icon):

**Filter Categories:**

- **Khoảng cách:**
  - Checkboxes: "Trong 10km", "10-20km", "20-30km", "Tất cả"
  
- **Loài rắn:**
  - Checkboxes: "Rắn độc", "Không độc", "Không rõ"
  
- **Số lượng:**
  - Radio: "1 con", "2-5 con", "Ổ rắn / Nhiều con", "Tất cả"
  
- **Mức giá:**
  - Slider: 300K - 5M VNĐ
  - Shows current range below

- **Actions:**
  - "ÁP DỤNG" button (orange, full width)
  - "Đặt lại" link (gray, left)

#### Stitch Prompt (English):

```
Mobile app job board screen for snake rescuer (First Come First Served). Emergency service theme with orange-red (#FF6B35) primary color on white background.

Top navigation bar (white, 60px):
- Left: "Đơn Có Thể Nhận" bold 24pt dark gray
- Right corner: Online status toggle "ĐANG HOẠT ĐỘNG" (green pill badge) + filter icon with red notification badge "3"

Below nav, stats summary card (horizontal scroll, white, 12px rounded):
Three small info cards side-by-side:
- Card 1: "Trong 10km" + "5 yêu cầu" (green badge 18pt bold)
- Card 2: "Trong 20km" + "+3 yêu cầu" (amber badge)
- Card 3: "Trong 30km" + "+2 yêu cầu" (orange badge)

Sort options row (horizontal chips with 12px spacing):
- "Gần nhất" (selected, orange background #FF6B35, white text)
- "Mới nhất" (gray outline)
- "Giá cao" (gray outline)

Vertical scrolling list of request cards with 16px spacing between cards:

REQUEST CARD 1 (white, 12px rounded, shadow 0px 2px 8px):
Top row badges:
- LEFT badge: "2.3 km" (green background #E8F5E9, forest green text, 14pt bold)
- RIGHT text: "5 phút trước" (light gray 14pt)

Snake photo section (200px height, 12px rounded corners):
- Landscape photo of cobra snake
- Top-right overlay badge: "ĐỘC MẠNH" (red #DC3545 background, white text, bold)

Below photo:
- "Rắn hổ mang chúa" (dark gray 18pt bold)
- "AI: 92% chính xác" (blue text 14pt with small robot icon)
- "1 con rắn" (gray 16pt)

Location row:
- Pin icon (16px) + "Quận 1, TP.HCM" (gray 16pt)
- Small map thumbnail 80×60px right side

Price section:
- "Giá dự kiến: 575,000 VNĐ" (forest green #228B22 bold 20pt)
- "Giá cuối sau khi hoàn thành" (light gray italic 12pt)

Competition indicator:
- Users icon + "3 rescuers đang xem" (amber text 14pt)
- Below: "Ai nhận trước người đó làm" (light gray italic 12pt)

Button: "XEM CHI TIẾT" (full width, orange-red #FF6B35, white text 16pt bold, 52px height)

REQUEST CARD 2 (similar structure but different data):
- Distance badge: "8.5 km" (amber background #FFF3CD)
- Time: "12 phút trước"
- Snake: Different snake photo
- Badge: "ĐỘC TRUNG BÌNH" (amber background)
- Species: "Rắn lục đuôi đỏ"
- AI: "87% chính xác"
- Quantity: "2 con rắn"
- Location: "Quận 7, TP.HCM"
- Price: "1,150,000 VNĐ"
- Competition: "5 rescuers đang xem"
- Button same style

REQUEST CARD 3 (with "Đã gửi đề xuất" state):
- Light green background tint (#E8F5E9)
- Top-right badge: "Đã gửi đề xuất" (green background, white text, small)
- Distance: "15.2 km" (orange background #FFE5CC)
- Other elements same as Card 1-2
- Button changed to: "XEM TRÚ THÁI" (green outline instead of solid orange)

Bottom: Pull-to-refresh indicator when scrolled to top.

Design: Job board interface, clear distance hierarchy, competition urgency, visual snake danger levels, price transparency, easy scanning, mobile-optimized cards.
```

#### Notes for Stitch:
- Distance badges màu sắc theo bán kính: <10km=green, 10-20km=amber, >30km=orange
- Danger badges rõ ràng: ĐỘC MẠNH=red, ĐỘC TB=amber, KHÔNG ĐỘC=green
- Competition counter tạo urgency
- Cards đã gửi proposal phải có visual distinction (green tint)
- Price "dự kiến" vs "cuối cùng" phải clear
- Easy scroll và tap targets lớn

---

### Screen 1 (OLD - TO BE DELETED): Incoming Rescue Request Notification

#### Key Components:
1. **Full-Screen Overlay Alert:**
   - Semi-transparent dark background
   - Central alert card with shadow
   - Pulsing border animation (orange-red)

2. **Header Section:**
   - Icon: Warning bell (large, orange-red)
   - Title: "YÊU CẦU CỨU HỘ MỚI"
   - Badge: "KHẨN CẤP" (red) or "BÌNH THƯỜNG" (amber)

3. **Snake Preview:**
   - Small thumbnail of snake photo
   - AI result badge: "Rắn Hổ Mang" (venomous = red, non-venomous = green)
   - Confidence: "Độ chính xác: 92%"

4. **Location Info:**
   - Distance: "1.2 km từ bạn" (bold, large)
   - Address: "123 Nguyễn Văn Linh, Quận 1"
   - Time estimate: "~5 phút lái xe"

5. **Fee Info:**
   - Proposed fee: "200,000 VNĐ" (bold, green)
   - Platform fee note: "(Bạn nhận 85%)"

6. **Countdown Timer:**
   - Large circular countdown: "1:45" (minutes:seconds remaining)
   - Text: "Thời gian còn lại để chấp nhận"

7. **Action Buttons:**
   - Primary button: "XEM CHI TIẾT" (large, orange-red, full width)
   - Secondary button: "TỪ CHỐI" (outlined, gray)

#### Stitch Prompt (English):

```
Mobile app full-screen notification overlay for snake rescue request alert. Emergency notification interface with orange-red (#FF6B35) theme.

Full screen with semi-transparent dark overlay (black 60% opacity). Centered white card with shadow and pulsing orange-red border (2px, animation).

Card top section: Large orange-red bell icon (48px) centered. Below icon, bold dark gray title "YÊU CẦU CỨU HỘ MỚI" (24pt). Top-right corner, small red badge "KHẨN CẤP" rounded.

Snake preview section: Horizontal layout with small snake photo thumbnail (80px square, rounded 8px) left. Right side vertical: Bold snake name "Rắn Hổ Mang" dark gray (18pt), small red badge "Có độc" below name, small gray text "Độ chính xác AI: 92%" below badge.

Location section white background, rounded, padding: Bold large text "1.2 km" orange-red (20pt) with location pin icon. Below, gray text "123 Nguyễn Văn Linh, Quận 1". Below, small gray text with car icon "~5 phút lái xe".

Fee section: Bold large green text "200,000 VNĐ" (24pt) centered. Below, small gray text "(Bạn nhận 85% = 170,000 VNĐ)".

Countdown timer: Large circular progress ring orange-red. Center shows "1:45" bold dark gray (32pt). Below circle, small gray text "Thời gian còn lại để chấp nhận".

Bottom section: Two buttons vertically stacked. Top button large solid orange-red "XEM CHI TIẾT" full width (50px height). Below, large outlined gray button "TỪ CHỐI" full width.

Design: Urgent alert interface, clear information hierarchy, countdown pressure, strong CTAs.
```

#### Notes for Stitch:
- Countdown timer phải có animation và auto-dismiss khi hết giờ
- Pulsing border để tạo urgency
- Fee calculation transparent để build trust
- Distance và time estimate phải prominent

---

### Screen 2: Request Detail & Accept Job

#### Thông tin màn hình:
- **Tên:** Màn hình chi tiết yêu cầu và nhận đơn trực tiếp
- **Mục đích:** Hiển thị đầy đủ thông tin request, rescuer nhận đơn ngay (First Come First Served)
- **Entry:** Tap "Xem Chi Tiết" từ Screen 1 (Job Board)
- **Flow position:** Xem chi tiết và nhận đơn trực tiếp (không cần chờ duyệt)
- **Priority:** ⭐⭐⭐

> **⚡ LƯU Ý:** Rescuer NHẬN ĐƠN TRỰC TIẾP - ai nhận trước người đó làm (First Come, First Served)

#### Key Components:

1. **Header:**
   - Back button (left)
   - Title: "Chi Tiết Yêu Cầu"
   - Share icon (right, optional)

2. **Distance & Time Card (top):**
   - Large bold "2.3 km" (green if <10km, amber 10-20km, orange >30km)
   - Icon: Location pin
   - "Thời gian đến ước tính: 8 phút" (gray, 16pt)
   - "Đã đăng: 5 phút trước" (light gray, 14pt)

3. **Competition Alert** (if >2 rescuers viewing):
   - Light amber background (#FFF9E6)
   - Icon: Users with alert badge
   - Text: "5 rescuers đang xem đơn này" (amber text, bold)
   - Subtext: "⚡ Nhận nhanh trước khi hết!" (red text, 14pt)
   - Creates urgency for first-come-first-served model

4. **Snake Photos Gallery:**
   - Horizontal swipeable carousel
   - Multiple snake photos (1-5 photos)
   - Dots indicator showing current photo (1/3)
   - Tap to view fullscreen
   - Swipe left/right

5. **AI Identification Result Card:**
   - **Snake Name:** "Rắn hổ mang chúa" (24pt, bold, dark gray)
   - **Toxicity Badge:** "ĐỘC MẠNH" (red) / "ĐỘC TB" (amber) / "KHÔNG ĐỘC" (green)
   - **AI Confidence:** "92% chính xác" (blue text with robot icon)
   - **Progress bar:** Visual confidence indicator (92% filled, blue)
   - **Scientific Name:** "Ophiophagus hannah" (gray, italic, 14pt)
   - **Danger Level:** "Nguy hiểm cao - Cần thận trọng" (red badge)

6. **Quantity & Type:**
   - Icon: Counter
   - "Số lượng: 1 con rắn" (18pt, dark gray)
   - "Loại: Rắn cạn, sống trong vườn" (16pt, gray)

7. **Safety Guidelines Card:**
   - Icon: Shield with exclamation (orange)
   - Title: "Hướng Dẫn An Toàn" (bold, 18pt)
   - Collapsible section (tap to expand)
   - Bullet points when expanded:
     - "Mang găng tay chống cắn chuyên dụng"
     - "Sử dụng móc bắt rắn dài tối thiểu 1.2m"
     - "Giữ khoảng cách an toàn 2-3 mét"
     - "Chuẩn bị túi vải dày hoặc hộp nhựa kín"
     - "Không bắt khi rắn đang hung dữ"
   - Link: "Xem quy trình bắt rắn đầy đủ →" (blue)

8. **Required Equipment Checklist:**
   - Title: "Thiết Bị Cần Thiết" (bold)
   - Read-only list with check icons:
     ✓ Móc bắt rắn (snake hook 1.2m+)
     ✓ Găng tay bảo hộ chống cắn
     ✓ Túi vải dày / Hộp nhựa kín
     ✓ Đèn pin (nếu tối)
     ✓ Phun nước (nếu cần xua đuổi)

9. **Location & Map:**
   - **Full-width interactive map** (200px height)
   - Pin showing exact location
   - User's current location dot (blue)
   - Distance line between two points
   - **Address:** "123 Nguyễn Văn Linh, P.Tân Hưng, Q.7, TP.HCM" (bold, 16pt)
   - Button: "CHỈ ĐƯỜNG" (blue outlined, opens navigation app)

10. **Patient Info Card:**
    - **Name:** "Nguyễn Văn A" (bold, with verified badge if available)
    - **Phone:** "0912 345 678" (with green call icon button)
    - **Rating:** ★★★★★ 4.8 (as customer)
    - **Additional Info:** "Rắn trong vườn, gần hồ nước. Đang ẩn dưới gốc cây" (gray, 14pt)
    - **Special Request:** "Xin rescuer đến trước 6pm" (amber text if urgent)

11. **Price Information Card:**
    - **Title:** "Giá Dự Kiến" (bold, 18pt)
    - **Amount:** "575,000 VNĐ" (forest green #228B22, bold, 28pt)
    - **Note:** "Giá cuối cùng tính SAU KHI hoàn thành" (gray italic, 14pt)
    - **Breakdown (collapsible):**
      - Phí cứu hộ cơ bản: 500,000 VNĐ
      - Bạn nhận (85%): ~489,000 VNĐ
      - Phí nền tảng (10%): ~58,000 VNĐ
      - Quỹ bảo hiểm (5%): ~28,000 VNĐ
    - **Info icon:** "Giá thực tế dựa trên độ khó, thời gian, khoảng cách"

12. **Expert Consultation Option** (optional):
    - Light blue background card
    - Icon: Expert badge
    - Text: "Không chắc về loài rắn này?" (gray, 16pt)
    - Button: "Hỏi Chuyên Gia" (outlined, blue, 44px)
    - Note: "Miễn phí tư vấn nhanh"

13. **Urgency Notice** (replacing Send Proposal Section):

**Alert Banner** (amber background #FFF9E6):
- Icon: Lightning bolt (orange)
- Text: "⚡ Ai nhận trước người đó làm - Nhận ngay!" (bold, orange, 18pt)
- Subtext: "Đơn sẽ biến mất khi có rescuer khác nhận" (gray, 14pt)

14. **Action Buttons (sticky bottom, white background, shadow):**

**Primary Button:**
- Text: "NHẬN ĐƠN NGAY"
- Full width, 60px height
- Orange-red background #FF6B35
- White text, bold, 18pt
- Icon: Check circle with lightning (left)
- Pulsing animation to create urgency

**Secondary Button:**
- Text: "KHÔNG NHẬN"
- Full width, 48px height
- Gray outlined
- Gray text, 16pt

#### Stitch Prompt (English):

```
Mobile app rescue request detail screen with direct job acceptance (First Come First Served). Orange-red (#FF6B35) theme.

Top navigation: Back arrow left, "Chi Tiết Yêu Cầu" title centered bold, share icon right.

Distance card (full width, white, shadow):
- Large "2.3 km" bold green #28A745 (32pt) centered with location pin icon
- Below: "Thời gian đến ước tính: 8 phút" (gray 16pt)
- Below: "Đã đăng: 5 phút trước" (light gray 14pt)

Competition alert (amber background #FFF9E6, 12px rounded):
- Users icon with alert badge left
- "5 rescuers đang xem đơn này" (amber bold 16pt)
- Below: "⚡ Nhận nhanh trước khi hết!" (red text 14pt)

Photo gallery section (full width, 250px height):
- Swipeable horizontal carousel with 3 snake photos
- Dots indicator below "1/3" gray

AI result card (white, shadow, 12px rounded):
- Top: "Rắn hổ mang chúa" (24pt bold dark gray)
- Right of title: Red badge "ĐỘC MẠNH" (white text)
- Row 2: "AI: 92% chính xác" (blue text, robot icon)
- Row 3: Progress bar (blue fill 92%, gray background)
- Row 4: Italic gray "Ophiophagus hannah" (14pt)
- Bottom: Red badge "Nguy hiểm cao - Cần thận trọng"

Quantity card:
- Counter icon + "Số lượng: 1 con rắn" (18pt dark gray)
- "Loại: Rắn cạn, sống trong vườn" (16pt gray)

Safety guidelines card (collapsible):
- Orange shield icon + "Hướng Dẫn An Toàn" (bold 18pt) + down arrow
- When expanded shows 5 bullet points with orange checks
- Blue link "Xem quy trình bắt rắn đầy đủ →"

Equipment checklist (white card):
- "Thiết Bị Cần Thiết" (bold 18pt)
- 5 rows with green check icons:
  ✓ Móc bắt rắn (snake hook 1.2m+)
  ✓ Găng tay bảo hộ chống cắn
  ✓ Túi vải dày / Hộp nhựa kín
  ✓ Đèn pin (nếu tối)
  ✓ Phun nước (nếu cần xua đuổi)

Interactive map section (full width, 200px height):
- Map with red pin (destination) and blue dot (user location)
- Distance line between points
- Below map: Bold "123 Nguyễn Văn Linh, P.Tân Hưng, Q.7, TP.HCM" (16pt)
- Blue outlined button "CHỈ ĐƯỜNG" (full width, 48px)

Patient info card (white, shadow):
- "Nguyễn Văn A" (bold) with verified green badge
- "0912 345 678" with green phone icon button right
- Star rating "★★★★★ 4.8" (gold stars)
- Gray text "Rắn trong vườn, gần hồ nước. Đang ẩn dưới gốc cây"
- Amber text "Xin rescuer đến trước 6pm"

Price card (white, shadow):
- "Giá Dự Kiến" (bold 18pt)
- "575,000 VNĐ" (forest green #228B22, bold 28pt)
- Italic gray "Giá cuối cùng tính SAU KHI hoàn thành" (14pt)
- Info icon with breakdown (collapsible)

Expert consultation card (light blue background #E7F3FF):
- Expert badge icon + "Không chắc về loài rắn này?"
- Outlined blue button "Hỏi Chuyên Gia" (44px height)
- Small text "Miễn phí tư vấn nhanh"

Urgency alert banner (amber background #FFF9E6, 12px rounded):
- Lightning bolt icon (orange) left
- "⚡ Ai nhận trước người đó làm - Nhận ngay!" (bold orange 18pt)
- Below: "Đơn sẽ biến mất khi có rescuer khác nhận" (gray 14pt)

Bottom sticky section (white, shadow):
- Large orange-red button "NHẬN ĐƠN NGAY" (60px, white text, check+lightning icon, pulsing animation)
- Below: Gray outlined button "KHÔNG NHẬN" (48px)

Design: Comprehensive job details, First Come First Served urgency, direct acceptance, safety-first, clear call-to-actions.
```

#### Notes for Stitch:
- Distance badge color theo bán kính: <10km=green, 10-20km=amber, >30km=orange
- Competition alert creates STRONG urgency with "⚡ Nhận nhanh trước khi hết!"
- Rescuer NHẬN ĐƠN TRỰC TIẾP - không cần gửi proposal, không chờ patient chọn
- Button "NHẬN ĐƠN NGAY" phải có pulsing animation
- Map interactive, tap để full screen
- Call button direct call patient
- Urgency banner phải prominent

---

### Screen 3: Request Accepted Successfully

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận đã nhận đơn thành công
- **Mục đích:** Thông báo rescuer đã nhận đơn, hiển thị thông tin patient đầy đủ, chuẩn bị xuất phát
- **Entry:** Sau khi tap "NHẬN ĐƠN NGAY" từ Screen 2 (nếu đơn còn available)
- **Flow position:** Xác nhận nhận đơn thành công → Chuẩn bị di chuyển
- **Priority:** ⭐⭐⭐
- **Alternative:** Nếu đơn đã được rescuer khác nhận → Show error "Đơn đã có người nhận"

#### Key Components:

1. **Success Animation (top):**
   - Large animated checkmark (120px, green circle)
   - Scale up animation on load
   - Text: "ĐÃ NHẬN ĐƠN THÀNH CÔNG!" (24pt, bold, green #28A745)
   - Subtext: "Hãy chuẩn bị thiết bị và bắt đầu di chuyển" (16pt, gray)

2. **Job Summary Card:**
   - Title: "Thông Tin Công Việc" (18pt, bold)
   - **Snake Info:**
     - Thumbnail image (80×80px, rounded)
     - "Rắn hổ mang chúa" (18pt, bold)
     - Danger badge: "ĐỘC MẠNH" (red)
     - "1 con rắn" (16pt, gray)
   - **Location:**
     - Pin icon + "2.3 km" (bold, green if <10km)
     - Address: "123 Nguyễn Văn Linh, Q.7, TP.HCM"
   - **Estimated Earnings:**
     - "Dự kiến thu nhập: ~489,000 VNĐ" (green, bold, 20pt)
     - Note: "Giá cuối sau khi hoàn thành" (gray italic, 12pt)

3. **Patient Information Card:**
   - Title: "Thông Tin Khách Hàng" (18pt, bold)
   - **Avatar & Name:**
     - Profile photo (60×60px, circular)
     - "Nguyễn Văn A" (18pt, bold)
     - Verified badge (if available)
   - **Contact:**
     - Phone: "0912 345 678"
     - Large green call button (48px height, full width)
     - Icon: Phone + "GỌI KHÁCH HÀNG"
   - **Rating:**
     - Stars: ★★★★★ 4.8 (gold)
     - "(25 đánh giá)" (gray, 14pt)
   - **Additional Info:**
     - "Rắn trong vườn, gần hồ nước. Đang ẩn dưới gốc cây" (gray, 14pt)
     - If urgent: "⚠️ Mong rescuer đến trước 6pm" (amber text)

4. **Location Map:**
   - Full-width interactive map (250px height)
   - Red pin: Patient location
   - Blue dot: Rescuer current location
   - Distance line between points
   - Button overlay: "CHỈ ĐƯỜNG" (blue, bottom-right corner)

5. **Equipment Checklist Reminder:**
   - Title: "Thiết Bị Cần Mang" (18pt, bold)
   - Quick checklist with checkboxes (user can tick):
     ☐ Móc bắt rắn (1.2m+)
     ☐ Găng tay bảo hộ
     ☐ Túi vải dày / Hộp nhựa
     ☐ Đèn pin (nếu tối)
   - Link: "Xem hướng dẫn an toàn đầy đủ →" (blue)

6. **Safety Reminder Banner:**
   - Light orange background (#FFF3E0)
   - Shield icon (orange)
   - Text: "⚠️ Đọc lại hướng dẫn an toàn trước khi xuất phát"
   - Link: "Xem hướng dẫn →" (orange)

7. **Quick Actions Bar** (horizontal, 3 buttons):
   - **Button 1:** "Gọi Chuyên Gia" (outlined, blue, icon: expert badge)
   - **Button 2:** "Xem Chi Tiết Rắn" (outlined, gray, icon: info)
   - **Button 3:** "Hủy Đơn" (outlined, red, icon: X)
   - Each button 32% width, 44px height

8. **Action Buttons (sticky bottom, white background, shadow):**

**Primary Button:**
- Text: "BẮT ĐẦU DI CHUYỂN"
- Full width, 60px height
- Forest green background #228B22
- White text, bold, 18pt
- Icon: Navigation arrow (right)
- Starts GPS tracking when tapped

**Secondary Action:**
- Small link "Tôi cần thêm thời gian" (gray, center, 14pt)
- Opens delay notification to patient

#### Stitch Prompt (English):

```
Mobile app success confirmation screen for snake rescuer after accepting job. Green success theme with orange-red (#FF6B35) accents.

Top section (white background):
- Large animated green checkmark circle (120px, #28A745) centered
- Below: "ĐÃ NHẬN ĐƠN THÀNH CÔNG!" (green bold 24pt)
- Below: "Hãy chuẩn bị thiết bị và bắt đầu di chuyển" (gray 16pt)

Job summary card (white, shadow, 12px rounded):
- "Thông Tin Công Việc" (bold 18pt)
- Horizontal layout: Snake thumbnail 80×80px left + info right
  - "Rắn hổ mang chúa" (18pt bold)
  - Red badge "ĐỘC MẠNH"
  - "1 con rắn" (16pt gray)
- Row: Pin icon + "2.3 km" (green bold) + "123 Nguyễn Văn Linh, Q.7"
- Row: "Dự kiến thu nhập: ~489,000 VNĐ" (green bold 20pt)
- Below: "Giá cuối sau khi hoàn thành" (gray italic 12pt)

Patient info card (white, shadow, 12px rounded):
- "Thông Tin Khách Hàng" (bold 18pt)
- Horizontal: Profile photo 60×60px circular + name right
  - "Nguyễn Văn A" (18pt bold) with verified badge
  - "0912 345 678" (16pt gray)
- Large green button "GỌI KHÁCH HÀNG" (48px, phone icon left)
- Star rating "★★★★★ 4.8" (gold) + "(25 đánh giá)" gray
- Gray text "Rắn trong vườn, gần hồ nước. Đang ẩn dưới gốc cây"
- Amber text "⚠️ Mong rescuer đến trước 6pm"

Interactive map (full width, 250px height):
- Red pin (patient location) + blue dot (rescuer)
- Distance line connecting points
- Blue button "CHỈ ĐƯỜNG" bottom-right corner overlay

Equipment checklist card:
- "Thiết Bị Cần Mang" (bold 18pt)
- 4 checkbox rows:
  ☐ Móc bắt rắn (1.2m+)
  ☐ Găng tay bảo hộ
  ☐ Túi vải dày / Hộp nhựa
  ☐ Đèn pin (nếu tối)
- Blue link "Xem hướng dẫn an toàn đầy đủ →"

Safety banner (light orange #FFF3E0, 12px rounded):
- Orange shield icon left
- "⚠️ Đọc lại hướng dẫn an toàn trước khi xuất phát"
- Orange link "Xem hướng dẫn →" right

Quick actions bar (3 buttons horizontal, equal width):
- "Gọi Chuyên Gia" (outlined blue, expert icon, 44px)
- "Xem Chi Tiết Rắn" (outlined gray, info icon, 44px)
- "Hủy Đơn" (outlined red, X icon, 44px)

Bottom sticky section (white, shadow):
- Large green button "BẮT ĐẦU DI CHUYỂN" (60px, white text, navigation arrow right)
- Below: Gray link "Tôi cần thêm thời gian" (14pt, centered)

Design: Success confirmation, comprehensive patient info, equipment checklist, safety reminders, ready-to-go interface.
```

#### Notes for Stitch:
- Success animation phải smooth và eye-catching
- Patient info card phải comprehensive - tên, ảnh, số điện thoại, rating
- Map interactive - tap để full screen navigation
- Equipment checklist interactive - user có thể tick
- Button "BẮT ĐẦU DI CHUYỂN" triggers GPS tracking
- "Hủy Đơn" button phải có confirmation dialog

#### Alternative State - Job Already Taken:

**Error Screen** (if someone else accepted first):
- Red X circle (120px)
- "ĐƠN ĐÃ CÓ NGƯỜI NHẬN" (red, bold, 24pt)
- Text: "Rescuer khác đã nhận đơn này trước bạn 2 giây" (gray, 16pt)
- Illustration: Disappointed face
- Button: "TRỞ LẠI DANH SÁCH ĐƠN" (orange-red, full width)
- Suggestion: "Các đơn tương tự trong khu vực:" → Show 2-3 similar jobs

---

### Screen 2 (OLD - TO BE DELETED): Rescue Request Detail Screen

#### Key Components:
1. **Header:**
   - Back button (left)
   - Title: "Chi Tiết Yêu Cầu"
   - Timer countdown (top-right, red): "1:23"

2. **Snake Photos Gallery (top section):**
   - Horizontal swipeable carousel
   - Multiple snake photos (3-5 photos)
   - Dots indicator showing current photo
   - Zoom capability on tap

3. **AI Identification Result Card:**
   - **Snake Name:** "Rắn Hổ Mang" (bold, large)
   - **Toxicity Badge:** "Có Độc" (red) / "Không Độc" (green)
   - **Confidence:** "92% chính xác" (with progress bar)
   - **Danger Level:** "Nguy hiểm cao" (red badge)
   - **Scientific Name:** "Naja kaouthia" (gray, italic)

4. **Safety Guidelines Card:**
   - Icon: Shield with exclamation
   - Title: "Hướng Dẫn An Toàn"
   - Bullet points:
     - "Mang găng tay dày"
     - "Sử dụng móc bắt rắn chuyên dụng"
     - "Giữ khoảng cách an toàn 2m"
     - "Chuẩn bị túi vải dày"
   - Link: "Xem hướng dẫn đầy đủ"

5. **Required Equipment Checklist:**
   - Title: "Thiết Bị Cần Thiết"
   - Checkboxes (Rescuer can tick):
     - ☐ Móc bắt rắn (snake hook)
     - ☐ Găng tay bảo hộ
     - ☐ Túi vải/hộp đựng
     - ☐ Đèn pin
     - ☐ Phun nước (nếu cần)

6. **Location & Patient Info:**
   - **Address:** "123 Nguyễn Văn Linh, Quận 1, TP.HCM"
   - **Distance:** "1.2 km" (bold)
   - **ETA:** "5 phút lái xe"
   - **Mini map** showing location
   - Button: "Chỉ Đường" (opens navigation)
   - **Patient Name:** "Nguyễn Văn A"
   - **Phone:** "0912 345 678" (with call button)
   - **Additional Info:** "Rắn trong vườn, gần hồ nước"

7. **Fee Breakdown Card:**
   - **Total Fee:** "200,000 VNĐ" (bold, green, large)
   - Breakdown:
     - "Phí cứu hộ: 200,000 VNĐ"
     - "Bạn nhận: 170,000 VNĐ (85%)"
     - "Phí nền tảng: 20,000 VNĐ (10%)"
     - "Quỹ bảo hiểm: 10,000 VNĐ (5%)"

8. **Expert Consultation Option:**
   - Text: "Không chắc về loài rắn này?"
   - Button: "Hỏi Chuyên Gia" (outlined, blue)

9. **Action Buttons (sticky bottom):**
   - Primary button: "CHẤP NHẬN YÊU CẦU" (large, orange-red, full width)
   - Secondary button: "TỪ CHỐI" (outlined, gray, full width)

#### Stitch Prompt (English):

```
Mobile app rescue request detail screen for snake rescue mission. Comprehensive information interface with orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Chi Tiết Yêu Cầu" centered bold dark gray, countdown timer "1:23" right in red with clock icon.

Top section: Horizontal swipeable photo gallery showing 3 snake images. Each photo rectangular (full width, 250px height), rounded corners (12px). Below gallery, 3 gray dots indicating photo position, center dot orange-red (active).

AI result card white background, shadow, rounded: Bold large "Rắn Hổ Mang" dark gray (22pt) top. Next to title, red rounded badge "Có Độc". Below name, horizontal progress bar showing "92% chính xác" with orange fill. Below bar, red badge "Nguy hiểm cao". Bottom, small italic gray text "Naja kaouthia".

Safety guidelines card: Orange shield icon left. Bold title "Hướng Dẫn An Toàn" dark gray right. Four bullet points with orange checkmarks:
• Mang găng tay dày
• Sử dụng móc bắt rắn chuyên dụng
• Giữ khoảng cách an toàn 2m
• Chuẩn bị túi vải dày
Small blue text link "Xem hướng dẫn đầy đủ" bottom-right.

Equipment checklist card: Bold title "Thiết Bị Cần Thiết". Five rows with checkboxes left, equipment name gray text right:
□ Móc bắt rắn (snake hook)
□ Găng tay bảo hộ
□ Túi vải/hộp đựng
□ Đèn pin
□ Phun nước (nếu cần)

Location card: Small map thumbnail (full width, 120px height) top. Below map, bold "123 Nguyễn Văn Linh, Quận 1" dark gray. Row showing "1.2 km" bold orange left, "5 phút lái xe" gray right with car icon. Outlined orange button "Chỉ Đường" full width. Divider line. Patient info: "Nguyễn Văn A" bold with phone "0912 345 678" and green call icon button right. Small gray text "Rắn trong vườn, gần hồ nước".

Fee breakdown card: Large bold green "200,000 VNĐ" (28pt) centered. Below, four lines gray text with breakdown:
- Phí cứu hộ: 200,000 VNĐ
- Bạn nhận: 170,000 VNĐ (85%)
- Phí nền tảng: 20,000 VNĐ (10%)
- Quỹ bảo hiểm: 10,000 VNĐ (5%)

Expert consultation box light blue background: Gray text "Không chắc về loài rắn này?" left. Outlined blue button "Hỏi Chuyên Gia" right.

Bottom sticky section white background, top shadow: Large solid orange-red button "CHẤP NHẬN YÊU CẦU" full width (55px height). Below, large outlined gray button "TỪ CHỐI" full width.

Design: Comprehensive mission briefing, safety-first approach, clear fee transparency, easy decision making.
```

#### Notes for Stitch:
- Photos phải swipeable và zoomable
- Equipment checklist phải interactive
- Call button phải direct call
- Map thumbnail tap để open full map
- Timer phải countdown real-time

---

### Screen 3: Expert Consultation Request Screen

#### Thông tin màn hình:
- **Tên:** Màn hình yêu cầu tư vấn chuyên gia
- **Mục đích:** Rescuer gửi ảnh rắn để Expert xác nhận loài nếu không chắc chắn
- **Flow position:** Optional - Khi Rescuer tap "Hỏi Chuyên Gia" (FE-12)
- **Priority:** ⭐⭐ (Related to Flow 3.2)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Tư Vấn Chuyên Gia Khẩn Cấp"
   - Status: "Đang tìm chuyên gia online..."

2. **Snake Photos Review:**
   - Shows same photos from request
   - AI result displayed
   - Text: "Bạn cần xác nhận về:"

3. **Quick Question Form:**
   - Text area: "Mô tả chi tiết (tùy chọn)"
   - Placeholder: "VD: Rắn có vằn vàng đen, đầu to..."
   - Character count: "0/200"

4. **Urgency Indicator:**
   - Badge: "ƯU TIÊN CAO" (red)
   - Text: "Chuyên gia sẽ phản hồi trong 2-3 phút"

5. **Action Button:**
   - Primary: "GỬI YÊU CẦU TƯ VẤN" (orange-red, full width)
   - Text below: "Miễn phí cho đội cứu hộ"

#### Stitch Prompt (English):

```
Mobile app expert consultation request screen for rescuer snake identification help. Urgent consultation interface with orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Tư Vấn Chuyên Gia Khẩn Cấp" bold dark gray centered. Below header, animated text "Đang tìm chuyên gia online..." with loading dots.

Photos review section: Horizontal scrollable showing 3 snake thumbnails (100px square each). Below photos, AI result badge "Rắn Hổ Mang - 92%" with question mark icon. Text "Bạn cần xác nhận về:" gray above photos.

Form section white card: Label "Mô tả chi tiết (tùy chọn)" bold dark gray. Large text area (4 lines height) with gray border, rounded corners, placeholder "VD: Rắn có vằn vàng đen, đầu to...". Bottom-right of textarea, small gray text "0/200".

Urgency card light red background (#FFEBEE): Red badge "ƯU TIÊN CAO" with alert icon left. Text "Chuyên gia sẽ phản hồi trong 2-3 phút" dark gray right.

Bottom section: Large solid orange-red button "GỬI YÊU CẦU TƯ VẤN" full width (55px height). Below button, centered small green text "Miễn phí cho đội cứu hộ" with checkmark icon.

Design: Quick consultation request, urgency emphasized, free service highlighted.
```

#### Notes for Stitch:
- Loading animation cho "finding expert"
- Text area auto-focus
- Free service badge để encourage usage

---

### Screen 4: Waiting for Expert Response Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chờ phản hồi từ chuyên gia
- **Mục đích:** Show progress trong khi đợi Expert accept và respond
- **Flow position:** Sau khi gửi yêu cầu tư vấn
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Đang Chờ Chuyên Gia"

2. **Progress Animation:**
   - Large animated icon (searching/connecting)
   - Text: "Đang kết nối với chuyên gia..."
   - Timer: "Đã chờ: 0:35"

3. **Status Updates:**
   - "✓ Yêu cầu đã gửi"
   - "↻ Đang tìm chuyên gia phù hợp..."
   - "⏳ Dự kiến: 2-3 phút"

4. **Meanwhile Section:**
   - Title: "Trong lúc chờ, bạn có thể:"
   - Quick actions:
     - "Xem lại ảnh rắn"
     - "Đọc hướng dẫn an toàn"
     - "Kiểm tra thiết bị"

5. **Cancel Option:**
   - Text link: "Hủy yêu cầu và tiếp tục"

#### Stitch Prompt (English):

```
Mobile app waiting screen for expert consultation response. Loading interface with orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Đang Chờ Chuyên Gia" centered bold dark gray.

Center section: Large animated circular loading icon orange-red (80px) with rotating effect. Below icon, bold text "Đang kết nối với chuyên gia..." dark gray (18pt). Below text, timer "Đã chờ: 0:35" gray with clock icon.

Status timeline vertical layout: Three rows with icons and text:
- Row 1: Green checkmark icon, "Yêu cầu đã gửi" gray strikethrough
- Row 2: Orange rotating arrow icon, "Đang tìm chuyên gia phù hợp..." bold dark gray
- Row 3: Gray clock icon, "Dự kiến: 2-3 phút" gray

Meanwhile section white card: Bold title "Trong lúc chờ, bạn có thể:" dark gray. Three action items with chevron right icons:
• Xem lại ảnh rắn
• Đọc hướng dẫn an toàn
• Kiểm tra thiết bị

Bottom: Centered blue text link "Hủy yêu cầu và tiếp tục".

Design: Progress feedback, reduce waiting anxiety, provide useful actions during wait time.
```

#### Notes for Stitch:
- Timer phải real-time counting
- Animation cho connecting status
- Quick actions phải functional

---

### Screen 5: Expert Consultation Chat Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chat với chuyên gia
- **Mục đích:** Chat/Video call real-time với Expert để xác nhận loài rắn
- **Flow position:** Khi Expert accept và bắt đầu tư vấn (FE-11, FE-14)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button (left)
   - Expert info: Avatar + Name "TS. Nguyễn Văn An"
   - Status: "Online" (green dot)
   - Video call button (top-right)

2. **Chat Messages:**
   - Expert photo/message bubbles (left, purple background)
   - Rescuer messages (right, orange background)
   - Timestamps
   - Snake photos shared (inline preview)

3. **Quick Photo Share:**
   - Camera button to take new photos
   - Gallery to share existing photos

4. **Expert Conclusion Card (after consultation):**
   - "KẾT LUẬN TƯ VẤN"
   - Confirmed snake: "Rắn Hổ Mang Chúa"
   - Toxicity: "Cực kỳ nguy hiểm"
   - Safety notes from expert
   - Button: "Xác Nhận & Tiếp Tục"

5. **Input Section:**
   - Text input field
   - Send button
   - Voice message button

#### Stitch Prompt (English):

```
Mobile app chat screen for expert consultation with snake specialist. Real-time messaging interface with orange-red (#FF6B35) theme.

Top header white background shadow: Back arrow left. Center: small circular avatar (40px) with name "TS. Nguyễn Văn An" bold dark gray right of avatar, small green dot and "Online" text below name. Top-right: video camera icon button.

Chat area white background: Scrollable message list. Expert messages: Left-aligned bubble purple background (#6F42C1), white text, rounded corners (12px sharp corner bottom-left). Small timestamp "14:32" gray below bubble. Rescuer messages: Right-aligned bubble orange background (#FF6B35), white text, rounded corners (12px sharp corner bottom-right). Timestamp below.

Shared photo message: Full-width image preview (200px height), rounded corners, with caption text below.

Expert conclusion card (when received): White card with shadow, purple left border (4px). Bold title "KẾT LUẬN TƯ VẤN" purple (18pt). Row: "Loài rắn:" gray left, "Rắn Hổ Mang Chúa" bold dark gray right. Row: "Độc tính:" gray left, red badge "Cực kỳ nguy hiểm" right. Gray text paragraph "Lưu ý an toàn từ chuyên gia...". Bottom: outlined orange button "Xác Nhận & Tiếp Tục" full width.

Bottom input section white background, top border: Camera icon button left. Text input field center (gray border, rounded, placeholder "Nhắn tin..."). Microphone icon button. Orange send arrow icon button right.

Design: Professional consultation chat, clear expert identity, visual conclusion summary.
```

#### Notes for Stitch:
- Real-time chat với WebSocket
- Video call button mở camera
- Expert conclusion phải clear và actionable

---

### Screen 6: En Route to Location Screen

#### Thông tin màn hình:
- **Tên:** Màn hình di chuyển đến địa điểm
- **Mục đích:** Navigation với GPS tracking real-time và status updates
- **Flow position:** Giai đoạn 2.3 - Sau khi chấp nhận yêu cầu, đang di chuyển (FE-07, FE-18, FE-19)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Full-Screen Map:**
   - Rescuer's current location (orange marker with avatar)
   - Destination (Patient location, red pin)
   - Route highlighted (orange line)
   - Traffic overlay (if available)

2. **Top Status Bar (overlay on map):**
   - Time remaining: "5 phút nữa"
   - Distance: "1.2 km"
   - Status badge: "ĐANG TRÊN ĐƯỜNG" (orange)

3. **Bottom Info Card (slide-up drawer):**
   - Patient info mini card
   - Phone: "0912 345 678" with call button
   - Address: "123 Nguyễn Văn Linh, Quận 1"
   - Snake preview: Small thumbnail + "Rắn Hổ Mang"
   - Safety reminder: "Nhớ mang găng tay bảo hộ"

4. **Navigation Controls:**
   - "Bắt đầu chỉ đường" button (opens Google Maps/Waze)
   - "Gọi cho khách hàng" button
   - "Dừng nhiệm vụ" button (red, outlined)

5. **Status Update Button:**
   - Floating button: "Đã đến nơi"
   - Only visible when near destination (<100m)

6. **Auto-notifications to Patient:**
   - System auto-sends updates every 30 seconds
   - "Đội cứu hộ cách bạn 5 phút"
   - "Đội cứu hộ đang đến gần"

#### Stitch Prompt (English):

```
Mobile app navigation screen for rescuer en route to snake rescue location. Full-screen map navigation interface with orange-red (#FF6B35) theme.

Full-screen map view showing: Orange location marker with small avatar for rescuer position. Red destination pin marker. Orange route line connecting them. Blue current location dot with accuracy circle.

Top overlay white card shadow, rounded bottom corners: Row layout: "5 phút nữa" bold dark gray (18pt) left with clock icon, vertical divider, "1.2 km" bold right with road icon. Below row, orange badge "ĐANG TRÊN ĐƯỜNG" full width centered.

Bottom slide-up drawer white background, rounded top corners (16px), shadow: Handle bar gray centered top. Patient mini card: Row with small circular avatar, name "Nguyễn Văn A" bold, green phone icon button right. Below, gray text "123 Nguyễn Văn Linh, Quận 1" with location pin. Below, horizontal layout: small snake thumbnail (60px), "Rắn Hổ Mang" bold dark gray, small red "Có độc" badge. Yellow info box: "Nhớ mang găng tay bảo hộ" with alert icon.

Three buttons stacked: Solid orange "Bắt đầu chỉ đường" with navigation icon. Outlined orange "Gọi cho khách hàng" with phone icon. Outlined red "Dừng nhiệm vụ".

Floating action button bottom-right on map: Large circular green button "Đã đến nơi" (only shows when near destination).

Design: Map-first navigation, clear ETA, easy communication, safety reminders, prominent arrival confirmation.
```

#### Notes for Stitch:
- Map phải real-time tracking với GPS
- "Đã đến nơi" button chỉ show khi distance < 100m
- Auto-send notification to Patient mỗi 30 giây

---

### Screen 7: Arrived at Location Screen

#### Thông tin màn hình:
- **Tên:** Màn hình đã đến nơi
- **Mục đích:** Confirm arrival và chuẩn bị bắt đầu nhiệm vụ
- **Flow position:** Giai đoạn 2.3 - Khi Rescuer tap "Đã đến nơi" (FE-20)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Đã Đến Địa Điểm"
   - Timer: "Thời gian di chuyển: 6 phút"

2. **Location Confirmation:**
   - Small map showing exact location
   - Text: "Bạn đã đến 123 Nguyễn Văn Linh"
   - Accuracy: "GPS chính xác ±5m"

3. **Patient Contact Card:**
   - Avatar + Name "Nguyễn Văn A"
   - Phone with direct call button
   - Text: "Khách hàng sẽ ra đón bạn"

4. **Pre-Rescue Checklist:**
   - Title: "Kiểm Tra Trước Khi Bắt"
   - Interactive checkboxes:
     - ☐ Đã gặp khách hàng
     - ☐ Đã xác định vị trí rắn
     - ☐ Thiết bị đầy đủ
     - ☐ Đánh giá môi trường an toàn

5. **Snake Info Reminder:**
   - Photo + "Rắn Hổ Mang - Có độc"
   - "Cần găng tay dày và móc 2m"

6. **Status Update Button:**
   - Primary: "BẮT ĐẦU BẮT RẮN" (orange-red, large)
   - This updates status to "Đang xử lý"

#### Stitch Prompt (English):

```
Mobile app arrival confirmation screen for snake rescue mission. Pre-work checklist interface with orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Đã Đến Địa Điểm" bold dark gray centered. Below header, small gray text "Thời gian di chuyển: 6 phút" with timer icon.

Location card: Small map thumbnail (full width, 120px height) rounded corners. Below map, bold text "Bạn đã đến 123 Nguyễn Văn Linh" dark gray with green checkmark. Small gray text "GPS chính xác ±5m" with location icon.

Patient contact card white shadow: Row with circular avatar (50px), name "Nguyễn Văn A" bold dark gray center, large green phone icon button right. Below, gray text "Khách hàng sẽ ra đón bạn".

Checklist card: Bold title "Kiểm Tra Trước Khi Bắt" dark gray (18pt). Four checkbox rows with gray text:
□ Đã gặp khách hàng
□ Đã xác định vị trí rắn
□ Thiết bị đầy đủ
□ Đánh giá môi trường an toàn

Snake reminder card light yellow background: Row with small snake thumbnail (60px) left, bold "Rắn Hổ Mang" dark gray center, red badge "Có độc" right. Below, orange text with alert icon "Cần găng tay dày và móc 2m".

Bottom section: Large solid orange-red button "BẮT ĐẦU BẮT RẮN" full width (55px height).

Design: Arrival confirmation, safety checklist emphasis, patient communication ready, clear next action.
```

#### Notes for Stitch:
- Checklist phải interactive và recommend ticking all
- Call button direct dial
- Status auto-notify Patient when arrival confirmed

---

### Screen 8: Rescue in Progress Screen

#### Thông tin màn hình:
- **Tên:** Màn hình đang thực hiện bắt rắn
- **Mục đích:** Track progress và allow documentation during rescue
- **Flow position:** Giai đoạn 2.3 - Trong quá trình bắt rắn (FE-07)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Đang Bắt Rắn"
   - Status badge: "ĐANG XỬ LÝ" (orange, pulsing)

2. **Timer:**
   - Large running timer: "12:34" (elapsed time)
   - Text: "Thời gian xử lý"

3. **Snake Info Banner:**
   - Photo + "Rắn Hổ Mang - Có độc"
   - Badge: "Cực kỳ nguy hiểm"

4. **Safety Reminders (expandable):**
   - "⚠️ An Toàn Trong Quá Trình Bắt"
   - Tap to expand safety guidelines
   - Quick reference for emergency procedures

5. **Photo Documentation:**
   - Section: "Chụp Ảnh Quá Trình"
   - Camera button: "Chụp ảnh rắn sau khi bắt"
   - Gallery showing photos taken (0-5 photos)
   - Required before completing

6. **Quick Notes:**
   - Text area: "Ghi chú về quá trình bắt"
   - Placeholder: "VD: Rắn trong bụi rậm, khó tiếp cận..."
   - Voice-to-text button

7. **Emergency Actions:**
   - Red button: "Gọi Hỗ Trợ Khẩn Cấp"
   - Link: "Liên hệ Expert"

8. **Status Update:**
   - Button: "HOÀN THÀNH BẮT RẮN" (disabled until photo taken)

#### Stitch Prompt (English):

```
Mobile app rescue in progress screen for active snake capture operation. Real-time work tracking interface with orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Đang Bắt Rắn" bold dark gray centered. Orange badge "ĐANG XỬ LÝ" with pulsing animation right.

Timer section centered: Very large bold "12:34" orange-red (36pt) with stopwatch icon. Below, small gray text "Thời gian xử lý".

Snake info banner yellow background, padding: Row with snake thumbnail (60px) left, bold "Rắn Hổ Mang" dark gray center, red badge "Có độc" and "Cực kỳ nguy hiểm" stacked right.

Safety reminders collapsed card: Orange alert icon left, bold "An Toàn Trong Quá Trình Bắt" dark gray, down chevron icon right. When expanded, shows bullet list of safety guidelines.

Photo documentation section: Bold title "Chụp Ảnh Quá Trình" dark gray (18pt). Large dashed border box with camera icon center, text "Chụp ảnh rắn sau khi bắt" gray. Below, horizontal scrollable gallery showing captured photos (thumbnail 100px square each) with X delete button on each. Red asterisk "*Bắt buộc" small text.

Notes section: Bold title "Ghi Chú" dark gray. Large text area (3 lines) gray border rounded, placeholder "VD: Rắn trong bụi rậm, khó tiếp cận...". Bottom-right: blue microphone icon button for voice input.

Emergency section: Outlined red button "Gọi Hỗ Trợ Khẩn Cấp" with phone icon. Below, blue text link "Liên hệ Expert".

Bottom: Large solid orange-red button "HOÀN THÀNH BẮT RẮN" full width (55px height). If no photos, button is disabled gray with lock icon.

Design: Focus on safety, documentation requirements, emergency access, clear completion criteria.
```

#### Notes for Stitch:
- Timer phải running real-time
- Photo REQUIRED trước khi complete
- Voice-to-text cho notes
- Emergency buttons prominent

---

### Screen 9: Rescue Completion Screen

#### Thông tin màn hình:
- **Tên:** Màn hình hoàn thành cứu hộ
- **Mục đích:** Confirm success, xác nhận loài rắn cuối cùng, và ghi nhận chi tiết (FE-15, FE-16)
- **Flow position:** Giai đoạn 2.3 - Sau khi bắt rắn xong
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận Hoàn Thành"

2. **Success Animation:**
   - Large green checkmark icon
   - Text: "Đã bắt rắn thành công!"

3. **Rescue Summary:**
   - Time taken: "Thời gian: 15 phút"
   - Location: "123 Nguyễn Văn Linh"
   - Date/time: "8/12/2025, 14:30"

4. **Snake Confirmation:**
   - Title: "Xác Nhận Loài Rắn"
   - Photos taken during rescue (gallery)
   - Dropdown: "Chọn loài rắn"
   - Options: List of common snakes + "Khác"
   - If different from AI: Show alert "Khác với kết quả AI"
   - Scientific name field (optional)

5. **Final Details:**
   - Snake size: Slider or input "~120 cm"
   - Snake condition: "Khỏe mạnh" / "Bị thương" / "Đã chết"
   - Release location: Text input
   - Notes: Text area (from Screen 8, editable)

6. **Fee Reminder:**
   - "Bạn sẽ nhận: 170,000 VNĐ"
   - "Khách hàng thanh toán sau"

7. **Action Button:**
   - Primary: "XÁC NHẬN HOÀN THÀNH" (green, large)

#### Stitch Prompt (English):

```
Mobile app rescue completion confirmation screen. Success documentation interface with green (#28A745) and orange-red (#FF6B35) theme.

Top navigation: Back arrow left, title "Xác Nhận Hoàn Thành" bold dark gray centered.

Success section centered: Large animated green checkmark icon (80px) with scale-in effect. Below, bold green text "Đã bắt rắn thành công!" (22pt). Confetti animation background.

Summary card white rounded shadow: Three rows with icons:
- Clock icon, "Thời gian: 15 phút" gray
- Location pin icon, "123 Nguyễn Văn Linh" gray
- Calendar icon, "8/12/2025, 14:30" gray

Snake confirmation card: Bold title "Xác Nhận Loài Rắn" dark gray (18pt) with red asterisk. Horizontal scrollable photo gallery showing 3 captured snake images (120px square, rounded). Below gallery, dropdown selector with down arrow "Chọn loài rắn" - placeholder, border orange. If selected different from AI, show yellow alert box "⚠️ Khác với kết quả AI (Rắn Hổ Mang)". Optional text input "Tên khoa học (tùy chọn)" below.

Details section: Label "Kích thước ước tính" with slider 0-200cm, current value "~120 cm" displayed. Label "Tình trạng" with three radio buttons horizontal: "Khỏe mạnh" (selected green), "Bị thương", "Đã chết". Label "Địa điểm thả" with text input placeholder "VD: Rừng xa dân cư". Label "Ghi chú bổ sung" with text area (2 lines) showing previous notes.

Fee reminder card green background light (#E8F5E9): Bold green text "Bạn sẽ nhận: 170,000 VNĐ" (20pt) centered. Below, small gray text "Khách hàng thanh toán sau".

Bottom: Large solid green button "XÁC NHẬN HOÀN THÀNH" full width (55px height) with checkmark icon.

Design: Celebration of success, thorough documentation, species verification, clear financial expectation.
```

#### Notes for Stitch:
- Success animation để celebrate
- Snake confirmation critical - nếu khác AI, phải có alert
- All fields validate trước khi submit
- Fee reminder để set expectation

---

### Screen 9B MỚI: Final Price Calculation (System Auto-Calculate)

#### Thông tin màn hình:
- **Tên:** Màn hình tính toán giá cuối cùng (Hệ thống tự động)
- **Mục đích:** Rescuer nhập thông tin thực tế (số lượng, độ khó), hệ thống tự động tính giá - NO MANUAL PRICE INPUT
- **Flow position:** Sau Screen 9 (Completion) → Trước Screen 10 (Waiting for Payment)
- **Model:** System calculates price based on: quantity, venom level, difficulty, distance, time
- **Priority:** ⭐⭐⭐

#### Entry Points:
- Sau khi tap "XÁC NHẬN HOÀN THÀNH" ở Screen 9

#### Exit Points:
- **Success:** Tap "GỬI KẾT QUẢ CHO KHÁCH HÀNG" → Navigate to Screen 10 (Waiting for Payment)
- **Back:** Edit completion details → Back to Screen 9

---

#### Key Components:

##### 1. Header (Fixed)
```
┌─────────────────────────────────────────┐
│  [<]  Tính Toán Giá Cuối Cùng          │
└─────────────────────────────────────────┘
```
- **Title:** "Tính Toán Giá Cuối Cùng" (18pt Medium, #1C1C1E)
- **Back Button:** [<] (can go back to edit Screen 9)
- **Height:** 60px
- **Background:** #FFFFFF
- **Border:** Bottom 1px #E5E5E5

---

##### 2. Info Banner (Important)
```
┌─────────────────────────────────────────┐
│  ℹ️ Hệ thống sẽ tính toán giá dựa trên │
│     thông tin bạn cung cấp              │
│                                         │
│  Bạn KHÔNG cần nhập số tiền thủ công   │
└─────────────────────────────────────────┘
```
- **Background:** #E7F3FF (light blue)
- **Icon:** ℹ️
- **Text:** 14pt Regular, #007AFF
- **Message:** Explains system auto-calculation
- **Bold emphasis:** "KHÔNG cần nhập số tiền thủ công"
- **Padding:** 16px
- **Border Radius:** 12px
- **Margin:** 16px

---

##### 3. Actual Rescue Details Section

**Section Title:** "Chi Tiết Thực Tế" (16pt Bold, #1C1C1E)

###### 3.1 Quantity Captured
```
┌─────────────────────────────────────────┐
│  Số lượng bắt được *                   │
│  ─────────────────────────────────────  │
│  [  1  ▼  ]                            │
│                                         │
│  ⓘ Dự kiến: 1 con                     │
└─────────────────────────────────────────┘
```
- **Label:** "Số lượng bắt được" + red asterisk (required)
- **Input Type:** Dropdown selector
- **Options:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 10+ (custom input)
- **Default:** Pre-filled from request (e.g., 1)
- **Comparison Note:** Shows expected vs actual
  - If same: "ⓘ Dự kiến: 1 con" (gray)
  - If different: "⚠️ Khác dự kiến (1 con)" (amber)
- **Height:** 50px dropdown
- **Border:** 1px #D1D1D6
- **Border Radius:** 8px

###### 3.2 Difficulty Level
```
┌─────────────────────────────────────────┐
│  Độ khó thực tế *                      │
│  ─────────────────────────────────────  │
│  [ Dễ ]  [ Trung Bình ]  [ Khó ]      │
│                                         │
│  ⓘ Độ khó ảnh hưởng đến giá cuối      │
└─────────────────────────────────────────┘
```
- **Label:** "Độ khó thực tế" + red asterisk
- **Input Type:** 3 radio chips (horizontal)
- **Options:**
  - **Dễ:** Light green chip #E8F5E9
  - **Trung Bình:** Amber chip #FFF9E6 (pre-selected)
  - **Khó:** Orange chip #FFE5CC
- **Selection:** Bold border 2px, filled background
- **Info Note:** "ⓘ Độ khó ảnh hưởng đến giá cuối" (12pt gray)
- **Height:** 48px chips
- **Spacing:** 8px between chips

**Difficulty Calculation:**
- **Dễ:** +0% bonus
- **Trung Bình:** +15% bonus
- **Khó:** +30% bonus

###### 3.3 Photo Upload
```
┌─────────────────────────────────────────┐
│  Ảnh chứng minh *                      │
│  ─────────────────────────────────────  │
│  [📷]  [IMG1]  [IMG2]  [IMG3]         │
│                                         │
│  Tối thiểu 2 ảnh (rắn + địa điểm)     │
└─────────────────────────────────────────┘
```
- **Label:** "Ảnh chứng minh" + red asterisk
- **Input Type:** Photo gallery (horizontal scroll)
- **Requirement:** Minimum 2 photos
  - Photo 1: Snake captured
  - Photo 2: Release location or environment
- **Camera Button:** [📷] 50×50px, blue #007AFF
- **Preview Thumbnails:** 80×80px rounded 8px
- **Max Photos:** 5
- **Validation:** Shows error if < 2 photos
- **Note:** "Tối thiểu 2 ảnh (rắn + địa điểm)" (12pt gray)

###### 3.4 Time Spent (Auto-Tracked)
```
┌─────────────────────────────────────────┐
│  Thời gian thực tế                     │
│  ─────────────────────────────────────  │
│  ⏱️ 18 phút                            │
│                                         │
│  [  Điều chỉnh thủ công  ]             │
└─────────────────────────────────────────┘
```
- **Label:** "Thời gian thực tế" (no asterisk - auto-tracked)
- **Display:** Large time "⏱️ 18 phút" (20pt Bold, #007AFF)
- **Source:** Auto-calculated from "BẮT ĐẦU DI CHUYỂN" to completion
- **Manual Adjust:** Link "Điều chỉnh thủ công" (blue)
  - Opens dialog with +/- buttons or time picker
- **Time Bonus:** >60 min adds 50,000 VNĐ bonus
- **Background:** #F9F9F9
- **Padding:** 16px

###### 3.5 Distance Traveled (GPS-Tracked)
```
┌─────────────────────────────────────────┐
│  Khoảng cách di chuyển                 │
│  ─────────────────────────────────────  │
│  📍 2.3 km                             │
│                                         │
│  Tự động tính từ GPS                   │
└─────────────────────────────────────────┘
```
- **Label:** "Khoảng cách di chuyển" (display only)
- **Display:** "📍 2.3 km" (20pt Bold, green #28A745)
- **Source:** GPS tracking from rescuer → patient location
- **Note:** "Tự động tính từ GPS" (12pt gray)
- **Distance Calculation:** 5,000 VNĐ per km
- **Background:** #F9F9F9
- **Padding:** 16px

---

##### 4. Venom Level (Auto-Retrieved from AI)
```
┌─────────────────────────────────────────┐
│  Mức độ độc (từ AI)                    │
│  ─────────────────────────────────────  │
│  ⚠️ CAO - Rắn hổ mang chúa            │
│                                         │
│  Bonus: +100,000 VNĐ                  │
└─────────────────────────────────────────┘
```
- **Label:** "Mức độ độc (từ AI)" (display only)
- **Display:** 
  - **HIGH:** Red badge "⚠️ CAO" + species name
  - **MEDIUM:** Amber badge "⚠️ TRUNG BÌNH"
  - **LOW:** Green badge "✓ THẤP"
- **Bonus Display:** Shows venom bonus amount
  - HIGH: +100,000 VNĐ
  - MEDIUM: +50,000 VNĐ
  - LOW: +0 VNĐ
- **Source:** Retrieved from AI recognition (Screen 2)
- **Background:** Light color matching badge
- **Padding:** 16px

---

##### 5. System Price Calculation Section

**Section Title:** "Tính Toán Giá" (16pt Bold, #1C1C1E)

```
┌─────────────────────────────────────────┐
│  Giá Cơ Bản                            │
│  500,000 VNĐ                           │
│                                         │
│  Hệ Số Nhân                            │
│  × 1 con rắn                           │
│                                         │
│  Các Khoản Thêm                        │
│  + Độc cao:        100,000 VNĐ         │
│  + Độ khó (Trung):  75,000 VNĐ         │
│  + Khoảng cách:     11,500 VNĐ         │
│  + Thời gian (<60): 0 VNĐ              │
│  ─────────────────────────────────────  │
│  Tổng Cộng:        686,500 VNĐ         │
│                                         │
│  Phí Nền Tảng (10%): -68,650 VNĐ      │
│  Phí Bảo Hiểm (5%):  -34,325 VNĐ      │
│  ═════════════════════════════════════  │
│  Bạn Nhận Được:     583,525 VNĐ       │
└─────────────────────────────────────────┘
```

**Breakdown Components:**

###### 5.1 Base Price
- **Label:** "Giá Cơ Bản" (14pt Medium)
- **Value:** "500,000 VNĐ" (18pt Bold, gray #8E8E93)
- **Fixed:** Always 500K base

###### 5.2 Quantity Multiplier
- **Label:** "Hệ Số Nhân" (14pt Medium)
- **Value:** "× [X] con rắn" (16pt, gray)
- **Calculation:** Base price × quantity

###### 5.3 Bonuses Section
- **Label:** "Các Khoản Thêm" (14pt Medium)
- **Line Items:**
  - "Độc cao/trung/thấp: [amount] VNĐ"
  - "Độ khó (Dễ/Trung/Khó): [amount] VNĐ"
  - "Khoảng cách: [amount] VNĐ" (distance × 5,000)
  - "Thời gian (>60 min): [amount] VNĐ"
- **Format:** Label left-aligned, amount right-aligned
- **Font:** 14pt Regular
- **Color:** Green #28A745 for positive amounts

###### 5.4 Subtotal
- **Separator:** Thin line 1px #D1D1D6
- **Label:** "Tổng Cộng" (16pt Bold)
- **Value:** "[amount] VNĐ" (20pt Bold, green #28A745)
- **Background:** Light green #F0FFF4
- **Padding:** 12px

###### 5.5 Platform Fees
- **Platform Fee:** "-[amount] VNĐ (10%)" (14pt, red #FF3B30)
- **Insurance Fee:** "-[amount] VNĐ (5%)" (14pt, red #FF3B30)
- **Format:** Negative amounts in red

###### 5.6 Final Rescuer Earning
- **Separator:** Double line 2px #28A745
- **Label:** "Bạn Nhận Được" (18pt Bold)
- **Value:** "[amount] VNĐ" (28pt Bold, green #28A745)
- **Background:** Green #E8F5E9
- **Padding:** 16px
- **Border:** 2px green
- **Border Radius:** 12px

**Calculation Logic:**
```javascript
basePrice = 500000;
quantityMultiplier = quantity; // From input

// Bonuses
venomBonus = venomLevel === "HIGH" ? 100000 : 
             venomLevel === "MEDIUM" ? 50000 : 0;
difficultyBonus = difficulty === "HARD" ? 150000 :
                  difficulty === "MEDIUM" ? 75000 : 0;
distanceBonus = distance * 5000; // 5K per km
timeBonus = timeSpent > 60 ? 50000 : 0;

// Subtotal
subtotal = (basePrice + venomBonus + difficultyBonus) * quantityMultiplier
           + distanceBonus + timeBonus;

// Fees
platformFee = subtotal * 0.10;
insuranceFee = subtotal * 0.05;

// Final
rescuerEarning = subtotal - platformFee - insuranceFee; // 85% of subtotal
```

---

##### 6. Customer Will Pay Section
```
┌─────────────────────────────────────────┐
│  ℹ️ Khách hàng sẽ thanh toán           │
│                                         │
│  686,500 VNĐ                           │
│                                         │
│  (Bao gồm phí nền tảng & bảo hiểm)    │
└─────────────────────────────────────────┘
```
- **Background:** #FFF9E6 (amber)
- **Icon:** ℹ️
- **Label:** "Khách hàng sẽ thanh toán" (14pt Medium)
- **Amount:** Subtotal (before fee deduction) - This is what patient pays
- **Font:** 24pt Bold, #FF9500
- **Note:** "(Bao gồm phí nền tảng & bảo hiểm)" (12pt gray)
- **Padding:** 16px
- **Border:** Left 4px #FF9500

---

##### 7. Bottom Actions Section
```
┌─────────────────────────────────────────┐
│  [ GỬI KẾT QUẢ CHO KHÁCH HÀNG ]       │
│                                         │
│  ⓘ Giá sẽ được gửi đến khách hàng      │
│     để thanh toán                       │
└─────────────────────────────────────────┘
```
- **Primary Button:**
  - Text: "GỬI KẾT QUẢ CHO KHÁCH HÀNG" (16pt Bold)
  - Background: Green #28A745
  - Height: 60px
  - Width: 90% centered
  - Icon: Paper plane 📤
  - Border Radius: 12px
  - Disabled until all required fields filled
- **Info Note:**
  - "ⓘ Giá sẽ được gửi đến khách hàng để thanh toán"
  - Font: 12pt Regular
  - Color: #8E8E93
  - Centered
- **Padding:** 20px

---

##### 8. Validation

**Required Fields:**
- Quantity (dropdown) - Must select
- Difficulty (radio) - Must select
- Photos - Minimum 2 uploaded
- Time - Auto-filled (can adjust)
- Distance - Auto-filled from GPS

**Validation Errors:**

If missing quantity:
```
┌─────────────────────────────────────────┐
│  ⚠️ Vui lòng chọn số lượng bắt được    │
└─────────────────────────────────────────┘
```

If missing difficulty:
```
┌─────────────────────────────────────────┐
│  ⚠️ Vui lòng chọn độ khó thực tế       │
└─────────────────────────────────────────┘
```

If < 2 photos:
```
┌─────────────────────────────────────────┐
│  ⚠️ Vui lòng tải lên ít nhất 2 ảnh    │
└─────────────────────────────────────────┘
```

**Error Style:**
- Red background #FFEBEE
- Red text #D32F2F
- Icon: ⚠️
- Padding: 12px
- Border: Left 4px #D32F2F

---

#### Interaction Flows:

##### Flow 1: Standard Completion (Same as Expected)
1. Screen loads with pre-filled data:
   - Quantity: 1 (from request)
   - Difficulty: Trung Bình (pre-selected)
   - Time: 18 min (auto-tracked)
   - Distance: 2.3 km (GPS)
   - Venom: CAO (from AI)
2. Rescuer uploads 2 photos
3. Reviews calculation:
   - Base: 500K
   - Venom: +100K
   - Difficulty: +75K
   - Distance: +11.5K
   - Subtotal: 686.5K
   - Rescuer gets: 583.5K (85%)
   - Patient pays: 686.5K
4. Tap "GỬI KẾT QUẢ CHO KHÁCH HÀNG"
5. Navigate to Screen 10 (Waiting for Payment)

##### Flow 2: Different Quantity/Difficulty
1. Screen loads
2. Rescuer changes quantity: 1 → 2
3. Calculation updates in real-time:
   - Base: 500K × 2 = 1,000K
   - Venom: +100K × 2 = +200K
   - Difficulty: +75K × 2 = +150K
   - Distance: +11.5K (same)
   - Subtotal: 1,361.5K
   - Rescuer gets: 1,157K
   - Patient pays: 1,361.5K
4. Rescuer selects difficulty: Khó
5. Calculation updates again:
   - Difficulty bonus: +150K × 2 = +300K
   - New subtotal: 1,511.5K
6. Upload photos
7. Submit

##### Flow 3: Manual Time Adjustment
1. Screen loads with auto-tracked time: 18 min
2. Rescuer taps "Điều chỉnh thủ công"
3. Dialog appears with time picker
4. Adjusts to 65 minutes
5. Calculation updates:
   - Time bonus: +50K (>60 min threshold)
   - Subtotal increases by 50K
6. Submit

##### Flow 4: Validation Error
1. Rescuer taps submit without uploading photos
2. Error banner appears: "⚠️ Vui lòng tải lên ít nhất 2 ảnh"
3. Button remains disabled
4. Rescuer uploads 2 photos
5. Error clears, button enables
6. Submit successful

---

#### Real-Time Calculation Logic:

```javascript
// Watch for changes
watch([quantity, difficulty, time, distance, venom], () => {
  recalculatePrice();
});

function recalculatePrice() {
  const base = 500000;
  const qty = quantityInput.value;
  
  // Bonuses
  const venomMap = { "HIGH": 100000, "MEDIUM": 50000, "LOW": 0 };
  const difficultyMap = { "HARD": 150000, "MEDIUM": 75000, "EASY": 0 };
  
  const venomBonus = venomMap[venomLevel];
  const diffBonus = difficultyMap[difficulty];
  const distBonus = distance * 5000;
  const timeBonus = time > 60 ? 50000 : 0;
  
  // Subtotal
  const subtotal = (base + venomBonus + diffBonus) * qty
                   + distBonus + timeBonus;
  
  // Fees
  const platformFee = subtotal * 0.10;
  const insuranceFee = subtotal * 0.05;
  
  // Final
  const rescuerEarning = subtotal * 0.85;
  const patientPays = subtotal;
  
  // Update UI
  updatePriceDisplay({
    base,
    qty,
    venomBonus,
    diffBonus,
    distBonus,
    timeBonus,
    subtotal,
    platformFee,
    insuranceFee,
    rescuerEarning,
    patientPays
  });
}
```

---

#### UI States:

**State 1: Initial Load**
- All fields pre-filled with defaults
- Calculation shown with default values
- Submit button disabled (waiting for photos)

**State 2: Editing**
- User changes quantity/difficulty
- Price recalculates instantly
- Smooth number animation for amounts

**State 3: Validated (Ready)**
- All required fields filled
- Photos uploaded (≥2)
- Submit button enabled (green, pulsing slightly)

**State 4: Error**
- Missing required fields highlighted red
- Error banners appear above submit button
- Submit button disabled

**State 5: Submitting**
- Loading spinner on button
- "Đang gửi..." text
- Fields disabled

---

#### Stitch Prompt:

```
Design an iOS-native final price calculation screen for SnakeAid rescuer app after completing rescue.

CRITICAL REQUIREMENTS:
1. System auto-calculates price - NO manual price input by rescuer
2. Real-time calculation updates as rescuer inputs details
3. Clear breakdown: Base + Bonuses - Fees = Rescuer Earning
4. Show both: What rescuer gets (85%) and what patient pays (100%)

LAYOUT (Top to Bottom):

1. HEADER (60px):
   - Back button [<]
   - Title: "Tính Toán Giá Cuối Cùng"

2. INFO BANNER:
   - Light blue background #E7F3FF
   - "ℹ️ Hệ thống sẽ tính toán giá dựa trên thông tin bạn cung cấp"
   - Bold: "Bạn KHÔNG cần nhập số tiền thủ công"

3. ACTUAL RESCUE DETAILS:
   - Section title: "Chi Tiết Thực Tế" (16pt Bold)
   
   a) Quantity dropdown:
      - Label: "Số lượng bắt được *"
      - Dropdown: 1, 2, 3... 10+
      - Note: "ⓘ Dự kiến: 1 con" (gray)
   
   b) Difficulty radio chips (horizontal):
      - "Dễ" (green chip) | "Trung Bình" (amber, selected) | "Khó" (orange)
      - Note: "ⓘ Độ khó ảnh hưởng đến giá cuối"
   
   c) Photo upload:
      - Camera button + thumbnails (horizontal scroll)
      - "Tối thiểu 2 ảnh (rắn + địa điểm)"
   
   d) Time display (auto):
      - "⏱️ 18 phút" (20pt blue)
      - Link: "Điều chỉnh thủ công"
   
   e) Distance display (auto):
      - "📍 2.3 km" (20pt green)
      - "Tự động tính từ GPS" (gray)

4. VENOM LEVEL (auto from AI):
   - "⚠️ CAO - Rắn hổ mang chúa" (red badge)
   - "Bonus: +100,000 VNĐ"

5. PRICE CALCULATION BREAKDOWN:
   - Section title: "Tính Toán Giá" (16pt Bold)
   - White card with shadow:
   
   ```
   Giá Cơ Bản
   500,000 VNĐ (gray, 18pt)
   
   Hệ Số Nhân
   × 1 con rắn (gray, 16pt)
   
   Các Khoản Thêm
   + Độc cao:        100,000 VNĐ (green)
   + Độ khó (Trung):  75,000 VNĐ (green)
   + Khoảng cách:     11,500 VNĐ (green)
   + Thời gian:            0 VNĐ (gray)
   ────────────────────────────────
   Tổng Cộng:        686,500 VNĐ (green 20pt, light green bg)
   
   Phí Nền Tảng (10%): -68,650 VNĐ (red)
   Phí Bảo Hiểm (5%):  -34,325 VNĐ (red)
   ════════════════════════════════
   Bạn Nhận Được:     583,525 VNĐ (green 28pt, green bg, bold)
   ```

6. PATIENT PAYMENT INFO:
   - Amber banner #FFF9E6
   - "ℹ️ Khách hàng sẽ thanh toán"
   - "686,500 VNĐ" (24pt amber)
   - "(Bao gồm phí nền tảng & bảo hiểm)"

7. BOTTOM ACTION:
   - Button: "GỬI KẾT QUẢ CHO KHÁCH HÀNG" (green, 60px, 📤)
   - Note: "ⓘ Giá sẽ được gửi đến khách hàng để thanh toán"
   - Disabled until all fields filled

VALIDATION ERRORS:
- Red banner if missing quantity: "⚠️ Vui lòng chọn số lượng bắt được"
- Red banner if missing difficulty: "⚠️ Vui lòng chọn độ khó thực tế"
- Red banner if < 2 photos: "⚠️ Vui lòng tải lên ít nhất 2 ảnh"

INTERACTIONS:
- Price recalculates INSTANTLY when quantity/difficulty changes
- Smooth number animations (count up/down)
- Submit button enabled only when validated
- Photo upload opens camera/gallery

DESIGN STYLE:
- iOS native
- SF Pro font
- Green theme (#28A745) for positive amounts
- Red (#FF3B30) for deductions
- Smooth animations (0.3s ease)
- Clear visual hierarchy
- Professional financial breakdown

Create a transparent, automated price calculation interface that prevents manual price manipulation and provides clear breakdown for both rescuer and patient payments.
```

---

### Screen 10: Waiting for Payment Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chờ thanh toán từ khách hàng
- **Mục đích:** Show status của payment process và rating (FE-26, FE-27)
- **Flow position:** Giai đoạn 2.4 - Sau khi confirm completion
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chờ Thanh Toán"

2. **Completion Status:**
   - Green checkmark: "Nhiệm vụ hoàn thành"
   - Info sent to: "Nguyễn Văn A"

3. **Payment Status:**
   - Status badge: "Đang chờ khách hàng thanh toán"
   - Timer: "Chờ từ: 2 phút trước"

4. **Expected Payment:**
   - Amount: "170,000 VNĐ" (bold, green, large)
   - Breakdown reminder:
     - "Phí cứu hộ: 200,000 VNĐ"
     - "Phí nền tảng: -20,000 VNĐ"
     - "Quỹ bảo hiểm: -10,000 VNĐ"

5. **Mission Summary:**
   - Snake: "Rắn Hổ Mang"
   - Time: "15 phút"
   - Location: "123 Nguyễn Văn Linh"
   - Photos count: "3 ảnh"

6. **Auto-notification:**
   - Text: "Chúng tôi đã gửi yêu cầu thanh toán đến khách hàng"
   - "Bạn sẽ nhận thông báo khi thanh toán thành công"

7. **Quick Actions:**
   - "Xem chi tiết nhiệm vụ"
   - "Nhắn tin với khách hàng"

8. **Navigation:**
   - Button: "Về Trang Chủ" (outlined)

#### Stitch Prompt (English):

```
Mobile app waiting for payment screen after rescue completion. Payment pending interface with green (#28A745) theme.

Top navigation: Back arrow left, title "Chờ Thanh Toán" bold dark gray centered.

Completion status card: Large green checkmark icon (60px) left, bold text "Nhiệm vụ hoàn thành" green (18pt) right. Below, small gray text "Đã gửi thông tin đến Nguyễn Văn A" with send icon.

Payment status card: Orange badge "Đang chờ khách hàng thanh toán" with clock icon. Below badge, gray text "Chờ từ: 2 phút trước" with timer icon.

Expected payment card white shadow prominent: Very large bold green "170,000 VNĐ" centered (32pt). Below, small gray text "Bạn sẽ nhận:" above amount. Thin divider line. Breakdown in small gray text:
- Phí cứu hộ: 200,000 VNĐ
- Phí nền tảng: -20,000 VNĐ
- Quỹ bảo hiểm: -10,000 VNĐ

Mission summary card: Four rows with icons and gray text:
- Snake icon, "Rắn Hổ Mang - Có độc"
- Clock icon, "Thời gian: 15 phút"
- Location pin icon, "123 Nguyễn Văn Linh"
- Camera icon, "3 ảnh đã ghi nhận"

Info card light blue background: Blue info icon left, text "Chúng tôi đã gửi yêu cầu thanh toán đến khách hàng. Bạn sẽ nhận thông báo khi thanh toán thành công" gray right.

Quick actions: Two text links blue:
- "Xem chi tiết nhiệm vụ"
- "Nhắn tin với khách hàng"

Bottom: Large outlined orange button "Về Trang Chủ" full width.

Design: Clear payment expectation, mission recap, patient reassurance during wait time.
```

#### Notes for Stitch:
- Auto-refresh khi có payment update
- Push notification khi payment complete
- Có thể message Patient nếu cần

---

## 🔗 NAVIGATION FLOW

```
Notification Alert (Screen 1)
    │
    ├─→ Rescue Request Detail (Screen 2)
    │   │
    │   ├─→ [Optional] Expert Consultation Request (Screen 3)
    │   │   └─→ Waiting for Expert (Screen 4)
    │   │       └─→ Expert Chat (Screen 5)
    │   │           └─→ Back to Detail (Screen 2)
    │   │
    │   ├─→ ACCEPT → En Route (Screen 6)
    │   │   └─→ Arrived (Screen 7)
    │   │       └─→ Rescue in Progress (Screen 8)
    │   │           └─→ Completion (Screen 9)
    │   │               └─→ Waiting for Payment (Screen 10)
    │   │                   └─→ [Payment Success] → Dashboard
    │   │
    │   └─→ DECLINE → Dashboard
```

---

## 📋 FEATURE MAPPING

| Screen | Related Major Features | Priority |
|--------|------------------------|----------|
| Notification Alert | FE-01, FE-02 | ⭐⭐⭐ |
| Request Detail | FE-02, FE-06, FE-09, FE-10, FE-21, FE-23 | ⭐⭐⭐ |
| Expert Consultation Request | FE-12 | ⭐⭐ |
| Waiting for Expert | FE-12 | ⭐⭐ |
| Expert Chat | FE-12, FE-14 | ⭐⭐⭐ |
| En Route | FE-07, FE-18, FE-19, FE-20 | ⭐⭐⭐ |
| Arrived | FE-20 | ⭐⭐⭐ |
| Rescue in Progress | FE-07, FE-16 | ⭐⭐⭐ |
| Completion | FE-15, FE-16 | ⭐⭐⭐ |
| Waiting for Payment | FE-24, FE-25, FE-26, FE-27 | ⭐⭐ |

---

## ✅ DESIGN CHECKLIST

Before implementation:

- [ ] All screens follow design system (colors, typography, spacing)
- [ ] Countdown timers functional và visible
- [ ] Photo galleries swipeable và zoomable
- [ ] GPS tracking real-time updates
- [ ] Map integration với Google Maps/Apple Maps
- [ ] Call buttons direct dial functionality
- [ ] Expert consultation chat real-time
- [ ] Status updates auto-notify Patient
- [ ] Payment breakdown transparent và clear
- [ ] Safety guidelines easily accessible
- [ ] Equipment checklist interactive
- [ ] Loading states for all async operations
- [ ] Error states for failed operations
- [ ] Offline mode considerations
- [ ] Push notifications cho critical updates

---

## 🔗 RELATED DOCUMENTATION

- **Main Flow:** `/01-Requirements/Main-Flow/Main-Flow.md` (Section 2)
- **Swimlane Diagram:** `/01-Requirements/Swimlane-Diagram/02-Swimlane-Rescue-Request-Flow.md`
- **Major Features:** `/01-Requirements/Major-Features/Major-Features-Summary.md` (Rescuer section)
- **Emergency Flow:** `/02-UI-Design/Rescuer/Rescuer-Emergency-Response-Flow-Screens.md`

---

**Last Updated:** December 8, 2025  
**Status:** ✅ Complete  
**Total Screens:** 10 screens

---

## 📊 IMPLEMENTATION NOTES

### Technical Requirements:
1. **Real-time GPS Tracking:** WebSocket connection cho live location updates
2. **Push Notifications:** Firebase Cloud Messaging cho incoming requests
3. **Maps Integration:** Google Maps SDK / Apple Maps
4. **Photo Upload:** Camera access + image compression
5. **Chat System:** WebSocket cho real-time messaging với Expert
6. **Timer/Countdown:** Precise countdown với server sync
7. **Payment Integration:** Connect với payment gateway APIs

### Business Logic:
1. **Matching Algorithm:** Backend tìm top 3 Rescuers dựa trên distance, rating, availability
2. **Timeout Handling:** 2 phút để accept, nếu không auto-decline và gửi cho Rescuer khác
3. **Fee Calculation:** 85% Rescuer, 10% Platform, 5% Insurance fund
4. **Expert Consultation:** Free cho Rescuers, không tính vào fee
5. **Rating Impact:** Rating từ Patient ảnh hưởng priority trong matching

### Security:
1. **Location Privacy:** Chỉ chia sẻ location khi mission active
2. **Payment Security:** Escrow system - hold payment until completion
3. **Photo Privacy:** Auto-delete sau 30 ngày nếu không dispute
4. **Chat History:** Encrypted và lưu để dispute resolution

### Analytics Events:
- `rescue_request_received`
- `rescue_request_accepted`
- `rescue_request_declined`
- `expert_consultation_requested`
- `en_route_started`
- `arrived_at_location`
- `rescue_started`
- `rescue_completed`
- `payment_received`
- `rating_received`
