# EXPERT CONSULTATION FLOW - UI DESIGN SCREENS (PATIENT ROLE)

## Thông tin tài liệu
- **Tên dự án:** SnakeAid - AI-Powered Platform for Snakebite First Aid and Rescue Support
- **Module:** Patient Mobile Application
- **Role:** 🧑 **PATIENT** (Người dùng cần tư vấn chuyên gia về rắn)
- **Flow:** Expert Consultation Flow (Tư vấn chuyên gia)
- **Công cụ thiết kế:** Stitch with Google (prompt-based design)
- **Số lượng màn hình:** 8 screens (6 main screens + 2 alternative screens)
- **Ngày tạo:** December 5, 2025
- **Location:** `/02-UI-Design/Patient-Expert-Consultation-Flow-Screens.md`

> **⚠️ LƯU Ý:** Document này chỉ cover màn hình cho **PATIENT role**. 
> Màn hình cho **Expert** sẽ được thiết kế trong document riêng.

---

## 🎨 Design System Overview

### Color Palette:
- **Primary Color:** Forest Green `#228B22`
- **Background:** White `#FFFFFF`
- **Text Primary:** Dark Gray `#333333`
- **Text Secondary:** Medium Gray `#666666`
- **Accent - Success:** Green `#28A745`
- **Accent - Info:** Blue `#007BFF`
- **Accent - Warning:** Amber `#FFC107`
- **Expert Badge:** Purple `#6F42C1`

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
- **Expert Cards:** Elevated with profile emphasis

---

## 📱 SCREEN DESIGNS & PROMPTS

> **🧑 Tất cả screens dưới đây là cho PATIENT role** - người dùng cần tư vấn về rắn

---

### Screen 1: Expert List Screen

#### Thông tin màn hình:
- **Tên:** Màn hình danh sách chuyên gia
- **Mục đích:** Hiển thị danh sách Snake Expert và cho phép tìm kiếm/lọc
- **Flow position:** Giai đoạn 3.1 - Bước 1-2: Truy cập và xem danh sách Expert
- **Priority:** ⭐⭐⭐ (Cao nhất)

#### Key Components:
1. **Header:**
   - Back button (top-left)
   - Title: "Chuyên Gia Rắn"
   - Search icon (top-right)

2. **Filter/Sort Bar:**
   - Dropdown "Chuyên môn" (Rắn độc VN / Rắn ngoại lai / Điều trị nọc độc)
   - Dropdown "Sắp xếp" (Rating cao / Phí thấp / Online)
   - Filter chips showing active filters

3. **Expert Cards (scrollable list):**
   Each card contains:
   - Circular avatar (60px) with online status dot
   - Name in bold
   - Specialization tag (e.g., "Rắn Độc Việt Nam")
   - Star rating: "4.9 ⭐ (128 đánh giá)"
   - Badge: "Đã Xác Minh" (purple)
   - Consultation fee: "150,000 VNĐ/30 phút"
   - Online status: Green dot + "Đang Online" (if available)
   - Right arrow for navigation

4. **Quick Stats Summary (top section):**
   - Total experts available
   - Number currently online

5. **Empty State (if no results):**
   - Icon: Magnifying glass
   - Message: "Không tìm thấy chuyên gia phù hợp"
   - Button: "Xóa bộ lọc"

#### Stitch Prompt (English):

```
Mobile app screen showing snake expert directory in "SnakeAid" app. Professional consultation interface with forest green (#228B22) primary color.

Top navigation: Back arrow left, centered title "Chuyên Gia Rắn", search icon right.

Below header, filter bar with two dropdowns horizontally arranged:
- Left dropdown: "Chuyên môn" with down arrow
- Right dropdown: "Sắp xếp theo" with down arrow
Below dropdowns, horizontal scrollable chips showing active filters in light gray with X icons.

Top section shows small stats card: "24 chuyên gia - 8 đang online" in medium gray text.

Main content area: Scrollable vertical list of expert cards. Each card is white with subtle shadow, rounded corners (12px), padding, with following layout:

CARD STRUCTURE:
Left side: Circular avatar image (60px diameter). Small green dot indicator overlaid on bottom-right if online.

Right side (vertical layout):
- Top line: Bold dark gray name "TS. Nguyễn Văn An"
- Second line: Purple rounded badge "Rắn Độc Việt Nam" (small, 8px padding)
- Third line: Yellow stars "4.9 ⭐" with gray text "(128 đánh giá)"
- Fourth line: Small purple badge "Đã Xác Minh" with checkmark icon
- Fifth line: Bold forest green text "150,000 VNĐ/30 phút"
- Bottom line: Small green dot + "Đang Online" in green text (only if online)

Far right: Gray chevron arrow icon for navigation.

Card spacing: 12px between cards vertically.

Design: Professional directory interface, clear information hierarchy, trust-building elements (verification, ratings), mobile-optimized card height (~110px).
```

