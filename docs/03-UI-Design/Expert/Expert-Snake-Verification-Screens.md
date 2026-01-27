# EXPERT SNAKE VERIFICATION SCREENS - SNAKEAID PLATFORM

## Document Information
- **Module:** Snake Expert
- **Feature Category:** AI Verification & Quality Control
- **Total Screens:** 5 screens
- **Related Features:** FE-01 to FE-06 (Verify identification data, Support AI improvement)
- **Color Scheme:** Purple Primary `#6B46C1`, Amber `#FFC107` for pending items

---

## Flow Context

### AI Verification Workflow

**Purpose:**
- Verify AI snake identification results
- Correct misidentifications
- Add expert notes and insights
- Improve AI model accuracy through expert feedback
- Build trusted snake species database

**Verification Sources:**
1. Patient submitted snake photos (via emergency flow)
2. Rescuer field photos (during rescue operations)
3. Community snake sighting reports
4. Automated AI batch processing results

**Key Features (Reference: Major-Features-Summary.md):**
- FE-01: Confirm snake species from images/descriptions
- FE-02: Modify AI results if identification is incorrect
- FE-03: Add professional notes on identification characteristics
- FE-04: Use AI to shorten verification time
- FE-05: Review and approve AI results before publication
- FE-06: Train and improve AI model by confirming new data

---

## Design System

### Color Palette
```
Primary Purple:     #6B46C1  (Verified correct)
Warning Amber:      #FFC107  (Pending verification)
Success Green:      #28A745  (AI correct, approved)
Error Red:          #DC3545  (AI incorrect, needs correction)
Info Blue:          #007BFF  (Additional info needed)
Neutral Gray:       #6C757D  (Low priority)
```

### Verification Status Colors
```
Pending:            Amber background (#FFF3CD), amber badge
Reviewing:          Blue background (#E3F2FD), blue badge
Correct:            Green background (#D4EDDA), green badge
Incorrect:          Red background (#FFE5E5), red badge
Uncertain:          Gray background (#F5F5F5), gray badge
```

---

## Screen Designs

### Screen 1: Verification Queue (Pending Items)

**Screen Purpose:**  
List of all AI identification results waiting for expert verification, prioritized by urgency and confidence level.

**Navigation:**
- Entry: Tap "Xác Minh" from Dashboard or Notification Center
- Exit: Tap item → Screen 2 (Review Detail), Back → Dashboard

**Key Components:**

1. **Header Section:**
   - Back arrow + Title: "Xác Minh AI"
   - Filter icon → Open filter sheet
   - Stats badge: "23 đang chờ" (amber)

2. **Priority Tabs:**
   - "Tất Cả" (All - default)
   - "Khẩn Cấp" (Urgent - red badge with count)
   - "Độ Tin Cậy Thấp" (Low confidence - amber badge)
   - "Đã Xử Lý" (Completed - green)

3. **Filter Options** (Slide-up sheet):
   - Confidence level: <50%, 50-70%, 70-90%, >90%
   - Source: Patient, Rescuer, Community, System
   - Date range: Today, This week, This month
   - Snake type: Venomous, Non-venomous, Unknown

4. **Verification Cards List** (Scrollable):

   **High Priority Card** (Red accent):
   - Left: Red badge "KHẨN CẤP"
   - Snake thumbnail (100x100px, rounded)
   - AI Result: "Rắn Hổ Mang Chúa" (bold, 18pt)
   - Confidence: "42% độ tin cậy" (amber, with warning icon)
   - Source: "Từ Patient - Nguyễn Văn A"
   - Timestamp: "5 phút trước"
   - Location: "Quận 1, TP.HCM"
   - Right arrow icon

   **Normal Priority Card** (Amber accent):
   - Left: Amber badge "CHỜ XÁC MINH"
   - Snake thumbnail (100x100px)
   - AI Result: "Rắn Ráo Trâu" (bold, 18pt)
   - Confidence: "78% độ tin cậy" (amber)
   - Source: "Từ Rescuer - Đội SG"
   - Timestamp: "2 giờ trước"
   - Additional photos badge: "+3 ảnh"
   - Right arrow

   **Low Priority Card** (Gray accent):
   - Left: Gray badge "ÍT KHẨN"
   - Snake thumbnail
   - AI Result: "Rắn Lục Đuôi Đỏ" (bold)
   - Confidence: "85% độ tin cậy" (green)
   - Source: "Từ Cộng đồng"
   - Timestamp: "1 ngày trước"

