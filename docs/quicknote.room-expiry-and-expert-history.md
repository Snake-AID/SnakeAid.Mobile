# Quick Note: Room Expiry & Expert Consultation History

> Bàn giao cho mobile dev — 2026-03-30

---

## 1. Expert Consultation History

### `GET /api/experts/me/consultations`

Endpoint MỚI. Expert xem toàn bộ lịch sử tư vấn (scheduled + emergency).

**Auth**: Bearer JWT, role `Expert`

**Query params**: `?status=Ongoing|Completed` `&type=Scheduled|Emergency` `&pageNumber=1` `&pageSize=10`

**Response**:
```json
{
  "data": {
    "items": [
      {
        "consultationId": "bfa25be0-...",
        "type": "Scheduled",
        "status": "Completed",
        "userId": "2a6d6f8f-...",
        "userName": "Alice Smith",
        "roomId": "consultation-bfa25be0...",
        "startTime": "2026-03-28T10:00:00Z",
        "endTime": "2026-03-28T10:30:00Z",
        "price": 150000,
        "bookingId": "7da8e6c6-...",
        "slotStartTime": "2026-03-28T10:00:00Z",
        "slotEndTime": "2026-03-28T10:30:00Z",
        "emergencyRequestId": null
      },
      {
        "consultationId": "ccc11111-...",
        "type": "Emergency",
        "status": "Completed",
        "userId": "d90d01f7-...",
        "userName": "Bob Johnson",
        "roomId": "consultation-ccc11111...",
        "startTime": "2026-03-27T14:00:00Z",
        "endTime": "2026-03-27T14:28:00Z",
        "price": null,
        "bookingId": null,
        "slotStartTime": null,
        "slotEndTime": null,
        "emergencyRequestId": "e12e34f5-..."
      }
    ],
    "meta": { "currentPage": 1, "pageSize": 10, "totalItems": 2, "totalPages": 1 }
  }
}
```

**Quy tắc trường theo type**:

| Trường | Scheduled | Emergency |
|--------|-----------|-----------|
| price | từ booking | null |
| bookingId | có | null |
| slotStartTime/slotEndTime | có | null |
| emergencyRequestId | null | có |

**Khác biệt với User endpoint** (`GET /api/users/me/consultations`): hiển thị `userId`/`userName` (caller) thay vì `expertId`/`expertName`, không có `problemDescription`.

**Endpoint cũ** `GET /api/experts/me/consultations/scheduled` vẫn hoạt động, không bị ảnh hưởng.

---

## 2. Room Expiry — SignalR `RoomExpiring`

Khi consultation hết giờ, backend tự động gửi signal rồi xóa phòng.

**Điều kiện**:
- Scheduled: `TimeSlot.EndTime <= UtcNow`
- Emergency: `StartTime + 30 phút <= UtcNow`

**Event trên** `/hubs/consultation`:

```json
{ "ConsultationId": "bfa25be0-...", "Reason": "slot_elapsed" }
```

**Thứ tự backend xử lý**: signal → xóa phòng LiveKit → update status `Completed` → settlement

**Mobile cần làm**:
1. Listen event `RoomExpiring` trên ConsultationHub
2. Hiển thị thông báo "Phòng sắp đóng do hết giờ"
3. Sau vài trăm ms, LiveKit SDK sẽ fire disconnect
4. Navigate về màn hình kết thúc / đánh giá

**Không cần làm**: gọi API trigger — hoàn toàn tự động từ backend (sweep mỗi 30 giây).
