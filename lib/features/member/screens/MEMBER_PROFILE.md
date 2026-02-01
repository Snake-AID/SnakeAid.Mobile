# 👤 Member Profile & Settings - Member Screens

## 📱 Screen Descriptions

### 1. **profile_screen.dart**
Màn hình profile chính của member - hiển thị avatar, tên, số điện thoại, số dư ví, menu settings với các options: Chỉnh sửa hồ sơ, Lịch sử cứu hộ, Ví tiền, Hồ sơ sức khỏe, Liên hệ khẩn cấp, Tin nhắn, và Cài đặt.

### 2. **edit_profile_screen.dart**
Màn hình chỉnh sửa thông tin cá nhân - form cho phép cập nhật avatar, tên, email, số điện thoại, ngày sinh, giới tính, địa chỉ, nhóm máu, và allergies. Có validation cho từng field.

### 3. **messages_screen.dart**
Màn hình danh sách tin nhắn - hiển thị conversations với experts, rescuers, và support. Tab filter (Tất cả/Chuyên gia/Cứu hộ), search bar, thread list với avatar, tên, last message preview, timestamp, unread badge.

### 4. **message_detail_screen.dart**
Màn hình chi tiết cuộc trò chuyện - chat interface với message bubbles, avatar cho receiver, timestamp, typing indicator, attachment options (photo/camera/document), và action bar với call/more options.

### 5. **health_history_screen.dart**
Màn hình lịch sử sức khỏe - timeline hiển thị các ca cấp cứu rắn cắn đã xử lý, filter theo thời gian (Tất cả/Tháng này/3 tháng/6 tháng), và summary cards với date, snake type, severity, hospital.

### 6. **health_history_detail_screen.dart**
Màn hình chi tiết ca cấp cứu - thông tin đầy đủ về 1 incident: timeline events, snake info, symptoms, first aid steps taken, hospital treatment, medications, rescuer info, và photos evidence.

### 7. **medical_records_screen.dart**
Màn hình hồ sơ y tế - danh sách các file y tế đã upload (PDF, images, lab results), filter theo loại (Tất cả/Đơn thuốc/Kết quả xét nghiệm/Hình ảnh), options upload mới, xem/download/share file.

### 8. **emergency_contacts_screen.dart**
Màn hình danh bạ khẩn cấp - quản lý danh sách người liên hệ khi SOS (Họ tên, Quan hệ, Số điện thoại), nút thêm/sửa/xóa contact, và toggle "Tự động thông báo khi SOS".

### 9. **id_documents_screen.dart**
Màn hình giấy tờ tùy thân - upload và quản lý CMND/CCCD, passport, bảo hiểm y tế. Hiển thị preview ảnh, status verification (Đã xác minh/Chờ xác minh/Bị từ chối), và nút upload/re-upload.

### 10. **hospital_finder_screen.dart**
Màn hình tìm bệnh viện - map view với hospital markers, search bar, filter (24/7, Có huyết thanh, Khoa cấp cứu), danh sách hospitals với khoảng cách, rating, facilities, nút "Chỉ đường" và "Gọi điện".

### 11. **deposit_money_screen.dart**
Màn hình nạp tiền vào ví - form nhập số tiền, chọn phương thức (Bank transfer/Credit card/E-wallet), hiển thị số dư hiện tại, quick amount buttons (100K, 200K, 500K, 1M), và nút "Nạp tiền".

### 12. **withdraw_money_screen.dart**
Màn hình rút tiền từ ví - form nhập số tiền muốn rút, chọn tài khoản ngân hàng (đã lưu hoặc thêm mới), hiển thị số dư khả dụng, phí rút tiền, và nút "Rút tiền".

### 13. **payment_history_screen.dart**
Màn hình lịch sử giao dịch - danh sách transactions (Nạp tiền/Rút tiền/Thanh toán cứu hộ), filter theo loại và thời gian, summary cards với amount, date, status, transaction ID, và nút "Xuất báo cáo".

### 14. **settings_screen.dart**
Màn hình cài đặt - grouped sections: Tài khoản (đổi mật khẩu, xóa tài khoản), Thông báo (push/email/SMS toggles), Bảo mật (2FA, face ID), Ngôn ngữ, Về ứng dụng (version, điều khoản, chính sách), và nút "Đăng xuất".

---

