# Read Community Report

## Summary

| Field | Value |
|---|---|
| Feature | Read Community Report |
| Test requirement | Member opens community snake alerts, filters map data by risk/province, reads marker details, and reviews personal report history in read-only scenarios |
| Number of TCs | 11 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 11 | 0 |
| Round 2 | 0 | 0 | 11 | 0 |
| Round 3 | 0 | 0 | 11 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC2400 | Setup: Create sample community report for read validation | 1) Login as Member<br>2) Open "Cảnh báo\nkhu vực"<br>3) Tap "Báo cáo phát hiện rắn"<br>4) In "Báo cáo phát hiện rắn", pick location "Vị trí phát hiện *"<br>5) (Optional) choose species and enter notes<br>6) Submit report | A new community report is created successfully and can be used as test data for map/detail/history read test cases | Member account is logged in and has location permission | Pending |  |  | Pending |  |  | Pending |  |  | Setup data for TC2401-TC2410 |
| TC2401 | Open community alert map from member home menu | 1) Login as Member<br>2) Go to Home screen<br>3) Tap menu tile "Cảnh báo\nkhu vực" | App opens map screen with title "Cảnh báo khu vực" | Member account is logged in and Home menu is visible | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2402 | Verify initial loading and alert counter in top bar | 1) Open "Cảnh báo khu vực"<br>2) Wait for loading to complete<br>3) Observe top counter badge and markers | Screen loads alert reports; top badge shows "{n} điểm cảnh báo" or filtered count format, and markers are shown when reports exist | Network is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2403 | Refresh map data using top action | 1) Open map screen<br>2) Tap top action "Làm mới"<br>3) Observe loading indicator and updated data | Refresh action re-fetches reports and updates marker/count data without leaving screen | Map screen is already open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2404 | Filter alerts by risk level chips | 1) Open map with available data<br>2) Tap chips "🔴 Cực kỳ", "🟠 Cao", "🟡 Trung bình", "🟢 Thấp"<br>3) Tap "Tất cả" | Marker list and count update according to selected chip; selected chip changes visual active state correctly | At least one alert report exists | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2405 | Filter map by province and clear province selection | 1) Tap FAB "Chọn tỉnh"<br>2) In sheet "Chọn tỉnh / thành phố", select one province<br>3) Observe map recenter<br>4) Tap close icon on selected province chip | Map recenters to selected province; selected province chip is shown; clearing chip removes province filter and returns broader map scope | Map screen is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2406 | Open and read report detail sheet from marker | 1) Tap any warning marker on map<br>2) Observe bottom sheet content | Detail sheet shows risk badge, venom badge (when applicable), reporter info, notes, time, and coordinates; user can read all fields | There is at least one marker on the map | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2407 | Copy coordinates from detail sheet | 1) Open report detail sheet<br>2) Tap "Sao chép tọa độ" | Coordinates are copied and snackbar appears with "Tọa độ đã sao chép: ..." | A report detail sheet is opened | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2408 | Open legend and verify risk explanation | 1) Tap info FAB "Chú thích"<br>2) Review legend content | Legend sheet appears and displays risk levels ("Cực kỳ nguy hiểm", "Nguy hiểm cao", "Trung bình", "Nguy hiểm thấp") plus guidance text | Map screen is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2409 | Open personal report history and read report cards | 1) From map screen, tap top action "Của tôi"<br>2) Observe "Lịch sử báo cáo của tôi"<br>3) Pull to refresh or tap refresh icon | History screen lists member reports with snake name, time, risk label, notes preview, and coordinates; refresh reloads list successfully | Member has at least one community report | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2410 | Verify read-flow fallback states (empty/error/retry) | 1) Open map/history under no-data or API-failure condition<br>2) Observe UI fallback<br>3) Tap "Thử lại" where shown | App shows proper fallback states such as "Chưa có báo cáo nào" or error banner; retry action attempts data reload and keeps user in flow | Test environment can simulate empty dataset or network/API error | Pending |  |  | Pending |  |  | Pending |  |  |  |
