# Search & View Snake Library

## Summary

| Field | Value |
|---|---|
| Feature | Search & View Snake Library (All Roles) |
| Test requirement | Verify the main snake library flow across Member, Rescuer, and Expert home entry points, including search, empty/error handling, and viewing species detail |
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
| TC2701 | Member opens snake library from Home | 1) Login as Member<br>2) On Home, tap tile "Thư viện\nloài rắn"<br>3) Observe screen | App opens snake library screen with title "Thư viện loài rắn" | Member account is logged in and Home menu is visible | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2702 | Rescuer opens snake library from Home | 1) Login as Rescuer<br>2) On Home section "Thư Viện Loài Rắn", tap card "Thư Viện Loài"<br>3) Observe screen | App opens snake library successfully via route "rescuer_snake_library" | Rescuer account is logged in and Home content is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2703 | Expert opens snake library from Home | 1) Login as Expert<br>2) On Home section "Công Cụ Hỗ Trợ", tap card "Thư Viện Loài"<br>3) Observe screen | App opens snake library successfully via route "expert_snake_library" | Expert account is logged in and Home content is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2704 | Search species by name in library | 1) Open "Thư viện loài rắn" screen<br>2) Enter keyword into "Tìm kiếm tên loài rắn..."<br>3) Observe results | List is filtered according to keyword and count bar updates to matching species | Library screen has loaded species list | Pending |  |  | Pending |  |  | Pending |  |  | Core search behavior |
| TC2705 | Clear search keyword and restore full list | 1) Enter any keyword in search box<br>2) Tap clear icon<br>3) Observe list and count | Search text is cleared, filter resets, and full species list is shown again | Library screen is open with search text entered | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2706 | Show no-result state when search has no match | 1) Open library<br>2) Enter unmatched keyword<br>3) Observe UI | App shows empty state text "Không tìm thấy loài rắn nào." | Library screen is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2707 | Open species detail from library card | 1) Open library list<br>2) Tap one snake card<br>3) Observe navigation | App navigates to species detail route /snake-species/:id and displays detail content | At least one species exists in library list | Pending |  |  | Pending |  |  | Pending |  |  | Core view behavior |
| TC2708 | Validate loading and error retry behavior | 1) Open library under unstable network/API error condition<br>2) Observe loading/error UI<br>3) Tap "Thử lại" | Loading indicator is shown while fetching; on error, retry button "Thử lại" appears and triggers reload when tapped | Test environment can simulate API failure or network interruption | Pending |  |  | Pending |  |  | Pending |  |  |  |
