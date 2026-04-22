# Create Snake Catching Request

## Summary

| Field | Value |
|---|---|
| Feature | Create Snake Catching Request (Images, GPS, Species) |
| Test requirement | Create request from "Báo Cáo Phát Hiện Rắn" with required location + address detail; support both flows "Chụp Ảnh" and "Chọn Loài Rắn" |
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
| TC601 | Create request successfully via photo flow (single) | 1) Open Home as Member<br>2) Open "Báo Cáo Phát Hiện Rắn"<br>3) Select "1 loài rắn" and click "Tiếp tục"<br>4) Keep tab "Chụp Ảnh"<br>5) Add slot-1 image via "Chụp ảnh" or "Album ảnh"<br>6) Click "Chọn vị trí" and select address or "Lấy vị trí hiện tại"<br>7) Fill "GHI CHÚ ĐỊA CHỈ CHI TIẾT *"<br>8) Click "Gửi Báo Cáo" | Request is created and app navigates to success screen with "Yêu Cầu Đã Được Gửi!" | Member logged in; internet available; create-request API available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC602 | Create request successfully via manual species flow | 1) Open report flow and select "1 loài rắn" -> "Tiếp tục"<br>2) Switch to tab "Chọn Loài Rắn"<br>3) Select one species<br>4) Set location via "Chọn vị trí" dialog<br>5) Fill "GHI CHÚ ĐỊA CHỈ CHI TIẾT *"<br>6) Click "Gửi Báo Cáo" | Request is submitted successfully and success screen is shown | Member logged in; species API available | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC603 | Block continue when quantity not selected | 1) Open "Báo Cáo Phát Hiện Rắn"<br>2) Do not select "1 loài rắn"/"2-5 loài rắn"/"Ổ rắn"<br>3) Observe "Tiếp tục" | "Tiếp tục" is disabled; cannot go to detail screen | Member is on quantity selection screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC604 | Block submit when location is missing | 1) Prepare valid photo/species data in detail screen<br>2) Fill "GHI CHÚ ĐỊA CHỈ CHI TIẾT *"<br>3) Keep location unset<br>4) Trigger submit path | Submission is blocked and snackbar "Vui lòng chọn vị trí trước khi gửi" is shown | Member is on report detail screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC605 | Require address detail before submit | 1) In detail screen, set valid location + valid photo/species data<br>2) Leave "GHI CHÚ ĐỊA CHỈ CHI TIẾT *" empty<br>3) Observe "Gửi Báo Cáo" | "Gửi Báo Cáo" remains disabled until address detail is entered | Member is on report detail screen | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC606 | No AI detection -> switch to manual species | 1) In tab "Chụp Ảnh", upload image with no AI detection<br>2) Click "Gửi Báo Cáo"<br>3) In dialog "Không nhận diện được rắn", click "Chọn loài rắn thủ công" | Dialog closes and app switches to tab "Chọn Loài Rắn" | At least one photo uploaded; AI returns no detection | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC607 | No AI detection -> still continue submit | 1) In tab "Chụp Ảnh", upload image with no AI detection<br>2) Click "Gửi Báo Cáo"<br>3) In dialog "Không nhận diện được rắn", click "Tiếp tục gửi" | System still creates request and navigates to success screen | Required fields valid; AI returns no detection | Pending |  |  | Pending |  |  | Pending |  |  |  |
| TC608 | Validate species selection in manual tab | 1) Switch to "Chọn Loài Rắn"<br>2) Set location + fill "GHI CHÚ ĐỊA CHỈ CHI TIẾT *"<br>3) Do not pick any species<br>4) Click "Gửi Báo Cáo" | Validation error is shown ("Vui lòng chọn loài rắn" or "Vui lòng chọn ít nhất 1 loài rắn") and request is not submitted | Member is on manual species tab | Pending |  |  | Pending |  |  | Pending |  |  |  |
