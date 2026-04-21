---
doc_role: integration
module: consultation-message-history
kind: flow
doc_type: useguide
status: active
last_updated: 2026-04-21
api_version: v1
owners: [backend-team]
verification_status: code-verified
---

# Consultation Message History Useguide

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

- consultation chat messages are sent through `ConsultationHub`
- each sent message is persisted into `ChatMessages`
- consultation participants can read terminal consultation message history through HTTP
- admin can also read the same history through the same endpoint
- the endpoint is read-only
- this work does not allow users to continue chatting after completion

Important integration note:

- this endpoint is now active
- mobile/frontend should treat admin access as an explicit allowed path for back-office or moderator-style tooling
- end-user mobile chat history screens should assume participant access, not admin access

## 3. Authentication & Authorization

### Expert/Member Operations

- JWT Bearer token is required
- caller must be a participant of the consultation
- participant means:
  - `Consultation.CallerId == current user id`
  - or `Consultation.CalleeId == current user id`

### Admin Operations

- JWT Bearer token is required
- `Admin` can access the same message-history endpoint even when not a consultation participant

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Current Verified Notes

Current code-verified facts relevant to mobile integration:

- hub route is `/hubs/consultation`
- current mobile send path should still use SignalR
- `ReceiveMessage` currently stores message data in the backend
- message history HTTP read endpoint now exists and is active

### 4.2 Current Verified SignalR Messaging Surface

#### Hub Connection

Purpose:

- connect a participant to consultation realtime messaging

Request shape:

```http
GET /hubs/consultation?consultationId={consultationId}
Authorization: Bearer <jwt>
```

Current verified backend behavior:

- hub rejects missing or invalid `consultationId`
- hub rejects users who are not the consultation caller or callee
- valid participants are joined into group `consultation:{consultationId}`

#### Client To Server Method: `ReceiveMessage`

Purpose:

- send one consultation message during the active realtime session

Current verified method shape:

```text
ReceiveMessage(string content, string? attachmentUrl = null)
```

Current verified backend behavior:

- message must contain `content` or `attachmentUrl`
- message is persisted before group broadcast
- rate limit is currently `10 messages per minute` per user

Current verified broadcast payload:

```json
{
  "id": "4e8708e6-17e3-4c7b-b76c-cd2dcb48a5f4",
  "content": "Please send me the wound photo again.",
  "attachmentUrl": null,
  "senderId": "f5c3290c-98d5-4760-bc43-f652f0c1d65b",
  "sentAt": "2026-04-21T09:15:00Z"
}
```

Important note:

- this realtime method is `implemented now`
- it is not the same as the active post-completion history endpoint

### 4.3 `GET /api/consultations/{consultationId}/messages-history`

Purpose:

- retrieve persisted chat history for one terminal consultation

Status:

- `Active`
- Code-verified

Auth:

- JWT Bearer token is required
- allowed callers:
  - consultation participant
  - admin

Route params:

| Field          | Type | Required | Notes                        |
| -------------- | ---- | -------- | ---------------------------- |
| consultationId | guid | Yes      | Existing `Consultation.Id` |

Query params:

| Field      | Type | Required | Notes                              |
| ---------- | ---- | -------- | ---------------------------------- |
| pageNumber | int  | No       | Default `1`, recommended `>= 1`; `1` means newest history batch and each next page moves to older history |
| pageSize   | int  | No       | Default `10`, allowed `1..100` |

Example request:

```http
GET /api/consultations/9fbba6ab-71ee-4a0d-b0b9-9a98d9835d12/messages-history?pageNumber=1&pageSize=10
Authorization: Bearer <jwt>
```

Current verified backend behavior:

- validate consultation exists
- validate caller is consultation participant or admin
- validate consultation is one of:
  - `Completed`
  - `UserAbsent`
  - `ExpertAbsent`
  - `AllAbsent`
- return persisted messages from `ChatMessages`
- keep the endpoint read-only
- select pages from newest batch backward
- keep items inside each page sorted ascending by `SentAt`, then `Id`

Success response:

- `ApiResponse<PagingResponse<ConsultationMessageHistoryItemResponse>>`