## 🔄 Complete Profile & Settings Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROFILE SCREEN (Main Hub)                                 │
│                    - Avatar + Name + Phone                                   │
│                    - Wallet balance: 1,250,000 VNĐ                          │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    ↓                                 ↓
         ┌──────────────────┐              ┌──────────────────┐
         │ Personal Info    │              │   Wallet         │
         └────────┬─────────┘              └────────┬─────────┘
                  │                                 │
    ┌─────────────┼─────────────┐        ┌─────────┼─────────┐
    ↓             ↓             ↓        ↓         ↓         ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────┐ ┌──────┐ ┌──────┐
│  Edit   │  │   ID    │  │Emergency│  │Deposit│ │Withdraw│ │History│
│ Profile │  │ Docs    │  │Contacts │  │      │ │       │ │      │
└─────────┘  └─────────┘  └─────────┘  └──────┘ └──────┘ └──────┘

                    ↓                                 ↓
         ┌──────────────────┐              ┌──────────────────┐
         │ Health & Medical │              │ Communication    │
         └────────┬─────────┘              └────────┬─────────┘
                  │                                 │
    ┌─────────────┼─────────────┐        ┌─────────┼─────────┐
    ↓             ↓             ↓        ↓         ↓         ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────┐ ┌──────┐ ┌──────┐
│ Health  │  │ Medical │  │Hospital │  │Messages│ │ Chat │ │      │
│ History │  │ Records │  │ Finder  │  │       │ │      │ │      │
└─────────┘  └─────────┘  └─────────┘  └──────┘ └──────┘ └──────┘

                    ↓
         ┌──────────────────┐
         │    Settings      │
         └──────────────────┘
