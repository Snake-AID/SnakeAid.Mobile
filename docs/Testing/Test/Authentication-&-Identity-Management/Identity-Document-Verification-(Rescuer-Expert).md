# Identity Document Verification (Rescuer/Expert)

## Summary

| Field | Value |
|---|---|
| Feature | Identity Document Verification (Rescuer/Expert) |
| Test requirement | Verify Rescuer and Expert can access document screens, view verification status, add/view/update/remove documents, and handle pending/verified/rejected states safely |
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
| TC501 | Expert opens ID documents screen from profile menu | 1) Login as Expert<br>2) Open profile tab/menu<br>3) Tap "Chứng Chỉ & Bằng Cấp" | App opens Expert ID documents screen with status banner and document sections | Expert account is logged in | Pending |  |  | Pending |  |  | Pending |  |  | Access control |
| TC502 | Expert document status badges render correctly | 1) Open Expert ID documents screen<br>2) Inspect cards with verified and pending statuses<br>3) Check badge text/icon/color | Each document shows correct status badge (verified/pending/rejected style mapping) and consistent visual state | Expert document data is available | Pending |  |  | Pending |  |  | Pending |  |  | Status mapping |
| TC503 | Expert add-new document entry points are available | 1) On Expert ID documents screen, tap top-right add icon<br>2) Tap add-new placeholder card in certificate section | Add-new action is accepted from both entry points (no crash; add flow trigger is called) | Expert ID documents screen is open | Pending |  |  | Pending |  |  | Pending |  |  | Action wiring |
| TC504 | Expert can open document preview/details action | 1) On Expert ID documents screen, tap "Xem" on a document card<br>2) Verify view behavior loads target document | App opens or triggers document detail/preview action for selected card without UI errors | At least one expert document card exists | Pending |  |  | Pending |  |  | Pending |  |  | Detail open |
| TC505 | Rescuer opens ID documents screen and sees secure-info banner | 1) Login as Rescuer<br>2) Navigate to Rescuer ID documents screen<br>3) Observe header, info banner, and bottom summary area | Screen opens successfully and shows document-security guidance plus saved-document counter | Rescuer account is logged in and has screen access | Pending |  |  | Pending |  |  | Pending |  |  | Access + base UI |
| TC506 | Rescuer add document flow appends new item to list | 1) On Rescuer ID documents screen, tap "Thêm Giấy Tờ"<br>2) Fill required document fields and save<br>3) Observe list and bottom counter | New document appears in document list and total saved-document count increases accordingly | Rescuer ID documents screen is open | Pending |  |  | Pending |  |  | Pending |  |  | Add flow |
| TC507 | Rescuer view and delete document behavior works correctly | 1) Open a document card<br>2) Trigger "Xóa" action and confirm in dialog<br>3) Verify post-delete list state | Confirmation dialog appears; after confirming, selected document is removed and success feedback is shown | At least one removable rescuer document exists | Pending |  |  | Pending |  |  | Pending |  |  | Delete safety |
| TC508 | Rescuer edit/upload placeholder actions fail safely | 1) Tap edit action on a document<br>2) Tap upload action on a document<br>3) Observe app behavior and feedback | App stays stable and shows expected placeholder feedback (no crash, no broken navigation) | Rescuer ID documents screen is open | Pending |  |  | Pending |  |  | Pending |  |  | Placeholder behavior |