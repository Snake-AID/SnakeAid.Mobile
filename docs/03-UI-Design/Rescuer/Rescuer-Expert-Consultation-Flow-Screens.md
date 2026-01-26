# EXPERT CONSULTATION FLOW - UI DESIGN SCREENS (RESCUER ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Rescuer Mobile Application
- **Role:** 🚑 **SNAKE RESCUER** (Đội cứu hộ rắn chuyên nghiệp)
- **Flow:** Expert Consultation Flow (Luồng yêu cầu tư vấn chuyên gia khẩn cấp)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 5 screens
- **Ngày tạo:** December 8, 2025
- **Location:** `/02-UI-Design/Rescuer/Rescuer-Expert-Consultation-Flow-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **RESCUER role** trong **Expert Consultation Flow** (Swimlane 3 - Giai đoạn 3.2).
> Đây là flow khi Rescuer đang ở hiện trường gặp khó khăn nhận diện rắn và cần hỗ trợ khẩn cấp từ Expert.

---

## 🎯 Flow Context (From Swimlane Diagram)

### Giai đoạn 3.2: RESCUER YÊU CẦU HỖ TRỢ KHẨN CẤP

**Rescuer's Journey trong Expert Consultation Flow:**

```
1. Rescuer đang ở hiện trường (đang thực hiện cứu hộ)
   ↓
2. Gặp khó khăn nhận diện loài rắn chính xác
   - AI không chắc chắn (độ tin cậy thấp < 70%)
   - Rắn có đặc điểm lạ, khó phân biệt
   - Rắn ngoại lai chưa có trong database
   ↓
3. Rescuer mở app → Chọn "Yêu cầu hỗ trợ chuyên gia" (FE-12)
   ↓
4. App kích hoạt camera để chụp ảnh/video real-time (FE-14)
   ↓
5. Rescuer chụp ảnh hoặc quay video rắn tại hiện trường
   ↓
6. Gửi yêu cầu khẩn cấp lên Backend
   ↓
7. Backend tìm Expert đang online (ưu tiên theo khu vực địa lý)
   ↓
8. Expert chấp nhận yêu cầu nhanh nhất → Kết nối
   ↓
9. Bắt đầu phiên tư vấn real-time (FE-11)
   - Chat text hoặc video call
   - Expert xem ảnh/video rắn
   - Expert phân tích đặc điểm
   ↓
10. Expert xác định loài rắn và tư vấn cách bắt an toàn
    - Tên loài rắn chính xác
    - Mức độ nguy hiểm (độc tính, tính hung dữ)
    - Thiết bị cần dùng
    - Kỹ thuật bắt phù hợp
    - Cảnh báo rủi ro đặc biệt
    ↓
11. Rescuer nhận hướng dẫn từ Expert
    ↓
12. Áp dụng kỹ thuật được tư vấn để bắt rắn
    ↓
13. Kết thúc phiên tư vấn khi bắt thành công
    ↓
14. Thanh toán tự động (Nền tảng trả phí hoặc Rescuer chia 10% phí cứu hộ)
```

### Key Features for Rescuer in Expert Consultation Flow:
- **FE-12:** Yêu cầu hỗ trợ từ xa khi gặp loài rắn khó xác định
- **FE-13:** Trao đổi thông tin với chuyên gia rắn để nhận diện chính xác
- **FE-14:** Chia sẻ ảnh/video real-time với chuyên gia
- **FE-11:** Tư vấn qua chat hoặc video call
- **FE-21:** AI nhận diện rắn (xem kết quả không chắc chắn)
- **FE-09, FE-10:** Nhận hướng dẫn an toàn bắt rắn từ Expert

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Orange-Red (Emergency) `#FF6B35`
- **Secondary Color:** Deep Orange `#F7931E`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Expert:** Purple `#6A1B9A`
- **Accent - Success:** Green `#28A745`
- **Accent - Danger (Venomous):** Red `#DC3545`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Info:** Blue `#007BFF`
- **Status Active:** Orange `#FF6B35`
- **Status Online:** Green `#00C853`

### Typography:
- **Logo:** Bold, Large (32-36pt)
- **Headings:** Semi-bold (20-24pt)
- **Body Text:** Regular (16-18pt)
- **Button Text:** Medium (16pt)
- **Caption:** Regular (14pt)
- **Expert Name:** Bold (18pt)

### Component Style:
- **Cards:** Rounded corners (12px), prominent shadows
- **Buttons:** Rounded (8px), large touch targets (min 50px height)
- **Status Badges:** Rounded pills with color-coded backgrounds
- **Chat Bubbles:** Rounded (16px), differentiated sender colors
- **Video Call:** Full-screen overlay with floating controls
- **Camera View:** Full-screen with capture button and gallery

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🚑 Tất cả screens dưới đây là cho RESCUER role** - yêu cầu hỗ trợ từ Expert khi đang ở hiện trường

