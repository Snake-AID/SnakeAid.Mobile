# MAIN FLOW - HỆ THỐNG SNAKEAID

## Thông tin dự án
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Mục đích:** Xác định luồng chính của hệ thống cho các tình huống sử dụng quan trọng

---

## 1. LUỒNG CHÍNH: XỬ LÝ SỰ CỐ RẮN CẮN KHẨN CẤP

### 1.1. Giai đoạn phát hiện và xử lý ban đầu (Patient)

**Flow 1.1: Khi người dùng bị rắn cắn**

```
Bước 1: Người dùng mở ứng dụng SnakeAid
    ↓
Bước 2: Chọn chức năng "Tôi bị rắn cắn - Cần trợ giúp khẩn cấp"
    ↓
Bước 3: Hệ thống hiển thị hướng dẫn sơ cứu ngay lập tức
    - FE-01: Hướng dẫn băng ép từng bước
    - FE-02: Hình ảnh minh họa cách băng ép đúng
    - FE-03: Cảnh báo hành động cấm kỵ (KHÔNG rạch vết thương, KHÔNG hút độc)
    ↓
Bước 4: Người dùng thực hiện sơ cứu theo hướng dẫn
    ↓
Bước 5: Hệ thống yêu cầu chụp ảnh rắn (nếu có thể)
    ↓
Bước 6A: Nếu có ảnh rắn
    → AI nhận diện loài rắn (FE-12)
    → Hiển thị kết quả: Tên, độc tính, mức độ nguy hiểm (FE-13)
    → Đề xuất biện pháp sơ cứu phù hợp (FE-14)
    ↓
Bước 6B: Nếu không có ảnh rắn
    → Chuyển sang bước 7
    ↓
Bước 7: Yêu cầu chụp ảnh vết cắn và nhập triệu chứng
    - FE-09: Nhập mô tả triệu chứng (đau, sưng, tê, buồn nôn...)
    - FE-10: Chụp ảnh vết cắn
    ↓
Bước 8: AI đánh giá mức độ nghiêm trọng (FE-15)
    → Phân loại: Nhẹ / Trung bình / Nặng / Nguy kịch (FE-17)
    ↓
Bước 9A: Nếu mức độ NẶNG hoặc NGUY KỊCH
    → Hệ thống tự động cảnh báo khẩn cấp (FE-16)
    → Hiển thị nút "GỌI CẤP CỨU NGAY" nổi bật
    → Chuyển sang Flow 1.2
    ↓
Bước 9B: Nếu mức độ NHẸ hoặc TRUNG BÌNH
    → Hiển thị hướng dẫn tiếp tục sơ cứu
    → Đề xuất tìm cơ sở y tế gần nhất
    → Chuyển sang Flow 1.3
```

### 1.2. Giai đoạn gọi cấp cứu và chia sẻ vị trí

**Flow 1.2: Kích hoạt SOS và gọi cấp cứu**

```
Bước 1: Người dùng nhấn nút SOS (FE-04)
    ↓
Bước 2: Hệ thống tự động:
    - Lấy vị trí GPS hiện tại
    - Gọi trực tiếp đến đường dây nóng cấp cứu 115
    - Gửi tin nhắn SMS chứa tọa độ GPS đến 115
    ↓
Bước 3: Hệ thống chia sẻ vị trí real-time (FE-05)
    - Gửi link theo dõi vị trí cho cấp cứu
    - Kích hoạt chế độ theo dõi liên tục
    ↓
Bước 4: Hệ thống gửi thông tin bổ sung:
    - Kết quả nhận diện rắn (nếu có)
    - Ảnh vết cắn
    - Triệu chứng đã ghi nhận
    - Mức độ nghiêm trọng từ AI
    ↓
Bước 5: Hiển thị màn hình chờ cấp cứu:
    - Timer đếm thời gian
    - Nút "Hủy cuộc gọi" (nếu tình hình thay đổi)
    - Tiếp tục hiển thị hướng dẫn sơ cứu
    ↓
Bước 6: Đồng thời gửi thông báo cho người thân (nếu đã cấu hình)
```