#### Notes for Stitch:
- Online status phải rất rõ ràng với green dot nổi bật
- Verification badge tạo trust - phải dễ nhìn
- Nếu có quá nhiều info trên card → "Reduce text size for fee and rating to 14pt"

---

### Screen 2: Expert Profile Detail Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chi tiết chuyên gia
- **Mục đích:** Hiển thị thông tin đầy đủ về Expert và 2 lựa chọn tư vấn
- **Flow position:** Giai đoạn 3.1 - Bước 3: Xem chi tiết Expert
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: Expert's name
   - Share icon (to share profile)

2. **Expert Profile Section:**
   - Large circular avatar (100px) centered
   - Name with title (e.g., "TS." or "BS.")
   - Online status badge (green "Đang Online" or gray "Offline")
   - Star rating: "4.9 ⭐ (128 đánh giá)"
   - Verification badge: "Chuyên gia đã xác minh"

3. **Specialization Tags:**
   - Multiple rounded chips showing expertise areas

4. **About Section:**
   - Heading: "Giới Thiệu"
   - Bio text (3-5 lines)
   - "Xem thêm" link if text is long

5. **Experience & Qualifications:**
   - Education background
   - Years of experience
   - Notable achievements (bullet points)

6. **Statistics Row:**
   - Total consultations completed
   - Average response time
   - Success rate

7. **Pricing Section:**
   - Card showing:
     - "Phí Tư Vấn"
     - "150,000 VNĐ / 30 phút"
     - "200,000 VNĐ / 60 phút"

8. **Availability Calendar (mini preview):**
   - Shows next 7 days with availability dots
   - Link: "Xem lịch đầy đủ"

9. **Reviews Section:**
   - Heading: "Đánh Giá Từ Bệnh Nhân"
   - Show 2-3 recent reviews with:
     - User avatar + name
     - Star rating
     - Review text (truncated)
   - Button: "Xem tất cả đánh giá"

10. **Action Buttons (sticky bottom):**
    - Primary button (forest green): "Tư Vấn Ngay" (if online)
    - Secondary button (outlined): "Đặt Lịch Tư Vấn"

#### Stitch Prompt (English):

```
Mobile app expert profile detail screen for snake consultation app "SnakeAid". Professional profile interface with forest green (#228B22) theme.

Top navigation: Back arrow left, expert name "TS. Nguyễn Văn An" centered, share icon right.

Top section white card: Centered large circular avatar (100px). Below avatar, bold large name "TS. Nguyễn Văn An" in dark gray. Below name, green badge "Đang Online" with small dot icon. Below that, yellow stars "4.9 ⭐" with gray text "(128 đánh giá)". Below rating, small purple badge "Chuyên gia đã xác minh" with checkmark.

Below profile, horizontal scrollable row of expertise chips: "Rắn Độc Việt Nam", "Điều Trị Nọc Độc", "Cứu Hộ Rắn" - all purple background with white text, rounded (16px).

Section titled "Giới Thiệu" in bold dark gray. White card containing 4 lines of gray body text: "Chuyên gia hàng đầu về rắn độc Việt Nam với hơn 15 năm kinh nghiệm. Từng tư vấn cho hơn 500 ca rắn cắn nghiêm trọng..." Small blue text link "Xem thêm" at bottom right.

Section "Kinh Nghiệm" with white card containing 3 bullet points:
• Tiến sĩ Sinh học, Đại học Khoa học Tự nhiên
• 15 năm nghiên cứu về nọc rắn
• Cố vấn cho 5 bệnh viện lớn

Section "Thống Kê" with white card showing 3 columns:
- Column 1: "500+" bold dark gray, "Ca tư vấn" small gray below
- Column 2: "< 5 phút" bold, "Thời gian phản hồi" below
- Column 3: "98%" bold, "Tỷ lệ thành công" below

Section "Phí Tư Vấn" with white card:
- Line 1: "30 phút" left aligned gray, "150,000 VNĐ" right aligned bold forest green
- Line 2: "60 phút" left aligned gray, "200,000 VNĐ" right aligned bold forest green

Section "Lịch Trống" with 7 small day cards horizontally scrollable. Each card shows date number and colored dot (green for available, gray for busy). Blue text link "Xem lịch đầy đủ" on right.

Section "Đánh Giá Từ Bệnh Nhân" showing 2 review cards. Each review card has small circular avatar left, name "Nguyễn Thị B" bold, stars "5 ⭐" below name, gray review text "Tư vấn rất chi tiết và hữu ích..." Bottom shows gray text link "Xem tất cả đánh giá".

Bottom sticky section (white background, top shadow): Two vertically stacked buttons:
- Large solid forest green button "Tư Vấn Ngay"
- Large outlined forest green button "Đặt Lịch Tư Vấn"

Design: Professional profile showcase, trust-building elements, clear pricing, social proof via reviews, strong CTAs.
```

#### Notes for Stitch:
- Profile section phải tạo được trust và credibility
- Statistics numbers phải prominent để show expertise
- Nếu Expert offline → Disable "Tư Vấn Ngay" button và show "Chỉ đặt lịch"

