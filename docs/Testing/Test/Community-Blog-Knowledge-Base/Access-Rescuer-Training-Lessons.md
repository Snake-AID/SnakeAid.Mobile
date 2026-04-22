# Access Rescuer Training Lessons

## Summary

| Field | Value |
|---|---|
| Feature | Access Rescuer Training Lessons |
| Test requirement | Verify the main rescuer training lesson flow from Home quick access "Bài học\nAn Toàn", including category tabs, list refresh, opening lesson detail, and read-state behavior |
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
| TC2901 | Open lesson module from Rescuer Home quick access | 1) Login as Rescuer<br>2) On Home, tap quick access "Bài học\nAn Toàn"<br>3) Observe screen | App navigates to lesson screen with title "Bài Học An Toàn" | Rescuer account is logged in and Home screen is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2902 | Verify lesson categories tab bar | 1) Open "Bài Học An Toàn"<br>2) Observe tabs and labels | Tab bar shows categories "Tất Cả", "An Toàn", "Bắt Rắn", "Sơ Cứu" | Lesson screen is opened | Pending |  |  | Pending |  |  | Pending |  |  | Main navigation behavior |
| TC2903 | Switch category tabs and verify filtered list | 1) Open lesson screen<br>2) Switch between category tabs<br>3) Observe list cards | Each tab displays corresponding lesson subset; list updates correctly by selected category | Lesson data exists in backend | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2904 | Refresh lesson list from app bar or pull-to-refresh | 1) Open lesson screen<br>2) Tap action "Làm mới" or pull down list<br>3) Observe reloading | Lesson list reloads successfully and updated data is reflected | Network is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2905 | Open lesson detail from lesson card | 1) Open any lesson card from list<br>2) Observe detail screen | App opens lesson detail with title/content and section "Nội Dung Bài Học" | At least one published lesson is available | Pending |  |  | Pending |  |  | Pending |  |  | Core read behavior |
| TC2906 | Verify lesson detail metadata and media handling | 1) Open lesson detail<br>2) Check updated date row<br>3) If video banner is shown, tap to open link | Detail shows metadata "Cập nhật: dd/MM/yyyy"; video banner is visible when URL exists and can be opened | Lesson detail is opened | Pending |  |  | Pending |  |  | Pending |  |  | Main detail behavior |
| TC2907 | Verify read-state update after opening lesson | 1) In lesson list, note unread indicator on one item<br>2) Open that lesson detail and go back<br>3) Observe lesson item state | Lesson is marked as read; unread indicator/dot is removed for the opened lesson | Lesson list contains unread items | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2908 | Validate empty/error fallback and retry | 1) Open lesson screen under empty data or API failure condition<br>2) Observe fallback UI<br>3) Tap "Thử lại" | App shows empty or error state properly; retry action "Thử lại" triggers re-fetch | Test environment can simulate empty dataset or API error | Pending |  |  | Pending |  |  | Pending |  |  |  |
