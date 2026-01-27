# 🚨 Emergency SOS Flow - Member Screens

## 📱 Screen Descriptions

### 1. **emergency_alert_screen.dart**
Màn hình SOS được kích hoạt - hiển thị trạng thái cảnh báo khẩn cấp, xác định vị trí, tìm cứu hộ và thông báo liên hệ khẩn cấp.

### 2. **snake_identification_screen.dart**
Màn hình nhận dạng rắn qua camera - live camera preview để chụp ảnh rắn, có option upload từ gallery hoặc báo không có ảnh.

### 3. **snake_identification_result_screen.dart**
Màn hình kết quả nhận dạng AI - hiển thị loài rắn được xác định với % confidence, thông tin độc/không độc, và các đặc điểm nhận dạng.

### 4. **snake_selection_by_location_screen.dart**
Màn hình chọn rắn theo vị trí - hiển thị 4 loài rắn phổ biến ở khu vực người dùng khi không có ảnh hoặc AI không nhận dạng được.

### 5. **snake_identification_questions_screen.dart**
Màn hình bộ câu hỏi nhận dạng - 4 câu hỏi tuần tự với progress bar để filter rắn: hình dạng đầu, hoa văn, kích thước, môi trường.

### 6. **snake_filtered_results_screen.dart**
Màn hình kết quả lọc theo câu hỏi - hiển thị danh sách rắn được lọc dựa trên câu trả lời của người dùng.

### 7. **snake_confirmation_screen.dart**
Màn hình xác nhận loài rắn - người dùng xác nhận/từ chối loài rắn đã chọn, có interactive feature selection để tăng/giảm confidence level.

### 8. **generic_first_aid_screen.dart**
Màn hình sơ cứu chung - hướng dẫn 6 bước sơ cứu an toàn khi KHÔNG xác định được loài rắn, áp dụng cho cả Neurotoxic và Hemotoxic venom.

### 9. **first_aid_steps_screen.dart**
Màn hình sơ cứu theo loài - hướng dẫn chi tiết các bước sơ cứu cụ thể dựa trên loại nọc độc của rắn đã xác định (Neurotoxic/Hemotoxic).

### 10. **symptom_report_screen.dart**
Màn hình báo cáo triệu chứng - người dùng chọn các triệu chứng đang gặp phải (đau, sưng, khó thở, buồn nôn, v.v.) để cứu hộ viên đánh giá mức độ nghiêm trọng.

### 11. **severity_assessment_screen.dart**
Màn hình đánh giá mức độ nghiêm trọng - hiển thị kết quả đánh giá (Khẩn cấp/Trung bình/Nhẹ) dựa trên triệu chứng đã báo cáo.

### 12. **emergency_tracking_screen.dart**
Màn hình theo dõi cứu hộ - real-time tracking vị trí cứu hộ viên trên map, chat với cứu hộ viên, countdown timer, và status updates.

### 13. **rescuer_arrived_screen.dart**
Màn hình cứu hộ viên đã đến - xác nhận cứu hộ viên đã tới hiện trường, hiển thị thông tin cứu hộ viên và bắt đầu quá trình sơ cứu/di chuyển.

### 14. **payment_success_screen.dart**
Màn hình thanh toán thành công - xác nhận thanh toán dịch vụ cứu hộ, hiển thị hóa đơn chi tiết và tổng số tiền.

### 15. **emergency_service_completion_screen.dart**
Màn hình hoàn thành dịch vụ - tổng kết toàn bộ quá trình cứu hộ, đánh giá dịch vụ, và các thông tin liên hệ hỗ trợ sau cứu hộ.

---

