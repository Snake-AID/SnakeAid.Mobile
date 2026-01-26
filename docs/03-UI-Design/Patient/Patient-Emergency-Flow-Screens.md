# EMERGENCY FLOW - UI DESIGN SCREENS

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Patient Mobile Application
- **Flow:** Emergency Flow (Xử lý sự cố rắn cắn khẩn cấp)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 20 screens (9 main + 5 expert SOS + 4 alternative flow + 2 payment screens)
- **Ngày tạo:** November 30, 2025
- **Cập nhật:** December 18, 2025 (Added Expert SOS Consultation screens 7.5-7.9)
- **Location:** `/02-UI-Design/Patient-Emergency-Flow-Screens.md`

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Forest Green `#228B22`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Emergency:** Red `#DC3545`
- **Accent - Warning:** Amber `#FFC107`
- **Accent - Success:** Green `#28A745`
- **Accent - Info:** Blue `#007BFF`

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
- **Minimal icons:** Only essential ones (star rating, arrow navigation)

---

## 📱 SCREEN DESIGNS & PROMPTS

---

### Screen 1: Homepage (Patient App)

#### Thông tin màn hình:
- **Tên:** Màn hình chủ - Patient Dashboard
- **Mục đích:** Entry point của ứng dụng, cung cấp truy cập nhanh đến tính năng khẩn cấp và các chức năng chính
- **Flow position:** Điểm bắt đầu của Emergency Flow
- **Priority:** ⭐⭐⭐ (Cao nhất - cần chi tiết nhất)

#### Key Components:
1. **Header Section:**
   - Logo text "SnakeAid" (bold, forest green, centered)
   - User avatar icon (top-right corner, small circle)
   - Notification bell icon (top-right, minimal)

2. **Hero Emergency Card:**
   - Large card with red accent background (light red #FFEBEE)
   - Icon: Emergency symbol (or text "⚠️")
   - Main text: "Khẩn cấp - Tôi bị rắn cắn!"
   - Subtitle: "Nhận hướng dẫn sơ cứu ngay lập tức"
   - Right arrow indicator
   - Prominent position (top of content area)

3. **Quick Access Section:**
   - Title: "Truy cập nhanh"
   - 3 equal-width cards in a row:
     - Card 1: "Tìm bệnh viện" (with location pin icon or text)
     - Card 2: "Thông tin rắn" (with book/info icon or text)
     - Card 3: "Báo cáo rắn" (with camera icon or text)
   - Cards have forest green border

4. **Information Section:**
   - Title: "Phòng ngừa & Giáo dục"
   - Horizontal scrollable cards:
     - "Hướng dẫn sơ cứu"
     - "Rắn phổ biến"
     - "Mẹo an toàn"
   - Each card has thumbnail image placeholder + title

5. **Bottom Navigation Bar:**
   - 4 tabs with text labels:
     - "Trang chủ" (active - forest green)
     - "Cứu hộ"
     - "Chuyên gia"
     - "Cá nhân"
   - Active tab highlighted with forest green color

#### Stitch Prompt (English):

```
Mobile app home screen for emergency snakebite assistance app named "SnakeAid". Modern clean medical app design with forest green (#228B22) as primary brand color on white background.

Top header: Centered bold text logo "SnakeAid" in forest green. Small circular user avatar icon in top-right corner. Notification bell icon next to avatar.

Main content area begins with large prominent emergency card with light red background (#FFEBEE) and red accent border. Card contains warning symbol emoji, large bold text "Khẩn cấp - Tôi bị rắn cắn!", subtitle "Nhận hướng dẫn sơ cứu ngay lập tức", and right arrow. This card takes up full width with significant padding.

Below emergency card, section title "Truy cập nhanh" in dark gray. Three equal-width cards in horizontal row with forest green borders: "Tìm bệnh viện" with location pin, "Thông tin rắn" with info icon, "Báo cáo rắn" with camera icon. Cards have white background.

Next section titled "Phòng ngừa & Giáo dục" shows horizontally scrollable row of 3 cards. Each card has light gray rectangular placeholder for thumbnail image on top, and text label below: "Hướng dẫn sơ cứu", "Rắn phổ biến", "Mẹo an toàn".

Bottom of screen has fixed navigation bar with 4 evenly spaced text tabs: "Trang chủ" (active, forest green color), "Cứu hộ", "Chuyên gia", "Cá nhân" in gray. Clean separator line above nav bar.

Overall style: Clean, minimal, professional medical/emergency app, iOS and Android compatible, focus on typography and card-based layouts, subtle shadows, no complex illustrations.
```

#### Notes for Stitch:
- Nếu icons render không đẹp → Re-prompt: "Replace all icons with simple text labels only, no pictogram icons"
- Nếu màu emergency card quá sáng → "Use deeper red tint for emergency card background #FFCDD2"
- Nếu layout bị lệch → "Ensure all cards have equal padding and are vertically aligned"

---

### Screen 2: Emergency Alert Screen with Rescuer Finder

#### Thông tin màn hình:
- **Tên:** Màn hình cảnh báo khẩn cấp với tìm kiếm đội cứu hộ
- **Mục đích:** Xác nhận tình huống khẩn cấp, hiển thị map tìm Rescuer gần nhất real-time, và đưa ra hướng dẫn an toàn
- **Flow position:** Ngay sau khi user tap "Emergency - I'm Bitten" từ homepage
- **Priority:** ⭐⭐⭐
- **Design inspiration:** Grab-style modern map interface với radar scanning effect

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Cảnh báo khẩn cấp" (centered)
   - Close button (top-right, X icon)

2. **Alert Status Banner:**
   - Red background with white text
   - Large text: "Đang tìm đội cứu hộ gần bạn..."
   - Icon: Pulsing heartbeat animation
   - Status: "GPS đã kích hoạt"

3. **Interactive Map Section (占 40% screen height):**
   - Full-width map view (similar to Grab)
   - User's location: Blue pulsing dot in center
   - Radar scanning animation: Rotating green arc emanating from user location
   - Rescuer markers: Orange pins with rescuer icons appearing as they're found
   - Distance circles: 1km, 3km, 5km radius indicators (faint green lines)
   - Map controls:
     - Re-center button (bottom-right of map)
     - Current location indicator showing address
   - Overlay status card on map:
     - "Đang quét: 3 đội cứu hộ gần bạn"
     - "Khoảng cách gần nhất: 2.1 km"

4. **Bottom Sheet Panel (Slide-up drawer):**
   
   **Collapsed State (Shows top section):**
   - Drag handle bar at top
   - Quick stats: "3 đội cứu hộ | Gần nhất: 2.1km | ETA: 8 phút"
   - Swipe up indicator: "Vuốt lên để xem hướng dẫn sơ cứu"
   
   **Expanded State (Full panel):**
   
   a) **Critical Warning Section:**
      - Yellow warning box with amber background
      - Bold text: "⚠️ TUYỆT ĐỐI KHÔNG:"
      - Horizontal scrollable chips (save space):
        - "Cắt vết thương"
        - "Hút nọc độc"
        - "Đắp băng garo"
        - "Uống rượu"
   
   b) **Immediate Action Card:**
      - Green background card (compact)
      - Title: "✓ LÀM NGAY (Trong lúc chờ):"
      - 3 numbered items with icons:
        - "1️Giữ bình tĩnh và đứng yên"
        - "2️Cởi đồ/trang sức chật"
        - "3️Giữ vết cắn thấp hơn tim"
   
   c) **Rescuer Status (Dynamic):**
      - **Đang quét:** "Đang tìm đội cứu hộ gần bạn..."
        - Animated radar scanning
        - "Đã tìm thấy 3 đội cứu hộ trong phạm vi 5km"
      
      - **Đã gửi yêu cầu:** "Đã gửi yêu cầu khẩn cấp đến đội cứu hộ gần nhất"
        - Rescuer preview card (read-only):
          - Avatar + Name + Rating
          - "2.1 km - ETA 8 phút"
          - Status badge: "Đang chờ phản hồi..." (amber pulsing)
        - Text: "Đội cứu hộ có 60 giây để phản hồi"
        - Timer: "00:45"
      
      - **Đã chấp nhận:** "✅ Đội cứu hộ đã chấp nhận!"
        - Rescuer card with details
        - Status: "Đang trên đường đến"
        - Button: "Liên hệ đội cứu hộ"

5. **Action Buttons (Sticky bottom):**
   - **State 1 (Scanning):**
     - Primary button (large, red): "Gửi Yêu Cầu SOS →"
     - Secondary button (outlined, green): "Bắt đầu sơ cứu ngay"
   
   - **State 2 (Waiting for response):**
     - Primary button (large, red, disabled): "Đang chờ phản hồi..."
     - Secondary button (outlined, green): "Xem hướng dẫn sơ cứu"
     - Tertiary text link: "Hủy yêu cầu"
   
   - **State 3 (Accepted):**
     - Primary button (large, green): "Liên hệ đội cứu hộ"
     - Secondary button (outlined): "Xem vị trí đội cứu hộ"
     - Tertiary text link: "Gọi 115 trực tiếp"

#### Stitch Prompt (English):

```
Modern mobile app emergency screen with interactive map and rescuer finder. Grab-style interface with forest green (#228B22) and red (#DC3545) emergency theme.

Top navigation bar: Back arrow left, centered title "Cảnh báo khẩn cấp", X close button right. White background.

Full-width red status banner (#DC3545) below nav with white text "Đang tìm đội cứu hộ gần bạn..." and small pulsing heartbeat icon. Subtext "GPS đã kích hoạt" with green checkmark.

Large interactive map section (40% screen height): Light style map similar to Grab interface. Center shows blue pulsing dot (user location) with animated rotating green radar arc sweeping outward. Faint green concentric circles at 1km, 3km, 5km radius. Three orange pins with rescuer icons scattered on map at various distances. Small white floating card overlay on map bottom shows "Đang quét: 3 đội cứu hộ gần bạn | Khoảng cách: 2.1 km". Small circular re-center button bottom-right of map.

Below map, slide-up bottom sheet panel with rounded top corners and drag handle bar at top (gray horizontal line).

**Collapsed state** shows quick stats bar: "3 đội cứu hộ | Gần nhất: 2.1km | ETA: 8 phút" with small up arrow and text "Vuốt lên để xem hướng dẫn".

**Expanded state** shows full panel content:

Yellow-amber warning box (#FFF3CD) with bold text "⚠️ TUYỆT ĐỐI KHÔNG:" followed by horizontal scrollable row of 4 compact chips with red X icons: "Cắt vết thương", "Hút nọc độc", "Đắp băng garo", "Uống rượu".

Green success card (#D4EDDA) titled "✓ LÀM NGAY (Trong lúc chờ):" with 3 numbered compact items:
Giữ bình tĩnh và đứng yên
Cởi đồ/trang sức chật  
Giữ vết cắn thấp hơn tim

**Rescuer Status Section (showing "waiting for response" state):**
Gray text "Đã gửi yêu cầu khẩn cấp đến đội cứu hộ gần nhất"

White card with subtle shadow showing rescuer preview:
- Left: Small circular avatar placeholder
- Center: "Nguyễn Văn A" bold text, "4.9 ⭐ (156 đánh giá)" below
- Right: "2.1 km" bold orange text, "ETA 8 phút" gray text below
- Amber pulsing badge "Đang chờ phản hồi..." below avatar
- Small gray text "Đội cứu hộ có 60 giây để phản hồi"
- Timer display "00:45" in amber color

Sticky bottom section with white background and top shadow:
- Large disabled gray button "Đang chờ phản hồi..." (60px height)
- Medium outlined green button "Xem hướng dẫn sơ cứu" (50px height)
- Small gray text link "Hủy yêu cầu" centered

Design: Modern ride-hailing app style (Grab/Uber pattern), live map interface with radar animation, clear status updates, bottom sheet UX pattern, emergency medical context, professional and calming despite urgency.
```

#### Alternative States for Stitch:

**State 1 - Scanning (Before sending request):**
```
Map shows radar animation actively scanning. No rescuer card yet. Bottom shows animated text "Đang quét khu vực..." Primary red button "Gửi Yêu Cầu SOS →" enabled. Secondary green outlined button "Bắt đầu sơ cứu ngay".
```

**State 3 - Accepted (Rescuer confirmed):**
```
Rescuer card shows green checkmark badge "✅ Đã chấp nhận!". Status text "Đang trên đường đến". Map shows route line from rescuer pin to user location. Primary green button "Liên hệ đội cứu hộ" enabled. Secondary outlined "Xem vị trí đội cứu hộ". Tertiary link "Gọi 115 trực tiếp".
```

#### Notes for Stitch:
- Nếu text quá nhỏ → "Increase font size for DO NOT section to 18pt minimum"
- Nếu buttons không rõ hierarchy → "Make primary button 60px height, secondary 50px height"
- Alert banner phải nổi bật nhất trong screen

---

### Screen 3: Species-Specific First Aid Guide Screen

#### Thông tin màn hình:
- **Tên:** Màn hình hướng dẫn sơ cứu CHUYÊN BIỆT theo loài rắn
- **Mục đích:** Cung cấp hướng dẫn sơ cứu CHI TIẾT cho LOÀI RẮN CỤ THỂ đã được AI xác định
- **Flow position:** SAU Screen 5 (AI Snake Identification) - Khi đã biết chính xác loài rắn và loại nọc độc
- **Priority:** ⭐⭐⭐ (Critical - Sơ cứu sai có thể gây tử vong)
- **Điểm khác biệt:** Hướng dẫn THAY ĐỔI dựa trên loài rắn (Neurotoxic vs Hemotoxic vs Non-venomous)

#### Key Components:
1. **Header:**
   - Back button
   - Progress indicator: "Bước 1 / 4" (text-based)
   - Timer: "02:15" (elapsed time)

2. **Snake Species Info Banner (NEW - From Screen 5):**
   - Small card at top showing identified snake
   - Snake name: "Rắn hổ mang chúa (King Cobra)"
   - Venom type badge: "Neurotoxic Venom" (red badge)
   - Small thumbnail of snake photo
   - Text: "Hướng dẫn sơ cứu chuyên biệt cho loài này"

3. **Step Indicator:**
   - Horizontal stepper: ●—○—○—○
   - Current step highlighted in forest green
   - Completed steps in green, upcoming in gray