### 1.3. Giai đoạn tìm cơ sở điều trị gần nhất

**Flow 1.3: Định vị bệnh viện có huyết thanh**

```
Bước 1: Người dùng chọn "Tìm bệnh viện gần nhất"
    ↓
Bước 2: Hệ thống lấy vị trí GPS hiện tại
    ↓
Bước 3: Truy vấn database cơ sở điều trị (FE-06)
    - Lọc các bệnh viện/trạm y tế có huyết thanh kháng nọc
    - Ưu tiên cơ sở trong bán kính 20km
    - Sắp xếp theo khoảng cách
    ↓
Bước 4: Hiển thị bản đồ với danh sách cơ sở y tế
    - FE-07: Tính khoảng cách và thời gian ước tính
    - FE-08: Hiển thị loại huyết thanh có sẵn tại mỗi cơ sở
    - Đánh dấu cơ sở mở cửa 24/7
    ↓
Bước 5: Người dùng chọn một cơ sở
    ↓
Bước 6: Hệ thống cung cấp:
    - Nút "Chỉ đường" (mở Google Maps/Apple Maps)
    - Số điện thoại để gọi trước
    - Thông tin chi tiết về cơ sở
    ↓
Bước 7: Lưu lịch sử vào hồ sơ sức khỏe (FE-11)
```

---

## 2. LUỒNG CHÍNH: YÊU CẦU CỨU HỘ RẮN

### 2.1. Giai đoạn phát hiện và báo cáo rắn (Patient)

**Flow 2.1: Báo cáo phát hiện rắn**

```
Bước 1: Người dùng phát hiện rắn (chưa bị cắn)
    ↓
Bước 2: Mở ứng dụng → Chọn "Báo cáo phát hiện rắn"
    ↓
Bước 3: Chụp ảnh rắn (có thể nhiều góc độ)
    ↓
Bước 4: Hệ thống tự động lấy vị trí GPS (FE-18)
    ↓
Bước 5: Người dùng bổ sung thông tin:
    - Vị trí cụ thể (trong nhà/ngoài trời/vườn...)
    - Kích thước ước tính
    - Mô tả hành vi rắn
    - Mức độ khẩn cấp (Rắn đang trong nhà / Khu vực đông người)
    ↓
Bước 6: AI phân tích ảnh và đưa ra nhận định sơ bộ:
    - Loài rắn có thể (FE-12)
    - Độc tính (FE-13)
    - Mức độ nguy hiểm
    ↓
Bước 7: Hiển thị 2 lựa chọn:
    [A] Yêu cầu đội cứu hộ đến bắt rắn (có phí)
    [B] Chỉ cảnh báo cộng đồng (miễn phí)
    ↓
Bước 8A: Nếu chọn [A] → Chuyển sang Flow 2.2
Bước 8B: Nếu chọn [B] → Gửi cảnh báo (FE-20) → Kết thúc
```

### 2.2. Giai đoạn kết nối với đội cứu hộ (Matching)

**Flow 2.2: Phân công đội cứu hộ**

```
Bước 1: Hệ thống nhận yêu cầu cứu hộ từ Patient
    ↓
Bước 2: Hệ thống xác định:
    - Vị trí GPS của yêu cầu
    - Mức độ khẩn cấp
    - Loại rắn (từ AI)
    ↓
Bước 3: Tìm kiếm Snake Rescuer phù hợp:
    - Đang online trong bán kính 10km
    - Có kinh nghiệm với loài rắn này
    - Đánh giá tốt từ khách hàng trước
    - Sắp xếp theo: Khoảng cách → Rating → Thời gian phản hồi
    ↓
Bước 4: Gửi thông báo đến top 3 Snake Rescuer (FE-01)
    - Thông tin vị trí
    - Ảnh rắn và kết quả AI
    - Mức phí đề xuất
    - Thời gian chấp nhận: 2 phút
    ↓
Bước 5A: Nếu có Rescuer chấp nhận trong 2 phút
    → Chuyển sang Flow 2.3
    ↓
Bước 5B: Nếu không có ai chấp nhận sau 2 phút
    → Mở rộng bán kính lên 20km
    → Gửi thông báo cho top 5 Rescuer tiếp theo
    → Tăng mức phí đề xuất 20%
    ↓
Bước 5C: Nếu vẫn không có ai sau 5 phút
    → Thông báo cho Patient: "Không tìm thấy đội cứu hộ"
    → Đề xuất: Gọi trung tâm kiểm soát động vật hoặc 115
```

