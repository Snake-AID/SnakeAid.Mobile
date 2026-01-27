# SWIMLANE DIAGRAM - YÊU CẦU CỨU HỘ RẮN

## Thông tin dự án
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Module:** Snake Rescue Request & Matching
- **Mục đích:** Minh họa quy trình từ khi người dùng phát hiện rắn đến khi đội cứu hộ hoàn thành nhiệm vụ

---

## SWIMLANE DIAGRAM - LUỒNG CHÍNH (CHIA NHỎ THEO GIAI ĐOẠN)

### 2.1. GIAI ĐOẠN 1: PHÁT HIỆN VÀ BÁO CÁO RẮN

**PlantUML Code:**

```plantuml
@startuml Stage-1-Report-Snake
title GIAI ĐOẠN 2.1 - PHÁT HIỆN VÀ BÁO CÁO RẮN

|Patient|
start
:Phát hiện rắn
(chưa bị cắn);
:Mở app SnakeAid;
:Chọn "Báo cáo
phát hiện rắn";

|Mobile App|
:Hiển thị form
báo cáo;
:Yêu cầu chụp
ảnh rắn;

|Patient|
:Chụp ảnh rắn
(nhiều góc độ);

|Mobile App|
:Tự động lấy
vị trí GPS (FE-18);

|Patient|
:Bổ sung thông tin;
note right
  Thông tin bổ sung:
  - Vị trí cụ thể
  - Kích thước ước tính
  - Mô tả hành vi
  - Mức độ khẩn cấp
end note

|Mobile App|
:Gửi dữ liệu
lên server;

|AI System|
:Phân tích ảnh rắn;
:So sánh với
database loài rắn;
:Đưa ra nhận định;
note right
  Kết quả AI:
  - Loài rắn có thể (FE-12)
  - Độc tính (FE-13)
  - Mức độ nguy hiểm
end note

|Mobile App|
:Hiển thị kết quả
nhận diện;
:Hiển thị 2 lựa chọn;
note right
  [A] Yêu cầu đội cứu hộ
      đến bắt rắn (có phí)
  [B] Chỉ cảnh báo cộng đồng
      (miễn phí)
end note

|Patient|
if (Chọn hành động?) then (Yêu cầu cứu hộ)
  :Chọn yêu cầu
  cứu hộ;
  note right
    Chuyển sang
    Giai đoạn 2.2
  end note
else (Cảnh báo)
  :Chọn cảnh báo
  cộng đồng;
  
  |Backend System|
  :Gửi cảnh báo đến
  người dùng lân cận
  (FE-20);
  
  |Patient|
  :Nhận xác nhận
  đã gửi cảnh báo;
  stop
endif

@enduml
```

---

### 2.2. GIAI ĐOẠN 2: KẾT NỐI VỚI ĐỘI CỨU HỘ (MATCHING)

**PlantUML Code:**

```plantuml
@startuml Stage-2-Matching-Rescuer
title GIAI ĐOẠN 2.2 - KẾT NỐI VỚI ĐỘI CỨU HỘ

|Backend System|
start
:Nhận yêu cầu
cứu hộ từ Patient;
:Xác định thông tin;
note right
  Thông tin:
  - Vị trí GPS
  - Mức độ khẩn cấp
  - Loại rắn (từ AI)
end note

:Tìm kiếm
Snake Rescuer;
note right
  Tiêu chí tìm kiếm:
  - Online trong bán kính 10km
  - Kinh nghiệm với loài này
  - Đánh giá tốt
  - Sắp xếp: Khoảng cách
    → Rating → Thời gian phản hồi
end note

:Chọn top 3
Rescuer phù hợp;

|Snake Rescuer|
:Nhận thông báo
yêu cầu cứu hộ (FE-01);
note right
  Thông báo bao gồm:
  - Vị trí
  - Ảnh rắn và kết quả AI
  - Mức phí đề xuất
  - Thời gian chấp nhận: 2 phút
end note

if (Rescuer chấp nhận\ntrong 2 phút?) then (Có)
  :Chấp nhận
  yêu cầu (FE-06);
  
  |Backend System|
  :Gán Rescuer
  cho yêu cầu;
  :Thông báo cho
  Patient;
  
  |Mobile App|
  :Hiển thị thông tin
  Rescuer;
  note right
    Hiển thị:
    - Tên, ảnh
    - Rating
    - Số điện thoại
  end note
  
  |Patient|
  :Xem thông tin
  đội cứu hộ;
  note right
    Chuyển sang
    Giai đoạn 2.3
  end note
  
else (Không)
  |Backend System|
  if (Đã hết 2 phút?) then (yes)
    :Mở rộng bán kính
    lên 20km;
    :Gửi thông báo cho
    top 5 Rescuer tiếp theo;
    :Tăng mức phí
    đề xuất 20%;
    
    if (Có Rescuer chấp nhận\ntrong 3 phút nữa?) then (yes)
      :Gán Rescuer
      cho yêu cầu;
      
      |Mobile App|
      :Thông báo cho
      Patient;
    else (no)
      :Thông báo cho Patient:
      "Không tìm thấy
      đội cứu hộ";
      :Đề xuất gọi
      115 hoặc trung tâm
      kiểm soát động vật;
      
      |Patient|
      :Nhận thông báo
      không tìm thấy;
      stop
    endif
  endif
endif

@enduml
```

