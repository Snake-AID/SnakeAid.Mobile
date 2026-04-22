Feature	Sign Up & Role Registration													
Test requirement	Register using email/password with profile data, accept required terms, complete OTP verification, and continue through role-specific onboarding.													
Number of TCs	7													
Testing Round	Passed	Failed	Pending	N/A										
Round 1	7	0	0	0										
Round 2	7	0	0	0										
Round 3	7	0	0	0										
														
Test Case ID	Test Case Description	Test Case Procedure	Expected Results	Pre-conditions	Round 1	Test date	Tester	Round 2	Test date	Tester	Round 3	Test date	Tester	Note
Sign Up & Role Registration														
TC101	Successful Member sign-up with valid required data	"1. Open the app and select the Member role card ""Người Dùng"". 
2. On the login screen, click ""Đăng ký ngay"". 
3. Enter valid values for all required fields. 
4. Click ""Đăng Ký""."	The system shows "Đăng ký thành công! Mã OTP đã được gửi đến email của bạn" and navigates to OTP verification.	Authentication backend is available; email is not registered.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC102	Expert registration follows approval workflow correctly	"1. Open the app and select the Expert role card ""Chuyên Gia"". 
2. On the login screen, click ""Đăng ký ngay"" and complete required fields. 
3. Click ""Tiếp Tục"" to submit registration. 
4. On ""Xác Thực OTP"" screen, enter a valid 6-digit code. 
5. Continue to the pending approval flow and document submission step ""Nộp Chứng Chỉ"" according to the configured Expert onboarding route."	Expert account is not considered fully verified until OTP succeeds; after successful OTP, user proceeds to pending/document onboarding flow.	Expert approval workflow is enabled; email is not registered; OTP delivery is available.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC103	OTP verification succeeds with a valid 6-digit code	"1. Complete a new registration flow until the ""Xác Thực OTP"" screen appears. 
2. Enter a valid 6-digit OTP. 
3. Click ""Xác Nhận""."	Verification succeeds and user moves to the next step.	A newly registered account exists; valid OTP has been sent to email.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC104	OTP verification is blocked for invalid or incomplete code	"1. Open ""Xác Thực OTP"" screen. 
2. Enter fewer than 6 digits or an invalid code. 
3. Click ""Xác Nhận""."	App shows validation or verification error (for example "Vui lòng nhập đủ 6 số") and stays on OTP screen.	OTP screen is reachable from registration flow.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC105	Required-field validation blocks incomplete sign-up	"1. Open the Member registration screen or the Expert registration screen. 
2. Leave at least one required field empty (for example, Email). 
3. Submit with the role-specific primary action: Member clicks ""Đăng Ký"", Expert clicks ""Tiếp Tục""."	Form submission is blocked and validation errors are displayed at missing fields.	Registration screen is loaded successfully.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC106	Weak password validation is enforced	"1. Open the Member registration screen or the Expert registration screen. 
2. Enter a weak password (too short or missing uppercase/digit). 
3. Submit with the role-specific primary action: Member clicks ""Đăng Ký"", Expert clicks ""Tiếp Tục""."	Validation error is shown (for example "Mật khẩu phải có ít nhất 1 chữ viết hoa" / "Mật khẩu phải có ít nhất 1 chữ số"); account is not created.	Password policy is active.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	
TC107	Confirm-password mismatch is rejected	"1. Open the Member registration screen or the Expert registration screen. 
2. Enter different values for password and confirm password. 
3. Submit with the role-specific primary action: Member clicks ""Đăng Ký"", Expert clicks ""Tiếp Tục""."	The error "Mật khẩu không khớp" is shown and registration request is not sent.	Registration screen is functioning normally.	Passed		KhoaPA	Passed		TrungDN	Passed		DuongNM	