### 2.3. Giai đoạn thực hiện cứu hộ (Rescuer)

**Flow 2.3: Quá trình cứu hộ rắn**

```
Bước 1: Snake Rescuer chấp nhận yêu cầu (FE-06)
    ↓
Bước 2: Hệ thống tự động:
    - Thông báo cho Patient: "Đã tìm thấy đội cứu hộ"
    - Hiển thị thông tin Rescuer (tên, ảnh, rating, SĐT)
    - Kích hoạt chế độ theo dõi real-time
    ↓
Bước 3: Rescuer chuẩn bị:
    - Xem lại ảnh rắn và kết quả AI (FE-21)
    - Đọc hướng dẫn an toàn cho loài này (FE-09, FE-10)
    - Chuẩn bị thiết bị (FE-23)
    - Nếu không chắc chắn → Liên hệ Expert (FE-12) → Chuyển sang Flow 3.2
    ↓
Bước 4: Rescuer bắt đầu di chuyển
    - Cập nhật trạng thái: "Đang trên đường" (FE-07)
    - Bật chia sẻ vị trí real-time (FE-18)
    ↓
Bước 5: Patient theo dõi trên bản đồ
    - FE-24: Xem vị trí Rescuer di chuyển
    - FE-25: Nhận thông báo "Đội cứu hộ cách bạn 5 phút"
    - FE-26: Xem lộ trình và thời gian ước tính
    ↓
Bước 6: Rescuer đến nơi
    - Cập nhật trạng thái: "Đã đến" (FE-20)
    - Patient nhận thông báo
    ↓
Bước 7: Rescuer thực hiện bắt rắn
    - Cập nhật trạng thái: "Đang xử lý" (FE-07)
    - Áp dụng quy trình an toàn
    ↓
Bước 8: Sau khi bắt xong
    - Chụp ảnh rắn đã bắt (FE-16)
    - Xác nhận lại loài rắn
    - Cập nhật trạng thái: "Hoàn thành" (FE-07)
    ↓
Bước 9: Lưu thông tin vào database
    - FE-15: Ghi nhận chi tiết (vị trí, thời gian, loài rắn, kết quả)
    - Cập nhật database rắn của Admin
    ↓
Bước 10: Thanh toán và đánh giá → Chuyển sang Flow 2.4
```

### 2.4. Giai đoạn thanh toán và đánh giá

**Flow 2.4: Hoàn tất giao dịch**

```
Bước 1: Rescuer đánh dấu "Hoàn thành nhiệm vụ"
    ↓
Bước 2: Hệ thống gửi thông báo đến Patient:
    "Cứu hộ hoàn tất. Vui lòng thanh toán và đánh giá."
    ↓
Bước 3: Patient xác nhận và thanh toán (FE-28)
    - Hiển thị hóa đơn: Phí cứu hộ + Phí nền tảng (10%)
    - Phương thức: Momo / VNPay / ZaloPay / Thẻ
    ↓
Bước 4: Sau khi thanh toán thành công
    → Patient đánh giá Rescuer (1-5 sao + Nhận xét)
    ↓
Bước 5: Hệ thống xử lý thanh toán:
    - 85% → Tài khoản Rescuer (FE-26)
    - 10% → Phí nền tảng
    - 5% → Quỹ bảo hiểm (cho Rescuer)
    ↓
Bước 6: Rescuer nhận thông báo:
    - "Bạn đã nhận được thanh toán XXX VNĐ"
    - Xem đánh giá từ khách hàng (FE-27)
    - Rating tổng thể được cập nhật
    ↓
Bước 7: Hệ thống lưu vào lịch sử:
    - Patient: Lịch sử dịch vụ đã sử dụng (FE-30)
    - Rescuer: Lịch sử doanh thu (FE-25)
    - Admin: Báo cáo tài chính (FE-33)
```