---

### Screen 1: Request Expert Help (Entry Point)

#### Thông tin màn hình:
- **Tên:** Màn hình yêu cầu hỗ trợ chuyên gia
- **Mục đích:** Entry point để Rescuer kích hoạt tính năng gọi Expert khi không chắc về loài rắn
- **Flow position:** Giai đoạn 3.2 - Rescuer quyết định yêu cầu hỗ trợ
- **Priority:** ⭐⭐⭐ (Cao - Critical support feature)

#### Key Components:
1. **Context Banner:**
   - Orange background with warning icon
   - Text: "Bạn đang ở hiện trường cứu hộ"
   - Badge: Current mission ID (e.g., "Nhiệm vụ #12345")

2. **AI Result Section (Current Uncertainty):**
   - Title: "Kết quả AI hiện tại"
   - Snake thumbnail with AI prediction
   - Snake name: "Rắn Hổ Mang (?)" (with question mark)
   - Confidence badge: "Độ tin cậy: 45%" (RED - Low confidence)
   - Warning text: "Độ tin cậy thấp - Nên xác minh với chuyên gia"

3. **Why Request Expert Section:**
   - Icon checklist with reasons:
     * "Rắn có đặc điểm lạ, khó phân biệt"
     * "AI không chắc chắn (< 70%)"
     * "Cần xác nhận trước khi bắt"
     * "Đảm bảo an toàn cho bạn"

4. **Expert Availability Banner:**
   - Green badge: "3 chuyên gia đang online"
   - Small avatars of available experts
   - Text: "Thời gian phản hồi trung bình: 30 giây"

5. **Action Section:**
   - Large primary button: "YÊU CẦU HỖ TRỢ CHUYÊN GIA" (full width, orange-red)
   - Subtitle: "Miễn phí - Được nền tảng hỗ trợ"
   - Info icon with tooltip: "Chuyên gia sẽ giúp bạn nhận diện chính xác và tư vấn cách bắt an toàn"

6. **Bottom Note:**
   - Small gray text: "Lưu ý: Hãy chuẩn bị chụp ảnh hoặc quay video rắn rõ nét để Expert dễ nhận diện"

#### Stitch Prompt (English):

```
Mobile app screen for snake rescuer requesting expert help. Emergency consultation request interface with orange-red (#FF6B35) theme.

Top: Orange background banner (padding 16px) with white warning icon left, white text "Bạn đang ở hiện trường cứu hộ" medium (16pt), small white badge right "Nhiệm vụ #12345" rounded.

Below banner, white background. Section title "Kết quả AI hiện tại" dark gray semi-bold (18pt), margin 16px. Horizontal card white background, border gray light, rounded 12px, padding 12px: Left small snake photo thumbnail (60px square, rounded 8px). Right vertical layout: Snake name "Rắn Hổ Mang (?)" dark gray bold (16pt) with question mark, below small red badge "Độ tin cậy: 45%" rounded. Below card, small red warning text "⚠ Độ tin cậy thấp - Nên xác minh với chuyên gia" (14pt).

Next section margin-top 24px, title "Tại sao cần chuyên gia?" dark gray semi-bold (18pt). Below, vertical list 4 items, each row: Orange checkmark icon left (20px), gray text right (16pt) "Rắn có đặc điểm lạ, khó phân biệt", spacing 12px between rows.

Expert availability banner margin-top 24px, light green background (#E8F5E9), rounded 12px, padding 16px: Left green dot icon (8px), bold dark green text "3 chuyên gia đang online" (16pt). Below, horizontal row 3 small circular expert avatars (32px each, overlap -8px). Below avatars, small gray text "Thời gian phản hồi trung bình: 30 giây" (14pt).

Bottom section margin-top 32px: Large primary button full width "YÊU CẦU HỖ TRỢ CHUYÊN GIA" orange-red (#FF6B35) background, white bold text (16pt), rounded 8px, height 56px. Below button center, small gray text "Miễn phí - Được nền tảng hỗ trợ" (14pt), purple info icon left.

Bottom note margin-top 24px, light gray background (#F5F5F5), rounded 8px, padding 12px, small gray text (14pt) "💡 Lưu ý: Hãy chuẩn bị chụp ảnh hoặc quay video rắn rõ nét để Expert dễ nhận diện".

Overall padding 16px, clean layout, emphasize low AI confidence and expert availability.
```

---

### Screen 2: Capture Snake Photo/Video for Expert

