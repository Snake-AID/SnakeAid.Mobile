## Operator SOS Snake Bite Flow

## Summary

| Field | Value |
|---|---|
| Feature | Operator Snake Bite SOS Flow (Verify, Dispatch, False Alarm, Track Mission) |
| Test requirement | Verify operator can process SOS case from Pending to Verified, dispatch rescuer from Verified, and handle false alarm or completion states with correct UI feedback |
| Number of TCs | 6 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 6 | 0 |
| Round 2 | 0 | 0 | 6 | 0 |
| Round 3 | 0 | 0 | 6 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC901 | Verify SOS case successfully (Pending -> Verified) | 1) Login with Operator account<br>2) Open Operator Dashboard<br>3) In tab "Cấp cứu", select a case with status "Chờ xử lý"<br>4) Open case detail modal<br>5) Click "Xác minh" | Case is verified; status badge changes to "Chờ điều phối"; success toast "Đã xác nhận case." is shown | Operator account exists; at least one active SOS case in Pending state | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC902 | Mark SOS case as false alarm | 1) Open a case in Pending state<br>2) Click "Báo động giả"<br>3) Confirm dashboard refresh | Case is marked as false alarm; success toast "Đã đánh dấu báo động giả." is shown; case is removed from active SOS list or no longer appears in processing queue | Case is in Pending state and operator is allowed to mark false alarm | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC903 | Dispatch rescuer for Verified SOS case | 1) Open a case already verified<br>2) Click "Điều phối đội cứu hộ"<br>3) Select one available rescuer in dispatch modal<br>4) Click "Xác nhận điều phối" | Dispatch completes; success toast "Đã điều phối đội cứu hộ." is shown; case status changes to "Đã điều phối" and assigned rescuer info is visible in detail | Case is Verified; at least one rescuer is online and available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC904 | Prevent dispatch before verification | 1) Open a case in Pending state<br>2) Observe action buttons in detail modal<br>3) Try to find dispatch action | Dispatch button is not shown for Pending case; operator must verify case first | Case is in Pending state | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC905 | Track assigned SOS mission info | 1) Open case in Assigned state<br>2) Observe assigned rescuer block and active mission block<br>3) Check mission timestamps and rescuer info | Detail modal shows assigned rescuer information, active mission information, and completion/ETA data where available | Case is Assigned and has active mission data from backend | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC906 | Verify completed SOS case stays read-only for dispatch | 1) Open a case in Completed state<br>2) Observe action area<br>3) Confirm dispatch is no longer available | Completed case shows final state, no dispatch action is available, and history/mission summary remains readable | Case is Completed or FalseAlarm | Pending |  |  | Pending |  |  | Pending |  |  |  |