---

## 3. LUỒNG CHÍNH: TƯ VẤN CHUYÊN GIA

### 3.1. Giai đoạn yêu cầu tư vấn (Patient)

**Flow 3.1: Đặt lịch tư vấn với chuyên gia**

```
Bước 1: Patient truy cập "Tư vấn chuyên gia"
    ↓
Bước 2: Xem danh sách Snake Expert
    - Hiển thị: Tên, Chuyên môn, Rating, Phí tư vấn
    - Lọc theo: Chuyên ngành (Rắn độc Việt Nam / Rắn ngoại lai / Điều trị nọc độc)
    - Sắp xếp theo: Rating / Phí tư vấn
    ↓
Bước 3: Chọn một Expert
    ↓
Bước 4: Chọn loại tư vấn:
    [A] Tư vấn ngay (nếu Expert online) → FE-10
    [B] Đặt lịch tư vấn → Chọn ngày giờ
    ↓
Bước 5: Upload tài liệu cần tư vấn:
    - Ảnh rắn hoặc vết cắn
    - Mô tả vấn đề
    - Câu hỏi cụ thể
    ↓
Bước 6: Thanh toán phí tư vấn trước (FE-27)
    - Số tiền tạm giữ (escrow)
    - Chỉ chuyển cho Expert sau khi tư vấn xong
    ↓
Bước 7A: Nếu chọn [A] Tư vấn ngay
    → Expert nhận thông báo
    → Nếu chấp nhận → Bắt đầu chat/video call
    → Chuyển sang Flow 3.3
    ↓
Bước 7B: Nếu chọn [B] Đặt lịch
    → Expert nhận yêu cầu
    → Xác nhận lịch
    → Gửi lịch hẹn cho Patient
    → Gửi nhắc nhở trước 30 phút
```

### 3.2. Giai đoạn Rescuer xin hỗ trợ từ Expert

**Flow 3.2: Tư vấn khẩn cấp cho Rescuer**

```
Bước 1: Rescuer đang ở hiện trường, gặp khó khăn nhận diện rắn
    ↓
Bước 2: Trong app Rescuer, chọn "Yêu cầu hỗ trợ chuyên gia" (FE-12)
    ↓
Bước 3: Chụp ảnh/video rắn real-time (FE-14)
    ↓
Bước 4: Hệ thống tìm Expert đang online
    - Ưu tiên Expert chuyên về khu vực địa lý này
    - Gửi thông báo khẩn cấp đến top 3 Expert
    ↓
Bước 5: Expert nào phản hồi nhanh nhất sẽ được kết nối
    ↓
Bước 6: Bắt đầu tư vấn qua chat/video call (FE-11)
    - Expert xác định loài rắn
    - Tư vấn cách bắt an toàn
    - Cảnh báo rủi ro
    ↓
Bước 7: Sau khi tư vấn xong
    - Expert cập nhật kết quả vào hệ thống
    - Rescuer cảm ơn và kết thúc
    ↓
Bước 8: Thanh toán tự động:
    - Nền tảng trả phí cho Expert (không tính vào khách hàng)
    - Hoặc: Rescuer chia sẻ 10% phí cứu hộ cho Expert (nếu có thỏa thuận)
```

### 3.3. Giai đoạn tư vấn trực tuyến

**Flow 3.3: Buổi tư vấn giữa Patient và Expert**

