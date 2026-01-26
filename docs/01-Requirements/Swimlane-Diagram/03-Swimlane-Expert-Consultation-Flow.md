# SWIMLANE DIAGRAM - TƯ VẤN CHUYÊN GIA

## Thông tin dự án
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** Expert Consultation
- **Mục đích:** Minh họa quy trình tư vấn chuyên gia từ Patient và hỗ trợ khẩn cấp cho Rescuer

---

## SWIMLANE DIAGRAM - LUỒNG CHÍNH (CHIA NHỎ THEO GIAI ĐOẠN)

### 3.1. GIAI ĐOẠN 1: YÊU CẦU TƯ VẤN TỪ PATIENT

**PlantUML Code:**

```plantuml
@startuml Stage-1-Patient-Request-Consultation
title GIAI ĐOẠN 3.1 - YÊU CẦU TƯ VẤN TỪ PATIENT

|Patient|
start
:Truy cập "Tư vấn
chuyên gia";

|Mobile App|
:Hiển thị danh sách
Snake Expert;
note right
  Hiển thị:
  - Tên
  - Chuyên môn
  - Rating
  - Phí tư vấn
end note

:Cung cấp bộ lọc;
note right
  Lọc theo:
  - Chuyên ngành
  - Rating
  - Phí tư vấn
end note

|Patient|
:Xem danh sách
Expert;
:Chọn một Expert;

|Mobile App|
:Hiển thị chi tiết
Expert;
:Hiển thị 2 lựa chọn;
note right
  Loại tư vấn:
  [A] Tư vấn ngay (nếu online)
  [B] Đặt lịch tư vấn
end note

|Patient|
if (Chọn loại tư vấn?) then (Tư vấn ngay)
  :Chọn tư vấn ngay
  (FE-10);
  
  |Mobile App|
  if (Expert đang online?) then (yes)
    :Cho phép tiếp tục;
  else (no)
    :Thông báo Expert
    đang offline;
    :Đề xuất đặt lịch;
    stop
  endif
  
else (Đặt lịch)
  :Chọn đặt lịch
  tư vấn;
  
  |Mobile App|
  :Hiển thị lịch
  trống của Expert;
  
  |Patient|
  :Chọn ngày giờ
  phù hợp;
endif

|Mobile App|
:Yêu cầu upload
tài liệu;

|Patient|
:Upload tài liệu;
note right
  Tài liệu:
  - Ảnh rắn hoặc vết cắn
  - Mô tả vấn đề
  - Câu hỏi cụ thể
end note

|Mobile App|
:Hiển thị hóa đơn
phí tư vấn (FE-27);

|Patient|
:Chọn phương thức
thanh toán;
:Xác nhận thanh toán;

|Payment Gateway|
:Xử lý thanh toán;
:Giữ tiền trong
escrow;
note right
  Tiền tạm giữ,
  chỉ chuyển cho Expert
  sau khi tư vấn xong
end note

|Backend System|
:Nhận xác nhận
thanh toán;
:Tạo yêu cầu
tư vấn;

if (Loại tư vấn?) then (Tư vấn ngay)
  :Gửi thông báo
  khẩn cấp đến Expert;
  
  |Snake Expert|
  :Nhận thông báo
  tư vấn ngay;
  
  if (Chấp nhận?) then (yes)
    :Chấp nhận
    yêu cầu;
    note right
      Chuyển sang
      Giai đoạn 3.3
    end note
  else (no)
    :Từ chối;
    
    |Backend System|
    :Hoàn tiền cho
    Patient;
    :Thông báo
    Patient;
    stop
  endif
  
else (Đặt lịch)
  :Gửi yêu cầu
  đặt lịch;
  
  |Snake Expert|
  :Nhận yêu cầu
  đặt lịch;
  :Xem thông tin
  Patient;
  :Xác nhận lịch hẹn;
  
  |Backend System|
  :Tạo lịch hẹn;
  :Gửi thông báo
  cho Patient;
  
  |Mobile App|
  :Hiển thị lịch hẹn
  đã xác nhận;
  
  |Patient|
  :Nhận xác nhận
  lịch hẹn;
  note right
    Hệ thống sẽ gửi
    nhắc nhở trước 30 phút
  end note
endif

stop
@enduml
```

---

### 3.2. GIAI ĐOẠN 2: RESCUER YÊU CẦU HỖ TRỢ KHẨN CẤP

**PlantUML Code:**

