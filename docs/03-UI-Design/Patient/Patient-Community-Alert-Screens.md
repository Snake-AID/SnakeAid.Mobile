# PATIENT APP - COMMUNITY SNAKE ALERT SCREENS

## Thông tin tài liệu
- **Module:** Community Snake Alerts (Cảnh báo cộng đồng)
- **Mục đích:** Hiển thị bản đồ cảnh báo rắn từ cộng đồng và cho phép người dùng báo cáo khi nhìn thấy rắn
- **Entry Point:** Homepage → Grid Menu → "Cảnh báo khu vực nguy hiểm"
- **Flow:** Screen 1 (Alert Map) → Screen 2 (Report Form)
- **Priority:** ★★★ (High - Community Safety Feature)
- **Date:** December 29, 2025

---

## MỤC ĐÍCH

### Vấn đề giải quyết:
1. **Community Awareness:** Người dùng cần biết khu vực nào có nhiều rắn xuất hiện gần đây
2. **Crowdsourced Data:** Tận dụng sức mạnh cộng đồng để cập nhật thông tin real-time
3. **Prevention:** Giúp người dân tránh né các khu vực nguy hiểm
4. **Data Collection:** Thu thập dữ liệu để phân tích xu hướng, mùa vụ, hotspots

### User Stories:
- **US-01:** Là người dùng, tôi muốn xem bản đồ các điểm có rắn xuất hiện gần nhà tôi
- **US-02:** Là người dùng, tôi muốn báo cáo khi nhìn thấy rắn để cảnh báo cộng đồng
- **US-03:** Là người dùng, tôi muốn biết loài rắn nào, mức độ nguy hiểm ra sao
- **US-04:** Là người dùng, tôi muốn lọc cảnh báo theo thời gian (24h/7 ngày/30 ngày)

---

## DANH SÁCH MÀN HÌNH

### Screen 1: Community Alert Map
- **Tên:** Bản đồ cảnh báo rắn cộng đồng
- **Mục đích:** Hiển thị map với các điểm báo cáo rắn từ cộng đồng
- **Priority:** ★★★ (High)

### Screen 2: Report Snake Sighting
- **Tên:** Báo cáo nhìn thấy rắn
- **Mục đích:** Form để người dùng gửi báo cáo về rắn họ nhìn thấy
- **Priority:** ★★★ (High)

### Screen 3: Alert Detail View
- **Tên:** Chi tiết cảnh báo
- **Mục đích:** Xem thông tin đầy đủ về một báo cáo rắn từ cộng đồng
- **Priority:** ★★ (Medium)

### Screen 4: Adjust Location Map
- **Tên:** Điều chỉnh vị trí
- **Mục đích:** Chọn vị trí chính xác trên map full-screen
- **Priority:** ★★ (Medium)

### Screen 5: My Reports History
- **Tên:** Lịch sử báo cáo của tôi
- **Mục đích:** Xem lại các báo cáo đã gửi và trạng thái
- **Priority:** ★★ (Medium)

### Screen 6: Report Success
- **Tên:** Báo cáo thành công
- **Mục đích:** Xác nhận gửi báo cáo thành công và nhận điểm thưởng
- **Priority:** ★★★ (High)

---

## SCREEN 1: COMMUNITY ALERT MAP

