# Hướng dẫn tích hợp chức năng tìm rắn theo vị trí

Phiên bản: `refactor/RF001-SOSFlow`

## Mục đích

Xây dựng luồng tìm nhanh các loài rắn phổ biến theo vị trí GPS (lat, lng) và hiển thị cho người dùng để xác nhận cho quy trình SOS.

## File liên quan

- `lib/features/snake_catching/models/snakes_by_location_response.dart`
- `lib/features/snake_catching/repository/snake_species_repository.dart`
- `lib/features/snake_catching/providers/snake_location_provider.dart`
- Tham khảo UI: `lib/features/emergency/screens/members/snake_selection_by_location_screen.dart`

---

## 1. Data model (DTO)

`SnakesByLocationResponse` chứa:

- `region` (`GeographicRegionDto`): id, code, name, description
- `snakes` (`List<SnakeInRegionDto>`): loài rắn với các trường: `id`, `scientificName`, `commonName`, `imageUrl`, `description?`, `identificationSummary`, `primaryVenomType?`, `riskLevel`, `isVenomous`, `commonLevel`, `priority`, `distributionNotes?`

Các lớp đã có `@JsonSerializable` và `fromJson(toJson)` generated.

---

## 2. Repository API

File: `lib/features/snake_catching/repository/snake_species_repository.dart`

Hàm cần dùng:

- `getSnakesByLocation({required double latitude, required double longitude})`

Nội dung:

- Gọi `GET /api/snake-species/by-location` với query params `lat`, `lng`
- Kiểm `response.data['is_success'] == true` và `response.data['data'] != null`
- Trả về `SnakesByLocationResponse.fromJson(response.data['data'])`
- Nếu lỗi throw `Exception(message)`

Gợi ý xử lý thêm (không bắt buộc nhưng tốt):

- bắt `DioException` cho 401/403/404 và map sang thông báo Việt hoá.

---

## 3. Provider + state management

File: `lib/features/snake_catching/providers/snake_location_provider.dart`

Đã có:

- `SnakeLocationState` (data, isLoading, error)
- `SnakeLocationNotifier` với `fetchSnakesByLocation(...)` và `clear()`
- `snakeLocationProvider` là `StateNotifierProvider<SnakeLocationNotifier, SnakeLocationState>`

Luồng:

1. `state = state.copyWith(isLoading: true, error: null)`
2. call repository
3. nếu thành công: `data: result`, `isLoading:false`
4. nếu lỗi: `error` và `isLoading:false`

---

## 4. UI sử dụng (tham khảo `snake_selection_by_location_screen.dart`)

1. `initState()` gọi `_fetchLocationAndSnakes()`
2. `Geolocator.getCurrentPosition(LocationAccuracy.high)`
3. `ref.read(snakeLocationProvider.notifier).fetchSnakesByLocation(...)`
4. Watch state:
   - `isLoading` -> spinner
   - `error` -> thông báo lỗi + nút thử lại
   - `data` -> hiển thị `region.name`, `snakes` list/grid

### Phần quan trọng trong build

- `_buildAppBar(locationState)` hiển thị khu vực
- `_buildBody(locationState)` xử lý trạng thái
- `_buildSnakeList` render list dữ liệu (banner thông tin, danh sách card)
- `_onSnakeSelected` xác nhận từ loài rắn

---

## 5. Triệu chứng cần test

- Quyền location bị từ chối
- API trả lỗi (401, 403, 500)
- location không có rắn (`snakes.isEmpty`)
- Dữ liệu hợp lệ (`snakes` > 0)

---

## 6. Ví dụ tích hợp nhanh trong 1 screen mới (tóm tắt)

- Import provider, DTO, repository, geolocator.
- Khởi tạo đã có provider (`snakeLocationProvider`) cùng repository provider (`snakeSpeciesRepositoryProvider`).
- Call `fetchSnakesByLocation` khi cần refresh hoặc `initState`.
- Dùng Riverpod `ref.watch` và `ref.read(...notifier)`.

---

## 7. Gợi ý nâng cấp

- Tăng trải nghiệm: thêm nút "Lấy lại vị trí" và RefreshIndicator.
- Cache theo vị trí nếu đã gọi trong 5 phút.
- Thêm filter nhanh: `Nhóm độc/không độc`, `Mức độ nguy hiểm`.
- Dẫn tới "Chi tiết rắn" khi người dùng tap card (mở màn hình detail).

---

## 8. Kết luận

Bạn chỉ cần đảm bảo 3 phần core: data model, repository, provider. Screen tham khảo `snake_selection_by_location_screen.dart` đã hoàn chỉnh, chỉ việc tái sử dụng lại và tuỳ biến giao diện.
