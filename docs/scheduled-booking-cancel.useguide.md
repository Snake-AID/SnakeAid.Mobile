---
doc_role: planning
module: scheduled-booking-cancel
kind: flow
doc_type: useguide
status: current
last_updated: 2026-04-21
api_version: v1
owners: [backend-team]
verification_status: implemented-and-code-verified
---

# Scheduled Booking Cancel Useguide

## 1. Table Of Contents

- [1. Table Of Contents](#1-table-of-contents)
- [2. Overview](#2-overview)
- [3. Authentication & Authorization](#3-authentication--authorization)
- [4. Expert/Member Business + Expert/Member APIs](#4-expertmember-business--expertmember-apis)
- [5. Admin Business + Admin APIs](#5-admin-business--admin-apis)
- [6. Shared Data Models](#6-shared-data-models)
- [7. Verified Endpoint List](#7-verified-endpoint-list)
- [8. Changelog](#8-changelog)

## 2. Overview

Current verified backend behavior:

- users can create a scheduled booking
- users can pay for a scheduled booking
- current payment supports both `WalletBalance` and `PayOs`
- users can read their own scheduled bookings
- experts can read their scheduled bookings
- users and experts can cancel future scheduled bookings
- expert-cancel of a paid booking refunds the booking owner
- expert-cancel queues a Vietnamese push notification to the booking owner/member
- member-cancel of a paid booking does not refund
- member-cancel of a paid confirmed booking settles escrow as part of cancellation
- cancelling a pending PayOs payment removes the local pending payment transaction and attempts to cancel the PayOs link

## 3. Authentication & Authorization

### Expert/Member Operations

- JWT Bearer token is required
- `User` can create, pay, list own bookings, and cancel own bookings
- `Expert` can list assigned bookings and cancel assigned bookings

### Admin Operations

- no admin-specific scheduled booking cancel API is currently in scope

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Current Verified Flow

Current code-verified flow:

1. member creates a scheduled booking
2. booking starts at `PendingPayment`
3. member pays the booking
4. wallet payment moves money into escrow immediately, while PayOs creates a pending intent first
5. after successful wallet payment or PayOs confirmation, booking becomes `Confirmed`
6. after the slot ends, backend auto-completes the booking and settles escrow to the expert

### 4.2 Current Verified `POST /api/consultations/scheduled`

Purpose:

- create a scheduled consultation booking for an available expert slot

Auth:

- JWT Bearer token is required
- caller must have role `User`

Request:

```http
POST /api/consultations/scheduled
Authorization: Bearer <jwt>
Content-Type: application/json
```

```json
{
  "timeSlotId": "550e8400-e29b-41d4-a716-446655440000",
  "problemDescription": "Need guidance about post-bite symptoms."
}
```

Success response example:

```json
{
  "status_code": 200,
  "message": "Success",
  "is_success": true,
  "data": {
    "id": "7a7a2e73-2bd4-4c8e-bc2f-b6af81e3b1d8",
    "userId": "d8609b6f-a6ad-4de9-8198-0c8186b63e2f",
    "userName": null,
    "expertId": "6eb3c47c-92c9-4d83-9f34-0c0fcba89f7a",
    "expertName": "Dr. Snake Aid",
    "price": 150000,
    "bookedAt": "2026-04-18T10:15:00Z",
    "paymentDeadline": "2026-04-18T10:30:00Z",
    "status": "PendingPayment",
    "problemDescription": "Need guidance about post-bite symptoms.",
    "timeSlotId": "550e8400-e29b-41d4-a716-446655440000",
    "slotStartTime": "2026-04-19T02:00:00Z",
    "slotEndTime": "2026-04-19T02:30:00Z",
    "consultationId": "5f5f35ef-c5e5-4431-8ca0-060f8575461f",
    "roomId": "consultation-5f5f35ef-c5e5-4431-8ca0-060f8575461f"
  },
  "error": null
}
```

### 4.3 Current Verified `POST /api/consultations/scheduled/{bookingId}/payments`

Purpose:

- pay for a scheduled booking

Auth:

- JWT Bearer token is required
- caller must have role `User`
- caller must own the booking

Request:

```http
POST /api/consultations/scheduled/7a7a2e73-2bd4-4c8e-bc2f-b6af81e3b1d8/payments
Authorization: Bearer <jwt>
Content-Type: application/json
```

```json
{
  "paymentMethod": "WalletBalance"
}
```

Current verified backend behavior:

- supports `WalletBalance` and `PayOs`
- wallet path:
  - creates `ConsultationPayment`
  - moves funds into escrow
  - sets booking status to `Confirmed`
- PayOs path:
  - creates a pending payment intent first
  - booking stays non-confirmed until payment confirmation succeeds
  - after confirmation, funds move into escrow and booking becomes `Confirmed`

Success response example:

```json
{
  "status_code": 200,
  "message": "Success",
  "is_success": true,
  "data": {
    "referenceId": "7a7a2e73-2bd4-4c8e-bc2f-b6af81e3b1d8",
    "referenceType": "ScheduledBooking",
    "transactionId": "7cb4f7be-9595-4987-b3e8-4c6ef8e2b2a6",
    "amount": 150000,
    "currency": "VND",
    "paymentMethod": "WalletBalance",
    "status": "Escrowed",
    "userWalletBalanceAfter": 350000,
    "paidAtUtc": "2026-04-18T10:17:00Z",
    "provider": "Wallet",
    "externalTransactionId": "WALLET-5f08d3d4303940d1a12a8f6f884d1171"
  },
  "error": null
}
```

PayOs request example:

```json
{
  "paymentMethod": "PayOs"
}
```

PayOs response shape note:

- current backend returns a consultation payment response for the PayOs intent path
- the exact payload depends on the generated payment link / transaction state
- for cancellation planning, the important distinction is:
  - `PayOs` may still be pending and not yet escrowed
  - refund logic should only run after successful confirmation moved money into escrow

### 4.4 Current Verified `POST /api/consultations/scheduled/{bookingId}/cancel`

Purpose:

- cancel a future scheduled booking
- apply actor-based refund policy

Auth:

- JWT Bearer token is required
- caller role can be `User` or `Expert`
- caller must be either:
  - the booking owner
  - the assigned expert

Request:

```http
POST /api/consultations/scheduled/7a7a2e73-2bd4-4c8e-bc2f-b6af81e3b1d8/cancel
Authorization: Bearer <jwt>
```

Current verified backend behavior:

- `PendingPayment`:
  - cancel booking
  - release slot
  - no escrow refund
  - if a pending `PayOs` transaction exists, backend deletes the local pending payment transaction and best-effort cancels the PayOs link
- `Confirmed` cancelled by `Expert`:
  - cancel booking
  - release slot
  - refund the member
  - queue a member-targeted push notification in Vietnamese after commit succeeds
- `PendingPayment` cancelled by `Expert`:
  - cancel booking
  - release slot
  - queue a member-targeted push notification in Vietnamese after commit succeeds
- `Confirmed` cancelled by `Member`:
  - cancel booking
  - release slot
  - no refund
  - confirmed escrow is settled during cancellation instead of remaining stranded
- linked `Consultation.Status` should also become `Cancelled`
- backend stores `ConsultationBooking.CancellationReason` as an enum-backed field
- outward responses render `CancellationReason` as string values such as `CancelledByMember` and `CancelledByExpert`

Success response example:

```json
{
  "status_code": 200,
  "message": "Scheduled booking cancelled successfully.",
  "is_success": true,
  "data": {
    "id": "7a7a2e73-2bd4-4c8e-bc2f-b6af81e3b1d8",
    "userId": "d8609b6f-a6ad-4de9-8198-0c8186b63e2f",
    "expertId": "6eb3c47c-92c9-4d83-9f34-0c0fcba89f7a",
    "price": 150000,
    "cancelledAt": "2026-04-20T10:45:00Z",
    "cancellationReason": "CancelledByExpert",
    "status": "Cancelled",
    "timeSlotId": "550e8400-e29b-41d4-a716-446655440000",
    "consultationId": "5f5f35ef-c5e5-4431-8ca0-060f8575461f"
  },
  "error": null
}
```

### 4.5 Planned Error Cases For Cancel

Expected failure conditions:

- booking not found
- caller is neither booking owner nor assigned expert
- booking already cancelled or completed
- slot has already started
- refund already exists for the same booking
- pending payment already has a confirmed external payment transaction

### 4.6 Current Verified Expert-Cancel Push Notification

Current delivery path in the codebase:

1. `BookingService` publishes through `INotificationQueueService`
2. `NotificationQueueService` persists `AppNotification`
3. `NotificationQueueService` publishes `NotificationMessage` through `MassTransit`
4. broker-delivered message is consumed by `NotificationConsumer`
5. `NotificationConsumer` calls `FirebaseNotificationService`
6. Firebase sends push to the member device using stored `FcmToken`

Current active language rule:

- notification title and body must be Vietnamese
- English push content must not be used for this feature

Current active Vietnamese copy:

- title:
  - `Lịch tư vấn đã bị chuyên gia hủy`
- body:
  - `Chuyên gia đã hủy lịch tư vấn của bạn. Vui lòng kiểm tra lại lịch hẹn trong ứng dụng.`

## 5. Admin Business + Admin APIs

There is no admin cancellation API in scope for this task.

## 6. Shared Data Models

### Current Verified `CreateConsultationBookingRequest`

| Field | Type | Description |
|------|------|-------------|
| timeSlotId | Guid | Required expert slot id |
| problemDescription | string? | Optional text, max length 2000 |

### Current Verified `ProcessConsultationPaymentRequest`

| Field | Type | Description |
|------|------|-------------|
| paymentMethod | enum | Required. Current active values include wallet and PayOS flows |

### Current Verified `ConsultationBookingResponse`

| Field | Type | Description |
|------|------|-------------|
| id | Guid | Booking id |
| userId | Guid | Member id |
| expertId | Guid | Expert id |
| price | decimal | Booking price |
| bookedAt | DateTime | Booking creation time |
| paymentDeadline | DateTime? | Payment deadline for pending booking |
| status | BookingStatus | Current booking state |
| cancelledAt | DateTime? | UTC cancel timestamp when cancelled |
| cancellationReason | string? | Actor-centric cancellation reason rendered as string |
| problemDescription | string? | Optional problem summary |
| timeSlotId | Guid | Slot id |
| slotStartTime | DateTime | Slot start time |
| slotEndTime | DateTime | Slot end time |
| consultationId | Guid? | Linked consultation id |
| roomId | string? | Consultation room id |

## 7. Verified Endpoint List

Current verified endpoints:

- `POST /api/consultations/scheduled`
- `GET /api/users/me/consultations/scheduled`
- `GET /api/experts/me/consultations/scheduled`
- `POST /api/consultations/scheduled/{bookingId}/cancel`
- `POST /api/consultations/scheduled/{bookingId}/payments`
- `POST /api/consultations/payments/confirm`

## 8. Changelog

### 2026-04-18

- Created a planning useguide for scheduled booking cancellation
- Documented current verified scheduled booking APIs
- Added the proposed cancel endpoint contract with explicit planned status

### 2026-04-20

- Locked the decision to reuse `ConsultationBooking.CancellationReason`
- Locked the decision to make `CancellationReason` enum-backed while keeping outward API rendering string-based

### 2026-04-20 Implementation Update

- Activated `POST /api/consultations/scheduled/{bookingId}/cancel`
- Verified expert-cancel refund and member-cancel no-refund behavior
- Documented `cancelledAt` and `cancellationReason` in the booking response
- Clarified that member-cancel of a confirmed booking settles escrow without refund
- Clarified that cancelling a pending payment now fails explicitly when the external payment was already confirmed

### 2026-04-21

- Activated member-facing push notification for expert-cancel
- Documented Vietnamese-only push copy and delivery path for the active flow