---

### 2.3. GIAI ĐOẠN 3: THỰC HIỆN CỨU HỘ

**PlantUML Code:**

```plantuml
@startuml Stage-3-Rescue-Execution
title GIAI ĐOẠN 2.3 - THỰC HIỆN CỨU HỘ RẮN

|Snake Rescuer|
start
:Chấp nhận
yêu cầu (FE-06);
:Xem lại thông tin;
note right
  Thông tin:
  - Ảnh rắn và kết quả AI (FE-21)
  - Hướng dẫn an toàn (FE-09, FE-10)
end note

:Chuẩn bị thiết bị
(FE-23);

if (Chắc chắn về\nloài rắn?) then (yes)
  :Bắt đầu di chuyển;
else (no)
  :Liên hệ Expert
  (FE-12);
  note right
    Chuyển sang Flow 3.2
    (Tư vấn khẩn cấp)
  end note
  
  |Snake Expert|
  :Nhận yêu cầu
  tư vấn khẩn cấp;
  :Xem ảnh rắn;
  :Tư vấn qua
  chat hoặc video call;
  :Xác định loài rắn;
  :Tư vấn cách bắt
  an toàn;
  
  |Snake Rescuer|
  :Nhận tư vấn
  từ Expert;
  :Bắt đầu di chuyển;
endif

:Cập nhật trạng thái
"Đang trên đường"
(FE-07);
:Bật chia sẻ vị trí
real-time (FE-18);

|Backend System|
:Kích hoạt
GPS tracking;
:Cập nhật vị trí
Rescuer;

|Mobile App|
:Hiển thị vị trí
Rescuer trên bản đồ
(FE-24);
:Tính thời gian
ước tính (FE-26);

|Patient|
:Theo dõi Rescuer
di chuyển;
:Nhận thông báo
"Đội cứu hộ cách
bạn 5 phút" (FE-25);

|Snake Rescuer|
:Đến nơi;
:Cập nhật trạng thái
"Đã đến" (FE-20);

|Mobile App|
:Thông báo cho
Patient;

|Patient|
:Nhận thông báo
đội cứu hộ đã đến;

|Snake Rescuer|
:Gặp gỡ Patient;
:Khảo sát vị trí
rắn xuất hiện;
:Cập nhật trạng thái
"Đang xử lý" (FE-07);
:Thực hiện bắt rắn;
note right
  Áp dụng quy trình
  an toàn theo hướng dẫn
end note

:Bắt rắn thành công;
:Chụp ảnh rắn
đã bắt (FE-16);
:Xác nhận lại
loài rắn;
:Cập nhật trạng thái
"Hoàn thành" (FE-07);

|Backend System|
:Lưu thông tin
vào database (FE-15);
note right
  Lưu:
  - Vị trí
  - Thời gian
  - Loài rắn
  - Kết quả xử lý
end note

|Mobile App|
:Thông báo cho
Patient;

|Patient|
:Nhận thông báo
hoàn thành;
note right
  Chuyển sang
  Giai đoạn 2.4
end note

stop
@enduml
```

---

### 2.4. GIAI ĐOẠN 4: THANH TOÁN VÀ ĐÁNH GIÁ

**PlantUML Code:**

```plantuml
@startuml Stage-4-Payment-Rating
title GIAI ĐOẠN 2.4 - THANH TOÁN VÀ ĐÁNH GIÁ

|Snake Rescuer|
start
:Đánh dấu
"Hoàn thành nhiệm vụ";

|Backend System|
:Tạo hóa đơn
thanh toán;
note right
  Hóa đơn:
  - Phí cứu hộ
  - Phí nền tảng (10%)
  - Tổng cộng
end note

|Mobile App|
:Gửi thông báo
đến Patient;
note right
  "Cứu hộ hoàn tất.
  Vui lòng thanh toán
  và đánh giá."
end note

|Patient|
:Nhận thông báo;
:Xem hóa đơn;
:Chọn phương thức
thanh toán (FE-28);
note right
  Phương thức:
  - Momo
  - VNPay
  - ZaloPay
  - Thẻ tín dụng
end note

:Xác nhận thanh toán;

|Payment Gateway|
:Xử lý thanh toán;
:Trả về kết quả;

|Backend System|
if (Thanh toán\nthành công?) then (yes)
  :Xác nhận thanh toán;
  :Phân chia tiền;
  note right
    Phân chia:
    - 85% → Rescuer (FE-26)
    - 10% → Phí nền tảng
    - 5% → Quỹ bảo hiểm
  end note
  
  |Mobile App|
  :Hiển thị form
  đánh giá;
  
  |Patient|
  :Đánh giá Rescuer;
  note right
    Đánh giá:
    - 1-5 sao
    - Nhận xét
  end note
  
  |Backend System|
  :Lưu đánh giá;
  :Cập nhật rating
  của Rescuer;
  :Gửi thông báo
  cho Rescuer;
  
  |Snake Rescuer|
  :Nhận thông báo
  thanh toán;
  note right
    "Bạn đã nhận được
    thanh toán XXX VNĐ"
  end note
  :Xem đánh giá
  từ khách hàng (FE-27);
  
  |Backend System|
  :Lưu vào lịch sử;
  note right
    Lưu vào:
    - Patient: Lịch sử dịch vụ (FE-30)
    - Rescuer: Lịch sử doanh thu (FE-25)
    - Admin: Báo cáo tài chính (FE-33)
  end note
  
else (no)
  :Thông báo lỗi
  thanh toán;
  
  |Mobile App|
  :Hiển thị lỗi
  cho Patient;
  
  |Patient|
  :Thử lại thanh toán
  hoặc đổi phương thức;
endif

stop
@enduml
```