---

### Screen 3: Consultation Type Selection Screen

#### Thông tin màn hình:
- **Tên:** Màn hình chọn loại tư vấn
- **Mục đích:** Cho phép chọn giữa Tư vấn ngay hoặc Đặt lịch
- **Flow position:** Giai đoạn 3.1 - Bước 4: Chọn loại tư vấn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chọn Loại Tư Vấn"
   - Expert mini info (avatar + name)

2. **Option A Card - Instant Consultation:**
   - Icon: Lightning bolt (urgent)
   - Title: "Tư Vấn Ngay"
   - Subtitle: "Chuyên gia sẽ phản hồi trong 2 phút"
   - Badge: "Đang Online" (green) or "Không Khả Dụng" (gray)
   - Price: "200,000 VNĐ" (có thể cao hơn 20-30%)
   - Features list:
     - ✓ Phản hồi tức thì
     - ✓ Chat hoặc video call
     - ✓ Không cần đặt trước
   - Button: "Chọn Tư Vấn Ngay" (disabled if expert offline)

3. **Option B Card - Scheduled Consultation:**
   - Icon: Calendar
   - Title: "Đặt Lịch Tư Vấn"
   - Subtitle: "Chọn thời gian phù hợp với bạn"
   - Price: "150,000 VNĐ"
   - Features list:
     - ✓ Linh hoạt thời gian
     - ✓ Chuẩn bị trước câu hỏi
     - ✓ Nhắc nhở trước 30 phút
   - Button: "Chọn Đặt Lịch"

4. **Info Box (bottom):**
   - Yellow background
   - Icon: Info circle
   - Text: "Bạn chỉ thanh toán sau khi hoàn thành tư vấn"

#### Stitch Prompt (English):

```
Mobile app consultation type selection screen for snake expert consultation in "SnakeAid". Choice comparison interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Chọn Loại Tư Vấn".

Below header, small white card showing expert mini profile: Small circular avatar (40px) left, name "TS. Nguyễn Văn An" bold right, specialization "Rắn Độc Việt Nam" in gray below name.

Main content: Two large vertically stacked option cards with equal height, white background, subtle shadow, rounded (12px).

CARD 1 (Instant Consultation):
Top left: Lightning bolt icon in amber/yellow color (32px).
Top right: Green badge "Đang Online".
Large bold heading "Tư Vấn Ngay" in dark gray.
Gray subtitle "Chuyên gia sẽ phản hồi trong 2 phút".
Large forest green price "200,000 VNĐ" centered.
Three checkmark bullet points in green:
✓ Phản hồi tức thì
✓ Chat hoặc video call
✓ Không cần đặt trước
Bottom: Large solid forest green button "Chọn Tư Vấn Ngay" spanning card width.

CARD 2 (Scheduled Consultation):
Top left: Calendar icon in blue color (32px).
Large bold heading "Đặt Lịch Tư Vấn".
Gray subtitle "Chọn thời gian phù hợp với bạn".
Large forest green price "150,000 VNĐ" centered.
Three checkmark bullet points in green:
✓ Linh hoạt thời gian
✓ Chuẩn bị trước câu hỏi
✓ Nhắc nhở trước 30 phút
Bottom: Large outlined forest green button "Chọn Đặt Lịch" spanning card width.

Bottom section: Yellow info box (#FFF3CD background) with amber left border. Info circle icon left, text "Bạn chỉ thanh toán sau khi hoàn thành tư vấn" in dark gray.

Design: Clear comparison interface, equal visual weight for both options, prominent pricing, feature-benefit lists, reassuring payment info.
```

#### Notes for Stitch:
- 2 cards phải equal height để fair comparison
- Instant option có premium feel với lightning icon
- Nếu expert offline → Card 1 phải disabled với gray badge "Không Khả Dụng"

---

### Screen 4: Schedule Selection Screen (for Option B)

#### Thông tin màn hình:
- **Tên:** Màn hình chọn lịch hẹn
- **Mục đích:** Cho phép chọn ngày giờ tư vấn từ lịch trống của Expert
- **Flow position:** Alternative path: Nếu chọn "Đặt Lịch Tư Vấn"
- **Priority:** ⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Chọn Thời Gian"
   - Expert mini profile

2. **Date Selector (horizontal scroll):**
   - Show next 14 days
   - Each day card shows:
     - Day name (T2, T3...)
     - Date number
     - Availability indicator (green dot = slots available)
   - Selected day highlighted with forest green border

3. **Time Slots Section:**
   - Title: "Giờ Khả Dụng - Thứ Hai, 05/12"
   - Grid of time slot buttons (2 columns):
     - Available slots: White with border
     - Booked slots: Gray with strikethrough
     - Selected slot: Forest green background
   - Each slot shows: "09:00 - 09:30"

4. **Selected Summary Card:**
   - Shows selected date + time
   - Duration: "30 phút"
   - Fee: "150,000 VNĐ"

