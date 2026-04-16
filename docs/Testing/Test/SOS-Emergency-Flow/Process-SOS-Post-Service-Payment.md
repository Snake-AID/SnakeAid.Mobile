# Process SOS Post-Service Payment

## Summary

| Field | Value |
|---|---|
| Feature | Process SOS Post-Service Payment |
| Test requirement | Member pays the emergency service fee after the incident is finished, using Wallet or PayOS, and verifies the payment success flow and post-payment actions |
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
| TC1701 | Open post-service payment screen after incident is finished | 1) Login as Member<br>2) Open the finished SOS incident detail after the rescue is completed<br>3) Verify payment area is available | The screen shows payment status and the action button changes to "Thanh toán ngay" (or "Hoàn tất đơn miễn phí" when the fee is zero) | The SOS incident is already in Finished/Completed state | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1702 | Verify payment card shows fee breakdown | 1) Open the payment area on the finished incident detail screen<br>2) Inspect the payment card | The payment card shows labels such as "Giá dịch vụ", "Chi phí di chuyển", and "Tổng thanh toán" | Incident contains payment information from the rescue mission | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1703 | Open payment sheet from the primary payment button | 1) Tap "Thanh toán ngay"<br>2) Observe the bottom sheet | A payment sheet opens with title "Thanh toán sự cố", payment summary, and payment methods | Incident is unpaid and has a non-zero total amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1704 | Verify Wallet payment option is available and enabled when balance is sufficient | 1) Open the payment sheet<br>2) Inspect the Wallet section<br>3) Check the button state | Wallet card shows "Ví SnakeAidPay" and the button "Thanh toán bằng ví" is enabled when the wallet balance is enough | Wallet info is loaded and balance is sufficient | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1705 | Block Wallet payment when balance is insufficient | 1) Open the payment sheet with an insufficient wallet balance<br>2) Observe the Wallet action button | The Wallet action becomes disabled and shows "Số dư không đủ" | Wallet info is available but balance is lower than the payment amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1706 | Pay successfully with Wallet | 1) Open the payment sheet<br>2) Tap "Thanh toán bằng ví"<br>3) Wait for the result dialog | Payment completes successfully and a confirmation dialog appears with title "Thanh Toán Thành Công" | Wallet balance is sufficient and wallet payment API succeeds | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1707 | Pay successfully with PayOS | 1) Open the payment sheet<br>2) Tap "Thanh toán qua PayOS"<br>3) Confirm the external checkout opens | The app opens PayOS checkout and shows the snackbar "Mở PayOS checkout..." | Payment amount is greater than 0 and PayOS checkout URL is returned | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1708 | Handle PayOS return and confirm payment success | 1) Complete the PayOS payment flow externally<br>2) Return to the app or wait for callback verification<br>3) Observe the payment status dialog and result | The app shows "Đang kiểm tra thanh toán" and then displays payment success with title "Thanh Toán Thành Công" | PayOS payment has been completed and the return/callback is received | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1709 | Verify payment success screen actions | 1) Open the payment success screen after payment completion<br>2) Inspect available actions | The screen shows "Thanh toán thành công", "Tóm tắt thanh toán", and buttons such as "Về trang chủ", "Xem lịch sử dịch vụ", and "Tải hóa đơn" | Payment was confirmed successfully | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC1710 | Verify free-payment path uses completion confirmation instead of payment gateway | 1) Open a finished incident with zero total amount<br>2) Tap the primary action button<br>3) Observe the payment sheet and result | The action label becomes "Hoàn tất đơn miễn phí" and the flow does not open PayOS; completion is confirmed directly | The incident total payment amount is 0 | Pending |  |  | Pending |  |  | Pending |  |  |  |