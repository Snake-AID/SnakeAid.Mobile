# Cancel Catching Request

## Summary

| Field | Value |
|---|---|
| Feature | Cancel Catching Request |
| Test requirement | Member can cancel eligible snake catching requests from Activity detail with a required reason, and request status changes to Cancelled |
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
| TC1201 | Show cancel action for eligible Pending request | 1) Login as Member<br>2) Open "Hoạt Động"<br>3) Open a snake catching booking in Pending state<br>4) Observe bottom actions | Outlined button "Hủy đơn" is visible and enabled | Booking is Pending and not being cancelled | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1202 | Show cancel action for eligible Assigned + Preparing mission | 1) Open a booking in Assigned state where mission status is Preparing<br>2) Observe bottom actions | Button "Hủy đơn" is visible and enabled | Booking is Assigned and mission is Preparing | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1203 | Hide cancel action for ineligible statuses | 1) Open booking in Assigned with mission EnRoute or Arrived, or booking in Finished/Completed<br>2) Observe bottom actions area | "Hủy đơn" is not shown (or not available) for ineligible states | Booking status is not cancellable under current app rules | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1204 | Open cancel bottom sheet and verify labels | 1) Tap "Hủy đơn"<br>2) Observe cancel sheet UI | Sheet title is "Hủy Đơn"; helper text "Vui lòng cho chúng tôi biết lý do bạn muốn hủy đơn."; confirm button label is "XÁC NHẬN HỦY ĐƠN" | Cancel button is visible from eligible booking | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1205 | Reason selection is mandatory before confirming cancel | 1) Open cancel sheet<br>2) Do not select any reason<br>3) Observe confirm button | "XÁC NHẬN HỦY ĐƠN" remains disabled until a reason is selected | Cancel sheet is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1206 | Free-text reason is required for "Lý do khác" | 1) Open cancel sheet<br>2) Select "Lý do khác"<br>3) Keep text field "Nhập lý do của bạn..." empty<br>4) Observe confirm button | Confirm button stays disabled; after entering text, button becomes enabled | Cancel sheet is open and "Lý do khác" is selected | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1207 | Cancel request successfully with predefined reason | 1) Open cancel sheet<br>2) Select one predefined reason (for example "Không cần hỗ trợ nữa")<br>3) Tap "XÁC NHẬN HỦY ĐƠN" | Success dialog appears with title "Đơn đã được hủy" and message "Yêu cầu của bạn đã được hủy thành công." | Booking is in cancellable state and API is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1208 | Return to list after cancellation confirmation | 1) Complete cancellation successfully<br>2) In success dialog, tap "Về Danh Sách" | App navigates to Member home/list screen and cancelled booking is no longer active | Cancellation was successful and dialog is shown | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1209 | Cancelled status is reflected in request detail | 1) Reopen the cancelled booking detail from history/list<br>2) Observe status and timeline area | Status text becomes "Đã Hủy" and timeline message shows cancelled state (for example "Yêu cầu đã bị hủy") | Booking was cancelled successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1210 | Cancellation flow does not include refund confirmation step | 1) Cancel an eligible booking from Activity detail<br>2) Observe post-cancel screens and booking detail<br>3) Verify there is no UI step requiring refund confirmation in this flow | Cancellation completes with status "Đã Hủy" and the flow ends at cancel confirmation/list; no refund confirmation step is shown in snake catching cancellation flow | Booking is eligible for cancellation | Pending |  |  | Pending |  |  | Pending |  |  |  |
