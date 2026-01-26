# SWIMLANE DIAGRAM - QUẢN TRỊ HỆ THỐNG (ADMIN)

## Thông tin dự án
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** Admin Management System
- **Mục đích:** Minh họa quy trình quản trị hệ thống bao gồm quản lý database rắn, cơ sở điều trị, giám sát real-time và quản lý tài chính

---

## SWIMLANE DIAGRAM - LUỒNG CHÍNH (CHIA NHỎ THEO GIAI ĐOẠN)

### 4.1. GIAI ĐOẠN 1: QUẢN LÝ DATABASE LOÀI RẮN

**PlantUML Code:**

```plantuml
@startuml Stage-1-Manage-Snake-Database
title GIAI ĐOẠN 4.1 - QUẢN LÝ DATABASE LOÀI RẮN

|Admin|
start
:Đăng nhập vào
Admin Portal;

|Admin Portal|
:Xác thực tài khoản
Admin;
:Hiển thị Dashboard;

|Admin|
:Truy cập "Quản lý
Database Rắn";

|Admin Portal|
:Hiển thị danh sách
loài rắn hiện có;
:Cung cấp các
chức năng;
note right
  Chức năng:
  [A] Thêm loài rắn mới
  [B] Chỉnh sửa thông tin
  [C] Xóa loài rắn
end note

|Admin|
if (Chọn chức năng?) then (Thêm mới)
  :Chọn "Thêm loài
  rắn mới" (FE-05);
  
  |Admin Portal|
  :Hiển thị form
  nhập liệu;
  
  |Admin|
  :Nhập thông tin
  cơ bản;
  note right
    Thông tin cơ bản:
    - Tên khoa học (Latin)
    - Tên tiếng Việt
    - Tên địa phương
    - Độc tính
    - Mức độ nguy hiểm
    - Đặc điểm nhận dạng
    - Phân bố địa lý
    - Môi trường sống
    - Hành vi
  end note
  
elseif (Chọn chức năng?) then (Edit)
  :Chọn loài rắn
  cần chỉnh sửa;
  
  |Admin Portal|
  :Hiển thị form
  với dữ liệu hiện có;
  
  |Admin|
  :Cập nhật thông tin;
  
elseif (Chọn chức năng?) then (Delete)
  :Chọn loài rắn
  cần xóa;
  
  |Admin Portal|
  :Hiển thị xác nhận
  xóa;
  
  |Admin|
  if (Xác nhận xóa?) then (yes)
    :Xác nhận xóa;
  else (no)
    :Hủy bỏ;
    stop
  endif
endif

|Admin|
:Tiếp tục xử lý;

|Admin Portal|
:Yêu cầu upload
hình ảnh (FE-06);

|Admin|
:Upload hình ảnh rắn;
note right
  Yêu cầu:
  - Tối thiểu 5 ảnh
  - Nhiều góc độ
  - Chất lượng cao
  - Gắn tag: Đầu, thân, đuôi
end note

|Admin Portal|
:Nhận và lưu trữ
hình ảnh;
:Yêu cầu phân loại
khu vực (FE-08);

|Admin|
:Chọn các tỉnh hoặc
thành phố;
:Đánh dấu mức độ
phổ biến;

|Admin Portal|
:Lưu thông tin
vào database;

|Backend System|
:Nhận dữ liệu mới;
:Đồng bộ với
AI Model;
note right
  Xử lý:
  - Cập nhật training data
  - Retrain mô hình (nếu cần)
  - Đồng bộ với tất cả app
end note

if (Có ảnh mới?) then (yes)
  :Trigger retrain
  AI Model;
  
  |AI System|
  :Retrain mô hình
  nhận diện;
  :Test độ chính xác;
  :Deploy model mới;
else (no)
  :Chỉ cập nhật
  metadata;
endif

|Admin Portal|
:Hiển thị thông báo
thành công;
:Đồng bộ hoàn tất;

|Admin|
:Kiểm tra kết quả;
:Test nhận diện
bằng ảnh mẫu;

|Admin Portal|
:Hiển thị kết quả
test AI;
:Hiển thị độ
chính xác;

|Admin|
if (Kết quả OK?) then (yes)
  :Hoàn thành;
  stop
else (no)
  :Điều chỉnh lại
  thông tin;
  note right
    Quay lại bước
    chỉnh sửa
  end note
endif

@enduml
```