#### Thông tin màn hình:
- **Tên:** Màn hình chụp ảnh/quay video rắn để gửi Expert
- **Mục đích:** Interface để Rescuer chụp ảnh hoặc quay video real-time của rắn tại hiện trường
- **Flow position:** Giai đoạn 3.2 - Rescuer chuẩn bị tài liệu gửi Expert
- **Priority:** ⭐⭐⭐ (Cao - Critical documentation)

#### Key Components:
1. **Full-Screen Camera View:**
   - Live camera feed full screen
   - Grid overlay (rule of thirds) for better framing
   - Focus indicator (square frame) at center

2. **Top Overlay Banner:**
   - Semi-transparent dark background (black 50% opacity)
   - White text: "Chụp ảnh rõ mặt và thân rắn"
   - Small tips icon with expandable tooltip

3. **Tips Expandable Section (Top):**
   - When tapped, shows overlay with tips:
     * "📸 Chụp từ nhiều góc độ (đầu, thân, đuôi)"
     * "💡 Đảm bảo đủ ánh sáng"
     * "🎯 Tập trung vào hoa văn và màu sắc"
     * "📏 Giữ khoảng cách an toàn"

4. **Capture Mode Selector (Bottom):**
   - Segmented control: "Ảnh" | "Video"
   - Selected mode highlighted orange-red

5. **Capture Button (Center Bottom):**
   - Large circular button (80px diameter)
   - Outer ring orange-red, inner white
   - Icon: Camera for photo mode, Record dot for video mode
   - Pulsing animation when ready

6. **Photo Gallery Preview (Bottom Left):**
   - Small circular thumbnail of last captured photo (50px)
   - Badge showing count: "3 ảnh"
   - Tap to view gallery

7. **Flash Toggle (Top Right):**
   - Flash icon button with states: Auto / On / Off
   - White icon on semi-transparent background

8. **Action Buttons (Bottom Right):**
   - Secondary button: "Bỏ qua" (skip - outlined, white text)
   - Primary button: "Gửi cho Expert" (orange-red, white text)
   - "Gửi" button only enabled when at least 1 photo/video captured

9. **Bottom Note:**
   - Small white text on semi-transparent background
   - "Đã chụp: 3 ảnh | Video: 15 giây"

#### Stitch Prompt (English):

```
Mobile app full-screen camera interface for snake photo/video capture. Real-time camera view for expert consultation with orange-red (#FF6B35) theme.

Full screen live camera feed background. Grid overlay (rule of thirds) 2 vertical and 2 horizontal thin white lines (opacity 30%). Center focus square frame white dashed border (100px, 2px dash).

Top overlay semi-transparent black background (opacity 50%), padding 16px: White text "Chụp ảnh rõ mặt và thân rắn" semi-bold (16pt), right small white info icon (20px). When icon tapped, overlay expands showing 4 tips, each row emoji + white text (14pt), spacing 8px.

Top-right corner: Flash toggle button white icon (24px) on semi-transparent black circle (48px), states cycling Auto/On/Off.

Bottom section overlay semi-transparent black background (opacity 60%): Center large circular capture button (80px diameter), outer ring orange-red (#FF6B35) 4px, inner circle white. Inside icon: camera for photo mode, or red record dot for video mode. Pulsing animation subtle.

Above capture button: Segmented control horizontal, 2 segments "Ảnh" and "Video", white borders, selected segment filled orange-red background white text, unselected transparent white text (16pt).

Bottom-left: Small circular thumbnail last photo (50px diameter, rounded full), small orange badge top-right corner "3" white text. Semi-transparent black background behind.

Bottom-right: Two stacked buttons, spacing 8px. Top button "Bỏ qua" white outlined border white text (14pt), height 40px, rounded 8px. Bottom button "Gửi cho Expert" orange-red (#FF6B35) background white bold text (16pt), height 48px, rounded 8px, disabled state gray.

Very bottom center: Small white text on semi-transparent black background "Đã chụp: 3 ảnh | Video: 15 giây" (12pt).

Overall full-screen immersive camera UI, professional photography guidance, clear action buttons.
```

---

### Screen 3: Waiting for Expert Response

#### Thông tin màn hình:
- **Tên:** Màn hình chờ Expert phản hồi
- **Mục đích:** Loading state khi hệ thống đang tìm Expert online và gửi yêu cầu
- **Flow position:** Giai đoạn 3.2 - Backend matching Expert với Rescuer
- **Priority:** ⭐⭐ (Trung bình - Intermediate state)

#### Key Components:
1. **Header:**
   - Title: "Đang tìm chuyên gia..."
   - Subtitle: "Vui lòng chờ trong giây lát"

