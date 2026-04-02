# Blog Rich Content – Test Data (POST payloads)

> All 6 payloads below target `POST /api/blogs`.  
> Images use **Unsplash CDN** (no Wikipedia). Replace with real assets in production.

---

## Payload 1 – Sơ Cứu Khẩn Cấp Khi Bị Rắn Cắn

```json
{
  "title": "Hướng Dẫn Sơ Cứu Khẩn Cấp Khi Bị Rắn Cắn",
  "thumbnailUrl": "https://images.unsplash.com/photo-1584714268709-c3dd9c92b378?w=800&auto=format&fit=crop",
  "category": "SnakeHealth",
  "tags": ["Safety", "Venomous"],
  "readingTime": 5,
  "status": "Published",
  "content": "## 🚨 Tình Huống Khẩn Cấp: Ngay Khi Bị Cắn\n\nKhi bị rắn cắn, mỗi giây đều có giá trị. Hãy bình tĩnh và làm theo các bước dưới đây.\n\n---\n\n## Bước 1 – Rời Xa Rắn An Toàn\n\n> ⚠️ **TUYỆT ĐỐI KHÔNG cố bắt hoặc giết rắn.** Rắn có thể cắn lần 2 dù đã chết (phản xạ tự nhiên kéo dài đến 60 phút sau khi chết).\n\n![Rắn hổ mang trong tự nhiên – hãy giữ khoảng cách an toàn](https://images.unsplash.com/photo-1561484930-998b6a7b22e8?w=800&auto=format&fit=crop)\n\n## Bước 2 – Đặt Nạn Nhân Nằm Yên\n\n- Giữ phần bị cắn **thấp hơn tim** để làm chậm lan truyền nọc độc\n- Tháo nhẫn, vòng tay, đồng hồ gần vết cắn (vì sưng nề sẽ xảy ra nhanh)\n- Dùng bút **đánh dấu viền sưng** và ghi giờ để theo dõi tốc độ lan\n\n---\n\n## Bước 3 – Làm Sạch Vết Thương Đúng Cách\n\n![Rửa vết thương bằng nước sạch và xà phòng](https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&auto=format&fit=crop)\n\nRửa nhẹ nhàng bằng nước sạch và xà phòng trong **15 giây**. Che vết thương bằng băng sạch, không băng quá chặt.\n\n---\n\n## Bước 4 – Gọi Cấp Cứu & Đến Viện\n\n> ✅ **Ghi nhớ đặc điểm rắn:** màu sắc, hoa văn, hình dạng đầu (không cần lại gần). Chụp ảnh từ xa nếu an toàn. Điều này giúp bác sĩ chọn huyết thanh chính xác.\n\n### Không được làm:\n\n1. ❌ Rạch vết thương, hút nọc bằng miệng\n2. ❌ Chườm đá trực tiếp lên vết cắn\n3. ❌ Garô hay buộc chặt chi bị cắn\n4. ❌ Uống rượu hoặc thuốc không theo chỉ dẫn\n\n---\n\n> ℹ️ **Đường dây cấp cứu:** 115 (trong nước) · Trung tâm Chống độc – BV Bạch Mai: (024) 3869 3731\n"
}
```

---

## Payload 2 – Nhận Dạng Rắn Hổ Mang