---

### 4.2. GIAI ĐOẠN 2: QUẢN LÝ CƠ SỞ ĐIỀU TRỊ

**PlantUML Code:**

```plantuml
@startuml Stage-2-Manage-Medical-Facilities
title GIAI ĐOẠN 4.2 - QUẢN LÝ CƠ SỞ ĐIỀU TRỊ

|Admin|
start
:Truy cập "Quản lý
Cơ sở Điều trị";

|Admin Portal|
:Hiển thị danh sách
bệnh viện hiện có;
:Hiển thị trên
bản đồ;
:Cung cấp chức năng;
note right
  Chức năng:
  - Thêm mới
  - Chỉnh sửa
  - Xóa
  - Tìm kiếm
end note

|Admin|
if (Chọn chức năng?) then (Thêm mới)
  :Chọn "Thêm cơ sở
  mới" (FE-09);
else (Chỉnh sửa)
  :Chọn cơ sở
  cần chỉnh sửa;
endif

|Admin Portal|
:Hiển thị form
nhập liệu;

|Admin|
:Nhập thông tin
cơ sở;
note right
  Thông tin:
  - Tên cơ sở
  - Địa chỉ chi tiết
  - Số điện thoại
  - Email liên hệ
end note

:Chọn vị trí trên
bản đồ;

|Admin Portal|
:Lấy tọa độ GPS
từ bản đồ;

|Admin|
:Cập nhật thông tin
huyết thanh (FE-10);
note right
  Loại huyết thanh:
  - Huyết thanh đa giá
  - Kháng nọc rắn hổ mang
  - Kháng nọc rắn lục
  - Kháng nọc rắn hổ
  - Số lượng tồn kho
end note

:Cấu hình thời gian
hoạt động (FE-11);
note right
  Thời gian:
  - Giờ mở cửa và đóng cửa
  - Các ngày trong tuần
  - Đánh dấu 24/7 (FE-12)
  - Lịch nghỉ lễ
end note

:Phân loại cơ sở;
note right
  Phân loại:
  - Bệnh viện trung ương
  - Bệnh viện tỉnh
  - Trạm y tế huyện/xã
  - Phòng khám tư nhân
end note

|Admin Portal|
:Lưu thông tin
vào database;

|Backend System|
:Cập nhật database
cơ sở điều trị;
:Tính toán lại
bản đồ;
:Đồng bộ với
Patient App;

|Patient App|
:Nhận cập nhật
database mới;
:Cập nhật bản đồ
bệnh viện;

|Admin Portal|
:Hiển thị thông báo
thành công;
:Hiển thị cơ sở
trên bản đồ;

|Admin|
:Kiểm tra vị trí
trên bản đồ;

if (Vị trí chính xác?) then (yes)
  :Xác nhận hoàn tất;
  stop
else (no)
  :Điều chỉnh lại
  tọa độ GPS;
endif

@enduml
```

---

### 4.3. GIAI ĐOẠN 3: GIÁM SÁT HOẠT ĐỘNG REAL-TIME

**PlantUML Code:**

