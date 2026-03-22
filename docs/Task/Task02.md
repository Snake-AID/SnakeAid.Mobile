Context:
Trong #file:home_screen.dart có button "Cảnh báo khu vực". Cần implement full feature cho chức năng này.

🎯 Feature 1: Hiển thị bản đồ cảnh báo khu vực

Yêu cầu:

Tái sử dụng map component có sẵn từ #file:location_picker_dialog.dart.
Hiển thị tất cả các báo cáo cộng đồng (community reports) lên map.

API sử dụng:

GET /api/community-reports → lấy danh sách tất cả reports
GET /api/community-reports/{id} → lấy chi tiết khi cần

Xử lý:

Parse các field:
longitude, latitude → để đặt marker
snakeSpecies, riskLevel, isVenomous → để customize UI marker
Hiển thị marker dạng biển cảnh báo (warning sign):
Marker phải to, rõ ràng, dễ nhìn
Style chuyên nghiệp (ưu tiên màu cảnh báo: đỏ/vàng)
Có thể scale theo riskLevel
Khi click marker:
Hiển thị popup/bottom sheet gồm:
Tên người báo cáo (reporterName)
Loài rắn (commonName)
Mức độ nguy hiểm (riskLevel)
Ghi chú (notes)
Hình ảnh (imageUrl)


🎯 Feature 2: Báo cáo phát hiện rắn (Create Report)

UI yêu cầu:

Thêm button: "Báo cáo phát hiện rắn"
Khi click:
Mở form input (bottom sheet / screen mới)

Form gồm:

Chọn vị trí (map picker hoặc current location)
Notes (text)
Dropdown chọn loài rắn

API:

GET /api/snake-species → load danh sách loài rắn
GET /api/snake-species/{id} → khi cần detail
POST /api/community-reports → tạo report

Request body:

{
  "longitude": number,
  "latitude": number,
  "notes": string,
  "snakeSpeciesId": number
}

Yêu cầu:

Validate input đầy đủ
UI dropdown hiển thị:
commonName
Có thể kèm image preview
Sau khi tạo thành công:
Refresh lại map
Hiển thị marker mới ngay lập tức


🎯 Feature 3: Lịch sử báo cáo của user

Yêu cầu:

Mỗi user có trang "Lịch sử báo cáo"
Chỉ hiển thị report của chính user đó

Chức năng:

Xem danh sách report
Xem chi tiết
Update report:
PUT /api/community-reports/{id}
Delete report:
DELETE /api/community-reports/{id}

UI:

List dạng card
Hiển thị:
Loài rắn
Thời gian (createdAt)
Notes
Có nút Edit / Delete rõ ràng