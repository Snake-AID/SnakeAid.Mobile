# BẢNG TÓM TẮT MAJOR FEATURES - SNAKEAID PLATFORM

## Thông tin dự án
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Mục đích:** Nền tảng tích hợp hỗ trợ sơ cứu rắn cắn, nhận diện loài rắn bằng AI, theo dõi cứu hộ, tư vấn chuyên gia và giám sát sự cố

---

| Topic | Description | Primary Actors |
|-------|-------------|----------------|
| **Major Features** | | |
| ***Mobile Application for Patient*** | | |
| Hướng dẫn sơ cứu khẩn cấp | FE-01: Chức năng cung cấp hướng dẫn từng bước khi bị rắn cắn (băng ép, cách xử lý, cảnh báo hành động cấm kỵ).<br>FE-02: Hiển thị hướng dẫn băng ép đúng cách có hình ảnh minh họa.<br>FE-03: Cảnh báo các hành động nguy hiểm cần tránh (đắp lá, rạch vết thương, hút độc...). | **Patient** |
| Gọi cứu hộ khẩn cấp (SOS) | FE-04: Nút SOS gửi vị trí GPS và gọi trực tiếp đến đường dây nóng cấp cứu.<br>FE-05: Tự động chia sẻ vị trí real-time với đội cứu hộ được phân công. | **Patient** |
| Định vị cơ sở điều trị gần nhất | FE-06: Hiển thị bản đồ các bệnh viện/trạm y tế có huyết thanh kháng nọc rắn.<br>FE-07: Tính toán khoảng cách và thời gian ước tính đến từng cơ sở.<br>FE-08: Thông tin chi tiết về loại huyết thanh có sẵn tại mỗi cơ sở (dựa trên dữ liệu admin cập nhật). | **Patient** |
| Theo dõi vết cắn và triệu chứng | FE-09: Cho phép người dùng nhập mô tả triệu chứng (đau, sưng, tê, buồn nôn...).<br>FE-10: Chụp ảnh vết cắn để theo dõi sự tiến triển theo thời gian.<br>FE-11: Lưu trữ lịch sử triệu chứng và ảnh để cung cấp cho bác sĩ hoặc chuyên gia. | **Patient** |
| Nhận diện loài rắn từ hình ảnh (AI) | FE-12: Sử dụng AI để nhận diện loài rắn từ ảnh chụp.<br>FE-13: Hiển thị kết quả: tên rắn, độc tính (có độc/không độc), mức độ nguy hiểm.<br>FE-14: Đề xuất biện pháp sơ cứu phù hợp dựa trên loài rắn được nhận diện. | **Patient** |
| Đánh giá mức độ nghiêm trọng (AI) | FE-15: Phân tích ảnh vết cắn và triệu chứng để đánh giá mức độ nguy hiểm.<br>FE-16: Cảnh báo khẩn cấp và khuyến nghị gọi cấp cứu nếu tình trạng nghiêm trọng.<br>FE-17: Phân loại mức độ: nhẹ, trung bình, nặng, nguy kịch. | **Patient** |
| Báo cáo sự cố rắn cắn / phát hiện rắn | FE-18: Gửi báo cáo vị trí GPS và hình ảnh rắn đến hệ thống.<br>FE-19: Yêu cầu đội cứu hộ rắn đến bắt/di dời rắn.<br>FE-20: Cảnh báo cộng đồng về khu vực có rắn độc xuất hiện. | **Patient** |
| Kiến thức phòng tránh rắn cắn | FE-21: Cung cấp bài viết, video về cách phòng tránh rắn cắn.<br>FE-22: FAQ - Câu hỏi thường gặp về xử lý rắn cắn.<br>FE-23: Thông tin về các loài rắn phổ biến ở từng khu vực. | **Patient** |
| Theo dõi đội cứu hộ real-time | FE-24: Hiển thị vị trí đội cứu hộ đang di chuyển trên bản đồ sau khi yêu cầu cứu hộ.<br>FE-25: Nhận thông báo khi đội cứu hộ đang trên đường đến và khi hoàn thành nhiệm vụ.<br>FE-26: Hiển thị lộ trình và thời gian dự kiến đến nơi. | **Patient** |
| Quản lý thanh toán dịch vụ | FE-27: Thanh toán phí tư vấn chuyên gia rắn trực tuyến.<br>FE-28: Thanh toán phí cứu hộ rắn trực tiếp cho đội cứu hộ qua nền tảng.<br>FE-29: Theo dõi trạng thái thanh toán và hóa đơn điện tử.<br>FE-30: Xem lịch sử giao dịch và chi tiết dịch vụ đã sử dụng. | **Patient** |
| ***Mobile Application for Snake Rescuer*** | | |
| Nhận cảnh báo cứu hộ rắn | FE-01: Nhận thông báo về phát hiện rắn hoặc yêu cầu cứu hộ kèm vị trí và hình ảnh.<br>FE-02: Xem chi tiết yêu cầu: loại rắn dự đoán, mức độ nguy hiểm, thông tin liên hệ. | **Snake Rescuer** |
| Xác nhận và phản hồi nhanh | FE-03: Xác nhận loại rắn (có độc/không độc) từ hình ảnh.<br>FE-04: Cập nhật kết quả xác minh lên hệ thống.<br>FE-05: Gửi thông tin sơ bộ cho người yêu cầu về mức độ nguy hiểm. | **Snake Rescuer** |
| Quản lý nhiệm vụ cứu hộ | FE-06: Chấp nhận hoặc từ chối yêu cầu cứu hộ.<br>FE-07: Cập nhật tiến độ (đang di chuyển, đang xử lý, đã hoàn thành).<br>FE-08: Quản lý danh sách nhiệm vụ: đang chờ, đang thực hiện, đã hoàn thành. | **Snake Rescuer** |
| Hướng dẫn an toàn bắt rắn | FE-09: Quy trình chuẩn để bắt và di dời rắn an toàn.<br>FE-10: Danh sách thiết bị cần thiết và kỹ thuật xử lý từng loài.<br>FE-11: Video hướng dẫn bắt rắn cho từng tình huống. | **Snake Rescuer** |
| Liên lạc với chuyên gia | FE-12: Trao đổi thông tin với chuyên gia rắn để nhận diện chính xác.<br>FE-13: Yêu cầu hỗ trợ từ xa khi gặp loài rắn khó xác định.<br>FE-14: Chia sẻ ảnh/video real-time với chuyên gia. | **Snake Rescuer**<br>**Snake Expert** |
| Ghi nhận và báo cáo hoạt động | FE-15: Ghi nhận chi tiết từng ca cứu hộ (vị trí, thời gian, loài rắn, kết quả).<br>FE-16: Chụp ảnh rắn sau khi bắt để lưu vào cơ sở dữ liệu.<br>FE-17: Tạo báo cáo thống kê hoạt động cứu hộ theo tháng/quý. | **Snake Rescuer** |
| Theo dõi bản đồ và điều hướng | FE-18: Cập nhật vị trí real-time của đội cứu hộ lên hệ thống.<br>FE-19: Hỗ trợ điều hướng đến vị trí của bệnh nhân.<br>FE-20: Gửi thông báo trạng thái (đang đến, đã đến, hoàn thành) cho bệnh nhân. | **Snake Rescuer**<br>**Patient** |
| Nhận diện rắn từ ảnh (AI) | FE-21: Sử dụng AI để nhận diện loài rắn từ ảnh do bệnh nhân gửi.<br>FE-22: Nhận cảnh báo về mức độ nguy hiểm trước khi đến hiện trường.<br>FE-23: Chuẩn bị thiết bị và biện pháp an toàn phù hợp. | **Snake Rescuer** |
| Quản lý doanh thu cứu hộ | FE-24: Chấp nhận yêu cầu cứu hộ có trả phí từ bệnh nhân.<br>FE-25: Theo dõi doanh thu, trạng thái thanh toán và lịch sử giao dịch.<br>FE-26: Nhận thanh toán qua nền tảng sau khi hoàn thành cứu hộ.<br>FE-27: Xem đánh giá và nhận phản hồi từ khách hàng để cải thiện ưu tiên xếp hạng. | **Snake Rescuer** |
| ***Mobile Application for Snake Expert*** | | |
| Xác minh dữ liệu nhận diện | FE-01: Xác nhận loài rắn từ hình ảnh/mô tả do hệ thống hoặc người dùng gửi.<br>FE-02: Sửa đổi kết quả AI nếu nhận diện sai.<br>FE-03: Thêm ghi chú chuyên môn về đặc điểm nhận dạng. | **Snake Expert** |
| Hỗ trợ AI nhận diện loài rắn | FE-04: Sử dụng AI để rút ngắn thời gian xác minh loài rắn.<br>FE-05: Kiểm tra và phê duyệt kết quả AI trước khi công bố.<br>FE-06: Đào tạo và cải thiện mô hình AI bằng cách xác nhận dữ liệu mới. | **Snake Expert** |
| Cập nhật hướng dẫn sơ cứu | FE-07: Cập nhật quy trình xử lý và sơ cứu theo từng loài rắn.<br>FE-08: Biên soạn hướng dẫn chi tiết về triệu chứng và cách xử lý nọc rắn.<br>FE-09: Cung cấp thông tin về liều lượng huyết thanh kháng nọc phù hợp. | **Snake Expert** |
| Tư vấn từ xa | FE-10: Hỗ trợ trực tuyến cho bệnh nhân qua chat/video call.<br>FE-11: Tư vấn cho đội cứu hộ về cách xử lý loài rắn phức tạp.<br>FE-12: Đánh giá tình trạng bệnh nhân và khuyến nghị biện pháp khẩn cấp. | **Snake Expert**<br>**Patient**<br>**Snake Rescuer** |
| Quản lý doanh thu tư vấn | FE-13: Thiết lập mức phí tư vấn trực tuyến.<br>FE-14: Nhận thanh toán qua nền tảng và xuất hóa đơn điện tử.<br>FE-15: Xem báo cáo doanh thu theo tháng/quý.<br>FE-16: Theo dõi số lượt tư vấn và đánh giá từ khách hàng. | **Snake Expert** |
| ***Admin Web Application*** | | |
| Quản lý người dùng và phân quyền | FE-01: Tạo tài khoản cho bệnh nhân, chuyên gia và đội cứu hộ.<br>FE-02: Phân quyền truy cập theo vai trò (Patient, Rescuer, Expert, Admin).<br>FE-03: Quản lý trạng thái tài khoản (kích hoạt, khóa, xóa).<br>FE-04: Xem lịch sử hoạt động của người dùng. | **Admin** |
| Quản lý cơ sở dữ liệu loài rắn | FE-05: Thêm, sửa, xóa thông tin loài rắn (tên khoa học, tên địa phương, đặc điểm, phân bố).<br>FE-06: Upload hình ảnh rắn cho từng loài.<br>FE-07: Quản lý thông tin về hành vi, môi trường sống của rắn.<br>FE-08: Phân loại rắn theo mức độ nguy hiểm và khu vực phân bố. | **Admin** |
| Quản lý cơ sở điều trị | FE-09: Thêm thông tin bệnh viện/trạm y tế (tên, địa chỉ, tọa độ GPS).<br>FE-10: Cập nhật danh sách loại huyết thanh kháng nọc có sẵn tại mỗi cơ sở.<br>FE-11: Quản lý giờ làm việc và thông tin liên hệ khẩn cấp.<br>FE-12: Đánh dấu cơ sở có khả năng điều trị rắn độc 24/7. | **Admin** |
| Quản lý nội dung hệ thống | FE-13: Cập nhật hướng dẫn sơ cứu, thông tin về rắn, khu vực nguy hiểm.<br>FE-14: Biên tập bài viết, video giáo dục về phòng tránh rắn cắn.<br>FE-15: Quản lý FAQ và nội dung trợ giúp người dùng.<br>FE-16: Đăng tin tức cập nhật về tình hình rắn độc theo mùa. | **Admin** |
| Thống kê và báo cáo dữ liệu | FE-17: Thống kê số ca rắn cắn theo khu vực, thời gian, loài rắn.<br>FE-18: Báo cáo số lượt cứu hộ và tỷ lệ hoàn thành của đội cứu hộ.<br>FE-19: Thống kê số lượt tư vấn và đánh giá chuyên gia.<br>FE-20: Phân tích xu hướng và khu vực có nguy cơ cao.<br>FE-21: Xuất báo cáo theo tháng/quý/năm. | **Admin** |
| Cảnh báo và thông báo cộng đồng | FE-22: Gửi cảnh báo về khu vực có rắn độc xuất hiện nhiều.<br>FE-23: Đẩy thông báo hướng dẫn phòng tránh theo mùa.<br>FE-24: Cảnh báo khẩn cấp khi phát hiện loài rắn độc nguy hiểm mới.<br>FE-25: Quản lý danh sách người nhận thông báo theo khu vực. | **Admin** |
| Giám sát hoạt động trên bản đồ | FE-26: Hiển thị real-time các ca cứu hộ đang diễn ra trên bản đồ.<br>FE-27: Theo dõi vị trí đội cứu hộ và trạng thái nhiệm vụ.<br>FE-28: Xem biểu đồ nhiệt về các điểm nóng rắn cắn.<br>FE-29: Giám sát thời gian phản hồi trung bình của đội cứu hộ. | **Admin** |
| Quản lý phí dịch vụ và doanh thu | FE-30: Thiết lập mức phí cho dịch vụ cứu hộ và tư vấn chuyên gia.<br>FE-31: Theo dõi tổng doanh thu và phân chia thu nhập cho rescuer/expert.<br>FE-32: Quản lý thanh toán giữa bệnh nhân – rescuer/expert – nền tảng.<br>FE-33: Tạo báo cáo tài chính định kỳ (tháng/quý/năm).<br>FE-34: Quản lý hoa hồng nền tảng và chính sách hoàn tiền.<br>FE-35: Xử lý tranh chấp thanh toán và yêu cầu hoàn tiền. | **Admin** |