```
Bước 1: Đến giờ hẹn, cả hai nhận thông báo
    ↓
Bước 2: Bắt đầu phiên tư vấn (FE-10)
    - Chat text
    - Hoặc Video call (nếu cần)
    ↓
Bước 3: Expert xem thông tin Patient đã gửi trước:
    - Ảnh rắn/vết cắn
    - Mô tả vấn đề
    - Câu hỏi
    ↓
Bước 4: Expert tư vấn:
    - Giải đáp thắc mắc
    - Đưa ra khuyến nghị
    - Có thể yêu cầu Patient cung cấp thêm ảnh/thông tin
    ↓
Bước 5: Expert có thể:
    - Cập nhật hướng dẫn sơ cứu (FE-07, FE-08)
    - Cung cấp thông tin về liều lượng huyết thanh (FE-09)
    - Khuyến nghị đến bệnh viện (nếu nghiêm trọng)
    ↓
Bước 6: Kết thúc buổi tư vấn
    - Expert đánh dấu "Hoàn thành" (FE-14)
    - Thời gian tư vấn được ghi nhận
    ↓
Bước 7: Hệ thống xử lý thanh toán:
    - Chuyển tiền từ escrow sang tài khoản Expert (FE-14)
    - Trừ phí nền tảng 10%
    - Xuất hóa đơn điện tử (FE-14)
    ↓
Bước 8: Patient đánh giá Expert
    - Rating 1-5 sao
    - Nhận xét
    ↓
Bước 9: Lưu vào lịch sử:
    - Patient: Lịch sử tư vấn (FE-30)
    - Expert: Doanh thu tháng này (FE-15, FE-16)
    - Admin: Thống kê số lượt tư vấn (FE-19)
```

---

## 4. LUỒNG CHÍNH: QUẢN TRỊ HỆ THỐNG (ADMIN)

### 4.1. Quản lý database loài rắn

**Flow 4.1: Cập nhật thông tin loài rắn**

```
Bước 1: Admin đăng nhập vào Admin Portal
    ↓
Bước 2: Truy cập "Quản lý Database Rắn"
    ↓
Bước 3: Chọn một trong các chức năng:
    [A] Thêm loài rắn mới
    [B] Chỉnh sửa thông tin loài rắn hiện có
    [C] Xóa loài rắn (nếu nhập nhầm)
    ↓
Bước 4: Với [A] Thêm mới (FE-05):
    - Tên khoa học (tiếng Latin)
    - Tên tiếng Việt
    - Tên địa phương (các vùng miền)
    - Độc tính: Có độc / Không độc / Độc nhẹ
    - Mức độ nguy hiểm: Thấp / Trung bình / Cao / Rất cao
    - Đặc điểm nhận dạng (màu sắc, hoa văn, kích thước)
    - Phân bố địa lý (Miền Bắc/Trung/Nam, tỉnh thành cụ thể)
    - Môi trường sống (rừng, đồng lúa, vườn nhà, suối...)
    - Hành vi (ban ngày/ban đêm, hiếu chiến/nhút nhát)
    ↓
Bước 5: Upload hình ảnh rắn (FE-06)
    - Tối thiểu 5 ảnh từ nhiều góc độ
    - Ảnh chất lượng cao để train AI
    - Gắn tag: Đầu, thân, đuôi, hoa văn
    ↓
Bước 6: Phân loại theo khu vực (FE-08)
    - Chọn các tỉnh/thành phố có rắn này
    - Đánh dấu mức độ phổ biến tại mỗi khu vực
    ↓
Bước 7: Lưu vào database
    ↓
Bước 8: Hệ thống tự động:
    - Đồng bộ dữ liệu mới với AI Model
    - Retrain mô hình nhận diện (nếu thêm nhiều ảnh mới)
    - Cập nhật cho tất cả ứng dụng (Patient, Rescuer, Expert)
    ↓
Bước 9: Admin kiểm tra kết quả:
    - Test nhận diện bằng ảnh mẫu
    - Xem độ chính xác của AI
```

### 4.2. Quản lý cơ sở điều trị

**Flow 4.2: Cập nhật thông tin bệnh viện**