2. **Animated Loading Indicator:**
   - Large circular spinner (orange-red color)
   - Pulsing dots animation below spinner
   - Text: "Đang kết nối với chuyên gia online"

3. **Preview Section:**
   - Small card showing request summary:
     * "Yêu cầu hỗ trợ của bạn"
     * Snake photo thumbnail
     * "3 ảnh đã gửi"
     * Current location
     * Timestamp: "Vừa gửi"

4. **Expert Matching Progress:**
   - Progress steps with checkmarks:
     * ✓ "Đã gửi yêu cầu khẩn cấp"
     * ⏳ "Đang tìm chuyên gia phù hợp..."
     * ⏸ "Chờ chuyên gia chấp nhận"
   - Current step highlighted orange

5. **Info Banner:**
   - Light blue background
   - Icon: Info
   - Text: "Thời gian phản hồi trung bình: 30 giây"
   - Text: "Top 3 chuyên gia gần nhất đang được thông báo"

6. **Action Button:**
   - Secondary button: "Hủy yêu cầu" (outlined, gray)
   - Small text below: "Bạn có thể tiếp tục xử lý nếu chắc chắn"

#### Stitch Prompt (English):

```
Mobile app waiting screen for expert response matching. Loading state with progress feedback, orange-red (#FF6B35) theme.

Top section center: Title "Đang tìm chuyên gia..." dark gray bold (24pt). Below, subtitle "Vui lòng chờ trong giây lát" gray (16pt).

Center large circular spinner orange-red (#FF6B35), rotating animation smooth (80px diameter, 4px stroke). Below spinner, 3 dots pulsing animation orange-red (8px each, spacing 8px). Below dots, gray text "Đang kết nối với chuyên gia online" (16pt).

Below loading section margin-top 32px: Card white background, rounded 12px, shadow light, padding 16px. Title "Yêu cầu hỗ trợ của bạn" dark gray semi-bold (16pt). Horizontal layout: Left small snake photo thumbnail (60px square, rounded 8px), right vertical: Gray text "3 ảnh đã gửi" (14pt), small location pin icon + gray text location, small gray text "Vừa gửi" italic.

Below card margin-top 24px: Progress steps vertical list, 3 items. Each item horizontal: Left circle icon (32px), inside checkmark or clock icon. Right text (16pt). Item 1: Green checkmark, dark gray text "Đã gửi yêu cầu khẩn cấp". Item 2: Orange clock, orange bold text "Đang tìm chuyên gia phù hợp...". Item 3: Gray pause icon, gray text "Chờ chuyên gia chấp nhận". Connector line between circles gray.

Below progress margin-top 24px: Info banner light blue background (#E3F2FD), rounded 8px, padding 12px. Left blue info icon (20px), right vertical: Bold blue text "Thời gian phản hồi trung bình: 30 giây" (14pt), small gray text "Top 3 chuyên gia gần nhất đang được thông báo" (12pt).

Bottom section margin-top 32px: Secondary button "Hủy yêu cầu" full width, gray outlined border, gray text (16pt), height 48px, rounded 8px. Below button center, small gray text "Bạn có thể tiếp tục xử lý nếu chắc chắn" (12pt).

Overall padding 16px, clean loading state, clear progress feedback, reassuring information.
```

---

### Screen 4: Active Consultation Session (Chat/Video Call)

#### Thông tin màn hình:
- **Tên:** Màn hình phiên tư vấn đang hoạt động
- **Mục đích:** Interface cho phiên tư vấn real-time giữa Rescuer và Expert
- **Flow position:** Giai đoạn 3.2 - Rescuer và Expert đang trao đổi
- **Priority:** ⭐⭐⭐ (Cao nhất - Active consultation)

#### Key Components:
1. **Header:**
   - Expert info bar (green online indicator)
   - Expert avatar, name: "TS. Nguyễn Văn A"
   - Badge: "Chuyên gia rắn độc Việt Nam"
   - Rating: 4.9 ⭐ (small)
   - Connection status: "Đang kết nối..." → "Đã kết nối ✓"

2. **Chat/Video Mode Toggle:**
   - Segmented control: "Chat" | "Video Call"
   - Switch between modes

3. **Chat Mode View:**
   - Chat messages container (scrollable)
   - Expert messages: Left aligned, purple background bubble
   - Rescuer messages: Right aligned, orange background bubble
   - Timestamp below each message (small gray)
   - System messages: Center aligned, gray background
     * "Chuyên gia đã tham gia phiên tư vấn"
     * "Ảnh đã được chia sẻ"