5. **Action Buttons:**
   - Primary button: "Tiếp Tục" (active when slot selected)
   - Text link: "Quay lại"

#### Stitch Prompt (English):

```
Mobile app schedule selection screen for booking snake expert consultation in "SnakeAid". Calendar booking interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Chọn Thời Gian".

Below header, small white card with expert mini profile: Avatar (40px) left, name "TS. Nguyễn Văn An" bold, specialization gray text below.

Horizontal scrollable date selector showing 14 day cards. Each card (60px width) has rounded corners, white background. Content: Top shows day name "T.HAI" in small gray text, large date number "5" in dark gray center, small green dot at bottom if slots available. Selected card has forest green border (2px) and light green background.

Below date selector, section title "Giờ Khả Dụng - Thứ Hai, 05/12" bold dark gray.

Time slots grid (2 columns, gap 12px). Each slot is rectangular button with rounded corners (8px):
- Available slots: White background, gray border, text "09:00 - 09:30" dark gray
- Booked slots: Light gray background, strikethrough text, disabled appearance
- Selected slot: Solid forest green background, white text "09:00 - 09:30"
Show 8 time slots in grid (4 rows x 2 columns).

Bottom section white card with subtle shadow:
Heading "Bạn Đã Chọn" bold dark gray.
Line 1: Calendar icon left, "Thứ Hai, 05/12/2025" dark gray
Line 2: Clock icon left, "09:00 - 09:30 (30 phút)" dark gray
Line 3: Money icon left, "150,000 VNĐ" bold forest green
Thin divider line above button.

Bottom: Large solid forest green button "Tiếp Tục" spanning full width. Below button, centered gray text link "Quay lại".

Design: Calendar booking interface, clear availability visualization, confirmed selection summary, intuitive time slot grid.
```

#### Notes for Stitch:
- Date selector phải scroll-friendly với swipe gesture
- Booked slots phải rõ ràng là không chọn được
- Selected slot phải stand out với green background

---

### Screen 5: Upload Documents Screen

#### Thông tin màn hình:
- **Tên:** Màn hình upload tài liệu tư vấn
- **Mục đích:** Cho phép upload ảnh và mô tả vấn đề trước khi tư vấn
- **Flow position:** Giai đoạn 3.1 - Bước 5: Upload tài liệu cần tư vấn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Tài Liệu Tư Vấn"
   - Progress indicator: "Bước 2/3"

2. **Consultation Summary Card (top):**
   - Expert info
   - Selected date/time (if scheduled)
   - Or "Tư vấn ngay" status

3. **Photo Upload Section:**
   - Title: "Ảnh Rắn hoặc Vết Cắn"
   - Large dashed border box for upload
   - Icon: Camera
   - Text: "Chụp ảnh hoặc chọn từ thư viện"
   - Note: "Có thể upload tối đa 5 ảnh"
   - After upload: Show thumbnails in horizontal scroll
   - Each thumbnail has small X button to remove

4. **Problem Description Section:**
   - Title: "Mô Tả Vấn Đề"
   - Large text area (multiline)
   - Placeholder: "Ví dụ: Con rắn xuất hiện trong vườn nhà tôi, dài khoảng 1m, có vằn đen vàng..."
   - Character counter: "0/500"

5. **Questions Section:**
   - Title: "Câu Hỏi Cụ Thể (Tùy chọn)"
   - Text area
   - Placeholder: "Bạn muốn hỏi gì chuyên gia?"
   - Character counter: "0/300"

6. **Helper Text:**
   - Info icon + "Thông tin càng chi tiết, tư vấn càng hiệu quả"

7. **Action Buttons:**
   - Primary button: "Tiếp Tục Thanh Toán"
   - Secondary link: "Bỏ qua (không upload)"

#### Stitch Prompt (English):

```
Mobile app document upload screen for snake expert consultation in "SnakeAid". Upload and form interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Tài Liệu Tư Vấn", right side small badge "Bước 2/3".

Top section white card: Small avatar (40px) of expert left, name "TS. Nguyễn Văn An" bold, below shows calendar icon + "Thứ Hai, 05/12 - 09:00" in gray, below shows clock icon + "30 phút" and money icon "150,000 VNĐ" in green.

Section title "Ảnh Rắn hoặc Vết Cắn" bold dark gray. Large dashed border rectangle (aspect 16:9) with light gray background. Center contains camera icon (48px) and text "Chụp ảnh hoặc chọn từ thư viện" in medium gray. Below rectangle, small gray text "Có thể upload tối đa 5 ảnh".

After photos added: Show horizontal scrollable row of photo thumbnails (square 80px each, rounded corners). Each thumbnail has small circular X button (white background, gray X icon) overlaid on top-right corner.

Section "Mô Tả Vấn Đề" bold with red asterisk (required field). White card containing large multiline text input field with placeholder "Ví dụ: Con rắn xuất hiện trong vườn nhà tôi, dài khoảng 1m..." in light gray. Bottom right of card shows character counter "0/500" in small gray text.

Section "Câu Hỏi Cụ Thể (Tùy chọn)" bold. White card with multiline text input, placeholder "Bạn muốn hỏi gì chuyên gia?". Character counter "0/300" bottom right.

Light blue info box (#E7F3FF) with info icon left and text "Thông tin càng chi tiết, tư vấn càng hiệu quả" in dark gray.

Bottom section: Large solid forest green button "Tiếp Tục Thanh Toán" spanning full width. Below button, centered gray text link "Bỏ qua (không upload)".

Design: Upload-focused interface, clear required vs optional fields, helpful guidance, progress indication, flexible photo management.
```

