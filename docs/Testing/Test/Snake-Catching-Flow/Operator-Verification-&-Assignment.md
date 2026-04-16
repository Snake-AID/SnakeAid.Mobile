# Operator Verification & Assignment - Test Prompt Format For Web AI Bot

## Muc tieu

Tai lieu nay dinh nghia cach viet prompt de AI web bot chay flow Operator tren web portal:

1. Operator xac nhan don (Pending -> Confirmed)
2. Operator phan cong Rescuer (Confirmed -> Assigned)
3. Ghi nhan ket qua test theo dinh dang co the doi chieu voi test sheet

## Prompt Format Chuan

Sao chep mau duoi day va thay gia tri trong dau nhon.

```text
[ROLE]
You are a QA web automation bot testing SnakeAid Operator Portal.

[TEST META]
Test Case ID: <TC_ID>
Flow: Operator Verification & Assignment
Environment: <DEV/UAT/PROD-STAGING>
Base URL: <WEB_PORTAL_URL>
Language: vi-VN UI labels

[GOAL]
Execute Operator flow and verify status transition:
<START_STATUS> -> <TARGET_STATUS>

[PRE-CONDITIONS]
1) Operator account exists: <OPERATOR_EMAIL>
2) A snake catching request exists with status: <PENDING/CONFIRMED>
3) Request reference id: <REQUEST_ID or SEARCH_KEY>
4) At least one eligible rescuer exists for assignment: <YES/NO>

[STRICT UI ACTIONS]
1) Login to Operator Portal with provided account.
2) Open menu/page: <REQUEST_LIST_PAGE_LABEL>.
3) Search request by <REQUEST_ID or customer phone/name>.
4) Open request detail.
5) Click action button: <BUTTON_LABEL_1>.
6) If confirmation modal appears, click: <CONFIRM_BUTTON_LABEL>.
7) For assignment case: choose rescuer <RESCUER_NAME_OR_CODE>.
8) Click assignment button: <BUTTON_LABEL_2>.

[ASSERTIONS - MUST VERIFY]
A) UI status badge changes from <START_STATUS_LABEL> to <TARGET_STATUS_LABEL>.
B) Timeline/history log contains an entry for operator action.
C) Assigned rescuer info is displayed (name/phone/code) for Assigned case.
D) No blocking error toast/snackbar appears.

[NEGATIVE CHECKS]
1) If missing required field, verify validation message text.
2) If no eligible rescuer, verify expected warning and status remains unchanged.

[EVIDENCE OUTPUT FORMAT]
Return exactly in this structure:
- Result: PASS or FAIL
- Executed steps: numbered list of actual clicks
- Assertions:
	- A: PASS/FAIL + observed text
	- B: PASS/FAIL + observed text
	- C: PASS/FAIL + observed text
	- D: PASS/FAIL + observed text
- Final status: <STATUS_TEXT>
- Evidence:
	- Screenshot_1: <what screen proves transition>
	- Screenshot_2: <what screen proves assignment/log>
- Defects:
	- <NONE or defect summary>
```

## Prompt Mau 1 - Confirm Request (Pending -> Confirmed)

```text
You are a QA web automation bot testing SnakeAid Operator Portal.

Test Case ID: TC801
Flow: Operator Verification & Assignment
Environment: UAT
Base URL: https://<operator-portal-url>
Language: vi-VN UI labels

Goal:
Execute operator confirmation and verify Pending -> Confirmed.

Pre-conditions:
1) Operator account exists: operator01@snakeaid.vn
2) Snake catching request exists with status Pending
3) Request ID: SC-REQ-000801

Strict UI actions:
1) Login to portal.
2) Open page Don bat ran.
3) Search SC-REQ-000801.
4) Open detail.
5) Click Xac nhan voi khach.
6) In modal, click Xac nhan.

Assertions:
A) Status badge changes to Confirmed.
B) Timeline has log entry that operator confirmed request.
C) No blocking error toast appears.

Evidence output format:
- Result: PASS/FAIL
- Executed steps
- Assertions A/B/C with observed text
- Final status
- Evidence screenshots
- Defects
```

## Prompt Mau 2 - Assign Rescuer (Confirmed -> Assigned)

```text
You are a QA web automation bot testing SnakeAid Operator Portal.

Test Case ID: TC802
Flow: Operator Verification & Assignment
Environment: UAT
Base URL: https://<operator-portal-url>
Language: vi-VN UI labels

Goal:
Execute assignment and verify Confirmed -> Assigned.

Pre-conditions:
1) Operator account exists: operator01@snakeaid.vn
2) Request is already Confirmed
3) Request ID: SC-REQ-000802
4) Eligible rescuer exists: RESCUER-021

Strict UI actions:
1) Login and open Don bat ran.
2) Search SC-REQ-000802 and open detail.
3) Click Phan cong cuu ho vien.
4) Select rescuer RESCUER-021.
5) Click Xac nhan phan cong.

Assertions:
A) Status changes to Assigned.
B) Rescuer information is visible in request detail.
C) Timeline has assignment log entry.
D) No blocking error toast appears.

Evidence output format:
- Result: PASS/FAIL
- Executed steps
- Assertions A/B/C/D with observed text
- Final status
- Evidence screenshots
- Defects
```

## Prompt Mau 3 - Negative (No Eligible Rescuer)

```text
You are a QA web automation bot testing SnakeAid Operator Portal.

Test Case ID: TC803
Flow: Operator Verification & Assignment
Environment: UAT
Base URL: https://<operator-portal-url>
Language: vi-VN UI labels

Goal:
Verify system behavior when no rescuer is available.

Pre-conditions:
1) Request is Confirmed
2) No eligible rescuer exists in assignment list
3) Request ID: SC-REQ-000803

Strict UI actions:
1) Login and open request detail SC-REQ-000803.
2) Click Phan cong cuu ho vien.
3) Try to assign when list is empty or no selectable rescuer.

Assertions:
A) Warning/empty-state message is shown.
B) Request status remains Confirmed.
C) No fake success message appears.

Evidence output format:
- Result: PASS/FAIL
- Executed steps
- Assertions A/B/C with observed text
- Final status
- Evidence screenshots
- Defects
```

## Checklist Khi Viet Prompt

1. Luon co Request ID cu the.
2. Luon khai bao start status va target status.
3. Dung dung label nut theo UI that (khong viet mo ho).
4. Tach ro action va assertion.
5. Bat buoc yeu cau bot tra ve bang chung (screenshots + observed text).
6. Neu test negative, phai assert status khong thay doi.

