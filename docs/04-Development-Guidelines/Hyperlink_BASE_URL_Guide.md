# Hướng dẫn sử dụng Hyperlink để thay đổi BASE_URL

## Tổng quan

SnakeAid Mobile hỗ trợ thay đổi BASE_URL thông qua deep links (hyperlinks). Tính năng này cho phép bạn chuyển đổi giữa các môi trường backend (development, staging, production) mà không cần rebuild ứng dụng.

## ⚠️ Lưu ý quan trọng

- **Chỉ hoạt động trong debug mode**: Deep links chỉ có tác dụng khi ứng dụng đang chạy ở chế độ debug (`kDebugMode = true`)
- **Production builds bỏ qua deep links**: Các bản build production sẽ không phản hồi các deep link cấu hình
- **Ứng dụng phải được cài đặt**: Thiết bị phải cài đặt ứng dụng SnakeAid thì deep link mới hoạt động

## Định dạng Deep Link

### Cơ bản

```
snakeaid://config/baseurl?url=<URL_CỦA_BẠN>
```

### Reset về mặc định

```
snakeaid://config/reset
```

## Các phương pháp sử dụng

### Phương pháp 1: HTML Hyperlink

Tạo liên kết HTML có thể click từ website hoặc email:

```html
<!-- Chuyển sang Development Server -->
<a href="snakeaid://config/baseurl?url=http://192.168.1.100:8080">
  🖥️ Switch to Development Server
</a>

<!-- Chuyển sang Staging Server -->
<a href="snakeaid://config/baseurl?url=https://staging-api.snakeaid.com">
  ☁️ Switch to Staging Server
</a>

<!-- Chuyển sang Production Server -->
<a href="snakeaid://config/baseurl?url=https://api.snakeaid.com">
  🚀 Switch to Production Server
</a>

<!-- Reset về BASE_URL mặc định -->
<a href="snakeaid://config/reset" style="color: red;">
  ⚠️ Reset to Default
</a>
```

### Phương pháp 2: QR Code

Tạo QR code để đồng đội có thể quét bằng điện thoại:

```html
<!-- Sử dụng QR code generator API miễn phí -->
<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=snakeaid://config/baseurl?url=http://192.168.1.100:8080" 
     alt="Quét để chuyển sang Dev Server">

<!-- QR Code cho Staging -->
<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=snakeaid://config/baseurl?url=https://staging-api.snakeaid.com" 
     alt="Quét để chuyển sang Staging">

<!-- QR Code cho Reset -->
<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=snakeaid://config/reset" 
     alt="Quét để reset BASE_URL">
```

**Công cụ tạo QR Code online:**
- https://api.qrserver.com/qr-code-creator/
- https://www.qr-code-generator.com/
- https://qr.io/

### Phương pháp 3: ADB Command (Android)

```bash
# Chuyển sang custom BASE_URL
adb shell am start -W -a android.intent.action.VIEW \
  -d "snakeaid://config/baseurl?url=http://192.168.1.100:8080" \
  com.snakeaid.mobile

# Reset về mặc định
adb shell am start -W -a android.intent.action.VIEW \
  -d "snakeaid://config/reset" \
  com.snakeaid.mobile
```

### Phương pháp 4: iOS Simulator

```bash
# Chuyển sang custom BASE_URL
xcrun simctl openurl booted "snakeaid://config/baseurl?url=http://192.168.1.100:8080"

# Reset về mặc định
xcrun simctl openurl booted "snakeaid://config/reset"
```

### Phương pháp 5: Trang HTML Quick Access