```plantuml
@startuml Stage-2-Rescuer-Emergency-Support
title GIAI ĐOẠN 3.2 - RESCUER YÊU CẦU HỖ TRỢ KHẨN CẤP

|Snake Rescuer|
start
:Đang ở hiện trường;
:Gặp khó khăn
nhận diện rắn;
:Mở app Rescuer;
:Chọn "Yêu cầu hỗ trợ
chuyên gia" (FE-12);

|Rescuer App|
:Kích hoạt camera;
:Yêu cầu chụp ảnh
hoặc video rắn;

|Snake Rescuer|
:Chụp ảnh hoặc quay
video rắn real-time
(FE-14);
:Gửi yêu cầu
khẩn cấp;

|Backend System|
:Nhận yêu cầu
hỗ trợ khẩn cấp;
:Xác định vị trí
Rescuer;
:Tìm Expert
đang online;
note right
  Ưu tiên:
  - Expert chuyên về
    khu vực địa lý này
  - Expert có kinh nghiệm
    với loài rắn trong vùng
end note

:Gửi thông báo
đến top 3 Expert;

|Snake Expert|
:Nhận thông báo
khẩn cấp;
note right
  Thông báo bao gồm:
  - Ảnh hoặc video rắn
  - Vị trí Rescuer
  - Thông tin tình huống
  - Mức độ khẩn cấp
end note

:Xem nhanh
ảnh rắn;

if (Có thể hỗ trợ?) then (yes)
  :Chấp nhận yêu cầu;
  note right
    Expert phản hồi
    nhanh nhất sẽ được
    kết nối
  end note
  
  |Backend System|
  :Kết nối Expert
  với Rescuer;
  :Kích hoạt kênh
  tư vấn;
  
else (no)
  :Từ chối;
  note right
    Nếu không chuyên môn
    hoặc đang bận
  end note
  stop
endif

|Rescuer App|
:Mở kênh tư vấn;
:Hiển thị thông tin
Expert;

|Snake Rescuer|
:Bắt đầu trao đổi
với Expert;

|Snake Expert|
:Tư vấn qua chat
hoặc video call
(FE-11);
:Xem ảnh hoặc video
rắn;
:Phân tích đặc điểm;
:Xác định loài rắn;
:Tư vấn cách bắt
an toàn;
note right
  Tư vấn:
  - Loài rắn
  - Mức độ nguy hiểm
  - Thiết bị cần dùng
  - Kỹ thuật bắt an toàn
  - Cảnh báo rủi ro
end note

:Gửi hướng dẫn
chi tiết;

|Snake Rescuer|
:Nhận hướng dẫn
từ Expert;
:Áp dụng kỹ thuật
được tư vấn;
:Thực hiện bắt rắn;

if (Thành công?) then (yes)
  :Bắt rắn thành công;
  :Cảm ơn Expert;
  
  |Snake Expert|
  :Cập nhật kết quả
  vào hệ thống;
  
else (no)
  :Gặp khó khăn
  tiếp tục;
  :Yêu cầu tư vấn
  thêm;
  
  |Snake Expert|
  :Tư vấn thêm
  giải pháp;
endif

|Backend System|
:Kết thúc phiên
tư vấn;
:Ghi nhận thời gian
tư vấn;

:Xử lý thanh toán;
note right
  Thanh toán:
  - Nền tảng trả phí cho Expert
  - Hoặc Rescuer chia sẻ 10%
    phí cứu hộ cho Expert
end note

|Snake Expert|
:Nhận thanh toán
phí tư vấn;

|Snake Rescuer|
:Tiếp tục hoàn thành
nhiệm vụ cứu hộ;

stop
@enduml
```

---

### 3.3. GIAI ĐOẠN 3: PHIÊN TƯ VẤN TRỰC TUYẾN

**PlantUML Code:**