4. **Video Call Mode View (Alternative):**
   - Large video feed of Expert (main screen)
   - Small self-view video (bottom-right corner, draggable)
   - Floating controls (bottom):
     * Mute button
     * Camera toggle
     * End call button (red)
     * Screenshot button (capture snake image during call)

5. **Shared Image Gallery (Bottom of Chat):**
   - Horizontal scrollable thumbnails
   - 3 snake photos Rescuer sent
   - Tap to view full screen

6. **Chat Input Area (Chat Mode):**
   - Text input field: "Nhập tin nhắn..."
   - Attach image button (camera icon)
   - Send button (orange-red)

7. **Quick Action Buttons (Above Input):**
   - Horizontal scrollable chips:
     * "Đã bắt thành công ✓"
     * "Cần tư vấn thêm"
     * "Gửi ảnh bổ sung"
     * "Cảm ơn Expert 🙏"

8. **Expert Guidance Panel (Expandable):**
   - Collapsible section showing Expert's recommendations:
     * Snake species: "Rắn Hổ Mang Chúa"
     * Venom level: "Rất độc" (RED badge)
     * Safety equipment: "Cần kẹp dài 1.5m, găng chống cắn"
     * Technique: "Bắt từ đuôi, kiểm soát đầu"
     * Warnings: "Cực kỳ hung dữ, di chuyển nhanh"

9. **Session Timer:**
   - Small badge top-right: "05:32" (minutes:seconds)
   - Color changes: Green < 5min, Amber 5-10min, Red > 10min

10. **End Consultation Button:**
    - Bottom fixed button: "Kết thúc tư vấn" (outlined, gray)
    - Confirmation dialog on tap

#### Stitch Prompt (English):

```
Mobile app active expert consultation screen. Real-time chat and video call interface for snake identification support, orange-red (#FF6B35) theme.

Top header purple gradient background (#6A1B9A to #4A148C), padding 16px: Horizontal layout, left circular expert avatar (48px), small green online dot top-right avatar. Right of avatar vertical: Expert name "TS. Nguyễn Văn A" white bold (18pt), small white badge "Chuyên gia rắn độc Việt Nam" rounded below name, small white text "4.9 ⭐" (14pt). Far right green checkmark icon "Đã kết nối" white text (12pt).

Below header: Segmented control 2 options "Chat" and "Video Call", white background, selected segment purple background white text, unselected transparent dark text.

CHAT MODE VIEW:
Chat container white background, flex-grow scroll: Messages list vertical. Expert messages left-aligned: Purple bubble (#E1BEE7) rounded-right-16px rounded-left-4px, padding 12px, dark gray text (16pt), small gray timestamp "15:32" below left. Rescuer messages right-aligned: Orange bubble (#FFCCBC) rounded-left-16px rounded-right-4px, padding 12px, dark gray text (16pt), timestamp below right. System messages center: Light gray bubble (#EEEEEE) rounded-full, small gray text (14pt). Spacing 12px between messages.

Shared image gallery horizontal scroll below messages: Small rounded thumbnails (80px square, 8px rounded, 8px spacing), border gray light. Badge "3 ảnh" orange background white text top-right.

Above chat input: Horizontal scroll chips, spacing 8px. Each chip light purple background (#F3E5F5) purple text (14pt), rounded-full padding 8px 16px: "Đã bắt thành công ✓", "Cần tư vấn thêm", "Gửi ảnh bổ sung", "Cảm ơn Expert 🙏".

Chat input area fixed bottom, white background, shadow top, padding 12px: Horizontal layout, left gray outlined text field "Nhập tin nhắn..." flex-grow height 44px rounded 22px. Right camera icon button gray (40px). Right send button orange-red circle (44px) white paper-plane icon.

Expert guidance collapsible panel margin-top 16px: Header purple background rounded-top 8px padding 12px, white text "Hướng dẫn từ chuyên gia" semi-bold (16pt), right chevron down icon white. Expanded content white background border purple rounded-bottom 8px padding 12px: Rows vertical spacing 8px. Row 1: Label gray "Loài rắn:" bold, value "Rắn Hổ Mang Chúa" dark. Row 2: Label, red badge "Rất độc". Row 3: Label, text equipment. Row 4: Label, text technique. Row 5: Label, red text warnings.

Top-right corner: Small badge white background border purple "05:32" purple text (14pt) rounded.

Bottom fixed button "Kết thúc tư vấn" full width gray outlined height 48px rounded 8px gray text (16pt).

VIDEO CALL MODE VIEW (Alternative):
Full screen video feed expert (background). Bottom-right corner small self-view video (120px x 160px) rounded 8px, draggable.

Bottom floating controls semi-transparent black background rounded-full padding 16px, horizontal layout center: Circular buttons spacing 16px (56px each). Mute button white icon microphone, Camera toggle white icon camera, End call button red background white phone-hang-up icon, Screenshot button white icon camera-plus.

Expert guidance panel overlay bottom-left, semi-transparent white background rounded 12px, same content format smaller text.

Session timer overlay top-right as described.

Overall clean consultation interface, clear expert guidance, easy communication, professional layout.
```