```

---

## 📊 Detailed Screen Flows

### 🎨 Profile Management Flow

```
PROFILE SCREEN
├─ Avatar section
│  - Tap avatar → Photo picker → Update
│  - Display: Name, Phone, Verified badge
│
├─ Wallet Card
│  - Balance: 1,250,000 VNĐ
│  - Quick actions: Nạp tiền | Rút tiền | Lịch sử
│  └─ "Nạp tiền" → DEPOSIT SCREEN
│     ├─ Enter amount (100K/200K/500K/1M)
│     ├─ Select method:
│     │  • Chuyển khoản ngân hàng
│     │  • Thẻ tín dụng/ghi nợ
│     │  • Ví điện tử (Momo/ZaloPay)
│     ├─ View current balance
│     └─ "Nạp tiền" → Payment processing → Success
│  └─ "Rút tiền" → WITHDRAW SCREEN
│     ├─ Enter amount to withdraw
│     ├─ Select bank account (saved or new)
│     ├─ View available balance
│     ├─ View withdrawal fee
│     └─ "Rút tiền" → [Confirm Dialog] → Processing
│  └─ "Lịch sử" → PAYMENT HISTORY SCREEN
│     ├─ Filter tabs: Tất cả | Nạp | Rút | Thanh toán
│     ├─ Date filter: Tháng này | 3 tháng | 6 tháng | Tùy chỉnh
│     ├─ Transaction cards:
│     │  - Amount (green +, red -)
│     │  - Type + Date
│     │  - Status (Thành công/Đang xử lý/Thất bại)
│     │  - Transaction ID
│     └─ "Xuất báo cáo" → Export PDF/Excel
│
├─ Menu Section: Personal
│  └─ "Chỉnh sửa hồ sơ" → EDIT PROFILE SCREEN
│     ├─ Avatar picker (camera/gallery)
│     ├─ Form fields:
│     │  • Họ và tên (required)
│     │  • Email (validation)
│     │  • Số điện thoại (read-only)
│     │  • Ngày sinh (date picker)
│     │  • Giới tính (radio: Nam/Nữ/Khác)
│     │  • Địa chỉ (textarea)
│     │  • Nhóm máu (dropdown: A/B/AB/O +/-)
│     │  • Dị ứng (multi-line)
│     ├─ Validation errors inline
│     └─ "Lưu thay đổi" → [Confirm] → Update success
│
│  └─ "Giấy tờ tùy thân" → ID DOCUMENTS SCREEN
│     ├─ Document cards:
│     │  1. CMND/CCCD
│     │     - Front image preview
│     │     - Back image preview
│     │     - Status: Đã xác minh ✓ (green)
│     │     - Number: 079***678
│     │     - Actions: Xem | Cập nhật
│     │  2. Passport
│     │     - Image preview
│     │     - Status: Chờ xác minh ⏳ (yellow)
│     │     - Number: C12***456
│     │  3. Bảo hiểm y tế
│     │     - Card preview
│     │     - Status: Bị từ chối ✗ (red)
│     │     - Reason: "Ảnh không rõ ràng"
│     │     - Action: Tải lên lại
│     ├─ Upload new document:
│     │  - Camera option
│     │  - Gallery option
│     │  - Auto crop & enhance
│     └─ Verification info banner
│
│  └─ "Liên hệ khẩn cấp" → EMERGENCY CONTACTS SCREEN
│     ├─ Setting toggle:
│     │  "Tự động thông báo khi SOS" (ON/OFF)
│     ├─ Contact cards (max 5):
│     │  1. Anh Nguyễn Văn B
│     │     - Relation: Anh trai
│     │     - Phone: 090***1234
│     │     - Primary contact ⭐
│     │     - Actions: Edit | Delete
│     │  2. Chị Nguyễn Thị C
│     │     - Relation: Chị gái
│     │     - Phone: 091***5678
│     ├─ Empty state: "Chưa có liên hệ khẩn cấp"
│     └─ "Thêm liên hệ" → [Add Dialog]
│        ├─ Họ tên (required)
│        ├─ Quan hệ (dropdown)
│        ├─ Số điện thoại (validation)
│        ├─ Set as primary (checkbox)
│        └─ "Lưu" → Add to list
│
├─ Menu Section: Health
│  └─ "Lịch sử sức khỏe" → HEALTH HISTORY SCREEN
│     ├─ Summary stats card:
│     │  - Total incidents: 3
│     │  - Last incident: 2 tháng trước
│     │  - Most common: Rắn lục đuôi đỏ
│     ├─ Filter: Tất cả | Tháng này | 3 tháng | 6 tháng
│     ├─ Timeline cards:
│     │  1. 28/11/2025 - Rắn hổ mang
│     │     - Severity: Nghiêm trọng (red)
│     │     - Hospital: BV Chợ Rẫy
│     │     - Rescuer: Nguyễn Văn A
│     │     - Status: Đã hồi phục ✓
│     │     - Action: Xem chi tiết →
│     │  2. 15/09/2025 - Rắn lục đuôi đỏ
│     │     - Severity: Nhẹ (green)
│     │  3. 03/06/2025 - Rắn ráo trâu
│     │     - Severity: Trung bình (orange)
│     └─ Tap card → HEALTH HISTORY DETAIL SCREEN
│        ├─ Header:
│        │  - Date + Time
│        │  - Snake image + name
│        │  - Severity badge
│        ├─ Timeline Events:
│        │  14:23 - Bị rắn cắn
│        │  14:25 - Gọi SOS
│        │  14:30 - Cứu hộ đến
│        │  14:45 - Đến bệnh viện
│        │  15:30 - Tiêm huyết thanh
│        │  17:00 - Xuất viện
│        ├─ Snake Info:
│        │  - Species + Scientific name
│        │  - Venom type
│        │  - Danger level
│        ├─ Symptoms Reported:
│        │  - Đau dữ dội ✓
│        │  - Sưng nhanh ✓
│        │  - Khó thở ✓
│        ├─ First Aid Taken:
│        │  - Băng ép vết cắn ✓
│        │  - Bất động chi bị cắn ✓
│        │  - Giữ bình tĩnh ✓
│        ├─ Hospital Treatment:
│        │  - Hospital: BV Chớ Rẫy
│        │  - Doctor: BS Nguyễn Văn X
│        │  - Serum: Anti-cobra 4 ống
│        │  - Stay: 2 giờ
│        ├─ Medications:
│        │  - Thuốc giảm đau
│        │  - Kháng sinh
│        │  - Thuốc chống dị ứng
│        ├─ Rescuer Info:
│        │  - Name + Avatar
│        │  - Rating: 4.9⭐
│        │  - Contact button
│        ├─ Evidence Photos:
│        │  - Snake photo
│        │  - Bite wound photos
│        │  - Hospital photos
│        └─ Export PDF button
│
│  └─ "Hồ sơ y tế" → MEDICAL RECORDS SCREEN
│     ├─ Storage info: "Đã sử dụng 45 MB / 500 MB"
│     ├─ Filter tabs:
│     │  Tất cả | Đơn thuốc | Kết quả XN | Hình ảnh | Khác
│     ├─ File cards:
│     │  1. Don_thuoc_28Nov2025.pdf
│     │     - Type: Đơn thuốc
│     │     - Size: 2.3 MB
│     │     - Date: 28/11/2025
│     │     - Actions: Xem | Tải | Chia sẻ | Xóa
│     │  2. Ket_qua_mau.jpg
│     │     - Type: Kết quả xét nghiệm
│     │     - Thumbnail preview
│     │  3. Chup_X-quang.pdf
│     ├─ Upload button (FAB):
│     │  - Camera
│     │  - Gallery
│     │  - File browser
│     │  - Scan document
│     └─ Empty state: "Chưa có hồ sơ y tế nào"
│
│  └─ "Tìm bệnh viện" → HOSPITAL FINDER SCREEN
│     ├─ Map view:
│     │  - Hospital markers (red +)
│     │  - User location (blue dot)
│     │  - Zoom controls
│     ├─ Search bar:
│     │  - "Tìm bệnh viện..."
│     │  - Voice search button
│     ├─ Filter chips:
│     │  - 24/7
│     │  - Có huyết thanh rắn
│     │  - Khoa cấp cứu
│     │  - Bảo hiểm
│     │  - Gần nhất
│     ├─ Hospital list:
│     │  1. Bệnh viện Chợ Rẫy
│     │     - Distance: 2.3 km
│     │     - Rating: 4.8⭐ (1,234 reviews)
│     │     - Features:
│     │       • 24/7 ✓
│     │       • Huyết thanh đầy đủ ✓
│     │       • Khoa độc ✓
│     │       • Bảo hiểm ✓
│     │     - Phone: (028) 3855 4137
│     │     - Actions:
│     │       [Chỉ đường] (blue) → Google Maps
│     │       [Gọi điện] (green) → Phone call
│     │  2. BV Quận 10 (5.1 km)
│     │  3. BV Nguyễn Tri Phương (6.8 km)
│     └─ Sort by: Khoảng cách | Rating | Tên
│
├─ Menu Section: Communication
│  └─ "Tin nhắn" → MESSAGES SCREEN
│     ├─ Tab filters:
│     │  Tất cả | Chuyên gia | Cứu hộ | Hỗ trợ
│     ├─ Search: "Tìm kiếm tin nhắn..."
│     ├─ Thread list:
│     │  1. BS Nguyễn Văn X 🩺
│     │     - Preview: "Nhớ uống thuốc đúng giờ nhé"
│     │     - Time: 10:30
│     │     - Unread badge: 2
│     │     - Online status: green dot
│     │  2. Cứu hộ Trần Văn Y 🚑
│     │     - Preview: "Đã đến nơi an toàn"
│     │     - Time: Hôm qua
│     │     - Verified badge ✓
│     │  3. Hỗ trợ SnakeAid 💬
│     │     - Preview: "Cảm ơn đã liên hệ..."
│     │     - Time: 2 ngày trước
│     ├─ Empty state: "Chưa có tin nhắn"
│     └─ Tap thread → MESSAGE DETAIL SCREEN
│        ├─ Header:
│        │  - Avatar + Name
│        │  - Status: Đang hoạt động
│        │  - Verified badge
│        │  - Actions: Call | More
│        ├─ Messages:
│        │  - Receiver bubbles (left, white)
│        │    • Avatar for last in group
│        │    • Timestamp below
│        │  - Sender bubbles (right, green)
│        │    • No avatar
│        │  - Image messages with preview
│        │  - Typing indicator: "Đang nhập..."
│        ├─ Input area:
│        │  - Text field: "Nhập tin nhắn..."
│        │  - Attach button:
│        │    [Bottom sheet]
│        │    • 📷 Thư viện
│        │    • 📸 Camera
│        │    • 📄 Tài liệu
│        │  - Send button (green circle)
│        └─ Options menu:
│           - Tìm kiếm trong cuộc trò chuyện
│           - Tắt thông báo
│           - Chặn người dùng
│
└─ Menu Section: Settings
   └─ "Cài đặt" → SETTINGS SCREEN
      ├─ Account Section:
      │  • Đổi mật khẩu
      │    → [Dialog] Old password + New password + Confirm
      │  • Liên kết tài khoản
      │    - Facebook (connected ✓)
      │    - Google (connect →)
      │  • Xóa tài khoản
      │    → [Warning Dialog] → Password confirm → Delete
      │
      ├─ Notifications Section:
      │  • Push notifications (toggle ON)
      │    - SOS alerts (ON)
      │    - Messages (ON)
      │    - Promotions (OFF)
      │  • Email notifications (toggle OFF)
      │  • SMS notifications (toggle ON)
      │
      ├─ Security Section:
      │  • Xác thực 2 bước (toggle OFF)
      │    → Setup: SMS / Authenticator app
      │  • Face ID / Touch ID (toggle ON)
      │  • Mã PIN ứng dụng (toggle OFF)
      │
      ├─ Preferences Section:
      │  • Ngôn ngữ: Tiếng Việt
      │    → [Dialog] Việt | English
      │  • Múi giờ: GMT+7 (Auto)
      │  • Theme: Tự động
      │    → Sáng | Tối | Tự động
      │
      ├─ About Section:
      │  • Phiên bản: 1.0.0 (Build 100)
      │  • Điều khoản sử dụng → Web view
      │  • Chính sách bảo mật → Web view
      │  • Giấy phép mã nguồn → List
      │  • Liên hệ hỗ trợ
      │    - Email: support@snakeaid.vn
      │    - Hotline: 1900-SNAKE
      │
      └─ Logout Section:
         • "Đăng xuất" (red text)
           → [Confirm Dialog]
           "Bạn có chắc muốn đăng xuất?"
           [Hủy] [Đăng xuất]
           → Clear session → Login screen