5. **Quick Stats Bar** (Top, collapsible):
   - "Hôm nay: 12 mới"
   - "Độ chính xác AI: 87.3%" (trend arrow)
   - "Đã xử lý: 156/179"

6. **Empty State** (When queue is empty):
   - Icon: Green checkmark in circle (80px)
   - "Không Có Yêu Cầu Xác Minh"
   - "Bạn đã xử lý hết tất cả"
   - Button: "Xem Lịch Sử"

**Stitch Prompt (English):**

```
Verification queue screen for snake expert AI review.

HEADER:
- Back arrow, "Xác Minh AI" (24pt semi-bold purple), filter icon, badge "23 đang chờ" (amber)

TABS (horizontal scroll):
- "Tất Cả" (active, purple underline)
- "Khẩn Cấp" (red badge "5")
- "Độ Tin Cậy Thấp" (amber badge "8")
- "Đã Xử Lý" (gray)

QUICK STATS BAR (collapsible, light purple background):
- "Hôm nay: 12 mới" | "Độ chính xác AI: 87.3% ↑" | "Đã xử lý: 156/179"

VERIFICATION CARDS (scrollable list):

CARD 1 (HIGH PRIORITY - red accent border-left 6px):
- Top: "KHẨN CẤP" red badge + "5 phút trước" gray text
- Left: Snake thumbnail (100x100px, rounded 8px)
- Right content:
  * "Rắn Hổ Mang Chúa" (18pt bold)
  * "42% độ tin cậy" (amber text) + warning icon
  * "Từ Patient - Nguyễn Văn A" (14pt gray)
  * "Quận 1, TP.HCM" (12pt gray) + location icon
- Far right: Arrow icon

CARD 2 (NORMAL - amber accent border-left 4px):
- Top: "CHỜ XÁC MINH" amber badge + "2 giờ trước"
- Snake thumbnail (100x100px)
- "Rắn Ráo Trâu" (18pt bold)
- "78% độ tin cậy" (amber text)
- "Từ Rescuer - Đội SG" (14pt gray)
- "+3 ảnh" blue chip
- Arrow icon

CARD 3 (LOW PRIORITY - gray accent border-left 4px):
- Top: "ÍT KHẨN" gray badge + "1 ngày trước"
- Snake thumbnail
- "Rắn Lục Đuôi Đỏ" (18pt bold)
- "85% độ tin cậy" (green text)
- "Từ Cộng đồng"
- Arrow icon

DESIGN: Queue management interface, priority-based color coding, confidence level indicators, source attribution, efficient scanning.
```

---

### Screen 2: Review AI Result Detail

**Screen Purpose:**  
Detailed view of AI identification result with all evidence photos, metadata, and comparison tools for expert review.

**Navigation:**
- Entry: Tap card from Screen 1
- Exit: Accept → Screen 3 (Confirm), Correct → Screen 4 (Edit Result), Back → Screen 1

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Xác Minh Chi Tiết"
   - Status badge: "Đang Xem Xét" (blue)
   - Help icon (?)

2. **AI Prediction Card** (Top section):
   - Large confidence indicator:
     - Circular progress (42% in red, 78% in amber, 90%+ in green)
     - Center: "42%" large number
   - AI Result: "Rắn Hổ Mang Chúa" (24pt, bold)
   - Scientific name: "Ophiophagus hannah" (italic, gray)
   - Danger badge: "CỰC ĐỘC" (red background, white text)
   - Model version: "AI Model v3.2.1" (small, gray)

3. **Photo Evidence Gallery:**
   - "Ảnh Gửi Lên (4 ảnh)"
   - Main photo (full width, 300px height)
   - Zoom controls (pinch/double tap)
   - Thumbnail strip below (4 photos, scroll horizontal)
   - Photo metadata: Date, time, location, lighting conditions
   - Button: "So Sánh Với Database" → Opens comparison view

4. **AI Reasoning Section:**
   - "Phân Tích Của AI"
   - Key features detected:
     - ✓ "Đầu hình tam giác rộng" (90% confidence)
     - ✓ "Vảy vàng-đen xen kẽ" (85% confidence)
     - ✓ "Kích thước lớn (ước tính 3-4m)" (70% confidence)
     - ? "Môi trường sống phù hợp" (45% confidence - amber)
   - Alternative predictions:
     - 2nd: "Rắn Hổ Mang (Naja kaouthia)" - 28%
     - 3rd: "Rắn Hổ Mang Miệng Trắng" - 15%