```
Bước 1: Admin truy cập "Quản lý Cơ sở Điều trị"
    ↓
Bước 2: Chọn [Thêm mới] hoặc [Chỉnh sửa] (FE-09)
    ↓
Bước 3: Nhập thông tin bệnh viện:
    - Tên cơ sở
    - Địa chỉ chi tiết
    - Tọa độ GPS (hoặc chọn trên bản đồ)
    - Số điện thoại khẩn cấp
    - Email liên hệ
    ↓
Bước 4: Cập nhật thông tin huyết thanh (FE-10)
    - Danh sách các loại huyết thanh có sẵn:
      + Huyết thanh đa giá (polyvalent)
      + Huyết thanh kháng nọc rắn hổ mang
      + Huyết thanh kháng nọc rắn lục
      + Huyết thanh kháng nọc rắn hổ
      ...
    - Số lượng tồn kho (nếu cơ sở chia sẻ)
    - Ngày cập nhật cuối cùng
    ↓
Bước 5: Cấu hình thời gian hoạt động (FE-11)
    - Giờ mở cửa / đóng cửa các ngày trong tuần
    - Đánh dấu nếu mở cửa 24/7 (FE-12)
    - Lịch nghỉ lễ, tết
    ↓
Bước 6: Phân loại cơ sở:
    - Bệnh viện tuyến trung ương
    - Bệnh viện tỉnh
    - Trạm y tế huyện/xã
    - Phòng khám tư nhân
    ↓
Bước 7: Lưu vào database
    ↓
Bước 8: Hệ thống tự động đồng bộ với ứng dụng Patient:
    - Cập nhật bản đồ cơ sở điều trị
    - Người dùng sẽ thấy thông tin mới ngay lập tức
```

### 4.3. Giám sát hoạt động real-time

**Flow 4.3: Theo dõi hệ thống trên bản đồ**

```
Bước 1: Admin mở Dashboard "Giám sát Real-time"
    ↓
Bước 2: Hiển thị bản đồ tổng quan (FE-26)
    ↓
Bước 3: Bản đồ hiển thị:
    🔴 Các ca rắn cắn đang xử lý (đỏ)
    🟡 Các yêu cầu cứu hộ đang chờ (vàng)
    🟢 Các ca đã hoàn thành trong ngày (xanh lá)
    🔵 Vị trí các Rescuer đang online (xanh dương)
    ⚫ Vị trí các Expert đang online (đen)
    ↓
Bước 4: Admin có thể:
    - Click vào từng điểm để xem chi tiết
    - Theo dõi vị trí Rescuer di chuyển (FE-27)
    - Xem trạng thái nhiệm vụ (FE-27)
    - Xem thời gian phản hồi của từng Rescuer (FE-29)
    ↓
Bước 5: Xem biểu đồ nhiệt (Heat Map) (FE-28)
    - Các khu vực có nhiều sự cố rắn cắn nhất
    - Phân bố theo thời gian (ngày/tuần/tháng)
    - Loài rắn gây sự cố nhiều nhất
    ↓
Bước 6: Nếu phát hiện bất thường:
    - Một khu vực có quá nhiều sự cố trong ngày
    → Admin gửi cảnh báo cộng đồng (FE-22, FE-24)
    - Rescuer phản hồi chậm hoặc không chấp nhận yêu cầu
    → Admin liên hệ Rescuer hoặc tìm người thay thế
    - Hệ thống quá tải
    → Bật chế độ ưu tiên cho ca khẩn cấp
    ↓
Bước 7: Xuất báo cáo cuối ngày:
    - Tổng số ca xử lý
    - Thời gian phản hồi trung bình
    - Tỷ lệ hoàn thành
    - Doanh thu nền tảng
```

### 4.4. Quản lý tài chính

**Flow 4.4: Báo cáo và phân chia doanh thu**