```

---

## 🎯 Navigation Map

```
Profile (Hub)
│
├─ Personal Info
│  ├─ Edit Profile → Form → Save → Back
│  ├─ ID Documents → Upload/View → Verification
│  └─ Emergency Contacts → Add/Edit/Delete → Save
│
├─ Wallet
│  ├─ Deposit → Select method → Payment → Success → Back
│  ├─ Withdraw → Enter amount → Confirm → Processing → Back
│  └─ Payment History → Filter/Search → Export
│
├─ Health
│  ├─ Health History → Timeline → Detail → Export PDF
│  ├─ Medical Records → Upload/View/Share → Manage
│  └─ Hospital Finder → Map/List → Directions/Call
│
├─ Communication
│  └─ Messages → Thread list → Chat detail → Send message
│
└─ Settings
   ├─ Account → Change password / Delete
   ├─ Notifications → Toggle preferences
   ├─ Security → 2FA / Biometric
   ├─ Preferences → Language / Theme
   └─ About → Terms / Privacy / Support
      └─ Logout → Confirm → Login screen
```

---

## 🎨 Design System - Member Profile

### Colors
- **Primary Green**: `#228B22` - Main actions, success states
- **Secondary Blue**: `#007AFF` - Info, links, hospital markers
- **Warning Orange**: `#FF9800` - Medium severity
- **Danger Red**: `#DC3545` - Critical, delete, logout
- **Success Light**: `#D4EDDA` - Success banners
- **Background**: `#F8F8F6` - App background
- **Card White**: `#FFFFFF` - Content cards
- **Border Gray**: `#E5E7EB` - Dividers, borders
- **Text Primary**: `#191910` - Headings
- **Text Secondary**: `#666666` - Body text
- **Text Tertiary**: `#999999` - Captions, placeholders

