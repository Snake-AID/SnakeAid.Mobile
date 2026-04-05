---
doc_role: baseline
module: topup
kind: flow
doc_type: usageguide
status: active
last_updated: 2026-04-05
api_version: v1
owners: [backend-team]
verification_status: code-verified
---

# Wallet Top-up API

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

Flow top-up hiện tại trong code hỗ trợ:
- User tạo PayOS payment link để nạp tiền vào ví
- User dùng `checkoutUrl` để mở trang thanh toán PayOS
- Backend tự xử lý PayOS `return` và PayOS `webhook`
- App có thể gọi manual confirm bằng `transactionId`
- App đọc lại ví hiện tại để kiểm tra số dư sau top-up

Client-visible behavior cần nắm ngay:
- `POST /api/wallet/topup` trả đủ `transactionId`, `checkoutUrl`, `orderCode`, `paymentLinkId` để app dùng cho các bước tiếp theo
- `transactionId` là giá trị app cần giữ lại để gọi `POST /api/v1/PayOs/confirm-payment`
- Top-up mới tạo có `status = Pending`; ví chưa được cộng tiền tại thời điểm create link
- `GET /api/v1/PayOs/return` là return URL do PayOS gọi về backend, không phải endpoint app mobile gọi trực tiếp
- App không nên coi việc user quay lại app là top-up thành công
- App chỉ nên coi top-up thành công sau khi refresh `GET /api/wallet/me` và thấy `balance` đã tăng
- `GET /api/transactions/{id}` có thể dùng để đọc lại transaction detail theo `transactionId` khi app cần màn hình trạng thái hoặc troubleshooting

## 3. Authentication & Authorization

### Expert/Member Operations
- JWT Bearer token bắt buộc
- `Expert` và `Member` dùng cùng user-facing APIs cho top-up flow

### Generic Payment Confirmation
- `POST /api/v1/PayOs/confirm-payment` yêu cầu JWT Bearer token hợp lệ
- `GET /api/v1/PayOs/return`
- `GET /api/v1/PayOs/cancel`
- `POST /api/v1/PayOs/webhook`
  là các endpoint backend-facing / provider-facing; mobile app không tự gọi 3 endpoint này trong flow bình thường

### Example Authorization Header

```http
Authorization: Bearer {{TOKEN}}
```

## 4. Expert/Member Business + Expert/Member APIs

### 4.1 Business Scope

- Xem số dư ví hiện tại
- Tạo top-up payment link
- Mở PayOS checkout
- Manual confirm giao dịch top-up bằng `transactionId`
- Đọc lại ví sau confirm / sau khi app resume
- Đọc transaction detail khi cần hiển thị trạng thái giao dịch

### 4.2 User Journey

#### Step 1. Read current wallet balance

App gọi:

```http
GET /api/wallet/me
Authorization: Bearer {{TOKEN}}
```

Mục đích:
- Hiển thị số dư hiện tại trước khi user nhập số tiền nạp
- Lưu `balanceBeforeTopup` nếu UI cần so sánh sau khi giao dịch hoàn tất

#### Step 2. Create top-up payment link

App gọi:

```http
POST /api/wallet/topup
Authorization: Bearer {{TOKEN}}
Content-Type: application/json
```

Body:

```json
{
  "amount": 50000,
  "description": "Top up via mobile app"
}
```

App phải lưu lại từ response:
- `transactionId`
- `checkoutUrl`
- `orderCode`
- `paymentLinkId`
- `amount`

#### Step 3. Open PayOS checkout

App dùng `checkoutUrl` để mở webview, in-app browser, hoặc external browser.

Trong lúc user đang thanh toán:
- backend chưa coi giao dịch là completed
- wallet balance chưa thay đổi

#### Step 4. User completes payment on PayOS

Sau khi thanh toán:
- PayOS có thể redirect về backend `GET /api/v1/PayOs/return`
- hoặc webhook PayOS có thể đến backend `POST /api/v1/PayOs/webhook`

App mobile không cần tự gọi 2 endpoint này.

#### Step 5. App resumes and requests manual confirmation

Khi app quay lại foreground sau PayOS checkout, app nên gọi:

```http
POST /api/v1/PayOs/confirm-payment
Authorization: Bearer {{TOKEN}}
Content-Type: application/json
```

Body:

```json
{
  "transactionId": "550e8400-e29b-41d4-a716-446655440000"
}
```

Input này lấy trực tiếp từ response của `POST /api/wallet/topup`.

#### Step 6. Re-fetch wallet and verify balance

Ngay sau bước confirm, app nên gọi lại:

```http
GET /api/wallet/me
Authorization: Bearer {{TOKEN}}
```

Rule hiển thị success:
- Chỉ hiển thị `Nạp tiền thành công` khi `balance` đã tăng đúng theo amount top-up

Recommended client behavior:
- Gọi `confirm-payment` một lần khi app resume
- Sau đó gọi `GET /api/wallet/me`
- Nếu số dư chưa tăng, hiển thị trạng thái `Đang xác nhận thanh toán` và retry wallet refresh thêm vài lần

### 4.3 Business Rules

#### Create Top-up
- `amount` bắt buộc, range `1000` đến `10000000`
- `description` optional, tối đa `200` ký tự
- User phải có wallet tồn tại
- Mỗi user chỉ được có một top-up pending tại một thời điểm
- Pending được xác định bởi:
  - `TransactionType = WalletTopup`
  - `ExternalTransactionId = null`

#### After Create Link
- Backend tạo transaction pending trước rồi mới tạo PayOS link
- Nếu PayOS link creation fail, backend xóa transaction vừa tạo

#### Confirmation
- App có thể dùng `transactionId` từ top-up response để gọi manual confirm
- Backend cũng có thể tự confirm qua return URL hoặc webhook
- App vẫn phải refresh wallet để kiểm tra kết quả cuối cùng

### 4.4 Wrapper Response Convention

Các endpoint kiểu wallet / transaction dùng `ApiResponse<T>`:

```json
{
  "status_code": 200,
  "message": "Operation successful",
  "is_success": true,
  "data": {},
  "error": null
}
```

Riêng `POST /api/v1/PayOs/confirm-payment` hiện trả object trực tiếp:

```json
{
  "success": true,
  "message": "Payment confirmed successfully",
  "data": {}
}
```

Client nên parse endpoint này theo shape riêng, không dùng chung parser `ApiResponse<T>`.

### 4.5 Expert/Member APIs

#### 4.5.1 `GET /api/wallet/me`

Mục đích:
- Lấy ví hiện tại của user
- Dùng trước khi create top-up và sau khi confirm top-up

Auth:
- JWT Bearer token bắt buộc

Success response:
- `ApiResponse<WalletResponse>`

Example response:

```json
{
  "status_code": 200,
  "message": "Wallet retrieved successfully",
  "is_success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440010",
    "userId": "550e8400-e29b-41d4-a716-446655440001",
    "balance": 350000,
    "createdAt": "2026-03-25T08:00:00Z",
    "updatedAt": "2026-04-05T11:25:00Z"
  },
  "error": null
}
```

Field notes:
- `balance` là số dư current wallet tại thời điểm gọi API
- App nên dùng endpoint này để verify top-up completion

#### 4.5.2 `POST /api/wallet/topup`

Mục đích:
- Tạo PayOS payment link cho top-up

Auth:
- JWT Bearer token bắt buộc

Request body:

```json
{
  "amount": 50000,
  "description": "Top up via mobile app"
}
```

Request body schema:

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| amount | decimal | Yes | `1000` đến `10000000` | Số tiền nạp vào ví |
| description | string | No | max `200` chars | Ghi chú app muốn gắn cho top-up |

Success response:

```json
{
  "status_code": 200,
  "message": "Wallet top-up payment link created successfully",
  "is_success": true,
  "data": {
    "transactionId": "550e8400-e29b-41d4-a716-446655440000",
    "userId": "550e8400-e29b-41d4-a716-446655440001",
    "amount": 50000,
    "status": "Pending",
    "checkoutUrl": "https://pay.payos.vn/web/3d3f8c1d2d8e4e5f8a11",
    "orderCode": 17123456781234,
    "paymentLinkId": "38f8470c-ef8f-4d5a-93a4-0fbe9d7c0a10",
    "expiresAt": null,
    "provider": "PayOS",
    "gatewayRawResponse": {
      "orderCode": 17123456781234,
      "paymentLinkId": "38f8470c-ef8f-4d5a-93a4-0fbe9d7c0a10",
      "checkoutUrl": "https://pay.payos.vn/web/3d3f8c1d2d8e4e5f8a11",
      "amount": 50000,
      "status": "PENDING",
      "currency": "VND"
    }
  },
  "error": null
}
```

Field notes:
- `transactionId` là field app phải lưu để gọi `POST /api/v1/PayOs/confirm-payment`
- `checkoutUrl` là link app phải mở cho user thanh toán
- `orderCode` hữu ích cho log, support, correlation
- `status` tại bước create luôn là `Pending`
- `expiresAt` hiện trả `null`

