Feature	Create Snake Catching Request (Images, GPS, Species)														
Test requirement	Member can create a snake catching request from quantity selection to request submission with required Images/GPS/Address Detail, using either photo-AI flow ("Chụp Ảnh") or manual species flow ("Chọn Loài Rắn").														
Number of TCs	8														
Testing Round	Passed	Failed	Pending	N/A											
Round 1	0	0	8	0											
Round 2	0	0	8	0											
Round 3	0	0	8	0											
															
Test Case ID	Test Case Description	Test Case Procedure	Expected Results	Pre-conditions	Round 1	Test date	Tester	Round 2	Test date	Tester	Round 3	Test date	Tester	Note
Create Snake Catching Request														
TC601	Create request successfully via photo flow (single species)	"1. Login as Member and open Home screen.
2. Click quick action to open ""Báo Cáo Phát Hiện Rắn"".
3. On quantity screen, select ""1 loài rắn"" and click ""Tiếp tục"".
4. Keep tab ""Chụp Ảnh"".
5. At photo slot 1, choose image source and click ""Chụp ảnh"" (or ""Album ảnh"").
6. Click location block ""Chọn vị trí"" -> in dialog ""Chọn vị trí"", select a result or click ""Lấy vị trí hiện tại"".
7. Fill required field ""GHI CHÚ ĐỊA CHỈ CHI TIẾT *"".
8. Click ""Gửi Báo Cáo""." 	Request is created successfully and app navigates to success screen showing "Yêu Cầu Đã Được Gửi!".	Member account is logged in; internet connection is available; backend create-request API is available.	Pending			Pending			Pending			
TC602	Create request successfully via manual species tab	"1. Open ""Báo Cáo Phát Hiện Rắn"" -> select ""1 loài rắn"" -> click ""Tiếp tục"".
2. Switch to tab ""Chọn Loài Rắn"".
3. Select one snake species from list.
4. Click ""Chọn vị trí"" and choose address in ""Chọn vị trí"" dialog (or click ""Lấy vị trí hiện tại"").
5. Fill ""GHI CHÚ ĐỊA CHỈ CHI TIẾT *"".
6. Click ""Gửi Báo Cáo""." 	Request is submitted successfully and success screen "Yêu Cầu Đã Được Gửi!" is displayed.	Member account is logged in; species list API is available.	Pending			Pending			Pending			
TC603	Quantity selection is required before continuing	"1. Open ""Báo Cáo Phát Hiện Rắn"" screen.
2. Do not select any option (""1 loài rắn"", ""2-5 loài rắn"", ""Ổ rắn"").
3. Observe button ""Tiếp tục""." 	""Tiếp tục"" remains disabled; user cannot navigate to detail report screen.	Member is on snake quantity selection screen.	Pending			Pending			Pending			
TC604	Location is mandatory before submit	"1. Open report detail screen and keep valid input for photo/species path.
2. Upload/select required data so that only location is missing.
3. Fill ""GHI CHÚ ĐỊA CHỈ CHI TIẾT *"".
4. Trigger submit (or call flow that reaches submit without location)." 	App blocks submission and shows snackbar: "Vui lòng chọn vị trí trước khi gửi".	Member is on snake report detail screen.	Pending			Pending			Pending			
TC605	Address detail is required by form before submit	"1. Open report detail and provide location + valid photo/species data.
2. Leave ""GHI CHÚ ĐỊA CHỈ CHI TIẾT *"" empty.
3. Observe primary action ""Gửi Báo Cáo""." 	""Gửi Báo Cáo"" is disabled until the required address-detail field is filled.	Member is on snake report detail screen.	Pending			Pending			Pending			
TC606	No AI detection: user chooses manual species path	"1. On tab ""Chụp Ảnh"", upload a photo that AI cannot detect.
2. Click ""Gửi Báo Cáo"".
3. In warning dialog ""Không nhận diện được rắn"", click ""Chọn loài rắn thủ công""." 	Dialog closes and screen switches to tab "Chọn Loài Rắn" for manual selection instead of submitting immediately.	Member is on photo tab with at least one uploaded image; AI returns no detection.	Pending			Pending			Pending			
TC607	No AI detection: user still submits request	"1. On tab ""Chụp Ảnh"", upload a photo that AI cannot detect.
2. Click ""Gửi Báo Cáo"".
3. In warning dialog ""Không nhận diện được rắn"", click ""Tiếp tục gửi""." 	System proceeds to create request and navigates to success screen "Yêu Cầu Đã Được Gửi!".	Member is on photo tab with valid required fields; AI returns no detection.	Pending			Pending			Pending			
TC608	Species tab validation blocks submit without species	"1. Open detail screen and switch to ""Chọn Loài Rắn"".
2. Complete location and ""GHI CHÚ ĐỊA CHỈ CHI TIẾT *"".
3. Do not choose any species.
4. Click ""Gửi Báo Cáo""." 	App shows validation snackbar (for example "Vui lòng chọn loài rắn" or "Vui lòng chọn ít nhất 1 loài rắn") and request is not submitted.	Member is on species tab.	Pending			Pending			Pending			
