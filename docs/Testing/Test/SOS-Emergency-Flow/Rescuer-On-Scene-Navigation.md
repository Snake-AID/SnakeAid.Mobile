# Rescuer On-Scene Navigation

## Summary

| Field | Value |
|---|---|
| Feature | Rescuer On-Scene Navigation |
| Test requirement | Rescuer follows live GPS navigation to the victim, handles off-route warnings, confirms arrival, and transitions to support flow; AI triage is out of scope |
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
| TC1501 | Open rescue navigation screen after accepting SOS mission | 1) Login as Rescuer<br>2) Open the accepted SOS mission<br>3) Enter the navigation screen | The navigation screen opens with full-screen map, SOS badge, victim marker, rescuer marker, and route polyline when route data is available | A valid SOS mission is assigned to the rescuer | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1502 | Verify live route and distance information are displayed | 1) Open the navigation screen<br>2) Observe the top information bar while GPS is active | The info bar shows turn-by-turn guidance and live distance/ETA such as "1.8 km • 6 phút"; when route data exists, the current instruction is displayed | GPS permission granted; route data available from mission provider | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1503 | Verify initial GPS loading overlay | 1) Open the navigation screen before the first GPS fix is available<br>2) Observe the screen state | A loading overlay appears with the text "Đang lấy vị trí của bạn..." until the initial position is acquired | Navigation screen is opened and GPS has not produced an initial fix yet | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1504 | Verify map follow and recenter behavior | 1) Open the navigation screen<br>2) Move the map manually with a gesture<br>3) Tap the follow/recenter control on the right side | Manual map movement disables follow mode; tapping the follow control recenters the map on the rescuer position | Navigation screen is active and GPS is updating rescuer location | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1505 | Show off-route warning when rescuer leaves route | 1) Simulate the rescuer moving away from the route polyline<br>2) Keep the screen active and wait for off-route check | The info bar switches to warning state with red styling and text "Đang đi sai đường!"; the distance line shows "Ngoài tuyến đường" | Route polyline exists and rescuer position updates are available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1506 | Clear off-route warning when rescuer returns to route | 1) Trigger the off-route warning first<br>2) Move the rescuer position back onto the planned route | The warning state is cleared and the info bar returns to normal navigation state | Off-route warning was previously shown | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1507 | Verify arrival button is shown on navigation screen | 1) Open the navigation screen<br>2) Observe the bottom action area | The main orange button "Đã đến nơi" is visible in the bottom sheet; when the user is far away it still shows the arrival state used by the current test configuration | Navigation screen is active | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1508 | Open arrival confirmation dialog | 1) Tap "Đã đến nơi" on the navigation screen<br>2) Observe the modal dialog | The dialog title is "Xác Nhận Đã Đến Nơi?" and it shows the warning text "Đảm bảo bạn đã ở đúng vị trí trước khi xác nhận" | Navigation screen is active and arrival button is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1509 | Confirm arrival and navigate to support screen | 1) Open the arrival confirmation dialog<br>2) Tap "Xác nhận"<br>3) Wait for the loading indicator to complete | Arrival status is submitted successfully and the app navigates to the rescuer support screen | Mission provider accepts arrival update successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1510 | Cancel arrival confirmation without status change | 1) Open the arrival confirmation dialog<br>2) Tap "Chưa đến" | The dialog closes and the mission remains on the navigation screen without updating arrival status | Arrival confirmation dialog is open | Pending |  |  | Pending |  |  | Pending |  |  |  |