### Thông tin màn hình:
- **Tên:** Bản đồ cảnh báo rắn cộng đồng
- **Entry:** Homepage → "Cảnh báo khu vực" grid cell (badge "3 mới")
- **Exit:** Tap marker → Alert Detail Popup | Tap Report Button → Screen 2
- **Priority:** ★★★ (High)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│ ← Cảnh báo khu vực           Filter ⋮  │ ← HEADER
├─────────────────────────────────────────┤
│ [FILTER BAR]                            │
│ [24h] [7 ngày] [30 ngày] [Tất cả]      │ ← TIME FILTER
├─────────────────────────────────────────┤
│                                         │
│          [INTERACTIVE MAP]              │
│                                         │
│   • Red Pin (Độc mạnh)                 │
│   • Orange Pin (Độc trung bình)        │
│   • Green Pin (Không độc)              │
│   • GPS User Location (blue dot)       │
│                                         │
│   [Cluster: 5 báo cáo]                 │
│                                         │
│   Zoom +/-                              │
│   My Location button                    │
│                                         │
├─────────────────────────────────────────┤
│ [STATS BAR]                             │
│ Red icon 12 Độc | Orange 8 TB | Green 5│ ← SUMMARY
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [REPORT BUTTON - STICKY BOTTOM]     │ │
│ │ "Bạn thấy rắn? Báo cáo ngay →"      │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Header Bar:
- **Background:** White #FFFFFF
- **Height:** 56px
- **Left:** Back arrow icon (24px, #333)
- **Title:** "Cảnh báo khu vực" (20pt, Bold, Forest Green #228B22)
- **Right:** Filter menu icon (3 dots, 24px, #666)
- **Border:** Bottom shadow 2px #E0E0E0

#### 2. Time Filter Bar:
- **Height:** 48px
- **Background:** White #FFFFFF
- **Layout:** Horizontal scrollable chips
- **Chips (4 options):**
  - "24 giờ qua" (Active: Green background #228B22, White text)
  - "7 ngày" (Inactive: White, Gray border #E0E0E0, Gray text #666)
  - "30 ngày" (Inactive)
  - "Tất cả" (Inactive)
- **Chip Design:**
  - Height: 36px
  - Border Radius: 18px
  - Padding: 12px 20px
  - Gap: 8px between chips
  - Font: 14pt, Semi-bold

#### 3. Interactive Map:
- **Height:** Viewport height - Header - Filter - Stats - Button (approx 60%)
- **Map Provider:** Google Maps / Mapbox
- **Zoom Level:** Default zoom to show 5km radius around user
- **User Location:**
  - Blue pulsing dot (24px)
  - Accuracy circle (semi-transparent blue)
  - "My Location" button (bottom-right, 48px, white, shadow)

#### 4. Map Markers:

**Marker Types:**

**Type 1: Độc mạnh (High Danger)**
- **Pin Color:** Red #DC3545
- **Icon:** Warning triangle (white)
- **Size:** 32px x 40px
- **Shadow:** Drop shadow for depth
- **Cluster:** If 3+ markers close → Show number badge

**Type 2: Độc trung bình (Medium Danger)**
- **Pin Color:** Amber #FFC107
- **Icon:** Warning icon (white)
- **Size:** 28px x 36px

**Type 3: Không độc (Non-venomous)**
- **Pin Color:** Green #28A745
- **Icon:** Info icon (white)
- **Size:** 24px x 32px

**Cluster Markers:**
- **When:** 3+ reports within 100m radius
- **Design:** Circle badge with count "5"
- **Color:** Gradient (Red to Orange based on danger level)
- **Size:** 48px circle
- **Text:** White, Bold, 18pt
- **Tap:** Zoom in to reveal individual markers

#### 5. Marker Tap → Detail Popup:

**Popup Design (Bottom Sheet):**
- **Height:** 240px (slides up from bottom)
- **Background:** White #FFFFFF
- **Border Radius:** 16px top corners
- **Shadow:** 0px -4px 12px rgba(0,0,0,0.1)

**Content:**
- **Photo:** 120px x 120px (top-left, rounded 12px)
  - If no photo: Placeholder with snake icon
- **Info (right of photo):**
  - Snake Name: "Rắn hổ mang chúa" (Bold, 18pt, #333)
  - Scientific: "Ophiophagus hannah" (Italic, 14pt, #999)
  - Danger Badge: Red "Độc mạnh" (12px padding, rounded 4px)
- **Meta Info:**
  - Time: "2 giờ trước" (14pt, #666)
  - Location: "123m từ vị trí của bạn" (14pt, #666)
  - Reporter: "Báo cáo bởi Nguyễn V.A" (13pt, #999)
- **Action Buttons (bottom):**
  - "Xem chi tiết" (Outlined, Green, 44px height)
  - "Đường đi tránh xa" (Solid Green, 44px height)

#### 6. Stats Summary Bar:
- **Position:** Above Report Button (sticky)
- **Height:** 56px
- **Background:** Light Gray #F8F9FA
- **Border:** Top 1px #E0E0E0
- **Content:** Horizontal layout (3 segments)

**Segment 1: Độc mạnh**
- Icon: Red danger icon (20px)
- Count: "12" (Bold, 20pt, Red #DC3545)
- Label: "Độc" (12pt, #666)

**Segment 2: Trung bình**
- Icon: Orange warning icon (20px)
- Count: "8" (Bold, 20pt, Amber #FFC107)
- Label: "T.Bình" (12pt, #666)

**Segment 3: Không độc**
- Icon: Green info icon (20px)
- Count: "5" (Bold, 20pt, Green #28A745)
- Label: "An toàn" (12pt, #666)

**Separator:** Vertical line 1px #E0E0E0 between segments

#### 7. Report Button (Sticky Bottom):
- **Height:** 64px
- **Background:** Forest Green #228B22
- **Text:** "Bạn thấy rắn? Báo cáo ngay →" (White, Bold, 18pt)
- **Icon:** Camera icon (left, white, 24px)
- **Border Radius:** 0px (full width)
- **Shadow:** 0px -2px 8px rgba(0,0,0,0.12)
- **Interaction:** Tap → Navigate to Screen 2 (Report Form)

---

## SCREEN 2: REPORT SNAKE SIGHTING

### Thông tin màn hình:
- **Tên:** Báo cáo nhìn thấy rắn
- **Entry:** Screen 1 → Tap "Báo cáo ngay" button
- **Exit:** Submit → Success message → Back to Screen 1 (with new marker)
- **Priority:** ★★★ (High)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│ ← Báo cáo nhìn thấy rắn          ✕     │ ← HEADER
├─────────────────────────────────────────┤
│ [SCROLLABLE FORM]                       │
│                                         │
│ 1. VỊ TRÍ NHÌN THẤY                    │
│ ┌─────────────────────────────────────┐ │
│ │ [Mini Map Preview]                  │ │
│ │ GPS: 21.0285, 105.8542             │ │
│ │ Địa chỉ: Đống Đa, Hà Nội           │ │
│ │ [Điều chỉnh vị trí →]              │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 2. THỜI GIAN NHÌN THẤY                 │
│ [Vừa xong] [1h trước] [Hôm nay] [Khác] │
│                                         │
│ 3. THÔNG TIN RẮN                       │
│ ┌─────────────────────────────────────┐ │
│ │ Chọn loài rắn (nếu biết)           │ │
│ │ [Dropdown: Tìm kiếm...]             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Kích thước (ước tính)              │ │
│ │ ○ Nhỏ (<50cm)  ○ Trung (50-150cm) │ │
│ │ ○ Lớn (>150cm) ○ Không rõ          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Màu sắc chủ đạo (tùy chọn)         │ │
│ │ □ Nâu □ Đen □ Xanh □ Vàng □ Khác   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 4. HÌNH ẢNH (Tùy chọn)                 │
│ ┌───────┐ ┌───────┐ ┌───────┐         │
│ │ [+]   │ │       │ │       │ ← Max 3 │
│ │ Thêm  │ │       │ │       │   ảnh   │
│ └───────┘ └───────┘ └───────┘         │
│                                         │
│ 5. MÔ TẢ THÊM (Tùy chọn)              │
│ ┌─────────────────────────────────────┐ │
│ │ VD: "Rắn đang trên cây cao 2m,     │ │
│ │      gần ao..."                     │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Checkbox] Ẩn danh (không hiện tên tôi)│
│                                         │
├─────────────────────────────────────────┤
│ [GỬI BÁO CÁO - BUTTON]                 │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Header Bar:
- **Background:** White #FFFFFF
- **Height:** 56px
- **Left:** Back arrow (24px, #333)
- **Title:** "Báo cáo nhìn thấy rắn" (20pt, Bold, #333)
- **Right:** Close icon ✕ (24px, #666)
- **Border:** Bottom 1px #E0E0E0

#### 2. Section 1: Vị trí nhìn thấy

**Mini Map Preview:**
- **Height:** 180px
- **Background:** Light Gray #F8F9FA
- **Border:** 1px solid #E0E0E0
- **Border Radius:** 12px
- **Content:**
  - Small static map image showing user location
  - Red marker at selected position
  - Zoom level: 15 (street level)

**GPS Coordinates:**
- Text: "GPS: 21.0285, 105.8542" (14pt, Monospace, #666)
- Icon: Location pin (16px, Forest Green)

**Address:**
- Text: "Địa chỉ: Đống Đa, Hà Nội" (14pt, #333)
- Auto-detected via reverse geocoding

**Adjust Button:**
- Text: "Điều chỉnh vị trí →" (14pt, Forest Green, Semi-bold)
- Tap: Open full-screen map to drag pin

#### 3. Section 2: Thời gian nhìn thấy

**Time Chips (Horizontal):**
- Layout: 4 chips, same design as Screen 1
- Options:
  - "Vừa xong" (Active by default)
  - "1 giờ trước"
  - "Hôm nay (sáng/chiều)"
  - "Khác" (Opens datetime picker)

#### 4. Section 3: Thông tin rắn

**Field 1: Chọn loài rắn**
- **Type:** Searchable Dropdown
- **Height:** 56px
- **Background:** White #FFFFFF
- **Border:** 1px solid #E0E0E0
- **Border Radius:** 12px
- **Placeholder:** "Tìm kiếm loài rắn..." (Gray #999)
- **Icon:** Search icon (left, 20px)
- **Interaction:**
  - Tap: Opens searchable list (250+ species)
  - Auto-complete while typing
  - Shows thumbnails + Vietnamese name + Scientific name
  - Option: "Không biết loài" (default)

**Field 2: Kích thước (Radio buttons)**
- **Layout:** 4 radio buttons horizontal
- **Options:**
  - "Nhỏ (<50cm)" - Snake illustration 30px
  - "Trung (50-150cm)" - Snake illustration 50px
  - "Lớn (>150cm)" - Snake illustration 70px
  - "Không rõ" - Question mark icon

**Radio Design:**
- **Circle:** 24px diameter
- **Active:** Green filled #228B22
- **Inactive:** White with Gray border #E0E0E0
- **Text:** 15pt, #333

**Field 3: Màu sắc (Checkboxes - Multi-select)**
- **Layout:** Horizontal wrap (5 checkboxes)
- **Options:**
  - "Nâu" (Brown square 32px)
  - "Đen" (Black square 32px)
  - "Xanh lá" (Green square 32px)
  - "Vàng" (Yellow square 32px)
  - "Khác" (Gradient square 32px)

**Checkbox Design:**
- **Size:** 24px
- **Active:** Green checkmark #228B22
- **Inactive:** White with Gray border
- **Label:** 14pt, #333

#### 5. Section 4: Hình ảnh (Tùy chọn)

**Photo Upload:**
- **Layout:** Horizontal 3 slots
- **Slot Design:**
  - Size: 100px x 100px
  - Border: 2px dashed #E0E0E0
  - Border Radius: 12px
  - Background: Light Gray #F8F9FA

**Slot 1 (Empty):**
- Icon: Plus sign (+) (36px, Gray #666)
- Text: "Thêm ảnh" (12pt, Gray #999)
- Tap: Open Camera / Gallery picker

**Slot 2, 3 (After upload):**
- Display thumbnail
- Delete icon (X) top-right corner (white circle, red X)

**Image Requirements:**
- Max 3 photos
- Max size: 5MB per photo
- Formats: JPG, PNG
- Auto-compress to 1080px width

#### 6. Section 5: Mô tả thêm (Tùy chọn)

**Text Area:**
- **Height:** 120px (expandable)
- **Background:** White #FFFFFF
- **Border:** 1px solid #E0E0E0
- **Border Radius:** 12px
- **Padding:** 16px
- **Placeholder:** "VD: Rắn đang trên cây cao 2m, gần ao, trông giống rắn lục..."
- **Max Length:** 500 characters
- **Character Count:** Bottom-right (14pt, Gray)

#### 7. Privacy Option:

**Checkbox:**
- **Layout:** Checkbox + Text
- **Checkbox Size:** 24px
- **Text:** "Ẩn danh (không hiện tên tôi trong báo cáo)" (14pt, #666)
- **Background:** Light Yellow #FFF9E6 (highlight privacy)
- **Padding:** 16px
- **Border Radius:** 8px

#### 8. Submit Button (Fixed Bottom):

**Button Design:**
- **Width:** Full width (minus 20px padding each side)
- **Height:** 56px
- **Background:** Forest Green #228B22
- **Text:** "GỬI BÁO CÁO" (White, Bold, 18pt)
- **Icon:** Send icon (right, white, 20px)
- **Border Radius:** 12px
- **Shadow:** 0px 4px 12px rgba(34,139,34,0.3)
- **Disabled State:** Gray #CCCCCC (when required fields empty)

**Required Fields:**
- Vị trí (auto-filled GPS)
- Thời gian (default "Vừa xong")
- At least one size selected OR species selected

**Loading State:**
- Show spinner (24px) replacing send icon
- Text: "Đang gửi..."
- Disable button during submission

---

## SCREEN 3: ALERT DETAIL VIEW

### Thông tin màn hình:
- **Tên:** Chi tiết cảnh báo
- **Entry:** Screen 1 → Tap marker → Tap "Xem chi tiết" button
- **Exit:** Back → Screen 1 | "Gọi cứu hộ" → Rescue Request Flow
- **Priority:** ★★ (Medium)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│ ← Chi tiết cảnh báo          Share ⋯   │ ← HEADER
├─────────────────────────────────────────┤
│ [SCROLLABLE CONTENT]                    │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [PHOTO GALLERY - Swipeable]         │ │
│ │ [Photo 1/3]                         │ │
│ │ ○ ○ ● (indicators)                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ VERIFICATION BADGE                      │
│ [Checkmark] Đã xác minh bởi Chuyên gia │
│                                         │
│ SNAKE INFORMATION                       │
│ Rắn hổ mang chúa                       │
│ Ophiophagus hannah                      │
│ [Red Badge: Độc mạnh]                  │
│                                         │
│ LOCATION & TIME                         │
│ [Pin icon] 123m từ vị trí của bạn      │
│ Đường Láng, Đống Đa, Hà Nội            │
│ [Clock] 2 giờ trước (29/12/2025 14:30) │
│                                         │
│ DETAILS CARD                            │
│ ┌─────────────────────────────────────┐ │
│ │ Kích thước: Lớn (>150cm)           │ │
│ │ Màu sắc: Nâu, Vàng                 │ │
│ │ Trạng thái: Đang di chuyển         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ DESCRIPTION                             │
│ "Rắn đang trên cây cao 2m, gần ao.     │
│  Có vẻ đang tìm mồi. Cẩn thận!"        │
│                                         │
│ REPORTER INFO                           │
│ Báo cáo bởi: Nguyễn Văn A              │
│ [Avatar] Cộng đồng tích cực (120đ)     │
│                                         │
│ MAP PREVIEW                             │
│ ┌─────────────────────────────────────┐ │
│ │ [Static Map with Marker]            │ │
│ │ [Xem bản đồ lớn hơn →]             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ HELPFUL SECTION                         │
│ Thông tin này có hữu ích?              │
│ [Thumbs Up: 12] [Thumbs Down: 1]      │
│                                         │
│ RELATED ALERTS                          │
│ 3 báo cáo khác gần đây (bán kính 500m)│
│ [Mini cards...]                         │
│                                         │
├─────────────────────────────────────────┤
│ [BOTTOM ACTION BAR]                     │
│ [Đường đi tránh xa] [Gọi cứu hộ]      │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Header Bar:
- **Background:** White #FFFFFF
- **Height:** 56px
- **Left:** Back arrow (24px, #333)
- **Title:** "Chi tiết cảnh báo" (20pt, Bold, #333)
- **Right:** Share icon (24px, #666) → Share to contacts/social
- **Border:** Bottom 1px #E0E0E0

#### 2. Photo Gallery:
- **Height:** 300px
- **Background:** Black #000000
- **Layout:** Horizontal swipeable carousel
- **Photos:** Up to 3 images, swipe left/right
- **Indicators:** Dots below (8px diameter)
  - Active: White filled
  - Inactive: White outline
- **Zoom:** Tap to zoom in/pan
- **Placeholder:** If no photos → Gray placeholder with snake icon

#### 3. Verification Badge:
- **Background:** Light Green #E8F5E9
- **Border:** 1px solid #4CAF50
- **Height:** 40px
- **Border Radius:** 8px
- **Icon:** Green checkmark (20px)
- **Text:** "Đã xác minh bởi Chuyên gia" (14pt, Green #4CAF50, Semi-bold)
- **If unverified:** Orange background "Chờ xác minh"

#### 4. Snake Information:
- **Vietnamese Name:** "Rắn hổ mang chúa" (24pt, Bold, #333)
- **Scientific Name:** "Ophiophagus hannah" (16pt, Italic, #999)
- **Danger Badge:**
  - Red "Độc mạnh" OR Orange "Độc trung bình" OR Green "Không độc"
  - Height: 28px, Border Radius: 4px, Padding: 6px 12px
  - Bold 14pt text, white

#### 5. Location & Time Card:
- **Background:** Light Gray #F8F9FA
- **Border Radius:** 12px
- **Padding:** 16px
- **Row 1:** Distance from user
  - Icon: Location pin (16px, Forest Green)
  - Text: "123m từ vị trí của bạn" (16pt, #333, Bold)
- **Row 2:** Full address
  - Text: "Đường Láng, Đống Đa, Hà Nội" (14pt, #666)
- **Row 3:** Time
  - Icon: Clock (16px, Gray)
  - Text: "2 giờ trước (29/12/2025 14:30)" (14pt, #999)

#### 6. Details Card:
- **Background:** White #FFFFFF
- **Border:** 1px solid #E0E0E0
- **Border Radius:** 12px
- **Padding:** 16px
- **Rows:**
  - **Kích thước:** "Lớn (>150cm)" (14pt, #333)
  - **Màu sắc:** "Nâu, Vàng" (14pt, #333) with color squares
  - **Trạng thái:** "Đang di chuyển" (14pt, #333)
- **Separator:** 1px Gray line between rows

#### 7. Description:
- **Background:** Light Blue #F0F8FF
- **Border Radius:** 12px
- **Padding:** 16px
- **Text:** 16pt, #333, line height 1.5
- **Max Height:** 200px (scroll if longer)

#### 8. Reporter Info:
- **Layout:** Horizontal (Avatar + Info)
- **Avatar:** 48px circle, left
- **Name:** "Nguyễn Văn A" (16pt, Bold, #333)
  - If anonymous: "Người dùng ẩn danh" + default avatar
- **Badge:** "Cộng đồng tích cực (120đ)" (12pt, Amber, badge icon)
- **Tap:** View reporter profile (if not anonymous)

#### 9. Map Preview:
- **Height:** 200px
- **Static Image:** Google Maps static image with marker
- **Border Radius:** 12px
- **Overlay Button:** "Xem bản đồ lớn hơn →"
  - Bottom-right, semi-transparent white background
  - Tap: Open Google Maps / Apple Maps with directions

#### 10. Helpful Section:
- **Question:** "Thông tin này có hữu ích?" (16pt, Bold, #333)
- **Buttons:** Horizontal layout
  - **Thumbs Up:** Icon (24px) + Count "12" (Green text)
  - **Thumbs Down:** Icon (24px) + Count "1" (Red text)
  - Active state: Filled icon
- **Purpose:** Community feedback, helps ranking

#### 11. Related Alerts:
- **Title:** "3 báo cáo khác gần đây (bán kính 500m)" (14pt, Bold, #666)
- **Cards:** Horizontal scrollable mini cards (140px width)
  - Thumbnail 60px x 60px
  - Snake name (12pt)
  - Distance (11pt, gray)
  - Time (11pt, gray)
- **Tap:** Navigate to that alert detail

#### 12. Bottom Action Bar:
- **Height:** 72px
- **Background:** White #FFFFFF
- **Shadow:** Top 0px -2px 8px rgba(0,0,0,0.1)
- **Buttons:** 2 equal width (gap 12px, side padding 16px)

**Button 1: Đường đi tránh xa**
- **Background:** White #FFFFFF
- **Border:** 2px solid Forest Green #228B22
- **Text:** "Đường đi tránh xa" (Green, Bold, 16pt)
- **Icon:** Navigation icon (Green)
- **Tap:** Open Google Maps with "Avoid this area" route

**Button 2: Gọi cứu hộ**
- **Background:** Forest Green #228B22
- **Text:** "Gọi cứu hộ" (White, Bold, 16pt)
- **Icon:** Phone icon (White)
- **Tap:** Navigate to Rescue Request Flow (pre-filled species + location)

---

## SCREEN 4: ADJUST LOCATION MAP

### Thông tin màn hình:
- **Tên:** Điều chỉnh vị trí
- **Entry:** Screen 2 → Tap "Điều chỉnh vị trí →" link
- **Exit:** Confirm → Back to Screen 2 with updated location
- **Priority:** ★★ (Medium)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│ ✕ Điều chỉnh vị trí          Xong     │ ← HEADER
├─────────────────────────────────────────┤
│                                         │
│                                         │
│         [FULL SCREEN MAP]               │
│                                         │
│         [Center Pin - Fixed]            │
│         [Red Marker Icon]               │
│                                         │
│         User can drag map               │
│         Pin stays centered              │
│                                         │
│         [My Location button]            │
│         [Zoom +/-]                      │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│ [BOTTOM INFO CARD - Draggable]         │
│ ┌─────────────────────────────────────┐ │
│ │ [Drag Handle]                       │ │
│ │                                     │ │
│ │ Vị trí đã chọn:                    │ │
│ │ Đường Láng, Đống Đa, Hà Nội        │ │
│ │ GPS: 21.0285, 105.8542             │ │
│ │                                     │ │
│ │ [XÁC NHẬN VỊ TRÍ - Button]         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Header Bar:
- **Background:** White #FFFFFF
- **Height:** 56px
- **Left:** Close icon ✕ (24px, #333)
- **Title:** "Điều chỉnh vị trí" (20pt, Bold, #333)
- **Right:** "Xong" text button (Green #228B22, 16pt)
- **Shadow:** Bottom 2px #E0E0E0

#### 2. Full Screen Map:
- **Height:** Full viewport minus header minus bottom card
- **Map Provider:** Google Maps / Mapbox
- **Interaction:** Draggable, zoomable
- **User Location:** Blue pulsing dot (24px)

#### 3. Fixed Center Pin:
- **Position:** Absolute center of screen
- **Icon:** Red location pin (48px x 60px)
- **Shadow:** Drop shadow for depth
- **Behavior:** Pin stays fixed while map moves underneath
- **Purpose:** User drags map to position pin at desired location

#### 4. Map Controls:
- **My Location Button:**
  - Position: Bottom-right (16px from edges)
  - Size: 48px circle
  - Background: White, shadow
  - Icon: Crosshair (24px, Gray)
  - Tap: Re-center map to user GPS

- **Zoom Controls:**
  - Position: Right side (16px from edge)
  - Size: 40px circles
  - Background: White, shadow
  - Icons: Plus/Minus (20px, Gray)

#### 5. Bottom Info Card:
- **Background:** White #FFFFFF
- **Height:** 180px (draggable to expand)
- **Border Radius:** 16px top corners
- **Shadow:** 0px -4px 12px rgba(0,0,0,0.15)
- **Padding:** 20px

**Drag Handle:**
- Horizontal gray line (40px width, 4px height)
- Centered at top
- User can drag down to minimize, up to expand

**Content:**
- **Label:** "Vị trí đã chọn:" (14pt, Bold, #666)
- **Address:** Auto-updated as map moves
  - "Đường Láng, Đống Đa, Hà Nội" (16pt, #333)
  - Loading spinner if geocoding
- **GPS:** "GPS: 21.0285, 105.8542" (14pt, Monospace, #999)

**Confirm Button:**
- **Width:** Full width
- **Height:** 56px
- **Background:** Forest Green #228B22
- **Text:** "XÁC NHẬN VỊ TRÍ" (White, Bold, 18pt)
- **Border Radius:** 12px
- **Tap:** Save location → Navigate back to Screen 2

#### 6. Interaction Flow:
1. Screen loads with user's current GPS location
2. User drags map to adjust position
3. Address auto-updates via reverse geocoding
4. Tap "XÁC NHẬN VỊ TRÍ" to save
5. Return to Screen 2 with new lat/lng + address

---

## SCREEN 5: MY REPORTS HISTORY

### Thông tin màn hình:
- **Tên:** Lịch sử báo cáo của tôi
- **Entry:** Profile Menu → "Báo cáo của tôi" OR Screen 1 Filter Menu → "Báo cáo của tôi"
- **Exit:** Tap report → Screen 3 (Alert Detail)
- **Priority:** ★★ (Medium)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│ ← Báo cáo của tôi            Filter ⋮  │ ← HEADER
├─────────────────────────────────────────┤
│ [STATS SUMMARY]                         │
│ ┌───────────┬───────────┬───────────┐  │
│ │ Tổng: 15  │ Xác minh  │ Chờ duyệt │  │
│ │           │    12     │     3     │  │
│ └───────────┴───────────┴───────────┘  │
├─────────────────────────────────────────┤
│ [TAB BAR]                               │
│ [Tất cả] [Đã duyệt] [Chờ] [Từ chối]   │
├─────────────────────────────────────────┤
│ [SCROLLABLE LIST]                       │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Thumbnail]  Rắn hổ mang chúa      │ │
│ │              [Green Badge: Đã XM]   │ │
│ │              123m • 2 giờ trước     │ │
│ │              +10 điểm • 12 helpful  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Thumbnail]  Rắn lục đuôi đỏ       │ │
│ │              [Orange: Chờ XM]       │ │
│ │              456m • 1 ngày trước    │ │
│ │              Chờ chuyên gia...      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [No Photo]   Không rõ loài         │ │
│ │              [Red: Từ chối]         │ │
│ │              2 ngày trước            │ │
│ │              Lý do: Ảnh mờ          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ... (more reports)                      │
│                                         │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Header Bar:
- **Background:** White #FFFFFF
- **Height:** 56px
- **Left:** Back arrow (24px, #333)
- **Title:** "Báo cáo của tôi" (20pt, Bold, Forest Green #228B22)
- **Right:** Filter icon (3 dots, 24px, #666)
  - Tap: Open filter (by date, species, status)
- **Border:** Bottom shadow 2px #E0E0E0

#### 2. Stats Summary:
- **Background:** Light Green #E8F5E9
- **Height:** 80px
- **Layout:** 3 columns, equal width

**Column 1: Tổng**
- Number: "15" (28pt, Bold, #333)
- Label: "Tổng báo cáo" (12pt, #666)

**Column 2: Xác minh**
- Number: "12" (28pt, Bold, Green #4CAF50)
- Label: "Đã xác minh" (12pt, #666)

**Column 3: Chờ duyệt**
- Number: "3" (28pt, Bold, Amber #FFC107)
- Label: "Chờ duyệt" (12pt, #666)

**Separator:** Vertical line 1px #E0E0E0 between columns

#### 3. Tab Bar:
- **Height:** 48px
- **Background:** White #FFFFFF
- **Layout:** 4 tabs, horizontal scrollable
- **Tabs:**
  - "Tất cả" (Active by default)
  - "Đã duyệt" (Verified reports only)
  - "Chờ" (Pending reports)
  - "Từ chối" (Rejected reports)

**Tab Design:**
- **Active:** Green underline 3px, Green text #228B22, Bold
- **Inactive:** Gray text #999, Regular
- **Font:** 16pt

#### 4. Report List:
- **Background:** White #FFFFFF
- **Layout:** Vertical list, scrollable
- **Card Design:**
  - Height: 100px
  - Padding: 12px
  - Border Bottom: 1px #F0F0F0
  - Tap: Navigate to Screen 3 (Alert Detail)

**Each Report Card:**

**Left: Thumbnail**
- Size: 80px x 80px
- Border Radius: 12px
- If no photo: Gray placeholder with snake icon

**Right: Info (flex grow)**
- **Snake Name:** "Rắn hổ mang chúa" (16pt, Bold, #333)
  - If unknown: "Không rõ loài" (Italic, Gray)
- **Status Badge:**
  - Green "Đã xác minh" (verified)
  - Orange "Chờ xác minh" (pending)
  - Red "Từ chối" (rejected)
  - Badge: 6px padding, rounded 4px, 12pt text
- **Meta Info:** (14pt, #666)
  - Distance OR Location name
  - Time: "2 giờ trước" / "1 ngày trước"
- **Points/Engagement:**
  - If verified: "+10 điểm • 12 helpful" (Green, 13pt)
  - If pending: "Chờ chuyên gia xác minh..." (Orange, 13pt)
  - If rejected: "Lý do: Ảnh mờ, không rõ" (Red, 13pt)

**Swipe Actions:**
- **Swipe Left:** Reveal "Xóa" button (Red)
- **Swipe Right:** Reveal "Chỉnh sửa" button (Blue) - only for pending

#### 5. Empty State:
- **Icon:** Empty box illustration (120px)
- **Title:** "Chưa có báo cáo nào" (20pt, Bold, #666)
- **Message:** "Hãy bắt đầu giúp cộng đồng bằng cách báo cáo khi nhìn thấy rắn!" (16pt, #999)
- **Button:** "Báo cáo ngay" (Green solid, 48px) → Navigate to Screen 2

---

## SCREEN 6: REPORT SUCCESS

### Thông tin màn hình:
- **Tên:** Báo cáo thành công
- **Entry:** Screen 2 → Submit success
- **Exit:** "Xem trên bản đồ" → Screen 1 OR "Đóng" → Back to previous
- **Priority:** ★★★ (High)

### LAYOUT STRUCTURE:

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│         [SUCCESS ANIMATION]             │
│         [Green Checkmark Circle]        │
│         (120px, animated)               │
│                                         │
│         Báo cáo thành công!             │
│                                         │
│         Cảm ơn bạn đã giúp cộng đồng   │
│         an toàn hơn                     │
│                                         │
├─────────────────────────────────────────┤
│ [REWARDS CARD]                          │
│ ┌─────────────────────────────────────┐ │
│ │ BẠN ĐÃ NHẬN ĐƯỢC:                  │ │
│ │                                     │ │
│ │ [Trophy] +10 điểm cộng đồng        │ │
│ │ [Star] +5 điểm (có ảnh)            │ │
│ │ [Medal] Đầu tiên ở khu vực +15     │ │
│ │                                     │ │
│ │ TỔNG: +30 điểm                     │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ [WHAT'S NEXT CARD]                      │
│ ┌─────────────────────────────────────┐ │
│ │ TIẾP THEO:                         │ │
│ │ • Chuyên gia sẽ xác minh trong 24h │ │
│ │ • Báo cáo sẽ hiện trên bản đồ      │ │
│ │ • Bạn nhận thông báo khi xác minh  │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ [QUICK PREVIEW]                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Mini Map Preview]                  │ │
│ │ Vị trí báo cáo của bạn             │ │
│ │ Đường Láng, Đống Đa, HN            │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│                                         │
│ [XEM TRÊN BẢN ĐỒ - Primary Button]    │
│                                         │
│ [VỀ TRANG CHỦ - Secondary Button]      │
│                                         │
│         [Đóng - Text Link]              │
│                                         │
└─────────────────────────────────────────┘
```

### Key Components:

#### 1. Success Animation:
- **Position:** Top center (80px from top)
- **Icon:** Green checkmark in circle
  - Circle: 120px diameter, Green #4CAF50
  - Checkmark: White, 60px, Bold stroke
- **Animation:** 
  - Scale up from 0.5 to 1.0 (0.3s ease-out)
  - Checkmark draws in (0.4s delay)
  - Subtle bounce at end

#### 2. Success Message:
- **Title:** "Báo cáo thành công!" (28pt, Bold, Forest Green #228B22)
  - Position: Below animation (24px gap)
- **Subtitle:** "Cảm ơn bạn đã giúp cộng đồng an toàn hơn" (18pt, #666)
  - Position: Below title (12px gap)
  - Max width: 80% screen
  - Centered, line height 1.4

#### 3. Rewards Card:
- **Background:** Light Amber #FFF9E6
- **Border:** 2px solid Amber #FFC107
- **Border Radius:** 16px
- **Padding:** 24px
- **Margin:** 32px from message

**Header:**
- Text: "BẠN ĐÃ NHẬN ĐƯỢC:" (14pt, Bold, Amber #FF8F00)

**Rewards List:**
- **Row 1:** Trophy icon (24px) + "+10 điểm cộng đồng" (16pt, #333)
- **Row 2:** Star icon (24px) + "+5 điểm (có ảnh)" (16pt, #333)
- **Row 3:** Medal icon (24px) + "Đầu tiên ở khu vực +15" (16pt, #333)
  - Only show if applicable (first report in area)
- **Gap:** 12px between rows

**Total:**
- **Separator:** 1px dashed Amber line
- **Text:** "TỔNG: +30 điểm" (20pt, Bold, Amber #FF8F00)
- **Background:** Light gradient (subtle highlight)

#### 4. What's Next Card:
- **Background:** Light Blue #E7F3FF
- **Border:** 1px solid Blue #007BFF
- **Border Radius:** 12px
- **Padding:** 20px
- **Margin:** 20px from rewards card

**Header:**
- Text: "TIẾP THEO:" (14pt, Bold, Blue #007BFF)

**Steps List:**
- **Bullet points (•):**
  - "Chuyên gia sẽ xác minh trong 24h" (15pt, #333)
  - "Báo cáo sẽ hiện trên bản đồ" (15pt, #333)
  - "Bạn nhận thông báo khi xác minh" (15pt, #333)
- **Icon:** Info icon (16px) next to each line
- **Gap:** 10px between lines

#### 5. Quick Preview Card:
- **Background:** White #FFFFFF
- **Border:** 1px solid #E0E0E0
- **Border Radius:** 12px
- **Padding:** 16px
- **Margin:** 20px from previous card

**Mini Map:**
- Height: 150px
- Static map image with red marker
- Border Radius: 8px

**Location Text:**
- "Vị trí báo cáo của bạn" (14pt, Bold, #666)
- "Đường Láng, Đống Đa, HN" (16pt, #333)

#### 6. Action Buttons:

**Primary Button: Xem trên bản đồ**
- **Width:** Full width (minus 32px margin each side)
- **Height:** 56px
- **Background:** Forest Green #228B22
- **Text:** "XEM TRÊN BẢN ĐỒ" (White, Bold, 18pt)
- **Icon:** Map icon (right, white, 20px)
- **Border Radius:** 12px
- **Shadow:** 0px 4px 12px rgba(34,139,34,0.3)
- **Margin:** 24px from preview card
- **Tap:** Navigate to Screen 1 (Map) with new marker highlighted

**Secondary Button: Về trang chủ**
- **Width:** Full width
- **Height:** 52px
- **Background:** White #FFFFFF
- **Border:** 2px solid Forest Green #228B22
- **Text:** "VỀ TRANG CHỦ" (Green, Bold, 17pt)
- **Border Radius:** 12px
- **Margin:** 12px from primary button
- **Tap:** Navigate to Homepage

**Text Link: Đóng**
- **Position:** Below secondary button (16px gap)
- **Text:** "Đóng" (16pt, Gray #999, Underline)
- **Tap:** Dismiss screen, return to previous

#### 7. Confetti Animation (Optional):
- **Trigger:** On screen load
- **Effect:** Colorful confetti falling from top
- **Duration:** 2 seconds
- **Colors:** Green, Amber, Blue (matching theme)

---

## SUCCESS CONFIRMATION

### After Submit Success:

**Success Modal (Overlay):**
- **Background:** Semi-transparent Black #00000080
- **Modal Size:** 320px x 280px (center screen)
- **Background:** White #FFFFFF
- **Border Radius:** 16px

**Content:**
- **Icon:** Green checkmark circle (80px)
- **Title:** "Báo cáo thành công!" (24pt, Bold, Forest Green)
- **Message:** "Cảm ơn bạn đã giúp cộng đồng an toàn hơn. Báo cáo của bạn đã được ghi nhận." (16pt, #666)
- **Points Badge:** "+10 điểm cộng đồng" (Amber badge)
- **Button:** "Xem trên bản đồ" (Green solid, 48px)
- **Close:** "Đóng" (Gray text, bottom)

**Auto Actions:**
- Show modal for 3 seconds
- Auto-close or tap "Xem trên bản đồ" → Navigate to Screen 1
- New marker appears on map with "MỚI" badge (24h)

---

## VALIDATION RULES

### Form Validation:

**Required Fields:**
1. Vị trí (GPS) - Auto-filled, can adjust
2. Thời gian - Default "Vừa xong"
3. Kích thước HOẶC Loài rắn - At least one must be filled

**Optional Fields:**
- Loài rắn (có thể "Không biết")
- Màu sắc
- Hình ảnh (khuyến khích nhưng không bắt buộc)
- Mô tả thêm

**Error Messages:**
- "Vui lòng chọn kích thước rắn hoặc loài rắn" (if both empty)
- "Ảnh quá lớn, tối đa 5MB" (if photo > 5MB)
- "Không thể xác định vị trí GPS, vui lòng bật định vị" (if GPS fail)

---

## DATA STRUCTURE

### Report Object:

```json
{
  "reportId": "RPT-20251229-0001",
  "userId": "USER-12345",
  "anonymous": false,
  "location": {
    "lat": 21.0285,
    "lng": 105.8542,
    "address": "Đống Đa, Hà Nội",
    "accuracy": 12.5
  },
  "timestamp": "2025-12-29T14:30:00Z",
  "timeReported": "vừa xong",
  "snakeInfo": {
    "speciesId": "SNAKE-045",
    "speciesName": "Rắn hổ mang chúa",
    "scientificName": "Ophiophagus hannah",
    "dangerLevel": "high",
    "sizeEstimate": "large",
    "colors": ["nâu", "vàng"]
  },
  "photos": [
    "https://cdn.snakeaid.com/reports/img1.jpg",
    "https://cdn.snakeaid.com/reports/img2.jpg"
  ],
  "description": "Rắn đang trên cây cao 2m, gần ao",
  "status": "verified",
  "verifiedBy": "EXPERT-089",
  "communityPoints": 10,
  "views": 234,
  "helpful": 12
}
```

---

## INTEGRATION POINTS

### From Other Screens:

**From Homepage:**
- Homepage → Grid "Cảnh báo khu vực" → Screen 1 (Map)

**From Snake Library:**
- Snake Library Screen 2 (Detail) → "Báo cáo gặp loài này" → Screen 2 (pre-filled species)

**From AI Result:**
- AI Result → "Báo cáo lên cộng đồng" → Screen 2 (pre-filled species + photo)

**From Rescue Tracking:**
- After rescue complete → "Báo cáo vị trí rắn" → Screen 2 (pre-filled location)

### To Other Screens:

**From Screen 1 (Map):**
- Tap marker detail → "Xem chi tiết loài" → Snake Library Screen 2
- Tap "Đường đi tránh xa" → Google Maps navigation

**From Screen 2 (Report):**
- "Chọn loài rắn" → Snake Library Screen 1 (picker mode)
- Success → Back to Screen 1 (Map) with new marker

---

## ADMIN MODERATION

### Report Verification Flow:

**Status Workflow:**
1. **Submitted** (Người dùng gửi)
2. **Pending Review** (Chờ Admin/Expert kiểm tra)
3. **Verified** (Đã xác nhận - hiện trên map)
4. **Rejected** (Spam/sai thông tin - không hiện)
5. **Expired** (Sau 30 ngày tự động ẩn)

**Admin Actions:**
- View all pending reports
- Verify species if user selected "Không biết"
- Flag spam/fake reports
- Edit location if inaccurate
- Add expert notes

---

## GAMIFICATION

### Community Points System:

**Earning Points:**
- Submit verified report: +10 points
- Add photo: +5 points bonus
- First report in area: +15 points bonus
- Report leads to rescue: +50 points
- Report verified by expert: +20 points

**Leaderboard:**
- Top reporters (monthly)
- Badge: "Cộng đồng tích cực" (100+ points)
- Badge: "Chuyên gia địa phương" (500+ points)

---

## STITCH PROMPTS - ADDITIONAL SCREENS

### STITCH PROMPT - SCREEN 3 (ALERT DETAIL)

```
Create a mobile app detail screen for community snake alert. iOS style, information-rich design.

HEADER (white, 56px):
- Left: back arrow
- Center: "Chi tiết cảnh báo" bold dark text (20pt)
- Right: share icon (3 dots)
- Bottom border

PHOTO GALLERY (300px height, black background):
- Large swipeable photo carousel
- Current photo fills width
- Three dot indicators below (white, 8px)
- Center dot filled, others outline

VERIFICATION BADGE (below photos, light green background #E8F5E9, 40px height):
- Green checkmark icon left (20px)
- "Đã xác minh bởi Chuyên gia" green text (#4CAF50, 14pt bold)
- Full width, 8px rounded corners

SNAKE INFO (20px padding):
- "Rắn hổ mang chúa" (24pt bold black)
- "Ophiophagus hannah" (16pt italic gray #999)
- Red pill badge "Độc mạnh" (28px height, white text, 4px rounded)

LOCATION CARD (light gray #F8F9FA, 16px padding, 12px rounded):
- Row 1: Pin icon + "123m từ vị trí của bạn" (16pt bold)
- Row 2: "Đường Láng, Đống Đa, Hà Nội" (14pt gray)
- Row 3: Clock icon + "2 giờ trước (29/12/2025 14:30)" (14pt light gray)

DETAILS CARD (white, 1px gray border, 12px rounded, 16px padding):
- "Kích thước: Lớn (>150cm)" (14pt)
- Separator line
- "Màu sắc: Nâu, Vàng" with color squares (14pt)
- Separator line
- "Trạng thái: Đang di chuyển" (14pt)

DESCRIPTION BOX (light blue #F0F8FF, 16px padding, 12px rounded):
- Quote-style text: "Rắn đang trên cây cao 2m, gần ao. Có vẻ đang tìm mồi. Cẩn thận!"
- 16pt dark text, line height 1.5

REPORTER INFO (horizontal layout):
- Avatar 48px circle left
- "Nguyễn Văn A" (16pt bold)
- Small amber badge "Cộng đồng tích cực (120đ)"

MAP PREVIEW (200px height, 12px rounded):
- Static Google Maps image with red marker
- "Xem bản đồ lớn hơn →" button overlay bottom-right

HELPFUL SECTION:
- "Thông tin này có hữu ích?" (16pt bold)
- Two buttons: Thumbs up "12" (green), Thumbs down "1" (red)

BOTTOM BAR (white, 72px, top shadow):
- Two equal buttons with 12px gap:
- Left: "Đường đi tránh xa" (outlined green, 16pt bold)
- Right: "Gọi cứu hộ" (solid green #228B22, white text, 16pt bold)

Professional detail view, comprehensive information, clear action buttons.
```

### STITCH PROMPT - SCREEN 4 (ADJUST LOCATION)

```
Create a mobile app full-screen map for location adjustment. iOS style, interactive map.

HEADER (white, 56px, top shadow):
- Left: X close icon
- Center: "Điều chỉnh vị trí" bold dark text (20pt)
- Right: "Xong" green text (#228B22, 16pt)

FULL SCREEN MAP (fills remaining space):
- Google Maps style with roads and landmarks
- Blue pulsing dot for user location (24px)
- Draggable map (user can pan freely)

FIXED CENTER PIN (absolute center, doesn't move):
- Large red location pin icon (48px width, 60px height)
- Drop shadow for depth
- Pin stays centered while map drags underneath

MAP CONTROLS (right side):
- "My Location" button (48px white circle, bottom-right, crosshair icon)
- Zoom + button (40px white circle, above location button)
- Zoom - button (40px white circle, above zoom +)

BOTTOM INFO CARD (white, 180px height, draggable):
- Top rounded corners 16px
- Top shadow subtle
- Drag handle (gray horizontal line 40px, 4px thick, centered top)
- 20px padding
- "Vị trí đã chọn:" (14pt bold gray #666)
- "Đường Láng, Đống Đa, Hà Nội" (16pt dark, updates as map moves)
- "GPS: 21.0285, 105.8542" (14pt monospace gray)
- Full-width green button "XÁC NHẬN VỊ TRÍ" (56px height, white bold text 18pt, 12px rounded)

Interactive map interface, clear pin positioning, smooth dragging experience.
```

### STITCH PROMPT - SCREEN 5 (MY REPORTS)

```
Create a mobile app list screen for user's report history. iOS style, organized layout.

HEADER (white, 56px):
- Left: back arrow
- Center: "Báo cáo của tôi" bold green text (#228B22, 20pt)
- Right: 3-dot filter icon
- Bottom border

STATS SUMMARY (light green background #E8F5E9, 80px height):
- Three equal columns separated by vertical lines:
- Left: "15" (28pt bold), "Tổng báo cáo" (12pt gray)
- Center: "12" green (28pt bold #4CAF50), "Đã xác minh" (12pt gray)
- Right: "3" amber (28pt bold #FFC107), "Chờ duyệt" (12pt gray)

TAB BAR (white, 48px):
- Four tabs horizontal: "Tất cả" "Đã duyệt" "Chờ" "Từ chối"
- Active tab: green underline 3px, green bold text
- Inactive: gray regular text

SCROLLABLE LIST (white background):
Each report card (100px height, 12px padding, bottom border 1px #F0F0F0):
- Left: Square thumbnail 80px with snake photo, 12px rounded
- Right content:
  - "Rắn hổ mang chúa" (16pt bold)
  - Green pill badge "Đã xác minh" (12pt, 6px padding, 4px rounded)
  - "123m • 2 giờ trước" (14pt gray #666)
  - "+10 điểm • 12 helpful" (13pt green)

Second card:
- Orange thumbnail
- "Rắn lục đuôi đỏ" (16pt bold)
- Orange badge "Chờ xác minh"
- "456m • 1 ngày trước"
- "Chờ chuyên gia..." (13pt orange)

Third card:
- Gray placeholder (no photo)
- "Không rõ loài" (16pt italic gray)
- Red badge "Từ chối"
- "2 ngày trước"
- "Lý do: Ảnh mờ" (13pt red)

Clean list design, clear status indicators, organized information hierarchy.
```

### STITCH PROMPT - SCREEN 6 (SUCCESS)

```
Create a mobile app success screen after report submission. iOS style, celebration design.

TOP SECTION (centered, white background):
- Large animated green checkmark in circle (120px diameter, #4CAF50)
- Checkmark draws in with animation
- "Báo cáo thành công!" below (28pt bold green #228B22)
- "Cảm ơn bạn đã giúp cộng đồng an toàn hơn" (18pt gray #666, centered, 80% width)

REWARDS CARD (light amber #FFF9E6, 2px amber border #FFC107, 16px rounded, 24px padding):
- Header: "BẠN ĐÃ NHẬN ĐƯỢC:" (14pt bold amber #FF8F00)
- Trophy icon + "+10 điểm cộng đồng" (16pt)
- Star icon + "+5 điểm (có ảnh)" (16pt)
- Medal icon + "Đầu tiên ở khu vực +15" (16pt)
- Dashed separator line
- "TỔNG: +30 điểm" (20pt bold amber, subtle gradient background)

WHAT'S NEXT CARD (light blue #E7F3FF, 1px blue border, 12px rounded, 20px padding):
- "TIẾP THEO:" (14pt bold blue #007BFF)
- Bullet list:
  - "• Chuyên gia sẽ xác minh trong 24h" (15pt)
  - "• Báo cáo sẽ hiện trên bản đồ" (15pt)
  - "• Bạn nhận thông báo khi xác minh" (15pt)

PREVIEW CARD (white, 1px gray border, 12px rounded, 16px padding):
- Mini static map 150px height with red marker (8px rounded)
- "Vị trí báo cáo của bạn" (14pt bold gray)
- "Đường Láng, Đống Đa, HN" (16pt dark)

BUTTONS (32px horizontal margins):
- Primary: "XEM TRÊN BẢN ĐỒ" (full width, 56px, green #228B22, white bold 18pt, 12px rounded, shadow)
- Secondary: "VỀ TRANG CHỦ" (full width, 52px, white, 2px green border, green text 17pt, 12px rounded)
- Text link: "Đóng" (16px gray underline, centered)

Celebratory design, clear rewards display, multiple action options, positive reinforcement.
```

---

## STITCH PROMPT - SCREEN 1 (ALERT MAP)

```
Create a mobile app screen for community snake alert map. iOS style, modern design.

HEADER (white background, 56px height):
- Left: back arrow icon black
- Center: "Cảnh báo khu vực" bold green text (#228B22, 20pt)
- Right: 3-dot menu icon gray
- Bottom border light gray

TIME FILTER BAR (white background, 48px height):
Four horizontal chips with 8px gaps:
- "24 giờ qua" (active: green background #228B22, white text, rounded 18px)
- "7 ngày" (inactive: white background, gray border #E0E0E0, gray text)
- "30 ngày" (inactive)
- "Tất cả" (inactive)

INTERACTIVE MAP (60% of screen):
- Google Maps style satellite + roads
- Blue pulsing dot for user location (24px)
- Red pin markers (32px) for dangerous snakes with warning triangle icon
- Orange pin markers (28px) for medium danger
- Green pin markers (24px) for safe snakes
- One cluster badge showing "5" in red circle (48px)
- "My Location" button bottom-right (white circle 48px, shadow, crosshair icon)
- Zoom +/- buttons top-right

STATS BAR (light gray background #F8F9FA, 56px height, above bottom):
Three equal segments separated by vertical lines:
- Left: Red icon, "12" bold red number (20pt), "Độc" gray label (12pt)
- Center: Orange icon, "8" bold amber number (20pt), "T.Bình" gray label
- Right: Green icon, "5" bold green number (20pt), "An toàn" gray label

REPORT BUTTON (sticky bottom, full width, 64px height):
- Forest green background (#228B22)
- White bold text "Bạn thấy rắn? Báo cáo ngay →" (18pt)
- Camera icon left side white
- Subtle top shadow

Professional design, clear hierarchy, mobile-optimized map interface.
```

---

## STITCH PROMPT - SCREEN 2 (REPORT FORM)

```
Create a mobile app form screen for reporting snake sighting. iOS style, clean form design.

HEADER (white, 56px):
- Left: back arrow
- Center: "Báo cáo nhìn thấy rắn" bold dark text (20pt)
- Right: X close icon
- Bottom border

SCROLLABLE FORM with sections:

SECTION 1: "VỊ TRÍ NHÌN THẤY" (bold 16pt)
- Mini map preview (180px height, rounded 12px, light border)
- Shows small map with red marker pin
- Below map: "GPS: 21.0285, 105.8542" (monospace gray 14pt)
- Below: "Địa chỉ: Đống Đa, Hà Nội" (14pt dark)
- Link: "Điều chỉnh vị trí →" (green text 14pt)

SECTION 2: "THỜI GIAN NHÌN THẤY" (bold 16pt)
- Four horizontal chips:
  "Vừa xong" (active green), "1h trước", "Hôm nay", "Khác" (all inactive gray)

SECTION 3: "THÔNG TIN RẮN" (bold 16pt)
- Dropdown field (56px height, white, rounded 12px, gray border):
  Placeholder "Tìm kiếm loài rắn..." with search icon left
  
- Radio buttons for size (horizontal 4 options):
  "Nhỏ (<50cm)" "Trung (50-150cm)" "Lớn (>150cm)" "Không rõ"
  Each with 24px circle, active green filled, inactive white with gray border
  
- Checkbox row for colors (horizontal 5 squares):
  Brown square 32px, Black square, Green square, Yellow square, "Khác" gradient square
  Each with 24px checkbox above

SECTION 4: "HÌNH ẢNH (Tùy chọn)" (bold 16pt)
- Three 100x100px squares with dashed gray border, rounded 12px, light gray background
- First square: large + icon (36px) and "Thêm ảnh" text (12pt gray)
- Other two squares empty

SECTION 5: "MÔ TẢ THÊM (Tùy chọn)" (bold 16pt)
- Text area (120px height, white, rounded 12px, gray border, 16px padding)
- Placeholder: "VD: Rắn đang trên cây cao 2m, gần ao..."
- Character count "0/500" bottom-right small gray

PRIVACY CHECKBOX (light yellow background #FFF9E6, 16px padding, rounded 8px):
- Checkbox 24px + text "Ẩn danh (không hiện tên tôi trong báo cáo)" (14pt gray)

SUBMIT BUTTON (fixed bottom, 56px height, 20px side margins):
- Forest green background (#228B22)
- "GỬI BÁO CÁO" white bold text (18pt) centered
- Send icon right side white
- Rounded 12px, shadow

Clean form layout, proper spacing, professional input fields, clear sections.
```

---

## NOTES FOR DEVELOPERS

### Technical Requirements:

**Map Integration:**
- Use Google Maps SDK / Mapbox GL
- Enable clustering for markers (threshold: 3+ within 100m)
- Implement marker tap → show bottom sheet
- GPS permission required

**Photo Upload:**
- Camera + Gallery access
- Image compression (max 1080px width)
- Upload to CDN (S3/Cloudinary)
- Show upload progress bar

**Form Validation:**
- Real-time validation (show errors on blur)
- Disable submit until required fields filled
- GPS fallback: if GPS fail, allow manual pin drop

**Performance:**
- Lazy load map markers (only visible area + 1km buffer)
- Cache map tiles for offline
- Debounce search input (300ms)

### Security:

**Spam Prevention:**
- Rate limit: Max 5 reports per day per user
- Photo required if "Không biết loài"
- Admin moderation queue

**Privacy:**
- Anonymous option hides user name/avatar
- GPS coordinates rounded to 100m precision (public display)
- Full precision only for admin/rescue team

---

## FUTURE ENHANCEMENTS

### Version 2.0:
- Heatmap overlay (density của báo cáo)
- Filter by species, danger level
- "Subscribe to alerts" for specific area
- Push notification when new report near user (1km)

### Version 3.0:
- AI verification: Auto-verify species from photo
- Trending alerts: "5 vụ trong 24h - khu vực này đang nguy hiểm"
- Integration với weather data: "Rắn hay xuất hiện sau mưa"
- Community comments on reports

---

**END OF DOCUMENT**