---

### Screen 5: Consultation Completed Summary

#### Thông tin màn hình:
- **Tên:** Màn hình tóm tắt kết quả tư vấn
- **Mục đích:** Hiển thị tóm tắt thông tin Expert cung cấp sau khi kết thúc phiên tư vấn
- **Flow position:** Giai đoạn 3.2 - Sau khi Expert hoàn thành tư vấn
- **Priority:** ⭐⭐⭐ (Cao - Critical reference for rescue)

#### Key Components:
1. **Header:**
   - Success icon (green checkmark in circle)
   - Title: "Tư vấn hoàn tất"
   - Subtitle: "Bạn đã nhận được hướng dẫn từ chuyên gia"

2. **Expert Info Card:**
   - Expert avatar, name, rating
   - Badge: "Đã tư vấn"
   - Session duration: "Thời gian: 6 phút 15 giây"
   - Text: "Cảm ơn TS. Nguyễn Văn A đã hỗ trợ"

3. **Snake Identification Result:**
   - Section title: "Kết quả nhận diện chính thức"
   - Large card with:
     * Snake photo (selected best photo from consultation)
     * Snake name: "Rắn Hổ Mang Chúa" (bold, large)
     * Scientific name: "(Ophiophagus hannah)" (italic, smaller)
     * Venom badge: "RẤT ĐỘC" (red background, white text, bold)
     * Danger level: 5 stars (red) "Nguy hiểm cực cao"
     * Verified badge: "✓ Đã xác minh bởi chuyên gia"

4. **Safety Guidelines Summary:**
   - Section title: "Hướng dẫn an toàn"
   - Numbered list (large icons):
     1. "Thiết bị cần thiết"
        - Kẹp bắt rắn dài 1.5m
        - Găng tay chống cắn
        - Bao vải dày
        - Hộp đựng an toàn
     2. "Kỹ thuật bắt"
        - Bắt từ đuôi trước
        - Kiểm soát đầu cẩn thận
        - Di chuyển chậm, không giật
     3. "Cảnh báo đặc biệt"
        - Cực kỳ hung dữ
        - Có thể tấn công nhanh
        - Độc tính rất cao
        - Gọi hỗ trợ nếu cần

5. **Expert Notes (Optional):**
   - Expandable section
   - Title: "Ghi chú bổ sung từ chuyên gia"
   - Text area with Expert's additional comments
   - Example: "Rắn này có thể dài 4-5m, cần thêm người hỗ trợ. Chuẩn bị sẵn huyết thanh kháng nọc tại hiện trường."

6. **Action Buttons:**
   - Primary button: "BẮT ĐẦU BẮT RẮN" (large, orange-red, bold)
   - Secondary button: "Lưu hướng dẫn" (outlined, gray)
   - Tertiary button: "Gửi tin nhắn cảm ơn Expert" (text button, purple)

7. **Emergency Contact:**
   - Small card at bottom:
     * Red warning icon
     * Text: "Nếu gặp nguy hiểm trong quá trình bắt"
     * Button: "GỌI HỖ TRỢ KHẨN CẤP" (red, outlined)

8. **Reference Badge:**
   - Top-right corner badge: "Tham khảo #12345"
   - For record keeping

#### Stitch Prompt (English):