```plantuml
@startuml Stage-3-Real-Time-Monitoring
title GIAI ĐOẠN 4.3 - GIÁM SÁT HOẠT ĐỘNG REAL-TIME

|Admin|
start
:Mở Dashboard
"Giám sát Real-time";

|Admin Portal|
:Hiển thị bản đồ
tổng quan (FE-26);

|Backend System|
:Lấy dữ liệu
real-time;
note right
  Dữ liệu:
  - Ca rắn cắn đang xử lý
  - Yêu cầu cứu hộ đang chờ
  - Ca hoàn thành trong ngày
  - Vị trí Rescuer online
  - Vị trí Expert online
end note

:Cập nhật bản đồ
mỗi 10 giây;

|Admin Portal|
:Hiển thị các điểm
trên bản đồ;
note right
  Mã màu:
  🔴 Ca rắn cắn (đỏ)
  🟡 Cứu hộ đang chờ (vàng)
  🟢 Ca hoàn thành (xanh)
  🔵 Rescuer online (xanh dương)
  ⚫ Expert online (đen)
end note

|Admin|
:Xem tổng quan
trên bản đồ;

if (Muốn xem chi tiết?) then (yes)
  :Click vào một điểm
  trên bản đồ;
  
  |Admin Portal|
  :Hiển thị popup
  thông tin chi tiết;
  note right
    Thông tin:
    - Loại sự kiện
    - Thời gian bắt đầu
    - Trạng thái hiện tại
    - Người liên quan
    - Vị trí GPS
  end note
  
  |Admin|
  if (Ca đang xử lý?) then (yes)
    :Theo dõi vị trí
    Rescuer di chuyển
    (FE-27);
    :Xem trạng thái
    nhiệm vụ (FE-27);
    :Xem thời gian
    phản hồi (FE-29);
  else (no)
    :Xem lịch sử
    sự kiện;
  endif
else (no)
  :Tiếp tục xem
  tổng quan;
endif

|Admin|
:Chọn xem Heat Map
(FE-28);

|Admin Portal|
:Hiển thị biểu đồ
nhiệt;
note right
  Heat Map hiển thị:
  - Khu vực có nhiều sự cố
  - Phân bố theo thời gian
  - Loài rắn gây sự cố nhiều
end note

|Admin|
:Phân tích dữ liệu;

if (Phát hiện bất thường?) then (yes)
  :Phân tích loại
  bất thường;
  
  :Xử lý theo
  tình huống;
  note right
    Xử lý:
    - Nhiều sự cố → Cảnh báo
    - Rescuer chậm → Liên hệ
    - Quá tải → Ưu tiên khẩn cấp
  end note
  
  |Backend System|
  :Thực hiện
  hành động xử lý;
else (no)
  :Tiếp tục giám sát;
endif

|Admin|
:Chọn xuất báo cáo
cuối ngày;

|Admin Portal|
:Tạo báo cáo;
note right
  Báo cáo bao gồm:
  - Tổng số ca xử lý
  - Thời gian phản hồi TB
  - Tỷ lệ hoàn thành
  - Doanh thu nền tảng
end note

:Xuất file báo cáo
(PDF hoặc Excel);

|Admin|
:Tải xuống báo cáo;
:Kết thúc giám sát;

stop
@enduml
```

---

### 4.4. GIAI ĐOẠN 4: QUẢN LÝ TÀI CHÍNH

**PlantUML Code:**