Possible business error cases:
- amount <= 0
- wallet không tồn tại
- user đang có top-up pending khác
- PayOS không tạo được payment link

#### 4.5.3 `POST /api/v1/PayOs/confirm-payment`

Mục đích:
- Manual confirm giao dịch PayOS bằng `transactionId`
- App nên gọi khi user quay lại app sau PayOS checkout

Auth:
- JWT Bearer token bắt buộc

Request body:

```json
{
  "transactionId": "550e8400-e29b-41d4-a716-446655440000"
}
```

Request body schema:

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| transactionId | guid | Yes | non-empty GUID | Transaction ID nhận từ response top-up create |

Success response shape:

```json
{
  "success": true,
  "message": "Payment confirmed successfully",
  "data": {
    "success": true,
    "message": "Snake catching payment confirmed successfully",
    "transactionId": "550e8400-e29b-41d4-a716-446655440000",
    "orderCode": 17123456781234,
    "amount": 50000,
    "transactionReference": "MANUAL-550e8400-e29b-41d4-a716-446655440000",
    "transactionDateTime": "2026-04-05T11:24:10Z"
  }
}
```

Field notes:
- Endpoint này hiện là generic confirm endpoint cho nhiều PayOS flow
- Với top-up wallet, app chỉ cần truyền `transactionId`
- Client không nên coi response này là nguồn xác nhận cuối cùng của balance
- Sau response success, app nên gọi lại `GET /api/wallet/me`

#### 4.5.4 `GET /api/transactions/{id}`

Mục đích:
- Lấy transaction detail theo `transactionId`
- Dùng khi app cần màn hình chi tiết giao dịch hoặc debug trạng thái

Auth:
- JWT Bearer token bắt buộc

Path parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | guid | Yes | Transaction ID |

Success response:

```json
{
  "status_code": 200,
  "message": "Transaction retrieved successfully.",
  "is_success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "userId": "550e8400-e29b-41d4-a716-446655440001",
    "referenceId": "550e8400-e29b-41d4-a716-446655440001",
    "amount": 50000,
    "currency": "VND",
    "transactionType": "WalletTopup",
    "description": "SNAKEAID-17123456781234",
    "paymentMethod": "PayOS",
    "externalTransactionId": "MANUAL-550e8400-e29b-41d4-a716-446655440000",
    "createdAt": "2026-04-05T11:24:10Z"
  },
  "error": null
}
```

Field notes:
- `externalTransactionId != null` cho biết transaction đã được backend đánh dấu là confirmed / processed theo payment gateway
- App có thể dùng endpoint này cho transaction history screen
- Với top-up flow, endpoint này là optional; `wallet/me` vẫn là endpoint verify completion quan trọng hơn

### 4.6 Error Catalog

| Status Code | Error Code | Message | Description | Resolution |
|-------------|------------|---------|-------------|------------|
| 400 | BAD_REQUEST | TransactionId is required | Confirm request thiếu `transactionId` | Gửi lại request với GUID hợp lệ |
| 400 | BAD_REQUEST | Transaction not found | `transactionId` không tồn tại | Dùng lại `transactionId` từ response top-up create |
| 400 | BAD_REQUEST | Unknown payment flow for the given transaction | Transaction description không map được vào PayOS flow đã support | Không sửa client-side; cần backend kiểm tra transaction |
| 400 | BAD_REQUEST | You have a pending wallet top-up transaction... | User đang có top-up pending khác | Tiếp tục giao dịch cũ hoặc chờ giao dịch cũ hoàn tất |
| 400 | BAD_REQUEST | Top-up amount must be greater than 0 | Amount không hợp lệ ở service layer | Gửi amount > 0 và trong range request model |
| 401 | UNAUTHORIZED | Unauthorized | Thiếu hoặc sai Bearer token | Refresh token / login lại |
| 404 | NOT_FOUND | Wallet not found for user | User chưa có wallet trong hệ thống | Không cho user vào top-up flow nếu wallet chưa được provision |
| 404 | NOT_FOUND | Transaction with ID ... was not found. | Transaction detail không tồn tại | Kiểm tra lại transactionId |
| 409 | CONFLICT | PayOS reports status '...' | Payment chưa ở trạng thái `PAID` khi confirm | Retry sau khi user hoàn tất thanh toán |
| 500 | INTERNAL_ERROR | An error occurred while confirming payment | Lỗi confirm backend | Retry an toàn hoặc hiển thị trạng thái chờ support |
| 500 | INTERNAL_ERROR | Failed to create PayOS payment link | PayOS link creation failed | Cho user tạo lại top-up |

