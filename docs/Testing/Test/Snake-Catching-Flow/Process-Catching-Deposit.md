# Process Catching Deposit

## Summary

| Field | Value |
|---|---|
| Feature | Process Catching Deposit (Round 1) |
| Test requirement | Member can open the deposit payment sheet from snake catching request detail, pay using either SnakeAidPay wallet or PayOS, and the deposit becomes confirmed for the request |
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
| TC701 | Open deposit payment sheet from Member activity flow | 1) Open Home as Member<br>2) Open "Hoạt Động"<br>3) Select 1 booking that needs travel fee payment<br>4) Click button "Thanh toán Phí Di Chuyển" | Payment sheet opens with title "Thanh toán đặt cọc", subtitle "Chọn phương thức thanh toán", and amount row "Đợt 1 — Đặt cọc" | A snake catching booking exists in Activity and still requires round-1 deposit payment | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC702 | Pay deposit successfully using SnakeAidPay wallet | 1) Open the payment sheet<br>2) In the card "Ví SnakeAidPay", verify sufficient balance is available<br>3) Tap "Thanh toán bằng ví" | Deposit payment succeeds and success dialog appears with title "Thanh Toán Thành Công!" and subtitle "Đặt cọc phí di chuyển đã được xác nhận." | Member has enough wallet balance; deposit payment sheet is open | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC703 | Wallet payment is blocked when balance is not enough | 1) Open the payment sheet<br>2) In the card "Ví SnakeAidPay", use an account with insufficient balance<br>3) Observe the action button state | Button changes to "Số dư không đủ" and the helper message indicates the missing amount; wallet payment cannot be completed | Wallet balance is lower than the deposit amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC704 | Pay deposit through PayOS checkout successfully | 1) Open the payment sheet<br>2) In the card "PayOS", tap "Thanh toán qua PayOS"<br>3) Complete payment on the PayOS checkout page<br>4) Return to the app via deep link or app resume | PayOS checkout opens, payment is confirmed, and the request is updated to deposit-paid state | PayOS service is available; request has a valid deposit amount | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC705 | PayOS payment updates request state after return | 1) Start a deposit payment through PayOS<br>2) Finish the payment successfully<br>3) Wait for the app to verify the deep link return | The app recognizes the returned payment, clears the pending PayOS context, and the booking shows the deposit as confirmed | A PayOS payment link was created for the current request | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC706 | Cancel PayOS checkout and keep deposit unpaid | 1) Open the payment sheet<br>2) Tap "Thanh toán qua PayOS"<br>3) Cancel or close the checkout page before payment is confirmed<br>4) Return to the request detail screen | Deposit remains unpaid and the request stays in the waiting-for-deposit state | PayOS checkout can be opened from the current request | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC707 | Deposit payment is not allowed when no amount is available | 1) Open a request detail screen that has no valid amount for round-1 payment<br>2) Open the deposit action if visible or trigger the payment action | App shows the snackbar "Không có thông tin giá để thanh toán" and does not open checkout | Request data is missing deposit amount or estimated price | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC708 | Deposit confirmation enables next rescue flow state | 1) Complete a round-1 payment by wallet or PayOS<br>2) Reopen the request detail screen<br>3) Verify the payment state area | The request reflects that round-1 deposit is confirmed and the payment entry changes to "Đã Thanh Toán Phí Di Chuyển" | Deposit payment has been confirmed by the backend | Pending |  |  | Pending |  |  | Pending |  |  |  |