## 🔄 Complete SOS Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        HOME SCREEN (Button: SOS)                             │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. EMERGENCY ALERT SCREEN                                                  │
│     - Kích hoạt SOS                                                         │
│     - Xác định vị trí GPS                                                   │
│     - Tìm cứu hộ gần nhất                                                   │
│     - Thông báo liên hệ khẩn cấp                                            │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  2. SNAKE IDENTIFICATION SCREEN (Live Camera)                               │
│     - Chụp ảnh rắn với camera preview                                       │
│     - Upload từ gallery                                                     │
│     - Option: "Không có ảnh"                                                │
└──────────┬──────────────────────────┬───────────────────────┬───────────────┘
           ↓                          ↓                       ↓
    ┌─────────────┐         ┌─────────────────┐    ┌───────────────────────┐
    │ Chụp/Upload │         │  Không có ảnh   │    │   AI Processing...    │
    └──────┬──────┘         └────────┬────────┘    └──────────┬────────────┘
           ↓                         ↓                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  3A. SNAKE IDENTIFICATION RESULT SCREEN (AI Result)                         │
│      - Hiển thị loài rắn AI nhận dạng                                       │
│      - Confidence level %                                                   │
│      - Thông tin độc/không độc                                              │
│      Options:                                                               │
│      • "Đúng rồi" → Confirmation Screen                                     │
│      • "Không đúng" → Selection by Location                                 │
└─────────────────────────────────────────────────────────────────────────────┘
           ↓ (Không đúng)            ↓ (Không có ảnh)
┌─────────────────────────────────────────────────────────────────────────────┐
│  3B. SNAKE SELECTION BY LOCATION SCREEN                                     │
│      - 4 loài rắn phổ biến ở khu vực                                        │
│      - Grid cards với hình ảnh, đặc điểm                                    │
│      Footer options:                                                        │
│      • "Không thấy trong danh sách" → Questions Screen                      │
│      • "Bỏ qua nhận định" → Generic First Aid                               │
│      • "Chọn loài này" → Confirmation Screen                                │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓ (Không thấy)
┌─────────────────────────────────────────────────────────────────────────────┐
│  3C. SNAKE IDENTIFICATION QUESTIONS SCREEN                                  │
│      - 4 câu hỏi tuần tự (1/4 → 2/4 → 3/4 → 4/4)                           │
│      - Progress bar 25% → 50% → 75% → 100%                                 │
│      Questions:                                                             │
│      1. Hình dạng đầu? (Tròn/Tam giác)                                      │
│      2. Hoa văn? (Có vân/Đơn sắc)                                           │
│      3. Kích thước? (Nhỏ/Trung/Lớn)                                         │
│      4. Môi trường? (Nước/Cây/Đất)                                          │
│      Buttons: "Tiếp theo", "Không chắc/Bỏ qua"                              │
└─────────────────────────────────────┬───────────────────────────────────────┘
                                      ↓ (Hoàn thành 4 câu hỏi)
┌─────────────────────────────────────────────────────────────────────────────┐
│  3D. SNAKE FILTERED RESULTS SCREEN                                          │
│      - Danh sách rắn filtered theo câu trả lời                              │
│      - Info banner: "Dựa trên câu trả lời của bạn..."                       │
│      - Grid 4 loài rắn phù hợp                                              │
│      Footer:                                                                │
│      • "Vẫn không tìm thấy" → Generic First Aid                             │
│      • "Chọn loài này" → Confirmation Screen                                │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓ (Chọn 1 loài hoặc từ Result Screen)
┌─────────────────────────────────────────────────────────────────────────────┐
│  4. SNAKE CONFIRMATION SCREEN                                               │
│     - Xác nhận loài rắn đã chọn                                             │
│     - Hình ảnh rắn (BoxFit.contain)                                         │
│     - Interactive features (tap to toggle)                                  │
│     - Dynamic confidence level (Cao/Trung/Thấp)                             │
│     - Poison badge                                                          │
│     Buttons:                                                                │
│     • "Xác nhận - Đây là con rắn tôi gặp" → POPUP → First Aid Steps        │
│     • "Không chắc - Chọn loài khác" → Back                                  │
│     • "Không giống - Trả lời câu hỏi" → Questions Screen                    │
│                                                                             │
│     [POPUP Xác nhận]                                                        │
│     - Icon warning (cam)                                                    │
│     - "Bắt đầu sơ cứu khẩn cấp?"                                            │
│     - Info box: Cảnh báo rắn độc/không độc                                  │
│     - "Quay lại" / "Bắt đầu sơ cứu →"                                       │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓ (Bắt đầu sơ cứu)
         ┌────────────────────────┴────────────────────────┐
         ↓ (Biết loài rắn)                   ↓ (Không biết loài)
