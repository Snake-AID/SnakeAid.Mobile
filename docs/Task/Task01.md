# Snake Catching Flow Update (Operator-based Assignment)

## 1. Overview
File tham chiếu: `01-Activity-Snake-Catching-Flow.md`

Sau buổi họp, flow bắt rắn đã được thay đổi để phù hợp với mô hình vận hành tập trung (centralized system).

---

## 2. Flow Changes

### ❌ Old Flow
- Member tạo request
- Rescuer có thể:
  - Accept
  - Reject

### ✅ New Flow
- Member tạo request → gửi lên hệ thống
- Thêm role mới: **Operator**

Operator sẽ chịu trách nhiệm xử lý request thông qua 2 trạng thái:

#### Status Definitions
- **Confirmed**
  - Operator đã gọi xác nhận với khách
  - Request được xác nhận là hợp lệ

- **Assigned**
  - Operator đã confirm
  - Gán rescuer cụ thể vào request

> Lưu ý: Flow này được xử lý ở backend/web, mobile chỉ nhận kết quả

---

## 3. Realtime Notification (SignalR)

Khi request chuyển sang trạng thái **Assigned**:

### Backend
- Trigger SignalR event

### Mobile
- Listen SignalR (tương tự flow SOS/Incident)
- Khi nhận event:
  - Hiển thị popup modal tại:
    - `rescuer_home_screen.dart`
  - Nội dung:
    - Thông báo có đơn bắt rắn mới
  - Action:
    - Button **"Xem chi tiết"**
    - Navigate đến:
      - `rescuer_request_detail_screen.dart`

---

## 4. Rescuer UI & API Updates

### File: `rescuer_available_jobs_screen.dart`

#### UI Changes
- ❌ Remove:
  - "Đơn có thể nhận"
- ✅ Redesign:
  - Chỉ hiển thị:
    - Đơn đã được assign
    - Lịch sử đơn

#### API
GET /api/snakecatching/requests?userId={userId}


#### Requirements
- Hiển thị:
  - Assigned requests
  - Request history
- Không hiển thị:
  - Status `Completed`
  - Status `Paid`

---

## 5. Remove Payment to Rescuer

### Remove hoàn toàn:

#### Status
- `Paid`

#### Endpoint
POST /api/v1/payos/transfer-to-rescuer


#### Related file
- `activity_detail_screen.dart`

### Reason
- Hệ thống chuyển sang mô hình **trung tâm**
- Không còn chuyển tiền trực tiếp cho rescuer

---

## 6. Customer Payment Flow Update

### File: `activity_detail_screen.dart`

Sau khi tạo request:

#### Allowed Payment Status
- `Pending`
- `Confirmed`
- `Assigned`

#### Payment Type
- Deposit (estimatedPrice)

#### Existing Logic (Giữ nguyên)

GET /api/transactions/snakecatchingrequest/{snakecatchingrequestId}

Check:

transactionType == CatchingDeposit

> Không thay đổi logic hiện tại

---

## 7. Remove Accept Flow

### Remove endpoint
POST /api/snakecatching/requests/accept


### Update Behavior
- Rescuer không còn quyền accept request
- Rescuer chỉ nhận job khi được Operator assign

---

## 8. Summary

- Thêm role **Operator**
  - Xử lý: `Confirmed`, `Assigned`
- Rescuer:
  - Không còn accept job
  - Nhận job qua SignalR
- UI:
  - Remove "Đơn có thể nhận"
  - Chỉ hiển thị job được assign + history
- Remove:
  - Status `Paid`
  - Transfer tiền cho rescuer
- Customer:
  - Có thể thanh toán deposit ở nhiều trạng thái (pending, confirmed, assigned)
  - Giữ nguyên logic transaction check

---