```
Mobile app consultation completed summary screen. Expert guidance results and safety instructions for snake rescue, orange-red (#FF6B35) theme.

Top section center: Large green checkmark icon circle (80px) with subtle animation. Below, title "Tư vấn hoàn tất" dark gray bold (24pt). Below, subtitle "Bạn đã nhận được hướng dẫn từ chuyên gia" gray (16pt).

Expert info card margin-top 24px, light purple background (#F3E5F5), rounded 12px, padding 16px: Horizontal layout, left expert avatar circular (56px) border purple, small green badge "Đã tư vấn" top-right avatar. Right vertical: Expert name "TS. Nguyễn Văn A" dark bold (18pt), rating "4.9 ⭐" small (14pt), small gray text "Thời gian: 6 phút 15 giây" clock icon. Below, gray text "Cảm ơn TS. Nguyễn Văn A đã hỗ trợ" italic (14pt).

Section title margin-top 32px "Kết quả nhận diện chính thức" dark gray semi-bold (20pt). Snake identification card white background, shadow medium, rounded 12px, padding 16px: Top snake photo full width height 200px rounded-top 12px. Below photo padding 16px: Snake name "Rắn Hổ Mang Chúa" dark gray bold (22pt). Below, scientific name "(Ophiophagus hannah)" gray italic (16pt). Below, red badge "RẤT ĐỘC" rounded padding 4px 12px white bold text (14pt). Below, danger level 5 red stars icons (20px each) horizontal, text "Nguy hiểm cực cao" red (16pt). Bottom, green badge "✓ Đã xác minh bởi chuyên gia" rounded.

Section title margin-top 32px "Hướng dẫn an toàn" dark gray semi-bold (20pt). White background card rounded 12px padding 16px: Vertical list 3 numbered items, spacing 20px. Each item: Large number circle orange-red background white text (32px) left, right vertical: Bold dark title (18pt), bullet points gray text (16pt) spacing 8px.

Expandable section margin-top 24px: Header "Ghi chú bổ sung từ chuyên gia" dark semi-bold (18pt), chevron icon right. Expanded: Light gray background (#F5F5F5) rounded 8px padding 12px, gray text (16pt) "Rắn này có thể dài 4-5m, cần thêm người hỗ trợ..." italic.

Action buttons section margin-top 32px: Primary button "BẮT ĐẦU BẮT RẮN" full width orange-red (#FF6B35) background white bold text (18pt) height 56px rounded 8px. Below spacing 12px, secondary button "Lưu hướng dẫn" full width gray outlined gray text (16pt) height 48px rounded 8px. Below spacing 8px, text button "Gửi tin nhắn cảm ơn Expert" purple text (16pt) center.

Emergency contact card margin-top 24px, light red background (#FFEBEE), border red dashed 2px, rounded 8px, padding 16px: Red warning icon left (32px), right vertical: Gray text "Nếu gặp nguy hiểm trong quá trình bắt" (14pt), below button "GỌI HỖ TRỢ KHẨN CẤP" red outlined red text (16pt) height 44px rounded 8px.

Top-right corner: Small badge white background shadow "Tham khảo #12345" gray text (12pt) rounded.

Overall padding 16px, comprehensive summary layout, actionable safety guidance, clear next steps.
```

---

## 📊 Navigation Flow

```
Screen Flow Diagram:

1. Request Expert Help
   ↓ (Tap "Yêu cầu hỗ trợ chuyên gia")
   ↓
2. Capture Snake Photo/Video
   ↓ (Capture photos/video → Tap "Gửi cho Expert")
   ↓
3. Waiting for Expert Response
   ↓ (Expert accepts → Connection established)
   ↓
4. Active Consultation Session
   ↓ (Chat or Video Call with Expert)
   ↓ (Expert provides guidance → Tap "Kết thúc tư vấn")
   ↓
5. Consultation Completed Summary
   ↓ (Review guidance → Tap "Bắt đầu bắt rắn")
   ↓
[Return to Rescue Mission Screen]

Alternative paths:
- Screen 3: Tap "Hủy yêu cầu" → Return to mission
- Screen 4: Expert disconnects → Show error → Retry
- Screen 5: Tap "Gọi hỗ trợ khẩn cấp" → Emergency call
```

---

## 🔗 Feature Mapping (từ Major-Features-Summary.md)

### Rescuer Features trong Expert Consultation Flow:

| Screen | Features Implemented | Major Features Code |
|--------|----------------------|---------------------|
| **Screen 1: Request Expert Help** | Yêu cầu hỗ trợ từ xa khi gặp loài rắn khó xác định | FE-12, FE-13 |
| **Screen 2: Capture Snake Photo/Video** | Chia sẻ ảnh/video real-time với chuyên gia | FE-14 |
| **Screen 3: Waiting for Expert Response** | Matching system connecting with online Expert | Backend FE-12 |
| **Screen 4: Active Consultation Session** | Trao đổi thông tin với chuyên gia, tư vấn qua chat/video call | FE-11, FE-12, FE-13 |
| **Screen 5: Consultation Completed Summary** | Nhận hướng dẫn an toàn bắt rắn, xác nhận loài rắn chính xác | FE-09, FE-10, FE-21 |

---

## 📝 Implementation Notes

### Technical Requirements:

1. **Real-time Communication:**
   - WebRTC for video call functionality
   - WebSocket for real-time chat messaging
   - SignalR/.NET Core for backend real-time hub
   - Low latency < 200ms for smooth video call

2. **Camera & Media:**
   - Camera API access for photo/video capture
   - Media upload with compression (max 5MB per image)
   - Video recording max 30 seconds per clip
   - Multiple image selection (max 10 images)

