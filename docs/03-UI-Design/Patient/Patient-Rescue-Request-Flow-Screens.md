# RESCUE REQUEST FLOW - UI DESIGN SCREENS (PATIENT ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Patient Mobile Application
- **Role:** 🧑 **PATIENT** (Người dùng phát hiện rắn và yêu cầu cứu hộ)
- **Flow:** Rescue Request Flow (Yêu cầu cứu hộ rắn)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 11 screens (8 main screens + 3 alternative/error screens)
- **Ngày tạo:** December 4, 2025
- **Location:** `/02-UI-Design/Patient-Rescue-Request-Flow-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **PATIENT role**. 
> Màn hình cho **Rescuer** và **Expert** sẽ được thiết kế trong documents riêng.

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

> **🧑 Tất cả screens dưới đây là cho PATIENT role** - người dùng phát hiện rắn và yêu cầu cứu hộ

---

### Screen 1: Report Snake Discovery - Quantity Selection

#### Thông tin màn hình:
- **Tên:** Màn hình báo cáo phát hiện rắn - Chọn số lượng
- **Mục đích:** Cho phép người dùng chọn số lượng rắn phát hiện trước khi chụp ảnh
- **Flow position:** Giai đoạn 2.1 - Phát hiện và báo cáo rắn
- **Priority:** ⭐⭐⭐ (Cao nhất)
- **Navigation:** Chọn số lượng → Screen 1A/1B/1C tương ứng

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Báo Cáo Phát Hiện Rắn"
   - Info icon (top-right)

2. **Quantity Selection Section:**
   - Heading: "Số lượng rắn bạn thấy:"
   - 3 radio button cards (vertically stacked):
     
     **Card 1 (Default selected):**
     - Radio button (left)
     - Icon: 1 snake illustration
     - Title: "1 con rắn"
     - Subtitle: "Chụp 1-3 ảnh từ nhiều góc độ"
     - Right arrow
     
     **Card 2:**
     - Radio button (left)
     - Icon: 2-3 snake illustration
     - Title: "2-5 con rắn"
     - Subtitle: "Chụp ảnh từng con rắn riêng biệt"
     - Right arrow
     
     **Card 3:**
     - Radio button (left)
     - Icon: Multiple snakes illustration
     - Title: "Nhiều con / Ổ rắn"
     - Subtitle: "Chụp ảnh tổng thể và cận cảnh"
     - Right arrow

3. **Information Note:**
   - Light blue background info box
   - Icon: Info circle
   - Text: "Chọn số lượng giúp chúng tôi báo giá chính xác và điều phối người hỗ trợ phù hợp"

4. **Action Button:**
   - Large primary button (forest green): "Tiếp tục →"
   - Enabled only when selection made

#### Stitch Prompt (English):

```
Mobile app screen for snake quantity selection in emergency assistance app "SnakeAid". Clean modern design with forest green (#228B22) primary color on white background.

Top navigation: Back arrow left, centered title "Báo Cáo Phát Hiện Rắn", info icon right.

Main content area starts with heading "Số lượng rắn bạn thấy:" in dark gray bold text (20pt).

Below heading, three vertically stacked white cards with subtle shadow and 16px spacing between them:

CARD 1 (selected state with forest green border 2px):
Left side: Selected radio button (filled green circle)
Center-left: Small snake icon (single snake illustration)
Center: Bold text "1 con rắn" with subtitle below "Chụp 1-3 ảnh từ nhiều góc độ" in gray
Right side: Right arrow icon
Card height: 80px

CARD 2 (unselected state with light gray border 1px):
Left side: Unselected radio button (empty circle)
Center-left: Small icon showing 2-3 snakes
Center: Bold text "2-5 con rắn" with subtitle "Chụp ảnh từng con rắn riêng biệt" in gray
Right side: Right arrow icon
Card height: 80px

CARD 3 (unselected state with light gray border 1px):
Left side: Unselected radio button (empty circle)
Center-left: Small icon showing multiple snakes/nest
Center: Bold text "Nhiều con / Ổ rắn" with subtitle "Chụp ảnh tổng thể và cận cảnh" in gray
Right side: Right arrow icon
Card height: 80px

Below cards, light blue background info box (#E3F2FD) with rounded corners:
Left: Small info circle icon in blue
Right: Text "Chọn số lượng giúp chúng tôi báo giá chính xác và điều phối người hỗ trợ phù hợp" in dark gray (14pt)

Bottom of screen: Large solid forest green button "Tiếp tục →" spanning full width with padding (60px height).

Design: Clean selection interface, clear card hierarchy, visual distinction between selected/unselected states, mobile-optimized touch targets.
```

#### Notes for Stitch:
- Snake icons nên đơn giản, outline style
- Selected card phải có green border rõ ràng
- Radio buttons phải standard size (24px)
- Cards phải có clear tap feedback

---

### Screen 1A: Report Snake Discovery - Single Snake (1-3 Photos)

#### Thông tin màn hình:
- **Tên:** Màn hình báo cáo 1 con rắn (Chụp ảnh HOẶC Chọn loài)
- **Mục đích:** Chụp 1-3 ảnh từ nhiều góc độ HOẶC chọn loài rắn từ danh sách
- **Flow position:** Sau Screen 1 khi chọn "1 con rắn"
- **Priority:** ⭐⭐⭐
- **Alternative Mode:** Chọn từ database nếu user biết loài hoặc không thể chụp an toàn

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Báo Cáo: 1 Con Rắn"
   - Info icon (top-right)

2. **Mode Switcher (NEW):**
   - Segmented control / Tab switcher
   - Two options (equal width):
     - **Tab 1:** "Chụp Ảnh" (default selected, green underline/background)
     - **Tab 2:** "Chọn Loài Rắn" (gray)
   - Subtitle: "Chọn cách bạn muốn báo cáo"
   - Switches between Photo Upload UI and Species Selection UI

---

### MODE A: PHOTO UPLOAD (Default View)

3. **Multi-Photo Camera Section:**
   - Heading: "Chụp ảnh con rắn (1-3 góc độ)"
   - Grid layout for photo slots:
     - **Slot 1 (Required):** Large dashed rectangle with camera icon + "Ảnh chính (bắt buộc)"
     - **Slot 2 (Optional):** Medium dashed rectangle + "Góc độ 2 (khuyến nghị)"
     - **Slot 3 (Optional):** Medium dashed rectangle + "Góc độ 3 (tùy chọn)"
   - Each filled slot shows thumbnail with "X" delete button
   - Primary button below: "Thêm ảnh" (visible after photo 1 taken)

4. **Photo Guidelines Card:**
   - Expandable section: "Mẹo chụp ảnh rắn"
   - When expanded shows 3 tips:
     - "Chụp từ xa an toàn (2-3 mét)"
     - "Chụp rõ đầu và thân rắn"
     - "Tránh dùng flash nếu rắn đang hung dữ"

5. **Location Section:**
   - Auto-detected GPS icon with green checkmark
   - Text: "Vị trí đã xác định"
   - Address preview (gray text)
   - Small text link: "Chỉnh sửa vị trí"

6. **Additional Information Card:**
   - Title: "Thông Tin Bổ Sung (Tùy chọn)"
   - 4 input fields:
     - "Vị trí cụ thể" (text input)
     - "Kích thước ước tính" (dropdown: Nhỏ/Trung bình/Lớn)
     - "Hành vi của rắn" (text input)
     - "Mức độ khẩn cấp" (3 chips: Thấp/Trung bình/Cao)

7. **Action Buttons:**
   - Large primary button (forest green): "Gửi Báo Cáo →"
   - Enabled only when at least 1 photo uploaded
   - Text below: "AI sẽ phân tích loài rắn"

---

### MODE B: SPECIES SELECTION (When Tab 2 selected)

3. **Info Banner:**
   - Light blue background (#E3F2FD)
   - Icon: Database/Book
   - Text: "Chọn loài rắn bạn gặp từ danh sách phổ biến ở khu vực"
   - Subtext: "Dựa trên vị trí GPS của bạn"

4. **Location Display:**
   - Small card: "Vị trí: Quận 1, TP.HCM" (from GPS)
   - Change location link if needed

5. **Snake Selection Grid:**
   - Grid layout: 2 columns
   - Shows 6-8 most common snakes in user's area
   - Each card contains:
     - **Snake photo:** Square 120×120px, clear image
     - **Venomous badge:** Red "RẮN ĐỘC" or Green "KHÔNG ĐỘC" (top-right overlay)
     - **Vietnamese name:** "Rắn hổ mang chúa" (bold, 16pt)
     - **Scientific name:** "Ophiophagus hannah" (gray, 12pt)
     - **2-3 key features:**
       - "Đầu dẹt hình thìa"
       - "Màu nâu vàng, có vân"
       - "1-3m dài"
     - **Selection:** Radio button or tap to select
   - Selected card has green border (3px) and checkmark

6. **Search Option:**
   - Search bar: "Tìm loài rắn khác..."
   - Expands full database when tapped

7. **Helper Box:**
   - Light yellow background (#FFFACD)
   - Text: "💡 Chọn con GIỐNG NHẤT, không cần chính xác 100%"
   - Icons showing what to look for: Head shape, Pattern, Size

8. **Location Section:**
   - Same as Photo Upload mode
   - Auto-detected GPS location

9. **Additional Information (Simplified):**
   - Title: "Thông Tin Bổ Sung"
   - Fields:
     - "Kích thước ước tính" (required if selecting species)
     - "Hành vi của rắn" (optional)
     - "Mức độ khẩn cấp" (optional)

10. **Action Buttons:**
    - Large green button: "Xác Nhận Loài Rắn →"
    - Enabled when 1 species selected
    - Text below: "Bỏ qua AI - Đi thẳng đến yêu cầu cứu hộ"

---

#### Stitch Prompt - MODE A (Photo Upload):

```
Mobile app screen for reporting single snake in "SnakeAid". Forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Báo Cáo: 1 Con Rắn", info icon right.

Below nav, segmented control with 2 equal-width tabs:
- Left tab "Chụp Ảnh" (selected, forest green background, white text)
- Right tab "Chọn Loài Rắn" (gray background, dark text)
Small gray subtitle below: "Chọn cách bạn muốn báo cáo"

Main content starts with heading "Chụp ảnh con rắn (1-3 góc độ)" in bold dark gray.

Photo grid section showing 3 photo slots in grid layout (2 columns, slot 1 spans full width):

SLOT 1 (full width, aspect ratio 4:3):
Large dashed border rectangle (#CCCCCC, 2px dashed) with light gray background (#F5F5F5)
Center: Camera icon (48px) and text "Ảnh chính (bắt buộc)" in dark gray
Small badge in top-right corner: "Required" in red background

SLOT 2 (left column, smaller):
Medium dashed border rectangle with camera icon (32px)
Text "Góc độ 2 (khuyến nghị)" in gray
Small badge: "Recommended" in amber

SLOT 3 (right column, same size as slot 2):
Medium dashed border rectangle with camera icon (32px)
Text "Góc độ 3 (tùy chọn)" in gray
Small badge: "Optional" in light gray

Below grid: Forest green outlined button "Thêm ảnh +" (disabled state shown with gray).

Expandable section "Mẹo chụp ảnh rắn ▼" with small info icon. When expanded shows:
• Chụp từ xa an toàn (2-3 mét)
• Chụp rõ đầu và thân rắn
• Tránh dùng flash nếu rắn đang hung dữ

White card labeled "Vị Trí" with green checkmark icon, text "Vị trí đã xác định", address preview in gray, and small blue link "Chỉnh sửa vị trí".

Section "Thông Tin Bổ Sung (Tùy chọn)" with white card containing 4 form fields:
- Text input "Vị trí cụ thể" with placeholder "trong nhà/vườn/đường phố"
- Dropdown "Kích thước ước tính" showing "Chọn kích thước"
- Text input "Hành vi của rắn" with placeholder "đang di chuyển/đứng yên/hung dữ"
- Three chips "Thấp", "Trung bình", "Cao" under "Mức độ khẩn cấp"

Bottom: Large forest green button "Gửi Báo Cáo →" (disabled state - grayed out). Below button, centered gray text "AI sẽ phân tích loài rắn".

Design: Clean photo upload interface, clear slot hierarchy, visual distinction between required/optional, mobile-optimized.
```

#### Notes for Stitch:
- Mode toggle phải rõ ràng - selected tab có green background
- Photo slots phải rõ ràng về required vs optional
- Grid layout responsive - slot 1 full width, slot 2-3 side by side
- Disabled state của button "Gửi Báo Cáo" khi chưa có ảnh
- Thumbnail preview khi đã chụp phải có X button để xóa

#### Stitch Prompt - MODE B (Species Selection):

```
Mobile app species selection screen for single snake in "SnakeAid". Forest green (#228B22) primary.

Top navigation: Back arrow, title "Báo Cáo: 1 Con Rắn", info icon.

Segmented control with 2 tabs:
- Left "Chụp Ảnh" (gray)
- Right "Chọn Loài Rắn" (selected, green background, white text)
Subtitle "Chọn cách bạn muốn báo cáo" gray.

Light blue info banner (#E3F2FD) with database icon:
"Chọn loài rắn bạn gặp từ danh sách phổ biến ở khu vực" bold
"Dựa trên vị trí GPS của bạn" small gray

Small location card: "Vị trí: Quận 1, TP.HCM" with pin icon and "Thay đổi" link.

2-column grid of snake cards (6-8 cards visible). Each card:
- Square snake photo 120×120px
- Top-right badge: Red "RẮN ĐỘC" or Green "KHÔNG ĐỘC"
- Bold "Rắn hổ mang chúa" (16pt)
- Gray italic "Ophiophagus hannah" (12pt)
- 3 feature lines with small gray text:
  • Đầu dẹt hình thìa
  • Màu nâu vàng, có vân
  • 1-3m dài
- Radio button (selected card has green border 3px)

Search bar "Tìm loài rắn khác..." with search icon.

Yellow helper box (#FFFACD):
"💡 Chọn con GIỐNG NHẤT, không cần chính xác 100%"
Small icons: Head, Pattern, Size

Location card same as Mode A.

Simplified "Thông Tin Bổ Sung" section with 3 fields:
- Kích thước ước tính (dropdown)
- Hành vi của rắn (text input)
- Mức độ khẩn cấp (3 chips)

Large green button "Xác Nhận Loài Rắn →" (enabled when 1 selected).
Gray text below "Bỏ qua AI - Đi thẳng đến yêu cầu cứu hộ"

Design: Visual selection gallery, clear badges, location-aware, quick identification.
```

---

### Screen 1B: Report Snake Discovery - Multiple Snakes (2-5 Photos)

#### Thông tin màn hình:
- **Tên:** Màn hình báo cáo nhiều con rắn (Chụp ảnh HOẶC Chọn loài)
- **Mục đích:** Chụp ảnh từng con riêng biệt HOẶC chọn loài rắn cho từng con
- **Flow position:** Sau Screen 1 khi chọn "2-5 con rắn"
- **Priority:** ⭐⭐⭐
- **Alternative Mode:** Chọn loài từ database (nhanh hơn nếu biết loài)

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Báo Cáo: 2-5 Con Rắn"
   - Info icon (top-right)

2. **Mode Switcher (NEW):**
   - Segmented control / Tab switcher
   - Two options:
     - **Tab 1:** "Chụp Ảnh" (default, green)
     - **Tab 2:** "Chọn Loài Rắn" (gray)
   - Note: "Chọn loài nếu bạn biết rõ hoặc không thể chụp an toàn"

---

### MODE A: PHOTO UPLOAD (Default)

3. **Instruction Banner:**
   - Light amber background alert box
   - Icon: Info/Warning
   - Text: "Vui lòng chụp ảnh TỪNG con rắn riêng biệt để AI phân tích chính xác"

3. **Sequential Photo Upload Section:**
   - Heading: "Ảnh các con rắn (Tối thiểu 2, Tối đa 5)"
   - Vertical list of photo cards:
     
     **Photo Card Template (repeated for each photo):**
     - Card number badge: "Con rắn #1", "Con rắn #2"...
     - Photo slot (dashed border if empty, thumbnail if filled)
     - "Chụp ảnh" button or "Thay đổi" if filled
     - Optional text input: "Ghi chú vị trí" (e.g., "trong vườn", "gần cửa")
     - Delete button (X) on filled cards
   
   - Add button at bottom: "+ Thêm con rắn" (max 5)
   - Counter: "2/5 con rắn đã chụp"

4. **Global Location Section:**
   - Icon: Map pin
   - Text: "Vị trí chung: [Address]"
   - Note: "Tất cả rắn ở khu vực này"
   - Link: "Chỉnh sửa"

5. **Additional Information Card:**
   - Title: "Thông Tin Chung (Tùy chọn)"
   - Fields:
     - "Kích thước chung" (dropdown: Nhỏ/Trung bình/Lớn/Khác nhau)
     - "Tình trạng" (text: e.g., "Nhiều con ở các góc khác nhau")
     - "Mức độ khẩn cấp" (3 chips)

6. **Pricing Estimate:**
   - Small info box with amber background
   - Icon: Currency
   - Text: "Ước tính phí: 575,000 VNĐ × số lượng rắn"
   - Subtext: "Giá chính xác sau khi Rescuer xác nhận"

7. **Action Buttons:**
   - Large primary button: "Gửi Báo Cáo →"
   - Enabled when ≥2 photos uploaded
   - Text below: "AI sẽ phân tích từng con rắn"

---

### MODE B: SPECIES SELECTION (Multiple Selection)

3. **Info Banner:**
   - Light blue background
   - Text: "Chọn loài rắn cho từng con bạn gặp (2-5 con)"
   - Subtext: "Có thể chọn cùng loài nhiều lần nếu gặp nhiều con giống nhau"

4. **Snake Counter:**
   - Display: "Đang chọn: Con rắn #1" (updates as user adds)
   - Counter: "0/5 con đã chọn"

5. **Snake Selection Grid:**
   - Grid 2 columns showing common snakes
   - Each card has:
     - Photo, venomous badge, name, features
     - Button: "+ Thêm Con Này"
   - When tapped → adds to selected list below

6. **Selected Snakes List:**
   - Vertical list showing added snakes (up to 5)
   - Each entry:
     - Number badge: "#1", "#2", "#3"...
     - Snake thumbnail + name
     - "Xóa" button
     - Optional note field: "Vị trí cụ thể con này..." (optional)

7. **Global Location:**
   - Same as Photo Upload mode
   - Auto-detected GPS

8. **Additional Information:**
   - Simplified fields
   - "Mức độ khẩn cấp" (optional)

9. **Pricing Estimate:**
   - Same as Photo Upload mode
   - "Ước tính: 575,000 × X con = XXX,XXX VNĐ"

10. **Action Buttons:**
    - Large green button: "Xác Nhận X Con Rắn →"
    - Enabled when ≥2 snakes selected
    - Text below: "Bỏ qua AI - Đi thẳng yêu cầu cứu hộ"

---

#### Stitch Prompt (English):

```
Mobile app screen for reporting multiple snakes (2-5) in "SnakeAid". Clean design with forest green (#228B22) primary color.

Top navigation: Back arrow left, title "Báo Cáo: 2-5 Con Rắn", info icon right.

Segmented control:
- Left "Chụp Ảnh" (selected, green background, white text)
- Right "Chọn Loài Rắn" (gray)
Note "Chọn loài nếu bạn biết rõ hoặc không thể chụp an toàn" gray.

Amber background banner (#FFF3CD) with info icon:
"Vui lòng chụp ảnh TỪNG con rắn riêng biệt để AI phân tích chính xác"

Heading "Ảnh các con rắn (Tối thiểu 2, Tối đa 5)" in bold dark gray.

Vertical list of photo upload cards with 12px spacing:

CARD 1 (filled state):
White card with subtle shadow
Top-left badge "Con rắn #1" (forest green background, white text)
Square photo thumbnail (200x200px) showing uploaded snake image
Small "X" delete button top-right corner of thumbnail
Below photo: Text input field labeled "Ghi chú vị trí" with placeholder "trong vườn, gần cửa..." and value "Trong vườn"
Bottom of card: Small gray button "Thay đổi ảnh"

CARD 2 (filled state, similar to Card 1):
Badge "Con rắn #2"
Photo thumbnail shown
"Ghi chú vị trí" input (empty)
"Thay đổi ảnh" button

CARD 3 (empty state):
Badge "Con rắn #3" (gray background)
Large dashed border rectangle (aspect ratio 1:1) with camera icon center
Text "Chụp ảnh" in gray
Forest green button "Chụp ảnh +"

Bottom of list: Dashed outlined button "+ Thêm con rắn (Tối đa 5)" in forest green outline.
Right-aligned text "2/5 con rắn đã chụp" in gray.

White card "Vị trí chung":
Map pin icon left
Text "123 Đường ABC, Quận XYZ" bold
Subtext "Tất cả rắn ở khu vực này" gray
Right: Small blue link "Chỉnh sửa"

Section "Thông Tin Chung (Tùy chọn)" with white card:
- Dropdown "Kích thước chung" showing "Khác nhau"
- Text input "Tình trạng" with placeholder
- Three chips "Thấp", "Trung bình" (selected), "Cao"

Amber info box (#FFF3CD) with currency icon:
"Ước tính phí: 575,000 VNĐ × số lượng rắn"
Small gray text below "Giá chính xác sau khi Rescuer xác nhận"

Bottom: Large forest green button "Gửi Báo Cáo →" enabled state.
Below button: Gray text "AI sẽ phân tích từng con rắn"

Design: Sequential upload flow, numbered cards, clear photo labeling, pricing transparency, mobile-optimized.
```

#### Notes for Stitch - MODE A:
- Mode toggle visible và clear
- Photo cards phải numbered rõ ràng (#1, #2, #3...)
- Empty vs Filled state phải khác biệt rõ
- Add button disabled khi đạt max 5 photos
- Counter "X/5 con rắn" phải update real-time

#### Stitch Prompt - MODE B (Species Selection):

```
Mobile app multi-species selection for 2-5 snakes in "SnakeAid". Forest green primary.

Top nav: Back arrow, title "Báo Cáo: 2-5 Con Rắn", info icon.

Segmented control:
- Left "Chụp Ảnh" (gray)
- Right "Chọn Loài Rắn" (selected, green background, white text)
Note "Chọn loài nếu bạn biết rõ hoặc không thể chụp an toàn" gray.

Light blue info banner (#E3F2FD):
"Chọn loài rắn cho từng con bạn gặp (2-5 con)" bold
"Có thể chọn cùng loài nhiều lần nếu gặp nhiều con giống nhau" small gray

Counter section with 2 parts:
Left: "Đang chọn: Con rắn #1" bold
Right: "0/5 con đã chọn" gray

2-column grid of snake cards (6-8 visible, scrollable). Each card:
- Square photo 120×120px
- Top-right badge: Red "RẮN ĐỘC" or Green "KHÔNG ĐỘC"
- Bold "Rắn hổ mang chúa" (16pt)
- Gray italic "Ophiophagus hannah" (12pt)
- 2-3 feature bullets
- Green button "+ Thêm Con Này" at bottom

Below grid, "Selected Snakes List" section showing added snakes (0-5 cards):

Card #1 (when added):
- Number badge "#1" (green circle, white text, 32px)
- Snake thumbnail 60×60px + name "Rắn hổ mang chúa"
- Red text link "Xóa" top-right
- Optional text input placeholder "Vị trí cụ thể con này..." gray border

Card #2, #3... same layout with incremented numbers.

Location card: "Vị trí chung: 123 Đường ABC" with pin icon.

Simplified "Mức độ khẩn cấp" section with 3 chips.

Amber pricing box (#FFF3CD):
"Ước tính: 575,000 × 3 con = 1,725,000 VNĐ" bold
"Giá chính xác sau khi Rescuer xác nhận" small gray

Large green button "Xác Nhận 3 Con Rắn →" (count updates dynamically).
Gray text "Bỏ qua AI - Đi thẳng yêu cầu cứu hộ"

Design: Multi-selection interface, running counter, numbered list, dynamic pricing calculation.
```

#### Notes for Stitch - MODE B:
- Counter must update as snakes added
- Selected list shows numbering clearly (#1, #2, #3)
- Add/Remove buttons easy to tap
- Dynamic pricing calculation
- Button text shows current count

---

### Screen 1C: Report Snake Discovery - Snake Nest (Multiple/Overview)

#### Thông tin màn hình:
- **Tên:** Màn hình báo cáo ổ rắn / nhiều con (Chụp ảnh HOẶC Chọn loài)
- **Mục đích:** Chụp ảnh tổng thể + chi tiết HOẶC chọn loài rắn chủ đạo
- **Flow position:** Sau Screen 1 khi chọn "Nhiều con / Ổ rắn"
- **Priority:** ⭐⭐⭐
- **Note:** Với ổ rắn, KHUYẾN CÁO chụp ảnh để chuyên gia đánh giá chính xác

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Báo Cáo: Ổ Rắn / Nhiều Con"
   - Info icon (top-right)

2. **Mode Switcher (NEW):**
   - Segmented control:
     - **Tab 1:** "Chụp Ảnh Ổ Rắn" (default, green - RECOMMENDED)
     - **Tab 2:** "Tôi Biết Loài Rắn" (gray)
   - Warning under tab 2: "⚠️ Với ổ rắn, khuyến nghị chụp ảnh để chuyên gia đánh giá"

---

### MODE A: PHOTO UPLOAD (Strongly Recommended)

3. **Important Alert Banner:**
   - Red/Orange background warning box
   - Icon: Warning triangle
   - Bold text: "CẢNH BÁO: Ổ rắn rất nguy hiểm"
   - Subtext: "Giữ khoảng cách an toàn tối thiểu 5 mét. Không tiếp cận!"

3. **Photo Strategy Guide:**
   - Collapsible section: "Hướng dẫn chụp ảnh ổ rắn"
   - When expanded shows numbered steps:
     1. "Chụp ảnh TOÀN CẢNH từ xa (để thấy tổng thể khu vực)"
     2. "Chụp 2-3 ảnh CẬN CẢNH (zoom hoặc dùng telephoto nếu có)"
     3. "Chụp môi trường xung quanh (cây, đá, lỗ, hốc...)"

4. **Photo Upload Section:**
   - Heading: "Ảnh chụp (Tối thiểu 2, Tối đa 5)"
   - Two subsections:
     
     **A. Ảnh Tổng Thể (Required):**
     - Large photo slot labeled "Ảnh toàn cảnh (BẮT BUỘC)"
     - Badge: "Overview" in red
     - Camera button
     
     **B. Ảnh Chi Tiết (2-4 ảnh):**
     - Grid of 4 smaller photo slots
     - Labels: "Chi tiết 1", "Chi tiết 2", "Chi tiết 3", "Chi tiết 4"
     - First 2 slots marked "Khuyến nghị", last 2 "Tùy chọn"
   
   - Counter below: "X/5 ảnh đã chụp"

5. **Quantity Estimate:**
   - Card with amber background
   - Icon: Question mark
   - Title: "Ước tính số lượng rắn"
   - Slider or number input: "Khoảng... con rắn"
   - Range selector: "5-10", "10-20", "20-50", ">50"
   - Text: "Ước tính giúp Rescuer chuẩn bị đầy đủ"

6. **Location & Details:**
   - Auto-detected location
   - Additional fields:
     - "Loại môi trường" (dropdown: Vườn/Rừng/Nhà/Công trình/Khác)
     - "Đặc điểm khu vực" (text: e.g., "Gần bụi cây, có nhiều lỗ")
     - "Mức độ khẩn cấp" (default: HIGH - locked)

7. **Specialist Required Notice:**
   - Info box with blue background
   - Icon: Expert/helmet
   - Text: "Trường hợp này CẦN chuyên gia xử lý ổ rắn"
   - Subtext: "Phí dịch vụ có thể cao hơn. Báo giá sau khi đánh giá."

8. **Action Buttons:**
   - Large primary button (red/orange): "Gửi Yêu Cầu Khẩn Cấp →"
   - Enabled when ≥2 photos (1 overview + 1 detail)
   - Text below: "Ưu tiên cao nhất - Phản hồi trong 5-10 phút"

---

### MODE B: SPECIES SELECTION (If User Knows - NOT Recommended)

3. **Strong Warning Banner:**
   - Amber background (#FFF3CD)
   - Icon: Warning
   - Bold text: "⚠️ CHÚ Ý: Với ổ rắn, KHUYẾN CÁO chụp ảnh để chuyên gia đánh giá chính xác"
   - Subtext: "Chỉ chọn loài nếu bạn CHẮC CHẮN 100% nhận biết được"
   - Link: "Tôi muốn chụp ảnh thay vì" (switches back to Photo mode)

4. **Nest Information Section:**
   - Title: "Thông tin về ổ rắn"
   - Fields:
     
     **A. Loài rắn chủ đạo (Required):**
     - Show selection cards (similar to 1A/1B)
     - Note: "Chọn loài chiếm đa số trong ổ"
     - Cards show common nest-forming snakes
     
     **B. Số lượng ước tính (Required):**
     - Range chips: "5-10 con", "10-20 con", "20-50 con", ">50 con"
     
     **C. Loại môi trường (Required):**
     - Dropdown: Đống gạch/đá, Hốc cây, Dưới đất, Khác

5. **Photo Upload (Optional but Recommended):**
   - Heading: "Bạn vẫn có thể thêm ảnh để hỗ trợ chuyên gia"
   - 1-2 photo slots for overview
   - Note: "Ảnh giúp chuyên gia chuẩn bị trang bị phù hợp"

6. **Location & Urgency:**
   - Same as Photo Upload mode
   - Auto-detected GPS
   - Urgency locked at "CAO"

7. **Specialist Notice:**
   - Same as Photo Upload mode
   - "CẦN chuyên gia xử lý ổ rắn"

8. **Pricing Estimate:**
   - Red/orange info box
   - Text: "Ước tính phí: 2,500,000 - 5,000,000 VNĐ"
   - Subtext: "Giá chính xác sẽ được báo SAU KHI chuyên gia khảo sát hiện trường"

9. **Action Buttons:**
   - Large red button: "Gọi Chuyên Gia Xử Lý Ổ Rắn →"
   - Enabled when loài + số lượng + môi trường filled
   - Text below: "Bỏ qua AI - Chuyên gia sẽ liên hệ trong 5-10 phút"

---

#### Stitch Prompt - MODE A (Photo Upload - Recommended):

```
Mobile app screen for reporting snake nest in "SnakeAid". Emergency-focused design with red (#DC3545) accents.

Top navigation: Back arrow left, title "Báo Cáo: Ổ Rắn / Nhiều Con", info icon right.

Segmented control:
- Left "Chụp Ảnh Ổ Rắn" (selected, green, RECOMMENDED badge)
- Right "Tôi Biết Loài Rắn" (gray)
Amber warning below tab 2: "⚠️ Với ổ rắn, khuyến nghị chụp ảnh để chuyên gia đánh giá"

Red/orange background alert banner (#FFE5E5) with warning triangle icon:
Bold text "CẢNH BÁO: Ổ rắn rất nguy hiểm"
Subtext "Giữ khoảng cách an toàn tối thiểu 5 mét. Không tiếp cận!"

Expandable section "Hướng dẫn chụp ảnh ổ rắn ▼". When expanded shows:
1. Chụp ảnh TOÀN CẢNH từ xa (để thấy tổng thể khu vực)
2. Chụp 2-3 ảnh CẬN CẢNH (zoom hoặc dùng telephoto nếu có)
3. Chụp môi trường xung quanh (cây, đá, lỗ, hốc...)

Heading "Ảnh chụp (Tối thiểu 2, Tối đa 5)".

SECTION A - Full width:
Large dashed rectangle (aspect ratio 16:9) labeled "Ảnh toàn cảnh (BẮT BUỘC)"
Red badge "Overview" top-left
Camera icon center with text "Chụp toàn cảnh"
Forest green button "Mở Camera" below

SECTION B - Grid (2x2):
Four smaller photo slots arranged in grid:
Top-left: "Chi tiết 1" with amber badge "Khuyến nghị"
Top-right: "Chi tiết 2" with amber badge "Khuyến nghị"
Bottom-left: "Chi tiết 3" with gray badge "Tùy chọn"
Bottom-right: "Chi tiết 4" with gray badge "Tùy chọn"
Each slot has dashed border and camera icon

Counter text "2/5 ảnh đã chụp" right-aligned gray.

Amber background card (#FFF3CD) "Ước tính số lượng rắn":
Question mark icon left
Text "Khoảng... con rắn"
Four chip buttons in row: "5-10", "10-20" (selected), "20-50", ">50"
Small text "Ước tính giúp Rescuer chuẩn bị đầy đủ"

White card "Vị Trí" with map pin and address.

Form section "Thông Tin Khu Vực":
- Dropdown "Loại môi trường" showing "Vườn"
- Text input "Đặc điểm khu vực" with value "Gần bụi cây, có nhiều lỗ"
- "Mức độ khẩn cấp" showing "CAO" chip selected and locked (disabled other options)

Blue background info box (#E3F2FD) with expert icon:
"Trường hợp này CẦN chuyên gia xử lý ổ rắn"
Small gray text "Phí dịch vụ có thể cao hơn. Báo giá sau khi đánh giá."

Bottom: Large red button "Gửi Yêu Cầu Khẩn Cấp →" (60px height).
Below: Gray text "Ưu tiên cao nhất - Phản hồi trong 5-10 phút"

Design: Emergency-focused, clear photo strategy, quantity estimation, specialist emphasis, high urgency visual treatment.
```

#### Notes for Stitch - MODE A:
- Mode toggle with warning for Mode B visible
- Warning banner phải prominent với red/orange color
- Overview photo slot phải largest và most prominent
- Quantity estimate slider/chips phải easy to use
- "Mức độ khẩn cấp" locked ở HIGH - không cho user change
- CTA button màu red thay vì green để nhấn mạnh emergency

#### Stitch Prompt - MODE B (Species Selection - NOT Recommended):

```
Mobile app nest species selection in "SnakeAid". Emergency design with strong amber warnings.

Top nav: Back arrow, title "Báo Cáo: Ổ Rắn / Nhiều Con", info icon.

Segmented control:
- Left "Chụp Ảnh Ổ Rắn" (gray, small green "Khuyến nghị" badge above)
- Right "Tôi Biết Loài Rắn" (selected, green background)

Strong amber warning banner (#FFF3CD, 4px left border #FFC107):
"⚠️ CHÚ Ý: Với ổ rắn, KHUYẾN CÁO chụp ảnh để chuyên gia đánh giá chính xác" bold 16pt
"Chỉ chọn loài nếu bạn CHẮC CHẮN 100% nhận biết được" gray 14pt
Blue text link "Tôi muốn chụp ảnh thay vì"

Heading "Thông tin về ổ rắn" bold dark gray.

Section A - "Loài rắn chủ đạo (Bắt buộc)" with red asterisk:
2-column grid showing nest-forming snakes (king cobra, rat snake, etc.). Cards similar to Mode A with photo, badges, features.
Small gray note: "Chọn loài chiếm đa số trong ổ"

Section B - "Số lượng ước tính (Bắt buộc)" with red asterisk:
4 horizontal chips in single row:
"5-10 con", "10-20 con" (selected, green), "20-50 con", ">50 con"

Section C - "Loại môi trường (Bắt buộc)" with red asterisk:
Dropdown showing "Đống gạch/đá" selected.
Options: Hốc cây, Dưới đất, Khác

Collapsible section "Bạn vẫn có thể thêm ảnh để hỗ trợ chuyên gia ▼":
When expanded shows 1-2 photo slots (dashed border, camera icon).
Note "Ảnh giúp chuyên gia chuẩn bị trang bị phù hợp" gray.

Location card with pin icon: "Vị trí: 123 Đường ABC" and "Chỉnh sửa" link.

Urgency section: "Mức độ khẩn cấp" with red "CAO" chip (locked, disabled state).

Blue specialist notice box (#E3F2FD):
Expert helmet icon
"CẦN chuyên gia xử lý ổ rắn"
"Phí dịch vụ có thể cao hơn. Báo giá sau khi đánh giá." gray

Red/orange pricing box (#FFEBEE, red left border 4px):
"Ước tính phí: 2,500,000 - 5,000,000 VNĐ" bold 18pt
"Giá chính xác sẽ được báo SAU KHI chuyên gia khảo sát hiện trường" gray 14pt

Large red button "Gọi Chuyên Gia Xử Lý Ổ Rắn →" (56px height, #DC3545).
Gray text "Bỏ qua AI - Chuyên gia sẽ liên hệ trong 5-10 phút"

Design: Warning-heavy interface, required field emphasis, optional photo encouragement, pricing transparency with range, emergency red CTA.
```

#### Notes for Stitch - MODE B:
- Warning banner must be very prominent to discourage this mode
- Link to switch back to Photo mode clearly visible
- Required fields marked with red asterisk
- Optional photo section collapsed by default but accessible
- Pricing range (2.5M-5M) clearly shown as estimate
- Red button emphasizes emergency nature

---

### Screen 2A: AI Snake Recognition Result - Single Snake

#### Thông tin màn hình:
- **Tên:** Màn hình kết quả nhận diện 1 con rắn
- **Mục đích:** Hiển thị kết quả phân tích AI về loài rắn và đưa ra 2 lựa chọn hành động
- **Flow position:** Sau Screen 1A - Khi AI phân tích xong 1 con rắn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Kết Quả Nhận Diện"
   - Close button (X)

2. **Report Summary Badge:**
   - Small gray badge: "1 con rắn đã phân tích"
   - Icon: Checkmark

3. **Photo Gallery Preview:**
   - Horizontal scrollable row showing uploaded photos (1-3 ảnh)
   - Primary photo highlighted with green border
   - Each thumbnail 80x80px with rounded corners
   - Tap to view full size

4. **AI Result Card:**
   - Badge: "AI Analysis" with robot icon
   - Snake name (Vietnamese + Scientific name)
   - Example: "Rắn hổ mang chúa (Ophiophagus hannah)"
   - Confidence level badge: "95% Chính xác"
   - Small info text: "Dựa trên 3 góc độ ảnh"

5. **Danger Level Indicator:**
   - Color-coded alert box (full-width):
     - High danger: Red background with "NGUY HIỂM CAO - RẮN ĐỘC MẠNH"
     - Medium: Amber with "CẢNH BÁO - RẮN ĐỘC VỪA"
     - Low: Green with "AN TOÀN - RẮN KHÔNG ĐỘC"
   - Icon: Warning triangle or checkmark
   - Risk description: "Loài này có thể gây nguy hiểm nghiêm trọng. Giữ khoảng cách và gọi chuyên gia."

6. **Snake Information Summary:**
   - Expandable section: "Thông Tin Loài Rắn"
   - When expanded shows 4 points:
     - Môi trường sống: Rừng, đồng cỏ
     - Hành vi: Hung dữ khi bị đe dọa
     - Phân bố: Đông Nam Á
     - Kích thước: 3-4 mét

7. **Location Confirmed:**
   - Small card with map pin icon
   - Text: "Vị trí: [Address]"
   - Size estimate: "Kích thước ước tính: Lớn"

8. **Recommendation Box:**
   - Light green background (#E8F5E9)
   - Icon: Thumbs up
   - Bold text: "Chúng tôi KHUYẾN NGHỊ gọi đội cứu hộ chuyên nghiệp"
   - Subtext: "An toàn, nhanh chóng và được bảo hiểm"

9. **Action Choice Section:**
   - Bold heading: "Bạn muốn làm gì tiếp theo?"
   - Three option cards (vertically stacked, 16px spacing):
     
     **Option A Card (PRIMARY - Highly Recommended):**
     - Large card, prominent design
     - Top-right badge: "KHUYẾN NGHỊ" (green background, white text)
     - Left icon: Rescue truck icon (48px, forest green)
     - Title: "Gọi Đội Cứu Hộ Chuyên Nghiệp" (20pt bold)
     - Subtitle: "Chuyên gia bắt rắn sẽ đến trong 15-30 phút"
     - Features list (small gray text):
       - "✓ An toàn và chuyên nghiệp"
       - "✓ Được bảo hiểm"
       - "✓ Đặt cọc chỉ 150,000 VNĐ"
     - Price preview: "Tổng phí: ≈ 575,000 VNĐ" (medium text)
     - Large green button inside card: "Chọn dịch vụ này →"
     - Forest green border (3px), card height 160px
     
     **Option B Card (SECONDARY - Expert Consultation):**
     - Medium card, professional design
     - Left icon: Video call/Expert icon (40px, blue #007BFF)
     - Title: "Đặt Lịch Tư Vấn Chuyên Gia" (18pt bold)
     - Subtitle: "Gọi video với chuyên gia về rắn để được tư vấn" (gray)
     - Features list (small gray text):
       - "✓ Tư vấn từ xa qua video"
       - "✓ Không cần di chuyển"
       - "✓ Đặt lịch linh hoạt"
     - Price: "500,000 VNĐ / 30 phút" (medium text)
     - Badge: "Có sẵn 24/7"
     - Medium blue outlined button inside card: "Đặt Lịch Ngay →"
     - Blue border (2px), card height 140px
     
     **Option C Card (ALTERNATIVE - Not Recommended for Dangerous Snakes):**
     - Smaller card, subtle design
     - Left icon: Bell icon (32px, gray)
     - Title: "Chỉ Cảnh Báo Cộng Đồng" (16pt)
     - Subtitle: "Thông báo cho người dùng gần đó" (gray)
     - Warning text (amber): "⚠️ Không xử lý rắn - Bạn tự chịu trách nhiệm"
     - Badge: "Miễn phí"
     - Small gray link: "Chọn tùy chọn này"
     - Light gray border (1px), card height 80px

#### Stitch Prompt (English):

```
Mobile app screen showing AI snake identification result for single snake in "SnakeAid". Modern clean interface with forest green (#228B22) brand color.

Top navigation: Back arrow left, centered title "Kết Quả Nhận Diện", X close button right.

Small badge at top: "1 con rắn đã phân tích" with checkmark icon, gray background.

Horizontal scrollable photo gallery showing 3 uploaded photos (80x80px each, rounded corners, 8px spacing). First photo has forest green border (2px) indicating primary image. Each thumbnail tappable.

Below gallery, prominent white card with subtle shadow. Top-left has small badge "AI Analysis" (forest green background, white text) with robot icon. Inside card: Large bold heading "Rắn hổ mang chúa" (24pt) in dark gray. Below, italic gray text "(Ophiophagus hannah)" (16pt). Right side has green badge "95% Chính xác". Small gray text below "Dựa trên 3 góc độ ảnh".

Full-width alert box with red background (#FFEBEE) and red left border (4px). Warning triangle icon left, bold red text "NGUY HIỂM CAO - RẮN ĐỘC MẠNH". Below in gray text: "Loài này có thể gây nguy hiểm nghiêm trọng. Giữ khoảng cách và gọi chuyên gia."

Expandable section "Thông Tin Loài Rắn ▼" (collapsed state shown). When expanded shows 4 bullet points:
• Môi trường sống: Rừng, đồng cỏ
• Hành vi: Hung dữ khi bị đe dọa
• Phân bố: Đông Nam Á
• Kích thước: 3-4 mét

Small white card with map pin icon: "Vị trí: 123 Đường ABC, Quận XYZ" and "Kích thước ước tính: Lớn" in gray.

Light green recommendation box (#E8F5E9) with thumbs up icon:
"Chúng tôi KHUYẾN NGHỊ gọi đội cứu hộ chuyên nghiệp" bold
"An toàn, nhanh chóng và được bảo hiểm" gray subtext

Heading "Bạn muốn làm gì tiếp theo?" (20pt bold) in dark gray.

Three vertically stacked cards (16px spacing):

CARD 1 (PRIMARY - Large, prominent):
Top-right green badge "KHUYẾN NGHỊ" (white text)
Left: Large rescue truck icon (48px, forest green)
Center section:
- Title "Gọi Đội Cứu Hộ Chuyên Nghiệp" (20pt bold)
- Subtitle "Chuyên gia bắt rắn sẽ đến trong 15-30 phút" (14pt gray)
- Features list in small gray text:
  ✓ An toàn và chuyên nghiệp
  ✓ Được bảo hiểm
  ✓ Đặt cọc chỉ 150,000 VNĐ
- Price "Tổng phí: ≈ 575,000 VNĐ" (16pt medium gray)
- Large green button inside card "Chọn dịch vụ này →" (full width, 48px height)
Forest green border (3px), card total height 160px

CARD 2 (SECONDARY - Medium, professional):
Left: Video call/Expert icon (40px, blue #007BFF)
Center section:
- Title "Đặt Lịch Tư Vấn Chuyên Gia" (18pt bold)
- Subtitle "Gọi video với chuyên gia về rắn để được tư vấn" (14pt gray)
- Features list in small gray text:
  ✓ Tư vấn từ xa qua video
  ✓ Không cần di chuyển
  ✓ Đặt lịch linh hoạt
- Price "500,000 VNĐ / 30 phút" (16pt medium gray)
- Top-right badge "Có sẵn 24/7" (blue background, white text)
- Medium blue outlined button inside card "Đặt Lịch Ngay →" (full width, 44px height)
Blue border (2px), card total height 140px

CARD 3 (ALTERNATIVE - Smaller, subtle):
Left: Bell icon (32px, gray)
Center: Title "Chỉ Cảnh Báo Cộng Đồng" (16pt), subtitle "Thông báo cho người dùng gần đó" gray
Amber warning text "⚠️ Không xử lý rắn - Bạn tự chịu trách nhiệm"
Top-right: Gray badge "Miễn phí"
Small gray text link "Chọn tùy chọn này" (no arrow)
Light gray border (1px), card height 80px

Design: Clean result display, photo gallery preview, clear danger indication, three-tier action choices with expert consultation option, Vietnamese-focused, pricing transparency.
```

#### Notes for Stitch:
- Photo gallery phải scrollable horizontally nếu có nhiều ảnh
- Danger level alert phải full-width và prominent với color-coded (red/amber/green)
- Card hierarchy rõ ràng: Card 1 (PRIMARY) 160px > Card 2 (SECONDARY) 140px > Card 3 (ALTERNATIVE) 80px
- Card 1 (Rescue) emphasized với green border 3px và "KHUYẾN NGHỊ" badge
- Card 2 (Expert Consultation) professional với blue theme (#007BFF), medium size
- Card 3 (Community Alert) minimal và discouraged
- Each card có pricing rõ ràng để user compare: 575K vs 500K/30min vs Free
- Features list (✓) giúp user understand benefits

---

### Screen 2B: AI Snake Recognition Result - Multiple Snakes

#### Thông tin màn hình:
- **Tên:** Màn hình kết quả nhận diện nhiều con rắn (2-5 con)
- **Mục đích:** Hiển thị kết quả phân tích AI cho từng con rắn và tổng hợp
- **Flow position:** Sau Screen 1B - Khi AI phân tích xong 2-5 con rắn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Kết Quả Nhận Diện"
   - Close button (X)

2. **Summary Overview Card:**
   - Badge: "Đã phân tích hoàn tất"
   - Summary stats:
     - "Tổng số: X con rắn"
     - "Số loài khác nhau: Y loài"
     - "Độc tính cao nhất: [Level]"

3. **Individual Snake Results (Expandable List):**
   - Vertical list of result cards, 1 card per snake
   - Each card shows:
     
     **Snake Card (#1, #2, #3...):**
     - Collapsed state:
       - Number badge: "Con rắn #1"
       - Thumbnail photo (60x60px)
       - Snake name: "Rắn hổ mang chúa"
       - Danger badge: Red/Amber/Green
       - Expand arrow "▼"
     
     - Expanded state:
       - Full photo preview
       - Scientific name
       - Confidence: "92% Chính xác"
       - Danger level alert box (compact)
     Strong Recommendation Box:**
   - Orange/amber background (#FFF3CD) with warning icon
   - Bold text: "KHUYẾN CÁO MẠNH: Nhiều con rắn CẦN đội chuyên nghiệp"
   - Subtext: "Tự xử lý rất nguy hiểm - Chúng tôi KHÔNG khuyến nghị"

8. **Action Section:**
   - Heading: "Hành động được khuyến nghị:"
   - Two option cards (large spacing):
     
     **Option A (REQUIRED ACTION - Highly Emphasized):**
     - Extra large card with emphasis
     - Top banner: Red badge "KHUYẾN CÁO MẠNH" spanning width
     - Left icon: Team/Multiple rescuers icon (56px, forest green)
     - Title: "Gọi Đội Cứu Hộ Chuyên Nghiệp" (22pt bold)
     - Subtitle: "Xử lý nhiều con rắn an toàn và hiệu quả"
     - Key features (checkmarks):
       - "✓ Đội ngũ 2+ người có kinh nghiệm"
       - "✓ Trang bị chuyên dụng đầy đủ"
       - "✓ Được bảo hiểm toàn diện"
       - "✓ Đặt cọc 150,000 VNĐ - Trả sau khi hoàn tất"
     - Price: "Tổng ước tính: XXX,XXX VNĐ" (large, bold)
     - Very large green button: "YÊU CẦU DỊCH VỤ NGAY →" (56px height)
     - Forest green border (4px), card height 200px
     
     **Option B (STRONGLY DISCOURAGED):**
     - Small, heavily dimmed card (opacity 0.5)
     - Disabled appearance
     - Icon: Bell (gray, small 24px)
     - Title: "Chỉ Cảnh Báo Cộng Đồng" (crossed out style)
     - Red warning box: "🚫 KHÔNG KHUYẾN NGHỊ"
     - Warning list:
       - "• Không xử lý rắn"
       - "• Nguy hiểm cao với nhiều con"
       - "• Bạn hoàn toàn tự chịu trách nhiệm"
     - Gray text link: "Tôi hiểu rủi ro và vẫn muốn chọn"
     - Red dashed border (2px), card height 100px phí:"
   - Breakdown:
     - "Phí cơ bản: 575,000 VNĐ × X con"
     - "Tổng ước tính: XXX,XXX VNĐ"
   - Note: "Giá chính xác sau khi Rescuer đánh giá hiện trường"

7. **Action Choice Section:**
   - Heading: "Bạn muốn làm gì tiếp theo?"
   - Two option cards:
     
     **Option A (Strongly Recommended):**
     - Badge: "KHUYẾN CÁO MẠNH" (red badge)
     - Icon: Team/Multiple rescuers icon
     - Title: "Gọi Đội Cứu Hộ Chuyên Nghiệp"
     - Subtitle: "Xử lý nhiều con rắn an toàn"
     - Price: "≈ XXX,XXX VNĐ"
     - Note: "Có thể cần 2+ người hỗ trợ"
     - Right arrow
     
     **Option B (Not Recommended):**
     - Dimmed/grayed out appearance
     - Icon: Bell (gray)
     - Title: "Chỉ Cảnh Báo Cộng Đồng"
     - Warning text: "⚠️ Không khuyến nghị cho nhiều con rắn"
     - Badge: "Miễn phí"

#### Stitch Prompt (English):

```
Mobile app screen showing AI results for multiple snakes (2-5) in "SnakeAid". Complex data display with forest green (#228B22) primary color.

Top navigation: Back arrow left, title "Kết Quả Nhận Diện", X close button right.

Summary card at top with green background (#E8F5E9):
Badge "Đã phân tích hoàn tất" with checkmark
Three stats in row:
"Tổng số: 3 con rắn" | "Số loài: 2 loài khác nhau" | "Độc tính: CAO"

Below summary, vertical list of snake result cards (12px spacing):

CARD #1 (expanded state):
White card with shadow
Top: Badge "Con rắn #1" (forest green), thumbnail 60x60px, "Rắn hổ mang chúa" bold, red danger badge
Expanded content:
- Larger photo 200x150px
- "(Ophiophagus hannah)" italic gray
- "92% Chính xác" green badge
- Compact red alert box "NGUY HIỂM CAO - ĐỘC MẠNH"
- "Ghi chú: Trong vườn" in gray
- 2 bullet points: Môi trường, Hành vi

CARD #2 (collapsed state):
Badge "Con rắn #2", thumbnail, "Rắn lục đuôi đỏ", amber danger badge, down arrow "▼"

CARD #3 (collapsed state):
Badge "Con rắn #3", thumbnail, "Rắn hổ mang chúa", red danger badge, down arrow "▼"

Large red/orange alert card (#FFEBEE):
Warning shield icon left
"Mức độ nguy hiểm tổng thể: CAO" bold red (20pt)
"Có 3 con rắn độc trong số 3 con" gray text
"Khuyến nghị GỌI chuyên gia ngay" bold

Small map card: "Tất cả rắn ở: 123 Đường ABC, Quận XYZ" with note "Khu vực rộng - Cần kiểm tra toàn diện"

Amber pricing box (#FFF3CD):
Calculator icon, heading "Ước tính chi phí:"
"Phí cơ bản: 575,000 VNĐ × 3 con"
"Tổng ước tính: 1,725,000 VNĐ" (bold, large)
Small gray note "Giá chính xác sau khi Rescuer đánh giá hiện trường"

Orange recommendation box (#FFF3CD) with warning icon:
"KHUYẾN CÁO MẠNH: Nhiều con rắn CẦN đội chuyên nghiệp" bold
"Tự xử lý rất nguy hiểm - Chúng tôi KHÔNG khuyến nghị" gray

Heading "Hành động được khuyến nghị:" bold

CARD A (PRIMARY - Extra large, emphasized):
Top banner spanning width: Red badge "KHUYẾN CÁO MẠNH" (white text)
Left: Team icon 56px (multiple rescuers, forest green)
Center section:
- Title "Gọi Đội Cứu Hộ Chuyên Nghiệp" (22pt bold)
- Subtitle "Xử lý nhiều con rắn an toàn và hiệu quả" gray
- Checkmarked features:
  ✓ Đội ngũ 2+ người có kinh nghiệm
  ✓ Trang bị chuyên dụng đầy đủ
  ✓ Được bảo hiểm toàn diện
  ✓ Đặt cọc 150,000 VNĐ - Trả sau khi hoàn tất
- Price "Tổng ước tính: 1,725,000 VNĐ" (20pt bold)
- Very large green button "YÊU CẦU DỊCH VỤ NGAY →" (56px height, full width)
Forest green border (4px), total card height 200px

CARD B (SECONDARY - Medium, professional):
Left: Video call/Expert icon 40px (blue #007BFF)
Center section:
- Title "Đặt Lịch Tư Vấn Chuyên Gia" (18pt bold)
- Subtitle "Gọi video với chuyên gia về rắn để được tư vấn" (14pt gray)
- Checkmarked features (small gray text):
  ✓ Tư vấn từ xa qua video
  ✓ Không cần di chuyển
  ✓ Đặt lịch linh hoạt
- Price "500,000 VNĐ / 30 phút" (16pt medium, gray)
- Top-right badge: "Có sẵn 24/7" (blue background, white text, 12pt)
- Medium blue outlined button inside card: "Đặt Lịch Ngay →" (full width, 44px height)
Blue border (2px), card total height 140px

CARD C (DISCOURAGED - Small, dimmed):
Opacity 0.5, disabled appearance
Bell icon 24px gray
Title "Chỉ Cảnh Báo Cộng Đồng" with strikethrough style
Red warning box "🚫 KHÔNG KHUYẾN NGHỊ"
Warning list:
• Không xử lý rắn
• Nguy hiểm cao với nhiều con
• Bạn hoàn toàn tự chịu trách nhiệm
Small gray text link "Tôi hiểu rủi ro và vẫn muốn chọn" (no button)
Red dashed border (2px), height 100px

Design: Complex data visualization, expandable cards, clear danger aggregation, pricing transparency, strong recommendation guidance.
```

#### Notes for Stitch:
- Snake cards phải expandable - tap to expand/collapse
- Summary stats phải prominent ở đầu page
- Overall risk assessment phải based on highest danger level
- Pricing calculation rõ ràng: 575K × số lượng (ví dụ: 3 con = 1,725,000 VNĐ)
- THREE CARDS with hierarchy: Card 1 (PRIMARY) 200px > Card 2 (SECONDARY) 140px > Card 3 (DISCOURAGED) 100px
- Card 1 (Rescue): Forest green border 4px, "KHUYẾN CÁO MẠNH" badge, very large button
- Card 2 (Expert Consultation): Blue theme #007BFF, medium size, "Có sẵn 24/7" badge, outlined button
- Card 3 (Community Alert): Dimmed/discouraged, opacity 0.5, no real button
- Pricing comparison: 1,725K (for 3 snakes) vs 500K/30min vs Free
- Features list with ✓ checkmarks giúp user understand benefits of each option
- Card 3 phải dimmed/discouraged cho nhiều con rắn (unsafe)

---

### Screen 2C: AI Snake Recognition Result - Snake Nest

#### Thông tin màn hình:
- **Tên:** Màn hình kết quả phân tích ổ rắn
- **Mục đích:** Hiển thị kết quả phân tích cho trường hợp ổ rắn/nhiều con rắn
- **Flow position:** Sau Screen 1C - Khi AI phân tích xong ổ rắn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Kết Quả Phân Tích"
   - Close button (X)

2. **Critical Alert Banner:**
   - Red background with warning stripes pattern
   - Large warning icon
   - Bold text: "PHÁT HIỆN Ổ RẮN / NHIỀU CON RẮN"
   - Subtext: "Tình huống nguy hiểm - Yêu cầu chuyên gia"

3. **Analysis Summary Card:**
   - Badge: "AI Analysis - Complex Situation"
   - Detected information:
     - "Loài chính: [Snake name]" (nếu AI detect được)
     - "Số lượng ước tính: X-Y con" (based on user input + AI)
     - "Khu vực: [Environment type]"
     - "Mức độ rủi ro: CỰC KỲ CAO"

4. **Photo Analysis Grid:**
   - Grid showing uploaded photos (2-5 ảnh)
   - Labels:
     - "Ảnh tổng thể" (overview photo)
     - "Chi tiết 1-4" (detail photos)
   - Tap to view full size
   - AI annotations: "Phát hiện X con rắn trong ảnh này"

5. **Danger Assessment:**
   - Large red alert box
   - Icon: Skull/Extreme danger
   - Text: "NGUY HIỂM CỰC KỲ CAO"
   - Bullet points:
     - "Nhiều con rắn trong khu vực nhỏ"
     - "Có thể có rắn mẹ và đàn con"
     - "Rất hung dữ khi bảo vệ ổ"
     - "CẤM tiếp cận - Nguy hiểm chết người"

6. **Expert Assessment Required:**
   - Yellow/amber card with warning stripes
   - Icon: Expert/Specialist helmet
   - Title: "CẦN CHUYÊN GIA XỬ LÝ Ổ RẮN"
   - Details:
     - "✓ Đội ngũ có kinh nghiệm ổ rắn"
     - "✓ Trang bị chuyên dụng đầy đủ"
     - "✓ Có thể cần 2-4 người hỗ trợ"
     - "✓ Thời gian xử lý: 2-4 giờ"

7. **Location & Environment:**
   - Map card
   - Full address
   - Environment details from user input
   - Note: "Khu vực nguy hiểm - Đã cảnh báo người xung quanh"

8. **Pricing Estimate (Complex):**
   - Amber box with calculator icon
   - Heading: "Ước tính chi phí (Phức tạp)"
   - Breakdown:
     - "Phí cơ bản ổ rắn: 1,500,000 VNĐ"
     - "Phí theo số lượng: 575,000 × X con"
     - "Phí chuyên gia: 500,000 - 1,000,000 VNĐ"
     - "Trang bị đặc biệt: 200,000 - 500,000 VNĐ"
   - Total range: "Tổng ước tính: 2,500,000 - 5,000,000 VNĐ"
   - Important note: "Giá chính xác SAU khi chuyên gia khảo sát hiện trường"

9. **Action Section:**
   - Heading: "Hành động được khuyến nghị:"
   - Three option cards with strong recommendation:
     
     **Option A Card (PRIMARY - Extra large, emergency):**
     - Top banner spanning width: Red badge "KHUYẾN CÁO MẠNH" (white text)
     - Left: Emergency/Specialist icon 56px (red #DC3545)
     - Center section:
       - Title "Gọi Chuyên Gia Xử Lý Ổ Rắn" (22pt bold)
       - Subtitle "Đội ngũ chuyên gia xử lý tình huống phức tạp" gray
       - Checkmarked features:
         ✓ Chuyên gia có kinh nghiệm ổ rắn
         ✓ Đội ngũ 2-4 người hỗ trợ
         ✓ Trang bị đặc biệt đầy đủ
         ✓ Đặt cọc 150,000 VNĐ - Giá chính xác sau khảo sát
       - Price range "Ước tính: 2,500,000 - 5,000,000 VNĐ" (20pt bold)
       - Very large red button "YÊU CẦU DỊCH VỤ NGAY →" (56px height, full width)
     - Red border (4px), total card height 200px
     
     **Option B Card (SECONDARY - Medium, professional):**
     - Left: Video call/Expert icon 40px (blue #007BFF)
     - Center section:
       - Title "Đặt Lịch Tư Vấn Chuyên Gia" (18pt bold)
       - Subtitle "Gọi video với chuyên gia để được tư vấn sơ bộ" (14pt gray)
       - Checkmarked features (small gray text):
         ✓ Tư vấn từ xa qua video
         ✓ Không cần di chuyển
         ✓ Đặt lịch linh hoạt
       - Price "500,000 VNĐ / 30 phút" (16pt medium, gray)
       - Top-right badge: "Có sẵn 24/7" (blue background, white text, 12pt)
       - Medium blue outlined button inside card: "Đặt Lịch Ngay →" (full width, 44px height)
     - Blue border (2px), card total height 140px
     - Warning note below card (amber): "⚠️ Tư vấn không thay thế xử lý trực tiếp cho ổ rắn"
     
     **Option C Card (DISCOURAGED - Small, dimmed):**
     - Opacity 0.3, highly discouraged appearance
     - Bell icon 24px gray
     - Title "Chỉ Cảnh Báo Cộng Đồng" with strikethrough style
     - Red warning box "🚫 KHÔNG KHUYẾN NGHỊ - CỰC KỲ NGUY HIỂM"
     - Warning list:
       • Không xử lý ổ rắn
       • Nguy hiểm chết người
       • Bạn hoàn toàn tự chịu trách nhiệm
     - Small gray text link "Tôi hiểu rủi ro và vẫn muốn chọn" (no button)
     - Red dashed border (2px), height 100px

10. **Safety Instructions:**
    - Collapsible red box: "Hướng dẫn an toàn trong khi chờ"
    - When expanded:
      - "1. GIỮ khoảng cách an toàn tối thiểu 10 mét"
      - "2. KHÔNG cố gắng tiếp cận hoặc tự xử lý"
      - "3. CẢNH BÁO người xung quanh không đến gần"
      - "4. GIỮ trẻ em và thú cưng xa khu vực"
      - "5. CHỜ chuyên gia đến - Không vội vàng"

#### Stitch Prompt (English):

```
Mobile app emergency screen showing snake nest analysis result in "SnakeAid". Critical emergency design with red (#DC3545) primary accent.

Top navigation: Back arrow left, title "Kết Quả Phân Tích", X close button right.

Critical alert banner at top with red background (#DC3545) and diagonal warning stripes pattern:
Large warning triangle icon (white)
Bold white text "PHÁT HIỆN Ổ RẮN / NHIỀU CON RẮN" (24pt)
Subtext "Tình huống nguy hiểm - Yêu cầu chuyên gia" white (16pt)

White card with badge "AI Analysis - Complex Situation" (red background):
"Loài chính: Rắn hổ mang chúa" bold
"Số lượng ước tính: 15-20 con" 
"Khu vực: Vườn/Bụi rậm"
"Mức độ rủi ro: CỰC KỲ CAO" (red text, large)

Photo grid (2x3 layout) showing 5 uploaded photos:
Top row: Large overview photo with label "Ảnh tổng thể", annotation "Phát hiện 12+ con rắn"
Bottom row: 4 smaller detail photos labeled "Chi tiết 1-4"
Each 150x150px, rounded corners, tap to enlarge

Large red alert box (#FFEBEE) with extreme danger icon:
Heading "NGUY HIỂM CỰC KỲ CAO" bold red (22pt)
Four bullet points:
• Nhiều con rắn trong khu vực nhỏ
• Có thể có rắn mẹ và đàn con
• Rất hung dữ khi bảo vệ ổ
• CẤM tiếp cận - Nguy hiểm chết người

Yellow/amber card (#FFF3CD) with warning stripes border:
Expert helmet icon
Title "CẦN CHUYÊN GIA XỬ LÝ Ổ RẮN" bold (20pt)
Four checkmarked items:
✓ Đội ngũ có kinh nghiệm ổ rắn
✓ Trang bị chuyên dụng đầy đủ
✓ Có thể cần 2-4 người hỗ trợ
✓ Thời gian xử lý: 2-4 giờ

Map card with location and environment details.

Amber pricing box with calculator icon:
Heading "Ước tính chi phí (Phức tạp)"
Breakdown:
Phí cơ bản ổ rắn: 1,500,000 VNĐ
Phí theo số lượng: 575,000 × 18 con
Phí chuyên gia: 500,000 - 1,000,000 VNĐ
Trang bị đặc biệt: 200,000 - 500,000 VNĐ
Divider line
"Tổng ước tính: 2,500,000 - 5,000,000 VNĐ" bold large (22pt)
Small note "Giá chính xác SAU khi chuyên gia khảo sát hiện trường"

Heading "Hành động được khuyến nghị:" bold

CARD 1 (PRIMARY - Extra large, emergency):
Top banner spanning width: Red badge "KHUYẾN CÁO MẠNH" (white text)
Left: Emergency/Specialist icon 56px (red #DC3545)
Center section:
- Title "Gọi Chuyên Gia Xử Lý Ổ Rắn" (22pt bold)
- Subtitle "Đội ngũ chuyên gia xử lý tình huống phức tạp" gray
- Checkmarked features:
  ✓ Chuyên gia có kinh nghiệm ổ rắn
  ✓ Đội ngũ 2-4 người hỗ trợ
  ✓ Trang bị đặc biệt đầy đủ
  ✓ Đặt cọc 150,000 VNĐ - Giá chính xác sau khảo sát
- Price range "Ước tính: 2,500,000 - 5,000,000 VNĐ" (20pt bold)
- Very large red button "YÊU CẦU DỊCH VỤ NGAY →" (56px height, full width)
Red border (4px), total card height 200px

CARD 2 (SECONDARY - Medium, professional):
Left: Video call/Expert icon 40px (blue #007BFF)
Center section:
- Title "Đặt Lịch Tư Vấn Chuyên Gia" (18pt bold)
- Subtitle "Gọi video với chuyên gia để được tư vấn sơ bộ" (14pt gray)
- Checkmarked features (small gray text):
  ✓ Tư vấn từ xa qua video
  ✓ Không cần di chuyển
  ✓ Đặt lịch linh hoạt
- Price "500,000 VNĐ / 30 phút" (16pt medium, gray)
- Top-right badge: "Có sẵn 24/7" (blue background, white text, 12pt)
- Medium blue outlined button inside card: "Đặt Lịch Ngay →" (full width, 44px height)
Blue border (2px), card total height 140px
Amber warning below: "⚠️ Tư vấn không thay thế xử lý trực tiếp cho ổ rắn"

CARD 3 (DISCOURAGED - Small, dimmed):
Opacity 0.3, highly discouraged
Bell icon 24px gray
Title "Chỉ Cảnh Báo Cộng Đồng" with strikethrough
Red warning box "🚫 KHÔNG KHUYẾN NGHỊ - CỰC KỲ NGUY HIỂM"
Warning list:
• Không xử lý ổ rắn
• Nguy hiểm chết người
• Bạn hoàn toàn tự chịu trách nhiệm
Small gray text link "Tôi hiểu rủi ro và vẫn muốn chọn" (no button)
Red dashed border (2px), height 100px

Collapsible red-bordered box "Hướng dẫn an toàn trong khi chờ ▼"
When expanded shows 5 numbered safety instructions

Design: Emergency-critical interface with three-tier options, strong red accents for primary action, expert consultation available but with warnings, extensive safety warnings, pricing transparency for complex situation, community alert highly discouraged.
```

#### Notes for Stitch:
- Warning banner phải most prominent element với stripes pattern
- Photo grid phải show AI annotations về số lượng rắn detected
- Pricing range rộng (2.5M-5M) vì complexity cao - user cần understand
- THREE CARDS with strong recommendation hierarchy: Card 1 (PRIMARY) 200px > Card 2 (SECONDARY) 140px > Card 3 (HIGHLY DISCOURAGED) 100px
- Card 1 (Rescue Specialist): Red theme #DC3545, "KHUYẾN CÁO MẠNH" badge, extra large button, emergency styling
- Card 2 (Expert Consultation): Blue theme #007BFF, "Có sẵn 24/7" badge, outlined button, with warning that consultation doesn't replace physical handling
- Card 3 (Community Alert): Opacity 0.3 (highly dimmed), strikethrough title, "KHÔNG KHUYẾN NGHỊ - CỰC KỲ NGUY HIỂM" warning
- Pricing comparison: 2.5M-5M (range, survey-based) vs 500K/30min vs Free
- Card 3 must be EXTREMELY discouraged for nest situations (much more than screens 2A/2B)
- Expert consultation card includes amber warning below: "Tư vấn không thay thế xử lý trực tiếp"
- KHÔNG có option "Community Alert" - too dangerous
- Only 1 CTA button - emergency red color
- Safety instructions collapsible nhưng nên default expanded

---

### Screen 3: Post Rescue Request (First Come First Served)

#### Thông tin màn hình:
- **Tên:** Màn hình đăng yêu cầu cứu hộ lên hệ thống
- **Mục đích:** Xác nhận thông tin và đăng request lên Job Board (KHÔNG thanh toán trước)
- **Flow position:** Sau Screen 2 → User chọn "Gọi Đội Cứu Hộ"
- **Priority:** ⭐⭐⭐
- **Model:** First Come First Served - Rescuers trong bán kính sẽ thấy đơn và nhận trực tiếp

> **💡 LƯU Ý:** Model mới - KHÔNG CÓ deposit payment, KHÔNG CÓ matching. Patient đăng request → Wait → Rescuer nhận → Start

#### Key Components:

1. **Header:**
   - Back button (top-left)
   - Title: "Xác Nhận Yêu Cầu Cứu Hộ"
   - Info icon (top-right)

2. **Request Summary Card:**
   - Title: "Thông Tin Yêu Cầu" (18pt, bold)
   - **Snake Info:**
     - AI detected thumbnail (100×100px)
     - "Rắn hổ mang chúa" (20pt, bold)
     - Danger badge: "ĐỘC MẠNH" (red) / "ĐỘC TB" (amber) / "KHÔNG ĐỘC" (green)
     - "AI: 92% chính xác" (blue, 14pt)
     - "Số lượng: 1 con rắn" (16pt, gray)
   - Edit link: "Chỉnh sửa ảnh/thông tin" (blue, 14pt)

3. **Location Card:**
   - Icon: Map pin (green)
   - **Address:** "123 Nguyễn Văn Linh, P.Tân Hưng, Q.7, TP.HCM" (16pt, bold)
   - Small map preview (full width, 120px height)
   - Link: "Chỉnh sửa vị trí" (blue, 14pt)

4. **Radar Search Explanation** (NEW - Important):
   - Light blue info card (#E7F3FF)
   - Icon: Radar icon (blue, animated pulse)
   - Title: "Cách Hệ Thống Tìm Rescuer" (18pt, bold)
   - **3-tier search logic:**
     
     **Tier 1 (Priority):**
     - "🎯 Ưu tiên: Tìm trong bán kính 10km"
     - "Thời gian phản hồi: 2-5 phút"
     - Green badge "NHANH NHẤT"
     
     **Tier 2 (If needed):**
     - "📡 Nếu không đủ: Mở rộng 20km"
     - "Thời gian phản hồi: 5-10 phút"
     - Amber badge "KHẢ NĂNG CAO"
     
     **Tier 3 (Maximum):**
     - "🔍 Tối đa: Mở rộng 30km"
     - "Thời gian phản hồi: 10-15 phút"
     - Orange badge "DỰ PHÒNG"
   
   - Note: "Hệ thống sẽ thông báo bạn khi mở rộng bán kính" (gray, italic, 12pt)

5. **Price Information** (NEW - No deposit):
   - Title: "Chi Phí Dịch Vụ" (18pt, bold)
   - **Estimated Price:**
     - "Giá dự kiến: 575,000 VNĐ" (forest green #228B22, bold, 28pt)
     - Breakdown (collapsible):
       - Phí cứu hộ: 500,000 VNĐ
       - Phí nền tảng (10%): 50,000 VNĐ
       - Quỹ bảo hiểm (5%): 25,000 VNĐ
   
   - **Important Note Card** (amber background #FFF9E6):
     - Icon: Info circle (amber)
     - Text: "⚠️ Thanh toán SAU KHI hoàn thành" (bold, 16pt)
     - Subtext: "Giá cuối cùng dựa trên:" (14pt)
       • Độ khó thực tế
       • Khoảng cách di chuyển
       • Thời gian xử lý
     - "KHÔNG CẦN thanh toán trước" (green text, bold, 16pt)

6. **Additional Notes** (optional):
   - Text area input (120px height)
   - Placeholder: "Ghi chú thêm cho rescuer (tùy chọn)"
   - Example: "Rắn trong vườn, gần hồ nước. Xin đến trước 6pm"
   - Character limit: 200 characters
   - Counter: "0/200"

7. **Urgency Level:**
   - Title: "Mức Độ Khẩn Cấp" (16pt, bold)
   - 3 radio chips:
     - "Thấp - Trong ngày OK" (gray outline)
     - "Trung Bình - Trong 2-3 giờ" (amber outline, selected)
     - "Cao - Càng sớm càng tốt" (red outline)

8. **How It Works Timeline:**
   - Title: "Quy Trình Tiếp Theo" (18pt, bold)
   - 4 steps with icons and connecting lines:
     
     **Step 1:** 
     - Icon: Upload (green circle)
     - "Đăng yêu cầu lên hệ thống"
     - "Rescuers trong 10-30km sẽ thấy"
     
     **Step 2:**
     - Icon: Eye (blue circle)
     - "Rescuers xem và nhận đơn"
     - "Ai nhận trước người đó làm"
     
     **Step 3:**
     - Icon: Navigation (orange circle)
     - "Rescuer đã chọn di chuyển đến"
     - "Bạn theo dõi trên bản đồ real-time"
     
     **Step 4:**
     - Icon: Checkmark (green circle)
     - "Hoàn thành và thanh toán"
     - "Đánh giá rescuer"

9. **Terms Checkbox:**
   - Checkbox (unchecked by default)
   - Text: "Tôi đã đọc và đồng ý với điều khoản dịch vụ cứu hộ rắn"
   - Link: "Xem điều khoản" (blue)

10. **Action Buttons (sticky bottom, white background, shadow):**

**Primary Button:**
- Text: "ĐĂNG YÊU CẦU CỨU HỘ"
- Full width, 60px height
- Forest green background #228B22
- White text, bold, 18pt
- Disabled until terms checkbox checked
- Icon: Upload cloud (left)

**Secondary Link:**
- "Hủy và quay lại" (gray, center, 14pt)

#### Stitch Prompt (English):

```
Mobile app post rescue request screen (First Come First Served model). Forest green (#228B22) primary color on white background.

Top navigation: Back arrow left, "Xác Nhận Yêu Cầu Cứu Hộ" title centered bold, info icon right.

Request summary card (white, shadow, 12px rounded):
- "Thông Tin Yêu Cầu" (bold 18pt)
- Snake thumbnail 100×100px left + info right:
  - "Rắn hổ mang chúa" (20pt bold)
  - Red badge "ĐỘC MẠNH"
  - "AI: 92% chính xác" (blue 14pt)
  - "Số lượng: 1 con rắn" (16pt gray)
- Blue link "Chỉnh sửa ảnh/thông tin"

Location card:
- Green pin icon + "123 Nguyễn Văn Linh, P.Tân Hưng, Q.7, TP.HCM" (16pt bold)
- Map preview 120px height
- Blue link "Chỉnh sửa vị trí"

Radar search explanation card (light blue #E7F3FF, 12px rounded):
- Animated radar icon (blue, pulse effect) top
- "Cách Hệ Thống Tìm Rescuer" (18pt bold)

Three-tier search display (vertical):
TIER 1 box (light green background):
- "🎯 Ưu tiên: Tìm trong bán kính 10km"
- "Thời gian phản hồi: 2-5 phút"
- Green badge "NHANH NHẤT"

TIER 2 box (light amber background):
- "📡 Nếu không đủ: Mở rộng 20km"
- "Thời gian phản hồi: 5-10 phút"
- Amber badge "KHẢ NĂNG CAO"

TIER 3 box (light orange background):
- "🔍 Tối đa: Mở rộng 30km"
- "Thời gian phản hồi: 10-15 phút"
- Orange badge "DỰ PHÒNG"

Below: Gray italic "Hệ thống sẽ thông báo bạn khi mở rộng bán kính"

Price card (white, shadow):
- "Chi Phí Dịch Vụ" (bold 18pt)
- "Giá dự kiến: 575,000 VNĐ" (green bold 28pt)
- Expandable breakdown (collapsed by default)

Amber payment note card (#FFF9E6):
- Amber info icon
- "⚠️ Thanh toán SAU KHI hoàn thành" (bold 16pt)
- "Giá cuối cùng dựa trên:" with 3 bullets
- Green text "KHÔNG CẦN thanh toán trước" (bold 16pt)

Text area "Ghi chú thêm cho rescuer (tùy chọn)" (120px height, gray border)
Character counter "0/200" bottom-right

Urgency level (3 radio chips horizontal):
- "Thấp - Trong ngày OK" (gray outline)
- "Trung Bình - Trong 2-3 giờ" (amber outline, selected)
- "Cao - Càng sớm càng tốt" (red outline)

Timeline "Quy Trình Tiếp Theo" with 4 connected steps:
- Step 1: Green circle upload icon + text
- Step 2: Blue circle eye icon + text
- Step 3: Orange circle navigation icon + text
- Step 4: Green circle checkmark icon + text
Connecting lines between steps

Terms checkbox + "Tôi đã đọc và đồng ý..." with blue "Xem điều khoản" link

Bottom sticky (white, shadow):
- Large green button "ĐĂNG YÊU CẦU CỨU HỘ" (60px, white text, cloud icon)
- Below: Gray link "Hủy và quay lại"

Design: Clear request confirmation, radar search explanation, no payment required, transparent process, First Come First Served model.
```

#### Notes for Stitch:
- Radar search explanation QUAN TRỌNG - phải rõ ràng về 3 tiers (10km → 20km → 30km)
- KHÔNG CÓ payment section - chỉ hiển thị giá dự kiến
- Amber note "Thanh toán SAU KHI hoàn thành" phải prominent
- Timeline process phải clear - patient hiểu flow
- Button disabled until checkbox checked
- Radar icon có pulse animation

---

### Screen 3 (OLD - TO BE DELETED): Request Rescue Service - Rescuer Matching

**Screen 3 has 3 variants based on snake quantity selected in Screen 1:**
- **Screen 3A:** Single snake (575,000 VNĐ total)
- **Screen 3B:** Multiple snakes (575,000 × quantity VNĐ total)
- **Screen 3C:** Snake nest (2,500,000 - 5,000,000 VNĐ range)

All variants use **SAME 150,000 VNĐ fixed deposit** mechanism.

---

### Screen 3A: Deposit Payment - Single Snake

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận cứu hộ 1 con rắn và thanh toán đặt cọc
- **Mục đích:** Hiển thị phí dịch vụ 575K, thanh toán đặt cọc 150K và xác nhận yêu cầu
- **Flow position:** Sau Screen 2A → User chọn "Gọi Đội Cứu Hộ"
- **Priority:** ⭐⭐⭐
- **Scenario:** 1 con rắn

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận yêu cầu cứu hộ và thanh toán đặt cọc
- **Mục đích:** Hiển thị phí dịch vụ, thanh toán đặt cọc 150,000 VNĐ (fixed) và xác nhận yêu cầu
- **Flow position:** Sau khi chọn "Request Rescue Team"
- **Priority:** ⭐⭐⭐
- **Related:** Payment Flow 1 - Deposit mechanism (150K fixed deposit, deducted from total)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận Cứu Hộ" (not "Request" - more direct Vietnamese)

2. **Service Summary Card:**
   - Badge: "1 CON RẮN" (green badge)
   - Service type icon: Rescue truck
   - Snake species: "Loài: [AI detected name]"
   - Danger level: Color-coded badge (Red/Amber/Green)
   - Your location preview: "Vị trí: [Address]"
   - Estimated time: "Đội cứu hộ đến trong: 15-30 phút"

3. **Service Fee Section:**
   - Title: "Chi Phí Dịch Vụ (1 con rắn)"
   - White card with breakdown:
     - "Phí cứu hộ cơ bản": "500,000 VNĐ"
     - "Phí nền tảng (10%)": "50,000 VNĐ"
     - "Quỹ bảo hiểm (5%)": "25,000 VNĐ"
     - Divider line
     - "Tổng Cộng": "575,000 VNĐ" (bold, large, 24pt)
   - Small note: "Chi phí cuối cùng có thể thay đổi tùy khoảng cách"

4. **Balance Payment Preview:**
   - Light green info box (#E8F5E9)
   - Icon: Calculator
   - Text: "Sau khi cứu hộ hoàn tất, bạn thanh toán:"
   - Large amount: "425,000 VNĐ" (575K - 150K deposit, 20pt forest green)
   - Subtext: "(Tổng phí 575K - Đặt cọc 150K)"

5. **Deposit Payment Section:**
   - Title: "Phí Cam Kết Dịch Vụ (Đặt Cọc)"
   - Info box (light blue #E7F3FF):
     - "Đặt cọc cố định: 150,000 VNĐ để xác nhận"
     - "⚠️ Cọc này sẽ được TRỪ vào tổng chi phí"
   - White card - Breakdown (all amounts dynamic/configurable):
     - "Cam kết yêu cầu": "25,000 VNĐ"
     - "Điều phối người hỗ trợ": "30,000 VNĐ"
     - "Di chuyển tối thiểu": "95,000 VNĐ" (or ₫/km × distance)
     - Divider line
     - "Tổng Đặt Cọc": "150,000 VNĐ" (bold, large, forest green, 24pt)
   - Note below: "👉 Sẽ được trừ vào tổng chi phí" (amber text #FFC107)

6. **Payment Method Selection:**
   - Title: "Chọn Phương Thức Thanh Toán"
   - Four payment option cards (horizontal scroll or 2×2 grid):
     - Momo (with logo)
     - VNPay (with logo)
     - ZaloPay (with logo)
     - Thẻ tín dụng (Credit Card icon)
   - Selected card has forest green border (3px)

7. **What Happens Next:**
   - Title: "Điều Gì Sẽ Xảy Ra Tiếp Theo"
   - Numbered steps (1-2-3) with circular badges (32px):
     1. "Thanh toán đặt cọc & tìm đội cứu hộ (2-5 phút)"
     2. "Đội cứu hộ đến và xử lý rắn"
     3. "Thanh toán số tiền còn lại: 425,000 VNĐ"

8. **Important Notes:**
   - Yellow info box (#FFF3CD background, #FFC107 left border 4px)
   - Title: "Lưu Ý Quan Trọng"
   - Bullet points:
     - "Giữ an toàn, giữ khoảng cách với rắn"
     - "Thời gian đội cứu hộ đến: 15-30 phút"
     - "Bạn có thể theo dõi vị trí đội cứu hộ trên bản đồ"
     - "Đặt cọc được hoàn lại nếu không tìm thấy đội cứu hộ"

9. **Action Buttons:**
   - Large primary button (forest green, 56px height): "Thanh Toán Cọc 150,000 VNĐ & Xác Nhận"
   - Secondary text link (centered, gray): "Hủy và quay lại"

#### Stitch Prompt (English):

```
Mobile app deposit payment screen for single snake rescue in "SnakeAid". Transaction interface with forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Xác Nhận Cứu Hộ".

White service summary card with green badge "1 CON RẮN" top-right. Rescue truck icon 40px left. Bold "Loài: Rắn hổ mang chúa", danger level badge (red/amber/green) next to it. Below: "Vị trí: 123 Đường ABC, Quận XYZ" gray, and "Đội cứu hộ đến trong: 15-30 phút" small gray.

Section "Chi Phí Dịch Vụ (1 con rắn)" bold dark gray. White card:
- "Phí cứu hộ cơ bản" left, "500,000 VNĐ" right (dark gray)
- "Phí nền tảng (10%)" left, "50,000 VNĐ" right (medium gray)
- "Quỹ bảo hiểm (5%)" left, "25,000 VNĐ" right (medium gray)
- Thin gray divider
- "Tổng Cộng" bold left, "575,000 VNĐ" bold 24pt right
Small gray text "Chi phí cuối cùng có thể thay đổi tùy khoảng cách"

Light green info box (#E8F5E9) with calculator icon:
"Sau khi cứu hộ hoàn tất, bạn thanh toán:"
"425,000 VNĐ" large 20pt forest green
"(Tổng phí 575K - Đặt cọc 150K)" small gray

Section "Phí Cam Kết Dịch Vụ (Đặt Cọc)" bold dark gray. Light blue info box (#E7F3FF):
• Đặt cọc cố định: 150,000 VNĐ để xác nhận
• ⚠️ Cọc này sẽ được TRỪ vào tổng chi phí

White card deposit breakdown:
- "Cam kết yêu cầu" left, "25,000 VNĐ" right
- "Điều phối người hỗ trợ" left, "30,000 VNĐ" right
- "Di chuyển tối thiểu" left, "95,000 VNĐ" right
- Thin gray divider
- "Tổng Đặt Cọc" bold left, "150,000 VNĐ" bold large 24pt forest green right
Amber text below "👉 Sẽ được trừ vào tổng chi phí" (#FFC107)

"Chọn Phương Thức Thanh Toán" heading. Four payment cards in 2×2 grid: Momo logo, VNPay logo, ZaloPay logo, Credit card icon. First card has forest green border 3px (selected).

"Điều Gì Sẽ Xảy Ra Tiếp Theo" heading. Three steps with circular badges 32px diameter forest green:
1. Thanh toán đặt cọc & tìm đội cứu hộ (2-5 phút)
2. Đội cứu hộ đến và xử lý rắn
3. Thanh toán số tiền còn lại: 425,000 VNĐ

Yellow info box (#FFF3CD, left border #FFC107 4px) titled "Lưu Ý Quan Trọng":
• Giữ an toàn, giữ khoảng cách với rắn
• Thời gian đội cứu hộ đến: 15-30 phút
• Bạn có thể theo dõi vị trí đội cứu hộ trên bản đồ
• Đặt cọc được hoàn lại nếu không tìm thấy đội cứu hộ

Large forest green button 56px height "Thanh Toán Cọc 150,000 VNĐ & Xác Nhận" full width.
Centered gray link "Hủy và quay lại" below.

Design: Clean transaction flow, clear balance preview, payment breakdown transparency, reassuring next-steps timeline.
```

#### Notes for Stitch:
- Badge "1 CON RẮN" should be small and subtle, top-right of service card
- Balance preview box (#E8F5E9) helps user understand they'll pay 425K later
- Pricing alignment must be precise (left-right)
- Circular badges for steps should be 32px diameter, forest green background, white numbers
- Payment method cards should be equal size in 2×2 grid layout

---

### Screen 3B: Deposit Payment - Multiple Snakes

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận cứu hộ nhiều con rắn và thanh toán đặt cọc
- **Mục đích:** Hiển thị phí dịch vụ theo số lượng (575K × N), thanh toán đặt cọc 150K
- **Flow position:** Sau Screen 2B → User chọn "Gọi Đội Cứu Hộ"
- **Priority:** ⭐⭐⭐
- **Scenario:** 2-5 con rắn

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận Cứu Hộ"

2. **Service Summary Card:**
   - Badge: "X CON RẮN" (amber badge with count)
   - Icon: Team of rescuers (2+ people)
   - Title: "Dịch Vụ Cứu Hộ Nhiều Con Rắn"
   - List of snakes (if different species):
     - "Con rắn #1: Rắn hổ mang (Nguy hiểm)"
     - "Con rắn #2: Rắn ri cá (Nguy hiểm thấp)"
     - "Con rắn #3: Chưa xác định"
   - OR: "X con rắn đã phát hiện - Cần đội ngũ 2+ người"
   - Location: "Vị trí: [Address]"
   - Estimated time: "Đội cứu hộ đến trong: 15-30 phút"

3. **Service Fee Section:**
   - Title: "Chi Phí Dịch Vụ (X con rắn)"
   - White card with calculation:
     - "Phí cơ bản mỗi con": "575,000 VNĐ"
     - "Số lượng rắn": "× X con"
     - Divider line
     - "Tổng Cộng": "XXX,XXX VNĐ" (bold, large, 24pt, e.g., 1,725,000 for 3 snakes)
   - Info note (light amber #FFF3CD):
     - "ℹ️ Phí theo số lượng để đảm bảo đầy đủ trang bị và nhân lực"
   - Small note: "Chi phí cuối cùng có thể thay đổi tùy khoảng cách"

4. **Balance Payment Preview:**
   - Light green info box (#E8F5E9)
   - Icon: Calculator
   - Text: "Sau khi cứu hộ hoàn tất, bạn thanh toán:"
   - Large amount: "XXX,XXX VNĐ" (Total - 150K, e.g., 1,575,000 for 3 snakes)
   - Subtext: "(Tổng phí XXX,XXXK - Đặt cọc 150K)"

5. **Deposit Payment Section:**
   - Title: "Phí Cam Kết Dịch Vụ (Đặt Cọc)"
   - Info box (light blue #E7F3FF):
     - "Đặt cọc cố định: 150,000 VNĐ (KHÔNG phụ thuộc số lượng)"
     - "⚠️ Cọc này sẽ được TRỪ vào tổng chi phí"
   - White card - Breakdown:
     - "Cam kết yêu cầu": "25,000 VNĐ"
     - "Điều phối đội ngũ": "30,000 VNĐ"
     - "Di chuyển tối thiểu": "95,000 VNĐ"
     - Divider
     - "Tổng Đặt Cọc": "150,000 VNĐ" (forest green, 24pt)
   - Note: "👉 Sẽ được trừ vào tổng chi phí" (amber)

6-9. **Same as Screen 3A:**
   - Payment Method Selection
   - What Happens Next (update step 3 with correct balance amount)
   - Important Notes
   - Action Buttons

#### Stitch Prompt (English):

```
Mobile app deposit payment for multiple snake rescue in "SnakeAid". Transaction interface, forest green (#228B22) primary, amber (#FFC107) accents.

Top: Back arrow, title "Xác Nhận Cứu Hộ".

Service card with amber badge "3 CON RẮN" top-right. Team icon (2+ people) 48px. Title "Dịch Vụ Cứu Hộ Nhiều Con Rắn" bold. Snake list:
• Con rắn #1: Rắn hổ mang (Nguy hiểm)
• Con rắn #2: Rắn ri cá (Nguy hiểm thấp)
• Con rắn #3: Chưa xác định
Below: "Vị trí: 123 Đường ABC" gray, "Đội cứu hộ đến trong: 15-30 phút" small gray.

Section "Chi Phí Dịch Vụ (3 con rắn)" bold. White card:
- "Phí cơ bản mỗi con" left, "575,000 VNĐ" right (dark gray)
- "Số lượng rắn" left, "× 3 con" right (medium gray)
- Gray divider
- "Tổng Cộng" bold left, "1,725,000 VNĐ" bold 24pt right

Light amber info box (#FFF3CD):
"ℹ️ Phí theo số lượng để đảm bảo đầy đủ trang bị và nhân lực"
Small gray "Chi phí cuối cùng có thể thay đổi tùy khoảng cách"

Light green box (#E8F5E9) with calculator icon:
"Sau khi cứu hộ hoàn tất, bạn thanh toán:"
"1,575,000 VNĐ" large 20pt forest green
"(Tổng phí 1,725K - Đặt cọc 150K)" small gray

Section "Phí Cam Kết Dịch Vụ (Đặt Cọc)". Light blue box (#E7F3FF):
• Đặt cọc cố định: 150,000 VNĐ (KHÔNG phụ thuộc số lượng)
• ⚠️ Cọc này sẽ được TRỪ vào tổng chi phí

White card breakdown:
- "Cam kết yêu cầu" / "25,000 VNĐ"
- "Điều phối đội ngũ" / "30,000 VNĐ"
- "Di chuyển tối thiểu" / "95,000 VNĐ"
- Gray divider
- "Tổng Đặt Cọc" bold / "150,000 VNĐ" bold 24pt forest green
Amber text "👉 Sẽ được trừ vào tổng chi phí"

[Same payment methods, steps, notes as 3A but step 3 shows "1,575,000 VNĐ"]

Large green button "Thanh Toán Cọc 150,000 VNĐ & Xác Nhận" 56px.
Gray link "Hủy và quay lại" centered.

Design: Quantity emphasis, fixed deposit clarity, balance calculation transparency, team requirement signals.
```

#### Notes for Stitch:
- Badge "3 CON RẮN" should use amber to signal higher complexity
- Snake list helps user verify what they reported
- Info box explaining per-quantity fee reduces confusion
- CRITICAL: Emphasize deposit is FIXED 150K regardless of snake count
- Balance calculation must be clear: (1,725,000 - 150,000 = 1,575,000)

---

### Screen 3C: Deposit Payment - Snake Nest

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận cứu hộ ổ rắn và thanh toán đặt cọc
- **Mục đích:** Hiển thị phí dịch vụ phức tạp (2.5M-5M range), thanh toán đặt cọc 150K, cảnh báo nghiêm trọng
- **Flow position:** Sau Screen 2C → User chọn "Gọi Chuyên Gia Xử Lý Ổ Rắn"
- **Priority:** ⭐⭐⭐
- **Scenario:** Ổ rắn / Nhiều con rất nguy hiểm

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận Yêu Cầu Khẩn Cấp"

2. **Critical Alert Banner:**
   - Red background with warning stripes
   - Icon: Skull/Extreme danger
   - Bold text: "Ổ RẮN - TÌNH HUỐNG NGUY HIỂM"
   - Subtext: "Yêu cầu chuyên gia và trang bị đặc biệt"

3. **Service Summary Card:**
   - Badge: "Ổ RẮN" (red badge)
   - Icon: Specialist helmet
   - Title: "Dịch Vụ Xử Lý Ổ Rắn Chuyên Nghiệp"
   - Details:
     - "Loài chính: [Name]" (if detected)
     - "Số lượng ước tính: X-Y con"
     - "Mức độ rủi ro: CỰC KỲ CAO"
     - "Khu vực: [Environment type]"
   - Location: "Vị trí: [Address]"
   - Estimated time: "Đội chuyên gia đến trong: 10-20 phút"

4. **Complex Pricing Section:**
   - Title: "Chi Phí Dịch Vụ (Ước Tính Phức Tạp)"
   - Warning box (amber #FFF3CD):
     - "⚠️ Giá cuối cùng SAU KHI chuyên gia khảo sát hiện trường"
   - White card with breakdown:
     - "Phí cơ bản ổ rắn": "1,500,000 VNĐ"
     - "Phí theo số lượng (X con)": "575,000 × X"
     - "Phí chuyên gia": "500,000 - 1,000,000 VNĐ"
     - "Trang bị đặc biệt": "200,000 - 500,000 VNĐ"
     - Divider (dotted line)
     - "Ước Tính Tổng": "2,500,000 - 5,000,000 VNĐ" (bold, red, 24pt, range)
   - Important note (red text):
     - "Bạn chỉ cam kết 150K đặt cọc ngay. Giá chính xác sẽ được báo SAU khảo sát."

5. **Deposit Payment Section (SAME 150K):**
   - Title: "Phí Cam Kết Dịch Vụ (Đặt Cọc)"
   - Info box (light blue #E7F3FF):
     - "Đặt cọc cố định: 150,000 VNĐ để xác nhận yêu cầu khẩn cấp"
     - "⚠️ Cọc này sẽ được TRỪ vào tổng chi phí sau khi khảo sát"
   - White card - Breakdown:
     - "Cam kết yêu cầu": "25,000 VNĐ"
     - "Điều phối chuyên gia": "30,000 VNĐ"
     - "Di chuyển tối thiểu": "95,000 VNĐ"
     - Divider
     - "Tổng Đặt Cọc": "150,000 VNĐ" (forest green, 24pt)
   - Note: "👉 Sẽ được trừ vào tổng chi phí cuối cùng" (amber)

6. **Payment Method Selection:**
   - Same as 3A/3B

7. **What Happens Next (Modified):**
   - Title: "Điều Gì Sẽ Xảy Ra Tiếp Theo"
   - Numbered steps (1-4):
     1. "Thanh toán đặt cọc 150K & tìm chuyên gia (5-10 phút)"
     2. "Chuyên gia đến KHẢO SÁT hiện trường"
     3. "Báo giá CHÍNH XÁC dựa trên tình hình thực tế"
     4. "Bạn xác nhận → Xử lý ổ rắn → Thanh toán số tiền còn lại"

8. **Important Notes (CRITICAL):**
   - Red border info box (#FFEBEE background, #DC3545 left border 4px)
   - Title: "LƯU Ý CỰC KỲ QUAN TRỌNG"
   - Bullet points (bold):
     - "TUYỆT ĐỐI giữ khoảng cách an toàn tối thiểu 10 mét"
     - "KHÔNG tiếp cận hoặc cố gắng tự xử lý"
     - "CẢNH BÁO người xung quanh không đến gần"
     - "Đội chuyên gia sẽ liên hệ SAU khi khảo sát để báo giá chính xác"
     - "Đặt cọc được hoàn lại 100% nếu bạn không chấp nhận giá sau khảo sát"

9. **Action Buttons:**
   - Large red button (not green, emergency style, 56px): "Thanh Toán Cọc 150,000 VNĐ & Yêu Cầu Khẩn Cấp"
   - Secondary text link: "Hủy và quay lại"

#### Stitch Prompt (English):

```
Mobile app emergency deposit payment for snake nest rescue in "SnakeAid". Critical interface, red (#DC3545) emergency accent, forest green for payment.

Top: Back arrow, title "Xác Nhận Yêu Cầu Khẩn Cấp".

Red alert banner with warning stripes pattern. Skull icon, bold white text "Ổ RẮN - TÌNH HUỐNG NGUY HIỂM". Subtext "Yêu cầu chuyên gia và trang bị đặc biệt".

Service card with red badge "Ổ RẮN". Specialist helmet icon 48px. Title "Dịch Vụ Xử Lý Ổ Rắn Chuyên Nghiệp" bold. Details:
• Loài chính: Rắn hổ mang chúa
• Số lượng ước tính: 15-20 con
• Mức độ rủi ro: CỰC KỲ CAO (red)
• Khu vực: Đống gạch/đá
"Vị trí: 123 Đường ABC" gray, "Đội chuyên gia đến trong: 10-20 phút" small gray.

Section "Chi Phí Dịch Vụ (Ước Tính Phức Tạp)" bold. Amber warning box (#FFF3CD):
"⚠️ Giá cuối cùng SAU KHI chuyên gia khảo sát hiện trường"

White card:
- "Phí cơ bản ổ rắn" / "1,500,000 VNĐ" (dark gray)
- "Phí theo số lượng (18 con)" / "575,000 × 18" (medium gray)
- "Phí chuyên gia" / "500,000 - 1,000,000 VNĐ" (medium gray)
- "Trang bị đặc biệt" / "200,000 - 500,000 VNĐ" (medium gray)
- Dotted divider
- "Ước Tính Tổng" bold / "2,500,000 - 5,000,000 VNĐ" bold 24pt RED (range)

Red text note: "Bạn chỉ cam kết 150K đặt cọc ngay. Giá chính xác sẽ được báo SAU khảo sát."

Section "Phí Cam Kết Dịch Vụ (Đặt Cọc)". Light blue box (#E7F3FF):
• Đặt cọc cố định: 150,000 VNĐ để xác nhận yêu cầu khẩn cấp
• ⚠️ Cọc này sẽ được TRỪ vào tổng chi phí sau khi khảo sát

White card breakdown:
- "Cam kết yêu cầu" / "25,000 VNĐ"
- "Điều phối chuyên gia" / "30,000 VNĐ"
- "Di chuyển tối thiểu" / "95,000 VNĐ"
- Gray divider
- "Tổng Đặt Cọc" bold / "150,000 VNĐ" bold 24pt forest green
Amber text "👉 Sẽ được trừ vào tổng chi phí cuối cùng"

[Payment methods same as 3A]

"Điều Gì Sẽ Xảy Ra Tiếp Theo" with 4 circular badges:
1. Thanh toán đặt cọc 150K & tìm chuyên gia (5-10 phút)
2. Chuyên gia đến KHẢO SÁT hiện trường
3. Báo giá CHÍNH XÁC dựa trên tình hình thực tế
4. Bạn xác nhận → Xử lý ổ rắn → Thanh toán số tiền còn lại

Red-bordered box (#FFEBEE background, #DC3545 left border 4px) titled "LƯU Ý CỰC KỲ QUAN TRỌNG" bold:
• TUYỆT ĐỐI giữ khoảng cách an toàn tối thiểu 10 mét
• KHÔNG tiếp cận hoặc cố gắng tự xử lý
• CẢNH BÁO người xung quanh không đến gần
• Đội chuyên gia sẽ liên hệ SAU khi khảo sát để báo giá chính xác
• Đặt cọc được hoàn lại 100% nếu bạn không chấp nhận giá sau khảo sát

Large RED button 56px "Thanh Toán Cọc 150,000 VNĐ & Yêu Cầu Khẩn Cấp" (#DC3545).
Gray link "Hủy và quay lại" centered.

Design: Emergency critical style, pricing transparency for complex situation, deposit simplicity, refund guarantee for user confidence.
```

#### Notes for Stitch:
- Alert banner MUST be prominent with stripes pattern
- Pricing range (2.5M-5M) shown clearly as ESTIMATE not final
- Red note explaining price will be confirmed AFTER survey is critical
- Deposit still 150K (same as other scenarios) - this must be clear
- Red button (not green) for emergency context
- Refund guarantee (100% if reject price after survey) builds trust
- 4 steps instead of 3 - extra step for survey & quote

---

### Screen 4 MỚI: Waiting for Rescuer Accept (Radar Expansion)

#### Thông tin màn hình:
- **Tên:** Màn hình chờ rescuer nhận đơn (với radar mở rộng)
- **Mục đích:** Hiển thị trạng thái tìm kiếm rescuer với radar mở rộng 10km → 20km → 30km và thông báo khi có rescuer nhận đơn
- **Flow position:** Sau Screen 3 (Post Request) - Đợi rescuer chấp nhận
- **Model:** First Come First Served - Ai nhận trước người đó làm
- **Priority:** ⭐⭐⭐

#### Entry Points:
- Sau khi patient tap "ĐĂNG YÊU CẦU CỨU HỘ" ở Screen 3

#### Exit Points:
- **Success:** Rescuer đã nhận đơn → Navigate to Screen 5 (Tracking Rescuer)
- **Cancel:** Patient hủy request → Navigate back to Screen 1
- **Timeout:** Không tìm được rescuer sau 30km → Show "Không tìm thấy rescuer" dialog

---

#### Key Components:

##### 1. Header (Fixed)
```
┌─────────────────────────────────────────┐
│  [<]  Đang Tìm Rescuer           [✕]   │
└─────────────────────────────────────────┘
```
- **Title:** "Đang Tìm Rescuer" (18pt Medium, #1C1C1E)
- **Back Button:** [<] (disabled during search)
- **Close Button:** [✕] (shows cancel confirmation)
- **Height:** 60px
- **Background:** #FFFFFF
- **Border:** Bottom 1px #E5E5E5

---

##### 2. Radar Animation Section
```
┌─────────────────────────────────────────┐
│                                         │
│          ┌───────────────┐             │
│        ┌─────────────────────┐         │
│      ┌───────────────────────────┐     │
│      │         👤                │     │
│      │      (Patient)            │     │
│      │                           │     │
│      └───────────────────────────┘     │
│        └─────────────────────┘         │
│          └───────────────┘             │
│                                         │
│   [Animated concentric circles]        │
│   expanding outward from center        │
│                                         │
└─────────────────────────────────────────┘
```
- **Radar Visualization:**
  - Center: Patient avatar (blue dot, 20px)
  - **Circle 1:** 10km radius (green #34C759, 2px stroke)
  - **Circle 2:** 20km radius (amber #FF9500, 2px stroke, dashed)
  - **Circle 3:** 30km radius (orange #FF3B30, 2px stroke, dashed)
  - Pulse animation: Circles fade in/out every 2s
  - Active circle: Solid stroke, others: 50% opacity
- **Map Style:** Light background #F5F5F7
- **Height:** 280px
- **Padding:** 20px

**Rescuer Dots:**
- Show rescuers as small dots within radius
- Online rescuers: Green dots (8px)
- Viewing request: Pulsing green dots (12px, scale animation)
- Position randomly within active radius

---

##### 3. Search Status Card
```
┌─────────────────────────────────────────┐
│  📡 Đang tìm trong bán kính 10km        │
│                                         │
│  [██████████░░░░░] 65%                 │
│                                         │
│  ⏱️ Thời gian ước tính: 2-5 phút       │
└─────────────────────────────────────────┘
```
- **Status Text:** Changes as radius expands:
  - Phase 1: "📡 Đang tìm trong bán kính 10km"
  - Phase 2: "📡 Đang mở rộng tìm kiếm - 20km"
  - Phase 3: "📡 Tìm kiếm tối đa - 30km"
- **Progress Bar:**
  - Green for 10km phase
  - Amber for 20km phase
  - Orange for 30km phase
  - Animates from 0% to 100% per phase
- **Time Estimate:** Updates per phase
  - 10km: "2-5 phút"
  - 20km: "5-10 phút"
  - 30km: "10-15 phút"
- **Background:** #F9F9F9
- **Padding:** 16px
- **Border Radius:** 12px

---

##### 4. Real-Time Activity Counter
```
┌─────────────────────────────────────────┐
│  👁️ 5 rescuers đang xem đơn này        │
│  📍 3 rescuers trong 10km               │
└─────────────────────────────────────────┘
```
- **Counter Updates:** Real-time via WebSocket
- **Viewing Counter:** 
  - "👁️ [X] rescuers đang xem đơn này"
  - Color: #007AFF (blue, engaging)
  - Font: 16pt Medium
- **Location Counter:**
  - "📍 [Y] rescuers trong [Z]km"
  - Shows rescuers in current search radius
  - Updates as radius expands
- **Animation:** Numbers count up smoothly
- **Background:** #E7F3FF (light blue)
- **Padding:** 12px
- **Border Radius:** 8px
- **Margin:** 16px

---

##### 5. Expansion Notification Banner (Shows when expanding)
```
┌─────────────────────────────────────────┐
│  ⚠️ Đang mở rộng tìm kiếm lên 20km     │
│  Vì chưa đủ rescuers trong 10km        │
└─────────────────────────────────────────┘
```
- **Appears:** When system expands from 10km → 20km or 20km → 30km
- **Background:** #FFF9E6 (amber)
- **Icon:** ⚠️
- **Message Examples:**
  - "Đang mở rộng tìm kiếm lên 20km"
  - "Đang mở rộng tìm kiếm lên 30km (Tối đa)"
- **Subtitle:** Explains reason (e.g., "Vì chưa đủ rescuers trong 10km")
- **Duration:** Fades in, stays 5s, fades out
- **Border:** Left 4px #FF9500

---

##### 6. Request Summary (Collapsible)
```
┌─────────────────────────────────────────┐
│  Thông Tin Yêu Cầu              [▼]    │
│  ─────────────────────────────────────  │
│  🐍 Rắn hổ mang chúa                   │
│  📍 123 Nguyễn Văn Linh, Q7            │
│  💰 Giá dự kiến: 575,000 VNĐ           │
│  🕐 Thời gian: 14:30 - 21/01/2025      │
└─────────────────────────────────────────┘
```
- **Header:** "Thông Tin Yêu Cầu" (14pt Medium) + chevron
- **Collapsed by default**
- **Expanded shows:**
  - Snake species + photo thumbnail
  - Location
  - Estimated price
  - Posted time
  - Urgency level
- **Background:** #FFFFFF
- **Border:** 1px #E5E5E5
- **Border Radius:** 12px
- **Padding:** 16px
- **Margin Bottom:** 16px

---

##### 7. Success Notification (When Rescuer Accepts)
```
┌─────────────────────────────────────────┐
│             ✅ (120px)                  │
│                                         │
│      ĐÃ CÓ RESCUER NHẬN ĐƠN!          │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  [Avatar]  Nguyễn Văn A         │   │
│  │            ⭐ 4.9 (127 đơn)     │   │
│  │            📍 2.3 km            │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Rescuer đang chuẩn bị di chuyển...    │
│                                         │
│     [ XEM CHI TIẾT RESCUER ]           │
└─────────────────────────────────────────┘
```
- **Trigger:** When rescuer taps "NHẬN ĐƠN NGAY"
- **Animation:**
  - Radar stops pulsing
  - Green checkmark scales up from 0 → 120px (0.5s)
  - Confetti animation (brief)
  - Success haptic feedback
- **Checkmark:** ✅ (120px, green #28A745)
- **Title:** "ĐÃ CÓ RESCUER NHẬN ĐƠN!" (24pt Bold, green)
- **Rescuer Card:**
  - Avatar (60×60px circular)
  - Name (18pt Medium)
  - Rating + completed jobs
  - Distance to patient
  - Background: #F0FFF4 (light green)
  - Border: 2px #28A745
- **Subtitle:** "Rescuer đang chuẩn bị di chuyển..." (14pt, #8E8E93)
- **Auto-dismiss:** After 3s, navigate to Screen 5 (Tracking)
- **Button:** "XEM CHI TIẾT RESCUER" (green outlined)

---

##### 8. Bottom Actions Section
```
┌─────────────────────────────────────────┐
│  [    HỦY YÊU CẦU    ]                 │
│                                         │
│  ⓘ Bạn sẽ không mất phí nếu hủy       │
└─────────────────────────────────────────┘
```
- **Cancel Button:**
  - Text: "HỦY YÊU CẦU" (16pt Medium)
  - Style: Outlined, red border #FF3B30
  - Height: 50px
  - Width: 90% centered
  - Icon: ✕
  - Shows confirmation dialog before canceling
- **Reassurance Note:**
  - "ⓘ Bạn sẽ không mất phí nếu hủy"
  - Font: 12pt Regular
  - Color: #8E8E93 (gray)
  - Centered
- **Padding:** 20px

---

##### 9. Cancel Confirmation Dialog
```
┌─────────────────────────────────────────┐
│  Hủy Yêu Cầu Cứu Hộ?                   │
│  ─────────────────────────────────────  │
│  Bạn có chắc muốn hủy yêu cầu này?     │
│  Đơn sẽ bị xóa khỏi hệ thống.          │
│                                         │
│  [ QUAY LẠI ]  [ HỦY ĐƠN ]            │
└─────────────────────────────────────────┘
```
- **Title:** "Hủy Yêu Cầu Cứu Hộ?" (18pt Bold)
- **Message:** Explains consequence
- **Buttons:**
  - "QUAY LẠI" (gray, dismiss dialog)
  - "HỦY ĐƠN" (red, confirm cancellation)
- **Style:** Modal overlay, semi-transparent backdrop

---

##### 10. Timeout State (No Rescuers Found)
```
┌─────────────────────────────────────────┐
│             ⚠️ (100px)                 │
│                                         │
│   Không tìm thấy rescuer phù hợp       │
│                                         │
│  Đã tìm kiếm trong bán kính 30km       │
│  nhưng không có rescuer sẵn sàng.      │
│                                         │
│  Bạn có thể:                           │
│  • Thử lại sau 5-10 phút               │
│  • Liên hệ hotline: 1900 xxxx         │
│  • Gọi chuyên gia tư vấn               │
│                                         │
│  [  THỬ LẠI  ]  [  GỌI HOTLINE  ]    │
└─────────────────────────────────────────┘
```
- **Trigger:** After searching all 3 tiers (30km max) with no rescuer accepting within timeout (e.g., 15 minutes)
- **Icon:** ⚠️ (100px, amber #FF9500)
- **Title:** "Không tìm thấy rescuer phù hợp" (20pt Bold)
- **Explanation:** Clear, empathetic message
- **Suggestions:** Bullet list of alternatives
- **Buttons:**
  - "THỬ LẠI" (green, restart search)
  - "GỌI HOTLINE" (blue, call support)

---

#### Interaction Flows:

##### Flow 1: Successful Match (Best Case)
1. Screen loads → Radar starts animating at 10km
2. Status: "Đang tìm trong bán kính 10km"
3. Counter: "3 rescuers đang xem đơn này"
4. **Rescuer accepts within 2 minutes**
5. **Success animation:** Checkmark scales up, confetti
6. Show rescuer card with details
7. Auto-navigate to Screen 5 (Tracking) after 3s

##### Flow 2: Expansion to 20km
1. Screen loads → Search 10km for 3 minutes
2. **< 3 rescuers in 10km** → System expands
3. Banner appears: "⚠️ Đang mở rộng tìm kiếm lên 20km"
4. Radar animates second circle (amber)
5. Status: "Đang mở rộng tìm kiếm - 20km"
6. Counter updates: "5 rescuers đang xem đơn này"
7. Rescuer accepts → Success flow

##### Flow 3: Maximum Expansion to 30km
1. After 20km search (5 minutes), still < 3 rescuers
2. System expands to max 30km
3. Banner: "⚠️ Đang mở rộng tìm kiếm lên 30km (Tối đa)"
4. Radar animates third circle (orange)
5. Status: "Tìm kiếm tối đa - 30km"
6. Wait for rescuer accept or timeout

##### Flow 4: Patient Cancels
1. Patient taps "HỦY YÊU CẦU"
2. Dialog appears: "Hủy Yêu Cầu Cứu Hộ?"
3. Patient confirms "HỦY ĐƠN"
4. Request removed from system
5. Navigate back to Home or Screen 1

##### Flow 5: Timeout (No Rescuers)
1. After 15 minutes at 30km, no rescuer accepts
2. Timeout state appears
3. Show alternatives (try again, call hotline)
4. Patient chooses action

---

#### WebSocket Events:

```javascript
// Real-time updates
socket.on('rescuerViewing', (data) => {
  // Update "X rescuers đang xem đơn này" counter
  updateViewingCounter(data.count);
  // Add pulsing dot to map
  addRescuerDotToMap(data.location);
});

socket.on('radiusExpanded', (data) => {
  // Show expansion banner
  showExpansionBanner(data.newRadius);
  // Animate to new circle
  expandRadarCircle(data.newRadius);
  // Update status text
  updateStatusText(data.newRadius);
});

socket.on('rescuerAccepted', (data) => {
  // Stop radar animation
  stopRadarAnimation();
  // Show success notification
  showSuccessNotification(data.rescuer);
  // Auto-navigate after 3s
  setTimeout(() => navigateToTracking(data.rescuer), 3000);
});

socket.on('searchTimeout', () => {
  // Show timeout state
  showTimeoutState();
});
```

---

#### UI States:

**State 1: Initial Search (10km)**
- Active circle: Green 10km
- Status: "Đang tìm trong bán kính 10km"
- Progress: 0% → 100% over ~3 minutes
- Counter: Real-time rescuer count

**State 2: Expanding to 20km**
- Banner appears (amber warning)
- Active circle: Amber 20km
- Status: "Đang mở rộng tìm kiếm - 20km"
- Progress: 0% → 100% over ~5 minutes

**State 3: Maximum 30km**
- Banner appears (orange warning)
- Active circle: Orange 30km
- Status: "Tìm kiếm tối đa - 30km"
- Progress: 0% → 100% until accept or timeout

**State 4: Success**
- Radar stops
- Checkmark animation
- Rescuer card displayed
- Auto-dismiss to tracking

**State 5: Timeout**
- Warning icon
- Alternatives listed
- Action buttons

---

#### Stitch Prompt:

```
Design an iOS-native waiting screen for SnakeAid app after patient posts rescue request.

CRITICAL REQUIREMENTS:
1. First Come First Served Model - Whoever accepts first gets the job
2. Radar expansion visualization: 10km (green) → 20km (amber) → 30km (orange)
3. Real-time rescuer activity counter
4. Success notification when rescuer accepts

LAYOUT (Top to Bottom):

1. HEADER (60px):
   - Title: "Đang Tìm Rescuer"
   - Back button [<] (disabled)
   - Close button [✕]

2. RADAR ANIMATION (280px):
   - Center: Blue patient dot (20px)
   - Concentric circles expanding:
     * Circle 1: 10km (green #34C759, solid, pulsing)
     * Circle 2: 20km (amber #FF9500, dashed, 50% opacity)
     * Circle 3: 30km (orange #FF3B30, dashed, 50% opacity)
   - Active circle pulses every 2s
   - Show rescuer dots (green 8px) within active radius
   - Viewing rescuers: Pulsing green dots (12px)

3. SEARCH STATUS CARD:
   - Icon + Text: "📡 Đang tìm trong bán kính 10km"
   - Progress bar (green/amber/orange based on phase)
   - Time estimate: "⏱️ Thời gian ước tính: 2-5 phút"
   - Background: #F9F9F9

4. ACTIVITY COUNTER:
   - "👁️ 5 rescuers đang xem đơn này" (blue #007AFF)
   - "📍 3 rescuers trong 10km"
   - Background: #E7F3FF (light blue)
   - Numbers animate/count up

5. EXPANSION BANNER (conditional):
   - Shows when expanding radius
   - "⚠️ Đang mở rộng tìm kiếm lên 20km"
   - "Vì chưa đủ rescuers trong 10km"
   - Background: #FFF9E6 (amber)
   - Left border: 4px #FF9500
   - Fades in/out

6. REQUEST SUMMARY (collapsible):
   - Header: "Thông Tin Yêu Cầu" + chevron
   - Collapsed by default
   - Shows: Snake, location, price, time

7. SUCCESS NOTIFICATION (when accepted):
   - Green checkmark ✅ (120px) with scale-up animation
   - Title: "ĐÃ CÓ RESCUER NHẬN ĐƠN!" (green #28A745)
   - Rescuer card:
     * Avatar (60px circular)
     * Name + rating ⭐ 4.9
     * Distance 📍 2.3 km
     * Background: #F0FFF4, border: 2px green
   - Auto-dismiss to tracking after 3s

8. BOTTOM ACTIONS:
   - Button: "HỦY YÊU CẦU" (red outlined)
   - Note: "ⓘ Bạn sẽ không mất phí nếu hủy"

INTERACTIONS:
- Radar continuously pulses during search
- Progress bar fills per phase (10km/20km/30km)
- Counter updates in real-time
- Expansion banner fades in when radius changes
- Success notification takes over screen when rescuer accepts
- Cancel button shows confirmation dialog

STATES:
- Searching 10km (green theme)
- Expanding to 20km (amber theme)
- Maximum 30km (orange theme)
- Success (green celebration)
- Timeout (amber warning)

DESIGN STYLE:
- iOS native feel
- SF Pro font
- Smooth animations (0.3s ease)
- Haptic feedback on state changes
- Light background #F5F5F7
- Rounded corners 12px
- 16px padding/margins

Create a professional, real-time waiting experience that clearly communicates radar expansion and creates anticipation for rescuer acceptance. Use iOS-native components and smooth animations.
```

---

### Screen 4: Searching for Rescuer Screen (TO BE DELETED - OLD VERSION)

#### Thông tin màn hình:
- **Tên:** Màn hình tìm kiếm đội cứu hộ
- **Mục đích:** Hiển thị trạng thái đang tìm kiếm rescuer phù hợp trong bán kính
- **Flow position:** Giai đoạn 2.2 - Matching với rescuer
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Title: "Finding Rescue Team..."
   - Close button (X)

2. **Loading Animation Section:**
   - Animated spinner or pulsing circles
   - Main message: "Searching for available rescuers"
   - Subtitle: "This may take 2-5 minutes"

3. **Search Status Card:**
   - Icon: Radar or search icon
   - Text: "Searching within 10km radius"
   - Secondary text: "3 rescuers found, waiting for response..."

4. **Your Request Summary:**
   - Small card showing:
     - Snake type
     - Your location
     - Time requested

5. **What's Happening (Timeline):**
   - Step 1: ✓ "Request submitted" (green checkmark)
   - Step 2: ⏳ "Notifying nearby rescuers" (in progress, animated)
   - Step 3: ○ "Waiting for acceptance" (pending)

6. **Cancel Option:**
   - Text link at bottom: "Cancel rescue request"

#### Stitch Prompt (English):

```
Mobile app loading screen for finding snake rescuer in app "SnakeAid". Modern waiting interface with forest green (#228B22) accents.

Top navigation: Centered title "Đang Tìm Đội Cứu Hộ..." with X close button on right.

Center of screen features animated loading spinner (circular, forest green color, rotating animation). Below spinner, large bold text "Đang tìm kiếm đội cứu hộ" in dark gray. Below that, smaller gray text "Quá trình này có thể mất 2-5 phút".

White card with subtle shadow below loading section. Contains radar/search icon on left in forest green. Main text "Tìm kiếm trong bán kính 10km" in dark gray bold. Below that, medium gray text "Đã tìm thấy 3 đội cứu hộ, đang chờ phản hồi...".

Below search card, smaller white card titled "Yêu Cầu Của Bạn" in small gray text. Inside card, 3 lines of information with icons:
- Snake icon: "Loài: Rắn hổ mang chúa"
- Location pin icon: "123 Tên đường"
- Clock icon: "2:45 PM"

Section titled "Đang Diễn Ra" with 3 steps displayed vertically:
- Step 1: Green checkmark icon, "Đã gửi yêu cầu" in dark gray (completed state)
- Step 2: Animated hourglass/loading icon in amber, "Đang thông báo cho đội cứu hộ gần đó" in dark gray (active state with pulsing animation)
- Step 3: Empty circle outline in gray, "Chờ chấp nhận" in light gray (pending state)

Bottom of screen: Centered text link in medium gray "Hủy yêu cầu cứu hộ".

Design: Loading/waiting state interface, clear progress indication, calming animation, informative status updates.
```

#### Notes for Stitch:
- Animation phải smooth và calming, không gây căng thẳng
- Nếu Stitch không render animation → "Show static spinner with note 'animated in implementation'"
- Timeline steps phải rõ ràng về trạng thái (completed/in-progress/pending)

---

### Screen 5: Rescuer Matched Screen

#### Thông tin màn hình:
- **Tên:** Màn hình đã tìm thấy đội cứu hộ
- **Mục đích:** Hiển thị thông tin rescuer đã chấp nhận và chuẩn bị di chuyển
- **Flow position:** Sau khi rescuer chấp nhận yêu cầu
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Rescuer Found!"
   - Timer showing elapsed time

2. **Success Banner:**
   - Green success background
   - Checkmark icon
   - Text: "Rescue team is on the way!"

3. **Rescuer Profile Card:**
   - Avatar image (circular)
   - Name of rescuer
   - Star rating (e.g., "4.8 ⭐")
   - Badge: "Verified Rescuer"
   - Total rescues completed: "127 rescues"
   - Phone call button
   - Message button

4. **Status Timeline:**
   - Current status badge: "Preparing equipment" (amber background)
   - Estimated arrival time: "20-30 minutes"
   - Progress bar (optional)

5. **Rescuer Location Preview:**
   - Small map thumbnail showing route
   - Distance: "3.5 km away"
   - Button: "View Live Tracking →" (leads to Screen 6)

6. **Action Buttons:**
   - Primary: "View on Map" (forest green)
   - Secondary: "Call Rescuer" (outlined)
   - Text link: "Cancel rescue" (small, gray)

#### Stitch Prompt (English):

```
Mobile app screen showing matched rescuer in snake rescue app "SnakeAid". Success confirmation interface with forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Đã Tìm Thấy Đội Cứu Hộ!", right side shows timer "02:15" in gray.

Full-width success banner with light green background (#D4EDDA) and green checkmark icon. Large bold text "Đội cứu hộ đang trên đường đến!" in dark green (#28A745).

Main content white card with subtle shadow. Top of card shows circular avatar image (60px diameter) centered. Below avatar, bold dark gray text showing rescuer name "Nguyễn Văn A". Below name, yellow star rating "4.8 ⭐" with "(45 đánh giá)" in gray. Small forest green badge below rating displaying "Đã Xác Minh". Bottom line shows gray text "Đã hoàn thành 127 ca cứu hộ".

Two equal-width buttons below profile section in horizontal row:
- Left button: Phone icon with "Gọi" label (forest green outline)
- Right button: Message icon with "Nhắn Tin" label (forest green outline)

Below profile card, white card titled "Trạng Thái Hiện Tại". Inside card, amber badge "Đang chuẩn bị thiết bị" with clock icon. Below badge, text "Thời gian ước tính đến" in gray. Large bold text "20-30 phút" in dark gray.

Next section shows small map thumbnail (rectangular, 16:9 ratio, placeholder with "Xem Trước Bản Đồ"). Overlaid on bottom-left of map: white badge showing "Cách 3.5 km". Right side of map area: forest green button "Xem Theo Dõi Trực Tiếp →".

Bottom section has 2 buttons vertically stacked:
- Large solid forest green button "Xem Trên Bản Đồ"
- Large outlined forest green button "Gọi Đội Cứu Hộ"
Small centered gray text link below buttons "Hủy cứu hộ".

Design: Success state interface, trust-building profile display, clear call-to-action hierarchy, mobile-optimized.
```

#### Notes for Stitch:
- Rescuer profile phải tạo cảm giác tin cậy với verified badge và rating
- Map thumbnail chỉ cần placeholder với text "Map Preview"
- Nếu buttons bị chồng chéo → "Ensure 16px vertical spacing between buttons"

---

### Screen 6: Live Tracking Map Screen

#### Thông tin màn hình:
- **Tên:** Màn hình theo dõi vị trí rescuer real-time
- **Mục đích:** Hiển thị vị trí rescuer đang di chuyển trên bản đồ với ETA
- **Flow position:** Giai đoạn 2.3 - Rescuer đang di chuyển
- **Priority:** ⭐⭐⭐ (Cao nhất - key feature)

#### Key Components:
1. **Header (overlay on map):**
   - Back button (white with shadow)
   - Status text: "Rescue in Progress"
   - Minimize button

2. **Full-Screen Map:**
   - User's location marker (blue pin)
   - Rescuer's location marker (green pin with avatar)
   - Route line connecting both (dashed or solid blue line)
   - Optional: Rescuer's path history (faded trail)

3. **Floating Status Card (bottom sheet):**
   - Draggable handle at top
   - Rescuer avatar + name
   - Current status badge: "On the way" (amber/green)
   - ETA (large, prominent): "Arriving in 12 minutes"
   - Distance remaining: "2.1 km away"
   - Last updated: "Updated 30 seconds ago"

4. **Quick Action Bar (inside status card):**
   - Call button
   - Message button
   - Share location button

5. **Collapse/Expand:**
   - Card can be collapsed to show minimal info (just ETA)
   - Can be expanded to show full details

#### Stitch Prompt (English):

```
Mobile app full-screen map tracking interface for snake rescue app "SnakeAid". Map-first design with overlay UI elements.

Full screen displays map view (use placeholder: light gray background with minimal street lines pattern). 

Map markers:
- Blue location pin marker labeled "You" at bottom-center of map
- Green location pin marker with small circular avatar overlay labeled "Rescuer" at top-left of map
- Dashed blue route line connecting the two pins

Top overlay (translucent white bar with shadow): Back arrow button on left (white background, circular), centered text "Đang Cứu Hộ" in white/dark gray, minimize button on right.

Bottom of screen: Draggable white card with rounded top corners (20px radius) and shadow. Small horizontal handle bar at top-center of card (gray, 40px wide, 4px tall, rounded).

Inside card:
- Left side: Small circular avatar (40px) of rescuer
- Right of avatar: Bold name "Nguyễn Văn A"
- Below name: Small amber badge "Đang trên đường" with arrow icon

Main ETA section (prominent):
- Large bold text "12 phút" in forest green (#228B22), 32pt font
- Above it, small gray text "Sẽ đến trong"
- Below it, medium gray text "Cách 2.1 km"

Below ETA, small gray text "Cập nhật 30 giây trước" with refresh icon.

Bottom section of card: Three equal-width outlined buttons in horizontal row with forest green borders:
- Phone icon button "Gọi"
- Message icon button "Nhắn Tin"  
- Share icon button "Chia Sẻ"

Design: Map-based navigation interface, floating overlay controls, real-time tracking visualization, minimal UI to maximize map visibility.
```

#### Notes for Stitch:
- Map phải chiếm phần lớn màn hình
- Bottom sheet card phải rõ ràng là draggable (có handle)
- ETA text phải rất nổi bật (largest text on screen)
- Nếu Stitch không render map đẹp → "Use simple gray background with minimal street grid lines, focus on markers and route line"

---

### Screen 7: Rescuer Arrived Screen

#### Thông tin màn hình:
- **Tên:** Màn hình rescuer đã đến nơi
- **Mục đích:** Thông báo rescuer đã đến và đang xử lý
- **Flow position:** Sau khi rescuer cập nhật "Đã đến"
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Rescuer Arrived"
   - Timer (total elapsed time)

2. **Status Banner:**
   - Green background
   - Checkmark icon
   - Text: "The rescuer is now at your location"

3. **Current Status Card:**
   - Large icon (person with tool)
   - Status badge: "Handling snake" (amber or blue)
   - Description: "The rescuer is safely capturing the snake"

4. **Rescuer Info Summary:**
   - Avatar
   - Name
   - Quick action buttons: Call / Message

5. **What to Do:**
   - Instructions for patient:
     - "Stay at a safe distance"
     - "Do not approach the snake"
     - "The rescuer will update you when complete"

6. **Estimated Completion:**
   - Text: "Typical rescue takes 10-20 minutes"

7. **Action Button:**
   - Text link: "Cancel rescue (if needed)"

#### Stitch Prompt (English):

```
Mobile app status screen showing rescuer has arrived for snake rescue in app "SnakeAid". Confirmation interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Đội Cứu Hộ Đã Đến", right side timer "15:30".

Full-width success banner with light green background (#D4EDDA) and green checkmark icon on left. Bold text "Đội cứu hộ đã có mặt tại vị trí của bạn" in dark green.

Main white card with subtle shadow. Center contains large icon illustration of person with rescue tool (simple line art, forest green color). Below icon, blue badge "Đang Xử Lý" with wrench/tool icon. Below badge, medium gray text "Đội cứu hộ đang an toàn bắt rắn".

Below status card, smaller white card showing horizontal layout: Left side has small circular avatar (50px) of rescuer. Right side shows bold name "Nguyễn Văn A" with two small outlined buttons below: "Gọi" and "Nhắn Tin" in forest green borders.

Next section titled "Điều Cần Làm" in dark gray bold. White card with yellow-amber background (#FFF3CD) containing 3 bullet points:
• Giữ khoảng cách an toàn
• Không tiếp cận con rắn
• Đội cứu hộ sẽ thông báo khi hoàn tất

Below instructions, gray text "Thường mất khoảng 10-20 phút để cứu hộ" with clock icon.

Bottom: Centered small gray text link "Hủy cứu hộ (nếu cần)".

Design: In-progress status interface, reassuring messaging, clear safety instructions, minimal interaction needed.
```

#### Notes for Stitch:
- Screen này tập trung vào reassurance - patient cần biết mọi việc đang được xử lý
- Icon minh họa rescuer phải đơn giản và professional
- Yellow instruction box phải dễ đọc với contrast tốt

---

### Screen 8: Balance Payment & Rating Screen

#### Thông tin màn hình:
- **Tên:** Màn hình thanh toán số dư và đánh giá
- **Mục đích:** Thanh toán số tiền còn lại (Tổng - Cọc 150K) và đánh giá rescuer sau khi hoàn thành
- **Flow position:** Giai đoạn 2.4 - Sau khi rescue hoàn tất
- **Priority:** ⭐⭐⭐
- **Related:** Payment Flow 1 - Balance payment (Total fee - 150K deposit)

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Service Complete"

2. **Completion Banner:**
   - Green success background
   - Checkmark icon
   - Text: "Snake successfully removed!"
   - Subtitle: "Thank you for using SnakeAid"

3. **Service Summary Card:**
   - Rescuer info (avatar + name)
   - Service details:
     - Snake species handled
     - Time taken: "25 minutes"
     - Date & time completed
   - Photos (if uploaded by rescuer): thumbnails of captured snake

4. **Balance Payment Section:**
   - Title: "Số Dư Còn Lại"
   - Info box (light blue):
     - "Bạn đã thanh toán 150,000 VNĐ đặt cọc trước đó"
     - "Hoàn tất thanh toán số dư còn lại"
   - Breakdown:
     - Total service fee: "575,000 VNĐ" (or actual calculated fee)
     - Deposit paid: "-150,000 VNĐ" (green, with checkmark)
     - Divider line
     - Balance due: "425,000 VNĐ" (bold, large, forest green)
   - Note: Final balance = Total fee - 150K deposit

5. **Payment Method Selection:**
   - Title: "Select Payment Method"
   - Note: "Use same method or choose new one"
   - Radio buttons or cards for:
     - Momo (with logo) - if used for deposit, show "Used for deposit" badge
     - VNPay (with logo)
     - ZaloPay (with logo)
     - Credit Card

6. **Rating Section:**
   - Title: "Rate Your Experience"
   - 5 star rating (tap to select)
   - Text input: "Write a review (optional)"
   - Character count: "0/200"

7. **Action Buttons:**
   - Large primary button: "Thanh Toán Số Dư (425,000 VNĐ) & Gửi Đánh Giá"
   - Secondary text link: "Khiếu nại / Báo cáo sự cố"

#### Stitch Prompt (English):

```
Mobile app balance payment and rating screen for completed snake rescue in app "SnakeAid". Transaction completion interface with forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Hoàn Thành Dịch Vụ".

Full-width success banner with light green background (#D4EDDA). Large green checkmark icon centered above text. Bold dark green text "Đã loại bỏ rắn thành công!" Below that, smaller gray text "Cảm ơn bạn đã sử dụng SnakeAid".

Main white card showing service summary. Top shows small circular avatar (50px) and bold name "Nguyễn Văn A" next to it. Below, 3 lines of gray text with icons:
- Snake icon: "Loài: Rắn hổ mang chúa"
- Clock icon: "Thời gian: 25 phút"
- Calendar icon: "15/12/2025 - 3:15 PM"

Horizontal row of 2 small thumbnail images (square, rounded corners) labeled "Ảnh từ ca cứu hộ".

Next section titled "Thanh Toán Số Dư Còn Lại" in dark gray bold. Light blue info box (#E7F3FF) with 2 lines:
• Bạn đã thanh toán 150,000 VNĐ đặt cọc trước đó
• Hoàn tất thanh toán số dư còn lại

White card with payment breakdown:
- "Tổng chi phí dịch vụ" left aligned, "575,000 VNĐ" right aligned (dark gray)
- "Đặt cọc đã thanh toán" left aligned, "-150,000 VNĐ" right aligned (green with checkmark icon)
- Thin gray divider line
- "Số Dư Còn Lại" bold left, "425,000 VNĐ" bold large right (forest green color, 24pt)

Next section titled "Chọn Phương Thức Thanh Toán". Small gray text "Dùng lại phương thức cũ hoặc chọn mới". Four horizontally arranged payment option cards (equal width, white background, forest green border when selected):
- Card 1: "Momo" with Momo logo placeholder and small purple badge "Đã dùng cho đặt cọc" (selected with forest green border)
- Card 2: "VNPay" with VNPay logo placeholder
- Card 3: "ZaloPay" with ZaloPay logo placeholder
- Card 4: "Thẻ" with credit card icon

Below payment, section titled "Đánh Giá Trải Nghiệm". Row of 5 large star outlines (yellow/amber color). First 4 stars filled, 5th empty (indicating 4-star rating). 

Below stars, multiline text input field with placeholder "Viết nhận xét (tùy chọn)" and character counter "0/200" in bottom-right.

Bottom section: Large solid forest green button "Thanh Toán Số Dư (425,000 VNĐ) & Gửi Đánh Giá" spanning full width. Below button, centered gray text link "Khiếu nại / Báo cáo sự cố".

Design: Balance payment completion flow, clear deposit reference, remaining amount prominent, integrated rating system, mobile payment optimization.
```

#### Notes for Stitch:
- Payment method cards phải rõ ràng về selection state (border color change)
- Star rating phải large và easy to tap (minimum 44px touch target)
- Pricing breakdown phải align rõ ràng left-right như invoice thực tế
- Nếu logo payment không có → "Use simple text labels with colored backgrounds: Momo (pink), VNPay (blue), ZaloPay (blue), Card (gray)"

---

## 📋 SUMMARY - SCREEN FLOW

### Luồng các màn hình theo thứ tự:

```
1. Trang Chủ
   → (Người dùng chọn "Báo Cáo Rắn" từ Quick Actions)
   ↓
2. Màn Hình Báo Cáo Phát Hiện Rắn
   → (Chụp ảnh, điền thông tin, gửi báo cáo)
   ↓
3. Màn Hình Kết Quả Nhận Diện AI
   → (Người dùng chọn "Yêu Cầu Đội Cứu Hộ")
   ↓
4. Màn Hình Xác Nhận Yêu Cầu Cứu Hộ
   → (Xác nhận và thanh toán phí dịch vụ)
   ↓
5. Màn Hình Đang Tìm Đội Cứu Hộ
   → (Hệ thống tìm và ghép nối với rescuer)
   ↓
6. Màn Hình Đã Tìm Thấy Đội Cứu Hộ
   → (Người dùng chọn "Xem Theo Dõi Trực Tiếp")
   ↓
7. Màn Hình Bản Đồ Theo Dõi Trực Tiếp
   → (Đội cứu hộ đến nơi và bắt đầu xử lý)
   ↓
8. Màn Hình Đội Cứu Hộ Đã Đến
   → (Đội cứu hộ hoàn thành nhiệm vụ)
   ↓
9. Màn Hình Thanh Toán & Đánh Giá
   → (Người dùng thanh toán và đánh giá, kết thúc)
```

---

## 🎯 DESIGN PRINCIPLES FOR RESCUE FLOW

### 1. **Trust & Safety:**
- Hiển thị verified badges và ratings để tạo niềm tin
- Luôn hiển thị thông tin rescuer rõ ràng (avatar, name, contact)
- Cung cấp options để liên lạc (call/message) mọi lúc

### 2. **Real-time Updates:**
- ETA và distance phải update liên tục
- Status badges thay đổi theo real-time (On the way → Arrived → Handling)
- "Last updated X seconds ago" để user biết data mới nhất

### 3. **Transparency:**
- Pricing breakdown rõ ràng trước khi confirm
- Hiển thị "what happens next" để user biết quy trình
- Photos và details sau rescue để user xác nhận công việc

### 4. **Progressive Disclosure:**
- Không overwhelming user với quá nhiều info cùng lúc
- Map screen: focus vào map, details ở bottom sheet
- Expandable sections cho optional info (Species Details)

### 5. **Error Handling:**
- "Cancel rescue" option available ở mọi stage
- "Pay later / Dispute" cho payment issues
- Fallback: "No rescuer found" → suggest alternatives

---

### Screen 9: Community Alert Confirmation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận cảnh báo cộng đồng
- **Mục đích:** Hiển thị xác nhận khi user chọn "Alert Community Only" thay vì request rescue
- **Flow position:** Alternative path từ Screen 2 (AI Recognition Result)
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Alert Sent"
   - Close button (X)

2. **Success Icon:**
   - Large checkmark or bell icon
   - Green success color

3. **Confirmation Message:**
   - Main heading: "Community Alert Sent!"
   - Subtitle: "Nearby users have been notified about this snake sighting"

4. **Alert Details Card:**
   - Snake species detected
   - Location
   - Number of users notified (e.g., "27 users within 2km")
   - Time sent

5. **Map Preview:**
   - Small map showing alert radius
   - User's location at center
   - Circular radius indicator

6. **What Happens Next:**
   - Info section explaining:
     - "Nearby users will receive notification"
     - "They can see photo and location"
     - "Alert expires in 24 hours"

7. **Action Buttons:**
   - Primary button: "Back to Home"
   - Secondary text link: "View Alert History"

#### Stitch Prompt (English):

```
Mobile app confirmation screen for community snake alert in app "SnakeAid". Success notification interface with forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Đã Gửi Cảnh Báo", X close button right.

Center of screen features large green bell icon (or checkmark with bell) in success green (#28A745), 80px size. Below icon, large bold heading "Đã Gửi Cảnh Báo Cộng Đồng!" in dark gray. Below that, medium gray text "Người dùng lân cận đã được thông báo về rắn này".

White card with subtle shadow showing alert details. Inside card, 4 lines with icons:
- Snake icon: "Loài: Rắn hổ mang chúa"
- Location pin icon: "123 Tên đường, Quận"
- Users icon: "Đã thông báo 27 người trong bán kính 2km"
- Clock icon: "04/12/2025 - 3:15 PM"

Below details card, small map preview (rectangular, 16:9 ratio, placeholder background). Map shows blue pin marker at center with circular radius overlay in light blue transparent color. Text overlay on map bottom: "Bán Kính Cảnh Báo: 2km".

Next section titled "Điều Gì Sẽ Xảy Ra Tiếp Theo" in dark gray bold. White card with light blue background (#E7F3FF) containing 3 bullet points:
• Người dùng lân cận sẽ nhận thông báo
• Họ có thể xem ảnh và vị trí
• Cảnh báo hết hạn sau 24 giờ

Bottom section has 2 elements:
- Large solid forest green button "Về Trang Chủ" spanning full width
- Below button, centered blue text link "Xem Lịch Sử Cảnh Báo"

Design: Success confirmation interface, informative and reassuring, community-focused messaging, clean hierarchy.
```

#### Notes for Stitch:
- Success icon phải lớn và prominent để convey success state
- Map preview với radius circle để visualize alert area
- Light blue info card để distinguish từ yellow warning boxes

---

### Screen 10: No Rescuer Found Screen

#### Thông tin màn hình:
- **Tên:** Màn hình không tìm thấy đội cứu hộ
- **Mục đích:** Hiển thị khi không có rescuer available sau thời gian timeout
- **Flow position:** Alternative path từ Screen 4 (Searching for Rescuer)
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "No Rescuer Available"

2. **Status Icon:**
   - Sad face or empty search icon
   - Amber/orange color

3. **Main Message:**
   - Heading: "We couldn't find a rescuer nearby"
   - Explanation: "No rescue teams are available in your area at this time"

4. **Search Details Card:**
   - Show what was searched:
     - "Searched within: 20km radius"
     - "Search duration: 5 minutes"
     - "Rescuers contacted: 8"

5. **Alternative Options Section:**
   - Title: "What You Can Do"
   - 3 option cards:
     
     **Option 1:**
     - Icon: Expand icon
     - "Expand Search Area"
     - "Search up to 50km with +20% service fee"
     - Button: "Try Again"
     
     **Option 2:**
     - Icon: Phone icon
     - "Call Animal Control"
     - "Contact local authorities directly"
     - Button: "Call 115"
     
     **Option 3:**
     - Icon: Bell icon
     - "Alert Community"
     - "Let nearby users know about the snake"
     - Button: "Send Alert"

6. **Bottom Actions:**
   - Text link: "Cancel and go back"

#### Stitch Prompt (English):

```
Mobile app error state screen for no rescuer found in snake rescue app "SnakeAid". Problem-solving interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Không Có Đội Cứu Hộ".

Center top section shows amber/orange colored icon (empty search or sad face emoji), 64px size. Below icon, large bold heading "Không tìm thấy đội cứu hộ gần đây" in dark gray. Below that, medium gray text "Hiện không có đội cứu hộ nào trong khu vực của bạn".

White card with subtle shadow titled "Tóm Tắt Tìm Kiếm" showing 3 lines:
- "Đã tìm kiếm trong: Bán kính 20km"
- "Thời gian tìm: 5 phút"  
- "Số đội cứu hộ đã liên hệ: 8"
All text in medium gray with small icons on left.

Below summary, bold heading "Bạn Có Thể Làm Gì" in dark gray.

Three vertically stacked option cards with white background and subtle shadow. Each card has left icon, title, subtitle, and right action button:

CARD 1: Left has expand/arrows icon in forest green. Title "Mở Rộng Vùng Tìm Kiếm" bold dark gray. Subtitle "Tìm kiếm trong 50km với phí thêm +20%" in medium gray. Right side: Forest green outlined button "Thử Lại".

CARD 2: Left has phone icon in blue. Title "Gọi Kiểm Soát Động Vật" bold. Subtitle "Liên hệ cơ quan chức năng trực tiếp" in gray. Right side: Blue outlined button "Gọi 115".

CARD 3: Left has bell icon in amber. Title "Cảnh Báo Cộng Đồng" bold. Subtitle "Thông báo cho người dùng lân cận về con rắn" in gray. Right side: Amber outlined button "Gửi Cảnh Báo".

Bottom: Centered gray text link "Cancel and go back".

Design: Error recovery interface, solution-focused, multiple clear alternatives, non-alarming tone.
```

#### Notes for Stitch:
- Không dùng red color để tránh panic - dùng amber/orange cho neutral tone
- 3 option cards phải equal height và rõ ràng về CTA
- "Try Again" option phải nổi bật nhất (forest green color)

---

### Screen 11: Rescue Cancellation Confirmation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận hủy cứu hộ
- **Mục đích:** Xác nhận và xử lý khi user hoặc rescuer cancel request
- **Flow position:** Có thể trigger từ nhiều screens (Screen 4, 5, 6, 7)
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Cancel Rescue?"

2. **Warning Icon:**
   - Alert/warning icon (amber color)

3. **Confirmation Message:**
   - Heading: "Are you sure you want to cancel?"
   - Explanation based on stage:
     - If before rescuer arrives: "The rescuer is on the way"
     - If rescuer arrived: "The rescuer has already arrived at location"

4. **Cancellation Fee Info (if applicable):**
   - Yellow info box explaining:
     - "Cancellation after rescuer departs: 50% fee"
     - "Cancellation after arrival: 100% fee"
     - "Free cancellation before rescuer departs"

5. **Reason Selection (optional):**
   - Title: "Why are you cancelling? (Optional)"
   - Radio buttons or dropdown:
     - "Snake already gone"
     - "Took too long"
     - "Found another solution"
     - "Changed my mind"
     - "Other"

6. **Rescuer Info Reminder:**
   - Small card showing rescuer who will be affected
   - Avatar, name, current status

7. **Action Buttons:**
   - Primary button (amber): "Yes, Cancel Rescue"
   - Secondary button (forest green): "No, Continue Rescue"

#### Stitch Prompt (English):

```
Mobile app cancellation confirmation dialog for snake rescue in app "SnakeAid". Decision confirmation interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Hủy Cứu Hộ?".

Center shows amber warning triangle icon, 64px. Below icon, large bold heading "Bạn có chắc muốn hủy?" in dark gray. Below that, medium gray text "Đội cứu hộ đang trên đường đến vị trí của bạn".

Yellow warning box (#FFF3CD background, #FFC107 left border) titled "Phí Hủy" in bold. Inside box, 3 lines in dark gray:
• Hủy miễn phí trước khi đội cứu hộ khởi hành
• Hủy sau khi khởi hành: Phí 50% (150,000 VNĐ)
• Hủy sau khi đã đến: Phí 100% (300,000 VNĐ)

Below warning box, section titled "Lý do hủy? (Tùy chọn)" in dark gray. White card containing 5 radio button options vertically stacked:
○ Rắn đã biến mất
○ Mất quá nhiều thời gian
○ Đã tìm được giải pháp khác
○ Đổi ý
○ Lý do khác

Bottom section shows small white card with gray border labeled "Thông Tin Đội Cứu Hộ". Horizontal layout: Left has small avatar (40px), right shows name "Nguyễn Văn A" bold and status "Đang di chuyển - còn 8 phút" in gray with amber badge.

Bottom buttons vertically stacked with 12px spacing:
- Large amber button (#FFC107) "Có, Hủy Cứu Hộ"
- Large forest green outlined button "Không, Tiếp Tục Cứu Hộ"

Design: Cautious confirmation interface, clear consequence communication, respectful of rescuer, provides exit option.
```

#### Notes for Stitch:
- Warning box với cancellation fees phải rất rõ ràng
- Green "Continue" button phải nổi bật hơn amber "Cancel" để encourage keeping rescue
- Rescuer info reminder để humanize decision

---

## 📋 SUMMARY - SCREEN FLOW (UPDATED)

### Luồng các màn hình theo thứ tự:

```
1. Trang Chủ
   → (Người dùng chọn "Báo Cáo Rắn" từ Quick Actions)
   ↓
2. Màn Hình Báo Cáo Phát Hiện Rắn
   → (Chụp ảnh, điền thông tin, gửi báo cáo)
   ↓
3. Màn Hình Kết Quả Nhận Diện AI
   ├─→ (Lựa chọn A: Chọn "Yêu Cầu Đội Cứu Hộ")
   │   ↓
   │   4. Màn Hình Xác Nhận Yêu Cầu Cứu Hộ
   │      → (Xác nhận và thanh toán phí dịch vụ)
   │      ↓
   │      5. Màn Hình Đang Tìm Đội Cứu Hộ
   │      ├─→ (Thành công: Tìm thấy đội cứu hộ)
   │      │   ↓
   │      │   6. Màn Hình Đã Tìm Thấy Đội Cứu Hộ
   │      │      → (Chọn "Xem Theo Dõi Trực Tiếp")
   │      │      ↓
   │      │      7. Màn Hình Bản Đồ Theo Dõi Trực Tiếp
   │      │         → (Đội cứu hộ đến nơi và bắt đầu xử lý)
   │      │         ↓
   │      │         8. Màn Hình Đội Cứu Hộ Đã Đến
   │      │            → (Đội cứu hộ hoàn thành nhiệm vụ)
   │      │            ↓
   │      │            9. Màn Hình Thanh Toán & Đánh Giá
   │      │               → (Kết thúc luồng)
   │      │
   │      └─→ (Hết thời gian: Không tìm thấy đội cứu hộ)
   │          ↓
   │          10. Màn Hình Không Có Đội Cứu Hộ
   │              ├─→ Thử lại với bán kính mở rộng → Quay lại Screen 5
   │              ├─→ Gọi dịch vụ khẩn cấp → Thoát app
   │              └─→ Cảnh báo cộng đồng → Screen 9
   │
   └─→ (Lựa chọn B: Chọn "Chỉ Cảnh Báo Cộng Đồng")
       ↓
       9. Màn Hình Xác Nhận Cảnh Báo Cộng Đồng
          → (Kết thúc luồng)

LUỒNG HỦY (có thể truy cập từ Screens 4, 5, 6, 7, 8):
   → Người dùng chọn "Hủy cứu hộ"
   ↓
   11. Màn Hình Xác Nhận Hủy Cứu Hộ
       ├─→ Xác nhận hủy → Quay về Trang Chủ
       └─→ Tiếp tục cứu hộ → Quay lại màn hình trước
```

---

## 🔄 ADDITIONAL ENHANCEMENTS TO CONSIDER

### Screens đã thiết kế đầy đủ trong document này:

✅ **Main Flow (8 screens):**
1. Màn Hình Báo Cáo Phát Hiện Rắn
2. Màn Hình Kết Quả Nhận Diện AI
3. Màn Hình Xác Nhận Yêu Cầu Cứu Hộ
4. Màn Hình Đang Tìm Đội Cứu Hộ
5. Màn Hình Đã Tìm Thấy Đội Cứu Hộ
6. Màn Hình Bản Đồ Theo Dõi Trực Tiếp
7. Màn Hình Đội Cứu Hộ Đã Đến
8. Màn Hình Thanh Toán & Đánh Giá

✅ **Alternative/Error Flows (3 screens):**
9. Màn Hình Xác Nhận Cảnh Báo Cộng Đồng
10. Màn Hình Không Có Đội Cứu Hộ
11. Màn Hình Xác Nhận Hủy Cứu Hộ

### Màn hình bổ sung có thể cần trong future iterations:

1. **Rescuer Rejected Screen:**
   - Khi rescuer từ chối request
   - Tự động tìm rescuer khác
   
2. **Payment Failed Screen:**
   - Khi thanh toán bị lỗi
   - Options to retry hoặc change payment method

3. **Expert Consultation Screen:**
   - Khi rescuer cần tư vấn expert (Flow 3.2 trong swimlane)
   - Video call hoặc chat interface

### Screens có thể thiết kế sau (lower priority):

1. **Rescuer Rejected Screen:**
   - Khi rescuer từ chối trong thời gian chờ
   - Tự động search rescuer khác

2. **Payment Failed Retry Screen:**
   - Khi thanh toán bị lỗi technical
   - Options to retry with same/different method

3. **Expert Consultation Screen:**
   - Khi rescuer request tư vấn từ expert (mentioned in swimlane Flow 3.2)
   - Video call hoặc chat interface để expert support rescuer

---

## 📝 IMPLEMENTATION NOTES

### For Developers:

1. **API Integration Points:**
   - `POST /api/rescue/request` - Submit rescue request (Screen 3)
   - `GET /api/rescue/find-rescuers` - Find available rescuers (Screen 4)
   - `POST /api/rescue/accept` - Rescuer accepts request (Screen 5)
   - `GET /api/rescue/track/:id` - Real-time location tracking (Screen 6)
   - `PUT /api/rescue/status` - Update rescue status (Screens 6, 7)
   - `POST /api/rescue/complete` - Mark rescue complete (Screen 8)
   - `POST /api/rescue/cancel` - Cancel rescue request (Screen 11)
   - `POST /api/payment/process` - Process payment (Screen 8)
   - `POST /api/rating/submit` - Submit rating (Screen 8)
   - `POST /api/alert/community` - Send community alert (Screen 9)

2. **Real-time Features:**
   - WebSocket connection for live location updates
   - Push notifications for status changes
   - Auto-refresh ETA every 30 seconds

3. **Image Handling:**
   - Compress images before upload (max 2MB)
   - Support multiple image upload (max 5 photos)
   - Thumbnail generation for gallery view

4. **Payment Integration:**
   - Integrate Momo, VNPay, ZaloPay SDKs
   - Implement escrow system (hold payment until completion)
   - Handle payment failures gracefully

5. **Map Integration:**
   - Use Google Maps SDK / Mapbox
   - Custom markers for user and rescuer
   - Route calculation with real-time traffic

---

## ✅ CHECKLIST FOR STITCH IMPLEMENTATION

### Before generating with Stitch:

- [ ] Review all 11 screen prompts (8 main + 3 alternative)
- [ ] Confirm color codes match design system
- [ ] Verify all text content is clear and accurate
- [ ] Check that component sizes are specified (when critical)
- [ ] Ensure button hierarchy is clear (primary/secondary)
- [ ] Confirm mobile-first responsive approach
- [ ] Validate error/alternative flows are covered

### After Stitch generates designs:

- [ ] Verify color consistency across all screens
- [ ] Check text readability (contrast ratios)
- [ ] Validate touch target sizes (minimum 44x44px)
- [ ] Test visual hierarchy on each screen
- [ ] Ensure consistent spacing and padding
- [ ] Verify icon consistency and clarity
- [ ] Check that cards have proper shadows and borders
- [ ] Validate that maps and images have proper placeholders

---

## 🔗 RELATED DOCUMENTATION

- Main Flow Document: `/01-Requirements/Main-Flow/Main-Flow.md` (Section 2)
- Swimlane Diagram: `/01-Requirements/Swimlane-Diagram/02-Swimlane-Rescue-Request-Flow.md`
- Feature List: `/01-Requirements/Major-Features/Major-Features-Summary.md`
- Emergency Flow Screens: `/02-UI-Design/Patient-Emergency-Flow-Screens.md` (for reference)

---

**Document Status:** ✅ Complete & Comprehensive - Ready for Stitch implementation  
**Role Coverage:** 🧑 **PATIENT ONLY** (Rescuer & Expert screens in separate documents)
**Screens Covered:** 11 screens (8 main flow + 3 alternative/error flows)
**Coverage:** 100% of swimlane diagram flows including error cases
**Last Updated:** December 4, 2025  

**Next Steps:** 
1. ✅ Generate designs with Stitch for Patient screens
2. ⏳ Create separate document: **Rescuer-Rescue-Request-Flow-Screens.md** (FE-01 to FE-27)
3. ⏳ Create separate document: **Expert-Consultation-Flow-Screens.md** (FE-01 to FE-16)
