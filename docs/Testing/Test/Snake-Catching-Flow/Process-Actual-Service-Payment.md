# Process Actual Service Payment

## Summary

| Field | Value |
|---|---|
| Feature | Process Actual Service Payment (Round 2) |
| Test requirement | Member can pay the final snake catching service fee after mission completion using either SnakeAidPay wallet or PayOS, and the request becomes fully paid |
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
| TC1101 | Open completed service payment section from Activity | 1) Login as Member<br>2) Open "Hoạt Động"<br>3) Select a booking whose mission is completed and final service fee is pending<br>4) Open booking detail | Detail screen shows the round-2 card "Đợt 2 — Thanh Toán Dịch Vụ" and the main action label "THANH TOÁN DỊCH VỤ" | Mission is completed and round-2 payment is not yet confirmed | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1102 | Open payment sheet for round 2 from completed booking | 1) Open a booking that still needs final payment<br>2) Tap "THANH TOÁN DỊCH VỤ"<br>3) Observe bottom sheet | Payment sheet opens with title "Thanh toán dịch vụ", subtitle "Chọn phương thức thanh toán", and amount row "Đợt 2 — Dịch vụ" | Round-2 payment is pending and mission actual cost is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1103 | Pay final service fee successfully using SnakeAidPay wallet | 1) Open the round-2 payment sheet<br>2) In the card "Ví SnakeAidPay", verify sufficient balance is available<br>3) Tap "Thanh toán bằng ví" | Payment succeeds and success dialog appears with title "Thanh Toán Thành Công!" and subtitle "Thanh toán dịch vụ bắt rắn đã được xác nhận." | Member wallet has enough balance for final amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1104 | Wallet payment is blocked when balance is not enough | 1) Open the round-2 payment sheet<br>2) Use a wallet account with insufficient balance<br>3) Observe the button state in "Ví SnakeAidPay" | Button changes to "Số dư không đủ" and helper text indicates the amount to top up; wallet payment cannot be completed | Wallet balance is lower than the round-2 amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1105 | Pay final service fee through PayOS successfully | 1) Open the round-2 payment sheet<br>2) Tap "Thanh toán qua PayOS"<br>3) Complete the payment on PayOS<br>4) Return to app via deep link or app resume | PayOS checkout opens, payment is confirmed, and round-2 payment becomes completed | PayOS service is available; round-2 amount is valid | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1106 | PayOS return updates the booking state to paid | 1) Start round-2 payment with PayOS<br>2) Finish payment successfully<br>3) Wait for the app to re-check status after returning | The app recognizes the returned payment and the round-2 card changes to "Đợt 2 — Thanh Toán Dịch Vụ (Đã Thanh Toán)" | A PayOS payment link was created for the current request | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1107 | Cancel PayOS checkout and keep round-2 unpaid | 1) Open the round-2 payment sheet<br>2) Tap "Thanh toán qua PayOS"<br>3) Cancel or close the checkout page before confirmation<br>4) Return to booking detail | Payment remains unpaid and the UI still shows the warning message "Người cứu hộ đã hoàn thành nhiệm vụ. Vui lòng thanh toán để xác nhận dịch vụ." | PayOS checkout can be opened from the current booking | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1108 | Round-2 amount is not payable when price is missing | 1) Open a booking detail where the final service amount is not available<br>2) Tap the final payment entry if visible | App shows the snackbar "Không có thông tin giá để thanh toán" and does not open checkout | Mission actualCost and fallback cost are unavailable or zero | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1109 | Final payment summary updates after confirmation | 1) Complete round-2 payment successfully<br>2) Reopen booking detail<br>3) Check the payment summary cards | Round-1 remains shown as paid, round-2 changes to paid, and the summary displays "Tổng đã thanh toán" with correct totals | Round-2 payment has been confirmed by backend | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1110 | Back navigation keeps payment state unchanged | 1) Open the round-2 payment sheet or booking detail<br>2) Tap "Quay Lại" or navigate back without paying<br>3) Reopen the same booking | Booking remains in unpaid round-2 state and the main action still shows "THANH TOÁN DỊCH VỤ" | Round-2 payment is still pending | Pending |  |  | Pending |  |  | Pending |  |  |  |
