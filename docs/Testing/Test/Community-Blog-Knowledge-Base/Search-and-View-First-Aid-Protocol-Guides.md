# Search & View First Aid Protocol Guides

## Summary

| Field | Value |
|---|---|
| Feature | Search & View First Aid Protocol Guides |
| Test requirement | Verify the main first-aid guide flow from Snake Library: open species detail, use button "Xem cách sơ cứu khi bị loài này cắn", and read first-aid protocol content |
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
| TC2801 | Member opens first-aid guide from snake detail | 1) Login as Member<br>2) Open "Thư viện loài rắn"<br>3) Open one snake detail<br>4) Tap "Xem cách sơ cứu khi bị loài này cắn" | App navigates to species first-aid screen successfully | Member can access snake library and species detail | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2802 | Rescuer opens first-aid guide from snake detail | 1) Login as Rescuer<br>2) Open "Thư Viện Loài" from Home<br>3) Open one snake detail<br>4) Tap "Xem cách sơ cứu khi bị loài này cắn" | App opens first-aid screen via same detail CTA flow | Rescuer can access snake library and species detail | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2803 | Expert opens first-aid guide from snake detail | 1) Login as Expert<br>2) Open "Thư Viện Loài" from Home<br>3) Open one snake detail<br>4) Tap "Xem cách sơ cứu khi bị loài này cắn" | App opens first-aid guide screen from selected species detail | Expert can access snake library and species detail | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2804 | Verify first-aid header/title matches selected species | 1) Open first-aid from selected snake detail<br>2) Observe app bar title | App bar displays species-specific title format "Sơ cứu: {commonName}" when name is provided | First-aid guide screen is opened from detail | Pending |  |  | Pending |  |  | Pending |  |  | Core mapping behavior |
| TC2805 | Verify first-aid protocol sections are rendered | 1) Open first-aid guide<br>2) Review content blocks | Screen shows key guidance sections such as "Các bước sơ cứu", "Nên làm", "Không nên làm", and "Lưu ý" when available | A species guideline exists in backend data | Pending |  |  | Pending |  |  | Pending |  |  | Main content behavior |
| TC2806 | Verify warning/emergency banner visibility | 1) Open first-aid guide<br>2) Inspect top notice area | Emergency banner is visible with warning message that this is initial guidance and user should go to medical facility immediately | First-aid guide screen is loaded | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2807 | Verify first-aid loading and retry on error | 1) Open first-aid with unstable network/API<br>2) Observe loading/error state<br>3) Tap "Thử lại" | Loading indicator appears during fetch; on failure, screen shows error text and "Thử lại" reload action | Test environment can simulate network/API failure | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2808 | Verify related search path in library before opening first-aid | 1) Open snake library<br>2) Search with "Tìm kiếm tên loài rắn..."<br>3) Open matched snake detail<br>4) Tap first-aid CTA | User can search species, open its detail, and continue into the correct first-aid protocol flow | Snake library contains searchable species data | Pending |  |  | Pending |  |  | Pending |  |  | End-to-end main path |
