# Trigger SOS Alarm

## Summary

| Field | Value |
|---|---|
| Feature | Trigger SOS Alarm (GPS, Symptoms, AI check) |
| Test requirement | Member triggers SOS from Home, system captures GPS and opens tracking; supports AI snake identification and symptom reporting with valid/invalid branches |
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
| TC1301 | Trigger SOS successfully from Home | 1) Sign in as Member<br>2) On Home, press and hold the SOS button following the hint "Giữ 2 giây để kích hoạt"<br>3) Wait for loading "Đang kích hoạt SOS..."<br>4) Verify success popup | Popup shows "SOS Đã Kích Hoạt!" with message "Đang gửi cảnh báo khẩn cấp và tìm kiếm hỗ trợ gần bạn..." and 2 buttons: "HỦY SOS" and "XEM CHI TIẾT" | Member is logged in; stable internet; GPS is on and location permission is granted | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1302 | Show error when GPS is unavailable during SOS activation | 1) Disable GPS or deny location permission<br>2) Trigger SOS from Home<br>3) Observe error feedback | System does not create an incident and shows error "Không thể lấy vị trí hiện tại. Vui lòng kiểm tra GPS." | Member is on Home; location permission denied or location service disabled | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1303 | Open Emergency Tracking from SOS success dialog | 1) Trigger SOS successfully<br>2) Tap "XEM CHI TIẾT"<br>3) Verify destination screen | App navigates to SOS tracking screen; quick actions area shows "Nhận dạng", "Triệu chứng", "Mức độ" | A new active SOS incident exists | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1304 | "HỦY SOS" on success dialog only closes dialog (does not cancel request) | 1) Trigger SOS and wait for success popup<br>2) Tap "HỦY SOS"<br>3) Verify SOS state in Home/Tracking | Popup is closed only; SOS incident remains active (no cancellation at this step) | SOS success popup is open after incident creation | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1305 | Open AI snake identification from tracking quick action | 1) Open Emergency Tracking<br>2) Tap quick action "Nhận dạng" (subtitle "AI Camera")<br>3) Verify target screen | App opens "Nhận diện rắn" screen with "Tải ảnh lên", camera capture control, and "Tôi không có ảnh rắn" link | Active SOS incident exists and user is on tracking screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1306 | No-image AI path switches to location-based snake selection | 1) On "Nhận diện rắn", tap "Tôi không có ảnh rắn"<br>2) On dialog "Chọn phương pháp xác minh khác", tap "Chọn theo vị trí"<br>3) Verify destination | App navigates to "Rắn thường gặp ở khu vực bạn" and fetches snake list by GPS | SOS incident is still active; location permission is granted | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1307 | Select snake by location and continue to symptom report | 1) On location-based snake screen, select one snake<br>2) Confirm dialog "Đã xác nhận loài rắn"<br>3) Tap "Tiếp theo: Báo cáo triệu chứng" (or "Tiếp tục báo cáo triệu chứng" in footer) | App navigates to "Báo cáo triệu chứng" for the current incident | Snake list by location is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1308 | Block symptom analysis when no symptom is selected | 1) Open "Báo cáo triệu chứng" screen<br>2) Select no symptoms<br>3) Tap "Phân tích triệu chứng" | Submit is blocked and warning "Vui lòng chọn ít nhất một triệu chứng" is shown | User is on Symptom Report screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1309 | Analyze symptoms successfully and navigate to severity assessment | 1) Open "Báo cáo triệu chứng" screen<br>2) Select at least 1 symptom<br>3) Tap "Phân tích triệu chứng" (or "Cập nhật triệu chứng" when existing symptoms are preloaded)<br>4) Wait for processing | Loading "Đang phân tích triệu chứng..." is shown, then app navigates to "Đánh giá mức độ nghiêm trọng" | SOS incident is active; symptom tracking API is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1310 | Report symptoms directly from tracking quick action | 1) From Emergency Tracking, tap quick action "Triệu chứng" (subtitle "Báo cáo")<br>2) Select symptoms and tap "Phân tích triệu chứng"<br>3) Verify navigation result | Direct-entry flow works: opens Symptom Report for current incident and then navigates to Severity Assessment after successful analysis | Active SOS incident exists and user is on tracking screen | Pending |  |  | Pending |  |  | Pending |  |  |  |