4. **Instruction Card (Species-Specific):**
   - Large card with white background
   - Step number badge (top-left): "BƯỚC 1"
   - Main heading: "Băng ép vết cắn" (for Neurotoxic)
     - OR "Làm sạch vết thương" (for Hemotoxic)
     - OR "Theo dõi vết cắn" (for Non-venomous)
   - Illustration placeholder: Rectangle area for image/diagram
   - Detailed text instructions (THAY ĐỔI theo loài rắn):
     
     **Ví dụ cho Rắn hổ mang chúa (Neurotoxic):**
     - "Băng ép NGAY LẬP TỨC từ vị trí vết cắn"
     - "Băng chặt vừa phải - ngăn độc lan qua lymph"
     - "Băng TOÀN BỘ chi bị cắn lên đến gốc"
     - "KHÔNG cắt vết thương, KHÔNG hút nọc độc"
     - "Giữ vùng cắn THẤP HƠN tim"
     
     **Ví dụ cho Rắn lục đuôi đỏ (Hemotoxic):**
     - "Làm sạch vết thương bằng nước sạch"
     - "Băng lỏng, KHÔNG băng chặt (gây hoại tử)"
     - "Nâng cao vùng bị cắn"
     - "Quan sát sưng tấy và đổi màu da"

4. **Visual Aid Section:**
   - Image placeholder with caption: "Kỹ thuật băng ép đúng cách"
   - Border in forest green

5. **Navigation Buttons:**
   - Primary button (bottom): "Bước tiếp theo →" (forest green)
   - Secondary button: "⚠️ Tôi cần cấp cứu ngay" (red, outlined)
   - Skip option: "Bỏ qua đến tìm bệnh viện" (text link)

6. **Quick Access Bar (sticky footer above buttons):**
   - 3 small icon buttons:
     - "SOS"
     - "Bệnh viện"
     - "Chụp rắn"

#### Stitch Prompt (English):

```
Mobile app species-specific first aid instruction screen for identified snake. Educational interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered text "Bước 1 / 4", right side shows timer "02:15" in gray.

Below nav, small info card showing identified snake: Left side has small square snake photo thumbnail (from Screen 5). Right side shows "Rắn hổ mang chúa (King Cobra)" bold text, with red badge "Neurotoxic Venom" below. Small gray text "Hướng dẫn sơ cứu chuyên biệt cho loài này".

Below info card, horizontal progress stepper with 4 circles connected by lines. First circle filled green (active), others outlined gray. Circles contain step numbers 1-2-3-4.

Main content area: White card with subtle shadow containing step badge "BƯỚC 1" in forest green at top-left. Large heading "Băng ép vết cắn (Neurotoxic Snake)" in dark gray below badge.

Card contains rectangular placeholder area (16:9 ratio) with light gray background and centered text "Khu vực minh họa" for diagram image. Below illustration, 4 bullet points with clear instructions:
• "Bắt đầu băng từ vị trí vết cắn"
• "Băng chặt vừa phải, không quá chặt"  
• "Băng toàn bộ chi bị cắn"
• "Kiểm tra tuần hoàn - ngón chân/tay vẫn hồng"

Below main card, smaller image placeholder with forest green border and caption "Kỹ thuật băng ép đúng cách" underneath.

Above bottom buttons, sticky bar with 3 small equal-width outlined buttons labeled "SOS", "Bệnh viện", "Chụp rắn" with forest green borders.

Bottom has 2 full-width buttons stacked:
- Primary solid green button "Bước tiếp theo →"
- Secondary red outlined button "⚠️ Tôi cần cấp cứu ngay"
Small gray text link below "Bỏ qua đến tìm bệnh viện"

Style: Educational, calm, step-by-step tutorial interface, clear typography, adequate spacing, easy to read while stressed.
```

#### Notes for Stitch:
- Illustration area phải đủ lớn để user thấy rõ
- Text instructions phải có line height tốt (1.6-1.8) để dễ đọc
- Buttons phải đủ lớn cho emergency situation (min 50px height)

---

### Screen 4: Snake Photo Capture Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chụp ảnh rắn để AI nhận diện
- **Mục đích:** Cho phép user chụp/upload ảnh rắn để hệ thống AI nhận diện loài
- **Flow position:** Có thể truy cập từ First Aid Guide hoặc từ Homepage
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Nhận diện rắn"
   - Help icon (?)

2. **Camera Viewfinder Area:**
   - Large rectangle taking up most of screen
   - Dark overlay with center focus frame
   - Guide text overlay: "Đặt con rắn vào giữa khung hình"
   - Corner brackets to indicate focus area

3. **Safety Warning Banner (top of camera area):**
   - Yellow background strip
   - Text: "⚠️ Giữ khoảng cách an toàn - KHÔNG đến gần rắn"

4. **Instructions Panel (bottom overlay):**
   - Semi-transparent dark background
   - White text: "Mẹo để có kết quả tốt nhất:"
   - Bullet points:
     - "Chụp toàn thân nếu có thể"
     - "Tập trung vào đầu và hoa văn"
     - "Chụp từ khoảng cách an toàn"
     - "Sử dụng zoom nếu cần"

5. **Action Buttons (bottom):**
   - Large circular camera button (center, white)
   - Gallery icon button (left): "Tải ảnh lên"
   - Flash toggle (right): "Flash: Tắt"

6. **Skip Option:**
   - Text link: "Tôi không có ảnh rắn →"

#### Stitch Prompt (English):

```
Mobile app camera capture screen for snake identification. Camera viewfinder interface with safety warnings.

Top nav bar: Back arrow left, centered title "Nhận diện rắn", help icon (?) right. White background.

Main area shows camera viewfinder mockup: Large dark gray rectangle (#2C2C2C) representing camera view taking up 70% of vertical space. In center, white outlined frame/bracket corners indicating focus area. Inside frame, light gray text "Đặt con rắn vào giữa khung hình".

Top of camera area has yellow warning banner strip (#FFF3CD) with dark text "⚠️ Giữ khoảng cách an toàn - KHÔNG đến gần rắn" centered.

Bottom overlay on camera area: Semi-transparent dark panel (#000000 50% opacity) with white text. Title "Mẹo để có kết quả tốt nhất:" followed by 4 bullet points in smaller white text:
• "Chụp toàn thân nếu có thể"
• "Tập trung vào đầu và hoa văn"  
• "Chụp từ khoảng cách an toàn"
• "Sử dụng zoom nếu cần"

Below camera viewfinder, white bottom section with 3 buttons in horizontal row:
- Left: Small outlined button "Tải ảnh lên" with gallery icon
- Center: Large circular button (white fill, 80px diameter) for camera capture
- Right: Small outlined button "Flash: Tắt" with flash icon

At very bottom, centered gray text link "Tôi không có ảnh rắn →"

Style: Camera app interface, dark viewfinder, clear safety messaging, simple controls, iOS/Android standard camera UI patterns.
```

#### Notes for Stitch:
- Camera viewfinder area phải đủ lớn và nổi bật
- Warning banner phải prominent để user chú ý an toàn
- Nếu không render được camera effect → "Show placeholder camera area with dark background and center frame outline"

---

### Screen 4.1: Location-Based Snake Selection (Alternative Flow)

#### Thông tin màn hình:
- **Tên:** Màn hình chọn rắn dựa trên vị trí địa lý
- **Mục đích:** Khi không có ảnh, show danh sách rắn phổ biến ở khu vực để user chọn nhanh
- **Flow position:** Alternative path từ Screen 4 khi nhấn "Tôi không có ảnh rắn"
- **Priority:** ⭐⭐⭐
- **Design strategy:** Fast visual selection - 80% cases có thể identify ngay

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Rắn thường gặp ở khu vực bạn"
   - Location badge: "Quận 1, TP.HCM" (from GPS)

2. **Context Banner:**
   - Light blue background
   - Icon: Location pin
   - Text: "Dựa trên vị trí của bạn, đây là các loài rắn thường gặp nhất"
   - Subtext: "Chọn con giống với rắn bạn gặp nhất"

3. **Snake Selection Cards (4-6 cards):**
   - Grid layout: 2 columns
   - Each card contains:
     
     **Card Example 1 - Venomous:**
     - Large snake photo (square, 150x150px)
     - Badge overlay (top-right): "RẮN ĐỘC" (red badge)
     - Snake name: "Rắn hổ mang chúa" (bold)
     - Scientific: "Ophiophagus hannah" (gray, small)
     - Quick features:
       - "🎯 Đầu dẹt hình thìa"
       - "🎨 Màu nâu vàng, có vân"
       - "📏 1-3m dài"
     - Select button: "Chọn loài này →"
     
     **Card Example 2 - Non-venomous:**
     - Photo
     - Badge: "KHÔNG ĐỘC" (green badge)
     - Name: "Rắn ráo trâu"
     - Features list
     - Button

4. **Helper Section (sticky top):**
   - Text: "💡 Lưu ý: Chọn con GIỐNG NHẤT, không cần chính xác 100%"
   - Small icons showing key features to look for:
     - Head shape icon
     - Color pattern icon
     - Size indicator icon

5. **Bottom Actions:**
   - Secondary button: "Không thấy trong danh sách này" (outlined)
   - Text link: "Quay lại chụp ảnh"

#### Stitch Prompt (English):

```
Mobile app location-based snake selection screen. Visual identification interface with forest green (#228B22) theme.

Top nav: Back arrow left, centered title "Rắn thường gặp ở khu vực bạn", right side shows small location badge "Quận 1, TP.HCM" with pin icon.

Below nav, light blue info banner (#E3F2FD) with rounded corners. Location pin icon on left, text "Dựa trên vị trí của bạn, đây là các loài rắn thường gặp nhất" bold. Below, smaller gray text "Chọn con giống với rắn bạn gặp nhất".

Small sticky helper bar with light yellow background (#FFFACD): "💡 Lưu ý: Chọn con GIỐNG NHẤT, không cần chính xác 100%" with 3 tiny icons showing head/pattern/size.

Main content shows 2-column grid of snake cards. Each card has white background, rounded corners, subtle shadow:

**Card 1 (Venomous):**
- Square snake photo placeholder at top (150x150px), showing king cobra
- Red badge overlay top-right corner "RẮN ĐỘC"
- Below photo: Bold text "Rắn hổ mang chúa" (18pt)
- Italic gray text "Ophiophagus hannah" (14pt)
- 3 feature lines with emoji icons:
  Đầu dẹt hình thìa
  Màu nâu vàng, có vân
  1-3m dài
- Forest green button at bottom "Chọn loài này →"

**Card 2 (Non-venomous):**
- Similar layout
- Green badge "KHÔNG ĐỘC" (#28A745)
- Snake name "Rắn ráo trâu"
- Scientific name
- 3 features
- Green button

**Cards 3-4 visible below** (partial view showing 2 more cards in grid)

Bottom section with white background:
- Medium outlined gray button "Không thấy trong danh sách này" (50px height)
- Small gray text link below "Quay lại chụp ảnh"

Style: Visual selection gallery, prominent photos for quick recognition, clear venomous/non-venomous badges, location-aware interface, educational snake features, emergency app design.
```

#### Notes for Stitch:
- Snake photos phải LARGE và clear để dễ nhận dạng
- Venomous badge (red) phải rất nổi bật
- Quick features giúp user so sánh nhanh
- Grid 2 columns cho easy scanning
- Nếu có > 6 species → vertical scroll

---

### Screen 4.2: Snake Confirmation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận loài rắn đã chọn
- **Mục đích:** Double-check để đảm bảo user chọn đúng loài trước khi đưa first aid instructions
- **Flow position:** Sau khi user chọn một loài từ Screen 4.1
- **Priority:** ⭐⭐⭐
- **Critical:** Preventing wrong identification → wrong first aid → death

#### Key Components:
1. **Header:**
   - Back button: "Chọn lại"
   - Title: "Xác nhận loài rắn"
   - Progress indicator: "Bước 1/2"

2. **Selected Snake Display:**
   - Large hero image of snake (multiple angles if possible)
   - Snake name (large, bold):
     - Vietnamese: "Rắn hổ mang chúa"
     - English: "King Cobra"
     - Scientific: "Ophiophagus hannah"
   - Danger badge: "⚠️ RẮN CỰC ĐỘC" (red, prominent)

3. **Detailed Identification Features:**
   - Section title: "Đặc điểm nhận dạng chi tiết:"
   - 5-6 feature cards with images/icons:
     
     **Feature 1: Head Shape**
     - Small diagram/photo showing head
     - Text: "Đầu dẹt hình thìa, rõ ràng so với cổ"
     - Checkbox: "✓ Đúng" / "✗ Không giống"
     
     **Feature 2: Color Pattern**
     - Color swatch or pattern image
     - Text: "Màu nâu vàng với vân đen chạy dọc"
     - Checkbox
     
     **Feature 3: Size**
     - Size comparison diagram
     - Text: "Thường 1.5-3m, có thể lên đến 5m"
     - Checkbox
     
     **Feature 4: Behavior**
     - Icon
     - Text: "Có thể dựng cổ lên khi bị đe dọa"
     - Checkbox
     
     **Feature 5: Habitat**
     - Location icon
     - Text: "Thường ở rừng, gần nước, núi đá"
     - Checkbox

4. **Confidence Check:**
   - Question: "Có bao nhiêu đặc điểm phù hợp?"
   - Auto-count: "✓ 4/5 đặc điểm phù hợp"
   - Visual indicator:
     - 4-5 matches: Green "Độ tin cậy cao"
     - 2-3 matches: Amber "Độ tin cậy trung bình"
     - 0-1 matches: Red "Không chắc chắn"

5. **Warning Section (if venomous):**
   - Red background box
   - Bold text: "⚠️ Nếu đây là rắn hổ mang chúa:"
   - Urgent bullet points:
     - "Nọc độc cực mạnh - có thể gây tử vong trong 30 phút"
     - "Cần băng ép NGAY và đến bệnh viện khẩn cấp"
     - "Huyết thanh kháng nọc có tại bệnh viện lớn"

6. **Action Buttons:**
   - Primary button: "Xác nhận - Đây là con rắn tôi gặp" (large, forest green)
   - Secondary button: "Không chắc - Chọn loài khác" (outlined, gray)
   - Tertiary button: "Không giống - Trả lời câu hỏi chi tiết" (text link)

#### Stitch Prompt (English):