```json
{
  "title": "Cách Nhận Dạng Rắn Hổ Mang Chúa Và Phân Biệt Với Rắn Lành",
  "thumbnailUrl": "https://images.unsplash.com/photo-1531386151447-fd76ad50012f?w=800&auto=format&fit=crop",
  "category": "SnakeSpecies",
  "tags": ["Venomous", "SnakeIdentification", "WildSnake"],
  "readingTime": 6,
  "status": "Published",
  "content": "# Nhận Dạng Rắn Hổ Mang Chúa (*Ophiophagus hannah*)\n\nRắn hổ mang chúa là loài rắn **độc dài nhất thế giới**, có thể đạt tới **5,5 mét**. Tuy nhiên việc nhận dạng chính xác sẽ giúp bạn phân biệt với các loài rắn lành vô hại.\n\n---\n\n## So Sánh Nhanh\n\n| Đặc điểm | Hổ Mang Chúa | Rắn lành thường |\n|---|---|---|\n| Kích thước | 3 – 5.5 m | Dưới 2 m |\n| Màu sắc | Nâu olive / đen, vân trắng | Đa dạng |\n| Cổ bành | **Có** (mang rộng) | Không |\n| Mắt | Tròn, màu vàng | Tròn hoặc elip |\n| Đầu | Hình oval, to | Nhỏ hơn |\n\n---\n\n## 3 Dấu Hiệu Nhận Dạng Chính\n\n### 1. Mang Cổ Đặc Trưng\n\n![Hổ mang bành mang cổ khi bị đe dọa](https://images.unsplash.com/photo-1527842891421-42eec6e703ea?w=800&auto=format&fit=crop)\n\nKhi bị đe dọa, hổ mang **dựng đứng 1/3 thân trước** và bành mang cổ rộng. Đây là dấu hiệu quan trọng nhất.\n\n### 2. Vảy Đầu Đặc Biệt\n\nHổ mang chúa có **2 vảy đỉnh đầu lớn** (occipital scales) – nét đặc trưng phân biệt với các loài hổ mang thường. Dấu hiệu này chỉ quan sát được khi đã ở gần – **không khuyến khích tiếp cận**.\n\n### 3. Âm Thanh Đặc Trưng\n\n> ⚠️ Hổ mang chúa phát ra âm thanh **\"gầm\" trầm, khàn** khác với tiếng rít của rắn thông thường. Nếu nghe thấy, **lui ngay lập tức**.\n\n---\n\n## Các Loài Hay Bị Nhầm Lẫn\n\n![Rắn ráo thường bị nhầm với rắn độc do hoa văn tương tự](https://images.unsplash.com/photo-1551189014-fe516d44f0e2?w=800&auto=format&fit=crop)\n\n- **Rắn ráo (Ptyas mucosa):** Lớn, đen bóng, nhưng **không có mang** và đầu nhỏ hơn\n- **Rắn nước (Xenochrophis flavipunctatus):** Sọc vàng xanh, vô hại hoàn toàn\n- **Rắn roi (Ahaetulla prasina):** Xanh lá, thân mỏng như que – không độc\n\n> ✅ **Quy tắc vàng:** Nếu không chắc chắn 100% — **coi mọi rắn đều có độc** và giữ khoảng cách tối thiểu 3 mét.\n"
}
```

---

## Payload 3 – Mùa Sinh Sản Của Rắn

```json
{
  "title": "Mùa Sinh Sản Của Rắn: Khi Nào Nguy Cơ Bị Cắn Cao Nhất?",
  "thumbnailUrl": "https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=800&auto=format&fit=crop",
  "category": "SnakeBehavior",
  "tags": ["WildSnake", "SnakeBehavior", "Safety"],
  "readingTime": 4,
  "status": "Published",
  "content": "## Rắn Hoạt Động Mạnh Nhất Khi Nào?\n\nHiểu được chu kỳ sinh học của rắn giúp bạn phòng tránh rủi ro một cách chủ động.\n\n---\n\n## Lịch Hoạt Động Theo Mùa\n\n### 🌱 Tháng 3 – 5: Mùa Giao Phối\n\n![Rắn di chuyển nhiều hơn trong mùa giao phối](https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&auto=format&fit=crop)\n\nĐây là giai đoạn **nguy hiểm nhất trong năm**. Rắn đực di chuyển rộng để tìm con cái, xuất hiện ở nhiều địa điểm bất ngờ: hành lang nhà, sân vườn, bụi rậm.\n\n> ⚠️ Số ca rắn cắn tại Việt Nam tăng **200–300%** trong giai đoạn tháng 3–5 so với các tháng còn lại.\n\n### ☀️ Tháng 6 – 8: Mùa Đẻ Trứng / Sinh Con\n\n- Rắn mẹ trở nên **hung hăng bảo vệ ổ**\n- Các tổ rắn thường ở gốc cây mục, đống lá, đống gạch\n- Ban đêm rắn ra ngoài kiếm ăn nhiều hơn do trời mát\n\n### 🍂 Tháng 9 – 11: Chuẩn Bị Đông\n\n![Rắn tìm nơi ẩn náu ấm áp trước mùa đông](https://images.unsplash.com/photo-1508264165352-258db2ebd59b?w=800&auto=format&fit=crop)\n\nRắn ăn nhiều và tích trữ năng lượng. Chúng tìm vào các chỗ ấm: nhà kho, chuồng trại, đống củi.\n\n> 💡 **Mẹo phòng tránh:** Dọn dẹp đống củi, mảnh gỗ, và cỏ rậm quanh nhà trước tháng 9. Dùng đèn pin khi ra ngoài ban đêm.\n\n---\n\n## Thời Gian Hoạt Động Trong Ngày\n\n| Loài | Thời gian hoạt động chính |\n|---|---|\n| Hổ mang | Sáng sớm & chiều tối |\n| Cạp nong / Cạp nia | **Ban đêm** (rất nguy hiểm) |\n| Rắn lục | Hoàng hôn đến nửa đêm |\n| Hổ mang chúa | Ban ngày |\n\n> 🚫 **Cạp nia (*Bungarus multicinctus*)** đặc biệt nguy hiểm vì không hiếu chiến — nọc độc gây liệt cơ hô hấp trong khi nạn nhân **không cảm thấy đau nhiều**. Bị cắn ban đêm khi đang ngủ là tình huống phổ biến.\n"
}
```

