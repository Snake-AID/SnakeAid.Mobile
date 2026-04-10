---
doc_role: baseline
module: myprofile
kind: layer
doc_type: usageguide
status: active
last_updated: 2026-04-07
api_version: v1
owners: [backend-team]
---

# MyProfile Usage Guide

## Overview

MyProfile endpoints let authenticated mobile/frontend users view and edit their own profile by role:

- Member: personal identity, emergency contacts, underlying disease flag.
- Expert: personal identity, biography, scheduled consultation fee, emergency consultation fee.
- Rescuer: personal identity only; operational fields are returned as read-only.

Base paths:

- `/api/members/me/profile`
- `/api/experts/me/profile`
- `/api/rescuers/me/profile`

All endpoints return the standard `ApiResponse<T>` envelope.

## Authentication & Authorization

Send JWT bearer token in the `Authorization` header:

```http
Authorization: Bearer {{TOKEN}}
Content-Type: application/json
```

Role requirements:

| Endpoint group | Required role in token | Notes |
|---|---|---|
| `/api/members/me/profile` | `User` | `User` is the current backend role used for member accounts. |
| `/api/experts/me/profile` | `Expert` | Expert account must have an `ExpertProfile`. |
| `/api/rescuers/me/profile` | `Rescuer` | Rescuer account must have a `RescuerProfile`. |

## Member APIs

### `GET /api/members/me/profile`

**Description**: Get the authenticated member's current profile.

**Authentication**: Required.

**Required role**: `User`.

**Success Response** (`200 OK`):

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "accountId": "8c7ad8f7-65e7-44d4-bf63-bb882e7a8d22",
    "userName": "member.8c7ad8f765e744d4bf63bb882e7a8d22",
    "fullName": "Nguyen Van An",
    "email": "member@example.com",
    "phoneNumber": "0912345678",
    "avatarUrl": "https://cdn.example.com/avatars/member.png",
    "role": "User",
    "isActive": true,
    "reputationPoints": 100,
    "reputationStatus": "Good",
    "rating": 4.2,
    "ratingCount": 8,
    "emergencyContacts": ["0987654321", "0900111222"],
    "hasUnderlyingDisease": true,
    "createdAt": "2026-04-01T03:10:00Z",
    "updatedAt": "2026-04-07T08:30:00Z"
  },
  "error": null
}
```

### `PUT /api/members/me/profile`

**Description**: Update the authenticated member's editable profile fields.

**Authentication**: Required.

**Required role**: `User`.

**Request Body**:

```json
{
  "fullName": "Nguyen Van An",
  "phoneNumber": "0912345678",
  "avatarUrl": "https://cdn.example.com/avatars/member.png",
  "emergencyContacts": ["0987654321", "0900111222"],
  "hasUnderlyingDisease": true
}
```

**Request Body Schema**:

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `fullName` | string | Yes | max 200 chars | Display name stored on the account. |
| `phoneNumber` | string or null | No | phone format, max 50 chars | Contact phone number. |
| `avatarUrl` | string or null | No | max 1000 chars | Public avatar URL. |
| `emergencyContacts` | string[] | Yes | no per-item validation in this endpoint | Member emergency contact list. Send `[]` to clear. |
| `hasUnderlyingDisease` | boolean | Yes | `true` or `false` | Member medical flag used by client profile display. |

**Success Response** (`200 OK`): returns `MemberMyProfileResponse`, same shape as `GET`.

## Expert APIs

### `GET /api/experts/me/profile`

**Description**: Get the authenticated expert's current profile.

**Authentication**: Required.

**Required role**: `Expert`.

**Success Response** (`200 OK`):

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "accountId": "cd47f31d-19fa-4f17-a897-b4da6a5bead8",
    "userName": "expert.cd47f31d19fa4f17a897b4da6a5bead8",
    "fullName": "Dr. Tran Minh",
    "email": "expert@example.com",
    "phoneNumber": "0922222222",
    "avatarUrl": "https://cdn.example.com/avatars/expert.png",
    "role": "Expert",
    "isActive": true,
    "reputationPoints": 100,
    "reputationStatus": "Good",
    "biography": "Chuyen gia tu van ran doc Viet Nam.",
    "isOnline": true,
    "scheduledConsultationFee": 250000,
    "emergencyConsultationFee": 300000,
    "rating": 4.8,
    "ratingCount": 22,
    "createdAt": "2026-04-01T03:10:00Z",
    "updatedAt": "2026-04-07T08:30:00Z"
  },
  "error": null
}
```

### `PUT /api/experts/me/profile`

**Description**: Update the authenticated expert's editable profile fields.

**Authentication**: Required.

**Required role**: `Expert`.

**Request Body**:

```json
{
  "fullName": "Dr. Tran Minh",
  "phoneNumber": "0922222222",
  "avatarUrl": "https://cdn.example.com/avatars/expert.png",
  "biography": "Chuyen gia tu van ran doc Viet Nam.",
  "scheduledConsultationFee": 250000,
  "emergencyConsultationFee": 300000
}
```

**Request Body Schema**:

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `fullName` | string | Yes | max 200 chars | Display name stored on the account. |
| `phoneNumber` | string or null | No | phone format, max 50 chars | Contact phone number. |
| `avatarUrl` | string or null | No | max 1000 chars | Public avatar URL. |
| `biography` | string | Yes | max 2000 chars | Expert bio shown to clients. |
| `scheduledConsultationFee` | decimal | Yes | `0` to `999999.99` | Fee for scheduled consultation. |
| `emergencyConsultationFee` | decimal or null | No | `0` to `999999.99` | Fee for emergency consultation. If omitted or `null`, backend stores the scheduled fee as fallback. |

**Success Response** (`200 OK`): returns `ExpertMyProfileResponse`, same shape as `GET`.