```
Mobile app snake confirmation screen with detailed identification features. Medical verification interface.

Top nav: Back arrow "Chọn lại" left, centered title "Xác nhận loài rắn", right shows "Bước 1/2" in gray.

Hero section with large snake photo (full width, 200px height) showing king cobra. Below photo, centered text:
- Large bold "Rắn hổ mang chúa" (24pt)
- Medium "King Cobra" (18pt) gray
- Small italic "Ophiophagus hannah" (14pt) gray
- Prominent red badge "⚠️ RẮN CỰC ĐỘC" with danger icon

Section titled "Đặc điểm nhận dạng chi tiết:" in bold.

Vertical list of 5 feature cards, each card has:
- Left side: Small square image/icon placeholder (60x60px)
- Center: Feature title bold, description text below in gray
- Right side: Checkbox (checked = green checkmark, unchecked = gray)

**Card 1:**
Icon: Head diagram
Title: "Hình dạng đầu"
Text: "Đầu dẹt hình thìa, rõ ràng so với cổ"
Checkbox: Checked ✓

**Card 2:**
Icon: Pattern swatch
Title: "Màu sắc & hoa văn"
Text: "Màu nâu vàng với vân đen chạy dọc"
Checkbox: Checked ✓

**Card 3:**
Icon: Ruler
Title: "Kích thước"
Text: "Thường 1.5-3m, có thể lên đến 5m"
Checkbox: Checked ✓

**Card 4:**
Icon: Snake behavior
Title: "Hành vi"
Text: "Có thể dựng cổ lên khi bị đe dọa"
Checkbox: Checked ✓

**Card 5:**
Icon: Location
Title: "Môi trường sống"
Text: "Thường ở rừng, gần nước, núi đá"
Checkbox: Unchecked ✗

Below features, confidence indicator card with green background (#D4EDDA):
"✓ 4/5 đặc điểm phù hợp" large text
"Độ tin cậy cao" with green checkmark

Red warning box (#FFEBEE) with bold text:
"⚠️ Nếu đây là rắn hổ mang chúa:"
3 bullet points:
• Nọc độc cực mạnh - có thể gây tử vong trong 30 phút
• Cần băng ép NGAY và đến bệnh viện khẩn cấp
• Huyết thanh kháng nọc có tại bệnh viện lớn

Bottom section with 3 buttons stacked:
- Large primary forest green button "Xác nhận - Đây là con rắn tôi gặp" (60px height)
- Medium outlined gray button "Không chắc - Chọn loài khác" (50px height)
- Small gray text link "Không giống - Trả lời câu hỏi chi tiết"

Style: Medical verification interface, detailed identification checklist, confidence scoring, clear warning for venomous species, emergency medical app design.
```

#### Notes for Stitch:
- Feature checklist phải interactive (checkboxes)
- Confidence indicator changes color based on match count
- Warning box chỉ hiển thị nếu là venomous species
- Photos showing multiple angles ideal
- Clear escape routes (3 buttons) if user unsure

---

### Screen 4.3: Visual Identification Questionnaire

#### Thông tin màn hình:
- **Tên:** Màn hình câu hỏi nhận dạng rắn bằng hình ảnh
- **Mục đích:** Fallback method khi user không tìm thấy trong location list - narrow down qua visual questions
- **Flow position:** Từ Screen 4.1 nhấn "Không thấy trong danh sách" hoặc từ Screen 4.2 nhấn "Không giống"
- **Priority:** ⭐⭐
- **Strategy:** 4 quick visual questions → AI narrow down to 2-3 possible species

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Nhận dạng qua câu hỏi"
   - Progress: "Câu 1 / 4" (updates for each question)

2. **Progress Bar:**
   - Horizontal bar showing 1/4, 2/4, 3/4, 4/4
   - Filled portion in forest green
   - Remaining in light gray

3. **Question 1: Head Shape**
   - Large question text: "Hình dạng đầu rắn?"
   - Helper text: "Nhìn từ phía trên xuống"
   - 2 large image cards (side by side):
     
     **Option A:**
     - Diagram: Round head
     - Label: "Đầu tròn / Oval"
     - Subtext: "(Thường không độc)"
     - Selection border when tapped
     
     **Option B:**
     - Diagram: Triangular head
     - Label: "Đầu tam giác / Dẹt"
     - Subtext: "(Thường có độc)"
   
   - Button: "Tiếp theo →" (enabled after selection)
   - Skip link: "Không chắc / Bỏ qua"

4. **Question 2: Primary Color**
   - Question: "Màu sắc chủ đạo của rắn?"
   - 4 color cards in 2x2 grid:
     - Card 1: Green swatch + "Xanh lá"
     - Card 2: Brown swatch + "Nâu / Vàng"
     - Card 3: Black swatch + "Đen / Xám"
     - Card 4: Multi swatch + "Nhiều màu / Sọc"
   - Multi-select allowed: "Chọn 1-2 màu chính"

5. **Question 3: Pattern Type**
   - Question: "Hoa văn trên thân?"
   - Helper: "Nhìn phần giữa thân rắn"
   - 4 visual pattern cards:
     - Pattern 1: Solid/Plain illustration + "Trơn / Một màu"
     - Pattern 2: Stripes illustration + "Sọc ngang / Dọc"
     - Pattern 3: Spots illustration + "Đốm / Chấm"
     - Pattern 4: Complex illustration + "Hoa văn phức tạp / Ô vuông"

6. **Question 4: Estimated Size**
   - Question: "Kích thước ước tính?"
   - Visual size comparison with common objects
   - 4 options:
     - "< 50cm" (icon: ruler, "Bằng cánh tay")
     - "50cm - 1m" (icon: "Bằng chiều cao bàn")
     - "1m - 2m" (icon: "Cao bằng người")
     - "> 2m" (icon: "Dài hơn người")

7. **Results Preview (After Q4):**
   - Text: "Đang phân tích..." with loading animation
   - Then: "Tìm thấy 3 loài phù hợp"
   - Button: "Xem kết quả →" (leads to filtered list similar to Screen 4.1)

#### Stitch Prompt (English):

```
Mobile app visual questionnaire for snake identification. Step-by-step question interface with progress tracking. Forest green theme.

Top nav: Back arrow left, centered title "Nhận dạng qua câu hỏi", right shows "Câu 1 / 4" in gray.

Below nav, horizontal progress bar full width: 25% filled in forest green (#228B22), 75% light gray (#E0E0E0). Thin bar, 6px height.

Main content area with white background:

Large bold question text (22pt): "Hình dạng đầu rắn?"
Small gray helper text below: "Nhìn từ phía trên xuống"

Two large side-by-side cards with equal width, white background, border, rounded corners:

**Left card:**
- Large diagram/illustration of snake head from top view showing round/oval shape (placeholder)
- Below diagram: Bold text "Đầu tròn / Oval" (18pt)
- Small gray text "(Thường không độc)" (14pt)
- Card has subtle border, when selected shows thick forest green border

**Right card:**
- Diagram showing triangular/flat head from top
- Bold text "Đầu tam giác / Dẹt"
- Gray text "(Thường có độc)"
- Border styling same as left

Below cards, large forest green button "Tiếp theo →" full width (55px height).
Small gray text link centered below button "Không chắc / Bỏ qua".

Style: Step-by-step survey interface, large visual options for easy selection, clear progress indicator, one question per screen, calm educational design despite emergency context.

---

For Questions 2-4, use same layout structure with:
- Same header and progress bar (updating to 2/4, 3/4, 4/4)
- Different question text and visual options as specified
- Q2: 2x2 grid of color swatches
- Q3: 2x2 grid of pattern illustrations
- Q4: 4 vertical cards with size comparisons and icons
```

#### Notes for Stitch:
- Each question = separate screen (4 screens total technically, but same template)
- Visual options phải LARGE và clear
- Progress bar giúp user biết gần xong
- "Skip" option quan trọng nếu user không nhớ
- After Q4 → Show loading → Then result list (reuse Screen 4.1 design but filtered)

---

### Screen 4.4: Generic First Aid Protocol (Safety Fallback)

#### Thông tin màn hình:
- **Tên:** Màn hình sơ cứu chung khi không xác định được loài
- **Mục đích:** Safety net - cung cấp hướng dẫn CHUNG an toàn cho mọi vết cắn rắn độc, SAU ĐÓ tiếp tục thu thập triệu chứng
- **Flow position:** Alternative flow khi không identify được → VẪN TIẾP TỤC đến Screen 6 (Symptom Input)
- **Priority:** ⭐⭐⭐ (CRITICAL - Must not give dangerous advice)
- **Medical principle:** "Do no harm" - generic protocol safe for ALL venomous snakes
- **Important:** Dù không biết loài, TRIỆU CHỨNG vẫn quan trọng cho đội cứu hộ!

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Hướng dẫn sơ cứu chung"
   - Status badge: "Chưa xác định loài" (amber)