```
Bước 1: Admin truy cập "Quản lý Tài chính"
    ↓
Bước 2: Thiết lập phí dịch vụ (FE-30)
    - Phí cứu hộ rắn đề xuất (theo loài, khu vực)
    - Phí tư vấn chuyên gia đề xuất
    - % hoa hồng nền tảng (mặc định 10%)
    - % chia cho Rescuer (mặc định 85%)
    - % quỹ bảo hiểm (mặc định 5%)
    ↓
Bước 3: Xem báo cáo doanh thu (FE-31, FE-33)
    - Tổng doanh thu hệ thống (theo ngày/tuần/tháng/năm)
    - Doanh thu từ cứu hộ rắn
    - Doanh thu từ tư vấn chuyên gia
    - Doanh thu theo từng Rescuer
    - Doanh thu theo từng Expert
    ↓
Bước 4: Quản lý thanh toán (FE-32)
    - Xem danh sách giao dịch chờ xử lý
    - Kiểm tra các khoản thanh toán đã hoàn thành
    - Xử lý các giao dịch lỗi
    ↓
Bước 5: Xử lý tranh chấp (FE-35)
    - Patient khiếu nại: "Rescuer không đến"
      → Admin kiểm tra lịch sử GPS
      → Nếu đúng → Hoàn tiền cho Patient
      → Nếu sai → Từ chối khiếu nại
    - Rescuer khiếu nại: "Patient không thanh toán"
      → Admin kiểm tra trạng thái thanh toán
      → Nhắc nhở Patient
      → Hoặc tự động trừ tiền nếu đã lưu thẻ
    ↓
Bước 6: Quản lý hoàn tiền (FE-34)
    - Duyệt yêu cầu hoàn tiền từ Patient
    - Hoàn tiền trong vòng 3-5 ngày làm việc
    - Cập nhật trạng thái cho người dùng
    ↓
Bước 7: Xuất báo cáo tài chính định kỳ (FE-33)
    - Báo cáo tháng
    - Báo cáo quý
    - Báo cáo năm
    - Gửi cho Ban Giám đốc
```

---

## 5. LUỒNG PHỤ: GIÁO DỤC VÀ PHÒNG NGỪA

### 5.1. Tra cứu thông tin rắn

**Flow 5.1: Người dùng tìm hiểu về rắn**

```
Bước 1: Patient mở phần "Kiến thức về rắn"
    ↓
Bước 2: Xem nội dung giáo dục (FE-21, FE-22, FE-23)
    - Bài viết: "10 loài rắn độc thường gặp ở Việt Nam"
    - Video: "Cách phòng tránh rắn cắn khi vào rừng"
    - FAQ: "Rắn hổ mang có nguy hiểm không?"
    - Infographic: "Phân biệt rắn độc và không độc"
    ↓
Bước 3: Tìm kiếm theo khu vực:
    - Chọn tỉnh/thành phố
    → Hệ thống hiển thị các loài rắn phổ biến ở đây
    → Đặc điểm nhận dạng
    → Mức độ nguy hiểm
    ↓
Bước 4: Đọc hướng dẫn phòng tránh:
    - Khi đi vào rừng
    - Khi làm vườn
    - Khi phát hiện rắn trong nhà
    - Cách bảo vệ trẻ em và vật nuôi
    ↓
Bước 5: Xem câu chuyện thực tế:
    - Các ca rắn cắn đã được xử lý thành công
    - Kinh nghiệm từ Rescuer
    - Lời khuyên từ Expert
```

### 5.2. Nhận cảnh báo khu vực

**Flow 5.2: Hệ thống cảnh báo chủ động**

```
Bước 1: Admin phát hiện một khu vực có nhiều sự cố rắn độc
    ↓
Bước 2: Admin tạo cảnh báo cộng đồng (FE-22, FE-24)
    - Tiêu đề: "Cảnh báo: Xuất hiện nhiều rắn hổ mang tại quận X"
    - Nội dung: Mô tả tình hình, khuyến nghị phòng tránh
    - Phạm vi: Chọn khu vực cảnh báo trên bản đồ
    ↓
Bước 3: Hệ thống gửi thông báo push (FE-25)
    - Đến tất cả Patient trong khu vực đó
    - Ưu tiên người có GPS hiện tại trong vùng nguy hiểm
    ↓
Bước 4: Patient nhận cảnh báo:
    - Notification trên điện thoại
    - Click vào → Xem chi tiết cảnh báo
    - Xem bản đồ vùng nguy hiểm
    - Đọc hướng dẫn phòng tránh
    ↓
Bước 5: Cảnh báo theo mùa (FE-23)
    - Mùa mưa: "Rắn thường vào nhà tránh lũ"
    - Mùa khô: "Rắn hay ra ruộng tìm nước"
    - Đầu hè: "Mùa sinh sản, rắn dễ tấn công"
    ↓
Bước 6: Lưu lịch sử cảnh báo
    - Patient có thể xem lại các cảnh báo cũ
    - Theo dõi tình hình khu vực của mình
```

