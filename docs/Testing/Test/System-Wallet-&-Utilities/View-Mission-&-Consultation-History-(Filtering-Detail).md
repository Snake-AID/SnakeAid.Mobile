# View Mission & Consultation History (Filtering, Detail)

## Summary

| Field | Value |
|---|---|
| Feature | View Mission & Consultation History (Filtering, Detail) |
| Test requirement | Verify users can view mission/consultation history, apply filters, refresh data, load more items, and open detail screens correctly across Member, Rescuer, and Expert roles |
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
| TC3401 | Member opens history screen and switches between Catching and Incident history | 1) Login as Member and open Lịch Sử screen<br>2) Observe default tab content<br>3) Switch between Bắt rắn and Sự cố modes | Screen loads correctly, mode toggle changes list source, and active mode styling is applied correctly | Member account is logged in | Pending |  |  | Pending |  |  | Pending |  |  | Member mode switch |
| TC3402 | Member Catching history shows only historical requests and newest-first order | 1) Open Member history in Bắt rắn mode<br>2) Compare displayed items with mixed-status test data<br>3) Check timestamp order | Only history statuses are shown (completed/paid/dispute/cancelled/expired), and cards are sorted descending by request date | Member has mixed Catching requests across statuses | Pending |  |  | Pending |  |  | Pending |  |  | History filtering |
| TC3403 | Member Catching history supports pull-to-refresh and open detail flow | 1) In Bắt rắn history, pull to refresh<br>2) Tap a request card<br>3) Observe destination and loaded detail data | List refreshes without crash; tapping a card opens the corresponding activity detail with matching request information | At least one Catching history item exists | Pending |  |  | Pending |  |  | Pending |  |  | Detail navigation |
| TC3404 | Member Incident history loads historical incidents with pagination | 1) Switch to Sự cố mode in Member history<br>2) Scroll near end of list repeatedly<br>3) Observe appended data and loading indicator | History list includes only historical incident statuses, loads next pages as user scrolls, and appends results without replacing previous items | Member has incident history spanning multiple pages | Pending |  |  | Pending |  |  | Pending |  |  | Infinite scroll |
| TC3405 | Member Incident history handles empty/error states and retry | 1) Open Sự cố history with no records<br>2) Verify empty-state message<br>3) Simulate API error and tap Thử lại | App shows proper empty state when no data; on error, shows error state and retry reloads data once backend/network recovers | Test environment can simulate no-data and API failure | Pending |  |  | Pending |  |  | Pending |  |  | Reliability |
| TC3406 | Member Consultation history tab shows completed/cancelled sessions with metadata | 1) Open Consultation home and switch to Lịch Sử tab<br>2) Verify cards for completed/cancelled sessions<br>3) Check type/status/fee or refund/rating info | Only historical consultations are displayed, newest first; card metadata reflects actual status (including cancelled refund label and rating when available) | Member has completed/cancelled consultations | Pending |  |  | Pending |  |  | Pending |  |  | Consultation history view |
| TC3407 | Member Consultation history supports load more and refresh consistency | 1) In Consultation Lịch Sử, scroll to bottom to trigger load more<br>2) Continue scrolling to next pages<br>3) Pull to refresh and re-check list | Additional history pages are appended in stable order, duplicate items are prevented, and refresh re-syncs list correctly | Consultation history has more than one page | Pending |  |  | Pending |  |  | Pending |  |  | Paging + dedup |
| TC3408 | Member Consultation history opens detail and supports rating continuation when not yet rated | 1) From consultation history card, tap Xem Chi Tiết<br>2) Verify detail shows service/time/fee/status/rating context<br>3) For completed item without rating, tap Đánh Giá and submit | Detail screen opens with correct mapped fields; rating action is available only for eligible completed items without rating and leads to successful rating flow | Have at least one completed consultation without rating and one with rating/cancelled | Pending |  |  | Pending |  |  | Pending |  |  | Detail + conditional action |
| TC3409 | Rescuer mission history supports period selector, status tabs, and detail open | 1) Login as Rescuer and open Lịch Sử Cứu Hộ<br>2) Change period (day/month/year) and verify analytics summary updates<br>3) Switch tabs Tất cả/Hoàn thành/Đã hủy and open item detail | Statistics update by selected period; tab filter returns correct subset; detail button opens corresponding mission detail flow for selected status | Rescuer has completed and cancelled missions | Pending |  |  | Pending |  |  | Pending |  |  | Rescuer filtering |
| TC3410 | Expert consultation history opens from profile shortcut and supports refresh/detail | 1) Login as Expert, go to profile, open consultation history shortcut<br>2) In consultation history tab, pull to refresh<br>3) Tap Xem Chi Tiết on a completed/cancelled card | App navigates to expert consultation history tab, refresh reloads data, and detail view opens correctly from history cards | Expert has historical consultations | Pending |  |  | Pending |  |  | Pending |  |  | Expert history flow |