---

## TÓM TẮT CÁC GIAI ĐOẠN

| Giai đoạn | Tên | Actors chính | Thời gian ước tính |
|-----------|-----|--------------|-------------------|
| **2.1** | Phát hiện và báo cáo rắn | Patient, Mobile App, AI System | 1-2 phút |
| **2.2** | Kết nối với đội cứu hộ | Backend System, Snake Rescuer | 2-5 phút |
| **2.3** | Thực hiện cứu hộ | Snake Rescuer, Patient, Backend | 15-60 phút |
| **2.4** | Thanh toán và đánh giá | Patient, Snake Rescuer, Payment Gateway | 2-3 phút |

---

## SWIMLANE DIAGRAM TỔNG HỢP (TẤT CẢ CÁC GIAI ĐOẠN)

### Phiên bản PlantUML đầy đủ

```plantuml
@startuml Complete-Rescue-Request-Flow
title YÊU CẦU CỨU HỘ RẮN - SWIMLANE DIAGRAM ĐẦY ĐỦ

|Patient|
start
:Phát hiện rắn;
:Mở app và báo cáo;
:Chụp ảnh rắn;
:Bổ sung thông tin;

|AI System|
:Phân tích và
nhận diện rắn;

|Mobile App|
:Hiển thị kết quả;
:Yêu cầu chọn
hành động;

|Patient|
:Chọn "Yêu cầu
cứu hộ";

|Backend System|
:Tìm kiếm Rescuer
phù hợp;
:Gửi thông báo
đến top 3 Rescuer;

|Snake Rescuer|
:Nhận thông báo;
:Chấp nhận yêu cầu;
:Chuẩn bị thiết bị;
:Di chuyển đến
địa điểm;
:Chia sẻ vị trí
real-time;

|Patient|
:Theo dõi Rescuer
trên bản đồ;

|Snake Rescuer|
:Đến nơi;
:Thực hiện bắt rắn;
:Hoàn thành;

|Patient|
:Thanh toán dịch vụ;
:Đánh giá Rescuer;

|Backend System|
:Xử lý thanh toán;
:Phân chia tiền;
:Lưu vào lịch sử;

|Snake Rescuer|
:Nhận thanh toán;
:Xem đánh giá;

stop
@enduml
```

---

## CHÚ THÍCH

### Actors (Vai trò)
- **Patient:** Người dùng phát hiện rắn và yêu cầu cứu hộ
- **Mobile App:** Ứng dụng di động SnakeAid
- **AI System:** Hệ thống AI nhận diện rắn
- **Backend System:** Hệ thống backend xử lý matching và thanh toán
- **Snake Rescuer:** Đội cứu hộ rắn chuyên nghiệp
- **Snake Expert:** Chuyên gia tư vấn về rắn (nếu cần)
- **Payment Gateway:** Cổng thanh toán (Momo, VNPay, ZaloPay)

### Các trường hợp đặc biệt
1. **Không tìm thấy Rescuer:** Hệ thống mở rộng bán kính tìm kiếm và tăng phí đề xuất
2. **Rescuer cần tư vấn Expert:** Chuyển sang Flow 3.2 để được hỗ trợ khẩn cấp
3. **Thanh toán thất bại:** Patient có thể thử lại hoặc đổi phương thức thanh toán
4. **Chỉ cảnh báo cộng đồng:** Không tính phí, chỉ gửi thông báo đến người dùng lân cận

### API Endpoints liên quan
- `POST /api/rescue/request` - Tạo yêu cầu cứu hộ
- `GET /api/rescue/find-rescuers` - Tìm đội cứu hộ phù hợp
- `POST /api/rescue/accept` - Rescuer chấp nhận yêu cầu
- `PUT /api/rescue/status` - Cập nhật trạng thái cứu hộ
- `POST /api/rescue/complete` - Đánh dấu hoàn thành
- `POST /api/payment/process` - Xử lý thanh toán
- `POST /api/rating/submit` - Gửi đánh giá

---

**Ghi chú:** Các feature code (FE-XX) tham chiếu đến file `Major-Features-Summary.md`