#### Notes for Stitch:
- Upload area phải large và easy to tap
- Photo thumbnails phải có X button rõ ràng để remove
- Character counter update real-time khi user typing
- Required field (Mô tả) phải có red asterisk

---

### Screen 6: Payment Confirmation Screen

#### Thông tin màn hình:
- **Tên:** Màn hình xác nhận thanh toán
- **Mục đích:** Hiển thị tóm tắt và xử lý thanh toán tư vấn
- **Flow position:** Giai đoạn 3.1 - Bước 6: Thanh toán phí tư vấn
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Back button
   - Title: "Xác Nhận & Thanh Toán"

2. **Consultation Summary Card:**
   - Expert profile (avatar + name + badge)
   - Consultation type: "Tư vấn đặt lịch" or "Tư vấn ngay"
   - Date & Time (if scheduled)
   - Duration: "30 phút"

3. **Uploaded Documents Preview:**
   - Small section showing uploaded photos count: "3 ảnh"
   - Link: "Xem chi tiết"

4. **Payment Breakdown:**
   - Title: "Chi Tiết Thanh Toán"
   - Line 1: "Phí tư vấn (30 phút)" - "150,000 VNĐ"
   - Line 2: "Phí nền tảng (đã bao gồm)" - "0 VNĐ"
   - Divider line
   - Total: "Tổng Cộng" - "150,000 VNĐ" (bold, large, green)

5. **Payment Method Selection:**
   - Title: "Phương Thức Thanh Toán"
   - 4 radio button cards:
     - Momo
     - VNPay
     - ZaloPay
     - Thẻ tín dụng/ghi nợ
   - Selected method has green border

6. **Escrow Information:**
   - Yellow info box:
   - Icon: Shield/Lock
   - Text: "Tiền sẽ được giữ an toàn và chỉ chuyển cho chuyên gia sau khi hoàn thành tư vấn"

7. **Terms Checkbox:**
   - Checkbox: "Tôi đồng ý với Điều khoản dịch vụ và Chính sách hoàn tiền"

8. **Action Buttons:**
   - Primary button: "Xác Nhận & Thanh Toán"
   - Secondary link: "Hủy"

#### Stitch Prompt (English):

```
Mobile app payment confirmation screen for snake expert consultation in "SnakeAid". Transaction review interface with forest green (#228B22) theme.

Top navigation: Back arrow left, centered title "Xác Nhận & Thanh Toán".

Top section white card with consultation summary:
Left: Circular avatar (60px) of expert with small purple "Verified" badge overlay.
Right: Bold name "TS. Nguyễn Văn An", below purple chip "Tư vấn đặt lịch", below calendar icon + "Thứ Hai, 05/12 - 09:00" gray text, below clock icon + "30 phút" gray text.

Small card showing "Tài liệu đã tải lên" with image icon + "3 ảnh" and blue text link "Xem chi tiết" on right.

Section "Chi Tiết Thanh Toán" bold dark gray. White card with pricing breakdown:
- Line 1: "Phí tư vấn (30 phút)" left aligned gray, "150,000 VNĐ" right aligned dark gray
- Line 2: "Phí nền tảng (đã bao gồm)" left aligned gray, "0 VNĐ" right aligned gray
- Thin gray divider line
- Line 3: "Tổng Cộng" bold dark gray left, "150,000 VNĐ" bold large forest green right

Section "Phương Thức Thanh Toán". Four payment method cards vertically stacked, white background with gray border. Selected card has forest green border (2px):
- Card 1: Radio button left, Momo logo placeholder center, "Momo" text
- Card 2: Radio button left, VNPay logo placeholder, "VNPay" text
- Card 3: Radio button left, ZaloPay logo placeholder, "ZaloPay" text
- Card 4: Radio button left, Credit card icon, "Thẻ tín dụng/ghi nợ" text
First card (Momo) shows selected state with filled radio and green border.

Yellow-amber info box (#FFF3CD) with amber left border: Shield/lock icon left, text "Tiền sẽ được giữ an toàn và chỉ chuyển cho chuyên gia sau khi hoàn thành tư vấn" in dark gray.

Checkbox row: Empty checkbox left, small text "Tôi đồng ý với Điều khoản dịch vụ và Chính sách hoàn tiền" with underlined links in blue.

Bottom: Large solid forest green button "Xác Nhận & Thanh Toán" spanning full width. Below button, centered gray text link "Hủy".

Design: Trustworthy payment interface, clear pricing transparency, secure payment indication, terms agreement, multiple payment options.
```