2. **Alert Banner:**
   - Amber background (#FFF3CD)
   - Icon: Warning triangle
   - Large text: "⚠️ Không xác định được loài rắn chính xác"
   - Subtext: "Đang sử dụng giao thức sơ cứu CHUNG an toàn cho tất cả vết cắn rắn độc"

3. **Critical Warning Section:**
   - Red box with white text
   - Title: "QUAN TRỌNG - ĐỌC KỸ:"
   - Text: "Vì không biết loại nọc độc, hướng dẫn này bao gồm biện pháp AN TOÀN cho cả Neurotoxic và Hemotoxic venom"
   - Subtext: "CẦN ĐẾN BỆNH VIỆN NGAY để xét nghiệm và điều trị chính xác"

4. **Universal First Aid Steps:**
   - Title: "Các bước sơ cứu AN TOÀN:"
   - Numbered steps with large icons:
     
     **Step 1: Stay Calm**
     - Icon: Meditation/calm symbol
     - Text: "GIỮ BÌNH TĨNH và hạn chế vận động"
     - Detail: "Vận động làm nọc độc lan nhanh hơn"
     
     **Step 2: Remove Constrictors**
     - Icon: Ring/jewelry
     - Text: "CỞI ngay đồ trang sức, quần áo chật"
     - Detail: "Vùng bị cắn sẽ sưng lên nhanh chóng"
     
     **Step 3: Gentle Pressure**
     - Icon: Bandage
     - Text: "Băng VỪA PHẢI - không quá chặt"
     - Detail: "Vừa đủ chặt, vẫn sờ thấy mạch máu"
     - Warning: "⚠️ KHÔNG băng quá chặt (gây hoại tử nếu là hemotoxic)"
     - Warning: "⚠️ KHÔNG để quá lỏng (không hiệu quả với neurotoxic)"
     
     **Step 4: Position**
     - Icon: Person lying down
     - Text: "GIỮ vùng cắn ngang BẰNG tim"
     - Detail: "Không quá cao, không quá thấp"
     - Rationale: "Compromise position an toàn cho cả 2 loại nọc"
     
     **Step 5: Mark Wound**
     - Icon: Pen/marker
     - Text: "ĐÁNH DẤU viền vết sưng mỗi 15 phút"
     - Detail: "Giúp bác sĩ đánh giá tốc độ lan độc"
     
     **Step 6: Hospital**
     - Icon: Hospital
     - Text: "ĐẾN BỆNH VIỆN NGAY - KHÔNG chần chừ"
     - Detail: "Mang theo ảnh rắn nếu có để bác sĩ xác định"

5. **Absolute Don'ts (Critical):**
   - Red background section
   - Title: "TUYỆT ĐỐI KHÔNG LÀM:"
   - Large X icons with text:
     - "❌ KHÔNG cắt vết thương"
     - "❌ KHÔNG hút nọc độc"
     - "❌ KHÔNG đắp băng garo (tourniquet)"
     - "❌ KHÔNG đắp đá lạnh"
     - "❌ KHÔNG cho uống rượu hoặc thuốc giảm đau"
     - "❌ KHÔNG bắt hoặc chụp thêm ảnh rắn (nguy hiểm)"

6. **Why Generic Protocol:**
   - Expandable info section: "Tại sao không cụ thể hơn? ▼"
   - When expanded:
     - "Neurotoxic venom (hổ mang, cạp nong): Cần băng CHẶT + Giữ THẤP"
     - "Hemotoxic venom (lục đuôi đỏ, rắn lục): Cần băng LỎNG + Giữ CAO"
     - "→ Không biết loại → Dùng biện pháp TRUNG GIAN an toàn"
     - "→ Bác sĩ sẽ điều chỉnh sau khi xét nghiệm"

7. **Continue Flow Actions:**
   - Large primary button: "Tiếp tục báo cáo triệu chứng →" (forest green, 60px)
     - Text below: "Đội cứu hộ cần biết triệu chứng của bạn để chuẩn bị"
   - Secondary text: "Hoặc nếu khẩn cấp:"
   - Small red outlined button: "Gọi 115 ngay" (50px)
   - Small outlined button: "Gửi SOS" (50px)

8. **Hospital Checklist:**
   - Title: "Thông tin cần đưa bác sĩ:"
   - Checklist items:
     - ☐ Thời gian bị cắn (ghi chính xác)
     - ☐ Vị trí gặp rắn (rừng/nhà/ruộng...)
     - ☐ Ảnh hoặc mô tả rắn (nếu có)
     - ☐ Triệu chứng đã xuất hiện
     - ☐ Các bước sơ cứu đã làm

#### Stitch Prompt (English):

```
Mobile app generic first aid protocol screen for unidentified snake bite. Medical safety fallback interface with comprehensive universal guidelines.

Top nav: Back arrow left, title "Hướng dẫn sơ cứu chung", right shows amber badge "Chưa xác định loài".

Full-width amber alert banner (#FFF3CD) with warning triangle icon, large bold text:
"⚠️ Không xác định được loài rắn chính xác"
Smaller text below: "Đang sử dụng giao thức sơ cứu CHUNG an toàn cho tất cả vết cắn rắn độc"

Red box (#FFEBEE) with bold text:
"QUAN TRỌNG - ĐỌC KỸ:"
"Vì không biết loại nọc độc, hướng dẫn này bao gồm biện pháp AN TOÀN cho cả Neurotoxic và Hemotoxic venom"
"CẦN ĐẾN BỆNH VIỆN NGAY để xét nghiệm và điều trị chính xác"

Section titled "Các bước sơ cứu AN TOÀN:" in bold.

Vertical list of 6 numbered step cards, each card:
- Left: Large circular icon (60px) with step number badge
- Right: Bold step title, regular detail text, warnings in amber/red where applicable

**Step 1:** Meditation icon, "GIỮ BÌNH TĨNH và hạn chế vận động", detail text
**Step 2:** Jewelry icon, "CỠI ngay đồ trang sức, quần áo chật"
**Step 3:** Bandage icon, "Băng VỪA PHẢI - không quá chặt"
Two small warning lines:
"⚠️ KHÔNG băng quá chặt (gây hoại tử nếu là hemotoxic)"
"⚠️ KHÔNG để quá lỏng (không hiệu quả với neurotoxic)"
**Step 4:** Person lying icon, "GIỮ vùng cắn ngang BẰNG tim"
**Step 5:** Marker icon, "ĐÁNH DẤU viền vết sưng mỗi 15 phút"
**Step 6:** Hospital icon, "ĐẾN BỆNH VIỆN NGAY - KHÔNG chần chừ"

Red section with title "TUYỆT ĐỐI KHÔNG LÀM:" showing 6 items with large X icons:
❌ KHÔNG cắt vết thương
❌ KHÔNG hút nọc độc
❌ KHÔNG đắp băng garo (tourniquet)
❌ KHÔNG đắp đá lạnh
❌ KHÔNG cho uống rượu hoặc thuốc giảm đau
❌ KHÔNG bắt hoặc chụp thêm ảnh rắn (nguy hiểm)

Expandable info section with forest green header bar: "Tại sao không cụ thể hơn? ▼" (collapsed state shown)

Large primary action section:
- Large forest green button "Tiếp tục báo cáo triệu chứng →" (60px height, solid fill)
- Small gray text below button: "Đội cứu hộ cần biết triệu chứng của bạn để chuẩn bị"

Below, small gray text "Hoặc nếu khẩn cấp:" centered

Two smaller buttons side-by-side:
- Red outlined button "Gọi 115 ngay" (50px height, left)
- Gray outlined button "Gửi SOS" (50px height, right)

Bottom card titled "Thông tin cần đưa bác sĩ:" with light blue background (#E3F2FD), 5 unchecked checkbox items in Vietnamese.

Style: Medical safety protocol, universal guidelines emphasis, clear compromise approach, detailed warnings, educational medical interface, emergency context but comprehensive information.
```

#### Notes for Stitch:
- Amber alert banner phải rất prominent
- Step 3 (Bandaging) có nhiều warnings - quan trọng nhất
- "Moderate pressure" và "level with heart" là compromise cho unknown venom type
- Red "Don'ts" section phải nổi bật như Warning banner
- Expandable section giải thích medical rationale
- Hospital checklist giúp user prepare

**Medical Accuracy Note:**
- Protocol này based on WHO guidelines for unidentified venomous snake bites
- Compromise approach: not optimal for either venom type, but SAFE for both
- Hospital visit absolutely mandatory - cannot treat properly without identification

---

### Screen 5: AI Snake Identification Result

#### Thông tin màn hình:
- **Tên:** Màn hình kết quả nhận diện loài rắn bằng AI
- **Mục đích:** Hiển thị kết quả nhận diện rắn, mức độ độc tính, và hướng dẫn xử lý phù hợp
- **Flow position:** Sau khi AI xử lý ảnh từ Screen 4
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Kết quả nhận diện"
   - Share button (top-right)

2. **Result Status Badge:**
   - Top banner với màu theo mức độ nguy hiểm:
     - VENOMOUS (Red): "⚠️ PHÁT HIỆN RẮN ĐỘC"
     - NON-VENOMOUS (Green): "✓ Rắn không độc"
   - Large, prominent, full-width

3. **Snake Information Card:**
   - Snake photo (user's uploaded image)
   - Snake name:
     - English: "King Cobra"
     - Scientific: "Ophiophagus hannah"
     - Vietnamese: "Rắn hổ mang chúa"
   - Confidence score: "Độ tin cậy AI: 94%"

4. **Danger Level Section:**
   - Visual indicator: Red/Amber/Green bar
   - Text: "Mức độ nguy hiểm: CAO"
   - Description: "Có độc rất cao - Cần chăm sóc y tế ngay lập tức"

5. **Recommended Actions Card:**
   - Title: "Cần làm NGAY:"
   - Numbered action items:
     - "1. Xem hướng dẫn sơ cứu CHUYÊN BIỆT cho loài rắn này"
     - "2. Gọi cấp cứu ngay lập tức"
     - "3. Băng ép vết cắn theo hướng dẫn"
     - "4. Đến bệnh viện có huyết thanh gần nhất"
   - PRIMARY CTA button: "Xem Hướng Dẫn Sơ Cứu Cho Loài Này →" (forest green, large, leads to Screen 3)
   - Secondary CTA button: "Tìm bệnh viện có huyết thanh" (red outlined)

6. **Snake Details (Expandable Section):**
   - Collapsible panel: "Xem chi tiết rắn ▼"
   - When expanded shows:
     - Môi trường sống
     - Vị trí thường gặp
     - Hành vi thường thấy
     - Tác dụng của nha độc

7. **Bottom Actions:**
   - Secondary button: "Báo cáo lần nhìn thấy này"
   - Text link: "Không đúng? Chụp lại"

#### Stitch Prompt (English):

```
Mobile app screen showing AI snake identification results. Emergency medical information design with clear danger indicators.

Top nav: Back arrow left, title "Kết quả nhận diện", share icon right. White background.

Full-width top banner: Red background (#DC3545) with white bold text "⚠️ PHÁT HIỆN RẮN ĐỘC" centered. High visual prominence.

Below banner, white card with padding showing user's uploaded snake photo (square placeholder, rounded corners). Below photo, snake name displayed in hierarchical typography:
- Large bold text "King Cobra" (20pt)
- Italic gray text "Ophiophagus hannah" (16pt)  
- Regular text "Rắn hổ mang chúa" (16pt)
- Light gray text "Độ tin cậy AI: 94%" (14pt)

Next section shows danger indicator: Horizontal bar with gradient red-to-green, marker positioned at "CAO" level. Below bar, large text "Mức độ nguy hiểm: CAO" and description "Có độc rất cao - Cần chăm sóc y tế ngay lập tức" in dark gray.

White card titled "Cần làm NGAY:" containing 4 numbered items in bold:
1. Xem hướng dẫn sơ cứu CHUYÊN BIỆT cho loài rắn này
2. Gọi cấp cứu ngay lập tức
3. Băng ép vết cắn theo hướng dẫn
4. Đến bệnh viện có huyết thanh gần nhất

Below list, two vertically stacked buttons:
- Large forest green primary button "Xem Hướng Dẫn Sơ Cứu Cho Loài Này →" (60px height, most prominent)
- Large red outlined secondary button "Tìm bệnh viện có huyết thanh" (50px height)

Expandable section with forest green header bar "Xem chi tiết rắn ▼" (collapsed state shown).

Bottom of screen has 2 buttons:
- Secondary outlined button "Báo cáo lần nhìn thấy này"
- Small gray text link "Không đúng? Chụp lại"

Style: Emergency medical results interface, clear hierarchy, danger indicators prominent, actionable next steps emphasized, professional medical app design.
```

#### Notes for Stitch:
- Danger banner phải là element nổi bật nhất
- Phân biệt rõ giữa VENOMOUS (red) và NON-VENOMOUS (green) cases
- Confidence score giúp user đánh giá độ tin cậy
- Nếu expandable không render được → "Show as separate section with 'Details' heading"

---

### Screen 6: Symptom Input Screen

#### Thông tin màn hình:
- **Tên:** Màn hình nhập triệu chứng và chụp vết cắn
- **Mục đích:** Thu thập thông tin về triệu chứng và ảnh vết cắn để AI đánh giá mức độ nghiêm trọng
- **Flow position:** Sau AI Snake Identification hoặc từ Emergency Alert
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Báo cáo triệu chứng"
   - Progress: "Bước 2 / 3"

2. **Photo Section:**
   - Title: "Ảnh vết cắn"
   - Large image upload area:
     - Dashed border rectangle
     - Camera icon
     - Text: "Nhấn để chụp hoặc tải ảnh"
   - If photo uploaded: Show thumbnail with edit/remove options
   - Helper text: "Điều này giúp đánh giá mức độ nghiêm trọng"

3. **Symptom Checklist:**
   - Title: "Chọn triệu chứng bạn đang gặp:"
   - Multi-select checkboxes (forest green when checked):
     - ☐ Đau tại vị trí vết cắn
     - ☐ Sưng tấy
     - ☐ Tê bỏi/Chốt mặt
     - ☐ Buồn nôn/Nôn mửa
     - ☐ Khó thở
     - ☐ Mờ mắt
     - ☐ Đổ mồ hôi nhiều
     - ☐ Chảy máu từ vết thương
     - ☐ Triệu chứng khác

4. **Severity Scale:**
   - Title: "Mức độ đau của bạn? (1-10)"
   - Visual slider from 1 (Nhẹ) to 10 (Nghiêm trọng)
   - Color gradient: Green → Yellow → Red
   - Current value displayed: "7"

5. **Time Since Bite:**
   - Title: "Thời gian kể từ khi bị cắn:"
   - Dropdown or picker: "15 phút trước"
   - Options: "Vừa xong", "5 phút", "15 phút", "30 phút", "1 giờ", "Trên 1 giờ"

6. **Additional Notes:**
   - Text area: "Thông tin bổ sung? (tùy chọn)"
   - Placeholder: "Mô tả các triệu chứng khác..."

7. **Action Buttons:**
   - Primary button: "Phân tích triệu chứng →" (forest green)
   - Secondary link: "Bỏ qua bước này"

#### Stitch Prompt (English):

```
Mobile app symptom input form screen for snakebite tracking. Clean medical form design.

Top nav: Back arrow left, centered title "Report Symptoms", right shows "Step 2 of 3" in gray.

First section titled "Photo of Bite Wound" in bold. Large rectangular upload area with dashed border (#CCCCCC), rounded corners, containing camera icon and centered text "Tap to capture or upload photo". Below upload area, small gray helper text "This helps assess severity".

Next section titled "Select symptoms you're experiencing:" with vertical list of checkboxes. 9 checkbox items with forest green checkmarks when selected:
□ Pain at bite site
□ Swelling  
□ Numbness/Tingling
□ Nausea/Vomiting
□ Difficulty breathing
□ Blurred vision
□ Excessive sweating
□ Bleeding from wound
□ Other symptoms

Below checkboxes, section titled "How would you rate the pain? (1-10)". Horizontal slider track with gradient from green (left) to yellow (center) to red (right). Labels "1 Mild" on left end, "10 Severe" on right end. Current value "7" displayed prominently above slider.

Next section titled "Time since bitten:" with dropdown/picker showing "15 minutes ago" with down arrow indicator.

Text area input labeled "Any other information? (optional)" with light gray placeholder text "Describe any other symptoms..." inside. Text area has light border, rounded corners.

Bottom has large primary button "Analyze Symptoms →" in forest green, full width. Small gray text link below button "Skip this step".

Style: Medical form interface, clear labels, adequate spacing between sections, touch-friendly inputs, professional healthcare app design.
```

#### Notes for Stitch:
- Checkboxes phải đủ lớn để easy to tap (min 44px touch target)
- Pain slider phải có visual feedback rõ ràng
- Photo upload area phải prominent
- Form validation cần rõ ràng nếu skip required fields

---

### Screen 7: Severity Assessment Result

#### Thông tin màn hình:
- **Tên:** Màn hình kết quả đánh giá mức độ nghiêm trọng
- **Mục đích:** Hiển thị kết quả phân tích AI về mức độ nguy hiểm và khuyến nghị hành động khẩn cấp
- **Flow position:** Sau khi AI phân tích symptoms từ Screen 6
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Đánh giá mức độ nghiêm trọng"
   - Time stamp: "Phân tích lúc 14:35"

2. **Severity Level Banner:**
   - Large top section với màu theo mức độ:
     - CRITICAL (Dark Red #C0392B): "🚨 NGHIÊM TRỌNG - CẦN CẤP CỨU NGAY"
     - SEVERE (Red #E74C3C): "⚠️ NẶNG - Đến bệnh viện NGAY"
     - MODERATE (Amber #F39C12): "⚠️ VỮA - Cần chăm sóc y tế"
     - MILD (Green #27AE60): "✓ NHẺ - Theo dõi triệu chứng"
   - Full-width, bold text, large font

3. **Assessment Score Card:**
   - Visual score: Circular progress indicator or bar (0-100)
   - Text: "Điểm mức độ: 85/100"
   - Color-coded based on severity
   - AI confidence: "Dựa trên triệu chứng và phân tích ảnh"

4. **Symptoms Summary:**
   - Title: "Các yếu tố nguy cơ:"
   - Icon list (red exclamation marks for critical symptoms):
     - ❗ Phát hiện khó thở
     - ❗ Mức độ đau cao (7/10)
     - ❗ Sưng tấy và tê bỏi
     - ⚠️ Xác nhận rắn độc
   - Time elapsed: "⏱️ 15 phút kể từ khi bị cắn"

5. **Immediate Actions Required:**
   - Large card with numbered urgent steps:
     - "1. GỌI CẤP CỨU NGAY"
     - "2. Đến bệnh viện gần nhất ngay lập tức"
     - "3. Thông báo người thân khẩn cấp"
     - "4. Tiếp tục sơ cứu trong khi chờ"

6. **Emergency Call Buttons:**
   - Large red primary button: "Gọi Đường dây nóng khẩn cấp" (with phone number)
   - Secondary button: "Tìm bệnh viện gần nhất →"
   - Tertiary button: "Gửi cảnh báo SOS"

7. **Progress Tracking:**
   - Text: "Triệu chứng của bạn đang được theo dõi"
   - Link: "Cập nhật triệu chứng" (if condition changes)

#### Stitch Prompt (English):

```
Mobile app emergency severity assessment results screen. High-urgency medical alert interface.

Top nav: Back arrow left, title "Đánh giá mức độ nghiêm trọng", timestamp "Phân tích lúc 14:35" in gray on right.

Large full-width banner at top with dark red background (#C0392B), white bold text "🚨 NGHIÊM TRỌNG - CẦN CẤP CỨU NGAY" centered. Very prominent, high contrast.

Below banner, white card showing circular severity indicator (85% filled in red) with large text "Điểm mức độ: 85/100" centered. Below score, small gray text "Dựa trên triệu chứng và phân tích ảnh".

Next white card titled "Các yếu tố nguy cơ:" with 4 items listed vertically, each with red exclamation icon:
❗ Phát hiện khó thở
❗ Mức độ đau cao (7/10)
❗ Sưng tấy và tê bỏi  
⚠️ Xác nhận rắn độc
Bottom of this card shows "⏱️ 15 phút kể từ khi bị cắn" in amber color.

Large white card titled "Cần làm NGAY:" containing 4 numbered items in bold text:
1. GỌI CẤP CỨU NGAY
2. Đến bệnh viện gần nhất ngay lập tức
3. Thông báo người thân khẩn cấp
4. Tiếp tục sơ cứu trong khi chờ

Bottom section has 3 vertically stacked buttons with spacing:
- Large red primary button "Gọi Đường dây nóng khẩn cấp" (60px height)
- Secondary outlined forest green button "Tìm bệnh viện gần nhất →"
- Tertiary outlined gray button "Gửi cảnh báo SOS"

At very bottom, small text "Triệu chứng của bạn đang được theo dõi" with link "Cập nhật triệu chứng" in forest green.

Style: Emergency medical alert interface, high urgency, clear hierarchy, critical information prominent, actionable buttons emphasized, professional medical emergency design.
```

#### Notes for Stitch:
- Severity banner màu phải thay đổi theo level: Critical (dark red), Severe (red), Moderate (amber), Mild (green)
- Score indicator phải rõ ràng và color-coded
- Call buttons phải largest và most prominent
- Layout phải work cho cả trường hợp Mild (ít urgent) và Critical

---

### Screen 7.5: Expert SOS Consultation Offer (OPTIONAL)

#### Thông tin màn hình:
- **Tên:** Màn hình đề xuất tư vấn khẩn cấp với chuyên gia
- **Mục đích:** Cung cấp tùy chọn tư vấn video với chuyên gia ngay lập tức với phí 500,000 VNĐ
- **Flow position:** Sau Screen 7 (Assessment Result) - Optional branch trước khi gọi SOS
- **Priority:** ⭐⭐⭐
- **Note:** Màn hình này là OPTIONAL - Patient có thể bỏ qua và đi thẳng đến Screen 8 (SOS)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Tư vấn khẩn cấp"
   - Skip button (top right): "Bỏ qua →"

2. **Premium Badge:**
   - Purple/gold badge: "DỊCH VỤ ƯU TIÊN"
   - Subtitle: "Phản hồi trong 1-2 phút"

3. **Hero Banner Card:**
   - Large illustration/icon: Video call with expert (doctor avatar + video icon)
   - Main title: "Gọi chuyên gia ngay lập tức"
   - Subtitle: "Tư vấn sơ cứu qua video call 5-10 phút"

4. **Benefits List:**
   - Title: "Bạn sẽ nhận được:"
   - 5 items với checkmark icons:
     - Phản hồi trong 1-2 phút (ưu tiên cao nhất)
     - Tư vấn trực tiếp với chuyên gia rắn
     - Hướng dẫn sơ cứu chi tiết qua video
     - Đánh giá mức độ nguy hiểm chính xác
     - Khuyến nghị cần thiết đến bệnh viện hay không

5. **Pricing Card:**
   - Large prominent card with border
   - Main price: "500,000 VNĐ" (large, bold)
   - Original price crossed: "~~300,000 VNĐ~~" (regular consultation)
   - Label: "Phí khẩn cấp - Thanh toán trước"
   - Small badge: ESCROW badge ("Giữ an toàn đến khi hoàn tất")

6. **Trust Signals:**
   - Small info box với amber background:
     - "Hoàn tiền 100% nếu không có chuyên gia trong 2 phút"
     - "Hoàn 50% nếu không hài lòng (khiếu nại trong 1 giờ)"

7. **Action Buttons:**
   - Large primary button (purple): "Gọi chuyên gia ngay (500,000 VNĐ)"
   - Secondary outlined button (forest green): "Bỏ qua - Gọi đội cứu hộ SOS"

8. **Context Note:**
   - Small gray text at bottom:
     - "Đội cứu hộ vẫn sẽ được gọi sau khi tư vấn"
     - "Tư vấn chỉ mất 5-10 phút"

#### Stitch Prompt (English):

```
Mobile app premium expert consultation offer screen for emergency snakebite app. Medical emergency upsell design with trust signals.

Top nav: Back arrow left, title "Tư vấn khẩn cấp" centered, "Bỏ qua →" link in forest green top-right.

Purple/gold badge at top center: "DỊCH VỤ ƯU TIÊN" with subtitle "Phản hồi trong 1-2 phút" in small gray text.

Large white card with video call illustration: doctor avatar in circle with video camera icon overlay. Below illustration, large bold text "Gọi chuyên gia ngay lập tức" and subtitle "Tư vấn sơ cứu qua video call 5-10 phút" in gray.

White card titled "Bạn sẽ nhận được:" with 5 items listed vertically, each with green checkmark icon:
Phản hồi trong 1-2 phút (ưu tiên cao nhất)
Tư vấn trực tiếp với chuyên gia rắn
Hướng dẫn sơ cứu chi tiết qua video
Đánh giá mức độ nguy hiểm chính xác
Khuyến nghị cần thiết đến bệnh viện hay không

Prominent white card with purple border showing large bold price "500,000 VNĐ" centered. Above price, small crossed-out text "~~300,000 VNĐ~~" in gray. Below price, text "Phí khẩn cấp - Thanh toán trước". Small badge "Giữ an toàn đến khi hoàn tất".

Amber background info box with 2 lines:
Hoàn tiền 100% nếu không có chuyên gia trong 2 phút
Hoàn 50% nếu không hài lòng (khiếu nại trong 1 giờ)

Two full-width buttons with 16px spacing:
1. Large purple primary button "Gọi chuyên gia ngay (500,000 VNĐ)" (60px height)
2. Secondary outlined forest green button "Bỏ qua - Gọi đội cứu hộ SOS" (52px height)

Bottom gray text in small font:
Đội cứu hộ vẫn sẽ được gọi sau khi tư vấn
Tư vấn chỉ mất 5-10 phút

Style: Premium medical service offer, emergency context, clear value proposition, trust signals prominent, purple as premium accent, professional medical upsell design, emergency-appropriate pricing transparency.
```

#### Notes for Stitch:
- Purple/gold premium badge phải nổi bật nhưng không overwhelming
- Price 500K phải rõ ràng và justify với benefits list
- Trust signals (refund policy) là critical cho high-price emergency payment
- "Bỏ qua" button phải visible - không force user
- ESCROW badge quan trọng để reassure về payment safety

---

### Screen 7.6: Expert SOS Payment Confirmation

#### Thông tin màn hình:
- **Tên:** Màn hình thanh toán tư vấn khẩn cấp
- **Mục đích:** Xử lý payment 500K upfront và hiển thị ESCROW protection
- **Flow position:** Sau Screen 7.5 khi Patient chọn "Gọi chuyên gia ngay"
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Thanh toán tư vấn khẩn cấp"
   - Progress indicator: "Bước 1/2"

2. **Service Summary Card:**
   - Icon: Video call with expert
   - Service name: "Tư vấn chuyên gia SOS"
   - Description: "Phản hồi 1-2 phút, tư vấn 5-10 phút"
   - Status badge: "Ưu tiên cao nhất" (purple)

3. **Payment Amount:**
   - Large prominent display: "500,000 VNĐ"
   - Subtitle: "Thanh toán trước - Giữ trong ESCROW"
   - Info icon với tooltip: "Tiền được giữ an toàn và chỉ chuyển cho chuyên gia sau khi hoàn tất tư vấn"

4. **Payment Summary:**
   - Simple display (no breakdown needed):
     - Phí tư vấn khẩn cấp: 500,000 VNĐ (bold)
     - Thanh toán trước - Giữ trong ESCROW

5. **Payment Methods:**
   - Title: "Phương thức thanh toán"
   - 4 options (radio buttons):
     - 💳 Thẻ tín dụng/Ghi nợ (Visa, Mastercard)
     - 🏦 Ví điện tử (MoMo, ZaloPay, VNPay)
     - 🏧 Chuyển khoản ngân hàng
     - 💰 Ví SnakeAid (nếu có số dư)
   - Selected option highlighted với forest green border

6. **ESCROW Protection Badge:**
   - Prominent green box with shield icon:
     - "BẢO VỆ THANH TOÁN ESCROW"
     - 3 bullet points:
       - Tiền được giữ an toàn trong hệ thống
       - Chỉ chuyển cho chuyên gia sau tư vấn hoàn tất
       - Hoàn tiền tự động nếu không kết nối trong 2 phút

7. **Important Notes Card:**
   - Amber background box:
     - Title: "Lưu ý quan trọng:"
     - 3 points:
       - Hoàn 100% nếu không có chuyên gia trong 2 phút
       - Hoàn 50% nếu khiếu nại chất lượng trong 1 giờ
       - Không hoàn nếu đã tư vấn đầy đủ hoặc Patient hủy sau khi bắt đầu

8. **Terms Checkbox:**
   - Checkbox: "Tôi đồng ý với Điều khoản dịch vụ và Chính sách hoàn tiền"
   - Link to full terms (opens modal)

9. **Action Buttons:**
   - Large primary button (purple): "Xác nhận thanh toán 500,000 VNĐ"
   - Secondary text button: "Quay lại"

10. **Security Badge:**
    - Small footer with lock icon:
      - "Thanh toán được mã hóa và bảo mật"

#### Stitch Prompt (English):

```
Mobile app payment confirmation screen for emergency expert consultation. Medical service payment with ESCROW protection emphasis.

Top nav: Back arrow left, title "Thanh toán tư vấn khẩn cấp" centered, progress indicator "Bước 1/2" right side in gray.

White card at top showing video call icon, service name "Tư vấn chuyên gia SOS" in bold, description "Phản hồi 1-2 phút, tư vấn 5-10 phút" in gray, and purple badge "Ưu tiên cao nhất".

Large payment amount display: "500,000 VNĐ" in huge bold text centered. Below in gray "Thanh toán trước - Giữ trong ESCROW" with info icon.

Simple payment summary:
Phí tư vấn khẩn cấp: 500,000 VNĐ (bold)
Thanh toán trước - Giữ trong ESCROW

White card titled "Phương thức thanh toán" with 4 radio button options vertically:
Thẻ tín dụng/Ghi nợ (Visa, Mastercard)
Ví điện tử (MoMo, ZaloPay, VNPay)
Chuyển khoản ngân hàng
Ví SnakeAid (nếu có số dư)
First option selected with forest green border.

Green background card with shield icon:
BẢO VỆ THANH TOÁN ESCROW
Three checkmarked items:
Tiền được giữ an toàn trong hệ thống
Chỉ chuyển cho chuyên gia sau tư vấn hoàn tất
Hoàn tiền tự động nếu không kết nối trong 2 phút

Amber background card:
Lưu ý quan trọng:
Hoàn 100% nếu không có chuyên gia trong 2 phút
Hoàn 50% nếu khiếu nại chất lượng trong 1 giờ
Không hoàn nếu đã tư vấn đầy đủ hoặc Patient hủy sau khi bắt đầu

Checkbox with text "Tôi đồng ý với Điều khoản dịch vụ và Chính sách hoàn tiền" with underlined link.

Two buttons:
1. Large purple primary button "Xác nhận thanh toán 500,000 VNĐ" (60px height)
2. Text-only gray button "Quay lại" below

Bottom footer with small gray text:
Thanh toán được mã hóa và bảo mật

Style: Professional payment interface, ESCROW protection prominent, trust signals throughout, clear refund policy, medical service payment, emergency context appropriate, purple as premium accent.
```

#### Notes for Stitch:
- ESCROW badge phải very prominent - đây là key trust signal cho 500K upfront
- Payment methods phải show familiar Vietnamese options (MoMo, ZaloPay, VNPay)
- Refund policy phải crystal clear - 3 scenarios rõ ràng
- Terms checkbox required before payment button active
- Security badges quan trọng cho high-value emergency payment

---

### Screen 7.7: Waiting for Expert - Matching Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chờ kết nối với chuyên gia
- **Mục đích:** Loading state sau payment, show matching progress với countdown 2 phút
- **Flow position:** Sau Screen 7.6 (Payment confirmed)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button (disabled during matching)
   - Title: "Đang kết nối chuyên gia"
   - Status: "Đang xử lý..."

2. **Countdown Timer (Prominent):**
   - Large circular countdown: "1:45" (mm:ss)
   - Color-coded:
     - Green (2:00-1:00): Normal
     - Amber (1:00-0:30): Warning
     - Red (0:30-0:00): Critical
   - Label below: "Thời gian phản hồi tối đa: 2 phút"

3. **Matching Animation:**
   - Center animated element:
     - Pulsing circles/waves emanating from center
     - OR rotating dots
     - OR searching radar animation
   - Icon: Video call symbol or expert avatar placeholder

4. **Status Messages (Dynamic):**
   - Main status text (changes every 5-10 seconds):
     - "Đang tìm chuyên gia khả dụng..."
     - "Đã tìm thấy 3 chuyên gia, đang kết nối..."
     - "Chuyên gia đang chuẩn bị, vui lòng chờ..."
     - "Sắp kết nối..."
   - Progress indicator: 4 dots showing current step

5. **Guarantee Badge:**
   - Green box with checkmark:
     - "Cam kết phản hồi trong 2 phút"
     - "Hoàn tiền 100% nếu không kết nối"

6. **What's Happening Card:**
   - Expandable info card: "Đang diễn ra gì? ▼"
   - When expanded shows 4 steps with progress:
     - Thanh toán đã xác nhận (completed - green checkmark)
     - Đang tìm chuyên gia khả dụng (in progress - animated)
     - Kết nối video call (pending - gray)
     - Bắt đầu tư vấn (pending - gray)

7. **Expert Matching Stats:**
   - Small info box:
     - "12 chuyên gia đang online"
     - "Thời gian phản hồi trung bình: 1m 20s"
     - "95% cuộc gọi kết nối thành công"

8. **Emergency Context Reminder:**
   - Amber box at bottom:
     - "Trong khi chờ:"
     - 3 quick tips:
       - Continue sơ cứu theo hướng dẫn AI
       - Giữ bình tĩnh
       - Chuẩn bị câu hỏi cho chuyên gia

9. **Cancel Option:**
   - Small text link at bottom: "Hủy yêu cầu & hoàn tiền"
   - Confirmation modal if clicked

#### Stitch Prompt (English):

```
Mobile app waiting/matching screen for emergency expert consultation. Loading state with countdown timer and progress indicators.

Top nav: Back arrow left (faded/disabled), title "Đang kết nối chuyên gia" centered, status badge "Đang xử lý..." in amber right side.

Large circular countdown timer centered at top: "1:45" in huge bold text inside circle. Circle has green progress ring (75% filled). Below timer, gray text "Thời gian phản hồi tối đa: 2 phút".

Below timer, center animated pulsing circles radiating outward from video call icon. Icon is purple. Animation suggests searching/matching.

Dynamic status text below animation: "Đã tìm thấy 3 chuyên gia, đang kết nối..." with 4 progress dots below (2 filled purple, 2 gray).

Green background card with checkmark:
Cam kết phản hồi trong 2 phút
Hoàn tiền 100% nếu không kết nối

White card with expandable header "Đang diễn ra gì? ▼". Expanded showing 4 steps:
1. Thanh toán đã xác nhận (green checkmark)
2. Đang tìm chuyên gia khả dụng (purple animated spinner)
3. Kết nối video call (gray clock icon)
4. Bắt đầu tư vấn (gray clock icon)

Small info card with 3 stat lines:
12 chuyên gia đang online
Thời gian phản hồi trung bình: 1m 20s
95% cuộc gọi kết nối thành công

Amber background card at bottom:
Trong khi chờ:
Continue sơ cứu theo hướng dẫn AI
Giữ bình tĩnh
Chuẩn bị câu hỏi cho chuyên gia

Bottom center small link text "Hủy yêu cầu & hoàn tiền" in gray.

Style: Professional medical waiting interface, reassuring design, progress transparency, countdown prominent, animated matching feedback, trust signals throughout, emergency context appropriate.
```

#### Notes for Stitch:
- Countdown timer phải very prominent và update real-time
- Animation phải smooth và reassuring (không stressful)
- Status messages phải update để show progress
- Guarantee badge critical để reduce anxiety về 500K payment
- Cancel option phải available nhưng not prominent
- Color coding cho countdown: green → amber → red theo thời gian

---

### Screen 7.8: Live Video Consultation with Expert

#### Thông tin màn hình:
- **Tên:** Màn hình tư vấn video trực tiếp với chuyên gia
- **Mục đích:** Video call interface cho consultation 5-10 phút
- **Flow position:** Sau Screen 7.7 khi Expert connected
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Expert Video (Large - Primary):**
   - Full screen OR 70% screen height
   - Expert's camera feed
   - Overlay elements on video:
     - Expert name badge (top): "TS. Nguyễn Văn A" + verified badge
     - Connection quality indicator (top-right): Signal bars (green/amber/red)
     - Session timer (top-left): "05:32" elapsed time

2. **Patient Video (PIP - Picture-in-Picture):**
   - Small floating window (bottom-right corner)
   - Patient's own camera feed
   - 120px × 160px size
   - Can be dragged to different corners
   - Minimize button

3. **Control Bar (Bottom Overlay - Semi-transparent dark):**
   - 5 main controls in row:
     - Mic button (mute/unmute) - red when muted
     - Camera button (on/off) - red when off
     - Switch camera (front/back)
     - Speaker button (toggle)
     - End call button (red, requires confirmation)
   - Each button is circular with icon, 56px diameter

4. **Quick Actions Drawer (Slide up from bottom):**
   - Trigger: "⋯" button on control bar
   - Options when opened:
     - Chụp ảnh rắn/vết thương
     - Gửi ảnh cho chuyên gia
     - Xem ghi chú của chuyên gia
     - Chia sẻ vị trí
     - Danh sách bệnh viện gần

5. **Expert Notes Panel (Slide in from right):**
   - Trigger: "Ghi chú" button on control bar OR auto-show khi Expert gửi note
   - Purple tab "Ghi chú của chuyên gia" on right edge
   - Slides in 50% width:
     - Header: "Ghi chú từ TS. Nguyễn Văn A"
     - Scrollable notes area showing:
       - Timestamp + note content
       - "14:35 - Rắn lục đuôi đỏ, độc tương đối cao"
       - "14:37 - Cần đến bệnh viện trong 2 giờ"
       - "14:38 - Sưng tấy và tê là bình thường, không lo lắng"
     - Auto-save badge at bottom
     - Notes persist after call

6. **Chat Messages (Overlay - Bottom):**
   - Minimal chat bubble overlay during call
   - Expert can send quick text messages:
     - "Vui lòng chụp rõ hơn vết cắn"
     - "Hãy giữ yên và thở đều"
   - Patient can send quick replies (thumbs up, OK, etc.)
   - Shows last 2 messages only

7. **Status Indicators:**
   - Connection status badge (top center, auto-hide after 3s):
     - "Kết nối tốt" (green)
     - "Kết nối yếu" (amber)
     - "Đang kết nối lại..." (red with spinner)
   - Recording indicator: "Cuộc gọi đang được ghi lại" (small text bottom)

8. **Session Info Bar (Collapsible top banner):**
   - Swipe down to show full info:
     - Expert profile: Avatar + Name + Specialization
     - Rating: 4.9 (328 đánh giá)
     - Consultation fee: "500,000 VNĐ - Đã thanh toán"
     - Time remaining estimate: "~5 phút còn lại"

9. **Emergency Actions (Always Visible):**
   - Small floating button (top-right):
     - "SOS" - red button
     - Nếu nhấn → Confirmation: "Gọi cứu hộ ngay & kết thúc tư vấn?"

#### Stitch Prompt (English):

```
Mobile app video call screen for medical expert consultation. Professional video conference interface with medical context.

Full-screen expert video feed showing doctor in professional setting. Video has slight rounded corners (12px).

Top-left overlay on video: Timer badge "05:32" in white text on semi-transparent dark background (40% opacity black), 14pt font.

Top-center overlay: Expert name badge "TS. Nguyễn Văn A" with small blue verified checkmark icon, white text on dark semi-transparent background.

Top-right overlay: Connection quality indicator showing 3/4 signal bars in green, on dark semi-transparent background.

Bottom-right corner: Small picture-in-picture patient video window (120×160px) with rounded corners. Has small "−" minimize button in top-left corner of PIP window.

Bottom of screen: Semi-transparent dark overlay bar (60% opacity black) containing 5 circular control buttons (56px diameter each) centered horizontally with 16px spacing:
1. Microphone icon (white)
2. Camera icon (white)
3. Switch camera icon (white)
4. Speaker icon (white)
5. End call X icon (red)
6. More menu ⋯ icon (white) at far right

Right edge: Purple vertical tab "Ghi chú" (collapsed). When expanded, shows white panel sliding in from right (50% screen width) with header "Ghi chú từ TS. Nguyễn Văn A" and scrollable notes:
14:35 - Rắn lục đuôi đỏ, độc tương đối cao
14:37 - Cần đến bệnh viện trong 2 giờ
14:38 - Sưng tấy và tê là bình thường, không lo lắng

Top-center of screen: Small green badge "Kết nối tốt" in white text on dark semi-transparent background.

Bottom center above controls: Small gray text "Cuộc gọi đang được ghi lại" (12pt).

Top-right corner outside video: Small red circular floating button "SOS" (48px diameter).

Style: Professional medical video consultation interface, clean overlay design, controls accessible but not intrusive, medical emergency context, expert's video prominent, patient PIP secondary, purple accent for notes panel.
```

#### Notes for Stitch:
- Expert video phải large và clear - primary focus
- Patient PIP nhỏ và movable - không che expert
- Control bar transparent overlay - không che video
- Notes panel critical - Expert gửi instructions để Patient follow sau call
- Connection quality indicator quan trọng - nếu poor thì show warning
- SOS button phải always accessible - có thể cần gọi cứu hộ ngay
- Recording notice required cho legal compliance

---

### Screen 7.9: Consultation Complete & Payment Confirmation

#### Thông tin màn hình:
- **Tên:** Màn hình hoàn tất tư vấn và xác nhận thanh toán
- **Mục đích:** Kết thúc consultation, confirm payment released to Expert, collect rating, show recommendations
- **Flow position:** Sau Screen 7.8 khi video call ended
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - No back button (flow complete)
   - Title: "Tư vấn hoàn tất"
   - Checkmark icon

2. **Success Banner:**
   - Large green checkmark animation (plays once)
   - Main text: "Tư vấn thành công"
   - Subtitle: "Cảm ơn bạn đã sử dụng dịch vụ"

3. **Consultation Summary Card:**
   - Expert avatar + name: "TS. Nguyễn Văn A"
   - Duration: "Thời gian: 08:42"
   - Date/time: "18/12/2025 - 14:35"
   - Status badge: "Đã hoàn tất" (green)

4. **Payment Confirmation Card:**
   - Title: "Thanh toán đã xử lý"
   - Summary:
     - Tổng phí dịch vụ: 500,000 VNĐ
     - Payment method: "Ví MoMo •••• 8888"
     - Transaction ID: "#TXN-2025-12345"
     - Green checkmark: "Thanh toán thành công"

5. **Expert Recommendations Card:**
   - Title: "Khuyến nghị từ chuyên gia"
   - Expert's final notes/recommendations:
     - "Rắn lục đuôi đỏ - Độc tính trung bình"
     - "Cần đến bệnh viện trong 2 giờ để theo dõi"
     - "Mang theo ảnh rắn khi đến bệnh viện"
     - "Theo dõi triệu chứng: sưng, khó thở, buồn nôn"
   - Button: "Xem đầy đủ ghi chú" → Opens full notes

6. **Rating Section:**
   - Title: "Đánh giá chuyên gia"
   - Expert avatar (small)
   - 5 stars (large, interactive): ⭐⭐⭐⭐⭐
   - Optional comment box: "Chia sẻ trải nghiệm của bạn..." (expandable)
   - Character count: "0/500"

7. **Next Steps Card:**
   - Title: "Bước tiếp theo"
   - Recommended actions:
     - Large button: "Tìm bệnh viện gần nhất" (primary action)
     - Secondary button: "Gọi đội cứu hộ SOS" (if recommended by Expert)
     - Link: "Xem lại ghi chú tư vấn"
     - Link: "Tải xuống tóm tắt tư vấn (PDF)"

8. **Support & Receipt:**
   - Small links at bottom:
     - "Gửi hóa đơn qua email"
     - "Trung tâm hỗ trợ"
     - "Báo cáo vấn đề"

9. **Return to Emergency Flow:**
   - If Expert recommended Rescuer:
     - Large amber banner: "Chuyên gia khuyên gọi đội cứu hộ"
     - Button: "Tiếp tục gọi SOS" → Returns to Screen 8
   - If Expert said no need Rescuer:
     - Button: "Về trang chủ"

10. **Consultation Record Saved:**
    - Small info badge:
      - "Ghi chú và recording đã lưu vào hồ sơ của bạn"
      - "Xem trong Lịch sử → Tư vấn"

#### Stitch Prompt (English):

```
Mobile app consultation completion screen for medical expert service. Success confirmation with payment details and rating.

Top header: Title "Tư vấn hoàn tất" centered with green checkmark icon left side.

Large animated green checkmark at top center (128px). Below checkmark, large bold text "Tư vấn thành công" and subtitle "Cảm ơn bạn đã sử dụng dịch vụ" in gray.

White card showing expert info: Small avatar circle (48px), name "TS. Nguyễn Văn A" next to it (16pt bold). Below name:
Thời gian: 08:42
18/12/2025 - 14:35
Green badge "Đã hoàn tất"

White card titled "Thanh toán đã xử lý":
Tổng phí dịch vụ: 500,000 VNĐ (bold)
Payment method: Ví MoMo •••• 8888
Transaction ID: #TXN-2025-12345 (small gray)
Green checkmark with text "Thanh toán thành công" at bottom

White card titled "Khuyến nghị từ chuyên gia":
Rắn lục đuôi đỏ - Độc tính trung bình
Cần đến bệnh viện trong 2 giờ để theo dõi
Mang theo ảnh rắn khi đến bệnh viện
Theo dõi triệu chứng: sưng, khó thở, buồn nôn
Button below "Xem đầy đủ ghi chú" (outlined forest green)

Rating section with title "Đánh giá chuyên gia":
Small expert avatar (40px)
5 large star icons (44px each) in a row, all filled yellow ⭐⭐⭐⭐⭐
Expandable text area "Chia sẻ trải nghiệm của bạn..." with character count "0/500" below

White card titled "Bước tiếp theo":
Large forest green primary button "Tìm bệnh viện gần nhất" (60px height)
Secondary outlined red button "Gọi đội cứu hộ SOS" (52px height)
Two links below:
"Xem lại ghi chú tư vấn" (forest green)
"Tải xuống tóm tắt tư vấn (PDF)" (forest green)

Amber banner at bottom: "Chuyên gia khuyên gọi đội cứu hộ" with amber warning icon.

Bottom links in small gray text:
Gửi hóa đơn qua email
Trung tâm hỗ trợ
Báo cáo vấn đề

Small info badge at very bottom:
Ghi chú và recording đã lưu vào hồ sơ của bạn
Xem trong Lịch sử → Tư vấn

Style: Professional service completion screen, success confirmation prominent, payment transparency, expert recommendations clear, rating section friendly, next steps actionable, medical context appropriate.
```

#### Notes for Stitch:
- Success animation phải reassuring - tư vấn complete OK
- Payment confirmation đơn giản - Patient chỉ cần biết đã thanh toán thành công
- Expert recommendations là most critical - Patient cần follow
- Rating section friendly nhưng optional - không force
- Next steps depend on Expert recommendation: hospital vs rescuer vs home care
- Receipt và support links available
- Flow có thể return về Screen 8 (SOS) nếu Expert recommend rescuer

---

### Screen 8: SOS Emergency Call - Live Tracking Screen

#### Thông tin màn hình:
- **Tên:** Màn hình SOS khẩn cấp với tracking real-time
- **Mục đích:** Kết nối đội cứu hộ, chia sẻ GPS, tracking rescuer location trên map tối giản
- **Flow position:** Sau Screen 7 (Assessment) hoặc từ bất kỳ màn hình nào nhấn SOS
- **Priority:** ⭐⭐⭐
- **Design inspiration:** Tối giản như Screen 6 của Rescue Request Flow - map-centric với floating card

#### Key Components:
1. **Header (overlay trên map):**
   - Back button (white với shadow)
   - Status: "SOS ACTIVE" (red badge pulsing)
   - Timer: "05:30" elapsed time
   - Minimize button

2. **Full-Screen Map:**
   - User location marker (blue pin pulsing)
   - Rescuer location marker (green pin với avatar) - nếu đã match
   - Route line nếu rescuer đang đến (dashed orange line)
   - Optional: 1km, 3km, 5km radius circles (faded)

3. **Floating Status Card (bottom sheet - draggable):**
   - **State 1: Searching for Rescuer**
     - Animated search indicator
     - Text: "Đang tìm đội cứu hộ..." + "2 đội gần bạn"
     
   - **State 2: Rescuer Matched & On The Way**
     - Small rescuer avatar + name
     - Status badge: "Đang trên đường" (amber)
     - ETA large: "8 phút" (prominent)
     - Distance: "2.1 km"
     - Last updated: "30 giây trước"

4. **Critical Info Panel (collapsed/expandable trong card):**
   - Tap to expand, shows:
     - Snake: "Rắn hổ mang chúa"
     - Severity: "NGHIÊM TRỌNG"
     - Symptoms: "Khó thở, đau 9/10"
     - Location shared: ✓

5. **Quick Action Bar (inside floating card):**
   - 3 prominent buttons horizontal row:
     - "Gọi cứu hộ" (green outlined) - nếu đã match
     - "Gọi 115" (red outlined)
     - "Bệnh viện" (gray outlined)

6. **Emergency Guidance (collapsible):**
   - Small "Trong lúc chờ ▼" expandable section
   - When expanded: 3-4 bullet points sơ cứu

#### Stitch Prompt (English):

```
Mobile app full-screen emergency SOS tracking interface for snakebite rescue. Map-first minimalist design with red (#DC3545) emergency accents and forest green (#228B22) actions.

Full screen displays map view (light gray background with minimal street pattern). 

Map markers:
- Blue pulsing location pin "Bạn" (user) at center-bottom
- Green location pin with small circular avatar overlay "Đội cứu hộ" at top-left (if matched)
- Dashed orange route line connecting pins (if rescuer on way)
- Faint green circles showing 1km, 3km radius around user

Top overlay bar (translucent white with shadow):
- Left: White circular back button
- Center: Red pulsing badge "SOS ĐANG HOẠT ĐỘNG"
- Right side: Timer "05:30" in white/dark
- Far right: Minimize button

Bottom floating white card with rounded top corners (20px radius), shadow, draggable handle at top.

**Card Content (Rescuer Matched State):**

Top section:
- Left: Small circular rescuer avatar (40px)
- Right of avatar: Bold "Nguyễn Văn A" with amber badge "Đang trên đường"

Center section (most prominent):
- Small gray text "Sẽ đến trong"
- LARGE bold forest green text "8 phút" (36pt)
- Below: Medium gray "Cách 2.1 km"
- Bottom: Tiny gray italic "Cập nhật 30 giây trước" with refresh icon

Expandable section with gray header bar "Thông tin chi tiết ▼" (collapsed shown).

Quick action section - 3 equal-width outlined buttons horizontal:
- Green outlined button with phone icon "Gọi cứu hộ"
- Red outlined button with phone icon "Gọi 115"
- Gray outlined button with hospital icon "Bệnh viện"

Collapsible section at bottom "Trong lúc chờ ▼" (collapsed state).

**Alternative State - Searching:**
If rescuer not matched yet, center of card shows:
- Animated radar/search spinner in amber
- "Đang tìm đội cứu hộ..." bold
- "2 đội gần bạn - đang chờ phản hồi" gray
- Same 3 action buttons at bottom

Design: Map-based emergency interface, minimal UI, floating overlay controls, real-time visualization, critical info accessible but not cluttered, professional emergency app aesthetic.
```

#### Alternative Prompts for Different States:

**State 1 - Searching (no rescuer yet):**
```
Bottom card shows animated search indicator (rotating radar in amber), text "Đang tìm đội cứu hộ gần bạn..." bold. Below: "2 đội cứu hộ trong bán kính 5km" gray. Below that: "Đã chia sẻ: Vị trí GPS + Loài rắn + Triệu chứng" with green checkmarks. Same 3 action buttons at bottom. On map: only user pin visible with scanning radius circles.
```

**State 2 - Rescuer Accepted:**
```
(Current main prompt)
```

**State 3 - Rescuer Arrived:**
```
Rescuer pin overlaps user pin on map. Card shows green success badge "Đã đến!" instead of ETA. Text "Đội cứu hộ đang xử lý" bold. Status: "Đang bắt rắn - Vui lòng giữ khoảng cách an toàn". Action buttons change: "Gọi cứu hộ" stays, "Gọi 115" stays, third button becomes "Hoàn tất" (green solid).
```

#### Notes for Stitch:
- Map phải chiếm 70-80% màn hình (tối đa visual space)
- Bottom card phải có draggable handle rõ ràng
- ETA text phải LARGEST element trong card (36pt+)
- SOS badge ở top phải pulsing animation để nhấn mạnh emergency
- 3 action buttons phải equal width, touch-friendly (50px+ height)
- Expandable sections giữ info hidden mặc định để tránh clutter
- Nếu Stitch không render map → "Use simple light gray background with minimal grid, focus on pins and route"
- Color coding: Red = Emergency/115, Green = Rescuer actions, Gray = Secondary

---

### Screen 10: Emergency Service Payment & Rating Screen

#### Thông tin màn hình:
- **Tên:** Màn hình thanh toán dịch vụ cấp cứu và đánh giá
- **Mục đích:** Thanh toán 100% phí dịch vụ SAU khi hoàn tất và đánh giá đội cứu hộ
- **Flow position:** Sau khi rescuer hoàn tất xử lý (từ Screen 8 state "Completed")
- **Priority:** ⭐⭐⭐
- **Payment model:** 100% payment AFTER service (không deposit) - Emergency medical model

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Hoàn tất dịch vụ cấp cứu"
   - Status badge: "Đã xử lý xong" (green)

2. **Success Banner:**
   - Light green background (#D4EDDA)
   - Checkmark icon
   - Text: "✅ Đội cứu hộ đã hoàn tất xử lý rắn"
   - Subtext: "Cảm ơn bạn đã sử dụng SnakeAid trong tình huống khẩn cấp"

3. **Rescuer Summary Card:**
   - Small avatar + name
   - Service time: "Đã xử lý trong 25 phút"
   - Service type: "Dịch vụ SOS khẩn cấp"

4. **Service Fee Breakdown:**
   - Title: "Chi tiết thanh toán"
   - White card with pricing:
     - "Phí cứu hộ khẩn cấp SOS": 500,000 VNĐ
     - "Phí nền tảng (10%)": 50,000 VNĐ
     - "Quỹ bảo hiểm (5%)": 25,000 VNĐ
     - Divider line
     - "Tổng cộng": 575,000 VNĐ (bold, large)
   - Info note: "💡 Phí khẩn cấp SOS được thanh toán SAU để bạn tập trung vào sơ cứu"

5. **Payment Method Selection:**
   - Title: "Chọn phương thức thanh toán"
   - 4 payment cards horizontal (Momo selected, VNPay, ZaloPay, Card)
   - Can use saved payment method
   - "Sử dụng phương thức đã lưu" checkbox if available

6. **Rating Section:**
   - Title: "Đánh giá đội cứu hộ"
   - Rescuer name: "Nguyễn Văn A"
   - 5 stars (tappable, large)
   - Placeholder: "Chất lượng phục vụ của bạn như thế nào?"
   - Quick tags (optional):
     - "Nhanh chóng" "Chuyên nghiệp" "Thân thiện" "Hiệu quả"

7. **Additional Comments:**
   - Text area (optional): "Nhận xét thêm? (tùy chọn)"
   - Placeholder: "Chia sẻ trải nghiệm của bạn..."
   - Character limit: "0 / 200"

8. **Action Buttons:**
   - Large primary button (forest green): "Thanh toán 575,000 VNĐ & Gửi đánh giá"
   - Secondary text link: "Báo cáo vấn đề / Khiếu nại"

9. **Payment Security Badge:**
   - Small footer: "🔒 Thanh toán an toàn & bảo mật"

#### Stitch Prompt (English):

```
Mobile app payment and rating screen for completed emergency snake rescue service in "SnakeAid". Transaction interface with forest green (#228B22) theme.

Top nav: Back arrow left, centered title "Hoàn tất dịch vụ cấp cứu", right shows green badge "Đã xử lý xong".

Full-width success banner with light green background (#D4EDDA): Large green checkmark icon, bold text "✅ Đội cứu hộ đã hoàn tất xử lý rắn". Below, smaller gray text "Cảm ơn bạn đã sử dụng SnakeAid trong tình huống khẩn cấp".

White card with rescuer summary:
- Left: Small circular avatar (40px)
- Right of avatar: Bold "Nguyễn Văn A"
- Below: "Đã xử lý trong 25 phút" gray text
- Badge: "Dịch vụ SOS khẩn cấp" amber badge

Section titled "Chi tiết thanh toán" in bold. White card with fee breakdown:
- Line 1: "Phí cứu hộ khẩn cấp SOS" left, "500,000 VNĐ" right (dark gray)
- Line 2: "Phí nền tảng (10%)" left, "50,000 VNĐ" right (medium gray)
- Line 3: "Quỹ bảo hiểm (5%)" left, "25,000 VNĐ" right (medium gray)
- Thin divider line
- Line 4: "Tổng cộng" bold left, "575,000 VNĐ" bold large right (forest green, 24pt)

Light blue info box (#E7F3FF) with lightbulb icon: "💡 Phí khẩn cấp SOS được thanh toán SAU để bạn tập trung vào sơ cứu".

Section "Chọn phương thức thanh toán". Four equal-width payment cards horizontal:
- Momo (selected with forest green border and checkmark)
- VNPay
- ZaloPay  
- Card icon
Each card has logo placeholder and label.

Section "Đánh giá đội cứu hộ". Shows "Nguyễn Văn A" in bold. Large 5-star rating display (empty stars, tappable, yellow when selected, 40px each). Below stars, gray placeholder text "Chất lượng phục vụ của bạn như thế nào?".

Horizontal row of 4 small rounded tag buttons (light gray background, forest green border when selected):
"Nhanh chóng" "Chuyên nghiệp" "Thân thiện" "Hiệu quả"

Text area input with light gray border, rounded corners. Label "Nhận xét thêm? (tùy chọn)". Placeholder inside "Chia sẻ trải nghiệm của bạn...". Bottom-right shows character counter "0 / 200" in small gray text.

Large solid forest green button at bottom "Thanh toán 575,000 VNĐ & Gửi đánh giá" (60px height, full width).

Below button, centered gray text link "Báo cáo vấn đề / Khiếu nại".

Very bottom footer: Small gray text with lock icon "🔒 Thanh toán an toàn & bảo mật" centered.

Style: Payment and rating combined interface, post-service transaction, clear fee breakdown, rating integrated with payment, emergency service completion design.
```

#### Notes for Stitch:
- Success banner phải tạo cảm giác tích cực
- Fee breakdown phải rất clear với total amount prominent
- Star rating phải large và easy to tap (min 40px each)
- Info note giải thích tại sao thanh toán SAU
- Primary button combines payment + rating action
- Security badge builds trust

---

### Screen 11: Payment Success & Thank You Screen

#### Thông tin màn hình:
- **Tên:** Màn hình thanh toán thành công và cảm ơn
- **Mục đích:** Xác nhận payment success, show receipt, và next steps
- **Flow position:** Sau Screen 10 khi payment processed successfully
- **Priority:** ⭐⭐
- **Final step:** Kết thúc emergency flow

#### Key Components:
1. **Header:**
   - Close button (X) - exits to homepage
   - Title: "Thanh toán thành công"

2. **Success Animation/Icon:**
   - Large green checkmark (animated if possible)
   - Or success icon with celebration particles

3. **Success Message:**
   - Large text: "Cảm ơn bạn! 🙏"
   - Subtitle: "Thanh toán đã được xử lý thành công"
   - Transaction ID: "#TXN-20231217-00123"
   - Timestamp: "17/12/2025 - 14:35"

4. **Payment Summary Card:**
   - Amount paid: "575,000 VNĐ" (large, bold)
   - Payment method: "Momo" with icon
   - Status: "Đã thanh toán" (green badge)
   - Receipt: "Hóa đơn đã gửi qua email"

5. **Rating Confirmed:**
   - Small card: "Đánh giá của bạn: ⭐⭐⭐⭐⭐"
   - Text: "Cảm ơn phản hồi của bạn!"

6. **Next Steps / Recommendations:**
   - Title: "Khuyến nghị tiếp theo:"
   - Card 1: "🏥 Theo dõi sức khỏe"
     - Text: "Theo dõi các triệu chứng trong 24-48 giờ tới"
     - Button: "Xem hướng dẫn →"
   - Card 2: "📱 Lưu thông tin"
     - Text: "Đã lưu thông tin vết cắn vào hồ sơ của bạn"
     - Button: "Xem hồ sơ"

7. **Action Buttons:**
   - Primary button: "Xem lịch sử dịch vụ"
   - Secondary button: "Tải hóa đơn" (PDF)
   - Text link: "Liên hệ hỗ trợ"

8. **Return to Home:**
   - Large button: "Về trang chủ" (forest green outlined)

#### Stitch Prompt (English):

```
Mobile app payment success confirmation screen for snake rescue app "SnakeAid". Success state interface with celebration design.

Top nav: X close button on right, centered title "Thanh toán thành công".

Center top shows large animated green checkmark icon (80px) in green circle (#28A745) with light green background glow.

Large bold text below checkmark "Cảm ơn bạn!" (28pt). Below that, medium gray text "Thanh toán đã được xử lý thành công".

Two lines of small gray text:
- "Mã giao dịch: #TXN-20231217-00123"
- "Thời gian: 17/12/2025 - 14:35"

White card with subtle shadow labeled "Tóm tắt thanh toán":
- Large bold forest green amount "575,000 VNĐ" (32pt)
- Below: Row showing "Momo" text with Momo logo icon (24px)
- Small green badge "Đã thanh toán" with checkmark
- Gray text "Hóa đơn đã gửi qua email" with email icon

Small card below with light yellow background (#FFFACD):
"Đánh giá của bạn: ⭐⭐⭐⭐⭐" followed by "Cảm ơn phản hồi của bạn!" in gray.

Section titled "Khuyến nghị tiếp theo:" in bold.

Two white cards stacked vertically:

CARD 1: 
- Left: Hospital emoji icon 🏥
- Center: Bold "Theo dõi sức khỏe", below: gray text "Theo dõi các triệu chứng trong 24-48 giờ tới"
- Right: Small forest green text link "Xem hướng dẫn →"

CARD 2:
- Left: Phone emoji icon 📱  
- Center: Bold "Lưu thông tin", below: gray text "Đã lưu thông tin vết cắn vào hồ sơ của bạn"
- Right: Small forest green text link "Xem hồ sơ"

Below cards, two buttons stacked:
- Forest green outlined button "Xem lịch sử dịch vụ" (50px height)
- Gray outlined button "Tải hóa đơn" with download icon (50px height)
Small centered gray text link "Liên hệ hỗ trợ"

Large primary solid forest green button at bottom "Về trang chủ" (60px height, full width).

Style: Success confirmation design, celebration aesthetic, clear transaction details, helpful next steps, positive completion experience.
```

#### Notes for Stitch:
- Success animation/checkmark phải tạo feeling tích cực
- Transaction ID và timestamp important cho tracking
- Receipt confirmation gives reassurance
- Next steps provide value-added guidance
- "Return home" button clear exit point
- Overall tone: Celebratory but professional

---

### Screen 9: Hospital Finder Map Screen

#### Thông tin màn hình:
- **Tên:** Màn hình bản đồ tìm kiếm bệnh viện có huyết thanh kháng nọc
- **Mục đích:** Hiển thị bản đồ các cơ sở y tế gần nhất có huyết thanh, khoảng cách, và chỉ đường
- **Flow position:** Từ Homepage, Emergency Alert, hoặc Severity Assessment
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Find Hospital"
   - Filter icon (top-right): "Filter by antivenom type"

2. **Search Bar:**
   - Search input: "Search by name or location..."
   - Current location button: "Dùng vị trí của tôi"

3. **Map View:**
   - Large map area (占 50-60% screen height)
   - Map placeholder with:
     - User's location pin (blue dot)
     - Hospital markers (red cross icons) with numbers
     - Distance circles overlay
   - Zoom controls (+/- buttons)

4. **Hospital List (Bottom Sheet / Scrollable List):**
   - List of 3-4 hospitals as cards, each containing:
     
     **Card 1 (Nearest):**
     - Hospital name: "Cho Ray Hospital"
     - Distance badge: "2.3 km" (forest green circle)
     - Estimated time: "8 phút lái xe"
     - Antivenom availability:
       - "✓ King Cobra antivenom available"
       - "✓ 24/7 Emergency service"
     - Rating: "4.8 (1,234 reviews)"
     - Primary button: "Get Directions →"
     - Secondary button: "Gọi bệnh viện"
     
     **Card 2:**
     - Similar structure with different distance: "5.1 km"
     - "✓ Multiple antivenom types"
     - "⚠️ Closes at 22:00"
     
     **Card 3:**
     - Distance: "8.7 km"

5. **Quick Filters (above list):**
   - Horizontal scrollable chips:
     - "Open Now" (selected - forest green)
     - "24/7"
     - "Has Antivenom"
     - "Closest"

6. **Bottom Info Banner:**
   - Light blue background
   - Text: "💡 Tip: Call ahead to confirm antivenom availability"

#### Stitch Prompt (English):

```
Mobile app hospital finder map screen for snakebite antivenom facilities. Map-based location finder with list view.

Top nav: Back arrow left, centered title "Tìm bệnh viện", filter icon right (funnel symbol).

Below nav, search bar with light gray background, rounded corners, placeholder text "Tìm theo tên hoặc vị trí..." with search icon. Small button on right "Dùng vị trí của tôi" in forest green text.

Large map area taking up 55% of screen height. Map placeholder shown as light gray rectangle with simple illustrated elements: blue dot for user location in center, 3-4 red cross markers around it representing hospitals numbered 1-3, faint distance circles. Small zoom buttons (+/-) in bottom-right corner of map.

Below map, horizontal row of filter chips (rounded pill buttons): "Đang mở cửa" (selected, forest green background), "24/7", "Có huyết thanh", "Gần nhất" (gray outlined).

Scrollable list of hospital cards below filters. First card most prominent:

Card 1 (white background, shadow, rounded corners):
- Bold text "Bệnh viện Chợ Rẫn" (18pt)
- Distance badge top-right: green circle with "2.3 km" in white
- Gray text "8 phút lái xe"
- Two lines with green checkmarks: "✓ Có huyết thanh King Cobra" and "✓ Cấp cứu 24/7"
- Rating line: "4.8 (1,234 đánh giá)" in gray
- Two buttons horizontally aligned: Primary green "Chỉ đường →" and secondary outlined "Gọi bệnh viện"

Card 2 visible below (partial):
- "Bệnh viện Quận 10"
- "5.1 km" badge
- "✓ Nhiều loại huyết thanh"
- "⚠️ Đóng cửa lúc 22:00"

At very bottom, light blue info banner (#E3F2FD) with text "💡 Mẹo: Gọi trước để xác nhận có huyết thanh".

Style: Map-based finder interface, clear geographic context, practical travel information, hospital cards with medical facility details, professional healthcare location finder design, iOS/Android map app patterns.
```

#### Notes for Stitch:
- Map area phải đủ lớn để user see context
- Hospital cards phải có clear hierarchy (nearest first)
- Distance và time estimates prominent
- "Get Directions" button phải clear CTA
- Nếu map không render tốt → "Show simplified map mockup with location pins and distance circles"
- Antivenom availability status critical - phải rõ ràng

---

## 📊 Screen Flow Diagram

```
┌─────────────────┐
│  1. Homepage    │
└────────┬────────┘
         │ User taps "Emergency - I'm Bitten"
         ▼
┌─────────────────┐
│ 2. Emergency    │
│    Alert +      │
│    Rescuer      │
│    Finder       │
└────────┬────────┘
         │ Taps "Chụp ảnh rắn"
         ▼
┌─────────────────┐
│ 4. Snake Photo  │ ◄─── Chụp ảnh để AI phân tích
│    Capture      │
└────┬────────┬───┘
     │        │
     │        └─────────────────┐ "Tôi không có ảnh rắn"
     │                          ▼
     │                    ┌─────────────────┐
     │                    │ 4.1 Location-   │ ◄─── Fast path (80%)
     │                    │     Based       │      Rắn phổ biến
     │                    │     Selection   │      ở khu vực
     │                    └────┬─────────┬──┘
     │                         │         │
     │                         │         └──────────┐ "Không có trong list"
     │                         │ "Chọn loài"         ▼
     │                         ▼              ┌─────────────────┐
     │                    ┌─────────────────┐ │ 4.3 Visual      │ ◄─── Fallback
     │                    │ 4.2 Snake       │ │     Question-   │      (15%)
     │                    │     Confirmation│ │     naire       │      4 câu hỏi
     │                    └────┬─────────┬──┘ └────┬────────────┘
     │                         │         │         │
     │                         │         │         │ Suggest 2-3
     │     "Xác nhận"          │         │         │ species
     │                         │         │         ▼
     │                         │         │    (Back to 4.1
     │                         │         │     filtered list)
     │                         │         │
     │                         │         └─────────┐ "Không giống"
     │                         │                   ▼
     │                         │            ┌─────────────────┐
     │                         │            │ 4.4 Generic     │ ◄─── Safety net
     │                         │            │     First Aid   │      (5%)
     │                         │            │     Protocol    │      Universal
     │                         │            └─────┬───────────┘      guidelines
     │                         │                  │
     │ AI processing...        │                  │ "Tiếp tục báo cáo triệu chứng"
     ▼                         ▼                  │
┌─────────────────┐      ┌─────────────────┐    │
│ 5. AI Snake     │      │ 3. First Aid    │    │
│    Identification│◄─────│    Guide        │    │
└────────┬────────┘      │ (Species-       │    │
         │                │  Specific)      │    │
         │                └────────┬────────┘    │
         │ "Xem hướng dẫn"         │             │
         └─────────────────────────┴─────────────┘
                  │
                  │ All paths merge here
                  │
                  │ Can loop through Steps 1-4
                  │ Then taps "Tiếp tục"
                  ▼
         ┌─────────────────┐
         │ 6. Symptom      │ ◄─── Nhập triệu chứng cụ thể
         │    Input        │      (đau, sưng, tê, khó thở...)
         └────────┬────────┘
                  │ AI analyzing symptoms + snake type
                  ▼
         ┌─────────────────┐
         │ 7. Severity     │ ◄─── Đánh giá dựa trên:
         │    Assessment   │      • Loài rắn (from Screen 5/4.2)
         └────────┬────────┘      • Triệu chứng (from Screen 6)
                  │                • Thời gian
                  ▼
         ┌─────────────────┐
         │ 8. SOS          │ ◄─── Gọi cấp cứu + chia sẻ:
         │    Emergency    │      • Loài rắn đã xác định
         │    Call         │      • Mức độ nghiêm trọng
         └────────┬────────┘      • Vị trí GPS
                  │
                  ▼
         ┌─────────────────┐
         │ 9. Hospital     │ ◄─── Tìm bệnh viện có huyết thanh
         │    Finder Map   │      cho loài rắn cụ thể
         └─────────────────┘

NOTE: Screen 8 (SOS) và Screen 9 (Hospital Finder) 
đều có thể trigger từ bất kỳ màn hình nào.

---

### Alternative Flow Success Rates:

**Path 1: Photo (Screen 4 → 5)** ✅ 60% users
- AI identification with 85%+ accuracy
- Fastest and most accurate path

**Path 2: Location List (4 → 4.1 → 4.2 → 3)** ✅ 30% users  
- No photo available (rắn trốn, tối, nguy hiểm)
- Fast selection from local common species
- 2-3 taps to identify

**Path 3: Questionnaire (4 → 4.1 → 4.3 → 4.1 → 4.2 → 3)** ⚠️ 8% users
- Rare species not in location list
- 4 visual questions narrow down possibilities
- Takes 1-2 minutes longer

**Path 4: Generic Protocol (4 → 4.1 → 4.2 → 4.4 → 6 → 7 → 8)** 🚨 2% users
- Cannot identify species at all
- Use universal safe first aid guidelines
- **VẪN TIẾP TỤC thu thập triệu chứng** (Screen 6)
- Assessment dựa trên symptoms only (Screen 7)
- SOS với full symptom info cho đội cứu hộ (Screen 8)
- Better generic + full symptoms than wrong species
```

### 🎯 Key Flow Logic:

**WHY này thứ tự này?**
1. **Screen 4 (Photo) → Screen 5 (AI) TRƯỚC Screen 3 (First Aid):**
   - Xác định loài rắn TRƯỚC để biết loại nọc độc
   - Neurotoxic (hổ mang) ≠ Hemotoxic (lục đuôi đỏ)
   - Sơ cứu khác nhau hoàn toàn!

2. **Screen 3 (First Aid) sau khi biết loài:**
   - Hiển thị hướng dẫn CHUYÊN BIỆT
   - "Băng ép cho Rắn hổ mang chúa" (neurotoxin)
   - "Làm sạch vết thương cho Rắn lục" (hemotoxin)

3. **Alternative Flow (4.1 → 4.2 → 4.3 → 4.4):**
   - **4.1 Location-Based:** Fast path cho 80% cases - chọn từ rắn phổ biến
   - **4.2 Confirmation:** Double-check với 5 features để tránh sai
   - **4.3 Questionnaire:** Fallback cho rare species không có trong list
   - **4.4 Generic Protocol:** Safety net - không identify được thì dùng universal guidelines
   - **Hybrid approach** đảm bảo user LUÔN có hướng dẫn (species-specific hoặc generic)

4. **Screen 6 (Symptoms) → Screen 7 (Assessment):**
   - Kết hợp: Loài rắn (Screen 5/4.2) + Triệu chứng (Screen 6)
   - AI đánh giá chính xác hơn

**Ví dụ thực tế:**

**Happy Path (60% users):**
```
User bị cắn → Screen 2 (Alert)
           → Screen 4 (Chụp ảnh)
           → Screen 5 (AI: "Rắn hổ mang chúa - Neurotoxic")
           → Screen 3 (Sơ cứu CHUYÊN cho hổ mang chúa)
           → Screen 6 (Nhập triệu chứng: khó thở, tê)
           → Screen 7 (Assessment: NGHIÊM TRỌNG - neurotoxin spreading)
           → Screen 8 (SOS với thông tin đầy đủ)
```

**Alternative Path - No Photo (30% users):**
```
User bị cắn → Screen 2 (Alert)
           → Screen 4 (Không chụp được - rắn trốn/tối)
           → "Tôi không có ảnh rắn"
           → Screen 4.1 (Location list: Quận 1 có 6 loài phổ biến)
           → Chọn "Rắn hổ mang chúa"
           → Screen 4.2 (Confirm: 4/5 features match → Tin cậy cao)
           → "Xác nhận"
           → Screen 3 (Sơ cứu CHUYÊN cho hổ mang chúa)
           → Tiếp tục flow bình thường...
```

**Fallback Path - Rare Species (8% users):**
```
User bị cắn → Screen 4 → "Không có ảnh"
           → Screen 4.1 → "Không có trong danh sách"
           → Screen 4.3 (Questionnaire):
              • Q1: Đầu tam giác
              • Q2: Màu xanh lá
              • Q3: Hoa văn sọc ngang
              • Q4: 50cm-1m
           → AI suggest: 3 possible species
           → Back to filtered Screen 4.1
           → Chọn + Confirm
           → Screen 3 (Species-specific)
```

**Safety Net - Cannot Identify (2% users):**
```
User bị cắn → Screen 4 → "Không có ảnh"
           → Screen 4.1 → Không match
           → Screen 4.3 → Vẫn không chắc
           → Screen 4.4 (Generic Protocol):
              • Băng vừa phải (compromise)
              • Giữ ngang tim (safe cho cả 2 loại)
              • KHÔNG cắt/hút/băng garo
              • ĐẾN BỆNH VIỆN NGAY
           → "Tiếp tục báo cáo triệu chứng"
           → Screen 6 (Symptom Input - VẪN CẦN!)
              • Đau mức độ?
              • Sưng bao nhiêu?
              • Khó thở không?
              • Tê bì?
           → Screen 7 (Assessment):
              • Species: UNKNOWN
              • Symptoms: Severe pain + difficulty breathing
              • → Severity: CRITICAL
           → Screen 8 (SOS với full info):
              • "Unknown species"
              • "Severe symptoms: pain 8/10, breathing difficulty"
              • "Generic first aid applied"
              • Đội cứu hộ biết cần chuẩ���ị gì!
```

**Medical Safety Logic:**
- **80-90% cases:** Species-specific first aid (optimal treatment)
- **8-10% cases:** Narrow down via questionnaire (good enough)
- **2% cases:** Generic protocol (safe for all, not optimal but DO NO HARM)
- **0% cases:** Wrong treatment (system refuses to guess - better generic than wrong)

---

## ✅ Checklist trước khi dùng Stitch

### Chuẩn bị:
- [ ] Đã đọc kỹ prompt tiếng Anh cho từng màn hình
- [ ] Đã hiểu rõ Key Components của mỗi screen
- [ ] Đã có brand colors: Forest Green #228B22
- [ ] Đã có logo text "SnakeAid" (bold font)

### Khi sử dụng Stitch:
- [ ] Copy-paste prompt NGUYÊN VĂN vào Stitch
- [ ] Nếu kết quả không đúng → đọc Notes section để refine
- [ ] Generate từng screen một, không generate hết 9 screens cùng lúc
- [ ] Save mỗi screen với tên rõ ràng: "SnakeAid_01_Homepage.png"

### Sau khi generate:
- [ ] Check màu sắc đúng brand (Forest Green)
- [ ] Check hierarchy rõ ràng (CTA buttons prominent)
- [ ] Check readability (font size đủ lớn)
- [ ] Check touch targets (buttons min 44-50px height)

### Nếu gặp vấn đề:
- **Icons xấu/không chuyên nghiệp:** Re-prompt: "Remove all icons, use text labels only"
- **Màu sai:** "Use exactly #228B22 for forest green"
- **Layout lộn xộn:** "Increase spacing between cards, use 16px padding"
- **Text quá nhỏ:** "Increase font size to 16pt minimum for body text"

---

## 🎨 Tips cho thiết kế tiếp theo:

1. **Test với 3 screens đầu tiên** (Homepage, Emergency Alert, First Aid Guide) trước
2. **Refine prompt** dựa trên kết quả thực tế từ Stitch
3. **Maintain consistency** về spacing, colors, typography giữa các screens
4. **Document changes** nếu cần adjust prompts
5. Sau khi có 9 screens → **import vào Figma** để tạo prototype với transitions

---

## 📝 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Nov 30, 2025 | Initial creation - 9 screens with Stitch prompts | AI Assistant |
| 1.1 | Nov 30, 2025 | Moved to `/02-UI-Design/` folder (proper location) | AI Assistant |

---

**Next Steps:**
1. Copy prompts vào Stitch with Google
2. Generate từng screen
3. Review và refine nếu cần
4. Import vào Figma để tạo interactive prototype
5. Tạo UI Design doc cho các flows khác (Rescue, Expert, Admin)

---

*Document này là phần của SnakeAid Project Documentation*
*Để cập nhật hoặc feedback, liên hệ team lead*