┌─────────────────────────────────────────────────────────────────────────────┐
│  5A. FIRST AID STEPS SCREEN (Specific)                                      │
│      - Hướng dẫn theo loại nọc độc                                          │
│      - PageView với timer countdown                                         │
│      - Steps: Băng ép, Bất động, v.v.                                       │
│      - "Tiếp tục báo cáo triệu chứng"                                       │
└─────────────────────────────────────────────────────────────────────────────┘
         ↓                                   ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  5B. GENERIC FIRST AID SCREEN (Unknown)                                     │
│      - Badge: "Chưa xác định loài"                                          │
│      - Warning banner (vàng)                                                │
│      - Important alert (đỏ): NGUY HIỂM                                      │
│      - 6 bước sơ cứu AN TOÀN chung                                          │
│      - "Tuyệt đối không làm" (4 cards)                                      │
│      Footer:                                                                │
│      • "Tiếp tục báo cáo triệu chứng"                                       │
│      • "Gọi 115" / "Tìm bệnh viện"                                          │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  6. SYMPTOM REPORT SCREEN                                                   │
│     - Chọn triệu chứng hiện tại                                             │
│     - Multi-select checkboxes                                               │
│     Categories: Đau, Sưng, Hô hấp, Tiêu hóa, Thần kinh, v.v.               │
│     - "Gửi báo cáo triệu chứng"                                             │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  7. SEVERITY ASSESSMENT SCREEN                                              │
│     - Đánh giá mức độ: Khẩn cấp/Trung bình/Nhẹ                              │
│     - Color-coded severity indicator                                        │
│     - Hướng dẫn cụ thể theo mức độ                                          │
│     - "Tiếp tục theo dõi cứu hộ"                                            │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  8. EMERGENCY TRACKING SCREEN                                               │
│     - Real-time map với vị trí cứu hộ viên                                  │
│     - Countdown timer đến nơi                                               │
│     - Chat với cứu hộ viên                                                  │
│     - Status timeline                                                       │
│     - Update triệu chứng realtime                                           │
│     - "Cứu hộ viên đã đến"                                                  │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  9. RESCUER ARRIVED SCREEN                                                  │
│     - Xác nhận cứu hộ viên tại hiện trường                                  │
│     - Thông tin cứu hộ viên (avatar, tên, rating)                           │
│     - Số điện thoại liên hệ                                                 │
│     - "Bắt đầu sơ cứu/Di chuyển"                                            │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
                    [Quá trình sơ cứu & di chuyển]
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  10. PAYMENT SUCCESS SCREEN                                                 │
│      - Thanh toán dịch vụ cứu hộ                                            │
│      - Hóa đơn chi tiết                                                     │
│      - Tổng tiền                                                            │
│      - "Tiếp tục"                                                           │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│  11. EMERGENCY SERVICE COMPLETION SCREEN                                    │
│      - Tổng kết dịch vụ cứu hộ                                              │
│      - Rating & đánh giá cứu hộ viên                                        │
│      - Thông tin liên hệ hỗ trợ                                             │
│      - "Về trang chủ"                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features by Screen

### 🔴 Critical Path (Main Flow)
1. **SOS Alert** → 2. **Camera/ID** → 4. **Confirm** → 5. **First Aid** → 6. **Symptoms** → 7. **Assessment** → 8. **Tracking** → 9. **Arrived** → 10. **Payment** → 11. **Complete**

### 🟡 Alternative Paths

**Path A: Không có ảnh**
- 2 → 3B (Location) → 4 (Confirm) → 5 (First Aid)

**Path B: AI sai / Không tìm thấy**
- 3A (Result) → 3B (Location) → 3C (Questions) → 3D (Filtered) → 4 (Confirm)

