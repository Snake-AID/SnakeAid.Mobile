/// API endpoint constants for SnakeAid backend
class ApiConstants {
  // Base URL - Update when backend is ready
  static const String baseUrl = 'https://api.snakeaid.com';
  
  // ==================== AUTH ENDPOINTS ====================
  
  /// POST - Login with email and password
  static const String login = '/auth/login';
  
  /// POST - Register new user
  static const String register = '/auth/register';
  
  /// POST - Logout current user
  static const String logout = '/auth/logout';
  
  /// POST - Request password reset
  static const String resetPassword = '/auth/reset-password';
  
  /// POST - Verify email with OTP
  static const String verifyEmail = '/auth/verify-email';
  
  /// GET - Get current user profile
  static const String profile = '/auth/profile';
  
  /// PUT - Update user profile
  static const String updateProfile = '/auth/profile';
  
  
}