5. **Submission Context:**
   - "Thông Tin Nguồn"
   - Source: "Patient - Nguyễn Văn A"
   - Submitted: "11/12/2025 - 14:30"
   - Location: "Quận 1, TP.HCM" + map thumbnail
   - Context: "Phát hiện trong vườn nhà, ban ngày"
   - Additional notes: "Rắn rất hung dữ, tấn công khi bị làm phiền"

6. **Similar Cases Section:**
   - "Ca Tương Tự Đã Xác Minh"
   - Show 3 similar verified cases
   - Each with: Photo thumbnail, Expert name, Verified species, Date
   - Helps Expert compare patterns

7. **Expert Decision Buttons:**
   - Primary: "✓ AI Đúng - Xác Nhận" (large, green, 56px)
   - Secondary: "✗ AI Sai - Chỉnh Sửa" (medium, red, 48px)
   - Tertiary: "? Cần Thêm Thông Tin" (outlined, blue, 48px)
   - Link: "Bỏ Qua" (gray text)

8. **Quick Actions:**
   - "Xem Hướng Dẫn Nhận Dạng Rắn Hổ Mang"
   - "Tra Cứu Database"
   - "Liên Hệ Chuyên Gia Khác"

**Stitch Prompt (English):**

```
AI result review detail screen for snake expert verification.

HEADER:
- Back arrow, "Xác Minh Chi Tiết" (24pt), "Đang Xem Xét" blue badge

AI PREDICTION CARD (white, rounded, shadow):
- Top: Circular confidence indicator (42%, red circle, 120px diameter)
- "Rắn Hổ Mang Chúa" (24pt bold purple)
- "Ophiophagus hannah" (16pt italic gray)
- "CỰC ĐỘC" red badge
- "AI Model v3.2.1" (12pt gray)

PHOTO GALLERY:
- "Ảnh Gửi Lên (4 ảnh)" header
- Large main photo (full-width, 300px height) with zoom controls
- Thumbnail strip (4 photos, 80px each, horizontal scroll)
- Metadata "11/12/2025 14:30 | Quận 1 | Ban ngày"
- Blue button "So Sánh Với Database"

AI REASONING:
- "Phân Tích Của AI" header
- Key features list:
  * ✓ "Đầu hình tam giác rộng" (90%, green check)
  * ✓ "Vảy vàng-đen xen kẽ" (85%, green check)
  * ✓ "Kích thước lớn (3-4m)" (70%, green check)
  * ? "Môi trường sống phù hợp" (45%, amber question)
- Alternative predictions:
  * "2. Rắn Hổ Mang (Naja kaouthia) - 28%"
  * "3. Rắn Hổ Mang Miệng Trắng - 15%"

SOURCE INFO CARD:
- "Thông Tin Nguồn" header
- "Patient - Nguyễn Văn A" with avatar
- "11/12/2025 - 14:30"
- "Quận 1, TP.HCM" + map thumbnail
- Quote: "Phát hiện trong vườn nhà, ban ngày"
- "Rắn rất hung dữ, tấn công khi bị làm phiền"

SIMILAR CASES:
- "Ca Tương Tự Đã Xác Minh" header
- 3 small cards (photo + "Expert A" + "Rắn Hổ Mang Chúa" + date)

DECISION BUTTONS:
- Large green "✓ AI Đúng - Xác Nhận" (56px height)
- Medium red "✗ AI Sai - Chỉnh Sửa" (48px height)
- Medium outlined blue "? Cần Thêm Thông Tin" (48px)
- Small gray link "Bỏ Qua"

QUICK ACTIONS (bottom links):
- "Xem Hướng Dẫn Nhận Dạng Rắn Hổ Mang" (blue)
- "Tra Cứu Database" (blue)

DESIGN: Comprehensive review interface, AI transparency, evidence-based decision making, comparison tools, confidence visualization.
```

---

### Screen 3: Confirm AI Result (Quick Approval)

**Screen Purpose:**  
Quick confirmation when Expert agrees with AI identification, with option to add notes.

**Navigation:**
- Entry: Tap "AI Đúng" from Screen 2
- Exit: Submit → Screen 5 (Verification Complete), Cancel → Screen 2