Tạo một trang HTML với tất cả các lựa chọn môi trường:

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SnakeAID - Bộ chuyển đổi môi trường</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 600px;
            margin: 40px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        h1 {
            color: #1a73e8;
            text-align: center;
        }
        .section {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h2 {
            color: #333;
            margin-top: 0;
            font-size: 18px;
        }
        a {
            display: block;
            padding: 12px 16px;
            margin: 8px 0;
            background: #e8f0fe;
            color: #1a73e8;
            text-decoration: none;
            border-radius: 6px;
            transition: background 0.2s;
        }
        a:hover {
            background: #d2e3fc;
        }
        a.reset {
            background: #fce8e6;
            color: #d93025;
        }
        a.reset:hover {
            background: #fad2cf;
        }
        .emoji {
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <h1>🐍 SnakeAID Environment Switcher</h1>
    
    <div class="section">
        <h2>🖥️ Development</h2>
        <a href="snakeaid://config/baseurl?url=http://localhost:8080">
            <span class="emoji">💻</span> Localhost (8080)
        </a>
        <a href="snakeaid://config/baseurl?url=http://127.0.0.1:8080">
            <span class="emoji">🏠</span> Localhost (127.0.0.1:8080)
        </a>
        <a href="snakeaid://config/baseurl?url=http://192.168.1.100:8080">
            <span class="emoji">📶</span> Local Network (192.168.1.100)
        </a>
        <a href="snakeaid://config/baseurl?url=http://192.168.1.200:3000">
            <span class="emoji">🔧</span> Dev Server (192.168.1.200:3000)
        </a>
    </div>
    
    <div class="section">
        <h2>☁️ Staging</h2>
        <a href="snakeaid://config/baseurl?url=https://staging-api.snakeaid.com">
            <span class="emoji">🧪</span> Staging Server
        </a>
        <a href="snakeaid://config/baseurl?url=https://test.snakeaid.com">
            <span class="emoji">🧪</span> Test Environment
        </a>
    </div>
    
    <div class="section">
        <h2>🚀 Production</h2>
        <a href="snakeaid://config/baseurl?url=https://api.snakeaid.com">
            <span class="emoji">✅</span> Production Server
        </a>
    </div>
    
    <div class="section">
        <h2>⚠️ Actions</h2>
        <a href="snakeaid://config/reset" class="reset">
            <span class="emoji">🔄</span> Reset to Default BASE_URL
        </a>
    </div>
    
    <p style="text-align: center; color: #666; font-size: 14px; margin-top: 30px;">
        ⚠️ Chỉ hoạt động trong debug mode
    </p>
</body>
</html>
```

**Cách sử dụng:**
1. Lưu file trên thành `environment-switcher.html`
2. Gửi file đến điện thoại hoặc host lên web server
3. Mở file bằng trình duyệt trên điện thoại
4. Click vào link tương ứng với môi trường muốn chuyển

## URL Encoding

Nếu URL của bạn chứa ký tự đặc biệt, cần mã hóa URL:

| Ký tự | Mã hóa |
|-------|--------|
| `:` | `%3A` |
| `/` | `%2F` |
| `?` | `%3F` |
| `=` | `%3D` |
| `&` | `%26` |
| `#` | `%23` |

**Ví dụ:**
```
http://example.com/path?query=value&token=abc
```

Thành:
```
snakeaid://config/baseurl?url=http%3A%2F%2Fexample.com%2Fpath%3Fquery%3Dvalue%26token%3Dabc
```

## Kiểm tra kết quả

Sau khi click hyperlink, kiểm tra log để xác nhận BASE_URL đã thay đổi:

### Android (ADB Logcat)
```bash
adb logcat | grep -E "DeepLinkHandler|BaseUrlConfig"
```

### iOS (Console)
Mở Console.app trên Mac và filter theo "DeepLinkHandler"

### Kết quả mong đợi

```
🔗 [DeepLinkHandler] Received deep link: snakeaid://config/baseurl?url=http://192.168.1.100:8080
✅ [DeepLinkHandler] Đã cập nhật BASE_URL:
http://192.168.1.100:8080
```

## Troubleshooting

### Deep link không hoạt động

1. **Kiểm tra debug mode:**
   - Đảm bảo app đang chạy ở chế độ debug
   - Production builds sẽ bỏ qua deep links

2. **Kiểm tra package name (Android):**
   ```bash
   # Sử dụng đúng package name
   adb shell am start -W -a android.intent.action.VIEW \
     -d "snakeaid://config/baseurl?url=..." \
     com.snakeaid.mobile
   ```

3. **Kiểm tra intent filter:**
   - Xác nhận `android/app/src/main/AndroidManifest.xml` có scheme `snakeaid://`

4. **Xem logs:**
   ```bash
   adb logcat | grep DeepLinkHandler
   ```

### BASE_URL không persist

1. **Kiểm tra SharedPreferences:**
   ```dart
   final prefs = await SharedPreferences.getInstance();
   print(prefs.getString('base_url_override'));
   ```

2. **Xóa data app và thử lại:**
   ```bash
   adb shell pm clear com.snakeaid.mobile
   ```

### HTTP calls vẫn dùng URL cũ

1. **Khởi động lại app:**
   - Một số service cần restart để nhận URL mới

2. **Kiểm tra provider:**
   - Services phải dùng `ref.watch(baseUrlProvider)` thay vì static values

## Các ví dụ thực tế

### Ví dụ 1: Development Team Setup

Tạo một trang nội bộ cho team với các môi trường:

```html
<!DOCTYPE html>
<html>
<body>
    <h1>Team Environment Switcher</h1>
    
    <!-- Các môi trường của team members -->
    <a href="snakeaid://config/baseurl?url=http://192.168.1.10:8080">
        Dev - Machine của Khiêm (192.168.1.10)
    </a>
    <a href="snakeaid://config/baseurl?url=http://192.168.1.20:8080">
        Dev - Machine của Nam (192.168.1.20)
    </a>
    <a href="snakeaid://config/baseurl?url=http://192.168.1.30:3000">
        Dev - Machine của Hùng (192.168.1.30)
    </a>
    
    <!-- Shared environments -->
    <a href="snakeaid://config/baseurl?url=http://192.168.1.100:8080">
        Shared Dev Server
    </a>
    <a href="snakeaid://config/baseurl?url=https://staging.snakeaid.com">
        Staging Server
    </a>
</body>
</html>
```

### Ví dụ 2: Email Template

Gửi email cho team với các link chuyển đổi:

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        .button {
            display: inline-block;
            padding: 10px 20px;
            margin: 5px;
            background: #1a73e8;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .button.reset {
            background: #d93025;
        }
    </style>
</head>
<body>
    <h2>SnakeAID Environment Switcher</h2>
    <p>Click vào nút bên dưới để chuyển đổi môi trường:</p>
    
    <a href="snakeaid://config/baseurl?url=http://localhost:8080" class="button">
        🖥️ Localhost
    </a>
    
    <a href="snakeaid://config/baseurl?url=https://staging-api.snakeaid.com" class="button">
        ☁️ Staging
    </a>
    
    <a href="snakeaid://config/reset" class="button reset">
        🔄 Reset
    </a>
</body>
</html>
```

### Ví dụ 3: Slack/Teams Message

Gửi message với deep links trong Slack hoặc Microsoft Teams:

```markdown
🐍 **SnakeAID Environment Switcher**

Chuyển đổi môi trường nhanh:

• Development: `snakeaid://config/baseurl?url=http://localhost:8080`
• Staging: `snakeaid://config/baseurl?url=https://staging-api.snakeaid.com`
• Production: `snakeaid://config/baseurl?url=https://api.snakeaid.com`
• Reset: `snakeaid://config/reset`

⚠️ Chỉ hoạt động trong debug mode!
```

## Tài liệu liên quan

- [`BASE_URL_Hotpatching.md`](BASE_URL_Hotpatching.md) - Hướng dẫn chi tiết về BASE_URL hot-patching
- [`lib/core/config/base_url_config.dart`](../../lib/core/config/base_url_config.dart) - Base URL configuration
- [`lib/core/handlers/deep_link_handler.dart`](../../lib/core/handlers/deep_link_handler.dart) - Deep link handler

## Future Enhancements

- [ ] Thêm lịch sử URL đã sử dụng để chuyển đổi nhanh
- [ ] Hỗ trợ QR code scanner trong app
- [ ] Thêm environment presets (Dev, Staging, Production)
- [ ] Thêm dialog xác nhận trước khi áp dụng URL mới
- [ ] Log thay đổi BASE_URL vào analytics (debug only)
