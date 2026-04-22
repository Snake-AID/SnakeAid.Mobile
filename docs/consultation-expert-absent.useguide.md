---
doc_role: planning
module: consultation-expert-absent
kind: flow
doc_type: usageguide
status: active
last_updated: 2026-04-21
api_version: v1
owners: [backend-team]
verification_status: code-verified
---

# Consultation Expert Absent API

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

This document records the `current verified backend contract` relevant to the expert-absent reporting use case.

Current status:

- the absent-report feature is `implemented`
- there is an active member API to report absent expert for scheduled consultation
- `Customer Report` is present in member and admin consultation DTOs
- `CustomerReportSubmittedAt` is present in member and admin consultation DTOs

## 3. Authentication & Authorization

### Expert/Member Operations

- JWT Bearer token is required
- `User` role is required for member consultation history
- `Expert` role is required for expert consultation history

### Admin Operations

- JWT Bearer token is required
- `Admin` role is required

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Business Scope

Current member consultation behavior:

- member can list their consultations
- member can see consultation status and room information
- member can submit an expert-absent report through a consultation API after `StartTime`

### 4.2 Member Endpoint

#### 4.2.1 `GET /api/users/me/consultations`

Purpose:

- member retrieves their own consultation history

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `User` role is required

Query params:

| Field      | Type   | Required | Notes                                                                 |
| ---------- | ------ | -------- | --------------------------------------------------------------------- |
| pageNumber | int    | No       | Default `1`, range `>= 1`                                             |
| pageSize   | int    | No       | Default `10`, range `1..100`                                          |
| status     | string | No       | `Scheduled`, `Ongoing`, `Completed`, `Cancelled`, `UserAbsent`, `ExpertAbsent`, `AllAbsent` |
| type       | string | No       | `Scheduled` or `Emergency`                                            |

Example request:

```http
GET /api/users/me/consultations?pageNumber=1&pageSize=10&type=Scheduled
Authorization: Bearer <member-jwt>
```

Success response:

- `ApiResponse<PagingResponse<MyConsultationResponse>>`

Verified example response shape:

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "items": [
      {
        "consultationId": "8ce96758-71b5-4310-bc35-d83525b2c54f",
        "type": "Scheduled",
        "status": "Completed",
        "expertId": "ba833fc7-6856-48b2-b032-9c5d985729d1",
        "expertName": "Pham Thi D",
        "roomId": "consultation-8ce96758-71b5-4310-bc35-d83525b2c54f",
        "startTime": "2026-04-09T14:00:00Z",
        "endTime": "2026-04-09T14:30:00Z",
        "price": 150000,
        "problemDescription": "Snakebite on finger",
        "bookingId": "ef54ec06-bb65-47d1-a7c5-db86aad6a49b",
        "slotStartTime": "2026-04-09T14:00:00Z",
        "slotEndTime": "2026-04-09T14:30:00Z",
        "emergencyRequestId": null
      }
    ],
    "meta": {
      "total_pages": 1,
      "total_items": 1,
      "current_page": 1,
      "page_size": 10
    }
  },
  "error": null
}
```

Field notes:

- `customerReport` is present when expert absence has been reported for that consultation
- `problemDescription` is booking problem content, not an expert-absent report
- successful absent-report submission sets consultation `status` to `ExpertAbsent`

#### 4.2.2 `POST /api/consultations/{consultationId}/expert-absent-report`

Purpose:

- member reports that the expert did not join the scheduled consultation

## 5. Admin Business + Admin APIs

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `User` role is required

Route params:

| Field          | Type | Required | Notes                    |
| -------------- | ---- | -------- | ------------------------ |
| consultationId | guid | Yes      | Existing `Consultation.Id` |

Request body:

| Field          | Type   | Required | Notes                    |
| -------------- | ------ | -------- | ------------------------ |
| customerReport | string | Yes      | `1..2000` chars after trim |

Business rules:

- only the member/caller of the consultation can report
- only `Scheduled` consultations are supported
- current time must be after `StartTime`
- duplicate report is rejected
- successful report sets `Consultation.Status = ExpertAbsent`

Example request:

```http
POST /api/consultations/8ce96758-71b5-4310-bc35-d83525b2c54f/expert-absent-report
Authorization: Bearer <member-jwt>
Content-Type: application/json