---

## Payload 4 – Nuôi Rắn Cảnh

```json
{
  "title": "5 Điều Bắt Buộc Phải Biết Trước Khi Nuôi Rắn Cảnh",
  "thumbnailUrl": "https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&auto=format&fit=crop",
  "category": "SnakeFeeding",
  "tags": ["SnakeCare", "NonVenomous"],
  "readingTime": 7,
  "status": "Published",
  "content": "# Nuôi Rắn Cảnh: Không Khó Như Bạn Nghĩ\n\nNuôi rắn cảnh đang ngày càng phổ biến tại Việt Nam. Tuy nhiên, đây là loài **có nhu cầu chăm sóc đặc thù** — không phải mọi người đều phù hợp.\n\n---\n\n## 1. Chọn Loài Phù Hợp Cho Người Mới\n\n![Rắn bắp cày – loài lý tưởng cho người mới nuôi](https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=800&auto=format&fit=crop)\n\nCác loài phù hợp nhất cho người mới:\n\n- 🐍 **Rắn bắp cày (Corn Snake):** Hiền lành, ăn tốt, tuổi thọ 15–20 năm\n- 🐍 **Ball Python:** Nhút nhát, kích thước vừa, ăn chuột đông lạnh\n- 🐍 **Rắn sữa (Milk Snake):** Màu sắc đẹp, nhỏ gọn, easy-care\n\n> ✅ **Tuyệt đối không** bắt đầu với rắn độc dù bạn có kinh nghiệm chăm sóc thú cưng khác. Cần ít nhất 2 năm kinh nghiệm với loài không độc.\n\n---\n\n## 2. Chuồng Nuôi – Thiết Lập Đúng Từ Đầu\n\n![Terrarium cho rắn với gradient nhiệt độ và chỗ ẩn náu](https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&auto=format&fit=crop)\n\n### Yêu cầu cơ bản:\n\n| Yếu tố | Thông số |\n|---|---|\n| Kích thước chuồng | Dài ≥ chiều dài cơ thể rắn |\n| Nhiệt độ \"nóng\" | 30–32°C |\n| Nhiệt độ \"mát\" | 24–26°C |\n| Độ ẩm | 50–70% (tùy loài) |\n| Chiếu sáng | 12h sáng / 12h tối |\n\n> ⚠️ **Gradient nhiệt là bắt buộc** — rắn điều chỉnh thân nhiệt bằng cách di chuyển giữa vùng nóng và mát. Chuồng chỉ có 1 nhiệt độ sẽ gây stress và bệnh về tiêu hóa.\n\n---\n\n## 3. Chế Độ Ăn\n\nRắn cảnh nên được cho ăn **mồi đông lạnh đã rã đông** — không bao giờ mồi sống. Mồi sống có thể cắn lại và gây thương tích cho rắn.\n\n### Lịch cho ăn theo tuổi:\n\n- **Con non (< 6 tháng):** Mỗi 5–7 ngày / 1 lần\n- **Trưởng thành:** Mỗi 10–14 ngày / 1 lần\n- **Sau khi lột xác:** Chờ 48h mới cho ăn\n\n---\n\n## 4. Dấu Hiệu Sức Khỏe Cần Theo Dõi\n\n![Kiểm tra sức khỏe định kỳ cho rắn cảnh](https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&auto=format&fit=crop)\n\n> 🚫 Đưa ngay đến bác sĩ thú y nếu rắn có: mắt đục bất thường (không phải lột xác), thở khò khè, tiết dịch mũi/miệng, hoặc không chịu ăn quá 3 tuần liên tiếp.\n\n---\n\n## 5. Pháp Lý Tại Việt Nam\n\n> ℹ️ Theo Nghị định 84/2021/NĐ-CP, một số loài rắn **bị cấm nuôi nhốt** không có giấy phép. Luôn kiểm tra giấy tờ nguồn gốc hợp pháp trước khi mua. Vi phạm có thể bị phạt đến **400 triệu đồng**.\n"
}
```

