# Rescuer EnRoute & Arrived Tracking

## Summary

| Field | Value |
|---|---|
| Feature | Rescuer EnRoute & Arrived Tracking |
| Test requirement | Rescuer receives assigned mission, starts moving (EnRoute), updates arrival (Arrived), and the app reflects tracking state correctly |
| Number of TCs | 8 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 8 | 0 |
| Round 2 | 0 | 0 | 8 | 0 |
| Round 3 | 0 | 0 | 8 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC901 | Open assigned mission and verify start-move action | 1) Login as Rescuer<br>2) Open assigned snake catching job detail<br>3) Verify payment check section and primary action area | Primary action "BẮT ĐẦU DI CHUYỂN" is visible; when deposit is not confirmed, button remains disabled and payment hint is shown | A mission is assigned to current rescuer; request is in Assigned stage | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC902 | Start mission transitions to EnRoute screen | 1) Open assigned mission detail with deposit confirmed<br>2) Tap "BẮT ĐẦU DI CHUYỂN"<br>3) Wait for navigation | App starts mission and opens EnRoute screen with header text "ĐANG DI CHUYỂN" | Deposit is confirmed and missionId is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC903 | EnRoute screen shows navigation and call tools | 1) From EnRoute screen, inspect top controls<br>2) Tap navigation icon (external map)<br>3) Tap call icon when customer phone exists | External navigation can be launched; call action opens phone dialer; EnRoute screen remains stable | Mission is in EnRoute; request has destination and customer phone number | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC904 | Arrived action is gated by distance > 1 km | 1) Start in EnRoute while still far from destination (> 1 km)<br>2) Observe distance hint panel and action area | UI shows hint text similar to "Còn cách ... nút \"Đã đến nơi\" hiện trong vòng 1 km" and arrival action is not available for confirmation | Mission is EnRoute and live location is available with distance > 1 km | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC905 | Arrived action appears within 1 km | 1) Move/simulate location to within 1 km of destination<br>2) Observe EnRoute action area | Floating action "ĐÃ ĐẾN NƠI" appears and hint changes to "Bạn đã gần đến nơi! Bấm \"ĐÃ ĐẾN NƠI\" ở phía trên" | Mission is EnRoute and distance can be updated | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC906 | Arrival confirmation dialog displays correct actions | 1) Tap "ĐÃ ĐẾN NƠI"<br>2) Observe confirmation dialog content | Dialog title is "Xác nhận đến nơi" with question "Bạn đã đến vị trí của khách hàng?" and action buttons "Chưa đến" / "Đã đến nơi" | Rescuer is within arrival threshold and arrival button is visible | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC907 | Choosing "Chưa đến" keeps mission in EnRoute | 1) Open dialog "Xác nhận đến nơi"<br>2) Tap "Chưa đến" | Dialog closes; mission remains in EnRoute screen; no Arrived transition is applied | Arrival confirmation dialog is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC908 | Choosing "Đã đến nơi" transitions mission to Arrived flow | 1) Open dialog "Xác nhận đến nơi"<br>2) Tap "Đã đến nơi"<br>3) Wait for API update and screen transition<br>4) Reopen job list/detail to verify status labels | System calls arrived update, navigates to tracking flow, and mission status reflects Arrived (labels such as "Đã đến nơi" in job status) | Mission is EnRoute; arrived endpoint is reachable | Pending |  |  | Pending |  |  | Pending |  |  |  |