**Key Components:**

1. **Confirmation Header:**
   - Green checkmark icon (large, animated)
   - "Xác Nhận AI Chính Xác"

2. **Result Summary Card:**
   - Snake photo (200px square)
   - Confirmed species: "Rắn Hổ Mang Chúa"
   - Scientific name: "Ophiophagus hannah"
   - Original AI confidence: "42% → 100% (Chuyên gia xác nhận)"
   - Status changes to: "Đã Xác Minh" (green badge)

3. **Expert Confidence Rating:**
   - "Độ Chắc Chắn Của Bạn"
   - Radio buttons:
     - "Hoàn Toàn Chắc Chắn (100%)" (selected)
     - "Rất Chắc (90-99%)"
     - "Khá Chắc (80-89%)"
     - "Có Chút Nghi Ngờ (70-79%)"

4. **Optional Expert Notes:**
   - "Ghi Chú Chuyên Gia (Tùy Chọn)"
   - Text area: "Thêm nhận xét về đặc điểm nhận dạng..."
   - Character count: "0/500"
   - Voice input button
   - Template button: "Sử Dụng Mẫu"

5. **Common Templates** (Quick insert):
   - "Đặc điểm nhận dạng rõ ràng, AI phân tích chính xác"
   - "Ảnh chất lượng tốt, dễ xác định"
   - "Môi trường sống và hành vi phù hợp với loài này"

6. **Training Data Option:**
   - Checkbox: "✓ Sử Dụng ảnh này để huấn luyện AI"
   - Helper text: "Giúp cải thiện độ chính xác của AI"

7. **Impact Stats:**
   - "Xác Nhận Này Sẽ:"
   - ✓ Cập nhật kết quả cho người gửi
   - ✓ Cải thiện độ chính xác AI (+0.02%)
   - ✓ Thêm vào database tin cậy
   - ✓ Bạn nhận 50,000 VNĐ

8. **Action Buttons:**
   - Primary: "Xác Nhận & Gửi" (large, green, 56px)
   - Secondary: "Quay Lại" (outlined gray)

**Stitch Prompt (English):**

```
AI confirmation screen for snake expert quick approval.

HEADER:
- Large green checkmark icon (80px, animated)
- "Xác Nhận AI Chính Xác" (22pt bold green)

RESULT CARD:
- Snake photo (200px square, centered)
- "Rắn Hổ Mang Chúa" (20pt bold)
- "Ophiophagus hannah" (16pt italic gray)
- Confidence bar: "42% → 100%" (gradient red to green)
- "Đã Xác Minh" green badge

CONFIDENCE RATING:
- "Độ Chắc Chắn Của Bạn" header
- 4 radio buttons (large, 48px height):
  * ○ "Hoàn Toàn Chắc Chắn (100%)" (SELECTED, purple)
  * ○ "Rất Chắc (90-99%)"
  * ○ "Khá Chắc (80-89%)"
  * ○ "Có Chút Nghi Ngờ (70-79%)"

NOTES SECTION:
- "Ghi Chú Chuyên Gia (Tùy Chọn)" header
- Large text area (6 lines visible)
- Placeholder "Thêm nhận xét về đặc điểm nhận dạng..."
- Mic icon (voice input) + "Mẫu" button (templates)
- "0/500" character count (gray, bottom-right)

TEMPLATE CHIPS (horizontal scroll):
- "Đặc điểm nhận dạng rõ ràng..."
- "Ảnh chất lượng tốt..."
- "Môi trường sống phù hợp..."

TRAINING OPTION:
- Checkbox (checked) "Sử Dụng ảnh này để huấn luyện AI"
- "Giúp cải thiện độ chính xác của AI" (12pt gray)

IMPACT STATS (light green background):
- "Xác Nhận Này Sẽ:" bold
- ✓ "Cập nhật kết quả cho người gửi"
- ✓ "Cải thiện độ chính xác AI (+0.02%)"
- ✓ "Thêm vào database tin cậy"
- ✓ "Bạn nhận 50,000 VNĐ" (green text)

BUTTONS:
- Large green "Xác Nhận & Gửi" (56px, full-width)
- Medium outlined gray "Quay Lại"

DESIGN: Quick approval interface, confidence rating, optional notes, training contribution, impact transparency, reward display.
```

---

### Screen 4: Correct AI Result (Edit Identification)