#### Notes for Stitch:
- Payment breakdown phải rõ ràng với left-right alignment
- Escrow info box rất quan trọng để build trust
- Selected payment method phải highlight với green border
- Terms checkbox phải checked trước khi enable button

---

### Screen 7: Consultation Session Screen (Chat/Video)

#### Thông tin màn hình:
- **Tên:** Màn hình phiên tư vấn trực tuyến
- **Mục đích:** Giao diện chat hoặc video call với Expert
- **Flow position:** Giai đoạn 3.3 - Bước 2-4: Buổi tư vấn trực tuyến
- **Priority:** ⭐⭐⭐ (Cao nhất)

#### Key Components:

**For Chat Mode:**

1. **Header:**
   - Back button (minimize)
   - Expert avatar + name + online status
   - Icons: Video call button, More options (...)
   - Timer showing session duration

2. **Message Area (scrollable):**
   - Expert messages: Left-aligned, gray bubble
   - Patient messages: Right-aligned, green bubble
   - Timestamp below each message group
   - Image attachments displayed as thumbnails
   - System messages centered (e.g., "Phiên tư vấn đã bắt đầu")

3. **Input Area (bottom):**
   - Camera icon button (attach photo)
   - Text input field: "Nhập tin nhắn..."
   - Send button (green paper plane icon)

4. **Quick Actions (above keyboard):**
   - Horizontal chips:
     - "Đây là loài rắn gì?"
     - "Có nguy hiểm không?"
     - "Cách xử lý?"

**For Video Call Mode:**

1. **Full Screen Video:**
   - Expert's video (large)
   - Patient's video (small, corner, draggable)

2. **Overlay Controls:**
   - Top bar: Timer + Expert name
   - Bottom bar:
     - Mute microphone button
     - Turn off camera button
     - Switch to chat button
     - End call button (red)

3. **Chat Panel (slide-in):**
   - Can be opened during video call
   - Shows messages alongside video

#### Stitch Prompt (English) - Chat Mode:

```
Mobile app consultation chat screen for snake expert consultation in "SnakeAid". Chat messaging interface with forest green (#228B22) theme.

Top navigation bar (white background, bottom shadow):
Left: Back/minimize arrow.
Center: Small circular avatar (40px) of expert, name "TS. Nguyễn Văn An" bold dark gray, small green dot + "Đang hoạt động" below in tiny gray text.
Right: Video camera icon button and three-dot menu icon.
Far right corner: Timer badge showing "12:45" in forest green.

Main chat area (light gray background #F5F5F5): Scrollable message list.

Message bubbles:
- Expert messages: Left-aligned, medium gray background (#E0E0E0), dark gray text, rounded corners (16px), max width 75% screen. Timestamp "09:15" in tiny light gray below bubble.
- Patient messages: Right-aligned, forest green background (#228B22), white text, rounded corners (16px), max width 75% screen. Timestamp below.
- System message: Centered, small light gray pill "Phiên tư vấn đã bắt đầu - 09:00" with clock icon.

Image attachments shown as rounded square thumbnails (120px) within message bubbles.

Above input area: Horizontal scrollable row of quick action chips with white background, gray border: "Đây là loài rắn gì?", "Có nguy hiểm không?", "Cách xử lý?".

Bottom input area (white background, top shadow):
Left: Camera icon button (gray).
Center: Large text input field with light gray background, rounded (20px), placeholder "Nhập tin nhắn..." in light gray.
Right: Send button - circular forest green background, white paper plane icon (only active when text entered).

Design: Clean messaging interface, clear message authorship, intuitive input controls, quick response suggestions, professional consultation feel.
```

#### Stitch Prompt (English) - Video Call Mode:

```
Mobile app video call screen for snake expert consultation in "SnakeAid". Video consultation interface with forest green (#228B22) theme.

Full screen: Expert's video feed (fills entire screen). Video shows professional consultation environment.

Top-right corner: Small rectangular picture-in-picture window (100x150px, rounded 8px) showing patient's own video feed. Small drag handle indicator.

Top overlay bar (translucent dark background):
Left: Timer "12:45" in white.
Center: Expert name "TS. Nguyễn Văn An" in white with small green active dot.
Right: Minimize button (white).

Bottom overlay bar (translucent dark background, rounded top corners):
Four circular control buttons horizontally centered, equal spacing (60px diameter each):
- Button 1: Microphone icon (white), tap to mute, "Mic" label below
- Button 2: Video camera icon (white), tap to turn off, "Camera" label below
- Button 3: Chat bubble icon (white), tap to open chat panel, "Chat" label below
- Button 4: Phone hang-up icon (white on red background), "Kết thúc" label below

When chat panel opened: Slide-in panel from right (40% screen width), white background, shows chat messages with semi-transparent overlay on video.

Design: Immersive video call interface, minimal distractions, clear controls, professional consultation setting, accessible quick actions.
```

