/// Form validators for user input
class Validators {
  /// Validate email address
  /// 
  /// Returns error message if invalid, null if valid
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }
  
  /// Validate phone number (Vietnam format)
  /// 
  /// Accepts: 10 digits starting with 0
  /// Returns error message if invalid, null if valid
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Vietnam phone: 10 digits starting with 0
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ (phải có 10 chữ số)';
    }
    
    return null;
  }
  
  /// Validate password
  /// 
  /// Minimum 6 characters
  /// Returns error message if invalid, null if valid
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    if (value.length > 50) {
      return 'Mật khẩu không được vượt quá 50 ký tự';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  /// 
  /// Must match the original password
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    
    if (value != originalPassword) {
      return 'Mật khẩu không khớp';
    }
    
    return null;
  }
  
  /// Validate required field
  /// 
  /// [fieldName] is used in error message
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    return null;
  }
  
  /// Validate required field with minimum length
  static String? requiredMin(String? value, String fieldName, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    if (value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }
    
    return null;
  }
  
  /// Validate name (no numbers or special characters)
  static String? name(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    // Allow letters, spaces, Vietnamese characters
    final nameRegex = RegExp(
      r'^[a-zA-ZÀ-ỹ\s]+$',
      unicode: true,
    );
    
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName không được chứa số hoặc ký tự đặc biệt';
    }
    
    return null;
  }
  
  /// Validate number field
  static String? number(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    if (int.tryParse(value) == null) {
      return '$fieldName phải là số';
    }
    
    return null;
  }
  
  /// Validate number in range
  static String? numberInRange(
    String? value,
    String fieldName,
    int min,
    int max,
  ) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    
    final number = int.tryParse(value);
    
    if (number == null) {
      return '$fieldName phải là số';
    }
    
    if (number < min || number > max) {
      return '$fieldName phải từ $min đến $max';
    }
    
    return null;
  }
  
  /// Validate text length
  static String? maxLength(String? value, String fieldName, int maxLength) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    
    return null;
  }
  
  /// Validate rating (1-5)
  static String? rating(double? value) {
    if (value == null) {
      return 'Vui lòng chọn đánh giá';
    }
    
    if (value < 1 || value > 5) {
      return 'Đánh giá phải từ 1 đến 5 sao';
    }
    
    return null;
  }
  
  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL không hợp lệ';
    }
    
    return null;
  }
}
