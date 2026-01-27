# Hướng dẫn thêm Logo SnakeAid

## ✅ Logo đã được đặt sẵn!

File logo: **`snakeaid_logo.jpg`** đã có trong thư mục:
```
assets/images/logo/snakeaid_logo.jpg
```

## Bước 3: Chạy lệnh Flutter

Sau khi đặt logo vào đúng vị trí, chạy lệnh:

```bash
flutter pub get
```

## Bước 4: Chạy app

```bash
flutter run
```

---

## Lưu ý về kích thước logo

Để logo hiển thị đẹp trên mọi thiết bị, bạn nên tạo các phiên bản:

- **1x**: 100x100 px
- **2x**: 200x200 px  
- **3x**: 300x300 px

Hoặc sử dụng 1 file PNG có kích thước 300x300 px (sẽ tự động scale).

---

## Cấu trúc thư mục assets đầy đủ

```
assets/
├── images/
│   ├── logo/
│   │   └── snakeaid_logo.png    ← Đặt logo ở đây
│   ├── snakes/                   ← Hình ảnh rắn (để sau)
│   ├── icons/                    ← Icons khác (để sau)
│   └── illustrations/            ← Illustrations (để sau)
```

---

## Nếu không có logo ngay bây giờ

App sẽ tự động hiển thị icon mặc định (health_and_safety icon) cho đến khi bạn thêm logo thật vào.