#### Notes for Stitch:
- Chat bubbles phải clear về sender (color coding)
- Video call controls phải accessible và large enough to tap easily
- Timer phải visible để user biết thời gian còn lại
- Quick action chips giúp user hỏi nhanh hơn

---

### Screen 8: Consultation Complete & Rating Screen

#### Thông tin màn hình:
- **Tên:** Màn hình hoàn thành tư vấn và đánh giá
- **Mục đích:** Xác nhận hoàn thành, xử lý thanh toán và cho phép đánh giá Expert
- **Flow position:** Giai đoạn 3.3 - Bước 6-8: Kết thúc và đánh giá
- **Priority:** ⭐⭐⭐

#### Key Components:
1. **Header:**
   - Close button (X)
   - Title: "Hoàn Thành Tư Vấn"

2. **Success Banner:**
   - Large checkmark icon (green)
   - Heading: "Cảm ơn bạn đã sử dụng dịch vụ!"
   - Subtitle: "Phiên tư vấn đã kết thúc"

3. **Session Summary Card:**
   - Expert info (avatar + name)
   - Date & Time completed
   - Duration: "32 phút"
   - Status badge: "Đã Hoàn Thành" (green)

4. **Payment Processed Section:**
   - Title: "Thanh Toán Đã Xử Lý"
   - Amount: "150,000 VNĐ"
   - Payment method: "Momo"
   - Status: "Đã thanh toán thành công"
   - Link: "Xem hóa đơn điện tử"

5. **Consultation Summary (if Expert provided):**
   - Title: "Tóm Tắt Tư Vấn"
   - Expert's summary notes (expandable text)
   - Recommendations list
   - Link: "Tải báo cáo PDF"

6. **Rating Section:**
   - Title: "Đánh Giá Chuyên Gia"
   - Large 5-star rating selector
   - Stars interactive and large (tap to rate)
   - Text below: "Chọn số sao"

7. **Review Text Area:**
   - Title: "Nhận Xét (Tùy chọn)"
   - Multiline text input
   - Placeholder: "Chia sẻ trải nghiệm của bạn..."
   - Character counter: "0/200"

8. **Quick Rating Tags (optional):**
   - Pre-written compliment chips:
     - "Rất chuyên nghiệp"
     - "Tư vấn chi tiết"
     - "Phản hồi nhanh"
     - "Dễ hiểu"
   - Tap to add to review

9. **Action Buttons:**
   - Primary button: "Gửi Đánh Giá"
   - Secondary link: "Bỏ qua"

10. **Bottom Actions:**
    - Button: "Xem Lịch Sử Tư Vấn"
    - Button: "Về Trang Chủ"

#### Stitch Prompt (English):

```
Mobile app consultation completion and rating screen for snake expert in "SnakeAid". Success confirmation and review interface with forest green (#228B22) theme.

Top navigation: X close button right, centered title "Hoàn Thành Tư Vấn".

Top section: Large green checkmark icon (80px) centered in light green circle background (#D4EDDA). Below icon, large bold heading "Cảm ơn bạn đã sử dụng dịch vụ!" in dark gray. Below that, medium gray text "Phiên tư vấn đã kết thúc".

White card showing session summary:
Left: Circular avatar (50px) of expert.
Right: Bold name "TS. Nguyễn Văn An", below calendar icon + "05/12/2025 - 09:00" gray, below clock icon + "32 phút" gray, below green badge "Đã Hoàn Thành".

Section "Thanh Toán Đã Xử Lý" bold dark gray. White card:
Line 1: "Số tiền" left gray, "150,000 VNĐ" right bold forest green.
Line 2: "Phương thức" left gray, "Momo" right with small Momo logo gray.
Line 3: Green checkmark icon + "Đã thanh toán thành công" green text.
Bottom: Blue text link "Xem hóa đơn điện tử".

Section "Tóm Tắt Tư Vấn" bold. White card with 3 lines of gray text summary and blue "Xem đầy đủ" link. Below card, outlined button "Tải báo cáo PDF" with download icon.

Section "Đánh Giá Chuyên Gia" bold dark gray. Row of 5 large star outlines (yellow/amber color #FFC107, 48px each) horizontally centered with spacing. When tapped, star fills with solid yellow. Small gray text below "Chọn số sao".

Section "Nhận Xét (Tùy chọn)". White card with multiline text input, light gray background, placeholder "Chia sẻ trải nghiệm của bạn..." Character counter "0/200" bottom right small gray.

Below text area, horizontal scrollable row of compliment chips: "Rất chuyên nghiệp", "Tư vấn chi tiết", "Phản hồi nhanh", "Dễ hiểu" - all light gray background with gray border, tap to select (green border when selected).

Bottom buttons:
- Large solid forest green button "Gửi Đánh Giá" spanning full width
- Below, centered gray text link "Bỏ qua"

Footer section: Two horizontally arranged outlined buttons:
- "Xem Lịch Sử Tư Vấn" left (50% width)
- "Về Trang Chủ" right (50% width)

Design: Completion celebration, payment transparency, easy rating interface, optional detailed feedback, clear next actions.
```