### Typography
- **Screen Titles**: 18-22px, Bold (w700)
- **Section Headers**: 16-18px, Bold (w600-w700)
- **Card Titles**: 15-16px, SemiBold (w600)
- **Body Text**: 14-15px, Regular/Medium (w400-w500)
- **Labels**: 13-14px, Medium (w500)
- **Captions**: 11-12px, Regular/Medium (w400-w500)

### Components
- **Profile Avatar**: 80-100px circle, green border for verified
- **Cards**: White bg, rounded 12-16px, shadow 0.05 opacity
- **List Items**: White bg, 56-72px height, dividers
- **Buttons**:
  - Primary: Green, rounded 12px, 48-56px height
  - Outlined: Border green/blue/red, transparent bg
  - Text: No bg, colored text
- **Input Fields**: 
  - Border gray, rounded 8px, 48px height
  - Focus: green border
  - Error: red border + text below
- **Badges**:
  - Verified: Green checkmark
  - Unread: Red circle with number
  - Status: Color-coded pills
- **Dialogs**: Rounded 20px, shadow, icon at top

### Spacing
- **Screen padding**: 16px horizontal
- **Section spacing**: 24px vertical
- **Card spacing**: 12px between cards
- **Item spacing**: 16px inside cards

---

## 🔧 Technical Implementation