**Screen Purpose:**  
Expert corrects misidentified species, provides accurate identification with reasoning.

**Navigation:**
- Entry: Tap "AI Sai" from Screen 2
- Exit: Submit → Screen 5 (Verification Complete), Cancel → Screen 2

**Key Components:**

1. **Header:**
   - Back arrow + Title: "Chỉnh Sửa Kết Quả"
   - Status: "AI Sai - Đang Sửa" (red badge)

2. **AI Result Comparison:**
   - "So Sánh Kết Quả"
   - Left column (Red background):
     - "AI Dự Đoán" header
     - Snake photo thumbnail
     - "Rắn Hổ Mang Chúa ✗" (strikethrough)
     - "42% độ tin cậy"
   - Right column (Green background):
     - "Chuyên Gia Xác Định" header
     - Same photo
     - Empty dropdown: "Chọn loài đúng..." (to be filled)

3. **Species Selection:**
   - "Chọn Loài Rắn Chính Xác"
   - Search field: "Tìm theo tên Việt hoặc Latin..."
   - Filter: "Rắn độc" / "Rắn không độc" / "Tất cả"
   - Dropdown list with snake species:
     - Each item: Photo thumbnail + Vietnamese name + Scientific name + Danger badge
     - Recently verified species at top
     - Alphabetical order
   - Selected: "Rắn Hổ Mang (Naja kaouthia)" (green checkmark)

4. **Correct Species Info Display:**
   - After selection, shows:
     - Large photo from database
     - Vietnamese name: "Rắn Hổ Mang"
     - Scientific name: "Naja kaouthia"
     - Danger: "CỰC ĐỘC" (red badge)
     - Quick facts: Distribution, habitat, size

5. **Reason for Correction (Required):**
   - "Lý Do Chỉnh Sửa *"
   - Text area (required field)
   - Placeholder: "Giải thích tại sao AI sai và đặc điểm nhận dạng đúng..."
   - Min characters: 50
   - Current: "0/1000"

6. **Identification Features Checklist:**
   - "Đặc Điểm Nhận Dạng"
   - Expert can select key features observed:
     - ☑ "Hình dạng đầu"
     - ☑ "Màu sắc vảy"
     - ☑ "Kích thước"
     - ☐ "Môi trường sống"
     - ☐ "Hành vi"

7. **Comparison Photos Option:**
   - "Thêm Ảnh So Sánh (Tùy Chọn)"
   - Upload button to add reference photos from database
   - Side-by-side comparison view

8. **Confidence Rating:**
   - "Độ Chắc Chắn Của Bạn *"
   - Slider: 70% - 100%
   - Current: 95% (Expert must be >70% to submit)

9. **Training Feedback:**
   - Checkbox: "Gửi phản hồi để cải thiện AI"
   - Auto-checked (helps AI learn from mistakes)

10. **Impact Warning:**
    - Yellow info box:
    - "⚠️ Chỉnh sửa này sẽ:"
    - • Thay đổi kết quả cho người gửi
    - • Đánh dấu dự đoán AI là sai
    - • Giúp huấn luyện lại model
    - • Bạn nhận 75,000 VNĐ (higher than simple confirmation)

11. **Action Buttons:**
    - Primary: "Xác Nhận Chỉnh Sửa" (large, red, 56px)
    - Secondary: "Xem Lại" (outlined purple)
    - Link: "Hủy" (gray)

**Stitch Prompt (English):**