```plantuml
@startuml Stage-4-Financial-Management
title GIAI ĐOẠN 4.4 - QUẢN LÝ TÀI CHÍNH

|Admin|
start
:Truy cập "Quản lý
Tài chính";

|Admin Portal|
:Hiển thị Dashboard
tài chính;

|Admin|
if (Chọn chức năng?) then (Setup)
  :Truy cập "Thiết lập
  phí dịch vụ" (FE-30);
  
  |Admin Portal|
  :Hiển thị form
  cấu hình phí;
  
  |Admin|
  :Cấu hình các
  mức phí;
  note right
    Cấu hình:
    - Phí cứu hộ rắn đề xuất
    - Phí tư vấn chuyên gia
    - % hoa hồng nền tảng (10%)
    - % chia cho Rescuer (85%)
    - % quỹ bảo hiểm (5%)
  end note
  
  |Admin Portal|
  :Lưu cấu hình;
  :Áp dụng cho
  giao dịch mới;
  
elseif (Chọn chức năng?) then (Report)
  :Chọn "Báo cáo
  doanh thu"
  (FE-31, FE-33);
  
  |Admin Portal|
  :Hiển thị bộ lọc
  báo cáo;
  note right
    Bộ lọc:
    - Theo thời gian
    - Theo loại dịch vụ
    - Theo người dùng
  end note
  
  |Admin|
  :Chọn bộ lọc;
  
  |Backend System|
  :Truy vấn database
  tài chính;
  :Tính toán
  thống kê;
  
  |Admin Portal|
  :Hiển thị báo cáo;
  note right
    Báo cáo bao gồm:
    - Tổng doanh thu hệ thống
    - Doanh thu từ cứu hộ
    - Doanh thu từ tư vấn
    - Doanh thu theo Rescuer
    - Doanh thu theo Expert
    - Biểu đồ xu hướng
  end note
  
  |Admin|
  :Xem và phân tích
  báo cáo;
  
elseif (Chọn chức năng?) then (Payment)
  :Chọn "Quản lý
  thanh toán" (FE-32);
  
  |Admin Portal|
  :Hiển thị danh sách
  giao dịch;
  note right
    Hiển thị:
    - Giao dịch chờ xử lý
    - Giao dịch hoàn thành
    - Giao dịch lỗi
  end note
  
  |Admin|
  if (Có giao dịch lỗi?) then (yes)
    :Chọn giao dịch lỗi;
    
    |Admin Portal|
    :Hiển thị chi tiết
    giao dịch;
    
    |Admin|
    :Phân tích nguyên nhân;
    :Xử lý theo
    nguyên nhân;
    note right
      Xử lý:
      - Lỗi cổng → Thử lại
      - Không đủ tiền → Liên hệ
      - Khác → Thủ công
    end note
  else (no)
    :Không có giao dịch lỗi;
  endif
  
elseif (Chọn chức năng?) then (Dispute)
  :Chọn "Xử lý
  tranh chấp" (FE-35);
  
  |Admin Portal|
  :Hiển thị danh sách
  khiếu nại;
  
  |Admin|
  :Chọn một khiếu nại;
  
  |Admin Portal|
  :Hiển thị chi tiết
  khiếu nại;
  note right
    Chi tiết:
    - Người khiếu nại
    - Nội dung khiếu nại
    - Bằng chứng đính kèm
    - Lịch sử giao dịch
  end note
  
  |Admin|
  :Phân tích khiếu nại;
  :Kiểm tra bằng chứng;
  
  |Backend System|
  :Truy vấn dữ liệu
  liên quan;
  note right
    Kiểm tra:
    - Lịch sử GPS
    - Trạng thái thanh toán
    - Lịch sử giao dịch
  end note
  
  |Admin Portal|
  :Hiển thị bằng chứng;
  
  |Admin|
  if (Chấp nhận khiếu nại?) then (yes)
    :Chấp nhận khiếu nại;
    :Hoàn tiền cho
    người dùng (FE-34);
    :Xử phạt bên vi phạm;
  else (no)
    :Từ chối khiếu nại;
    :Gửi bằng chứng
    cho người khiếu nại;
  endif
  
elseif (Chọn chức năng?) then (Export)
  :Chọn "Xuất báo cáo
  định kỳ" (FE-33);
  
  |Admin Portal|
  :Hiển thị tùy chọn
  báo cáo;
  note right
    Loại báo cáo:
    - Báo cáo tháng
    - Báo cáo quý
    - Báo cáo năm
  end note
  
  |Admin|
  :Chọn loại báo cáo;
  
  |Backend System|
  :Tạo báo cáo
  tổng hợp;
  :Tính toán các
  chỉ số tài chính;
  
  |Admin Portal|
  :Xuất file báo cáo
  (PDF và Excel);
  
  |Admin|
  :Tải xuống báo cáo;
  :Gửi cho Ban
  Giám đốc;
endif

stop
@enduml
```