```plantuml
@startuml Stage-3-Online-Consultation-Session
title GIAI ĐOẠN 3.3 - PHIÊN TƯ VẤN TRỰC TUYẾN

|Backend System|
start
:Đến giờ hẹn;
:Gửi thông báo
nhắc nhở;

fork
  |Patient|
  :Nhận thông báo
  nhắc nhở;
  :Chuẩn bị tham gia
  phiên tư vấn;
fork again
  |Snake Expert|
  :Nhận thông báo
  nhắc nhở;
  :Chuẩn bị tài liệu
  tư vấn;
end fork

|Mobile App|
:Kích hoạt phiên
tư vấn;
:Hiển thị giao diện
chat hoặc video call;

|Patient|
:Tham gia phiên
tư vấn (FE-10);

|Snake Expert|
:Tham gia phiên
tư vấn;
:Xem thông tin
Patient đã gửi trước;
note right
  Xem:
  - Ảnh rắn hoặc vết cắn
  - Mô tả vấn đề
  - Câu hỏi cụ thể
end note

if (Chọn hình thức?) then (Chat text)
  :Bắt đầu chat
  text;
  
  |Patient|
  :Trao đổi qua
  chat;
  
else (Video call)
  :Bắt đầu video
  call;
  
  |Patient|
  :Trao đổi qua
  video call;
endif

|Snake Expert|
:Phân tích tình huống;
:Giải đáp thắc mắc;
:Đưa ra khuyến nghị;

if (Cần thêm thông tin?) then (yes)
  :Yêu cầu Patient
  cung cấp thêm;
  
  |Patient|
  :Chụp thêm ảnh
  hoặc mô tả chi tiết;
  
  |Snake Expert|
  :Nhận thông tin
  bổ sung;
  :Phân tích tiếp;
else (no)
  :Tiếp tục tư vấn;
endif

|Snake Expert|
:Tư vấn chi tiết;
note right
  Expert có thể:
  - Cập nhật hướng dẫn sơ cứu
    (FE-07, FE-08)
  - Cung cấp thông tin về
    liều lượng huyết thanh (FE-09)
  - Khuyến nghị đến bệnh viện
    (nếu nghiêm trọng)
end note

:Tổng kết và
đưa ra kết luận;

|Patient|
:Nhận tư vấn
từ Expert;
:Ghi nhận khuyến nghị;

if (Còn thắc mắc?) then (yes)
  :Đặt câu hỏi
  tiếp;
  
  |Snake Expert|
  :Giải đáp thêm;
else (no)
  :Kết thúc phần
  hỏi đáp;
endif

|Snake Expert|
:Đánh dấu "Hoàn thành"
(FE-14);
:Gửi báo cáo
tư vấn;

|Backend System|
:Ghi nhận thời gian
tư vấn;
:Kết thúc phiên;

:Xử lý thanh toán;
note right
  Thanh toán:
  - Chuyển tiền từ escrow
    sang tài khoản Expert (FE-14)
  - Trừ phí nền tảng 10%
  - Xuất hóa đơn điện tử (FE-14)
end note

|Snake Expert|
:Nhận thanh toán;
:Xem hóa đơn
điện tử;

|Mobile App|
:Hiển thị form
đánh giá;

|Patient|
:Đánh giá Expert;
note right
  Đánh giá:
  - Rating 1-5 sao
  - Nhận xét chi tiết
end note

|Backend System|
:Lưu đánh giá;
:Cập nhật rating
của Expert;

:Lưu vào lịch sử;
note right
  Lưu vào:
  - Patient: Lịch sử tư vấn (FE-30)
  - Expert: Doanh thu tháng (FE-15, FE-16)
  - Admin: Thống kê tư vấn (FE-19)
end note

|Snake Expert|
:Xem đánh giá
từ Patient;

|Patient|
:Kết thúc phiên
tư vấn;

stop
@enduml
```

---

## TÓM TẮT CÁC GIAI ĐOẠN

| Giai đoạn | Tên | Actors chính | Thời gian ước tính |
|-----------|-----|--------------|-------------------|
| **3.1** | Yêu cầu tư vấn từ Patient | Patient, Mobile App, Snake Expert | 2-3 phút |
| **3.2** | Rescuer yêu cầu hỗ trợ khẩn cấp | Snake Rescuer, Snake Expert, Backend | 5-10 phút |
| **3.3** | Phiên tư vấn trực tuyến | Patient, Snake Expert, Backend | 15-30 phút |

---

## SWIMLANE DIAGRAM TỔNG HỢP (TẤT CẢ CÁC GIAI ĐOẠN)

### Phiên bản PlantUML đầy đủ