Example response:

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {
    "items": [
      {
        "id": "4e8708e6-17e3-4c7b-b76c-cd2dcb48a5f4",
        "consultationId": "9fbba6ab-71ee-4a0d-b0b9-9a98d9835d12",
        "senderId": "f5c3290c-98d5-4760-bc43-f652f0c1d65b",
        "content": "Please send me the wound photo again.",
        "attachmentUrl": null,
        "sentAt": "2026-04-21T09:15:00Z"
      },
      {
        "id": "7c5c8984-75df-49c1-8b11-df8d7e6e80ea",
        "consultationId": "9fbba6ab-71ee-4a0d-b0b9-9a98d9835d12",
        "senderId": "67b6dbd9-5e6e-48f3-a270-0a0f12ea9d36",
        "content": "",
        "attachmentUrl": "https://res.cloudinary.com/demo/image/upload/v1/consultations/messages/wound-01.jpg",
        "sentAt": "2026-04-21T09:16:10Z"
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

- `content` may be empty when the message is attachment-only
- `attachmentUrl` may be `null`
- `senderId` should be treated as the source of truth for message ownership
- v1 intentionally does not add sender display name, sender role, or avatar fields
- `pageNumber = 1` is the newest history window, not the oldest one
- each next page returns the next older history window
- each returned page is still ordered old-to-new inside that page
- the response example above reflects the active contract shape
- frontend should not assume `content` is always non-empty
- frontend should not assume every caller is a participant, because admin tooling can also consume the same endpoint

### 4.4 Expected Failure Behavior

Current failure behavior:

- missing token or invalid token -> `401`
- non-admin caller who is not a consultation participant -> `403`
- consultation does not exist -> `404`
- consultation is not in an allowed terminal state -> business validation failure mapped to `400`

## 5. Admin Business + Admin APIs

### 5.1 Current Scope

- admin uses the same endpoint:
  - `GET /api/consultations/{consultationId}/messages-history`

### 5.2 Future Extension Note

- current admin read access is already part of this module
- if admin later needs extra audit filters or bulk history access, document that in a separate module instead of silently extending this contract

## 6. Shared Data Models

### `ConsultationMessageHistoryQueryRequest`

| Field      | Type | Required | Constraints                   |
| ---------- | ---- | -------- | ----------------------------- |
| pageNumber | int  | No       | newest-window-first, recommended `>= 1` |
| pageSize   | int  | No       | default `10`, allowed `1..100`|

### `ConsultationMessageHistoryItemResponse`

| Field          | Type      | Description                                    |
| -------------- | --------- | ---------------------------------------------- |
| id             | Guid      | Message id                                     |
| consultationId | Guid      | Consultation id                                |
| senderId       | Guid      | Sender account id                              |
| content        | string    | Message text, may be empty for attachment-only |
| attachmentUrl  | string?   | Optional attachment URL                        |
| sentAt         | datetime  | UTC send time                                  |

### `ApiResponse<T>`

| Field       | Type    | Description                   |
| ----------- | ------- | ----------------------------- |
| status_code | int     | HTTP-like status code in body |
| message     | string  | Human-readable message        |
| is_success  | bool    | Success flag                  |
| data        | T       | Payload                       |
| error       | object? | Error detail if request fails |

### `PagingResponse<T>`

| Field | Type   | Description         |
| ----- | ------ | ------------------- |
| items | array  | Current page items  |
| meta  | object | Pagination metadata |

### `PaginationMeta`

| Field        | Type | Description         |
| ------------ | ---- | ------------------- |
| total_pages  | int  | Total pages         |
| total_items  | long | Total items         |
| current_page | int  | Current page        |
| page_size    | int  | Requested page size |

## 7. Verified Endpoint List

Code-verified related surfaces that already exist today:

- `POST /api/consultations/{consultationId}/end`
- `GET /api/consultations/{consultationId}/messages-history`
- `GET /api/users/me/consultations`
- `GET /api/experts/me/consultations`
- `POST /api/consultations/{consultationId}/expert-absent-report`
- `POST /api/consultations/{consultationId}/reviews`
- `GET /api/consultations/{consultationId}/reviews`
- SignalR hub `/hubs/consultation`

Frontend/mobile relevance:

- end-user apps mainly use:
  - `GET /api/consultations/{consultationId}/messages-history`
  - SignalR hub `/hubs/consultation`
- admin tooling may also use:
  - `GET /api/consultations/{consultationId}/messages-history`

## 8. Changelog

### 2026-04-21

- created the planning useguide for consultation message history
- documented that message persistence already exists in `ChatMessages`
- documented the current realtime send surface in `ConsultationHub`
- proposed a participant-facing read-only endpoint for terminal consultation history
- locked v1 payload to stored-truth message fields without sender enrichment
- clarified newest-window-first paging with ascending ordering inside each page
- accepted newest-window-first paging as the baseline contract for mobile UX

### 2026-04-21 Implementation Update

- activated `GET /api/consultations/{consultationId}/messages-history`
- updated the contract from participant-only to participant-or-admin access
- confirmed terminal-state validation and `400` failure for non-terminal consultations
