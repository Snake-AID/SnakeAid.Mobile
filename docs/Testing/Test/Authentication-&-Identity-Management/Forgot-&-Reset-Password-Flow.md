# Forgot & Reset Password Flow

## Summary

| Field | Value |
|---|---|
| Feature | Forgot & Reset Password Flow |
| Test requirement | Verify complete password recovery flow: request OTP, verify OTP, reset password with policy checks, and return to role-based login |
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
| TC301 | Open forgot-password screen from login and verify required field | 1) Open Member/Rescuer/Expert login screen<br>2) Tap "Forgot Password"<br>3) Leave email/phone empty and tap "Send Verification Code" | User is navigated to forgot-password screen; empty input is rejected with validation message | User is on a role login screen | Pending |  |  | Pending |  |  | Pending |  |  | Input required |
| TC302 | Submit forgot-password request with valid email/phone | 1) Enter valid email or phone on forgot-password screen<br>2) Tap "Send Verification Code"<br>3) Wait for loading to complete | Loading indicator appears; app navigates to OTP verification screen with masked contact display | Valid email/phone value is available | Pending |  |  | Pending |  |  | Pending |  |  | Current flow is client-side simulated delay |
| TC303 | OTP verify is blocked when fewer than 6 digits are entered | 1) On forgot-password OTP screen, enter less than 6 digits<br>2) Tap "Confirm" | Snackbar prompts user to enter complete OTP; no navigation to reset-password screen | User is on forgot-password OTP screen | Pending |  |  | Pending |  |  | Pending |  |  | OTP length validation |
| TC304 | OTP input behavior and resend countdown works correctly | 1) Enter OTP digits one-by-one and observe cursor auto-move<br>2) Delete a digit and observe focus move back<br>3) Wait for countdown expiry and tap resend | OTP boxes auto-advance/backspace correctly; countdown reaches expiry state; resend restarts timer and shows confirmation snackbar | User is on forgot-password OTP screen | Pending |  |  | Pending |  |  | Pending |  |  | UX behavior |
| TC305 | Successful OTP verification navigates to reset-password screen | 1) Enter 6 OTP digits<br>2) Tap "Confirm"<br>3) Wait for processing | App navigates to reset-password screen and keeps role theme/route context | OTP screen is open with 6-digit input | Pending |  |  | Pending |  |  | Pending |  |  | Current flow is client-side simulated delay |
| TC306 | Reset password form validates policy and confirm-password mismatch | 1) Open reset-password screen<br>2) Enter weak password not meeting requirements<br>3) Enter non-matching confirmation and submit | Form blocks submission and shows appropriate validation errors for policy and mismatch | User has reached reset-password screen | Pending |  |  | Pending |  |  | Pending |  |  | Password validation |
| TC307 | Reset password success navigates to success screen | 1) Enter valid new password meeting policy<br>2) Enter matching confirmation<br>3) Tap "Reset Password" | Processing completes and app navigates to password reset success screen | Reset-password screen is open with valid input | Pending |  |  | Pending |  |  | Pending |  |  | Current flow is client-side simulated delay |
| TC308 | Return-to-login after password reset success uses role route | 1) On password reset success screen, tap "Back to Login"<br>2) Observe destination screen | App navigates to the correct role login route passed from the forgot-password flow | Password reset success screen is open | Pending |  |  | Pending |  |  | Pending |  |  | Role-based navigation |