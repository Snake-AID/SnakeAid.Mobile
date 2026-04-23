---
doc_role: integration
module: consultation-information-response
kind: flow
doc_type: useguide
status: active
last_updated: 2026-04-23
api_version: v1
owners: [backend-team]
verification_status: code-verified
---

# Consultation Information Response Useguide

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

This document reflects the current implemented consultation-history response behavior that is relevant to mobile integration.

Current verified backend behavior:

- expert consultation history is exposed by `GET /api/experts/me/consultations`
- the response now exposes `grossPrice` and `netPrice`
- legacy `price` has been removed from expert history

Important integration note:

- scheduled expert-history `grossPrice` means gross amount before platform fee
- scheduled expert-history `netPrice` means persisted payout truth when available, otherwise `null`
- emergency expert-history `grossPrice` means persisted consultation payment amount
- emergency expert-history `netPrice` means persisted expert payout amount
- client should render these values directly and must not re-calculate platform fee locally for this endpoint

## 3. Authentication & Authorization

### Expert Operations

- JWT Bearer token is required
- `Expert` role is required

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Current Verified Notes

Current code-verified facts:

- route is `GET /api/experts/me/consultations`
- response type is `PagingResponse<ExpertConsultationResponse>`
- scheduled and emergency items share one DTO
- this endpoint now uses explicit money fields instead of one ambiguous price field

### 4.2 `GET /api/experts/me/consultations`

Purpose:

- retrieve the current expert's consultation history

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `Expert` role is required

Query params:

| Field      | Type   | Required | Notes |
| ---------- | ------ | -------- | ----- |
| pageNumber | int    | No       | Default `1` |
| pageSize   | int    | No       | Default `10` |
| type       | string | No       | `Scheduled` or `Emergency` |
| status     | string | No       | Consultation status filter |

Example request:

```http
GET /api/experts/me/consultations?pageNumber=1&pageSize=10
Authorization: Bearer <expert-jwt>
```

Success response:

- `ApiResponse<PagingResponse<ExpertConsultationResponse>>`

Example response:

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "items": [
      {
        "consultationId": "1b1d73f4-a32d-4a3c-95f5-bb0c3b7d8c01",
        "type": "Scheduled",
        "status": "Completed",
        "userId": "bd4f9968-53f8-4757-a3a0-53f2049a8c2f",
        "userName": "Nguyen Van A",
        "roomId": "consultation-1b1d73f4-a32d-4a3c-95f5-bb0c3b7d8c01",
        "startTime": "2026-04-20T09:00:00Z",
        "endTime": "2026-04-20T09:25:00Z",
        "grossPrice": 5000000,
        "netPrice": null,
        "bookingId": "c3b5f18d-8871-4ea0-97d2-6ac4b5fd4f2f",
        "slotStartTime": "2026-04-20T09:00:00Z",
        "slotEndTime": "2026-04-20T09:30:00Z",
        "emergencyRequestId": null
      },
      {
        "consultationId": "51bc626d-5f03-43df-8549-22729b5b3cb4",
        "type": "Emergency",
        "status": "Completed",
        "userId": "ca124c14-32b2-4779-a84d-1833d3614ee3",
        "userName": "Tran Thi B",
        "roomId": "consultation-51bc626d-5f03-43df-8549-22729b5b3cb4",
        "startTime": "2026-04-20T11:00:00Z",
        "endTime": "2026-04-20T11:12:00Z",
        "grossPrice": 5000000,
        "netPrice": 4000000,
        "bookingId": null,
        "slotStartTime": null,
        "slotEndTime": null,
        "emergencyRequestId": "6d4e90bb-a798-49fe-9730-d9fd2ab9485d"
      }
    ],
    "meta": {
      "total_pages": 1,
      "total_items": 2,
      "current_page": 1,
      "page_size": 10
    }
  },
  "error": null
}
```

Field notes:

- scheduled `grossPrice` comes from `ConsultationBooking.Price`
- scheduled `netPrice` comes from persisted `ExpertPayout` for the consultation when available, otherwise `null`
- emergency `grossPrice` comes from `ConsultationPayment` using `ConsultationPingRequest.Id`
- emergency `netPrice` comes from `ExpertPayout` using `Consultation.Id`
- `bookingId`, `slotStartTime`, `slotEndTime` are scheduled-only fields
- `emergencyRequestId` is an emergency-only field

### 4.3 Current Client Risk Resolved

This endpoint no longer requires Flutter to subtract platform fee locally.

Remaining integration note:

- adjacent member/admin consultation-history endpoints have not been aligned in this release

### 4.4 Expected Failure Behavior

- missing token or invalid token -> `401`
- user without `Expert` role -> `403`
- invalid query validation -> validation error

## 5. Admin Business + Admin APIs

### 5.1 Current Scope

- this module does not change admin APIs yet
- admin consultation history is tracked in a separate doc module

## 6. Shared Data Models

### `ExpertConsultationResponse`

| Field              | Type      | Description |
| ------------------ | --------- | ----------- |
| consultationId     | Guid      | Consultation id |
| type               | string    | `Scheduled` or `Emergency` |
| status             | string    | Consultation status |
| userId             | Guid      | Caller / rescuer id |
| userName           | string?   | Caller / rescuer display name |
| roomId             | string?   | Consultation room id |
| startTime          | datetime? | Consultation start time |
| endTime            | datetime? | Consultation end time |
| grossPrice         | decimal?  | Gross consultation amount before platform fee |
| netPrice           | decimal?  | Persisted expert payout amount after platform fee; `null` if payout does not exist |
| bookingId          | Guid?     | Present for scheduled items |
| slotStartTime      | datetime? | Present for scheduled items |
| slotEndTime        | datetime? | Present for scheduled items |
| emergencyRequestId | Guid?     | Present for emergency items |

### `ApiResponse<T>`

| Field       | Type    | Description |
| ----------- | ------- | ----------- |
| status_code | int     | HTTP-like status code in body |
| message     | string  | Human-readable message |
| is_success  | bool    | Success flag |
| data        | T       | Payload |
| error       | object? | Error detail if request fails |

### `PagingResponse<T>`

| Field | Type   | Description |
| ----- | ------ | ----------- |
| items | array  | Current page items |
| meta  | object | Pagination metadata |

## 7. Verified Endpoint List

Code-verified related endpoints:

- `GET /api/experts/me/consultations`
- `GET /api/users/me/consultations`
- `GET /api/admin/consultations`
- `GET /api/admin/consultations/{consultationId}`

## 8. Changelog

### 2026-04-23

- initialized the baseline useguide for consultation information response
- documented the active expert-history endpoint
- documented the current mixed semantics of `price`
- captured the mobile double-deduction risk as an integration note

### 2026-04-23 Decision Update

- locked next contract field names as `grossPrice` and `netPrice`
- locked same-release removal of `price`
- locked `netPrice` as persisted payout truth only
- locked scheduled `netPrice = null` until actual payout exists

### 2026-04-23 Implementation Update

- implemented `grossPrice` and `netPrice` on `GET /api/experts/me/consultations`
- removed `price` from `ExpertConsultationResponse`
- documented that only expert history changed in this release
