# Bug Report: Consultation Completion Flow Bypasses Backend Settlement Trigger

## Summary

The Flutter mobile app currently has multiple consultation completion paths. Some of them call the backend endpoint that finalizes the consultation, but at least one important path navigates directly to completion UI without calling the backend `end consultation` API.

This creates a false-complete state in the app:
- the user sees a completion screen,
- but the consultation may not actually be completed in backend,
- so consultation escrow settlement is not triggered,
- and no `ExpertPayout` transaction is inserted.

This explains the reported behavior:
- end call
- confirm complete
- still appears stuck around consultation payment flow
- no `ExpertPayout` row is created

## Scope

This report focuses on the Flutter mobile repository:
- `D:\SourceCode\Snake_AID\SnakeAid.Mobile`

The backend is referenced only where needed to explain dependency and expected behavior.

## Reported Symptom

Mobile developer reported:

```text
end cuộc gọi
xác nhận hoàn thành
vẫn ở consultation payment
ko có insert thêm cái expert payout nào
```

Interpreted symptom in English:
- user ends the call,
- confirms completion,
- but the consultation still behaves like it remains in payment-related state,
- and no expert payout is generated.

## Expected Behavior

Whenever a consultation is actually finished from the mobile app, all completion paths should converge on the same backend action:

- call `POST /api/consultations/{consultationId}/end`
- let backend mark consultation as completed
- let backend trigger consultation escrow settlement
- let backend insert settlement transactions such as `ExpertPayout` and `PlatformFee`
- only after that should mobile navigate to completion UI

## Actual Behavior Observed In Mobile Code

There are multiple end/completion paths in mobile, and they are inconsistent.

Some paths call backend completion correctly.
Some paths only navigate to completion UI without ending the consultation in backend.

Because of that inconsistency, users can reach a completion screen without the backend ever receiving the completion request.

## Relevant Backend Dependency

The backend completion endpoint is:

- `POST /api/consultations/{consultationId}/end`

Mobile repository wrapper:
- `lib/features/consultation/repository/consultation_repository.dart`
- method: `endConsultation(String consultationId)`

This backend endpoint is the trigger point for consultation settlement.
If mobile does not call this endpoint, backend settlement will not run, and `ExpertPayout` will not be created.

## Mobile Findings

### 1. Member waiting room has a correct completion path

File:
- `lib/features/consultation/screens/members/consultation_waiting_room_screen.dart`

Method:
- `_endConsultation()`

Observed behavior:
- shows confirmation dialog
- calls `repo.endConsultation(widget.consultationId)`
- if success, navigates to `/consultation-complete`

This is the correct pattern.

### 2. Member waiting room also has a UI-only completion helper

Same file:
- `lib/features/consultation/screens/members/consultation_waiting_room_screen.dart`

Method:
- `_confirmComplete()`

Observed behavior:
- directly navigates to `/consultation-complete`
- does not call `repo.endConsultation(...)`

This helper is a bypass path and is unsafe if used.

### 3. Video consultation `RoomExpiring` path bypasses backend completion

File:
- `lib/features/consultation/screens/members/video_consultation_screen.dart`

Method:
- `_handleRoomExpiringEvent(...)`

Observed behavior:
- disconnects the room
- then navigates directly to completion UI:
  - member: `/consultation-complete`
  - expert: `/expert-consultation-complete`
- does not call `repo.endConsultation(...)`

This is the strongest bug candidate.

If the user reaches completion via `RoomExpiring`, mobile can show a completed UI while backend never received the completion command.

### 4. Expert-side completion flow is incomplete

File:
- `lib/features/consultation/screens/experts/expert_waiting_room_screen.dart`

Observed behavior:
- supports entering the room
- supports leaving waiting room
- receives `showCompleteButton` from router
- but does not provide a corresponding backend completion action using `endConsultation(...)`

This means expert-side flow is not symmetrical with member-side flow.

### 5. Expert completion screen is presentation-only

File:
- `lib/features/consultation/screens/experts/expert_consultation_completion_screen.dart`

Observed behavior:
- displays completion UI
- auto-counts down and returns to expert home
- does not call backend completion API
- does not verify consultation completion state

This screen assumes completion already happened elsewhere, but mobile does not guarantee that.

## Flow Analysis

### Safe flow

Member waiting room:
1. user confirms completion
2. mobile calls `endConsultation(consultationId)`
3. backend ends consultation
4. backend triggers settlement
5. mobile navigates to completion screen

### Unsafe flow

Video room expiry path:
1. room expiry event arrives
2. mobile disconnects room
3. mobile navigates directly to completion screen
4. no backend completion API call happens
5. backend settlement may never run
6. no `ExpertPayout` is inserted

## Why This Produces The Reported Bug

The app currently mixes two meanings:
- "show completion UI"
- "actually complete the consultation in backend"

These are not the same operation.

At least one mobile path performs only the first one.
That causes the UI to look completed while the authoritative backend lifecycle is still unfinished.

From that point of view, the reported symptom is consistent with the codebase.

## Severity

High.

Reason:
- consultation completion is tied to money settlement
- settlement affects expert earnings
- this is not just a UI bug
- this can create financial inconsistency and trust issues

## Risk Areas

### Financial risk
- expert payout may never be created
- platform fee may never be recorded
- consultation appears done to user but not settled in ledger

### State consistency risk
- mobile screen says completed
- backend consultation may still be non-completed
- history and transaction views may diverge from user expectation

### UX risk
- users think they ended the session successfully
- later they still see payment-related state or missing payout artifacts

## Root Cause

The root cause in the mobile repository is:

**consultation completion is not normalized into a single mandatory operation before navigating to completion screens.**

Instead, mobile currently has multiple completion-like paths:
- some call backend `endConsultation(...)`
- some only navigate

## Recommended Fix Direction

### Primary fix
Normalize all consultation completion paths to the same rule:

**Before any completion screen is shown, mobile must call `endConsultation(consultationId)` successfully.**

### Concrete targets

1. `video_consultation_screen.dart`
- update `RoomExpiring` path so it does not navigate directly to completion UI
- it should first call `endConsultation(...)`
- then navigate only on success

2. `consultation_waiting_room_screen.dart`
- remove or block any UI-only bypass such as `_confirmComplete()` if unused
- keep only the API-backed completion flow

3. `expert_waiting_room_screen.dart`
- add a proper completion action symmetrical to member flow
- that action must call `endConsultation(...)`

4. `expert_consultation_completion_screen.dart`
- treat it as result UI only
- do not rely on it to imply backend completion

### Optional hardening

- centralize consultation completion into one mobile service/helper
- expose a single method such as `completeConsultationAndNavigate(...)`
- make all screens use that method instead of hand-rolled navigation

## Verification Plan

After fix, verify these scenarios:

1. Member manual complete from waiting room
- backend `/end` is called exactly once
- consultation is completed
- settlement transactions are created

2. Member room-expiry path
- backend `/end` is still called
- no direct UI-only completion remains

3. Expert completion path
- expert can trigger the same backend completion action if the product allows it
- backend settlement still occurs

4. No duplicate completion side effects
- repeated taps or repeated expiry signals should not double-complete or double-settle

## Key Conclusion

The mobile repository contains a real flow inconsistency.

The issue is not that mobile has no completion API available.
The issue is that mobile does not use that API consistently across all consultation-ending paths.

As a result, the app can show a completion screen without actually ending the consultation in backend, and that is sufficient to explain why `ExpertPayout` may not appear.