---

## TÓM TẮT CÁC GIAI ĐOẠN

| Giai đoạn | Tên | Chức năng chính | Thời gian ước tính |
|-----------|-----|-----------------|-------------------|
| **4.1** | Quản lý database loài rắn | Thêm, sửa, xóa thông tin rắn + Upload ảnh + Train AI | 10-20 phút/loài |
| **4.2** | Quản lý cơ sở điều trị | Thêm, sửa bệnh viện + Cập nhật huyết thanh + Cấu hình giờ hoạt động | 5-10 phút/cơ sở |
| **4.3** | Giám sát hoạt động real-time | Theo dõi bản đồ + Heat map + Xử lý bất thường + Xuất báo cáo | Liên tục |
| **4.4** | Quản lý tài chính | Thiết lập phí + Báo cáo doanh thu + Xử lý tranh chấp + Hoàn tiền | 5-30 phút/tác vụ |

---

## SWIMLANE DIAGRAM TỔNG HỢP (TẤT CẢ CÁC GIAI ĐOẠN)

### Phiên bản PlantUML đầy đủ

```plantuml
@startuml Complete-Admin-Management-Flow
title QUẢN TRỊ HỆ THỐNG - SWIMLANE DIAGRAM ĐẦY ĐỦ

|Admin|
start
:Đăng nhập Admin
Portal;

|Admin Portal|
:Hiển thị Dashboard
tổng quan;

|Admin|
if (Chọn module?) then (Database Rắn)
  :Quản lý database
  loài rắn;
  :Thêm hoặc sửa
  thông tin rắn;
  :Upload hình ảnh;
  
  |Backend System|
  :Đồng bộ với
  AI Model;
  :Retrain mô hình;
  
else (Cơ sở điều trị)
  :Quản lý bệnh viện;
  :Thêm hoặc sửa
  thông tin BV;
  :Cấu hình huyết thanh
  và giờ hoạt động;
  
  |Backend System|
  :Cập nhật database;
  :Đồng bộ với
  Patient App;
  
else (Giám sát)
  :Mở Dashboard
  real-time;
  :Xem bản đồ
  hoạt động;
  :Phân tích Heat Map;
  
  if (Phát hiện
  bất thường?) then (yes)
    :Xử lý bất thường;
    :Gửi cảnh báo
    cộng đồng;
  endif
  
  :Xuất báo cáo
  cuối ngày;
  
else (Tài chính)
  :Quản lý tài chính;
  
  if (Chức năng?) then (Thiết lập phí)
    :Cấu hình mức phí
    dịch vụ;
  else (Báo cáo)
    :Xem báo cáo
    doanh thu;
  else (Tranh chấp)
    :Xử lý khiếu nại;
    :Hoàn tiền nếu cần;
  endif
endif

|Admin Portal|
:Lưu thay đổi;
:Đồng bộ toàn hệ thống;

stop
@enduml
```

---

## CHÚ THÍCH

### Actors (Vai trò)
- **Admin:** Quản trị viên hệ thống
- **Admin Portal:** Giao diện web quản trị
- **Backend System:** Hệ thống backend xử lý dữ liệu
- **AI System:** Hệ thống AI nhận diện rắn
- **Patient App:** Ứng dụng người dùng cuối

### Quyền hạn Admin
1. **Super Admin:**
   - Toàn quyền trên hệ thống
   - Quản lý tất cả module
   - Xử lý tranh chấp cao cấp
   - Xuất báo cáo tài chính

2. **Content Admin:**
   - Quản lý database rắn
   - Quản lý cơ sở điều trị
   - Không truy cập tài chính

3. **Support Admin:**
   - Giám sát hoạt động
   - Xử lý khiếu nại người dùng
   - Không sửa database

### Tính năng nâng cao

