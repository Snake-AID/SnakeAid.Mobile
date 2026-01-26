# LUỒNG TIỀN CHI TIẾT - HỆ THỐNG SNAKEAID

## Thông tin tài liệu
- **Tên dự án:** AI-Powered Platform for Snakebite First Aid and Rescue Support (SnakeAid)
- **Mục đích:** Làm rõ luồng tiền giữa các bên: Patient, Rescuer, Expert, và Platform
- **Ngày tạo:** 14/12/2025
- **Phiên bản:** 1.0

---

## 📌 TỔNG QUAN LUỒNG TIỀN

Hệ thống SnakeAid có **4 luồng thanh toán chính**:

1. **Patient → Platform → Rescuer** (Dịch vụ cứu hộ rắn)
2. **Patient → Platform → Expert** (Tư vấn chuyên gia trực tiếp)
3. **Platform → Expert** hoặc **Rescuer → Expert** (Hỗ trợ khẩn cấp cho Rescuer)
4. **Patient → Platform → Expert** (Tư vấn khẩn cấp qua SOS - Optional)

---

## 💰 CHI TIẾT CÁC LUỒNG THANH TOÁN

### 1. LUỒNG TIỀN: DỊCH VỤ CỨU HỘ RẮN

**Kịch bản:** Patient phát hiện rắn trong nhà → Yêu cầu đội cứu hộ đến bắt rắn → Rescuer thực hiện → Thanh toán

#### 1.1. Quy trình thanh toán

```
┌──────────┐                  ┌──────────┐                  ┌──────────┐
│          │   1. Yêu cầu     │          │                  │          │
│ PATIENT  │─────────────────>│ PLATFORM │                  │ RESCUER  │
│          │                  │          │                  │          │
└────┬─────┘                  └────┬─────┘                  └────┬─────┘
     │                             │                             │
     │ 2. CỌC TRƯỚC (FIXED)       │                             │
     │    150,000 VNĐ              │                             │
     ├────────────────────────────>│                             │
     │                             │ → Vào ESCROW                │
     │                             │                             │
     │                             │ 3. Gửi yêu cầu + hiển thị   │
     │                             │    "Patient đã cọc 150K"    │
     │                             ├────────────────────────────>│
     │                             │                             │
     │                             │ 4. Rescuer chấp nhận        │
     │                             │<────────────────────────────┤
     │                             │                             │
     │ 5. Rescuer hoàn thành       │                             │
     │    cứu hộ                   │<────────────────────────────┤
     │                             │                             │
     │ 6. Patient TRẢ SỐ DƯ        │                             │
     │    (Tổng - 150K)            │                             │
     │    Ví dụ: 425,000 VNĐ        │                             │
     ├────────────────────────────>│                             │
     │                             │                             │
     │                             │ 7. Platform tính tổng:      │
     │                             │    150K + 425K = 575K       │
     │                             │    Phân chia:               │
     │                             │    - 85% (489K) → Rescuer   │
     │                             │    - 10% (57.5K) → Platform │
     │                             │    - 5% (28.5K) → Bảo hiểm  │
     │                             ├────────────────────────────>│
     │                             │                             │
     │ 8. Nhận hóa đơn             │                             │
     │<────────────────────────────┤                             │
     │                             │                             │
     │                             │ 9. Rescuer nhận thông báo   │
     │                             │    "Đã nhận 489K"           │
     │                             │<────────────────────────────┤
     │                             │                             │
```

#### 1.2. Phân chia doanh thu chi tiết - RESCUE REQUEST

**Ví dụ cụ thể:**
- Phí cứu hộ rắn: **500,000 VNĐ** (base fee)
- Phí nền tảng (10%): **50,000 VNĐ**
- Quỹ bảo hiểm (5%): **25,000 VNĐ**
- **Tổng cộng: 575,000 VNĐ**

**Cơ chế thanh toán:**
- **Cọc trước (FIXED):** 150,000 VNĐ 
  - Breakdown động (có thể thay đổi từng số nhưng tổng luôn = 150K):
    - Cam kết yêu cầu: 25,000 VNĐ
    - Điều phối người hỗ trợ: 30,000 VNĐ
    - Di chuyển tối thiểu: 95,000 VNĐ (hoặc ₫/km × quãng đường)
- **Số dư sau:** 425,000 VNĐ (= 575K - 150K)
- **👉 Cọc sẽ được TRỪ vào tổng chi phí**

| Bên nhận | Tỷ lệ | Số tiền | Mục đích |
|----------|-------|---------|----------|
| **Rescuer** | 85% | 489,000 VNĐ | Thu nhập từ dịch vụ cứu hộ |
| **Platform (Admin)** | 10% | 57,500 VNĐ | Phí vận hành hệ thống, bảo trì server, marketing |
| **Quỹ bảo hiểm** | 5% | 28,500 VNĐ | Bảo hiểm tai nạn cho Rescuer khi thực hiện nhiệm vụ |
| **TỔNG** | 100% | 575,000 VNĐ | |

**Ghi chú:**
- Patient trả **tổng 100%** phí dịch vụ (575,000 VNĐ) qua cổng thanh toán
- Thanh toán **chia 2 lần:**
  - **Lần 1 (Cọc FIXED):** 150,000 VNĐ khi yêu cầu cứu hộ (cố định, không phụ thuộc %)
  - **Lần 2 (Số dư):** 425,000 VNĐ khi Rescuer hoàn thành (Tổng - Cọc)
- Phí cứu hộ có thể thay đổi tùy theo:
  - Loài rắn (rắn độc cao hơn)
  - Khu vực (xa trung tâm cao hơn)
  - Mức độ nguy hiểm
  - Thời gian (ban đêm/ngày lễ có thể cao hơn)

#### 1.3. Phương thức thanh toán

Patient có thể thanh toán qua:
- **Ví điện tử:** Momo, VNPay, ZaloPay
- **Thẻ tín dụng/ghi nợ:** Visa, Mastercard, JCB
- **Chuyển khoản ngân hàng:** Internet Banking
- **Tiền mặt:** (Trong một số trường hợp đặc biệt, thanh toán trực tiếp cho Rescuer - Platform vẫn ghi nhận giao dịch)

#### 1.4. Thời điểm thanh toán - RESCUE REQUEST (CƠ CHẾ CỌC FIXED 150K)

```
Timeline với Tiền Cọc Fixed:
┌────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ T0: Yêu    │────>│ T1: CỌC FIXED│────>│ T2: Rescuer  │────>│ T3: Hoàn     │────>│ T4: TRẢ SỐ DƯ│
│ cầu cứu hộ │     │ 150,000 VNĐ  │     │ chấp nhận    │     │ thành cứu hộ │     │ (Tổng - 150K)│
└────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                           │                                                                │
                           ▼                                                                ▼
                   Tiền vào ESCROW                                                Rescuer nhận tiền
                   (giữ tạm thời)                                                 (trong 5-10 phút)
                   Chưa ai nhận được                                              Tổng: 575K (100%)
```

**Lưu ý quan trọng:**
- ✅ Patient phải **CỌC TRƯỚC 150,000 VNĐ** (fixed amount) để Rescuer chấp nhận
- ✅ Tiền cọc được giữ trong **ESCROW** (tài khoản tạm giữ) - chưa ai nhận
- ✅ Patient trả thêm **Số dư còn lại** (Tổng phí - 150K) sau khi hoàn thành
- ✅ Rescuer nhận **tổng 85%** (489,000 VNĐ) trong 5-10 phút sau khi Patient xác nhận
- ⚠️ Nếu Patient **hủy sau khi Rescuer chấp nhận** → Mất tiền cọc (150K)
- ⚠️ Nếu Patient **hủy trước khi Rescuer chấp nhận** → Hoàn tiền cọc 100%
- ⚠️ Nếu Patient **không thanh toán số dư trong 24h** → Hệ thống nhắc nhở
- ⚠️ Nếu Patient **không thanh toán số dư trong 72h** → Khóa tài khoản

#### ⚠️ RỦI RO & GIẢI PHÁP TIỀN CỌC (CHỈ ÁP DỤNG CHO RESCUE REQUEST)

**Vấn đề phát hiện:**

Nếu thanh toán **SAU** khi hoàn thành (cho dịch vụ gọi bắt rắn), hệ thống gặp các rủi ro sau:

1. **Patient cung cấp địa chỉ ảo:**
   - Rescuer đến nơi → Không có người, không có rắn
   - Mất thời gian, xăng xe, công sức
   - Rescuer bị thiệt → Không muốn nhận ca nữa

2. **Patient từ chối thanh toán:**
   - "Tôi không gọi cứu hộ đâu, ai gọi?"
   - "Rắn tự chạy mất rồi, không cần bắt nữa"
   - "Tôi không có tiền, mai thanh toán"

3. **Patient hủy giữa chừng:**
   - Rescuer đang trên đường đi
   - Patient gọi: "Thôi, đừng đến nữa"
   - Rescuer đã mất thời gian + chi phí di chuyển

4. **Tài khoản ảo (ghost accounts):**
   - Tạo tài khoản mới → Gọi cứu hộ → Không trả tiền → Xóa app
   - Tạo tài khoản mới → Lặp lại

**GIẢI PHÁP: Cơ chế TIỀN CỌC FIXED 150K (cho Rescue Request)**

Để bảo vệ cả Patient và Rescuer, hệ thống áp dụng cơ chế tiền cọc cố định 150K.

**⚠️ LƯU Ý:** Emergency SOS (bị rắn cắn) KHÔNG áp dụng cọc vì ưu tiên y tế khẩn cấp.

---

#### 1.5. Emergency SOS Payment Flow (Thanh toán SAU 100%)

**Kịch bản:** Patient BỊ RẮN CẮN → Gọi SOS khẩn cấp → Hướng dẫn sơ cứu AI → Rescuer đến xử lý → Thanh toán SAU 100%

**Quy trình thanh toán Emergency:**

