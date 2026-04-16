# Rescuer Mission Execution & Evidence Upload

## Summary

| Field | Value |
|---|---|
| Feature | Rescuer Mission Execution & Evidence Upload |
| Test requirement | Rescuer executes on-site mission, uploads evidence photos, confirms snake details and environment, then submits final mission result to customer |
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
| TC1001 | Open mission execution screen after Arrived | 1) Login as Rescuer<br>2) Open an assigned mission already at Arrived state<br>3) Enter mission execution screen | Screen title shows "Đang Bắt Rắn" with processing badge "ĐANG XỬ LÝ" | Mission status is Arrived and belongs to current rescuer | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1002 | Capture first evidence photo successfully | 1) On "Đang Bắt Rắn" screen, tap area "Chụp ảnh rắn sau khi bắt"<br>2) Capture one photo from camera<br>3) Wait for upload | Photo thumbnail appears, upload state completes, and progress label updates to "Đã tải 1/1" (or equivalent done count) | Camera permission granted and network available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1003 | Upload failure shows retry behavior | 1) Trigger a photo upload failure (unstable network / server error)<br>2) Observe snackbar and failed thumbnail overlay<br>3) Tap "Thử lại" on failed photo | Snackbar appears with "Tải ảnh thất bại. Nhấn ’Thử lại’ trên ảnh để upload lại.", then retry can set state back to uploaded | At least one captured photo exists and upload fails | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1004 | Complete button remains locked without uploaded photo | 1) Open "Đang Bắt Rắn" with no successful uploaded evidence<br>2) Observe bottom button state | Bottom button is disabled and text shows "CẦN ÍT NHẤT 1 ẢNH" | Rescuer has not uploaded any successful evidence photo | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1005 | Navigate to result confirmation after having uploaded photo | 1) Upload at least one evidence photo successfully<br>2) Tap bottom button "HOÀN THÀNH BẮT RẮN" | App navigates to screen "Xác Nhận Hoàn Thành" | At least one evidence photo is uploaded successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1006 | Add snake species entry with quantity | 1) In "Xác Nhận Hoàn Thành", tap picker "Chọn loài rắn đã bắt..."<br>2) Select one species<br>3) Set quantity<br>4) Tap "THÊM RẮN" then confirm in dialog "Xác nhận loài rắn" using button "Xác nhận" | Selected species is added to confirmed list with quantity badge (xN) and can be seen under confirmed snakes | Species list API available; mission is editable | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1007 | Delete confirmed snake entry | 1) Add at least one confirmed snake entry<br>2) Tap delete icon on that entry | Entry is removed from confirmed list (or error shown if backend reject), and UI list is updated | At least one mission detail entry exists | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1008 | Submit button validation requires snake + environment | 1) Open "Xác Nhận Hoàn Thành"<br>2) Case A: no confirmed snake -> observe button text<br>3) Case B: has snake but no environment -> observe button text | Button remains disabled and shows either "CẦN XÁC NHẬN ÍT NHẤT 1 LOÀI RẮN" or "CẦN CHỌN NƠI BẮT RẮN" accordingly | User is on result confirmation screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1009 | Submit mission result successfully | 1) Ensure at least one confirmed snake exists<br>2) Select environment in "Nơi bắt rắn" dropdown<br>3) Tap "GỬI KẾT QUẢ CHO KHÁCH HÀNG"<br>4) In confirmation dialog "Xác nhận gửi kết quả", tap "Gửi ngay" | Mission is completed successfully and app navigates to mission success screen | Confirmed snake list is not empty and catching environment is selected | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1010 | Cancel submit from confirmation dialog | 1) Prepare valid data to enable submit<br>2) Tap "GỬI KẾT QUẢ CHO KHÁCH HÀNG"<br>3) In dialog, tap "Kiểm tra lại" | Dialog closes, mission is not submitted yet, and user remains on "Xác Nhận Hoàn Thành" for editing | Submit conditions are valid and dialog is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
