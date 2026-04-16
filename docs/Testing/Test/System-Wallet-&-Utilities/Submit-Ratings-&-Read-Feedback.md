# Submit Ratings & Read Feedback

## Summary

| Field | Value |
|---|---|
| Feature | Submit Ratings & Read Feedback |
| Test requirement | Verify member rating submission and feedback display across Catching and Consultation flows, including duplicate prevention, filters, sorting, pagination, empty/error states, and role-specific read screens |
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
| TC3301 | Member sees Catching feedback prompt when not yet reviewed | 1) Login as Member with a completed catching request assigned to a rescuer<br>2) Open activity detail screen for that request<br>3) Check feedback card section | Feedback card shows CTA button "Đánh giá ngay" and allows opening rating bottom sheet | Request has `assignedRescuer` and no existing feedback by current member for same `referenceId` | Pending |  |  | Pending |  |  | Pending |  |  | Catching submit entry |
| TC3302 | Catching feedback sheet enforces star selection before submit | 1) From activity detail, tap "Đánh giá ngay"<br>2) In bottom sheet, leave stars at 0 and type optional comment<br>3) Observe submit button state | Submit button "Gửi đánh giá" is disabled until user selects at least 1 star | Member is on Catching feedback sheet | Pending |  |  | Pending |  |  | Pending |  |  | Client-side validation |
| TC3303 | Submit Catching feedback successfully and refresh card state | 1) Open Catching feedback sheet<br>2) Select star rating and enter comment<br>3) Tap "Gửi đánh giá" | App submits Catching feedback successfully, shows snackbar "Cảm ơn bạn đã đánh giá!", and feedback card changes to "Đã gửi đánh giá" with submitted stars/comment | API is reachable and accepts payload | Pending |  |  | Pending |  |  | Pending |  |  | Success path |
| TC3304 | Prevent duplicate Catching feedback submission | 1) Submit feedback once for a completed catching request<br>2) Re-open same activity detail<br>3) Try to submit again (or trigger duplicate via API) | UI no longer shows submit CTA for same reviewer-target-reference triple; if duplicate request is forced, API returns conflict and app shows duplicate warning message | Existing feedback already recorded for same request and target rescuer | Pending |  |  | Pending |  |  | Pending |  |  | Duplicate guard + 409 handling |
| TC3305 | Rescuer opens feedback screen and reads summary + list | 1) Login as Rescuer<br>2) Open màn hình Đánh giá của cứu hộ viên tương ứng<br>3) Observe overview and review list | Screen loads received feedbacks, sorts newest first, shows average score, star distribution, total count, and review cards | Rescuer has at least one received feedback | Pending |  |  | Pending |  |  | Pending |  |  | Rescuer read flow |
| TC3306 | Rescuer feedback filters work correctly | 1) On rescuer feedback screen, switch filters: "Tất cả", "5 sao", "4 sao", "Có bình luận"<br>2) Compare displayed list with source data | Each filter returns matching subset only (all, exact 5-star, exact 4-star, non-empty comments) | Dataset contains mixed ratings and comment/no-comment items | Pending |  |  | Pending |  |  | Pending |  |  | Filter behavior |
| TC3307 | Member submits consultation review after completion | 1) Complete a consultation and open consultation completion screen<br>2) Try submit without stars, then with stars and optional text/tags<br>3) Submit review | Without stars: app warns user to choose rating; with valid stars: app submits consultation review successfully, shows thank-you snackbar, then navigates to member home | Consultation is completed and has a valid consultation ID | Pending |  |  | Pending |  |  | Pending |  |  | Consultation rating submit |
| TC3308 | Member can skip consultation rating without submitting | 1) Open consultation completion screen<br>2) Tap "Bỏ qua" | App navigates out (member home) and no review submit request is sent | Completion screen is displayed | Pending |  |  | Pending |  |  | Pending |  |  | Optional rating |
| TC3309 | Expert reviews list for specific expert supports load and pagination | 1) As Member, open the full review screen from expert profile<br>2) Verify header rating/count and first page items<br>3) Tap "Xem thêm đánh giá" when available | App loads paged expert reviews, renders cards, and appends next page without replacing existing items | Expert has reviews across multiple pages | Pending |  |  | Pending |  |  | Pending |  |  | Public review browsing |
| TC3310 | Expert self-feedback screen supports filters, sort order, refresh, and error retry | 1) Login as Expert and open expert feedback screen<br>2) Use filters (all, 5-star, with comment) and toggle sort (newest/oldest)<br>3) Pull-to-refresh or tap refresh; simulate API error then retry | Screen shows correct filtered/sorted subset, refresh reloads data, and error state provides "Thử lại" recovery without app crash | Expert account exists; API can be toggled to fail/recover | Pending |  |  | Pending |  |  | Pending |  |  | Expert internal feedback view |