### State Management
```dart
// User Profile State
- profileData: UserProfile
- isEditing: bool
- isLoading: bool
- validationErrors: Map<String, String>

// Wallet State
- balance: double
- transactions: List<Transaction>
- isProcessing: bool

// Messages State
- threads: List<MessageThread>
- activeThread: MessageThread?
- messages: List<Message>
- unreadCount: int

// Settings State
- preferences: UserPreferences
- notificationSettings: NotificationSettings
- securitySettings: SecuritySettings
```

### Data Models
```dart
class UserProfile {
  String id;
  String name;
  String email;
  String phone;
  DateTime? birthday;
  String? gender;
  String? address;
  String? bloodType;
  String? allergies;
  String? avatarUrl;
  bool isVerified;
}

class Transaction {
  String id;
  TransactionType type; // deposit/withdraw/payment
  double amount;
  DateTime date;
  TransactionStatus status;
  String? description;
  PaymentMethod? method;
}

class MessageThread {
  String id;
  String userId;
  String userName;
  String userAvatar;
  bool isExpert;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  bool isOnline;
}

class EmergencyContact {
  String id;
  String name;
  String relationship;
  String phone;
  bool isPrimary;
}

class HealthIncident {
  String id;
  DateTime date;
  String snakeName;
  String severity;
  String hospital;
  List<String> symptoms;
  List<String> treatments;
  bool isRecovered;
}
```

### Validation Rules
```dart
// Email
- Format: email@domain.com
- Required for edit profile

// Phone
- Format: 10 digits starting with 0
- Required, read-only in edit

// Password
- Min 8 characters
- At least 1 uppercase, 1 number
- Required for change password

// Amount (deposit/withdraw)
- Min deposit: 10,000 VNĐ
- Max deposit: 50,000,000 VNĐ
- Min withdraw: 50,000 VNĐ
- Max withdraw: balance - 10,000 VNĐ (reserve)

// Emergency Contact
- Max 5 contacts
- Phone unique
- At least 1 required for SOS
```

### File Upload
```dart
// Image compression
- Max size: 5 MB
- Quality: 80%
- Format: JPEG/PNG

// Document upload
- Max size: 10 MB per file
- Total storage: 500 MB
- Formats: PDF, JPG, PNG

// ID verification
- Front + Back required for CMND/CCCD
- Auto crop and enhance
- OCR for auto-fill
```

---

## 📝 API Endpoints

```
User Profile
GET    /api/user/profile
PUT    /api/user/profile
POST   /api/user/avatar
DELETE /api/user/account

Wallet
GET    /api/wallet/balance
POST   /api/wallet/deposit
POST   /api/wallet/withdraw
GET    /api/wallet/transactions

Messages
GET    /api/messages/threads
GET    /api/messages/:threadId
POST   /api/messages/:threadId
PUT    /api/messages/:messageId/read

Health
GET    /api/health/history
GET    /api/health/incidents/:id
POST   /api/health/records/upload
GET    /api/health/records
DELETE /api/health/records/:id

Emergency
GET    /api/emergency/contacts
POST   /api/emergency/contacts
PUT    /api/emergency/contacts/:id
DELETE /api/emergency/contacts/:id

Hospitals
GET    /api/hospitals/nearby?lat=&lng=&radius=
GET    /api/hospitals/search?q=

Settings
GET    /api/settings/preferences
PUT    /api/settings/preferences
POST   /api/settings/change-password
POST   /api/auth/logout
```

---

## 🔐 Security Features

### Data Protection
- ✅ **Encryption**: All sensitive data encrypted at rest
- ✅ **HTTPS**: All API calls over SSL
- ✅ **Token**: JWT with 24h expiration
- ✅ **Biometric**: Face ID / Fingerprint for app access
- ✅ **2FA**: SMS or Authenticator app
- ✅ **Session**: Auto logout after 30min inactive

### Privacy Controls
- ✅ Phone number masking: 090***1234
- ✅ Email masking: abc***@gmail.com
- ✅ ID document blur in preview
- ✅ Message encryption end-to-end
- ✅ Location sharing consent
- ✅ Data export option (GDPR)
- ✅ Account deletion with confirmation

---

## 🎯 User Experience Guidelines

### Form Best Practices
1. **Inline validation**: Show errors as user types
2. **Clear labels**: Above field, not placeholder
3. **Helper text**: Below field for guidance
4. **Error state**: Red border + icon + text
5. **Success state**: Green check when valid
6. **Focus state**: Green border highlight
7. **Required fields**: Red asterisk (*)
8. **Character count**: Show for limited fields