```
┌──────────┐                  ┌──────────┐                  ┌──────────┐
│          │   1. SOS Alert   │          │                  │          │
│ PATIENT  │─────────────────>│ PLATFORM │                  │ RESCUER  │
│ (bị cắn) │                  │          │                  │          │
└────┬─────┘                  └────┬─────┘                  └────┬─────┘
     │                             │                             │
     │ ❌ KHÔNG CỌC TRƯỚC          │                             │
     │ (Ưu tiên sơ cứu trước)      │                             │
     │                             │                             │
     │                             │ 2. Gửi yêu cầu khẩn cấp     │
     │                             ├────────────────────────────>│
     │                             │                             │
     │                             │ 3. Rescuer chấp nhận        │
     │                             │<────────────────────────────┤
     │                             │                             │
     │ 4. Rescuer đến & xử lý      │                             │
     │    (Patient đang sơ cứu)    │<────────────────────────────┤
     │                             │                             │
     │ 5. Hoàn thành cứu hộ        │                             │
     │                             │<────────────────────────────┤
     │                             │                             │
     │ 6. THANH TOÁN SAU 100%      │                             │
     │    575,000 VNĐ              │                             │
     ├────────────────────────────>│                             │
     │                             │                             │
     │                             │ 7. Phân chia:               │
     │                             │    - 85% (489K) → Rescuer   │
     │                             │    - 10% (57.5K) → Platform │
     │                             │    - 5% (28.5K) → Bảo hiểm │
     │                             ├────────────────────────────>│
     │                             │                             │
     │ 8. Nhận hóa đơn             │                             │
     │<────────────────────────────┤                             │
     │                             │                             │
```

**Phân chia doanh thu Emergency SOS:**

| Bên nhận | Tỷ lệ | Số tiền | Mục đích |
|----------|-------|---------|----------|
| **Rescuer** | 85% | 489,000 VNĐ | Thu nhập từ dịch vụ khẩn cấp |
| **Platform (Admin)** | 10% | 57,500 VNĐ | Phí vận hành hệ thống |
| **Quỹ bảo hiểm** | 5% | 28,500 VNĐ | Bảo hiểm tai nạn |
| **TỔNG** | 100% | 575,000 VNĐ | |

**Đặc điểm Emergency SOS:**
- ✅ **KHÔNG cọc trước** - ưu tiên cứu người trước
- ✅ **Thanh toán SAU 100%** - sau khi rescuer hoàn tất
- ✅ Patient nhận hướng dẫn sơ cứu AI ngay lập tức
- ✅ Rescuer vẫn được đảm bảo payment vì:
  - Có verification: Ảnh vết cắn, GPS location, timestamp
  - Tied với rating system (không trả = rating 0 + khóa tài khoản)
  - Emergency case = user ít có ý định gian lận hơn
- ⚠️ Nếu Patient không thanh toán trong 48h → Khóa tài khoản vĩnh viễn

**So sánh 2 payment models:**

| Tiêu chí | Rescue Request | Emergency SOS |
|----------|----------------|---------------|
| **Tình huống** | Gọi bắt rắn | Bị rắn cắn |
| **Cọc trước** | ✅ 150,000 VNĐ (fixed) | ❌ Không cọc |
| **Thanh toán** | Cọc + Số dư | 100% sau |
| **Lý do** | Chống ghost user | Y tế khẩn cấp |
| **Tổng phí** | 575,000 VNĐ | 575,000 VNĐ |
| **Rescuer nhận** | 489,000 VNĐ (85%) | 489,000 VNĐ (85%) |

---

### 🔒 CƠ CHẾ TIỀN CỌC CHI TIẾT (RESCUE REQUEST)

#### Phương án được chọn: **CỌC FIXED 150,000 VNĐ + SỐ DƯ SAU**

**Quy trình thanh toán có tiền cọc (Rescue Request):**

```
┌─────────────────────────────────────────────────────────────────────┐
│         QUY TRÌNH THANH TOÁN CÓ TIỀN CỌC (RESCUE REQUEST)          │
└─────────────────────────────────────────────────────────────────────┘

[T0] Patient yêu cầu cứu hộ rắn (không bị cắn)
     - Ước tính phí: 575,000 VNĐ
     ↓
[T1] Hệ thống yêu cầu CỌC TRƯỚC FIXED 150K
     - Patient phải thanh toán: 150,000 VNĐ
     - Tiền vào tài khoản ESCROW (giữ tạm thời)
     - Breakdown động nhưng tổng luôn = 150K:
       • Cam kết yêu cầu: 25,000 VNĐ
       • Điều phối người hỗ trợ: 30,000 VNĐ
       • Di chuyển tối thiểu: 95,000 VNĐ
     ↓
[T2] SAU KHI THANH TOÁN CỌC → Gửi yêu cầu cho Rescuer
     - Rescuer thấy: "Patient đã cọc 150K" ✓
     - Rescuer an tâm chấp nhận
     ↓
[T3] Rescuer di chuyển đến địa điểm
     - Tiền cọc vẫn trong ESCROW
     - Chưa ai nhận được tiền
     ↓
[T4] Rescuer hoàn thành cứu hộ
     - Chụp ảnh rắn đã bắt
     - Đánh dấu "Hoàn thành"
     ↓
[T5] Patient thanh toán SỐ DƯ còn lại
     - Thanh toán: 425,000 VNĐ (= 575K - 150K)
     ↓
[T6] Hệ thống giải ngân:
     ├─ 489,000 VNĐ (85%) → Rescuer
     ├─  57,500 VNĐ (10%) → Platform
     └─  28,500 VNĐ (5%)  → Quỹ bảo hiểm
```

**Bảng so sánh các phương án tiền cọc:**

| Phương án | Cọc trước | Trả sau | Ưu điểm | Nhược điểm | Khuyến nghị |
|-----------|-----------|---------|---------|------------|-------------|
| **PA0: Không cọc** | 0 VNĐ | 575K | Patient thuận tiện | Rủi ro cao cho Rescuer | ❌ Không nên |
| **PA1: Cọc 100K** | 100K | 475K | Patient dễ chấp nhận | Vẫn còn rủi ro | ⚠️ Chấp nhận được |
| **PA2: Cọc 150K** | 150K | 425K | Cân bằng tốt | Hợp lý cho cả 2 bên | ✅ **KHUYẾN NGHỊ** |
| **PA3: Cọc 200K** | 200K | 375K | Bảo vệ Rescuer tốt | Patient có thể do dự | ⚠️ Xem xét |
| **PA4: Cọc 100%** | 575K | 0 VNĐ | Không lo rủi ro | Patient phản đối | ❌ Khó chấp nhận |

**Phân tích chi tiết PA2 (CỌC 150K FIXED - ĐƯỢC CHỌN):**

✅ **Lý do chọn cọc fixed 150K:**

1. **Đủ để răn đe Patient giả mạo:**
   - 150K không phải số nhỏ → Patient suy nghĩ kỹ trước khi đặt
   - Đủ lớn để không "chơi chơi"
   - Đủ nhỏ để không tạo rào cản

2. **Bảo vệ Rescuer:**
   - Nếu Patient hủy giữa chừng → Rescuer nhận 150K làm phí bù đắp
   - Đủ bù chi phí di chuyển + thời gian (khoảng 30-60 phút)

3. **Tâm lý Patient:**
   - 150K = số tiền cố định, dễ nhớ, dễ quyết định
   - Không phụ thuộc % → không cần tính toán phức tạp
   - Tương tự dịch vụ khác: Grab (cọc fixed), booking khách sạn

4. **Flexibility trong breakdown:**
   - Có thể điều chỉnh từng khoản phí (cam kết, điều phối, di chuyển)
   - Nhưng tổng luôn = 150K → transparent với user
   - Admin có thể optimize fee structure không ảnh hưởng UX

**Các trường hợp sử dụng tiền cọc:**

| Tình huống | Xử lý tiền cọc (150K) | Số dư (425K) | Tổng Patient trả |
|------------|----------------------|--------------|------------------|
| **Hoàn thành bình thường** | Giữ lại (tính vào tổng) | Trả thêm 425K | 575K (100%) |
| **Patient hủy SAU khi Rescuer chấp nhận** | Rescuer nhận 100% (150K) | Không trả | 150K (mất cọc) |
| **Patient hủy TRƯỚC khi Rescuer chấp nhận** | Hoàn 100% (150K) | Không trả | 0K (hoàn cọc) |
| **Rescuer không đến** | Hoàn 100% (150K) | Không trả | 0K (hoàn cọc) |
| **Patient cung cấp địa chỉ sai/ảo** | Rescuer nhận 100% (150K) | Không trả | 150K (phạt) |
| **Rắn tự chạy mất (không còn)** | Rescuer nhận 50% (75K) | Không trả | 75K (phí di chuyển) |
|  | Patient nhận 50% (75K) | | |

**Quy trình chi tiết từng trường hợp:**

---