#### 4.1. Quản lý Database Rắn
- **Import/Export:** Nhập xuất dữ liệu hàng loạt (CSV, Excel)
- **Version Control:** Theo dõi lịch sử thay đổi dữ liệu
- **AI Accuracy Report:** Báo cáo độ chính xác nhận diện theo loài
- **Image Quality Check:** Tự động kiểm tra chất lượng ảnh upload

#### 4.2. Quản lý Cơ sở Điều trị
- **Auto-sync với Google Maps:** Tự động lấy thông tin từ Google Maps
- **Inventory Management:** Quản lý tồn kho huyết thanh
- **Alert System:** Cảnh báo khi huyết thanh sắp hết
- **Verification Status:** Đánh dấu cơ sở đã xác minh

#### 4.3. Giám sát Real-time
- **Multi-screen Dashboard:** Hỗ trợ nhiều màn hình giám sát
- **Alert Thresholds:** Cấu hình ngưỡng cảnh báo tự động
- **Historical Playback:** Xem lại lịch sử di chuyển Rescuer
- **Performance Metrics:** Đo lường hiệu suất từng Rescuer/Expert

#### 4.4. Quản lý Tài chính
- **Automated Reconciliation:** Đối soát tự động với cổng thanh toán
- **Tax Reports:** Báo cáo thuế theo quy định
- **Commission Rules:** Cấu hình quy tắc hoa hồng linh hoạt
- **Fraud Detection:** Phát hiện giao dịch bất thường

### API Endpoints liên quan

#### Database Management
- `POST /api/admin/snake/create` - Tạo loài rắn mới
- `PUT /api/admin/snake/:id/update` - Cập nhật thông tin rắn
- `DELETE /api/admin/snake/:id/delete` - Xóa loài rắn
- `POST /api/admin/snake/:id/upload-images` - Upload ảnh rắn
- `POST /api/admin/snake/retrain-ai` - Trigger retrain AI model

#### Hospital Management
- `POST /api/admin/hospital/create` - Thêm bệnh viện mới
- `PUT /api/admin/hospital/:id/update` - Cập nhật thông tin BV
- `PUT /api/admin/hospital/:id/antivenom` - Cập nhật huyết thanh
- `PUT /api/admin/hospital/:id/schedule` - Cấu hình giờ hoạt động

#### Monitoring
- `GET /api/admin/monitoring/realtime` - Lấy dữ liệu real-time
- `GET /api/admin/monitoring/heatmap` - Lấy dữ liệu heat map
- `GET /api/admin/monitoring/report/daily` - Báo cáo cuối ngày
- `POST /api/admin/alert/community` - Gửi cảnh báo cộng đồng

#### Financial
- `PUT /api/admin/finance/fees` - Cấu hình phí dịch vụ
- `GET /api/admin/finance/revenue` - Báo cáo doanh thu
- `GET /api/admin/finance/transactions` - Danh sách giao dịch
- `POST /api/admin/finance/refund` - Xử lý hoàn tiền
- `PUT /api/admin/finance/dispute/:id/resolve` - Giải quyết tranh chấp

### Báo cáo và Analytics

#### Daily Report
- Tổng số ca xử lý trong ngày
- Thời gian phản hồi trung bình
- Tỷ lệ thành công
- Top 5 loài rắn gây sự cố
- Doanh thu trong ngày

#### Weekly Report
- Xu hướng số lượng sự cố
- So sánh với tuần trước
- Hiệu suất Rescuer/Expert
- Phân bố địa lý sự cố
- Tỷ lệ hài lòng khách hàng

#### Monthly Report
- Tổng quan tháng
- Doanh thu và lợi nhuận
- Growth rate
- User retention
- Top performers (Rescuer/Expert)

#### Quarterly/Yearly Report
- Báo cáo tổng hợp cho Ban Giám đốc
- Phân tích xu hướng dài hạn
- Đề xuất chiến lược
- Budget planning

---

**Ghi chú:** Các feature code (FE-XX) tham chiếu đến file `Major-Features-Summary.md`