### Loading States
- **Shimmer**: For list/card loading
- **Spinner**: For button actions
- **Progress bar**: For file upload
- **Pull to refresh**: For list screens
- **Skeleton**: For profile/details loading

### Empty States
- **Illustration**: Friendly image
- **Title**: Clear, concise
- **Description**: Helpful guidance
- **Action**: Primary CTA to resolve

### Error Handling
- **Network error**: Retry button
- **Validation error**: Inline with field
- **Server error**: Toast with "Try again"
- **Permission error**: Dialog to settings
- **File error**: Toast with reason

---

## 📊 Analytics Events

```javascript
// Profile
- profile_viewed
- profile_edited
- avatar_changed
- emergency_contact_added

// Wallet
- deposit_initiated
- deposit_completed
- withdraw_initiated
- withdraw_completed
- transaction_viewed

// Health
- health_history_viewed
- incident_detail_viewed
- medical_record_uploaded
- hospital_searched
- hospital_directions_opened

// Messages
- message_thread_opened
- message_sent
- attachment_sent
- call_initiated

// Settings
- password_changed
- 2fa_enabled
- notification_toggled
- language_changed
- logout_confirmed
```

---

## 🚀 Future Enhancements

### Profile & Identity
- [ ] Social login (Facebook, Google, Apple)
- [ ] QR code for profile sharing
- [ ] Digital health passport
- [ ] Voice signature verification
- [ ] NFC card for quick ID

### Wallet & Payments
- [ ] Cryptocurrency support
- [ ] Split payment with insurance
- [ ] Subscription plans
- [ ] Loyalty points/rewards
- [ ] Auto top-up when low balance
- [ ] Bill splitting with family

### Health & Medical
- [ ] Wearable device integration (Apple Watch)
- [ ] Symptom checker AI
- [ ] Medication reminders
- [ ] Doctor appointment booking
- [ ] Telemedicine video calls
- [ ] Health score trending
- [ ] Family health profiles

### Communication
- [ ] Voice messages
- [ ] Video calls
- [ ] Group chats
- [ ] Translation for multilingual
- [ ] Scheduled messages
- [ ] Message templates

### Smart Features
- [ ] AI chatbot for common questions
- [ ] Predictive hospital suggestions
- [ ] Auto-categorize medical records
- [ ] Smart document scanner with OCR
- [ ] Voice commands for navigation
- [ ] Offline mode with sync

---

## 🎓 Developer Notes

### Code Organization
```
lib/features/member/screens/
├─ profile/
│  ├─ profile_screen.dart
│  ├─ edit_profile_screen.dart
│  ├─ id_documents_screen.dart
│  └─ emergency_contacts_screen.dart
├─ wallet/
│  ├─ deposit_money_screen.dart
│  ├─ withdraw_money_screen.dart
│  └─ payment_history_screen.dart
├─ health/
│  ├─ health_history_screen.dart
│  ├─ health_history_detail_screen.dart
│  ├─ medical_records_screen.dart
│  └─ hospital_finder_screen.dart
├─ messages/
│  ├─ messages_screen.dart
│  └─ message_detail_screen.dart
└─ settings/
   └─ settings_screen.dart
```

### Shared Components
- `UserAvatar` - Profile picture with verified badge
- `WalletCard` - Balance display with actions
- `TransactionCard` - Transaction list item
- `MessageBubble` - Chat message bubble
- `HealthIncidentCard` - Timeline card for incidents
- `HospitalCard` - Hospital list item
- `FormField` - Reusable input field
- `StatusBadge` - Color-coded status pills
- `EmptyState` - No data placeholder
- `LoadingShimmer` - Loading skeleton

### Testing Checklist
- ✅ Form validation (all edge cases)
- ✅ File upload (size, format limits)
- ✅ Navigation flows (forward/back)
- ✅ Error handling (network, validation)
- ✅ Payment processing (success/failure)
- ✅ Message real-time updates
- ✅ Biometric authentication
- ✅ Logout session clearing
- ✅ Deep linking to specific screens
- ✅ Accessibility (screen readers)

---

**Last Updated**: January 29, 2026  
**Version**: 1.0.0  
**Team**: SnakeAid Member Development Team  
**Screens**: 14 (excluding home_screen.dart)
