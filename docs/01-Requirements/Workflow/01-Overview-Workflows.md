# WORKFLOW OVERVIEW (4 MAIN FLOWS)

## 3.1 Overview

- Workflow 1: SOS Snake Bite
1. Member opens SnakeAid and triggers SOS emergency.
2. Member submits SOS details (GPS location, symptoms, optional snake image).
3. SnakeAid System creates Emergency Case with status Pending and notifies Operator.
4. Operator verifies the case with Member and updates status to Verified.
5. Operator assigns a Rescuer and updates status to Assigned.
6. SnakeAid System sends SignalR assignment to Rescuer and updates Member with Rescuer/ETA.
7. Rescuer travels to the scene, provides first aid support, and marks task completion.
8. SnakeAid System closes the case as Finished and sends payment request to Member.
9. Member completes payment via available method.
10. SnakeAid System marks case Completed, settles payment, and stores case history.

- Workflow 2: Snake Catching
1. Member creates a snake catching request (photo/species, location, address detail).
2. SnakeAid System creates request as Pending, calculates estimated price and distance, and notifies Operator.
3. Member can pay Round 1 deposit in allowed states (Pending, Confirmed, Assigned).
4. Operator verifies request with Member and updates status to Confirmed.
5. Operator assigns a Rescuer and updates status to Assigned.
6. SnakeAid System sends SignalR assignment to Rescuer and assignment notification to Member.
7. Rescuer executes mission flow (Preparing, EnRoute, Arrived), captures snake, and uploads evidence.
8. SnakeAid System marks request Finished and calculates actual cost.
9. Member reviews service details and pays Round 2 service fee.
10. SnakeAid System marks request Completed, sends completion notifications, and stores history.

- Workflow 3: Tu van dat lich (Scheduled Consultation)
1. Member opens Expert directory and selects an Expert.
2. Member taps "Chọn Đặt Lịch" on the service selection screen, then selects date/time slot.
3. SnakeAid System validates slot availability and prepares booking summary.
4. Member confirms payment for consultation fee.
5. Payment Gateway processes transaction and holds escrow.
6. SnakeAid System creates booking with Confirmed status and locks the selected slot.
7. SnakeAid System sends booking confirmation to both Member and Expert.
8. At consultation time, system opens waiting room and notifies both sides.
9. Member and Expert join waiting room; session starts as InProgress and ends normally.
10. SnakeAid System marks booking Completed, releases escrow to Expert, and stores consultation history.

- Workflow 4: Tu van ngay (Instant Consultation)
1. Member taps "Chọn Tư Vấn Ngay" on an available Expert profile service selection screen.
2. SnakeAid System validates that Expert is online and ready.
3. If unavailable, Member is prompted to select another Expert or switch flow.
4. If available, SnakeAid System creates temporary booking and locks Expert slot.
5. Member confirms payment for consultation fee.
6. Payment Gateway holds escrow and returns successful payment result.
7. SnakeAid System confirms booking and notifies both Member and Expert.
8. Both parties enter waiting room and video session starts immediately.
9. Session ends and booking is marked Completed.
10. Escrow is released to Expert; Member can submit rating/feedback.

- Workflow 5: Register Member
1. Guest opens SnakeAid, taps role "Người Dùng" on role selection, then opens Member Login.
2. Guest taps "Đăng ký ngay" on Member Login to open the registration screen.
3. Guest enters required Member information (full name, email/phone, password, and required fields).
4. Guest taps "Đăng Ký" to submit registration data.
5. SnakeAid System validates input format and checks duplicate account constraints.
6. If validation fails, the app shows field-level errors and blocks submission.
7. If validation passes, SnakeAid System creates Member account in unverified state.
8. SnakeAid System sends OTP to the registered contact channel.
9. Member enters OTP and submits verification.
10. SnakeAid System verifies OTP and activates the Member account.
11. App shows registration success state.
12. User is redirected to the corresponding Login screen.

- Workflow 6: Register Expert
1. Guest opens SnakeAid, taps role "Chuyên Gia" on role selection, then opens Expert Login.
2. Guest taps "Đăng ký ngay" on Expert Login to open the registration screen.
3. Guest completes required Expert information fields and account credentials.
4. Guest accepts required terms and conditions.
5. SnakeAid System validates profile fields and duplicate account constraints.
6. SnakeAid System sends OTP to the registered contact channel.
7. Expert enters OTP and completes verification.
8. Expert is redirected to the certificate/credential submission screen.
9. Expert uploads required certificates and identity documents.
10. SnakeAid System sets Expert status to Pending Verification and waits for admin approval.
11. Only after admin approval, Expert can access Home screen and use full Expert functions.

## Notes
- The SOS and Snake Catching flows follow operator-based assignment (v2.0).
- Consultation payment uses escrow: hold at confirmation, release at completion, refund if canceled by allowed rule.
- Realtime assignment/updates use SignalR where applicable.