#### Notes for Stitch:
- Success state phải feel rewarding với green checkmark
- Stars phải large và easy to tap (minimum 44px touch target)
- Quick compliment chips giúp user rate nhanh hơn
- Payment status phải reassuring với green checkmark

---

## 📋 SUMMARY - SCREEN FLOW

### Luồng các màn hình theo thứ tự:

```
1. Trang Chủ
   → (Người dùng chọn "Tư Vấn Chuyên Gia")
   ↓
2. Màn Hình Danh Sách Chuyên Gia
   → (Xem danh sách, lọc, chọn một Expert)
   ↓
3. Màn Hình Chi Tiết Chuyên Gia
   → (Xem profile đầy đủ, chọn action button)
   ↓
4. Màn Hình Chọn Loại Tư Vấn
   ├─→ (Lựa chọn A: Tư vấn ngay)
   │   → Chuyển sang Screen 5
   │
   └─→ (Lựa chọn B: Đặt lịch)
       ↓
       4B. Màn Hình Chọn Lịch Hẹn
       → (Chọn ngày giờ từ lịch trống)
       ↓
5. Màn Hình Upload Tài Liệu
   → (Upload ảnh, mô tả vấn đề, câu hỏi)
   ↓
6. Màn Hình Xác Nhận Thanh Toán
   → (Xem tóm tắt, chọn phương thức, thanh toán)
   ↓
7. Màn Hình Phiên Tư Vấn (Chat hoặc Video)
   → (Trao đổi với Expert, nhận tư vấn)
   ↓
8. Màn Hình Hoàn Thành & Đánh Giá
   → (Đánh giá Expert, xem tóm tắt, kết thúc)
```

---

## 🎯 DESIGN PRINCIPLES FOR CONSULTATION FLOW

### 1. **Trust & Credibility:**
- Hiển thị verification badges, ratings, reviews để build trust
- Show Expert qualifications, experience, statistics
- Transparent pricing và payment security (escrow)

### 2. **Flexibility:**
- 2 options: Instant hoặc Scheduled consultation
- Multiple payment methods
- Chat or Video call modes

### 3. **Preparation:**
- Cho phép upload documents trước
- Quick action suggestions trong chat
- Pre-consultation information gathering

### 4. **Transparency:**
- Clear pricing breakdown
- Escrow payment explanation
- Session duration timer visible
- Payment status confirmation

### 5. **Feedback Loop:**
- Rating system sau consultation
- Optional detailed review
- Quick compliment tags
- Consultation summary from Expert

---

## 🔗 IMPLEMENTATION NOTES

### API Endpoints:
- `GET /api/experts` - Lấy danh sách chuyên gia (with filters)
- `GET /api/experts/:id` - Chi tiết chuyên gia
- `GET /api/experts/:id/availability` - Lịch trống của chuyên gia
- `POST /api/consultation/request` - Tạo yêu cầu tư vấn
- `POST /api/consultation/upload` - Upload documents
- `POST /api/payment/escrow` - Thanh toán escrow
- `POST /api/consultation/start` - Bắt đầu session
- `POST /api/consultation/message` - Gửi message
- `POST /api/consultation/complete` - Kết thúc session
- `POST /api/payment/release` - Giải ngân cho Expert
- `POST /api/rating/expert` - Đánh giá chuyên gia

### Real-time Features:
- WebSocket cho chat messages
- WebRTC cho video call
- Online status updates
- Session timer sync

### Payment Integration:
- Momo API
- VNPay API
- ZaloPay API
- Escrow system (hold funds until completion)

### Notifications:
- 30 phút trước lịch hẹn (scheduled consultation)
- Expert chấp nhận yêu cầu (instant consultation)
- Payment confirmation
- Session start reminder
- Session completion

---

## 📊 DOCUMENT STATUS

**Coverage:**
- ✅ Main Flow: 6 screens (List → Profile → Type → Upload → Payment → Session → Complete)
- ✅ Alternative Flow: 2 screens (Schedule selection, Video mode)
- ✅ Total: 8 screens designed

**Related Documents:**
- Referenced: `03-Swimlane-Expert-Consultation-Flow.md`
- Referenced: `Main-Flow.md` (Section 3)
- Referenced: `Major-Features-Summary.md` (FE-10, FE-27, etc.)
- Related UI Flow: `Patient-Emergency-Flow-Screens.md`
- Related UI Flow: `Patient-Rescue-Request-Flow-Screens.md`

**Next Steps:**
- Tạo Expert screens document (Expert perspective)
- Implement WebSocket/WebRTC cho real-time features
- Test payment escrow flow
- Design notification templates

---

**Ghi chú:** Tất cả các feature code (FE-XX) tham chiếu đến `Major-Features-Summary.md`

**Document Version:** 1.0
**Last Updated:** December 5, 2025
