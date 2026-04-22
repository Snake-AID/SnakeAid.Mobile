---
doc_role: integration
module: expert-availability
kind: flow
doc_type: useguide
status: active
last_updated: 2026-04-21
api_version: v1
owners: [backend-team]
verification_status: code-verified
---

# Expert Availability Useguide

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

This document records the current verified backend contract for expert availability.

Current code-verified state:

- expert online state is persisted in `ExpertProfile.IsOnline`
- expert online state is exposed by existing expert read APIs
- expert online state is set to `true` when the expert joins `/hubs/expert` through `JoinAsExpert()`
- expert online state is set to `false` when the expert SignalR connection disconnects

Current implemented state:

- `JoinAsExpert()` is the online trigger
- `LeaveAsExpert()` is the explicit offline trigger on the same hub
- `ExpertOnlineStatusService` owns persisted online-state writes

## 3. Authentication & Authorization

### Expert Operations

- JWT Bearer token is required
- `Expert` role is required for expert availability trigger methods

### Member Operations

- JWT Bearer token is required
- `User` role is required for member presence subscription in `JoinAsMember()`

### Admin Operations

- there is currently no dedicated admin API in this module

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Current Expert Business Flow

Current code-verified behavior:

- when the Expert App connects to `/hubs/expert` and calls `JoinAsExpert()`, backend marks the expert online
- when that connection disconnects, backend marks the expert offline
- members who joined the presence group can receive expert presence changes

### 4.2 Current SignalR Route

#### `GET /hubs/expert`

Purpose:

- establish realtime expert availability and emergency consultation presence connection

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required

Example handshake:

```http
GET /hubs/expert
Authorization: Bearer <jwt>
```

### 4.3 Current Client To Server Method: `JoinAsExpert()`

Purpose:

- mark the current expert online

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `Expert` role is required

Request:

```text
JoinAsExpert()
```

Current verified backend behavior:

- validate role `Expert`
- resolve `expertId` from JWT
- add current connection into in-memory connected expert tracking
- persist `ExpertProfile.IsOnline = true`
- broadcast `ExpertPresenceChanged` with `isOnline = true`

Current success event to caller:

```json
{
  "expertId": "9c992ece-5b3d-4a51-9459-db89ff0a6b43",
  "connectionId": "Lbx3d8mY5bP8mL6g5R0z4Q",
  "message": "Expert connected successfully."
}
```

### 4.4 Client To Server Method: `LeaveAsExpert()`

Purpose:

- allow the Expert App to intentionally switch expert availability to offline

Status:

- `Active`
- Code-verified

Request:

```text
LeaveAsExpert()
```

Current verified backend behavior:

- remove current expert connection from in-memory tracking
- persist `ExpertProfile.IsOnline = false`
- broadcast `ExpertPresenceChanged` with `isOnline = false`
- reply to caller with a confirmation event

Example caller response:

```json
{
  "expertId": "9c992ece-5b3d-4a51-9459-db89ff0a6b43",
  "message": "Expert switched to offline successfully."
}
```

### 4.5 Current Client To Server Method: `JoinAsMember()`

Purpose:

- allow a member app connection to subscribe to online expert presence changes

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- `User` role is required

Request:

```text
JoinAsMember()
```

Current verified caller response:

```json
{
  "onlineExpertIds": [
    "9c992ece-5b3d-4a51-9459-db89ff0a6b43",
    "28fbb65d-2b60-4b1f-9057-47718dbd88f8"
  ],
  "serverTimeUtc": "2026-04-21T09:30:00Z"
}
```

### 4.6 Current Server Event: `ExpertPresenceChanged`

Purpose:

- notify subscribed member clients that one expert changed presence state

Current verified payload shape:

```json
{
  "expertId": "9c992ece-5b3d-4a51-9459-db89ff0a6b43",
  "isOnline": true,
  "changedAtUtc": "2026-04-21T09:30:05Z"
}
```

Field notes:

- `expertId` is the `ExpertProfile.AccountId`
- `isOnline = true` means expert is currently available in the persisted expert profile
- mobile should treat this event as presence state change, not as consultation acceptance

### 4.7 Existing HTTP Reads That Expose Expert Online State

#### `GET /api/experts`

Purpose:

- list experts for member browsing

Current integration note:

- response items already contain `isOnline`
- request already supports filtering by `isOnline`

Example request:

```http
GET /api/experts?isOnline=true&pageNumber=1&pageSize=10
Authorization: Bearer <jwt-or-none-depending-client-surface>
```

#### `GET /api/experts/me/profile`

Purpose:

- get the current expert's own profile

Current integration note:

- response already contains `isOnline`
- app can use this endpoint to hydrate the current persisted availability state on screen load

Example response fragment:

```json
{
  "accountId": "9c992ece-5b3d-4a51-9459-db89ff0a6b43",
  "biography": "Emergency toxicology expert",
  "isOnline": false
}
```

## 5. Admin Business + Admin APIs

There is currently no dedicated admin endpoint in this module.

Admin can still inspect expert online state indirectly through existing admin or support surfaces outside this module, but that is not the primary contract here.

## 6. Shared Data Models

### `ExpertPresenceChanged`

| Field        | Type     | Description                      |
| ------------ | -------- | -------------------------------- |
| expertId     | Guid     | Expert account id                |
| isOnline     | bool     | Current persisted online state   |
| changedAtUtc | datetime | UTC timestamp of presence change |

### `JoinedAsExpert` response

| Field        | Type   | Description               |
| ------------ | ------ | ------------------------- |
| expertId     | Guid   | Current expert id         |
| connectionId | string | Current SignalR connection id |
| message      | string | Human-readable status     |

### Existing read DTO fields relevant to this module

`ExpertProfileResponse` includes:

- `accountId`
- `name`
- `isOnline`
- other profile fields

`ExpertMyProfileResponse` includes:

- `accountId`
- `biography`
- `isOnline`
- fee and rating fields

## 7. Verified Endpoint List

Current related verified surfaces:

- SignalR hub `/hubs/expert`
- SignalR method `JoinAsExpert()`
- SignalR method `JoinAsMember()`
- SignalR method `JoinEmergencyRequestRoom(Guid requestId)`
- `GET /api/experts`
- `GET /api/experts/{id}`
- `GET /api/experts/me/profile`

- SignalR method `LeaveAsExpert()`

## 8. Changelog

### 2026-04-21

- created the baseline useguide for expert availability
- documented the current connection-driven online or offline behavior
- documented the existing read APIs that already expose `isOnline`
- activated the explicit offline trigger `LeaveAsExpert()` on `ExpertHub`