{
  "customerReport": "Expert did not join the room."
}
```

Success response:

- `ApiResponse<MyConsultationResponse>`

Example response:

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "consultationId": "8ce96758-71b5-4310-bc35-d83525b2c54f",
    "type": "Scheduled",
    "status": "ExpertAbsent",
    "expertId": "ba833fc7-6856-48b2-b032-9c5d985729d1",
    "expertName": "Pham Thi D",
    "roomId": "consultation-8ce96758-71b5-4310-bc35-d83525b2c54f",
    "startTime": "2026-04-09T14:00:00Z",
    "endTime": null,
        "price": 150000,
        "problemDescription": "Snakebite on finger",
        "customerReport": "Expert did not join the room.",
        "customerReportSubmittedAt": "2026-04-09T14:05:00Z",
        "bookingId": "ef54ec06-bb65-47d1-a7c5-db86aad6a49b",
        "slotStartTime": "2026-04-09T14:00:00Z",
        "slotEndTime": "2026-04-09T14:30:00Z",
        "emergencyRequestId": null
  },
  "error": null
}
```

### 5.1 Business Scope

Current admin consultation behavior:

- admin can list consultations across the system
- admin can open one consultation detail
- admin can see `Customer Report` in consultation responses when it exists

### 5.2 Admin Endpoint

#### 5.2.1 `GET /api/admin/consultations`

Purpose:

- admin retrieves a paged list of consultations across the system

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `Admin` role is required

Query params:

| Field      | Type   | Required | Notes                                                                 |
| ---------- | ------ | -------- | --------------------------------------------------------------------- |
| pageNumber | int    | No       | Default `1`, range `>= 1`                                             |
| pageSize   | int    | No       | Default `10`, range `1..100`                                          |
| status     | string | No       | `Scheduled`, `Ongoing`, `Completed`, `Cancelled`, `UserAbsent`, `ExpertAbsent`, `AllAbsent` |
| type       | string | No       | `Scheduled` or `Emergency`                                            |

Example request:

```http
GET /api/admin/consultations?pageNumber=1&pageSize=10&type=Scheduled
Authorization: Bearer <admin-jwt>
```

Success response:

- `ApiResponse<PagingResponse<AdminConsultationResponse>>`

Verified field notes:

- `customerReport` is included when expert absence has been reported
- `problemDescription` is the scheduled-booking problem description
- scheduled and emergency consultations share one admin response DTO

#### 5.2.2 `GET /api/admin/consultations/{consultationId}`

Purpose:

- admin retrieves one consultation detail by `consultationId`

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `Admin` role is required

Route params:

| Field          | Type | Required | Notes                    |
| -------------- | ---- | -------- | ------------------------ |
| consultationId | guid | Yes      | Existing `Consultation.Id` |

Example request:

```http
GET /api/admin/consultations/8ce96758-71b5-4310-bc35-d83525b2c54f
Authorization: Bearer <admin-jwt>
```

Success response:

- `ApiResponse<AdminConsultationResponse>`

Verified field notes:

- `customerReport` is included when expert absence has been reported
- admin can see status, room, booking data, and emergency-request data
- admin can inspect absent-report text from current code

## 6. Shared Data Models

### 6.1 Current `MyConsultationResponse`

Current verified shape includes:

- `consultationId`
- `type`
- `status`
- `expertId`
- `expertName`
- `roomId`
- `startTime`
- `endTime`
- `price`
- `problemDescription`
- `customerReport`
- `customerReportSubmittedAt`
- `bookingId`
- `slotStartTime`
- `slotEndTime`
- `emergencyRequestId`

### 6.2 Current `AdminConsultationResponse`

Current verified shape includes:

- consultation identity
- type and status
- user and expert identifiers/names
- room and timing data
- price
- `problemDescription`
- `customerReport`
- `customerReportSubmittedAt`
- booking metadata
- emergency-request metadata
- slot timing

## 7. Verified Endpoint List

Active endpoints relevant to this module:

- `GET /api/users/me/consultations`
- `POST /api/consultations/{consultationId}/expert-absent-report`
- `GET /api/experts/me/consultations`
- `GET /api/admin/consultations`
- `GET /api/admin/consultations/{consultationId}`

## 8. Changelog

### 2026-04-21

- Initialized use guide for the consultation expert-absent module
- Updated the guide to the implemented absent-report contract