### 4.7 Examples

#### Example: Create Top-up And Confirm On App Resume

**1. Create top-up**

```bash
curl -X POST https://api.example.com/api/wallet/topup \
  -H "Authorization: Bearer {{TOKEN}}" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50000,
    "description": "Top up via mobile app"
  }'
```

**2. Open `checkoutUrl` from response**

App stores:
- `transactionId`
- `checkoutUrl`
- `orderCode`

**3. After app resumes, confirm payment**

```bash
curl -X POST https://api.example.com/api/v1/PayOs/confirm-payment \
  -H "Authorization: Bearer {{TOKEN}}" \
  -H "Content-Type: application/json" \
  -d '{
    "transactionId": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**4. Re-fetch wallet**

```bash
curl -X GET https://api.example.com/api/wallet/me \
  -H "Authorization: Bearer {{TOKEN}}"
```

Mobile decision rule:
- Nếu `balanceAfter = balanceBefore + amountTopup` thì hiển thị thành công
- Nếu chưa tăng, tiếp tục hiển thị `Đang xác nhận thanh toán` và refresh lại

## 5. Admin Business + Admin APIs

Flow top-up hiện tại không có admin-facing API riêng trong module này.

Admin không có endpoint riêng để:
- tạo top-up thay user
- manual approve top-up
- query top-up status qua admin API

Nếu cần support/admin tooling, client hiện chỉ có thể dùng:
- `GET /api/transactions/{id}`
- hoặc các công cụ backend nội bộ ngoài usage guide này

## 6. Shared Data Models

### CreateWalletTopupRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| amount | decimal | Yes | Số tiền cần nạp |
| description | string | No | Ghi chú gửi kèm top-up |

### CreateWalletTopupResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| transactionId | guid | Yes | Transaction ID dùng cho confirm-payment |
| userId | guid | Yes | User tạo top-up |
| amount | decimal | Yes | Số tiền top-up |
| status | string | Yes | Trạng thái hiện tại, create step là `Pending` |
| checkoutUrl | string | No | URL PayOS để app mở checkout |
| orderCode | int64 | Yes | Mã đơn PayOS để correlation |
| paymentLinkId | string | No | ID payment link từ PayOS |
| expiresAt | datetime | No | Hiện tại trả `null` |
| provider | string | Yes | Provider hiện tại là `PayOS` |
| gatewayRawResponse | object | No | Dữ liệu gateway backend passthrough cho debug |

### ConfirmPaymentRequest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| transactionId | guid | Yes | Transaction ID cần confirm |

### WalletResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | guid | Yes | Wallet ID |
| userId | guid | Yes | Owner user ID |
| balance | decimal | Yes | Current wallet balance |
| createdAt | datetime | Yes | Thời điểm tạo ví, ISO 8601 |
| updatedAt | datetime | No | Thời điểm update gần nhất, ISO 8601 |

### TransactionResponse

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | guid | Yes | Transaction ID |
| userId | guid | Yes | Transaction owner |
| referenceId | guid | Yes | Với top-up, reference là chính user ID |
| amount | decimal | Yes | Transaction amount |
| currency | string | Yes | Currency code, hiện tại `VND` |
| transactionType | enum | Yes | Với top-up là `WalletTopup` |
| description | string | No | Mô tả transaction, gồm prefix order code |
| paymentMethod | string | No | Ví dụ `PayOS` |
| externalTransactionId | string | No | Payment gateway reference sau khi confirmed |
| createdAt | datetime | No | Timestamp giao dịch |

## 7. Verified Endpoint List

| Method | Endpoint | Auth | Purpose | Client Uses Directly |
|--------|----------|------|---------|----------------------|
| GET | `/api/wallet/me` | Bearer JWT | Read current wallet balance | Yes |
| POST | `/api/wallet/topup` | Bearer JWT | Create PayOS top-up link | Yes |
| POST | `/api/v1/PayOs/confirm-payment` | Bearer JWT | Manual confirm by transactionId | Yes |
| GET | `/api/transactions/{id}` | Bearer JWT | Read transaction detail | Optional |
| GET | `/api/v1/PayOs/return` | None | PayOS return URL handler | No |
| GET | `/api/v1/PayOs/cancel` | None | PayOS cancel URL handler | No |
| POST | `/api/v1/PayOs/webhook` | None | PayOS webhook receiver | No |

## 8. Changelog

- `2026-04-05`: Added initial code-verified top-up usage guide with create-link, confirm-payment, wallet refresh journey, and response fields required by mobile clients.
