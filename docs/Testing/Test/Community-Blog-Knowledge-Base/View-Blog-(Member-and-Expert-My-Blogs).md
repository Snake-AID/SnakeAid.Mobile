# View Blog

## Summary

| Field | Value |
|---|---|
| Feature | View Blog (Member + Expert My Blogs) |
| Test requirement | Verify main viewing journeys for member public blogs and expert personal blog list (tabs/status), focusing on key read/browse behavior only |
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
| TC2501 | Member opens blog list screen | 1) Login as Member<br>2) Open blog list entry point<br>3) Observe screen header | Screen opens with title "Bài Viết" and shows list area with search/filter section | Member account is logged in | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2502 | Member searches blog by keyword | 1) Open "Bài Viết"<br>2) Enter keyword into "Tìm kiếm bài viết..."<br>3) Clear keyword using clear icon | List updates according to keyword and resets after clearing search text | At least one blog exists in data source | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2503 | Member filters blogs by category chip | 1) Open "Bài Viết"<br>2) Tap category chips (including "Tất cả")<br>3) Observe result list | Blog list changes based on selected category and can return to full list with "Tất cả" | Blog data contains multiple categories | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2504 | Member opens blog detail and reads content | 1) From list, tap one blog card<br>2) Observe detail screen<br>3) Verify key metadata | Blog detail shows title/content, author info, reading time ("phút đọc"), view count ("lượt xem"), and like count ("lượt thích") | Member can access at least one blog item | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2505 | Member toggles like state from list or detail | 1) Open list or detail<br>2) Tap like control once<br>3) Tap again | Like state toggles correctly (icon/count updates for like and unlike) without leaving the screen | Blog item is visible and interactive | Pending |  |  | Pending |  |  | Pending |  |  | Main behavior only |
| TC2506 | Expert opens "Bài Viết Của Tôi" list | 1) Login as Expert<br>2) Open route /expert/blogs<br>3) Observe header and tabs | Screen shows title "Bài Viết Của Tôi" with status tabs: "Tất cả", "Bản nháp", "Chờ duyệt", "Đã đăng", "Bị từ chối" | Expert account is logged in | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2507 | Expert switches tabs to view blog groups by status | 1) Open "Bài Viết Của Tôi"<br>2) Switch through each status tab<br>3) Observe list content | Each tab shows corresponding blog subset; if no data, UI shows "Không có bài viết nào" | Expert has at least one blog or empty-state is allowed | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC2508 | Expert refreshes personal blog list | 1) Open "Bài Viết Của Tôi"<br>2) Pull to refresh in current tab<br>3) Observe data reloaded state | RefreshIndicator reloads blog data and keeps user on current view flow | Expert blog list screen is open and network is available | Pending |  |  | Pending |  |  | Pending |  |  |  |
