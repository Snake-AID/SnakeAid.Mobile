import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Helper class for handling app permissions
class PermissionHelper {
  // ==================== CAMERA ====================
  
  /// Request camera permission
  /// 
  /// Returns true if granted, false otherwise
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  /// Request camera with rationale dialog
  static Future<bool> requestCameraWithDialog(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Quyền truy cập Camera',
        'SnakeAid cần quyền truy cập camera để chụp ảnh rắn và vết cắn.',
      );
      
      if (result == true) {
        return await requestCamera();
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        'Quyền Camera bị từ chối',
        'Vui lòng vào Cài đặt để cấp quyền camera cho SnakeAid.',
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  // ==================== LOCATION ====================
  
  /// Request location permission
  /// 
  /// Returns true if granted, false otherwise
  static Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  /// Request location permission when in use
  static Future<bool> requestLocationWhenInUse() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
  
  /// Request location permission always
  static Future<bool> requestLocationAlways() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }
  
  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }
  
  /// Request location with rationale dialog
  static Future<bool> requestLocationWithDialog(BuildContext context) async {
    final status = await Permission.location.status;
    
    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Quyền truy cập Vị trí',
        'SnakeAid cần quyền truy cập vị trí để:\n'
        '• Gọi cấp cứu và chia sẻ vị trí GPS\n'
        '• Tìm bệnh viện gần nhất\n'
        '• Kết nối với đội cứu hộ',
      );
      
      if (result == true) {
        return await requestLocation();
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        'Quyền Vị trí bị từ chối',
        'Vui lòng vào Cài đặt để cấp quyền vị trí cho SnakeAid.',
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  // ==================== PHOTOS ====================
  
  /// Request photos/gallery permission
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  
  /// Check if photos permission is granted
  static Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted;
  }
  
  /// Request photos with rationale dialog
  static Future<bool> requestPhotosWithDialog(BuildContext context) async {
    final status = await Permission.photos.status;
    
    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Quyền truy cập Thư viện ảnh',
        'SnakeAid cần quyền truy cập thư viện ảnh để bạn có thể tải lên ảnh rắn hoặc vết cắn.',
      );
      
      if (result == true) {
        return await requestPhotos();
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        'Quyền Thư viện ảnh bị từ chối',
        'Vui lòng vào Cài đặt để cấp quyền thư viện ảnh cho SnakeAid.',
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  // ==================== PHONE ====================
  
  /// Request phone permission (for making calls)
  static Future<bool> requestPhone() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }
  
  /// Check if phone permission is granted
  static Future<bool> hasPhonePermission() async {
    return await Permission.phone.isGranted;
  }
  
  // ==================== NOTIFICATIONS ====================
  
  /// Request notification permission
  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }
  
  /// Request notification with rationale dialog
  static Future<bool> requestNotificationWithDialog(
    BuildContext context,
  ) async {
    final status = await Permission.notification.status;
    
    if (status.isDenied) {
      final result = await _showPermissionDialog(
        context,
        'Quyền Thông báo',
        'SnakeAid cần quyền gửi thông báo để:\n'
        '• Cảnh báo khẩn cấp\n'
        '• Cập nhật trạng thái cứu hộ\n'
        '• Nhắc nhở lịch tư vấn',
      );
      
      if (result == true) {
        return await requestNotification();
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showSettingsDialog(
        context,
        'Quyền Thông báo bị từ chối',
        'Vui lòng vào Cài đặt để cấp quyền thông báo cho SnakeAid.',
      );
      return false;
    }
    
    return status.isGranted;
  }
  
  // ==================== STORAGE ====================
  
  /// Request storage permission
  static Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }
  
  // ==================== MICROPHONE ====================
  
  /// Request microphone permission (for video calls)
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  /// Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }
  
  // ==================== MULTIPLE PERMISSIONS ====================
  
  /// Request camera and photos permissions together
  static Future<Map<Permission, PermissionStatus>> requestCameraAndPhotos() async {
    return await [
      Permission.camera,
      Permission.photos,
    ].request();
  }
  
  /// Request all emergency permissions
  /// (Location, Phone, Camera)
  static Future<Map<Permission, PermissionStatus>> requestEmergencyPermissions() async {
    return await [
      Permission.location,
      Permission.phone,
      Permission.camera,
    ].request();
  }
  
  // ==================== SETTINGS ====================
  
  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
  
  // ==================== DIALOGS ====================
  
  /// Show permission rationale dialog
  static Future<bool?> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Từ chối'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cho phép'),
          ),
        ],
      ),
    );
  }
  
  /// Show settings dialog when permission is permanently denied
  static Future<void> _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }
  
  // ==================== UTILITY ====================
  
  /// Check if all required emergency permissions are granted
  static Future<bool> hasAllEmergencyPermissions() async {
    final location = await Permission.location.isGranted;
    final camera = await Permission.camera.isGranted;
    
    return location && camera;
  }
  
  /// Get permission status text in Vietnamese
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Đã cấp';
      case PermissionStatus.denied:
        return 'Bị từ chối';
      case PermissionStatus.permanentlyDenied:
        return 'Bị từ chối vĩnh viễn';
      case PermissionStatus.restricted:
        return 'Bị giới hạn';
      case PermissionStatus.limited:
        return 'Giới hạn';
      case PermissionStatus.provisional:
        return 'Tạm thời';
      default:
        return 'Không xác định';
    }
  }
}
