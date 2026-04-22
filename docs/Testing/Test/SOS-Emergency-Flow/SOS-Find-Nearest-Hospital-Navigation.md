# SOS Find Nearest Hospital

## Summary

| Field | Value |
|---|---|
| Feature | SOS Find Nearest Hospital (Navigation) |
| Test requirement | Rescuer searches for the nearest hospital, filters the list, opens directions/call actions, and confirms transfer-to-hospital flow; AI triage is out of scope |
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
| TC1601 | Open the hospital finder from support screen | 1) Login as Rescuer<br>2) Open the support screen after arrival<br>3) Tap "Tìm bệnh viện"<br>4) Verify the next screen | App opens "Tìm bệnh viện" screen with map, search bar, and hospital list | Rescuer is in support flow and the mission has a valid incident/location | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1602 | Verify current location and loading state on hospital screen | 1) Open "Tìm bệnh viện"<br>2) Observe location loading behavior<br>3) Wait until hospitals are loaded | The screen shows current-location handling; when data is not ready it shows loading or error states, and when ready it shows nearby hospitals | Location permission is granted or can be requested successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1603 | Verify search bar and location shortcut | 1) Open hospital screen<br>2) Observe the search area<br>3) Tap "Dùng vị trí của tôi" | Search field shows placeholder "Tìm theo tên hoặc vị trí..." and tapping "Dùng vị trí của tôi" refreshes the current location flow | Hospital screen is open and location permission is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1604 | Verify map markers and hospital list are synchronized | 1) Open hospital screen with loaded data<br>2) Tap a hospital marker on the map<br>3) Observe the selected card in the list | Selected hospital is highlighted on the map and in the list | Hospitals are loaded with current location | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1605 | Verify hospital list shows the expected action buttons | 1) Open a hospital card in the list<br>2) Inspect available actions | Each hospital card shows action buttons such as "Chỉ đường" or "Chọn bệnh viện" depending on selection state, and "Gọi BV" | At least one hospital is visible in the list | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1606 | Select hospital and confirm transfer to hospital | 1) Tap a hospital card or marker<br>2) Wait for the selection flow to complete<br>3) Observe the result dialog | Dialog shows "Đã chọn bệnh viện" and confirms the transfer request was recorded | Hospital data and route calculation are available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1607 | Start navigation to the selected hospital | 1) After selecting a hospital, tap "Bắt đầu chỉ đường"<br>2) Observe external navigation | Google Maps opens with the destination hospital coordinates | A hospital has already been selected successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1608 | Show error when Google Maps cannot be opened | 1) Select a hospital<br>2) Block external map launch or simulate app-link failure<br>3) Tap "Bắt đầu chỉ đường" | Snackbar shows "Không thể mở Google Maps" and the app stays on the hospital screen | Hospital selection is complete; external maps cannot be launched | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1609 | Show error when no hospital is selected before completion | 1) Open hospital screen<br>2) Do not select any hospital<br>3) Tap the bottom completion action | Snackbar shows "Vui lòng chọn bệnh viện trước" and no completion dialog is opened | Hospital screen is open and nothing is selected | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1610 | Complete support flow after hospital transfer confirmation | 1) Select a hospital<br>2) Open the completion confirmation dialog via the bottom action<br>3) Tap "Xác nhận" after reading "Hoàn thành hỗ trợ?" | App shows the confirmation flow and then navigates to the mission completion screen | Hospital selection is already available and transfer flow is active | Pending |  |  | Pending |  |  | Pending |  |  |  |