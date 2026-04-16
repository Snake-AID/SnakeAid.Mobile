# Trigger SOS Alarm

## Summary

| Field | Value |
|---|---|
| Feature | Trigger SOS Alarm (GPS, Symptoms, AI check) |
| Test requirement | Member kích hoạt SOS từ Home, hệ thống lấy GPS và mở tracking; hỗ trợ AI nhận diện rắn + báo cáo triệu chứng với các nhánh hợp lệ/không hợp lệ |
| Number of TCs | 10 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 10 | 0 |
| Round 2 | 0 | 0 | 10 | 0 |
| Round 3 | 0 | 0 | 10 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC1301 | Trigger SOS successfully from Home | 1) Login vai tro Member<br>2) Ở Home, nhấn giữ nút SOS theo hướng dẫn "Giữ 2 giây để kích hoạt"<br>3) Chờ loading "Đang kích hoạt SOS..."<br>4) Quan sát popup thành công | Popup hiển thị "SOS Đã Kích Hoạt!" với nội dung "Đang gửi cảnh báo khẩn cấp và tìm kiếm hỗ trợ gần bạn..."; có 2 nút "HỦY SOS" và "XEM CHI TIẾT" | Member đã đăng nhập; internet ổn định; GPS bật và cấp quyền vị trí | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1302 | Show error when GPS is unavailable during SOS activation | 1) Tắt GPS hoặc từ chối quyền vị trí<br>2) Từ Home, kích hoạt SOS<br>3) Theo dõi thông báo lỗi | Hệ thống không tạo incident; hiển thị lỗi "Không thể lấy vị trí hiện tại. Vui lòng kiểm tra GPS." | Member ở Home; quyền vị trí bị từ chối hoặc location service tắt | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1303 | Open Emergency Tracking from SOS success dialog | 1) Kích hoạt SOS thành công<br>2) Bấm "XEM CHI TIẾT"<br>3) Quan sát màn hình tracking | Điều hướng vào màn tracking SOS; khu vực quick actions hiển thị "Nhận dạng", "Triệu chứng", "Mức độ" | Có incident SOS active vừa tạo | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1304 | "HỦY SOS" on success dialog only closes dialog (does not cancel request) | 1) Kích hoạt SOS thành công để hiện popup<br>2) Bấm "HỦY SOS"<br>3) Kiểm tra trạng thái SOS ở Home/Tracking | Popup đóng lại; incident SOS vẫn còn active (không có hành vi cancel request ở bước này) | SOS popup đang mở sau khi tạo incident | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1305 | Open AI snake identification from tracking quick action | 1) Vào Emergency Tracking<br>2) Bấm quick action "Nhận dạng" (subtitle "AI Camera")<br>3) Quan sát màn hình đích | Mở màn "Nhận diện rắn"; có action "Tải ảnh lên", nút camera chụp ảnh, và link "Tôi không có ảnh rắn" | Có incident SOS active và đang ở tracking | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1306 | No-image AI path switches to location-based snake selection | 1) Ở màn "Nhận diện rắn", bấm "Tôi không có ảnh rắn"<br>2) Ở dialog "Chọn phương pháp xác minh khác", bấm "Chọn theo vị trí"<br>3) Quan sát màn hình đích | Điều hướng sang màn "Rắn thường gặp ở khu vực bạn"; hệ thống lấy GPS để tải danh sách rắn theo khu vực | Incident SOS còn hiệu lực; có quyền vị trí | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1307 | Select snake by location and continue to symptom report | 1) Tại màn chọn rắn theo vị trí, chọn 1 loài rắn<br>2) Xác nhận dialog "Đã xác nhận loài rắn"<br>3) Bấm "Tiếp theo: Báo cáo triệu chứng" (hoặc "Tiếp tục báo cáo triệu chứng" ở footer) | Điều hướng sang màn "Báo cáo triệu chứng" với incident hiện tại | Có dữ liệu danh sách rắn theo vị trí | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1308 | Block symptom analysis when no symptom is selected | 1) Mở màn "Báo cáo triệu chứng"<br>2) Không chọn triệu chứng nào<br>3) Bấm nút "Phân tích triệu chứng" | Hệ thống chặn submit và hiển thị cảnh báo "Vui lòng chọn ít nhất một triệu chứng" | Đang ở màn Symptom Report | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1309 | Analyze symptoms successfully and navigate to severity assessment | 1) Mở màn "Báo cáo triệu chứng"<br>2) Chọn >=1 triệu chứng<br>3) Bấm "Phân tích triệu chứng" (hoặc "Cập nhật triệu chứng" nếu đã có dữ liệu trước đó)<br>4) Chờ xử lý | Hiển thị loading "Đang phân tích triệu chứng..."; sau đó điều hướng tới màn "Đánh giá mức độ nghiêm trọng" | Incident SOS active; API symptom tracking hoạt động | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1310 | Report symptoms directly from tracking quick action | 1) Từ Emergency Tracking, bấm quick action "Triệu chứng" (subtitle "Báo cáo")<br>2) Chọn triệu chứng và bấm "Phân tích triệu chứng"<br>3) Quan sát kết quả điều hướng | Luồng direct-entry hoạt động đúng: vào Symptom Report cho incident hiện tại và chuyển sang Severity Assessment sau khi phân tích thành công | Có incident SOS active và đang ở tracking | Pending |  |  | Pending |  |  | Pending |  |  |  |