# Confirm AI Snake Detection Image (Expert)

## Summary

| Field | Value |
|---|---|
| Feature | Confirm AI Snake Detection Image (Expert) |
| Test requirement | Verify the main AI recognition review flow for experts from Expert Home Profile tab, including queue access, detail review, confirm, reject, and history view |
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
| TC2601 | Open AI review queue from Expert Home Profile tab | 1) Login as Expert<br>2) Open Expert Home<br>3) Switch to Profile tab<br>4) Tap menu "Xem Xét AI Nhận Diện" | App navigates to AI queue screen successfully | Expert account is logged in | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2602 | Verify queue screen structure and tabs | 1) Open AI queue screen<br>2) Observe title and top area<br>3) Check tabs | Screen shows title "Xem Xét AI Nhận Diện" with tabs "Hàng Đợi" and "Đã Xử Lý"; pending badge is shown when queue has items | AI queue screen is opened | Pending |  |  | Pending |  |  | Pending |  |  | Main UI behavior |
| TC2603 | Refresh queue list and handle empty or error state | 1) Open "Hàng Đợi" tab<br>2) Pull to refresh<br>3) Observe empty/error fallback if applicable<br>4) Tap "Thử lại" when error appears | Queue data reloads on refresh; empty state shows "Không có ảnh cần xem xét"; error state shows retry action "Thử lại" | Network/API can be normal or intentionally unstable | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2604 | Open one queue item to review detail | 1) In "Hàng Đợi", tap one review card<br>2) Observe detail page | App opens review detail screen titled "Xem Xét Nhận Diện" with image, AI result, and action area | At least one queue item exists | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2605 | Validate confirm action requires species selection | 1) Open review detail<br>2) Do not choose corrected species<br>3) Tap "Xác nhận" action | Snackbar shows validation message "Vui lòng chọn loài rắn chính xác để xác nhận." and submit is blocked | Review detail screen is opened | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2606 | Confirm AI detection with corrected species | 1) Open review detail<br>2) Select corrected species<br>3) (Optional) enter notes<br>4) Submit confirm action | Success snackbar "Đã xác nhận loài rắn thành công!" appears; app returns to queue; processed item is removed from queue | Review detail screen is opened with a valid pending item | Pending |  |  | Pending |  |  | Pending |  |  | Core confirm behavior |
| TC2607 | Reject AI detection with confirmation dialog | 1) Open review detail<br>2) Tap reject action<br>3) In dialog "Từ chối ảnh?", tap "Từ chối" | Success snackbar "Đã từ chối ảnh." appears; app returns to queue; item is removed from pending queue | Review detail screen is opened with a valid pending item | Pending |  |  | Pending |  |  | Pending |  |  | Core reject behavior |
| TC2608 | Review processed results in history tab | 1) Open tab "Đã Xử Lý"<br>2) Pull to refresh<br>3) Observe list or empty state | Processed results are displayed in history list; if empty, UI shows "Chưa có lịch sử xem xét" | AI queue module is accessible by expert | Pending |  |  | Pending |  |  | Pending |  |  | Main history behavior |
