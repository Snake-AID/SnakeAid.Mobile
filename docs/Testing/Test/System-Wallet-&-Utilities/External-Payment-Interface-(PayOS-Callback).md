# External Payment Interface (PayOS Callback)

## Summary

| Field | Value |
|---|---|
| Feature | External Payment Interface (PayOS Callback) |
| Test requirement | Verify shared PayOS callback handling across wallet top-up and consultation payment flows, including success, cancel, mismatch, fallback confirm, and safe ignore when no pending context exists |
| Number of TCs | 9 |

## Testing Round Summary

| Testing Round | Passed | Failed | Pending | N/A |
|---|---:|---:|---:|---:|
| Round 1 | 0 | 0 | 9 | 0 |
| Round 2 | 0 | 0 | 9 | 0 |
| Round 3 | 0 | 0 | 9 | 0 |

## Test Cases

| Test Case ID | Test Case Description | Test Case Procedure | Expected Results | Pre-conditions | Round 1 | Test date | Tester | Round 2 | Test date | Tester | Round 3 | Test date | Tester | Note |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC3101 | Parse valid PayOS return callback into deep-link event | 1) Open a callback URI such as `snakeaid://payment/return?status=PAID&orderCode=123`<br>2) Let the app deep-link handler receive it<br>3) Observe callback dispatch | App recognizes the URI as a PayOS callback and creates a success event with the correct orderCode and status | App has the global PayOS deep-link listener active | Pending |  |  | Pending |  |  | Pending |  |  | Callback parsing |
| TC3102 | Parse cancel callback and clear pending state | 1) Start a PayOS payment flow<br>2) Return with a cancel URI or `cancel=true`<br>3) Observe UI feedback | App treats the callback as cancelled, clears pending PayOS context, and shows cancellation feedback | A pending PayOS transaction exists for wallet top-up or consultation payment | Pending |  |  | Pending |  |  | Pending |  |  | Main cancel flow |
| TC3103 | Member wallet top-up is confirmed after PayOS return | 1) Login as Member<br>2) Create a wallet top-up and open PayOS checkout<br>3) Return to app with a success callback<br>4) Observe wallet refresh | App verifies the pending top-up, confirms it with backend if needed, clears the pending state, and refreshes wallet balance | Member has an active wallet top-up checkout URL and transactionId | Pending |  |  | Pending |  |  | Pending |  |  | Wallet callback |
| TC3104 | Wallet callback with mismatched orderCode is rejected | 1) Start a wallet top-up<br>2) Return from PayOS with a callback that has a different orderCode<br>3) Observe result | App detects the mismatch, clears the pending top-up, and shows an error message instead of confirming the wrong transaction | Wallet top-up is pending and callback orderCode is intentionally incorrect | Pending |  |  | Pending |  |  | Pending |  |  | Safety check |
| TC3105 | Wallet callback with backend pending state falls back to confirm-payment | 1) Start a wallet top-up<br>2) Return with a success callback before backend reflects the transaction<br>3) Observe verification flow | App retries verification, calls confirm-payment fallback when allowed, then finalizes the top-up once backend confirmation succeeds | Wallet top-up is pending and test backend can delay or defer transaction reflection | Pending |  |  | Pending |  |  | Pending |  |  | Fallback confirm |
| TC3106 | Consultation PayOS payment callback completes booking/payment | 1) Start a consultation payment flow using PayOS<br>2) Return from PayOS with a success callback<br>3) Observe screen transition and data refresh | App verifies the payment, clears pending consultation context, refreshes consultation data, and continues to the appropriate success flow | Consultation payment screen has an active PayOS transactionId and orderCode | Pending |  |  | Pending |  |  | Pending |  |  | Shared callback path |
| TC3107 | Consultation wallet top-up created from payment screen is finalized on callback | 1) Open consultation payment screen with wallet top-up fallback path<br>2) Trigger wallet top-up via PayOS<br>3) Return with a success callback<br>4) Observe wallet balance and snackbar | App confirms the wallet top-up, clears the pending wallet-topup context, and refreshes the displayed wallet balance | Consultation payment screen is using the wallet-topup fallback path | Pending |  |  | Pending |  |  | Pending |  |  | Cross-feature callback |
| TC3108 | No pending PayOS context means callback is ignored safely | 1) Ensure there is no active PayOS payment context<br>2) Send a PayOS callback deep link to the app<br>3) Observe behavior | App ignores the callback without crashing, and no unrelated wallet or consultation state is changed | No wallet top-up or consultation payment is currently pending | Pending |  |  | Pending |  |  | Pending |  |  | Defensive behavior |
| TC3109 | Latest callback is handled after app resume | 1) Start a PayOS payment in browser<br>2) Return to the app after it is resumed or relaunched<br>3) Observe the latest callback handling | App replays the latest PayOS event on resume, verifies it once, and does not double-handle the same event | A PayOS payment is pending and the app lifecycle resumes from background | Pending |  |  | Pending |  |  | Pending |  |  | Lifecycle coverage |