---

## 6. SƠ ĐỒ TỔNG QUAN CÁC LUỒNG CHÍNH

```
┌─────────────────────────────────────────────────────────────────┐
│                    HỆ THỐNG SNAKEAID                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐          ┌─────────┐
   │ PATIENT │          │ RESCUER  │          │ EXPERT  │
   └─────────┘          └──────────┘          └─────────┘
        │                     │                     │
        │                     │                     │
   [1] Bị rắn cắn        [2] Nhận cảnh báo     [3] Xác minh
        │                     │                     │
        ├─► Sơ cứu           ├─► Chấp nhận         ├─► Tư vấn
        │                     │                     │
        ├─► Nhận diện AI      ├─► Di chuyển         ├─► Cập nhật DB
        │                     │                     │
        ├─► Gọi SOS           ├─► Bắt rắn           ├─► Nhận thanh toán
        │                     │                     │
        ├─► Tìm bệnh viện     ├─► Báo cáo           │
        │                     │                     │
        ├─► Yêu cầu cứu hộ    ├─► Nhận thanh toán   │
        │                     │                     │
        └─► Thanh toán        └───────┬─────────────┘
                                      │
                                      ▼
                              ┌─────────────┐
                              │    ADMIN    │
                              └─────────────┘
                                      │
                                      ├─► Quản lý User
                                      ├─► Quản lý DB Rắn
                                      ├─► Quản lý Bệnh viện
                                      ├─► Giám sát Real-time
                                      ├─► Cảnh báo Cộng đồng
                                      └─► Quản lý Tài chính
```

---

## 7. MA TRẬN TƯƠNG TÁC GIỮA CÁC MODULE

| Tình huống | Patient | Rescuer | Expert | Admin | AI System |
|------------|---------|---------|--------|-------|-----------|
| Rắn cắn khẩn cấp | Kích hoạt | - | (Nếu cần) | Giám sát | Nhận diện + Đánh giá |
| Cứu hộ rắn | Yêu cầu | Thực hiện | (Hỗ trợ) | Giám sát | Nhận diện sơ bộ |
| Tư vấn từ xa | Yêu cầu | - | Tư vấn | Giám sát | - |
| Cập nhật database | - | Góp ảnh | Xác minh | Quản lý | Học từ dữ liệu mới |
| Cảnh báo cộng đồng | Nhận | Nhận | - | Gửi | Phân tích xu hướng |
| Thanh toán | Trả tiền | Nhận tiền | Nhận tiền | Quản lý | - |

---

## 8. THỜI GIAN XỬ LÝ DỰ KIẾN

| Luồng | Thời gian dự kiến | Ghi chú |
|-------|-------------------|---------|
| Nhận diện rắn bằng AI | < 5 giây | Tùy chất lượng ảnh |
| Đánh giá mức độ nghiêm trọng | < 3 giây | AI xử lý |
| Tìm cơ sở điều trị gần nhất | < 2 giây | Truy vấn database |
| Tìm Rescuer phù hợp | < 30 giây | Tối đa 2 phút |
| Rescuer di chuyển đến hiện trường | 10-30 phút | Tùy khoảng cách |
| Bắt rắn | 5-20 phút | Tùy loài và tình huống |
| Tư vấn chuyên gia | 15-30 phút | Tùy độ phức tạp |
| Thanh toán qua cổng | < 10 giây | Nếu mạng ổn định |

---

## PHỤ LỤC: DANH SÁCH MÃ TÍNH NĂNG (FEATURE CODE)

### Patient Module
- FE-01 đến FE-30: Tất cả tính năng cho Patient

### Rescuer Module  
- FE-01 đến FE-27: Tất cả tính năng cho Rescuer

### Expert Module
- FE-01 đến FE-16: Tất cả tính năng cho Expert

### Admin Module
- FE-01 đến FE-35: Tất cả tính năng cho Admin

*(Xem chi tiết trong file `Major-Features-Summary.md`)*
