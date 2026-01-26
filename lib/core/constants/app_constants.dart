/// Application-wide constants
class AppConstants {
  // ==================== APP INFO ====================
  
  static const String appName = 'SnakeAid';
  static const String appVersion = '1.0.0';
  
  // ==================== EMERGENCY ====================
  
  /// Vietnam emergency hotline
  static const String emergencyHotline = '115';
  
  /// Poison control center
  static const String poisonControlHotline = '19003456';
  
  /// Animal control
  static const String animalControlHotline = '1800-6091';
  
  // ==================== TIMEOUTS ====================
  
  /// API connection timeout in seconds
  static const int connectionTimeout = 30;
  
  /// API receive timeout in seconds
  static const int receiveTimeout = 30;
  
  /// Send timeout in seconds
  static const int sendTimeout = 30;
  
  /// Location update interval in seconds
  static const int locationUpdateInterval = 10;
  
  /// Rescuer matching timeout in seconds
  static const int rescuerMatchingTimeout = 120; // 2 minutes
  
  /// SOS auto-call delay in seconds (time to cancel)
  static const int sosAutoCallDelay = 5;
  
  // ==================== PAGINATION ====================
  
  /// Default items per page for lists
  static const int itemsPerPage = 20;
  
  /// Max items to load at once
  static const int maxItemsPerLoad = 50;
  
  // ==================== MAPS ====================
  
  /// Default zoom level for Google Maps
  static const double defaultZoom = 15.0;
  
  /// Close zoom level for detailed view
  static const double closeZoom = 18.0;
  
  /// Far zoom level for area view
  static const double farZoom = 12.0;
  
  /// Default latitude (Ho Chi Minh City center)
  static const double defaultLatitude = 10.8231;
  
  /// Default longitude (Ho Chi Minh City center)
  static const double defaultLongitude = 106.6297;
  
  /// Default search radius in kilometers
  static const double defaultSearchRadius = 20.0;
  
  /// Close search radius in kilometers
  static const double closeSearchRadius = 5.0;
  
  /// Extended search radius in kilometers
  static const double extendedSearchRadius = 50.0;
  
  // ==================== FILE & MEDIA ====================
  
  /// Maximum photos per upload
  static const int maxPhotos = 5;
  
  /// Maximum file size in bytes (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;
  
  /// Maximum image width/height for upload
  static const int maxImageDimension = 1920;
  
  /// Image compression quality (0-100)
  static const int imageQuality = 85;
  
  /// Supported image formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // ==================== SNAKE IDENTIFICATION ====================
  
  /// Minimum AI confidence threshold to show result (0.0 - 1.0)
  static const double minAIConfidence = 0.6;
  
  /// High confidence threshold (0.0 - 1.0)
  static const double highConfidence = 0.85;
  
  /// Time limit for AI processing in seconds
  static const int aiProcessingTimeout = 10;
  
  // ==================== SEVERITY LEVELS ====================
  
  /// Severity level: Mild/Nhẹ
  static const String severityMild = 'mild';
  
  /// Severity level: Moderate/Trung bình
  static const String severityModerate = 'moderate';
  
  /// Severity level: Severe/Nặng
  static const String severitySevere = 'severe';
  
  /// Severity level: Critical/Nguy kịch
  static const String severityCritical = 'critical';
  
  // ==================== DANGER LEVELS ====================
  
  /// Danger level: Low/Thấp
  static const String dangerLevelLow = 'low';
  
  /// Danger level: Medium/Trung bình
  static const String dangerLevelMedium = 'medium';
  
  /// Danger level: High/Cao
  static const String dangerLevelHigh = 'high';
  
  /// Danger level: Very High/Rất cao
  static const String dangerLevelVeryHigh = 'very_high';
  
  // ==================== RESCUE STATUS ====================
  
  /// Rescue status: Pending/Chờ xác nhận
  static const String rescueStatusPending = 'pending';
  
  /// Rescue status: Accepted/Đã chấp nhận
  static const String rescueStatusAccepted = 'accepted';
  
  /// Rescue status: En Route/Đang trên đường
  static const String rescueStatusEnRoute = 'en_route';
  
  /// Rescue status: Arrived/Đã đến
  static const String rescueStatusArrived = 'arrived';
  
  /// Rescue status: In Progress/Đang xử lý
  static const String rescueStatusInProgress = 'in_progress';
  
  /// Rescue status: Completed/Hoàn thành
  static const String rescueStatusCompleted = 'completed';
  
  /// Rescue status: Cancelled/Đã hủy
  static const String rescueStatusCancelled = 'cancelled';
  
  // ==================== PAYMENT ====================
  
  /// Platform fee percentage
  static const double platformFeePercentage = 0.10; // 10%
  
  /// Rescuer commission percentage
  static const double rescuerCommissionPercentage = 0.85; // 85%
  
  /// Insurance fund percentage
  static const double insuranceFundPercentage = 0.05; // 5%
  
  /// Minimum rescue fee in VND
  static const int minRescueFee = 100000; // 100k VND
  
  /// Default rescue fee in VND
  static const int defaultRescueFee = 300000; // 300k VND
  
  /// Maximum rescue fee in VND
  static const int maxRescueFee = 2000000; // 2M VND
  
  /// Minimum consultation fee in VND
  static const int minConsultationFee = 50000; // 50k VND
  
  /// Default consultation fee in VND
  static const int defaultConsultationFee = 200000; // 200k VND
  
  // ==================== RATING ====================
  
  /// Minimum rating (stars)
  static const int minRating = 1;
  
  /// Maximum rating (stars)
  static const int maxRating = 5;
  
  /// Minimum rating to be featured rescuer
  static const double featuredRescuerMinRating = 4.5;
  
  /// Minimum rating to be featured expert
  static const double featuredExpertMinRating = 4.5;
  
  // ==================== NOTIFICATION ====================
  
  /// Max notifications to show in list
  static const int maxNotifications = 50;
  
  /// Notification retention days
  static const int notificationRetentionDays = 30;
  
  // ==================== CACHE ====================
  
  /// Cache duration in hours
  static const int cacheDurationHours = 24;
  
  /// Image cache duration in days
  static const int imageCacheDurationDays = 7;
  
  // ==================== LOCALE ====================
  
  /// Default locale
  static const String defaultLocale = 'vi';
  
  /// Supported locales
  static const List<String> supportedLocales = ['vi', 'en'];
  
  // ==================== REGIONS (Vietnam) ====================
  
  /// Regions of Vietnam
  static const List<String> regions = [
    'Miền Bắc',
    'Miền Trung',
    'Miền Nam',
  ];
  
  /// Major cities
  static const List<String> majorCities = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Cần Thơ',
    'Hải Phòng',
  ];
  
  // ==================== VALIDATION ====================
  
  /// Min password length
  static const int minPasswordLength = 6;
  
  /// Max password length
  static const int maxPasswordLength = 50;
  
  /// Phone number length (Vietnam)
  static const int phoneNumberLength = 10;
  
  /// Min review length
  static const int minReviewLength = 10;
  
  /// Max review length
  static const int maxReviewLength = 500;
  
  /// Max description length
  static const int maxDescriptionLength = 1000;
}