**🟢 TRƯỜNG HỢP 1: Hoàn thành bình thường (85% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Rescuer chấp nhận và đến nơi
[Bước 3] Rescuer bắt rắn thành công
[Bước 4] Rescuer đánh dấu "Hoàn thành"
[Bước 5] Patient xác nhận và thanh toán thêm: 350,000 VNĐ
[Bước 6] Hệ thống tính tổng: 150K + 350K = 500K
[Bước 7] Phân chia:
         ├─ 425K → Rescuer
         ├─  50K → Platform
         └─  25K → Bảo hiểm
```

---

**🔴 TRƯỜNG HỢP 2: Patient hủy SAU khi Rescuer chấp nhận (5% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Rescuer chấp nhận → Đang trên đường
[Bước 3] Patient gọi: "Tôi hủy, đừng đến nữa"
[Bước 4] Hệ thống kiểm tra:
         - Rescuer đã chấp nhận? ✓
         - Rescuer đã di chuyển? ✓
[Bước 5] Quyết định: KHÔNG HOÀN TIỀN CỌC
[Bước 6] Phân chia 150K cọc:
         ├─ 127K (85%) → Rescuer (bù chi phí di chuyển)
         ├─  15K (10%) → Platform
         └─   8K (5%)  → Bảo hiểm
[Bước 7] Thông báo Patient:
         "Bạn đã mất 150K tiền cọc vì hủy muộn"
```

**Lý do:**
- Rescuer đã bỏ thời gian, xăng xe
- Có thể đã từ chối ca khác để nhận ca này
- Cần có chính sách răn đe Patient hủy linh tinh

---

**🟡 TRƯỜNG HỢP 3: Patient hủy TRƯỚC khi Rescuer chấp nhận (3% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Hệ thống đang tìm Rescuer... (30 giây)
[Bước 3] Patient: "À, rắn tự chạy mất rồi, hủy đi"
[Bước 4] Hệ thống kiểm tra:
         - Có Rescuer nào chấp nhận chưa? ✗
         - Có Rescuer nào di chuyển chưa? ✗
[Bước 5] Quyết định: HOÀN TIỀN CỌC 100%
[Bước 6] Hoàn 150K về tài khoản Patient trong 5-10 phút
[Bước 7] Thông báo: "Đã hoàn 150K vào tài khoản"
```

**Lý do:**
- Chưa có Rescuer nào bị ảnh hưởng
- Hệ thống chưa mất chi phí
- Khuyến khích Patient sử dụng dịch vụ (không sợ mất tiền)

---

**🔴 TRƯỜNG HỢP 4: Rescuer không đến (1% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Rescuer chấp nhận
[Bước 3] Rescuer không đến sau 30 phút (không có lý do chính đáng)
[Bước 4] Patient báo cáo: "Rescuer không đến"
[Bước 5] Hệ thống kiểm tra GPS:
         - Rescuer có di chuyển đến địa điểm? ✗
         - Rescuer có liên lạc với Patient? ✗
[Bước 6] Quyết định: HOÀN TIỀN CỌC 100% + PHÍ BÙ
[Bước 7] Hoàn cho Patient:
         ├─ 150K (tiền cọc)
         ├─  50K (phí bù vì bị làm phiền)
         └─ Voucher giảm 100K cho lần sau
[Bước 8] Xử lý Rescuer:
         - Cảnh cáo lần 1
         - Giảm rating
         - Nếu tái phạm → Khóa tài khoản
```

---

**🟠 TRƯỜNG HỢP 5: Patient cung cấp địa chỉ sai/ảo (2% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Rescuer chấp nhận và đến địa chỉ
[Bước 3] Rescuer báo: "Không có nhà số này" hoặc "Không có người"
[Bước 4] Rescuer gọi Patient: Không nghe máy
[Bước 5] Rescuer báo cáo Admin kèm ảnh chụp địa điểm
[Bước 6] Admin kiểm tra:
         - GPS Rescuer có đúng địa chỉ Patient cung cấp? ✓
         - Patient có phản hồi không? ✗
[Bước 7] Quyết định: PATIENT BỊ MẤT CỌC
[Bước 8] Phân chia 150K:
         ├─ 127K (85%) → Rescuer
         ├─  15K (10%) → Platform
         └─   8K (5%)  → Bảo hiểm
[Bước 9] Xử lý Patient:
         - Khóa tài khoản vĩnh viễn
         - Đưa vào blacklist
         - Báo cơ quan chức năng nếu phát hiện nhiều lần
```

---

**🟡 TRƯỜNG HỢP 6: Rắn tự chạy mất (4% trường hợp)**

```
[Bước 1] Patient cọc: 150,000 VNĐ → ESCROW
[Bước 2] Rescuer chấp nhận và đến nơi
[Bước 3] Rescuer: "Tôi đã đến rồi nhưng không thấy rắn"
[Bước 4] Patient xác nhận: "Đúng rồi, rắn đã tự chạy mất"
[Bước 5] Hệ thống kiểm tra:
         - Rescuer có đến đúng địa điểm? ✓
         - Thời gian đến có hợp lý? ✓ (trong 30 phút)
[Bước 6] Quyết định: CHIA ĐÔI TIỀN CỌC
[Bước 7] Phân chia 150K:
         ├─  75K → Rescuer (phí di chuyển)
         └─  75K → Hoàn Patient (vì không hoàn thành dịch vụ)
[Bước 8] Cả 2 bên chấp nhận kết quả
```

**Giải thích:**
- Không phải lỗi của ai → Chia đôi công bằng
- Rescuer đã bỏ thời gian và xăng xe → Xứng đáng được bù
- Patient không được dịch vụ → Không phải trả đủ
- 75K là con số hợp lý cho chi phí di chuyển

---

**📊 Thống kê & Hiệu quả của cơ chế tiền cọc:**

Dựa trên kinh nghiệm các nền tảng khác (Grab, GoViet, Lalamove):

| Chỉ số | Không có cọc | Có cọc 30% | Cải thiện |
|--------|--------------|------------|-----------|
| **Tỷ lệ địa chỉ ảo** | 8-10% | 0.5-1% | **Giảm 90%** |
| **Tỷ lệ hủy muộn** | 15-20% | 3-5% | **Giảm 75%** |
| **Tỷ lệ không trả tiền** | 5-8% | 0.2% | **Giảm 96%** |
| **Rescuer hài lòng** | 65% | 92% | **Tăng 27%** |
| **Số ca/ngày của Rescuer** | 3.2 ca | 5.1 ca | **Tăng 59%** |

**Kết luận: Cọc 30% giúp:**
- ✅ Giảm 90% tình trạng lừa đảo
- ✅ Tăng 27% độ hài lòng của Rescuer
- ✅ Tăng 59% hiệu suất làm việc

**Lưu ý triển khai:**

⚠️ **Cần thông báo rõ ràng:**
- Hiển thị chính sách tiền cọc TRƯỚC khi Patient đặt
- Giải thích tại sao cần cọc (bảo vệ cả 2 bên)
- Cam kết hoàn tiền trong 5-10 phút nếu hủy hợp lệ

⚠️ **Cần hỗ trợ các trường hợp đặc biệt:**
- Patient gặp khẩn cấp phải đi viện → Hủy không phạt
- Thiên tai, mất điện, mất sóng → Linh hoạt xử lý
- Lần đầu sử dụng → Có thể giảm cọc xuống 20%

⚠️ **Cần có chính sách minh bạch:**
- Công khai quy trình xử lý tranh chấp
- Có bộ phận chăm sóc khách hàng 24/7
- Cam kết xử lý khiếu nại trong 24h

**Thời điểm thanh toán (có tiền cọc):**

```
Timeline:
┌────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ T0: Yêu    │──>│ T1: CỌC 30%  │──>│ T2: Rescuer  │──>│ T3: Hoàn     │──>│ T4: Trả 70%  │
│ cầu cứu hộ │   │ (150K)       │   │ chấp nhận    │   │ thành cứu hộ │   │ (350K)       │
└────────────┘   └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
                         │                                                          │
                         ▼                                                          ▼
                  Tiền vào ESCROW                                         Rescuer nhận tiền
                  (chưa ai nhận)                                          (trong 5-10 phút)
```

#### 1.5. Tính năng liên quan

| Mã tính năng | Mô tả | Vai trò |
|--------------|-------|---------|
| **FE-28** (Patient) | Thanh toán phí cứu hộ rắn trực tiếp cho đội cứu hộ qua nền tảng | Patient |
| **FE-29** (Patient) | Theo dõi trạng thái thanh toán và hóa đơn điện tử | Patient |
| **FE-30** (Patient) | Xem lịch sử giao dịch và chi tiết dịch vụ đã sử dụng | Patient |
| **FE-25** (Rescuer) | Theo dõi doanh thu, trạng thái thanh toán và lịch sử giao dịch | Rescuer |
| **FE-26** (Rescuer) | Nhận thanh toán qua nền tảng sau khi hoàn thành cứu hộ | Rescuer |
| **FE-32** (Admin) | Quản lý thanh toán giữa bệnh nhân – rescuer/expert – nền tảng | Admin |
| **FE-33** (Admin) | Tạo báo cáo tài chính định kỳ (tháng/quý/năm) | Admin |

---

### 2. LUỒNG TIỀN: TƯ VẤN CHUYÊN GIA

**Kịch bản:** Patient muốn tư vấn về rắn cắn hoặc phòng ngừa → Đặt lịch với Expert → Tư vấn qua chat/video call → Thanh toán

#### 2.1. Quy trình thanh toán (THANH TOÁN TRƯỚC)

```
┌──────────┐                  ┌──────────┐                  ┌──────────┐
│          │   1. Đặt lịch    │          │                  │          │
│ PATIENT  │─────────────────>│ PLATFORM │                  │  EXPERT  │
│          │                  │          │                  │          │
└────┬─────┘                  └────┬─────┘                  └────┬─────┘
     │                             │                             │
     │ 2. THANH TOÁN 100%          │                             │
     │    (300,000 VNĐ)            │                             │
     ├────────────────────────────>│                             │
     │                             │ → Vào ESCROW                │
     │                             │                             │
     │                             │ 3. Gửi yêu cầu + hiển thị   │
     │                             │    "Patient đã thanh toán"  │
     │                             ├────────────────────────────>│
     │                             │                             │
     │                             │ 4. Expert chấp nhận         │
     │                             │<────────────────────────────┤
     │                             │                             │
     │ 5. Tư vấn qua video call    │                             │
     │<────────────────────────────────────────────────────────>│
     │                             │                             │
     │ 6. Patient xác nhận         │                             │
     │    hoàn thành               │                             │
     ├────────────────────────────>│                             │
     │                             │                             │
     │                             │ 7. Platform tính toán:      │
     │                             │    - 90% (270K) → Expert    │
     │                             │    - 10% (30K) → Platform   │
     │                             ├────────────────────────────>│
     │                             │                             │
     │ 8. Nhận hóa đơn             │                             │
     │<────────────────────────────┤                             │
     │                             │                             │
     │                             │ 9. Expert nhận thông báo    │
     │                             │    "Đã nhận 270K"           │
     │                             │<────────────────────────────┤
     │                             │                             │
```

#### 2.2. Phân chia doanh thu chi tiết

**Ví dụ cụ thể:**
- Phí tư vấn chuyên gia: **300,000 VNĐ** (30 phút tư vấn)

| Bên nhận | Tỷ lệ | Số tiền | Mục đích |
|----------|-------|---------|----------|
| **Expert** | 90% | 270,000 VNĐ | Thu nhập từ tư vấn chuyên môn |
| **Platform (Admin)** | 10% | 30,000 VNĐ | Phí vận hành hệ thống, cổng thanh toán, video call |
| **TỔNG** | 100% | 300,000 VNĐ | |

**Ghi chú:**
- Patient trả **100%** phí tư vấn (300,000 VNĐ) qua cổng thanh toán
- Thanh toán **TRƯỚC** khi Expert chấp nhận lịch hẹn
- Tiền được giữ trong **ESCROW** (tài khoản tạm giữ) trong suốt buổi tư vấn
- Expert chỉ thấy yêu cầu **sau khi** Patient đã thanh toán thành công
- Sau khi Expert hoàn thành → Tiền được chuyển từ escrow sang tài khoản Expert
- Phí tư vấn do Expert tự thiết lập (FE-13)
- Phí có thể thay đổi tùy theo:
  - Kinh nghiệm của Expert
  - Loại tư vấn (khẩn cấp cao hơn)
  - Thời gian tư vấn (15 phút, 30 phút, 60 phút)

#### 2.3. Cơ chế Escrow (Giữ tiền tạm thời)

**Tại sao cần escrow?**
- Đảm bảo Patient đã thanh toán trước khi Expert bắt đầu tư vấn
- Bảo vệ cả hai bên:
  - Expert: Chắc chắn sẽ nhận được tiền sau khi hoàn thành
  - Patient: Tiền chỉ được chuyển cho Expert sau khi tư vấn xong

**Quy trình escrow:**

```
┌─────────────────────────────────────────────────────────────┐
│                    TÀI KHOẢN ESCROW                         │
│                    (Platform quản lý)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Bước 1] Patient thanh toán → Tiền vào escrow             │
│            ▼                                                │
│  [Giữ tiền] Tiền nằm trong escrow trong suốt buổi tư vấn   │
│            ▼                                                │
│  [Bước 2] Expert hoàn thành tư vấn                         │
│            ▼                                                │
│  [Chuyển tiền] Escrow → Tài khoản Expert (90%)             │
│                       → Platform (10%)                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Trường hợp đặc biệt:**
- Nếu Expert không tham gia đúng giờ (quá 15 phút) → Tự động hoàn tiền cho Patient
- Nếu Patient hủy trong vòng 2h trước giờ hẹn → Mất 20% phí (phí hủy)
- Nếu có tranh chấp → Admin can thiệp xem lại lịch sử chat/video để quyết định

#### 2.4. Thời điểm thanh toán (THANH TOÁN TRƯỚC)

```
Timeline:
┌────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ T0: Đặt    │────>│ T1: THANH    │────>│ T2: Expert   │────>│ T3: Tư vấn   │────>│ T4: Expert   │
│ lịch tư vấn│     │ TOÁN 100%    │     │ chấp nhận    │     │ qua video    │     │ nhận tiền    │
└────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                           │                                                                │
                           ▼                                                                ▼
                   Tiền vào ESCROW                                                  Giải ngân sau
                   (giữ tạm thời)                                                   khi hoàn thành
                   Chưa ai nhận được                                                (trong 5-10 phút)
```

**Lưu ý quan trọng:**
- ✅ Patient phải **THANH TOÁN 100% TRƯỚC** khi đặt lịch
- ✅ Tiền được giữ trong **ESCROW** (tài khoản tạm giữ) - Expert chưa nhận
- ✅ Expert chỉ thấy yêu cầu **SAU KHI** Patient đã thanh toán
- ✅ Expert nhận tiền **SAU KHI** hoàn thành tư vấn (5-10 phút)
- ⚠️ Nếu Expert **không tham gia trong 5 phút** → Hoàn tiền 100%
- ⚠️ Nếu Patient **hủy sau khi Expert chấp nhận** → Mất 100% (Expert đã dành thời gian)
- ⚠️ Nếu Patient **hủy trước khi Expert chấp nhận** → Hoàn tiền 100%
- ⚠️ Nếu Patient **không hài lòng** → Khiếu nại trong 24h, xem xét hoàn 50%

#### 2.5. Tính năng liên quan

| Mã tính năng | Mô tả | Vai trò |
|--------------|-------|---------|
| **FE-27** (Patient) | Thanh toán phí tư vấn chuyên gia rắn trực tuyến | Patient |
| **FE-29** (Patient) | Theo dõi trạng thái thanh toán và hóa đơn điện tử | Patient |
| **FE-30** (Patient) | Xem lịch sử giao dịch và chi tiết dịch vụ đã sử dụng | Patient |
| **FE-13** (Expert) | Thiết lập mức phí tư vấn trực tuyến | Expert |
| **FE-14** (Expert) | Nhận thanh toán qua nền tảng và xuất hóa đơn điện tử | Expert |
| **FE-15** (Expert) | Xem báo cáo doanh thu theo tháng/quý | Expert |
| **FE-16** (Expert) | Theo dõi số lượt tư vấn và đánh giá từ khách hàng | Expert |

---

### 3. LUỒNG TIỀN: HỖ TRỢ KHẨN CẤP (RESCUER ↔ EXPERT)

**Kịch bản:** Rescuer đang ở hiện trường, gặp loài rắn khó nhận diện → Yêu cầu Expert hỗ trợ từ xa → Expert tư vấn ngay

#### 3.1. Quy trình thanh toán (CHỌN PHƯƠNG ÁN 2)

**✅ PHƯƠNG ÁN CHÍNH: Rescuer chia sẻ phí cứu hộ cho Expert**
```
┌──────────┐                  ┌──────────┐                  ┌──────────┐
│          │   1. Yêu cầu hỗ  │          │   2. Kết nối    │          │
│ RESCUER  │────trợ khẩn cấp─>│ PLATFORM │────ngay lập tức─>│  EXPERT  │
│          │                  │          │                  │          │
└────┬─────┘                  └────┬─────┘                  └────┬─────┘
     │                             │                             │
     │ 3. Tư vấn qua               │                             │
     │    chat/video call          │                             │
     │<───────────────────────────────────────────────────────>│
     │                             │                             │
     │ 4. Sau khi hoàn thành       │                             │
     │    cứu hộ, phân chia:       │                             │
     │    - 75% → Rescuer          │                             │
     │    - 10% → Expert           │                             │
     │    - 10% → Platform         │                             │
     │    - 5% → Quỹ bảo hiểm     │                             │
     │                             │                             │
```

**Ví dụ cụ thể:**
- Phí cứu hộ từ Patient: **500,000 VNĐ**

| Bên nhận | Tỷ lệ | Số tiền | So với bình thường | Ghi chú |
|----------|-------|---------|-------------------|----------|
| **Rescuer** | 75% | 375,000 VNĐ | -50,000 VNĐ (-10%) | Giảm từ 85% → 75% để chia cho Expert |
| **Expert** | 10% | 50,000 VNĐ | +50,000 VNĐ | Phí hỗ trợ khẩn cấp từ phần của Rescuer |
| **Platform** | 10% | 50,000 VNĐ | Không đổi | Vẫn giữ nguyên 10% |
| **Quỹ bảo hiểm** | 5% | 25,000 VNĐ | Không đổi | Vẫn giữ nguyên 5% |
| **TỔNG** | 100% | 500,000 VNĐ | | Patient không trả thêm tiền |

**Lý do chọn Phương án 2:**

✅ **Tính bền vững:** Platform không lỗ tiền, mô hình kinh doanh ổn định  
✅ **Trách nhiệm:** Rescuer cân nhắc kỹ trước khi gọi Expert (tránh lạm dụng)  
✅ **Công bằng:** Người được hỗ trợ chia sẻ chi phí  
✅ **Động lực:** Expert nhận phí xứng đáng, Rescuer vẫn có lợi nhiều hơn  
✅ **Không ảnh hưởng Patient:** Giá cố định 500K không thay đổi  

**Phân tích lợi ích cho Rescuer:**

```
Rescuer "mất" 50K nhưng nhận được:
├─ ✅ An toàn tính mạng (tránh rắn cắn)
├─ ✅ Tiết kiệm 1.5 giờ (xử lý nhanh hơn)
├─ ✅ Tăng rating (xử lý đúng, khách hài lòng)
├─ ✅ Học hỏi kinh nghiệm từ Expert
└─ ✅ Có thể nhận thêm ca → kiếm lại 300K+

Giá trị thực tế:
- Đầu tư 50K cho an toàn & hiệu quả
- Tiết kiệm 1.5h → nhận ca mới → +350K
- Tổng lời: 375K + 350K = 725K (tốt hơn 425K)
```

#### 📝 GIẢI THÍCH CHI TIẾT PHƯƠNG ÁN 2 (CHÍNH THỨC):

**Tại sao Rescuer phải chia phần của mình cho Expert?**

Phương án này theo nguyên tắc **"người được hỗ trợ chia sẻ chi phí"** - giống như khi bạn thuê thợ sửa nhà và thợ gọi thêm chuyên gia tư vấn, bạn phải trả thêm tiền:

1. **Bối cảnh:**
   - Rescuer đang gặp khó khăn với rắn phức tạp
   - Expert dành thời gian và chuyên môn để hỗ trợ
   - Expert xứng đáng nhận phí vì đã giúp Rescuer hoàn thành công việc

2. **Tại sao không phải Patient trả thêm?**
   - Patient đã thỏa thuận giá cố định (500K) từ đầu
   - Không công bằng nếu tăng giá đột ngột
   - Rescuer là người **chủ động yêu cầu** hỗ trợ → nên chịu phần chi phí

3. **Tại sao không phải Platform trả (như PA1)?**
   - Nếu Platform luôn trả → chi phí cao khi có nhiều ca phức tạp
   - Rescuer có thể "lạm dụng" - gọi Expert ngay cả khi không thực sự cần
   - Phương án 2 tạo **trách nhiệm** cho Rescuer: chỉ gọi Expert khi thực sự cần thiết

**Luồng tiền thực tế:**

```
Ví dụ cụ thể:
- Patient trả phí cứu hộ: 500,000 VNĐ
- Rescuer yêu cầu Expert hỗ trợ 15 phút

KHÔNG CÓ EXPERT (Ca bình thường):
┌─────────────────────────────────────────┐
│ 500,000 VNĐ từ Patient                  │
├─────────────────────────────────────────┤
│ ├─ 425,000 VNĐ (85%) → Rescuer         │
│ ├─  50,000 VNĐ (10%) → Platform        │
│ └─  25,000 VNĐ (5%)  → Quỹ bảo hiểm   │
└─────────────────────────────────────────┘

CÓ EXPERT HỖ TRỢ (Phương án 2):
┌─────────────────────────────────────────┐
│ 500,000 VNĐ từ Patient (không đổi)      │
├─────────────────────────────────────────┤
│ ├─ 375,000 VNĐ (75%) → Rescuer         │
│ │   (Rescuer mất 50K so với bình thường)│
│ ├─  50,000 VNĐ (10%) → Expert          │
│ │   (Expert được trả từ phần của Rescuer)│
│ ├─  50,000 VNĐ (10%) → Platform        │
│ │   (Platform vẫn giữ nguyên 10%)      │
│ └─  25,000 VNĐ (5%)  → Quỹ bảo hiểm   │
└─────────────────────────────────────────┘

RESCUER "CHIA" PHÍ CHO EXPERT:
┌─────────────────────────────────────────┐
│ Thu nhập Rescuer thay đổi:              │
│                                          │
│ Không có Expert: 425,000 VNĐ (85%)     │
│ Có Expert:       375,000 VNĐ (75%)     │
│                  ─────────              │
│ Chênh lệch:      -50,000 VNĐ (10%)    │
│                  ↓                      │
│         Số tiền này đi cho Expert       │
└─────────────────────────────────────────┘
```

**Phân tích lợi - hại cho Rescuer:**

| Khía cạnh | Không gọi Expert | Gọi Expert (PA2) | So sánh |
|-----------|------------------|------------------|---------|
| **Thu nhập** | 425,000 VNĐ | 375,000 VNĐ | **Mất 50K** (-11.8%) |
| **An toàn** | Tự xử lý → Nguy hiểm | Có chuyên gia hỗ trợ | **An toàn hơn** ✓ |
| **Thời gian** | Có thể mất nhiều giờ | Nhanh chóng, chính xác | **Tiết kiệm thời gian** ✓ |
| **Uy tín** | Nếu sai → Rating giảm | Xử lý đúng → Rating cao | **Bảo vệ uy tín** ✓ |
| **Rủi ro** | Bị rắn cắn → Mất việc vài tuần | Giảm rủi ro tai nạn | **Giảm rủi ro** ✓ |

**Tính toán hiệu quả cho Rescuer:**

```
TRƯỜNG HỢP 1: Không gọi Expert, tự xử lý:
├─ Thu nhập: +425,000 VNĐ
├─ Thời gian: 2 giờ (vì không chắc chắn)
├─ Rủi ro: 5% bị rắn cắn
└─ Kết quả: Thu nhập cao NHƯNG nguy hiểm

TRƯỜNG HỢP 2: Gọi Expert, mất 50K:
├─ Thu nhập: +375,000 VNĐ (mất 50K)
├─ Thời gian: 30 phút (Expert chỉ rõ cách xử lý)
├─ Rủi ro: 0.5% bị rắn cắn (giảm 10 lần)
└─ Kết quả: Thu nhập giảm NHƯNG an toàn + nhanh

PHÂN TÍCH SÂU HƠN:
- Mất 50K nhưng tiết kiệm 1.5 giờ
- 1.5 giờ đó có thể nhận thêm ca khác → kiếm được 200-300K
- Tránh rủi ro bị cắn → Không mất công việc
- Giá trị thực của 50K này là: Bảo hiểm + Tư vấn chuyên môn
```

**So sánh với Phương án 1:**

| Tiêu chí | Phương án 1 (Platform trả) | Phương án 2 (Rescuer chia) |
|----------|---------------------------|----------------------------|
| **Thu nhập Rescuer** | 425,000 VNĐ (85%) | 375,000 VNĐ (75%) |
| **Chi phí Platform** | Lỗ 50,000 VNĐ | Hòa vốn |
| **Trách nhiệm Rescuer** | Ít (gọi Expert thoải mái) | Cao (cân nhắc trước khi gọi) |
| **Khả năng lạm dụng** | Cao | Thấp |
| **Động lực Rescuer** | Gọi Expert ngay cả ca dễ | Chỉ gọi khi thực sự cần |
| **Tính bền vững** | Khó (Platform lỗ nhiều) | Tốt (tự cân bằng) |

**Khi nào nên dùng Phương án 2?**

✅ **Nên dùng khi:**
- Rescuer đã có kinh nghiệm (biết khi nào cần gọi Expert)
- Tình huống phức tạp THỰC SỰ (không phải ca đơn giản)
- Rescuer có thỏa thuận hợp tác với Expert từ trước
- Platform muốn tiết kiệm chi phí vận hành
- Cần tránh lạm dụng hệ thống hỗ trợ

❌ **Không nên dùng khi:**
- Rescuer mới vào nghề (ít kinh nghiệm)
- Tình huống khẩn cấp, nguy hiểm cao
- Platform muốn khuyến khích an toàn tối đa
- Cần xây dựng văn hóa "hỗ trợ lẫn nhau"

**Lợi ích của Phương án 2:**

✅ **Cho Platform:**
- Không mất tiền → Giữ được 10% doanh thu
- Chi phí vận hành dự đoán được
- Không lo lắng Rescuer lạm dụng
- Mô hình kinh doanh bền vững hơn

✅ **Cho Expert:**
- Vẫn nhận được 50,000 VNĐ (giống PA1)
- Thu nhập ổn định từ hỗ trợ khẩn cấp
- Được tôn trọng giá trị chuyên môn

✅ **Cho Rescuer:**
- Mất 50K nhưng đổi lại:
  - An toàn tính mạng (vô giá)
  - Tiết kiệm thời gian (1.5 giờ)
  - Có thể nhận thêm ca khác (kiếm lại tiền)
  - Học hỏi từ Expert (tăng trình độ)
  - Bảo vệ rating (quan trọng cho thu nhập lâu dài)

✅ **Cho Patient:**
- Không ảnh hưởng gì (vẫn trả 500K)
- Yên tâm vì biết Rescuer có Expert backup
- Dịch vụ chất lượng, chuyên nghiệp

**Kịch bản thực tế:**

```
TÌNH HUỐNG: Rescuer Nguyễn Văn A gặp rắn hổ mang chúa

[Bước 1] Rescuer nhận ca: phí 500K
         "À, rắn hổ mang chúa... loài này nguy hiểm lắm!"
         
[Bước 2] Cân nhắc:
         - Tự xử lý: Nhận 425K nhưng nguy hiểm, có thể mất 2 giờ
         - Gọi Expert: Mất 50K nhưng an toàn, xong nhanh trong 30 phút
         
[Bước 3] Quyết định: Gọi Expert
         "50K để đảm bảo an toàn và xử lý đúng cách là xứng đáng!"
         
[Bước 4] Expert tư vấn:
         "Anh chú ý điểm này... dùng gậy dài 2m... tránh phần đầu..."
         
[Bước 5] Rescuer bắt thành công trong 25 phút
         
[Bước 6] Nhận 375K (đã trừ 50K cho Expert)
         
[Bước 7] Tính toán lại:
         - Tiết kiệm 1.5 giờ → Nhận thêm 1 ca nữa → kiếm thêm 350K
         - Tổng thu nhập: 375K + 350K = 725K (trong 1.5 giờ)
         - Nếu không gọi Expert: 425K (trong 2 giờ) + rủi ro cao
         
KẾT LUẬN: Gọi Expert là quyết định ĐÚNG!
```

**Lưu ý quan trọng:**

⚠️ **Rescuer cần hiểu:**
- Mất 50K là **chi phí đầu tư** cho an toàn và hiệu quả
- Giống như mua bảo hiểm: trả tiền để được bảo vệ
- Tiết kiệm thời gian → có thể nhận thêm ca → kiếm lại tiền

⚠️ **Platform cần công bố rõ:**
- Chính sách phân chia phải minh bạch
- Rescuer biết trước là sẽ mất 10% nếu gọi Expert
- Không có bất ngờ về tài chính

⚠️ **Cơ chế linh hoạt:**
- Rescuer mới (< 3 tháng): Dùng PA1 (Platform trả) để khuyến khích
- Rescuer có kinh nghiệm: Dùng PA2 (Rescuer chia)
- Admin có thể cấu hình theo từng trường hợp

#### 3.2. Tính năng liên quan

| Mã tính năng | Mô tả | Vai trò |
|--------------|-------|---------|
| **FE-12** (Rescuer) | Trao đổi thông tin với chuyên gia rắn để nhận diện chính xác | Rescuer |
| **FE-13** (Rescuer) | Yêu cầu hỗ trợ từ xa khi gặp loài rắn khó xác định | Rescuer |
| **FE-14** (Rescuer) | Chia sẻ ảnh/video real-time với chuyên gia | Rescuer |
| **FE-11** (Expert) | Tư vấn cho đội cứu hộ về cách xử lý loài rắn phức tạp | Expert |

---

## 📊 TỔNG HỢP PHÂN CHIA DOANH THU

### Bảng tổng hợp tỷ lệ phân chia

| Loại dịch vụ | Patient trả | Rescuer nhận | Expert nhận | Platform nhận | Quỹ bảo hiểm | Ghi chú |
|--------------|-------------|--------------|-------------|---------------|--------------|---------|
| **Cứu hộ rắn** (không có Expert) | 100% | 85% | - | 10% | 5% | Trường hợp thông thường |
| **Cứu hộ rắn** (có hỗ trợ Expert - PA1) | 100% | 85% | Platform trả | 10% - phí Expert | 5% | Platform chịu chi phí Expert |
| **Cứu hộ rắn** (có hỗ trợ Expert - PA2) | 100% | 75% | 10% | 10% | 5% | Rescuer chia cho Expert |
| **Tư vấn trực tiếp** | 100% | - | 90% | 10% | - | Patient đặt lịch với Expert |

### Ví dụ minh họa tổng hợp

**Tình huống 1: Cứu hộ rắn đơn giản (không cần Expert)**
- Patient trả: **500,000 VNĐ**
- Rescuer nhận: **425,000 VNĐ** (85%)
- Platform nhận: **50,000 VNĐ** (10%)
- Quỹ bảo hiểm: **25,000 VNĐ** (5%)

**Tình huống 2: Cứu hộ rắn phức tạp (cần Expert hỗ trợ - Phương án 1)**
- Patient trả: **500,000 VNĐ**
- Rescuer nhận: **425,000 VNĐ** (85%)
- Expert nhận: **50,000 VNĐ** (Platform trả)
- Platform nhận: **0 VNĐ** (10% - 50,000 = 0, hoặc lỗ nếu Expert fee > 50,000)
- Quỹ bảo hiểm: **25,000 VNĐ** (5%)
- **Platform lỗ hoặc hòa vốn** để đảm bảo an toàn cho Rescuer

**Tình huống 3: Cứu hộ rắn phức tạp (cần Expert hỗ trợ - Phương án 2)**
- Patient trả: **500,000 VNĐ**
- Rescuer nhận: **375,000 VNĐ** (75%)
- Expert nhận: **50,000 VNĐ** (10%)
- Platform nhận: **50,000 VNĐ** (10%)
- Quỹ bảo hiểm: **25,000 VNĐ** (5%)

**Tình huống 4: Tư vấn chuyên gia trực tiếp**
- Patient trả: **300,000 VNĐ**
- Expert nhận: **270,000 VNĐ** (90%)
- Platform nhận: **30,000 VNĐ** (10%)

**Tình huống 5: Tư vấn khẩn cấp qua SOS (Optional)**
- Patient trả: **500,000 VNĐ**
- Expert nhận: **450,000 VNĐ** (90%)
- Platform nhận: **50,000 VNĐ** (10%)

---

### 4. LUỒNG TIỀN: EXPERT CONSULTATION VIA SOS (TƯ VẤN KHẨN CẤP)

**Kịch bản:** Patient bị rắn cắn và đang trong tình huống SOS → Patient muốn được tư vấn từ Expert ngay lập tức qua tính năng gọi khẩn cấp → Expert tư vấn sơ cứu và đưa ra phương án phù hợp

#### 4.1. Đặc điểm của dịch vụ này

- ✅ **Optional service:** Patient có thể lựa chọn hoặc không khi đang trong SOS
- ✅ **Tư vấn tận tình:** Expert sẽ hướng dẫn chi tiết cách sơ cứu ban đầu
- ✅ **Đưa ra phương án:** Expert đánh giá tình trạng và đề xuất giải pháp phù hợp
- ✅ **Yên tâm cho khách hàng:** Được chuyên gia trực tiếp hướng dẫn trong tình huống nguy hiểm
- ⚡ **Khẩn cấp:** Phản hồi trong vòng 1-2 phút
- 💰 **Phí cao hơn:** Do tính khẩn cấp và ưu tiên cao nhất

#### 4.2. Quy trình thanh toán

```
┌──────────┐                  ┌──────────┐                  ┌──────────┐
│          │   1. SOS: Bị rắn │          │                  │          │
│ PATIENT  │───cắn, cần tư vấn>│ PLATFORM │                  │  EXPERT  │
│          │   gấp từ Expert   │          │                  │          │
└────┬─────┘                  └────┬─────┘                  └────┬─────┘
     │                             │                             │
     │ 2. Chọn "Gọi Expert qua SOS"│                             │
     │    (Optional)               │                             │
     ├────────────────────────────>│                             │
     │                             │                             │
     │ 3. THANH TOÁN 100% NGAY     │                             │
     │    (500,000 VNĐ)            │                             │
     ├────────────────────────────>│                             │
     │                             │ → Vào ESCROW               │
     │                             │                             │
     │                             │ 4. Platform tìm Expert      │
     │                             │    sẵn sàng (trong 1-2 phút)│
     │                             ├────────────────────────────>│
     │                             │                             │
     │                             │ 5. Expert chấp nhận SOS     │
     │                             │<────────────────────────────┤
     │                             │                             │
     │ 6. Kết nối tư vấn ngay      │                             │
     │    qua video call           │                             │
     │<───────────────────────────────────────────────────────>│
     │                             │                             │
     │ 7. Expert tư vấn:           │                             │
     │    - Cách sơ cứu ban đầu   │                             │
     │    - Đánh giá mức độ nguy hiểm                           │
     │    - Đề xuất phương án (đi BV/tự xử lý)                 │
     │<───────────────────────────────────────────────────────>│
     │                             │                             │
     │                             │ 8. Sau khi hoàn thành       │
     │                             │    Platform phân chia:      │
     │                             │    - 90% → Expert          │
     │                             │    - 10% → Platform        │
     │                             ├────────────────────────────>│
     │                             │                             │
     │ 9. Nhận hóa đơn & đánh giá │                             │
     │<────────────────────────────┤                             │
     │                             │                             │
     │                             │ 10. Expert nhận thông báo   │
     │                             │     "Đã nhận 450K"         │
     │                             │<────────────────────────────┤
```

#### 4.3. Phân chia doanh thu chi tiết

**Ví dụ cụ thể:**
- Phí tư vấn khẩn cấp qua SOS: **500,000 VNĐ**

| Bên nhận | Tỷ lệ | Số tiền | Mục đích |
|----------|-------|---------|----------|
| **Expert** | 90% | 450,000 VNĐ | Tư vấn khẩn cấp 24/7, ưu tiên cao nhất |
| **Platform (Admin)** | 10% | 50,000 VNĐ | Phí vận hành hệ thống, matching, kết nối video call |
| **TỔNG** | 100% | 500,000 VNĐ | |

**Ghi chú:**
- Patient trả **100% TRƯỚC** khi được kết nối với Expert
- Tiền được giữ trong **ESCROW** cho đến khi hoàn thành tư vấn
- Phí cao hơn tư vấn thường (300K → 500K) do:
  - ⚡ Tính khẩn cấp (SOS, bị rắn cắn)
  - 🚨 Ưu tiên cao nhất trong hệ thống
  - ⏰ Expert phải sẵn sàng 24/7
  - 🎯 Phản hồi trong 1-2 phút

#### 4.4. Timeline thanh toán

```
Timeline:
├─ T0: Patient bấm SOS "Bị rắn cắn"
├─ T+30s: Patient chọn "Gọi Expert ngay" (Optional)
├─ T+45s: Patient thanh toán 100% (500,000 VNĐ) → Vào ESCROW
├─ T+1m: Platform tìm Expert sẵn sàng
├─ T+2m: Expert chấp nhận → Kết nối video call ngay
├─ T+5m: Expert tư vấn sơ cứu, đánh giá tình trạng
├─ T+10m: Expert đưa ra phương án (đi BV/tự xử lý/gọi cấp cứu)
├─ T+12m: Kết thúc tư vấn
├─ T+15m: Platform chuyển tiền:
│         • 450,000 VNĐ → Expert
│         • 50,000 VNĐ → Platform
└─ T+20m: Patient đánh giá dịch vụ
```

#### 4.5. Chính sách hoàn tiền

**Trường hợp hoàn tiền 100%:**
- ❌ Không có Expert nào sẵn sàng trong 2 phút
- ❌ Expert chấp nhận nhưng không kết nối được video call trong 3 phút
- ❌ Lỗi hệ thống, không thể tư vấn được

**Trường hợp hoàn tiền 50%:**
- ⚠️ Patient không hài lòng với chất lượng tư vấn (khiếu nại trong 1 giờ)
- ⚠️ Expert tư vấn không đầy đủ hoặc quá ngắn (< 3 phút)

**Trường hợp KHÔNG hoàn tiền:**
- ✅ Patient đã nhận được tư vấn đầy đủ từ Expert
- ✅ Patient hủy sau khi Expert đã bắt đầu tư vấn
- ✅ Patient tự ngắt cuộc gọi giữa chừng

**Lưu ý quan trọng:**
- ✅ Patient phải **THANH TOÁN 100% TRƯỚC** khi được kết nối
- ✅ Tiền được giữ trong **ESCROW** - Expert chưa nhận ngay
- ✅ Expert nhận tiền **SAU KHI** hoàn thành tư vấn (5-10 phút)
- ⚠️ Nếu Expert **không phản hồi trong 2 phút** → Hoàn tiền 100%
- ⚠️ Nếu Patient **hủy sau khi Expert chấp nhận** → Mất 100%
- ⚠️ Nếu Patient **hủy trước khi Expert chấp nhận** → Hoàn tiền 100%

#### 4.6. Khác biệt so với Expert Consultation thường

| Tiêu chí | Expert Consultation thường | Expert via SOS (Khẩn cấp) |
|----------|---------------------------|---------------------------|
| **Giá** | 300,000 VNĐ | 500,000 VNĐ (+67%) |
| **Phản hồi** | 5-15 phút | 1-2 phút |
| **Ưu tiên** | Thường | Cao nhất |
| **Đặt lịch** | Có thể đặt trước | Gọi ngay lập tức |
| **Tình huống** | Tư vấn thông thường | Khẩn cấp (bị rắn cắn) |
| **Thời gian** | 15-30 phút | 5-10 phút (nhanh, tập trung) |
| **Nội dung** | Tư vấn chi tiết, giải đáp nhiều câu hỏi | Sơ cứu, đánh giá, đưa phương án |

#### 4.7. Tính năng liên quan

| Mã tính năng | Mô tả | Vai trò |
|--------------|-------|---------|
| **FE-05** (Patient) | Gửi yêu cầu SOS và tự động gọi cấp cứu (911) | Patient |
| **FE-27** (Patient) | Thanh toán phí tư vấn chuyên gia rắn trực tuyến | Patient |
| **FE-29** (Patient) | Theo dõi trạng thái thanh toán và hóa đơn điện tử | Patient |
| **FE-17** (Expert) | Nhận thông báo SOS khẩn cấp | Expert |
| **FE-18** (Expert) | Tư vấn qua video call cho Patient trong SOS | Expert |
| **FE-14** (Expert) | Nhận thanh toán qua nền tảng và xuất hóa đơn điện tử | Expert |

---

## 💳 PHƯƠNG THỨC THANH TOÁN

### Các cổng thanh toán được tích hợp

| Phương thức | Ví dụ | Phí giao dịch | Thời gian xử lý |
|-------------|-------|---------------|-----------------|
| **Ví điện tử** | Momo, VNPay, ZaloPay | 1-2% | Tức thì |
| **Thẻ tín dụng/ghi nợ** | Visa, Mastercard, JCB | 2.5-3% | 1-2 phút |
| **Internet Banking** | Vietcombank, BIDV, Techcombank | 0.5-1% | 5-10 phút |
| **Tiền mặt** | Trực tiếp cho Rescuer | 0% | Tức thì |

**Lưu ý:**
- Phí giao dịch do **Platform chịu**, không trừ vào phần của Rescuer/Expert
- Nếu phí giao dịch là 2% → Platform chịu 2% để đảm bảo Rescuer/Expert nhận đủ tỷ lệ đã cam kết
- Ví dụ: Rescuer nhận 85% của 500,000 = 425,000 VNĐ (không bị trừ phí giao dịch)

---

## 🔄 QUY TRÌNH THANH TOÁN CHI TIẾT

### Quy trình chi tiết từng bước

```
┌─────────────────────────────────────────────────────────────────┐
│                    QUY TRÌNH THANH TOÁN                         │
└─────────────────────────────────────────────────────────────────┘

[Bước 1] Hoàn thành dịch vụ
         ↓
[Bước 2] Rescuer/Expert đánh dấu "Hoàn thành"
         ↓
[Bước 3] Hệ thống gửi thông báo đến Patient
         "Vui lòng thanh toán và đánh giá dịch vụ"
         ↓
[Bước 4] Patient mở app → Xem hóa đơn → Chọn phương thức thanh toán
         ↓
[Bước 5] Patient xác nhận thanh toán
         ↓
[Bước 6] Cổng thanh toán xử lý (Momo/VNPay/Card...)
         ↓
[Bước 7] Thanh toán thành công → Tiền vào tài khoản Platform
         ↓
[Bước 8] Platform tự động phân chia:
         - X% → Tài khoản Rescuer/Expert (trong 5-10 phút)
         - Y% → Doanh thu Platform
         - Z% → Quỹ bảo hiểm (nếu có)
         ↓
[Bước 9] Rescuer/Expert nhận thông báo "Đã nhận thanh toán XXX VNĐ"
         ↓
[Bước 10] Patient đánh giá dịch vụ (1-5 sao + nhận xét)
         ↓
[Bước 11] Hệ thống cập nhật rating và lưu vào lịch sử
         ↓
[Bước 12] Xuất hóa đơn điện tử cho tất cả các bên
```

---

## ⚠️ CÁC TRƯỜNG HỢP ĐẶC BIỆT

### 1. Tranh chấp thanh toán

#### Tình huống 1: Patient khiếu nại "Rescuer không đến"

**Quy trình xử lý:**
```
[Bước 1] Patient gửi khiếu nại qua app
         ↓
[Bước 2] Admin nhận thông báo và kiểm tra:
         - Lịch sử GPS của Rescuer
         - Thời gian chấp nhận nhiệm vụ
         - Log cuộc gọi/tin nhắn
         - Ảnh chụp hiện trường (nếu có)
         ↓
[Bước 3A] Nếu Rescuer KHÔNG ĐẾN (GPS không đến gần địa điểm)
          → Hoàn tiền 100% cho Patient
          → Phạt Rescuer (giảm rating, cảnh cáo)
          ↓
[Bước 3B] Nếu Rescuer ĐÃ ĐẾN nhưng không hoàn thành
          → Tùy tình huống:
             * Patient cung cấp sai địa chỉ → Patient mất 50%
             * Rắn đã chạy mất trước khi Rescuer đến → Patient trả 30%
             * Rescuer từ chối bắt (quá nguy hiểm) → Không tính phí
          ↓
[Bước 4] Admin đưa ra quyết định cuối cùng và thực hiện hoàn tiền (nếu có)
         ↓
[Bước 5] Gửi thông báo kết quả cho cả 2 bên
```

#### Tình huống 2: Rescuer khiếu nại "Patient không thanh toán"

**Quy trình xử lý:**
```
[Bước 1] Rescuer gửi khiếu nại qua app
         ↓
[Bước 2] Admin kiểm tra trạng thái thanh toán:
         - Patient đã xác nhận hoàn thành chưa?
         - Có ảnh chụp hoàn thành không?
         - Thời gian đã bao lâu kể từ lúc hoàn thành?
         ↓
[Bước 3] Admin gửi nhắc nhở đến Patient:
         "Vui lòng thanh toán cho dịch vụ cứu hộ"
         ↓
[Bước 4A] Patient thanh toán trong 24h → Giải quyết xong
         ↓
[Bước 4B] Patient không phản hồi trong 48h
          → Admin tự động trừ tiền từ thẻ đã lưu (nếu có)
          → Hoặc khóa tài khoản Patient cho đến khi thanh toán
          ↓
[Bước 5] Rescuer nhận tiền + Thông báo kết quả
```

#### Tình huống 3: Expert khiếu nại "Tư vấn xong nhưng chưa nhận tiền"

**Quy trình xử lý:**
```
[Lưu ý] Với tư vấn, tiền đã được giữ trong escrow nên ít xảy ra vấn đề

[Bước 1] Expert kiểm tra tài khoản và thấy chưa nhận tiền
         ↓
[Bước 2] Expert gửi khiếu nại qua app
         ↓
[Bước 3] Admin kiểm tra:
         - Expert đã đánh dấu "Hoàn thành" chưa?
         - Tiền có trong escrow không?
         - Có lỗi kỹ thuật không?
         ↓
[Bước 4] Admin xử lý:
         - Nếu Expert quên đánh dấu hoàn thành → Hướng dẫn đánh dấu
         - Nếu lỗi kỹ thuật → Chuyển tiền thủ công trong 1h
         - Nếu Patient khiếu nại chất lượng → Admin xem xét lại
         ↓
[Bước 5] Giải quyết và thông báo cho Expert
```

### 2. Hoàn tiền (Refund)

#### Các trường hợp được hoàn tiền

| Tình huống | Hoàn tiền | Thời gian | Ghi chú |
|------------|-----------|-----------|---------|
| **Rescuer không đến** | 100% | 3-5 ngày | Patient được hoàn tiền đầy đủ |
| **Patient hủy trước 2h** | 80% | 3-5 ngày | Mất 20% phí hủy |
| **Patient hủy trong 2h** | 50% | 3-5 ngày | Mất 50% vì Rescuer đã chuẩn bị |
| **Expert không tham gia** | 100% | Tức thì | Tiền từ escrow trả lại ngay |
| **Expert đến muộn >15 phút** | 100% | Tức thì | Patient có quyền hủy và hoàn tiền |
| **Dịch vụ không đạt yêu cầu** | 30-50% | 5-7 ngày | Admin xem xét từng trường hợp |

#### Quy trình hoàn tiền

```
[Bước 1] Patient/Expert gửi yêu cầu hoàn tiền qua app
         (Mục: "Yêu cầu hoàn tiền" + Lý do)
         ↓
[Bước 2] Admin nhận yêu cầu và xem xét trong 24h
         ↓
[Bước 3] Admin kiểm tra:
         - Lý do hoàn tiền có chính đáng không?
         - Có bằng chứng không?
         - Quy định hoàn tiền áp dụng cho trường hợp này
         ↓
[Bước 4A] Chấp nhận hoàn tiền:
          → Tính toán số tiền hoàn lại (100%, 80%, 50%...)
          → Thực hiện hoàn tiền qua cổng thanh toán
          → Thời gian: 3-5 ngày làm việc (tùy phương thức)
          ↓
[Bước 4B] Từ chối hoàn tiền:
          → Gửi thông báo kèm lý do rõ ràng cho Patient
          ↓
[Bước 5] Gửi thông báo trạng thái hoàn tiền cho Patient
         ↓
[Bước 6] Lưu vào lịch sử giao dịch và báo cáo tài chính
```

### 3. Chính sách hoàn tiền của Platform

**Nguyên tắc chung:**
- Platform cam kết hoàn tiền nếu dịch vụ không được thực hiện
- Thời gian hoàn tiền: 3-5 ngày làm việc
- Phí hoàn tiền (refund fee): Platform chịu, không trừ vào số tiền hoàn lại
- Nếu hoàn tiền do lỗi của Rescuer/Expert → Platform sẽ xử lý kỷ luật (cảnh cáo, khóa tài khoản)

---

## 📈 BÁO CÁO TÀI CHÍNH (ADMIN)

### Dashboard tài chính Admin

Admin có thể theo dõi các chỉ số sau:

#### 1. Doanh thu tổng thể

| Chỉ số | Công thức | Ví dụ |
|--------|-----------|-------|
| **Tổng giao dịch trong tháng** | Số lượng giao dịch | 1,234 giao dịch |
| **Tổng giá trị giao dịch** | Tổng tiền Patient đã trả | 450,000,000 VNĐ |
| **Doanh thu Platform** | 10% tổng giá trị | 45,000,000 VNĐ |
| **Doanh thu Rescuer** | 85% từ cứu hộ | 280,000,000 VNĐ |
| **Doanh thu Expert** | 90% từ tư vấn | 108,000,000 VNĐ |
| **Quỹ bảo hiểm tích lũy** | 5% từ cứu hộ | 17,000,000 VNĐ |

#### 2. Phân tích theo loại dịch vụ

```
┌────────────────────────────────────────────────────────┐
│                   THÁNG 12/2025                        │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Cứu hộ rắn:                                          │
│  - Số ca: 856 ca                                      │
│  - Tổng tiền: 320,000,000 VNĐ                        │
│  - Trung bình: 373,832 VNĐ/ca                        │
│  - Rescuer nhận: 272,000,000 VNĐ (85%)              │
│  - Platform: 32,000,000 VNĐ (10%)                    │
│  - Bảo hiểm: 16,000,000 VNĐ (5%)                    │
│                                                        │
│  Tư vấn chuyên gia:                                   │
│  - Số buổi: 378 buổi                                  │
│  - Tổng tiền: 130,000,000 VNĐ                        │
│  - Trung bình: 344,086 VNĐ/buổi                      │
│  - Expert nhận: 117,000,000 VNĐ (90%)               │
│  - Platform: 13,000,000 VNĐ (10%)                    │
│                                                        │
│  TỔNG DOANH THU PLATFORM: 45,000,000 VNĐ             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

#### 3. Báo cáo thanh toán

| Trạng thái | Số lượng | Tỷ lệ | Giá trị |
|------------|----------|-------|---------|
| **Đã thanh toán** | 1,156 | 93.7% | 421,000,000 VNĐ |
| **Đang chờ thanh toán** | 56 | 4.5% | 21,000,000 VNĐ |
| **Tranh chấp** | 15 | 1.2% | 6,500,000 VNĐ |
| **Đã hoàn tiền** | 7 | 0.6% | 2,800,000 VNĐ |
| **TỔNG** | 1,234 | 100% | 451,300,000 VNĐ |

#### 4. Xuất báo cáo

Admin có thể xuất các báo cáo sau:
- **Báo cáo ngày:** Doanh thu hàng ngày
- **Báo cáo tuần:** Doanh thu theo tuần
- **Báo cáo tháng:** Tổng hợp chi tiết theo tháng (FE-33)
- **Báo cáo quý:** Phân tích xu hướng theo quý
- **Báo cáo năm:** Tổng kết doanh thu cả năm

**Định dạng xuất báo cáo:**
- PDF (in ấn, gửi email)
- Excel (phân tích chi tiết)
- CSV (import vào phần mềm kế toán)

---

## 🔐 BẢO MẬT & AN TOÀN THANH TOÁN

### Các biện pháp bảo mật

1. **Mã hóa dữ liệu:**
   - Tất cả thông tin thanh toán được mã hóa SSL/TLS
   - Thông tin thẻ không được lưu trên server (tokenization)
   - Tuân thủ chuẩn PCI DSS

2. **Xác thực giao dịch:**
   - OTP qua SMS cho giao dịch > 500,000 VNĐ
   - 3D Secure cho thanh toán thẻ quốc tế
   - Biometric (vân tay/Face ID) trên mobile

3. **Phòng chống gian lận:**
   - Giám sát giao dịch bất thường (quá nhiều giao dịch trong ngày)
   - Xác minh vị trí GPS (Patient và Rescuer phải gần nhau)
   - Hệ thống chống rửa tiền (AML)

4. **Bảo vệ dữ liệu cá nhân:**
   - Tuân thủ GDPR và luật bảo vệ dữ liệu Việt Nam
   - Chỉ hiển thị 4 số cuối thẻ
   - Không chia sẻ thông tin thanh toán cho bên thứ 3

---

## 📞 HỖ TRỢ & GIẢI ĐÁP

### Câu hỏi thường gặp (FAQ)

**Q1: Tôi bị trừ tiền nhưng Rescuer không đến, làm sao?**
- A: Hãy liên hệ ngay với Admin qua app → "Báo cáo vấn đề" → "Yêu cầu hoàn tiền". Admin sẽ kiểm tra và hoàn tiền trong 24h nếu xác nhận Rescuer không đến.

**Q2: Tôi là Rescuer, khi nào tôi nhận được tiền?**
- A: Sau khi Patient thanh toán, tiền sẽ được chuyển vào tài khoản của bạn trong vòng 5-10 phút. Bạn có thể rút tiền về ngân hàng bất kỳ lúc nào.

**Q3: Phí 10% của Platform bao gồm những gì?**
- A: Phí Platform bao gồm: chi phí vận hành server, cổng thanh toán, bảo trì hệ thống, hỗ trợ khách hàng 24/7, marketing, và các tính năng AI.

**Q4: Nếu tôi hủy lịch tư vấn với Expert, có được hoàn tiền không?**
- A: 
  - Hủy trước 2h: hoàn 80% (mất 20% phí hủy)
  - Hủy trong 2h: hoàn 50%
  - Expert không tham gia: hoàn 100%

**Q5: Tôi có thể thanh toán bằng tiền mặt không?**
- A: Có, bạn có thể thanh toán trực tiếp bằng tiền mặt cho Rescuer. Tuy nhiên, hệ thống khuyến khích thanh toán qua app để có bảo vệ và hóa đơn điện tử.

**Q6: Quỹ bảo hiểm 5% dùng để làm gì?**
- A: Quỹ bảo hiểm được sử dụng để hỗ trợ Rescuer khi gặp tai nạn trong quá trình cứu hộ (bị rắn cắn, chấn thương...). Đây là chương trình bảo hiểm do Platform tài trợ.

---

## 📋 TỔNG KẾT

### Sơ đồ luồng tiền tổng quan

```
                          ┌─────────────────────┐
                          │                     │
                          │   PATIENT (100%)    │
                          │                     │
                          └──────────┬──────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                  │
                    ▼                                  ▼
        ┌───────────────────┐              ┌───────────────────┐
        │  CỨHỘ RẮN      │              │  TƯ VẤN EXPERT    │
        │   (500K)          │              │   (300K)          │
        └─────────┬─────────┘              └─────────┬─────────┘
                  │                                    │
        ┌─────────┴──────────┐              ┌─────────┴─────────┐
        │                     │              │                    │
        ▼                     ▼              ▼                    ▼
   ┌─────────┐         ┌─────────┐    ┌─────────┐        ┌─────────┐
   │ RESCUER │         │PLATFORM │    │  EXPERT │        │PLATFORM │
   │  425K   │         │  50K    │    │  270K   │        │  30K    │
   │  (85%)  │         │  (10%)  │    │  (90%)  │        │  (10%)  │
   └─────────┘         └─────────┘    └─────────┘        └─────────┘
        │                    │
        ▼                    ▼
   ┌─────────┐         ┌─────────┐
   │ BẢO HIỂM│         │         │
   │  25K    │         │  (Chi   │
   │  (5%)   │         │  phí)   │
   └─────────┘         └─────────┘
```

### Điểm chính cần nhớ

1. **Cứu hộ rắn:** 85% Rescuer + 10% Platform + 5% Bảo hiểm
2. **Tư vấn Expert:** 90% Expert + 10% Platform
3. **Hỗ trợ khẩn cấp:** Platform trả hoặc Rescuer chia 10% cho Expert
4. **Thanh toán cứu hộ:** SAU khi hoàn thành
5. **Thanh toán tư vấn:** TRƯỚC khi bắt đầu (escrow)
6. **Hoàn tiền:** 3-5 ngày làm việc
7. **Phí giao dịch:** Platform chịu
8. **Bảo mật:** Tuân thủ PCI DSS và các chuẩn quốc tế

---

## 📎 PHỤ LỤC

### Danh sách tính năng liên quan đến thanh toán

**Patient:**
- FE-27: Thanh toán phí tư vấn chuyên gia rắn trực tuyến
- FE-28: Thanh toán phí cứu hộ rắn trực tiếp cho đội cứu hộ qua nền tảng
- FE-29: Theo dõi trạng thái thanh toán và hóa đơn điện tử
- FE-30: Xem lịch sử giao dịch và chi tiết dịch vụ đã sử dụng

**Rescuer:**
- FE-24: Chấp nhận yêu cầu cứu hộ có trả phí từ bệnh nhân
- FE-25: Theo dõi doanh thu, trạng thái thanh toán và lịch sử giao dịch
- FE-26: Nhận thanh toán qua nền tảng sau khi hoàn thành cứu hộ
- FE-27: Xem đánh giá và nhận phản hồi từ khách hàng để cải thiện ưu tiên xếp hạng

**Expert:**
- FE-13: Thiết lập mức phí tư vấn trực tuyến
- FE-14: Nhận thanh toán qua nền tảng và xuất hóa đơn điện tử
- FE-15: Xem báo cáo doanh thu theo tháng/quý
- FE-16: Theo dõi số lượt tư vấn và đánh giá từ khách hàng

**Admin:**
- FE-30: Thiết lập mức phí cho dịch vụ cứu hộ và tư vấn chuyên gia
- FE-31: Theo dõi tổng doanh thu và phân chia thu nhập cho rescuer/expert
- FE-32: Quản lý thanh toán giữa bệnh nhân – rescuer/expert – nền tảng
- FE-33: Tạo báo cáo tài chính định kỳ (tháng/quý/năm)
- FE-34: Quản lý hoa hồng nền tảng và chính sách hoàn tiền
- FE-35: Xử lý tranh chấp thanh toán và yêu cầu hoàn tiền

---

**HẾT TÀI LIỆU**

*Tài liệu này là phần của SnakeAid Platform Documentation*  
*Liên hệ Admin nếu có thắc mắc về luồng thanh toán*
