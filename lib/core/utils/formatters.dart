import 'package:intl/intl.dart';

/// Utility class for formatting data
class Formatters {
  // ==================== DATE & TIME ====================
  
  /// Format date to dd/MM/yyyy
  /// 
  /// Example: 26/01/2026
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Format date and time to dd/MM/yyyy HH:mm
  /// 
  /// Example: 26/01/2026 14:30
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  /// Format time to HH:mm
  /// 
  /// Example: 14:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// Format date to readable Vietnamese format
  /// 
  /// Example: Thứ 2, 26 Tháng 1, 2026
  static String formatDateReadable(DateTime date) {
    final weekday = _getVietnameseWeekday(date.weekday);
    final day = date.day;
    final month = date.month;
    final year = date.year;
    return '$weekday, $day Tháng $month, $year';
  }
  
  /// Get Vietnamese weekday name
  static String _getVietnameseWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
  
  /// Format relative time (e.g., "2 phút trước", "1 giờ trước")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  /// Format duration in minutes to readable format
  /// 
  /// Example: 90 minutes → "1 giờ 30 phút"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours giờ';
      }
      return '$hours giờ $remainingMinutes phút';
    }
  }
  
  // ==================== CURRENCY ====================
  
  /// Format amount to Vietnamese Dong (₫)
  /// 
  /// Example: 300000 → "300.000₫"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  /// Format currency with compact notation for large numbers
  /// 
  /// Example: 1500000 → "1,5 triệu"
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} nghìn';
    } else {
      return '${amount.toStringAsFixed(0)}₫';
    }
  }
  
  // ==================== DISTANCE ====================
  
  /// Format distance in meters
  /// 
  /// Example: 500 → "500m", 1500 → "1.5km"
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
  
  /// Format distance with direction (for navigation)
  /// 
  /// Example: "1.5km về phía Đông Bắc"
  static String formatDistanceWithDirection(
    double meters,
    String? direction,
  ) {
    final distance = formatDistance(meters);
    if (direction != null && direction.isNotEmpty) {
      return '$distance về phía $direction';
    }
    return distance;
  }
  
  // ==================== PHONE NUMBER ====================
  
  /// Format phone number with separators
  /// 
  /// Example: 0901234567 → 090 123 4567
  static String formatPhoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
  }
  
  /// Format phone number for calling (remove spaces)
  static String formatPhoneForCall(String phone) {
    return phone.replaceAll(RegExp(r'[\s-]'), '');
  }
  
  // ==================== NUMBER ====================
  
  /// Format number with thousand separators
  /// 
  /// Example: 1234567 → "1.234.567"
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern('vi_VN').format(number);
  }
  
  /// Format percentage
  /// 
  /// Example: 0.75 → "75%"
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
  
  /// Format decimal number
  /// 
  /// Example: 3.14159 → "3.14"
  static String formatDecimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }
  
  // ==================== FILE SIZE ====================
  
  /// Format file size in bytes
  /// 
  /// Example: 1024 → "1 KB", 1048576 → "1 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // ==================== RATING ====================
  
  /// Format rating with one decimal
  /// 
  /// Example: 4.666 → "4.7"
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
  
  /// Format rating with stars
  /// 
  /// Example: 4.5 → "4.5 ⭐"
  static String formatRatingWithStar(double rating) {
    return '${formatRating(rating)} ⭐';
  }
  
  // ==================== TEXT ====================
  
  /// Capitalize first letter of each word
  /// 
  /// Example: "nguyen van a" → "Nguyen Van A"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Truncate text with ellipsis
  /// 
  /// Example: "This is a long text" → "This is a lo..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Format list to comma-separated string
  /// 
  /// Example: ["A", "B", "C"] → "A, B, C"
  static String formatList(List<String> items) {
    return items.join(', ');
  }
  
  /// Format list with "và" for last item
  /// 
  /// Example: ["A", "B", "C"] → "A, B và C"
  static String formatListVietnamese(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    
    final allButLast = items.sublist(0, items.length - 1).join(', ');
    final last = items.last;
    return '$allButLast và $last';
  }
}