---

## Payload 5 – Lầm Tưởng Về Rắn

```json
{
  "title": "6 Lầm Tưởng Phổ Biến Về Rắn Mà 90% Người Tin Là Đúng",
  "thumbnailUrl": "https://images.unsplash.com/photo-1614027164847-1b28cfe1df60?w=800&auto=format&fit=crop",
  "category": "SnakeKnowledge",
  "tags": ["SnakeMyths", "SnakeIdentification"],
  "readingTime": 5,
  "status": "Published",
  "content": "# Phá Vỡ 6 Lầm Tưởng Nguy Hiểm Về Rắn\n\nNhững quan niệm sai lầm về rắn không chỉ gây ra nỗi sợ vô căn — chúng còn có thể **nguy hiểm đến tính mạng** khi bạn gặp rắn ngoài thực tế.\n\n---\n\n## ❌ Lầm Tưởng 1: \"Rắn đuôi đỏ / đầu đỏ là độc, đuôi đen / đầu đen là lành\"\n\n![Không thể phán đoán độc tính qua màu sắc đơn giản](https://images.unsplash.com/photo-1623170435887-e3d8bfe04df6?w=800&auto=format&fit=crop)\n\n**Sự thật:** Màu sắc **không phải** chỉ báo độc tính đáng tin cậy. Rắn san hô (độc) và rắn sữa (vô hại) có màu sắc rất giống nhau. Rắn cạp nia đen trắng là loài **cực độc** tại Việt Nam.\n\n---\n\n## ❌ Lầm Tưởng 2: \"Rắn không độc không nguy hiểm\"\n\n> ⚠️ **Sai hoàn toàn.** Rắn \"không độc\" vẫn có thể cắn gây **nhiễm khuẩn nặng, hoại tử**, đặc biệt nếu không xử lý vết thương đúng cách. Một số loài còn có nọc độc nhẹ không đủ gây chết nhưng gây phản ứng dị ứng nghiêm trọng.\n\n---\n\n## ❌ Lầm Tưởng 3: \"Rắn chủ động tấn công người\"\n\n![Rắn thường cố thoát thân khi gặp người](https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop)\n\n**Sự thật:** Rắn **không coi người là con mồi**. Hầu hết vụ cắn xảy ra khi người vô tình đạp lên hoặc chạm vào rắn. Rắn cắn để **tự vệ**, không phải tấn công.\n\n---\n\n## ❌ Lầm Tưởng 4: \"Hút nọc bằng miệng để cứu nạn nhân\"\n\n> 🚫 Hút nọc bằng miệng là **hoàn toàn vô hiệu** và có thể khiến người cứu bị ngộ độc nếu có vết thương trong miệng. Phương pháp này đã bị tất cả tổ chức y tế thế giới bác bỏ từ thập niên 1990.\n\n---\n\n## ❌ Lầm Tưởng 5: \"Rắn mù vào mùa lột xác – rất nguy hiểm\"\n\n**Sự thật:** Mắt rắn bị mờ vì lớp vảy cũ che phủ, nhưng chúng vẫn **cảm nhận được rung động và nhiệt**. Chúng thực sự **ít hung hăng hơn** vì hạn chế di chuyển. Tuy nhiên vẫn nên giữ khoảng cách.\n\n---\n\n## ❌ Lầm Tưởng 6: \"Garô ngay chỗ bị cắn để chặn nọc độc\"\n\n> ⚠️ **Garô gây hoại tử chi** – đây là biến chứng nghiêm trọng hơn nhiều so với nọc rắn trong hầu hết trường hợp. Nhiều nạn nhân phải **cắt cụt tay chân** do garô sai cách, không phải do nọc độc.\n\n---\n\n> ✅ **Nguyên tắc đúng khi gặp rắn:** Đứng yên → lùi từ từ → không vung tay chân → không làm ồn. Rắn sẽ tự rời đi.\n"
}
```

---