## Rescuer APIs

### `GET /api/rescuers/me/profile`

**Description**: Get the authenticated rescuer's current profile.

**Authentication**: Required.

**Required role**: `Rescuer`.

**Success Response** (`200 OK`):

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "accountId": "d28d18c9-2258-420b-a4aa-6e3ff6dffb97",
    "userName": "rescuer.d28d18c92258420ba4aa6e3ff6dffb97",
    "fullName": "Le Quoc Bao",
    "email": "rescuer@example.com",
    "phoneNumber": "0933333333",
    "avatarUrl": "https://cdn.example.com/avatars/rescuer.png",
    "role": "Rescuer",
    "isActive": true,
    "reputationPoints": 100,
    "reputationStatus": "Good",
    "isOnline": true,
    "isAvailable": true,
    "type": "Both",
    "rating": 4.7,
    "ratingCount": 15,
    "totalMissions": 20,
    "completedMissions": 18,
    "lastLocationUpdate": "2026-04-07T08:20:00Z",
    "latitude": 10.7769,
    "longitude": 106.7009,
    "createdAt": "2026-04-01T03:10:00Z",
    "updatedAt": "2026-04-07T08:30:00Z"
  },
  "error": null
}
```

**Field notes**:

- `type`, `isOnline`, `isAvailable`, `rating`, `ratingCount`, `totalMissions`, `completedMissions`, `lastLocationUpdate`, `latitude`, and `longitude` are read-only in this profile endpoint.
- `latitude` and `longitude` can be `null` if the rescuer has no last known location.

### `PUT /api/rescuers/me/profile`

**Description**: Update the authenticated rescuer's editable personal identity fields.

**Authentication**: Required.

**Required role**: `Rescuer`.

**Request Body**:

```json
{
  "fullName": "Le Quoc Bao",
  "phoneNumber": "0933333333",
  "avatarUrl": "https://cdn.example.com/avatars/rescuer.png"
}
```

**Request Body Schema**:

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `fullName` | string | Yes | max 200 chars | Display name stored on the account. |
| `phoneNumber` | string or null | No | phone format, max 50 chars | Contact phone number. |
| `avatarUrl` | string or null | No | max 1000 chars | Public avatar URL. |

**Success Response** (`200 OK`): returns `RescuerMyProfileResponse`, same shape as `GET`.

## Shared Data Models

### `ApiResponse<T>`

| Field | Type | Required | Description |
|---|---|---|---|
| `status_code` | int | Yes | HTTP-like status code in response body. |
| `message` | string | Yes | Human-readable result message. |
| `is_success` | boolean | Yes | `true` for success. |
| `data` | object or null | Yes | Role-specific profile response for success. |
| `error` | object or null | Yes | Error details for failed requests. |

### Shared Account Fields

| Field | Type | Editable | Description |
|---|---|---|---|
| `accountId` | UUID | No | Current account id from JWT identity. |
| `userName` | string | No | Account username. |
| `fullName` | string | Yes | Display name. |
| `email` | string or null | No | Account email. |
| `phoneNumber` | string or null | Yes | Contact phone number. |
| `avatarUrl` | string or null | Yes | Public avatar URL. |
| `role` | string enum | No | `User`, `Expert`, or `Rescuer`. |
| `isActive` | boolean | No | Account active flag. |
| `reputationPoints` | int | No | Current reputation points. |
| `reputationStatus` | string enum | No | `Excellent`, `Good`, `Average`, `Poor`, or `Suspended`. |
| `createdAt` | datetime | No | ISO 8601 timestamp. |
| `updatedAt` | datetime | No | ISO 8601 timestamp, updated on successful `PUT`. |

### Role-Specific Enums

| Enum | Values |
|---|---|
| `role` | `User`, `Admin`, `Expert`, `Rescuer`, `Operator` |
| `reputationStatus` | `Excellent`, `Good`, `Average`, `Poor`, `Suspended` |
| `type` | `Emergency`, `Catching`, `Both` |

## Error Catalog

| HTTP Status | Error Code | When it happens | Client action |
|---|---|---|---|
| `400` | `VALIDATION_ERROR` or `BAD_REQUEST` | Request body fails validation or cannot be processed. | Check required fields, max lengths, phone format, and fee range. |
| `401` | `UNAUTHORIZED` | Missing/invalid token or token does not contain valid user id. | Re-authenticate and send `Authorization: Bearer {{TOKEN}}`. |
| `403` | `FORBIDDEN` | Token role does not match endpoint role requirement, or service detects role mismatch. | Use the role-specific endpoint for the signed-in account. |
| `404` | `NOT_FOUND` | Account exists but the required role profile row is missing, or account is not found. | Refresh session/account state or contact support. |
| `500` | `INTERNAL_SERVER_ERROR` | Unexpected server failure. | Retry later or report the issue. |

## Verified Endpoint List

| Method | Path | Required role | Implemented behavior |
|---|---|---|---|
| `GET` | `/api/members/me/profile` | `User` | Returns current member profile. |
| `PUT` | `/api/members/me/profile` | `User` | Updates member editable profile fields. |
| `GET` | `/api/experts/me/profile` | `Expert` | Returns current expert profile. |
| `PUT` | `/api/experts/me/profile` | `Expert` | Updates expert editable profile fields. |
| `GET` | `/api/rescuers/me/profile` | `Rescuer` | Returns current rescuer profile. |
| `PUT` | `/api/rescuers/me/profile` | `Rescuer` | Updates rescuer editable identity fields. |

## Changelog

| Date | Change |
|---|---|
| 2026-04-07 | Consolidated backend implementation into one `MyProfileController`; public endpoint contract unchanged. |
| 2026-04-07 | Added self-profile GET/PUT endpoints for member, expert, and rescuer roles. |
