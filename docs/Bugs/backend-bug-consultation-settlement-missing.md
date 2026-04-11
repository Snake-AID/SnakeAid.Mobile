# Bug Report: ExpertPayout Transaction Not Created After Consultation Ends

**Severity:** High — financial data missing  
**Reported by:** Mobile Team  
**Date:** 2026-04-12  
**Affected endpoint:** `POST /api/consultations/{consultationId}/end`

---

## Summary

When a member taps **"Hoàn Thành Tư Vấn"** to end a scheduled consultation, the mobile app calls `POST /api/consultations/{consultationId}/end`. The backend returns `200 OK` with `is_success: true`, but no `ExpertPayout` (or `PlatformFee`) transaction is created.

As a result, the expert's income tab shows **0đ** even after completing paid consultations.

---

## Reproduction Steps

1. Member books a scheduled consultation with a valid `feeCost > 0`.
2. Member joins waiting room → enters video call → calls expert.
3. After the call, member navigates back to waiting room.
4. Member taps **"Hoàn Thành Tư Vấn"** → confirms in dialog → taps **"Kết Thúc"**.
5. Mobile calls `POST /api/consultations/{consultationId}/end`.
6. Backend responds `200 { is_success: true }`.
7. Mobile navigates to completion/review screen.
8. **Expected:** `ExpertPayout` + `PlatformFee` transactions are inserted.
9. **Actual:** No settlement transactions are inserted. Expert income tab shows 0đ.

---

## Evidence from Mobile Logs

```
📥 RESPONSE [200] => /api/experts/me/consultations
data: {items: [
  {consultationId: 04dd8cad-..., type: Scheduled, status: Completed, price: 2000.0, ...},
  ...
]}
```

Consultation reaches status `Completed` (verified via `/api/experts/me/consultations`), but querying `/api/transactions` with `transType=consultation` shows **no ExpertPayout rows** for that consultationId.

---

## Mobile-Side Behavior (Confirmed Correct)

Mobile calls the endpoint at the right time. Relevant code path:

```
File: lib/features/consultation/screens/members/consultation_waiting_room_screen.dart
Method: _endConsultation()
```

Sequence:
1. User confirms dialog
2. `await repo.endConsultation(widget.consultationId)` — calls `POST /api/consultations/{id}/end`
3. If `is_success == true` → navigate to `/consultation-complete`
4. If `false` → show error snackbar (no navigation)

The mobile-side fix made in this session (RoomExpiry path) is a **separate** issue. The manual "Hoàn Thành Tư Vấn" button correctly calls `/end` before navigating.

---

## Hypothesis

`POST /api/consultations/{id}/end` sets consultation status to `Completed` but does **not** trigger the escrow settlement pipeline. Possible causes:

1. Settlement is triggered by a different event/hook that is not wired to the `/end` endpoint.
2. Settlement logic runs but silently fails (e.g., wallet or escrow record not found).
3. Settlement is conditional on a payment status that was never set to `Held/Escrow`.

---

## What Backend Should Verify

1. **Does `POST /api/consultations/{id}/end` run settlement?**
   - After marking the consultation `Completed`, is `CreateExpertPayoutTransaction()` (or equivalent) called?
   - Check the handler / command for `EndConsultationCommand`.

2. **Is escrow funded before the call starts?**
   - When the member pays for the booking, is the amount held in escrow (`ConsultationEscrow` or similar)?
   - If escrow is never funded, settlement has nothing to release.

3. **Is there a transaction log?**
   - Even if payout fails, is there an error log entries for the settlement attempt?
   - Check application logs around the time `consultationId = 04dd8cad-5f9b-45a1-878b-1012b636647f` was completed.

4. **Is the `feeCost` / `price` being used correctly?**
   - The consultation has `price: 2000.0`.
   - Is the settlement handler reading from the right field?

---

## Sample Consultation IDs to Investigate

| consultationId | status | price | Expected transaction |
|---|---|---|---|
| `04dd8cad-5f9b-45a1-878b-1012b636647f` | Completed | 2000đ | ExpertPayout + PlatformFee |

---

## Expected Behavior After Fix

After calling `POST /api/consultations/{id}/end` with `is_success: true`, the following should be observable:

- `GET /api/transactions?transType=consultation` returns rows with `transactionType = ExpertPayout` linked to the consultation
- Expert's income tab shows the correct earnings
- Platform fee row is also created

---

## Contact

For API contract questions, refer to:  
- `lib/features/consultation/repository/consultation_repository.dart` → `endConsultation()`  
- `lib/features/expert/screens/expert_home_screen.dart` → `_IncomeTabState._fetchPage()` (queries `/api/transactions` with `transType=consultation`)