```
AI result correction screen for snake expert.

HEADER:
- Back arrow, "Chỉnh Sửa Kết Quả" (24pt), "AI Sai - Đang Sửa" red badge

COMPARISON SECTION:
- "So Sánh Kết Quả" header
- Two columns:
  LEFT (light red background):
  * "AI Dự Đoán" label
  * Snake thumbnail (80px)
  * "Rắn Hổ Mang Chúa ✗" (strikethrough, red)
  * "42%" (red text)
  
  RIGHT (light green background):
  * "Chuyên Gia Xác Định" label
  * Same thumbnail
  * "Rắn Hổ Mang ✓" (green)
  * "95%" (green text)

SPECIES SELECTION:
- "Chọn Loài Rắn Chính Xác" header
- Search field "Tìm theo tên..."
- Filter chips: "Rắn độc" (selected) | "Không độc" | "Tất cả"
- Dropdown showing:
  * Item 1: Thumbnail + "Rắn Hổ Mang" + "Naja kaouthia" + "CỰC ĐỘC" badge (SELECTED, green check)
  * Item 2: Thumbnail + "Rắn Hổ Mang Chúa" + "Ophiophagus hannah"
  * Item 3: Similar layout

CORRECT SPECIES DISPLAY:
- Large database photo (200px)
- "Rắn Hổ Mang" (20pt bold)
- "Naja kaouthia" (16pt italic)
- "CỰC ĐỘC" red badge
- "Phân bố: Miền Nam | Môi trường: Ruộng lúa, vườn"

REASON FIELD (REQUIRED):
- "Lý Do Chỉnh Sửa *" header (red asterisk)
- Large text area (8 lines)
- Placeholder "Giải thích tại sao AI sai..."
- "Min 50 ký tự" gray helper
- "0/1000" counter

FEATURES CHECKLIST:
- "Đặc Điểm Nhận Dạng" header
- 5 checkboxes:
  * ✓ "Hình dạng đầu" (checked)
  * ✓ "Màu sắc vảy" (checked)
  * ✓ "Kích thước" (checked)
  * ☐ "Môi trường sống"
  * ☐ "Hành vi"

CONFIDENCE SLIDER:
- "Độ Chắc Chắn Của Bạn *" header
- Slider (70% to 100%, current: 95%)
- Display "95%" large purple number

TRAINING CHECKBOX:
- ✓ "Gửi phản hồi để cải thiện AI" (checked)

IMPACT WARNING (yellow background):
- Warning icon "⚠️ Chỉnh sửa này sẽ:"
- • "Thay đổi kết quả cho người gửi"
- • "Đánh dấu dự đoán AI là sai"
- • "Giúp huấn luyện lại model"
- • "Bạn nhận 75,000 VNĐ" (green bold)

BUTTONS:
- Large red "Xác Nhận Chỉnh Sửa" (56px, full-width)
- Medium outlined purple "Xem Lại"
- Small gray link "Hủy"

DESIGN: Clear before/after comparison, searchable species selection, required reasoning field, confidence rating, AI feedback integration.
```

---

### Screen 5: Verification Complete (Success Confirmation)

**Screen Purpose:**  
Confirmation that verification is complete, showing impact and reward information.

**Navigation:**
- Entry: Submit from Screen 3 or Screen 4
- Exit: Auto-redirect to Dashboard after 3s, or tap buttons

**Key Components:**

1. **Success Animation:**
   - Green checkmark with expanding circle (120px)
   - Confetti or particle effect

2. **Completion Message:**
   - "✓ Xác Minh Hoàn Tất!"
   - Subtext: "Cảm ơn bạn đã đóng góp vào hệ thống"

3. **Verification Summary Card:**
   - Case type:
     - If confirmed: "AI Dự Đoán Chính Xác" (green badge)
     - If corrected: "Đã Chỉnh Sửa Kết Quả AI" (red badge)
   - Snake species (final): "Rắn Hổ Mang"
   - Scientific name: "Naja kaouthia"
   - Your confidence: "95%"
   - Time taken: "3 phút 24 giây"

4. **Impact Metrics:**
   - "Ảnh Hưởng Của Bạn"
   - Stats with icons:
     - ✓ "Kết quả đã gửi cho người yêu cầu"
     - ✓ "Cải thiện độ chính xác AI: +0.03%"
     - ✓ "Đóng góp vào database: +1 ảnh"
     - ✓ "Tổng xác minh của bạn: 157 ca"

5. **Reward Card:**
   - "Phần Thưởng"
   - Amount: "+75,000 VNĐ" (large, green, bold)
   - Type: "Phí xác minh & chỉnh sửa"
   - Status: "Đang chờ" (amber) → "Sẽ được cộng vào ví sau 24h"
   - Total earnings today: "325,000 VNĐ (từ 5 xác minh)"

6. **Next Items Preview:**
   - "Tiếp Theo Trong Hàng Đợi"
   - Show 2 next pending verifications:
     - Thumbnail + Species name + Confidence %
     - Tap to navigate directly

7. **Action Buttons:**
   - Primary: "Xác Minh Tiếp" (purple, 56px) → Back to Screen 1
   - Secondary: "Xem Báo Cáo" (outlined purple) → View detailed report
   - Link: "Về Trang Chủ" (gray)

8. **Auto-redirect:**
   - "Tự động về trang chủ sau 5s..." (small, gray, bottom)