## Payload 6 – Bảo Tồn Rắn

```json
{
  "title": "Rắn Đang Biến Mất: Tại Sao Chúng Ta Cần Bảo Vệ Loài Động Vật \"Đáng Sợ\" Này?",
  "thumbnailUrl": "https://images.unsplash.com/photo-1602491453631-e2a5ad90a131?w=800&auto=format&fit=crop",
  "category": "SnakeKnowledge",
  "tags": ["SnakeConservation", "WildSnake", "SnakeIdentification"],
  "readingTime": 6,
  "status": "Published",
  "content": "# Vì Sao Rắn Quan Trọng Với Hệ Sinh Thái?\n\nDù bị sợ hãi và săn bắt, rắn đóng vai trò **không thể thay thế** trong chuỗi thức ăn tự nhiên. Sự biến mất của chúng gây ra những hậu quả mà ít ai ngờ tới.\n\n---\n\n## Rắn Làm Gì Cho Hệ Sinh Thái?\n\n![Rắn là mắt xích quan trọng trong chuỗi thức ăn rừng nhiệt đới](https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=800&auto=format&fit=crop)\n\n### Kiểm Soát Dịch Hại\n\nMột con rắn trưởng thành tiêu thụ **50–200 con chuột mỗi năm**. Tại những vùng rắn bị săn bắt cạn kiệt:\n\n- 📈 Quần thể chuột tăng vọt\n- 🌾 Mùa màng bị phá hoại nặng hơn\n- 🦠 Dịch bệnh từ chuột (như dịch hạch, leptospirosis) gia tăng\n\n> ℹ️ Nghiên cứu tại Ấn Độ (2016) ghi nhận: các làng nông nghiệp không có rắn bị **thiệt hại lúa gạo cao gấp 3 lần** so với làng còn quần thể rắn tự nhiên.\n\n---\n\n## Thực Trạng Tại Việt Nam\n\n![Môi trường sống của rắn đang bị thu hẹp do đô thị hóa](https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop)\n\n### Các Mối Đe Dọa Chính:\n\n1. **Săn bắt làm thực phẩm và thuốc** – ước tính hàng triệu cá thể/năm\n2. **Mất môi trường sống** – phá rừng, đô thị hóa\n3. **Thuốc diệt cỏ và thuốc trừ sâu** – giết chết con mồi của rắn\n4. **Giao thông** – rắn thường bị cán khi di chuyển qua đường\n\n> 🚫 Rắn hổ mang chúa (*Ophiophagus hannah*) hiện được xếp vào danh sách **\"Dễ bị tổn thương\"** (Vulnerable) trên Sách Đỏ IUCN. Quần thể đã giảm hơn **80%** trong 3 thế hệ gần đây.\n\n---\n\n## Bạn Có Thể Làm Gì?\n\n![Tham gia hoạt động bảo tồn thiên nhiên](https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800&auto=format&fit=crop)\n\n### Hành Động Thiết Thực:\n\n- ✅ **Không mua, không ăn** các sản phẩm từ rắn hoang dã\n- ✅ **Báo cáo** vi phạm săn bắt rắn lên đường dây 1800 599 979 (Kiểm Lâm)\n- ✅ **Tái định cư** rắn lạc vào khu dân cư thay vì giết – liên hệ SnakeAid\n- ✅ **Trồng cây bản địa** tạo môi trường sống cho rắn và con mồi của chúng\n\n---\n\n> 💡 **Thực tế thú vị:** Nọc độc rắn đang được nghiên cứu để **điều trị ung thư, Alzheimer và đột quỵ**. Hơn 100 loại thuốc hiện nay có thành phần từ nọc rắn — bao gồm thuốc huyết áp captopril và thuốc chống đông eptifibatide.\n"
}
```

---

## Ghi Chú Chung

| Trường | Kiểu | Bắt buộc | Ghi chú |
|---|---|---|---|
| `title` | string | ✅ | Tối đa 200 ký tự |
| `thumbnailUrl` | string | ✅ | URL ảnh bìa |
| `category` | string (enum) | ✅ | Xem danh sách enum |
| `tags` | string[] | ✅ | 1–5 tags |
| `readingTime` | int | ✅ | Phút đọc ước tính |
| `status` | string | ✅ | `Published` / `Draft` / `PendingApproval` |
| `content` | string | ✅ | **Markdown** – xem guide ở `blog-content-guide.md` |