```plantuml
@startuml Complete-Expert-Consultation-Flow
title TƯ VẤN CHUYÊN GIA - SWIMLANE DIAGRAM ĐẦY ĐỦ

|Patient|
start
:Truy cập "Tư vấn
chuyên gia";
:Xem danh sách
Expert;
:Chọn một Expert;
:Chọn loại tư vấn
(Ngay hoặc Đặt lịch);
:Upload tài liệu
cần tư vấn;
:Thanh toán phí
tư vấn trước;

|Backend System|
:Xử lý thanh toán;
:Giữ tiền trong escrow;
:Gửi yêu cầu
đến Expert;

|Snake Expert|
:Nhận yêu cầu
tư vấn;
:Xem thông tin
và tài liệu;
:Chấp nhận hoặc
xác nhận lịch;

|Backend System|
if (Đến giờ hẹn?) then (yes)
  :Gửi thông báo
  nhắc nhở;
else (no)
  :Chờ đến giờ;
endif

|Patient|
:Tham gia phiên
tư vấn;

|Snake Expert|
:Tham gia phiên
tư vấn;
:Phân tích tình huống;
:Tư vấn chi tiết;
:Đưa ra khuyến nghị;
:Hoàn thành tư vấn;

|Backend System|
:Xử lý thanh toán;
:Chuyển tiền cho Expert;

|Patient|
:Đánh giá Expert;

|Backend System|
:Lưu đánh giá;
:Cập nhật rating;
:Lưu vào lịch sử;

stop
@enduml
```

---

## CHÚ THÍCH

### Actors (Vai trò)
- **Patient:** Người dùng cần tư vấn về rắn hoặc vết cắn
- **Snake Rescuer:** Đội cứu hộ cần hỗ trợ khẩn cấp từ chuyên gia
- **Snake Expert:** Chuyên gia về rắn và nọc độc
- **Mobile App:** Ứng dụng di động SnakeAid
- **Rescuer App:** Ứng dụng dành cho đội cứu hộ
- **Backend System:** Hệ thống backend xử lý matching và thanh toán
- **Payment Gateway:** Cổng thanh toán (Momo, VNPay, ZaloPay)

### Các trường hợp đặc biệt
1. **Tư vấn ngay nhưng Expert offline:** Hệ thống đề xuất đặt lịch hoặc chọn Expert khác
2. **Expert từ chối yêu cầu tư vấn ngay:** Hoàn tiền cho Patient và đề xuất Expert khác
3. **Rescuer cần tư vấn khẩn cấp:** Ưu tiên cao nhất, gửi đến top 3 Expert online
4. **Thanh toán giữ trong escrow:** Chỉ chuyển cho Expert sau khi hoàn thành tư vấn
5. **Patient không hài lòng:** Có thể khiếu nại trong vòng 24 giờ để được xem xét hoàn tiền

### Loại hình tư vấn
1. **Tư vấn ngay (Instant Consultation):**
   - Expert phải online
   - Phản hồi trong vòng 2 phút
   - Phí cao hơn 20-30% so với đặt lịch
   
2. **Đặt lịch (Scheduled Consultation):**
   - Có thể đặt trước 24-48 giờ
   - Expert xác nhận lịch
   - Gửi nhắc nhở trước 30 phút
   
3. **Tư vấn khẩn cấp cho Rescuer:**
   - Miễn phí hoặc nền tảng chi trả
   - Ưu tiên cao nhất
   - Expert có kinh nghiệm với khu vực

### API Endpoints liên quan
- `GET /api/experts` - Lấy danh sách chuyên gia
- `POST /api/consultation/request` - Tạo yêu cầu tư vấn
- `POST /api/consultation/accept` - Expert chấp nhận yêu cầu
- `POST /api/consultation/schedule` - Đặt lịch tư vấn
- `POST /api/consultation/start` - Bắt đầu phiên tư vấn
- `POST /api/consultation/complete` - Hoàn thành tư vấn
- `POST /api/consultation/emergency` - Yêu cầu tư vấn khẩn cấp (Rescuer)
- `POST /api/payment/escrow` - Giữ tiền trong escrow
- `POST /api/payment/release` - Giải ngân cho Expert
- `POST /api/rating/expert` - Đánh giá chuyên gia

### Chuyên môn của Expert
1. **Rắn độc Việt Nam:** Chuyên về các loài rắn bản địa
2. **Rắn ngoại lai:** Chuyên về rắn nhập khẩu, rắn cảnh
3. **Điều trị nọc độc:** Bác sĩ chuyên về xử lý vết cắn rắn độc
4. **Sinh thái rắn:** Chuyên về hành vi, môi trường sống
5. **Cứu hộ rắn:** Kỹ thuật bắt rắn an toàn

---

**Ghi chú:** Các feature code (FE-XX) tham chiếu đến file `Major-Features-Summary.md`