**Path C: Bỏ qua nhận dạng**
- 3B → 5B (Generic First Aid) → 6 (Symptoms)

**Path D: Không chắc loài rắn**
- 3D (Filtered) → 5B (Generic First Aid) → 6 (Symptoms)

---

## 📊 Navigation Decision Tree

```
Camera Screen
├─ Chụp ảnh → AI Result
│  ├─ Đúng → Confirmation
│  └─ Không đúng → Location Selection
├─ Upload → AI Result
│  ├─ Đúng → Confirmation
│  └─ Không đúng → Location Selection
└─ Không có ảnh → Location Selection
   ├─ Chọn 1 trong 4 → Confirmation
   ├─ Không thấy → Questions (4 steps)
   │  └─ Hoàn thành → Filtered Results
   │     ├─ Chọn → Confirmation
   │     └─ Vẫn không thấy → Generic First Aid
   └─ Bỏ qua → Generic First Aid

Confirmation Screen
├─ Xác nhận → [POPUP] → First Aid Steps (Specific)
├─ Không chắc → Back to previous
└─ Không giống → Questions Screen

First Aid (Specific/Generic)
└─ Tiếp tục → Symptom Report

Symptom Report
└─ Gửi → Severity Assessment

Severity Assessment
└─ Tiếp tục → Emergency Tracking

Emergency Tracking
└─ Đã đến → Rescuer Arrived

Rescuer Arrived
└─ Bắt đầu → [Process] → Payment Success

Payment Success
└─ Tiếp tục → Service Completion

Service Completion
└─ Về trang chủ → HOME
```

---

## 🎨 Design System

### Colors
- **Primary Green**: `#228B22` - Main actions, success states
- **Warning Orange**: `#FF9800` - Medium severity, cautions
- **Danger Red**: `#DC3545` - Poisonous snakes, critical alerts
- **Info Blue**: `#1976D2` - Information banners
- **Background**: `#F8F8F6` - App background
- **Card White**: `#FFFFFF` - Content cards

### Typography
- **Headings**: 16-28px, Bold (w700-w800)
- **Body**: 12-16px, Regular/Medium (w400-w600)
- **Captions**: 10-12px, Medium (w500-w600)

### Components
- **Cards**: White bg, rounded 12-16px, subtle shadow
- **Buttons**: 
  - Primary: Green, rounded 12px, bold text
  - Outlined: Gray/Green border, transparent bg
- **Badges**: Rounded pill, colored bg + border
- **Dialogs**: CustomDialog widget with icon circle

---

## 🔧 Technical Notes

### State Management
- StatefulWidget for interactive screens (Confirmation, Questions)
- StatelessWidget for display-only screens

### Navigation
- `Navigator.push()` - Forward navigation
- `Navigator.pushReplacement()` - Replace current screen
- `Navigator.pop()` - Go back

### Key Widgets
- **Camera**: `CameraController` for live preview
- **Maps**: Google Maps for tracking
- **Chat**: Real-time messaging in tracking
- **Forms**: Checkbox groups for symptoms
- **Progress**: Linear indicators for multi-step flows

### Data Flow
```
User Input → Local State → Navigation with Data → Next Screen
           ↓
    (Future: API calls to backend)
```

---

## 📝 Notes for Developers

1. **Camera permissions** cần được request trước khi vào Identification Screen
2. **Location permissions** cần cho Emergency Alert và Tracking
3. **CustomDialog** widget được reuse cho tất cả popups
4. **IdentificationFeature** model được dùng cho feature selection
5. Tất cả screens follow **SnakeAid design system** (green primary, consistent spacing)

---

## 🚀 Future Enhancements

- [ ] Backend API integration cho AI recognition
- [ ] Real-time database cho symptom updates
- [ ] Push notifications cho rescuer status
- [ ] Offline mode với cached data
- [ ] Multi-language support (EN/VI)
- [ ] Voice commands trong emergency
- [ ] AR overlay cho snake identification

---

**Last Updated**: January 28, 2026  
**Version**: 1.0.0  
**Team**: SnakeAid Development Team