3. **Push Notifications:**
   - Expert accepted notification
   - Expert typing indicator
   - Consultation ended notification

4. **Offline Handling:**
   - Save consultation summary locally
   - Queue messages if connection lost
   - Resume consultation when reconnected

5. **Security:**
   - Encrypted video/chat communication (TLS 1.3)
   - Automatic session timeout after 30 minutes
   - Media auto-delete after 30 days
   - Expert identity verification

### Business Logic:

1. **Expert Matching Algorithm:**
   - Priority 1: Experts specialized in geographic region
   - Priority 2: Experts with experience with similar snake species
   - Priority 3: Highest-rated available experts
   - Send to top 3 experts, first to accept wins
   - Timeout: 60 seconds, then expand search radius

2. **Consultation Pricing:**
   - **Free for Rescuer** during active rescue missions
   - Platform pays Expert consultation fee (flat rate)
   - Alternative: Rescuer shares 10% of rescue fee with Expert
   - Payment processed automatically after consultation

3. **Session Management:**
   - Max consultation duration: 30 minutes
   - Warning at 25 minutes
   - Auto-save guidance summary
   - Allow follow-up messages for 24 hours

4. **Quality Control:**
   - Rescuer can rate Expert after consultation (1-5 stars)
   - Expert can add notes to Rescuer's profile (internal)
   - Admin monitors consultation quality
   - Flag inappropriate behavior

### Edge Cases:

1. **No Expert Available:**
   - Show message: "Không có chuyên gia online"
   - Suggest: "Thử lại sau 5 phút" or "Tiếp tục với AI"
   - Emergency fallback: Call platform support hotline

2. **Expert Disconnects Mid-Session:**
   - Auto-reconnect attempt (3 tries)
   - If fails: "Kết nối bị gián đoạn"
   - Options: "Chờ Expert kết nối lại" or "Tìm Expert khác"

3. **Poor Image Quality:**
   - Expert requests better photos
   - Show tips: "Cần ánh sáng tốt hơn" or "Đến gần hơn"
   - Allow retake without ending session

4. **Rescuer Completes Capture Before Expert Responds:**
   - Consultation ends automatically
   - Rescuer receives refund/credit
   - Expert still receives base fee for standby time

---

## ✅ Screen Checklist

- [x] **Screen 1:** Request Expert Help - Entry point with AI uncertainty display ✅
- [x] **Screen 2:** Capture Snake Photo/Video - Camera interface with tips ✅
- [x] **Screen 3:** Waiting for Expert Response - Loading with progress feedback ✅
- [x] **Screen 4:** Active Consultation Session - Chat and video call interface ✅
- [x] **Screen 5:** Consultation Completed Summary - Guidance and safety instructions ✅

**Total Screens:** 5 screens covering complete Expert Consultation flow for Rescuer

---

## 📚 Related Documents

- **Main Flow:** `/01-Requirements/Main-Flow/Main-Flow.md` - Section 3.2
- **Swimlane Diagram:** `/01-Requirements/Swimlane-Diagram/03-Swimlane-Expert-Consultation-Flow.md` - Giai đoạn 3.2
- **Major Features:** `/01-Requirements/Major-Features/Major-Features-Summary.md` - Rescuer Expert Consultation Features
- **Emergency Response Flow:** `/02-UI-Design/Rescuer/Rescuer-Emergency-Response-Flow-Screens.md` - Context for active rescue
- **Rescue Request Flow:** `/02-UI-Design/Rescuer/Rescuer-Rescue-Request-Flow-Screens.md` - Context for rescue missions

---

## 🎨 Design Resources

### Stitch with Google:
- All prompts in English for Stitch compatibility
- Vietnamese text embedded in quotes within prompts
- Color codes in HEX format
- Explicit sizing (px, pt) for all elements

### Figma Export (Future):
- Export screens from Stitch → Import to Figma
- Create interactive prototype
- Share with development team
- Generate design specs and assets

---

## 📅 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Dec 8, 2025 | Initial creation - 5 screens for Rescuer Expert Consultation Flow | AI Assistant |

---

**🎯 Document Status:** ✅ Complete - Ready for UI Implementation

**📍 Next Steps:**
1. Generate UI designs using Stitch with provided prompts
2. Review and refine designs with stakeholders
3. Create interactive prototype in Figma
4. Handoff to development team with technical specifications
5. Implement backend real-time communication infrastructure
6. Integrate WebRTC for video call functionality

---

*Tài liệu này được tạo để hỗ trợ thiết kế giao diện cho module Rescuer trong flow tư vấn chuyên gia của hệ thống SnakeAid.*
