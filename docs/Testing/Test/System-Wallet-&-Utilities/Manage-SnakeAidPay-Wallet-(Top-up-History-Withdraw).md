# Manage SnakeAidPay Wallet

## Summary

| Field | Value |
|---|---|
| Feature | Manage SnakeAidPay Wallet (Top-up, History, Withdraw) |
| Test requirement | Verify wallet entry points, top-up flow, withdrawal flow, and transaction history for Member and Expert, plus negative access for Rescuer |
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
| TC3001 | Member opens SnakeAidPay wallet from Profile | 1) Login as Member<br>2) Open Profile screen<br>3) Observe wallet card and balance | Wallet card is visible with title "Ví SnakeAidPay", balance, and actions "Nạp tiền", "Rút tiền", and history icon | Member account is logged in and profile data loads | Pending |  |  | Pending |  |  | Pending |  |  | Main wallet entry |
| TC3002 | Member tops up SnakeAidPay wallet successfully | 1) From Member Profile tap "Nạp tiền"<br>2) Enter valid amount<br>3) Continue to PayOS checkout and complete payment<br>4) Return to app | App creates top-up order, opens PayOS checkout, then shows success message "Nạp tiền thành công" and refreshed balance | Member wallet screen is accessible and PayOS test environment is available | Pending |  |  | Pending |  |  | Pending |  |  | Main top-up behavior |
| TC3003 | Member is blocked when a pending top-up already exists | 1) Start a top-up but do not finish it<br>2) Open "Nạp tiền" again from wallet card<br>3) Observe dialog | App shows the pending-order warning and does not create a second top-up until the existing one is completed or cancelled | A previous top-up checkout URL is still pending for the same member | Pending |  |  | Pending |  |  | Pending |  |  | Guard rail |
| TC3004 | Member views wallet history and filters entries | 1) From Member Profile tap wallet history icon<br>2) Observe "Lịch Sử Ví" screen<br>3) Switch between "Tất cả", "Nạp tiền", and "Rút tiền" | History screen loads and filters the combined wallet entries correctly | Member has at least one wallet transaction or withdrawal record | Pending |  |  | Pending |  |  | Pending |  |  | Wallet history coverage |
| TC3005 | Member opens payment history from Profile | 1) Open Member Profile<br>2) Tap "Lịch Sử Thanh Toán"<br>3) Observe transaction list and filters | App opens payment history screen and displays transaction list with transaction-type filtering | Member account is logged in | Pending |  |  | Pending |  |  | Pending |  |  | History navigation |
| TC3006 | Member requests a withdrawal successfully | 1) From Member Profile tap "Rút tiền"<br>2) Select bank and fill account information<br>3) Enter valid amount and confirm | App creates withdrawal request, shows confirmation flow, and displays success message "Yêu cầu rút tiền đã gửi" | Member has sufficient wallet balance and a supported bank is available | Pending |  |  | Pending |  |  | Pending |  |  | Main withdraw behavior |
| TC3007 | Member sees withdrawal guard when limit is reached | 1) Prepare member account with 3 active withdrawal requests<br>2) Open withdrawal screen<br>3) Try to submit a new withdrawal | App blocks submission and shows the limit message "Đã đạt giới hạn rút tiền" | Member already has 3 pending/approved withdrawal requests | Pending |  |  | Pending |  |  | Pending |  |  | Business rule |
| TC3008 | Expert opens wallet card from Expert Profile | 1) Login as Expert<br>2) Open Expert Profile screen<br>3) Observe wallet card | Wallet card is visible with title "Ví SnakeAidPay", balance, "Rút tiền" button, and history icon; no top-up button is shown | Expert account is logged in and profile data loads | Pending |  |  | Pending |  |  | Pending |  |  | Role access |
| TC3009 | Expert requests a withdrawal and views wallet history | 1) From Expert Profile tap "Rút tiền"<br>2) Enter valid bank and amount<br>3) Confirm request<br>4) Open wallet history | Expert can submit withdrawal successfully and open "Lịch Sử Ví" with withdrawal entries only | Expert has sufficient wallet balance and a supported bank is available | Pending |  |  | Pending |  |  | Pending |  |  | Expert wallet flow |
| TC3010 | Rescuer does not get wallet top-up or withdraw entry points | 1) Login as Rescuer<br>2) Open Rescuer Profile screen<br>3) Inspect menu and available actions | Rescuer profile does not expose SnakeAidPay top-up/withdraw wallet actions; wallet access is not available from the rescuer UI | Rescuer account is logged in | Pending |  |  | Pending |  |  | Pending |  |  | Negative access |