---

## Ghi chú
- **FE:** Feature (Tính năng chức năng)
- Mỗi module bắt đầu lại từ FE-01 để dễ quản lý và theo dõi
- Primary Actors bao gồm: **Patient** (Bệnh nhân), **Snake Rescuer** (Đội cứu hộ rắn), **Snake Expert** (Chuyên gia rắn), **Admin** (Quản trị viên)

---
---

# MAJOR FEATURES SUMMARY TABLE - SNAKEAID PLATFORM (ENGLISH VERSION)

## Project Information
- **Project Name:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Purpose:** Integrated platform for snakebite first aid support, AI-powered snake species identification, rescue tracking, expert consultation, and incident monitoring

---

| Topic | Description | Primary Actors |
|-------|-------------|----------------|
| **Major Features** | | |
| ***Mobile Application for Patient*** | | |
| Emergency First Aid Guidance | FE-01: Provide step-by-step guidance when bitten by a snake (compression bandage, treatment methods, prohibited action warnings).<br>FE-02: Display proper compression bandage instructions with illustrated images.<br>FE-03: Warn against dangerous actions to avoid (applying leaves, cutting wound, sucking venom...). | **Patient** |
| Emergency Rescue Call (SOS) | FE-04: SOS button sends GPS location and directly calls emergency hotline.<br>FE-05: Automatically share real-time location with assigned rescue team. | **Patient** |
| Locate Nearest Treatment Facility | FE-06: Display map of hospitals/medical stations with snake antivenom.<br>FE-07: Calculate distance and estimated time to each facility.<br>FE-08: Detailed information about available antivenom types at each facility (based on admin-updated data). | **Patient** |
| Track Bite and Symptoms | FE-09: Allow users to input symptom descriptions (pain, swelling, numbness, nausea...).<br>FE-10: Take photos of bite to track progression over time.<br>FE-11: Store symptom history and photos to provide to doctors or experts. | **Patient** |
| Identify Snake Species from Image (AI) | FE-12: Use AI to identify snake species from photos.<br>FE-13: Display results: snake name, toxicity (venomous/non-venomous), danger level.<br>FE-14: Suggest appropriate first aid measures based on identified snake species. | **Patient** |
| Assess Severity Level (AI) | FE-15: Analyze bite photos and symptoms to assess danger level.<br>FE-16: Issue emergency warning and recommend calling emergency services if critical.<br>FE-17: Classify severity levels: mild, moderate, severe, critical. | **Patient** |
| Report Snakebite Incident / Snake Sighting | FE-18: Send GPS location report and snake images to system.<br>FE-19: Request snake rescue team to capture/relocate snake.<br>FE-20: Alert community about areas with venomous snake presence. | **Patient** |
| Snake Prevention Knowledge | FE-21: Provide articles, videos about snake bite prevention.<br>FE-22: FAQ - Frequently asked questions about snakebite treatment.<br>FE-23: Information about common snake species in each area. | **Patient** |
| Track Rescue Team Real-time | FE-24: Display rescue team's moving location on map after requesting rescue.<br>FE-25: Receive notifications when rescue team is en route and when mission is completed.<br>FE-26: Display route and estimated arrival time. | **Patient** |
| Service Payment Management | FE-27: Pay online snake expert consultation fees.<br>FE-28: Pay snake rescue fees directly to rescue teams via platform.<br>FE-29: Track payment status and electronic invoices.<br>FE-30: View transaction history and used service details. | **Patient** |
| ***Mobile Application for Snake Rescuer*** | | |
| Receive Snake Rescue Alerts | FE-01: Receive notifications about snake sightings or rescue requests with location and images.<br>FE-02: View request details: predicted snake type, danger level, contact information. | **Snake Rescuer** |
| Quick Confirmation and Response | FE-03: Confirm snake type (venomous/non-venomous) from images.<br>FE-04: Update verification results to system.<br>FE-05: Send preliminary information to requester about danger level. | **Snake Rescuer** |
| Rescue Task Management | FE-06: Accept or decline rescue requests.<br>FE-07: Update progress (moving, processing, completed).<br>FE-08: Manage task list: pending, in progress, completed. | **Snake Rescuer** |
| Safe Snake Capture Guidance | FE-09: Standard procedures for safely capturing and relocating snakes.<br>FE-10: List of necessary equipment and handling techniques for each species.<br>FE-11: Video tutorials for snake capture in various situations. | **Snake Rescuer** |
| Communication with Experts | FE-12: Exchange information with snake experts for accurate identification.<br>FE-13: Request remote support when encountering difficult-to-identify snake species.<br>FE-14: Share real-time photos/videos with experts. | **Snake Rescuer**<br>**Snake Expert** |
| Record and Report Activities | FE-15: Record detailed rescue cases (location, time, snake species, results).<br>FE-16: Take photos of captured snakes to store in database.<br>FE-17: Create statistical reports on rescue activities by month/quarter. | **Snake Rescuer** |
| Map Tracking and Navigation | FE-18: Update rescue team's real-time location to system.<br>FE-19: Support navigation to patient's location.<br>FE-20: Send status notifications (en route, arrived, completed) to patient. | **Snake Rescuer**<br>**Patient** |
| Snake Identification from Image (AI) | FE-21: Use AI to identify snake species from patient-submitted images.<br>FE-22: Receive warnings about danger level before arriving at scene.<br>FE-23: Prepare appropriate equipment and safety measures. | **Snake Rescuer** |
| Rescue Revenue Management | FE-24: Accept paid rescue requests from patients.<br>FE-25: Track revenue, payment status, and transaction history.<br>FE-26: Receive payment via platform after rescue completion.<br>FE-27: View ratings and receive customer feedback to improve priority ranking. | **Snake Rescuer** |
| ***Mobile Application for Snake Expert*** | | |
| Verify Identification Data | FE-01: Confirm snake species from images/descriptions submitted by system or users.<br>FE-02: Modify AI results if identification is incorrect.<br>FE-03: Add professional notes on identification characteristics. | **Snake Expert** |
| Support AI Snake Identification | FE-04: Use AI to shorten snake species verification time.<br>FE-05: Review and approve AI results before publication.<br>FE-06: Train and improve AI model by confirming new data. | **Snake Expert** |
| Update First Aid Guidelines | FE-07: Update treatment and first aid procedures for each snake species.<br>FE-08: Compile detailed guidelines on symptoms and snake venom treatment methods.<br>FE-09: Provide information on appropriate antivenom dosages. | **Snake Expert** |
| Remote Consultation | FE-10: Provide online support for patients via chat/video call.<br>FE-11: Consult rescue teams on handling complex snake species.<br>FE-12: Assess patient condition and recommend emergency measures. | **Snake Expert**<br>**Patient**<br>**Snake Rescuer** |
| Consultation Revenue Management | FE-13: Set online consultation fee rates.<br>FE-14: Receive payment via platform and issue electronic invoices.<br>FE-15: View revenue reports by month/quarter.<br>FE-16: Track consultation sessions and customer reviews. | **Snake Expert** |
| ***Admin Web Application*** | | |
| User and Permission Management | FE-01: Create accounts for patients, experts, and rescue teams.<br>FE-02: Assign access permissions by role (Patient, Rescuer, Expert, Admin).<br>FE-03: Manage account status (activate, lock, delete).<br>FE-04: View user activity history. | **Admin** |
| Snake Species Database Management | FE-05: Add, edit, delete snake species information (scientific name, local name, characteristics, distribution).<br>FE-06: Upload snake images for each species.<br>FE-07: Manage information about snake behavior and habitat.<br>FE-08: Classify snakes by danger level and distribution area. | **Admin** |
| Treatment Facility Management | FE-09: Add hospital/medical station information (name, address, GPS coordinates).<br>FE-10: Update list of available antivenom types at each facility.<br>FE-11: Manage operating hours and emergency contact information.<br>FE-12: Mark facilities capable of treating venomous snake bites 24/7. | **Admin** |
| System Content Management | FE-13: Update first aid guidelines, snake information, dangerous areas.<br>FE-14: Edit articles, educational videos on snake bite prevention.<br>FE-15: Manage FAQ and user help content.<br>FE-16: Post news updates on seasonal venomous snake situations. | **Admin** |
| Data Statistics and Reporting | FE-17: Compile snakebite cases by region, time, snake species.<br>FE-18: Report rescue operations and rescue team completion rates.<br>FE-19: Compile consultation statistics and expert reviews.<br>FE-20: Analyze trends and high-risk areas.<br>FE-21: Export reports by month/quarter/year. | **Admin** |
| Community Alerts and Announcements | FE-22: Send alerts about areas with frequent venomous snake appearances.<br>FE-23: Push seasonal prevention guidance notifications.<br>FE-24: Issue emergency alerts when new dangerous venomous snake species detected.<br>FE-25: Manage notification recipient list by area. | **Admin** |
| Map Activity Monitoring | FE-26: Display real-time ongoing rescue cases on map.<br>FE-27: Track rescue team locations and task status.<br>FE-28: View heat map of snakebite hotspots.<br>FE-29: Monitor average response time of rescue teams. | **Admin** |
| Service Fee and Revenue Management | FE-30: Set fee rates for rescue services and expert consultation.<br>FE-31: Track total revenue and distribute income to rescuers/experts.<br>FE-32: Manage payments between patients – rescuers/experts – platform.<br>FE-33: Create periodic financial reports (monthly/quarterly/yearly).<br>FE-34: Manage platform commission and refund policies.<br>FE-35: Handle payment disputes and refund requests. | **Admin** |

---

## Notes
- **FE:** Feature (Functional Feature)
- Each module starts from FE-01 for easier management and tracking
- Primary Actors include: **Patient**, **Snake Rescuer**, **Snake Expert**, **Admin**