**Stitch Prompt (English):**

```
Verification completion screen for snake expert.

SUCCESS ANIMATION:
- Large green checkmark (120px, animated)
- Confetti/sparkle effect

MESSAGE:
- "✓ Xác Minh Hoàn Tất!" (26pt bold green)
- "Cảm ơn bạn đã đóng góp vào hệ thống" (16pt gray)

SUMMARY CARD (white, rounded):
- "Đã Chỉnh Sửa Kết Quả AI" red badge
- Snake photo (150px square)
- "Rắn Hổ Mang" (20pt bold)
- "Naja kaouthia" (16pt italic gray)
- "Độ chắc chắn: 95%" (purple text)
- "Thời gian: 3 phút 24 giây" (gray)

IMPACT METRICS:
- "Ảnh Hưởng Của Bạn" header
- 4 rows with green checkmarks:
  * "Kết quả đã gửi cho người yêu cầu"
  * "Cải thiện độ chính xác AI: +0.03%"
  * "Đóng góp vào database: +1 ảnh"
  * "Tổng xác minh của bạn: 157 ca"

REWARD CARD (light green background):
- "Phần Thưởng" header
- "+75,000 VNĐ" (32pt bold green)
- "Phí xác minh & chỉnh sửa" (14pt gray)
- "Đang chờ" amber badge
- "Sẽ được cộng vào ví sau 24h" (12pt gray)
- Divider
- "Tổng hôm nay: 325,000 VNĐ (từ 5 xác minh)"

NEXT ITEMS:
- "Tiếp Theo Trong Hàng Đợi" header
- 2 preview cards (horizontal):
  * Thumbnail + "Rắn Ráo Trâu" + "78%" + arrow
  * Thumbnail + "Rắn Lục" + "85%" + arrow

BUTTONS:
- Large purple "Xác Minh Tiếp" (56px, full-width)
- Medium outlined purple "Xem Báo Cáo"
- Small gray link "Về Trang Chủ"

COUNTDOWN:
- "Tự động về trang chủ sau 5s..." (bottom, 12pt gray)

DESIGN: Celebratory completion, clear impact metrics, reward transparency, smooth continuation flow, achievement recognition.
```

---

## Integration Points

### API Endpoints:
- `GET /expert/verification/queue` - Get pending verifications
- `GET /expert/verification/{id}/detail` - Get detailed case
- `POST /expert/verification/{id}/confirm` - Confirm AI is correct
- `POST /expert/verification/{id}/correct` - Submit correction
- `POST /expert/verification/{id}/request-info` - Request more info
- `GET /expert/snake-database/search` - Search species for correction
- `GET /expert/verification/stats` - Get expert's verification stats
- `POST /expert/verification/training-feedback` - Submit AI training data

### Real-time Features:
- Live queue updates when new verifications arrive
- Priority notifications for urgent cases
- AI accuracy metrics update in real-time
- Reward balance updates

### Data Flow:
```
AI Identifies Snake (42% confidence)
    ↓
Enters Verification Queue
    ↓
Expert Reviews (Screen 2)
    ↓
Decision:
    [Correct] → Confirm (Screen 3) → Complete (Screen 5)
    [Incorrect] → Edit (Screen 4) → Complete (Screen 5)
    [Uncertain] → Request More Info → Back to Queue
    ↓
Update AI Model Training Data
    ↓
Notify Original Submitter
    ↓
Update Database & Stats
```

### Payment Structure:
- Simple confirmation (AI correct): 50,000 VNĐ
- Correction (AI incorrect): 75,000 VNĐ
- Complex correction with notes: 100,000 VNĐ
- Priority/urgent verification: +25,000 VNĐ bonus

---

## Version History
- **v1.0** - December 11, 2025: Initial verification screens design (5 screens)

---

## Design Review Checklist
- [x] Queue management with priority system
- [x] AI transparency (confidence, reasoning shown)
- [x] Expert confidence rating required
- [x] Clear before/after comparison for corrections
- [x] Required reasoning field for corrections
- [x] Training data contribution option
- [x] Impact metrics displayed
- [x] Reward structure transparent
- [x] Smooth workflow from queue to completion
- [x] Purple color scheme consistent

---

*This document is part of the SnakeAid Platform UI Design Documentation*  
*Related Documents: Expert-Dashboard-Screens.md, Expert-Consultation-Flow-Screens.md*
