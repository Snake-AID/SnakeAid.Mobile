# 🎯 CODING STANDARDS & RULES - SNAKEAID MOBILE

> **Áp dụng cho:** Tất cả developers làm việc trên dự án SnakeAid Mobile

---

## 📐 KIẾN TRÚC DỰ ÁN

### **Feature-Based Architecture**
```
lib/
├── app/                    # App configuration
│   ├── router.dart        # Navigation
│   └── theme.dart         # Theme definitions
├── core/                   # Shared utilities
│   ├── providers/         # Global providers
│   └── services/          # Global services
├── features/              # Feature modules
│   ├── auth/
│   ├── consultation/
│   ├── emergency/
│   ├── expert/
│   ├── payment/
│   ├── rescuer/
│   ├── shared/
│   └── snake_catching/
└── examples/              # Examples & demos
```

### **Feature Module Structure**
```
feature_name/
├── models/         # Data models & entities
├── providers/      # State management (Riverpod)
├── repository/     # Data layer (API calls)
├── screens/        # UI screens
└── widgets/        # Reusable UI components
```

---

## 📝 NAMING CONVENTIONS

### **1. Files & Folders**
```dart
// ✅ ĐÚNG - snake_case
user_profile.dart
auth_repository.dart
payment_provider.dart
emergency_request_card.dart

// ❌ SAI
UserProfile.dart
authRepository.dart
PaymentProvider.dart
Class.dart
EmptyFile.dart
```

### **2. Classes**
```dart
// ✅ ĐÚNG - PascalCase
class UserProfile {}
class AuthRepository {}
class PaymentProvider extends StateNotifier<PaymentState> {}
class CustomButton extends StatelessWidget {}
class LoginScreen extends ConsumerStatefulWidget {}

// Models
class User {}
class SnakeInfo {}
class EmergencyRequest {}

// State classes
class AuthState {}
class PaymentState {}

// Enums
enum UserRole { patient, rescuer, expert, admin }
enum PaymentStatus { pending, completed, failed }
```

### **3. Variables & Functions**
```dart
// ✅ ĐÚNG - camelCase
String userName;
int userId;
bool isAuthenticated;
Future<void> fetchUserData() {}
void handleLoginPressed() {}

// Private - prefix với underscore
String _privateVariable;
void _privateMethod() {}
Widget _buildHeader() {}

// Constants - UPPER_CASE hoặc camelCase với const
const String BASE_URL = 'https://api.snakeaid.com';
const int MAX_RETRY_COUNT = 3;
const double defaultPadding = 16.0;

// Boolean - prefix với is, has, should, can
bool isLoading;
bool hasError;
bool shouldShowDialog;
bool canSubmit;
```

### **4. Providers**
```dart
// ✅ ĐÚNG
// StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(...);

// Regular Provider (services, repositories)
final httpServiceProvider = Provider<HttpService>(...);
final authRepositoryProvider = Provider<AuthRepository>(...);

// FutureProvider
final userFutureProvider = FutureProvider<User>(...);

// StreamProvider
final notificationStreamProvider = StreamProvider<Notification>(...);

// Computed/Derived Provider
final isAuthenticatedProvider = Provider<bool>(...);
final unreadCountProvider = Provider<int>(...);
```

---

## 📦 IMPORT ORGANIZATION

```dart
// Thứ tự imports (phân cách bởi dòng trống):

// 1. Dart SDK
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

// 3. Third-party packages (alphabetical)
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 4. Internal - Core
import 'package:snakeaid_mobile/app/theme.dart';
import 'package:snakeaid_mobile/core/providers/http_provider.dart';
import 'package:snakeaid_mobile/core/services/http_service.dart';

// 5. Internal - Features (current feature imports)
import 'package:snakeaid_mobile/features/auth/models/user.dart';
import 'package:snakeaid_mobile/features/auth/repository/auth_repository.dart';
import 'package:snakeaid_mobile/features/auth/providers/auth_provider.dart';

// 6. Relative imports (only within same feature)
import '../models/emergency_request.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

// ❌ KHÔNG: Mix absolute và relative imports cho cùng module
// ❌ KHÔNG: Relative imports để access features khác
```

---

## 🧩 LAYER-SPECIFIC RULES

### **📊 MODELS**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents a user in the system
/// 
/// Used for authentication and profile management
@JsonSerializable()
class User {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address (required for login)
  final String email;
  
  /// Optional phone number for contact
  final String? phoneNumber;
  
  /// User's role in the system
  final UserRole role;
  
  /// When the user account was created
  final DateTime createdAt;
  
  /// Creates a new User instance
  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
  });
  
  /// Creates User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  /// Converts User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  /// Creates a copy with modified fields
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';
}

/// User roles in the application
enum UserRole {
  @JsonValue('patient')
  patient,
  
  @JsonValue('rescuer')
  rescuer,
  
  @JsonValue('expert')
  expert,
  
  @JsonValue('admin')
  admin,
}
```

**✅ Model Rules:**
1. Tất cả fields phải `final` (immutable)
2. Sử dụng `@JsonSerializable()` cho serialization
3. Implement `fromJson()` và `toJson()`
4. Implement `copyWith()` method
5. Implement `==` và `hashCode` nếu cần equality comparison
6. Implement `toString()` cho debugging
7. Document public fields với `///` comments
8. Sử dụng `const` constructor khi có thể
9. Nullable fields với `?` và optional parameters
10. Enums nên có `@JsonValue` annotations

**❌ Model Anti-patterns:**
```dart
// ❌ Mutable fields
class User {
  String id; // SAI - không final
}

// ❌ Business logic trong model
class User {
  bool canEditProfile() { // SAI - logic nên ở Provider
    return role == UserRole.admin;
  }
}

// ❌ Không có fromJson/toJson
class User {
  final String id;
  // SAI - thiếu serialization
}
```

---

### **🗄️ REPOSITORY**

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/providers/http_provider.dart';
import 'package:snakeaid_mobile/core/services/http_service.dart';
import '../models/user.dart';
import '../models/login_response.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return AuthRepository(httpService: httpService);
});

/// Repository for authentication-related API calls
/// 
/// Handles login, registration, password reset, etc.
class AuthRepository {
  final HttpService httpService;
  
  AuthRepository({required this.httpService});
  
  /// Login user with email and password
  /// 
  /// Returns [LoginResponse] with user data and token
  /// Throws [Exception] on authentication failure
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting login for: $email');
      
      final response = await httpService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      debugPrint('✅ Login successful');
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Login failed: ${e.message}');
      throw _handleError(e);
    }
  }
  
  /// Register new user
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      debugPrint('📝 Registering user: $email');
      
      final response = await httpService.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'role': role.name,
        },
      );
      
      debugPrint('✅ Registration successful');
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      debugPrint('❌ Registration failed: ${e.message}');
      throw _handleError(e);
    }
  }
  
  /// Request password reset
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔑 Password reset requested for: $email');
      
      await httpService.post(
        '/auth/reset-password',
        data: {'email': email},
      );
      
      debugPrint('✅ Password reset email sent');
    } on DioException catch (e) {
      debugPrint('❌ Password reset failed: ${e.message}');
      throw _handleError(e);
    }
  }
  
  /// Verify email with OTP
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      await httpService.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle DioException and convert to meaningful error
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      // Extract error message from response
      String message = 'Đã xảy ra lỗi không mong muốn';
      
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      }
      
      // Specific error messages based on status code
      switch (statusCode) {
        case 400:
          message = data['message'] ?? 'Dữ liệu không hợp lệ';
          break;
        case 401:
          message = 'Email hoặc mật khẩu không đúng';
          break;
        case 403:
          message = 'Bạn không có quyền thực hiện thao tác này';
          break;
        case 404:
          message = 'Không tìm thấy tài nguyên';
          break;
        case 409:
          message = data['message'] ?? 'Dữ liệu đã tồn tại';
          break;
        case 500:
          message = 'Lỗi server, vui lòng thử lại sau';
          break;
      }
      
      return Exception(message);
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      return Exception('Kết nối timeout, vui lòng kiểm tra mạng');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('Không thể kết nối đến server');
    } else {
      return Exception('Lỗi mạng: ${error.message}');
    }
  }
}
```

**✅ Repository Rules:**
1. Inject dependencies (HttpService) qua constructor
2. Tạo Provider cho repository
3. Tất cả methods phải async (`Future<T>`)
4. Return domain models, không return raw Response
5. Document methods với `///` comments
6. Handle errors với try-catch
7. Throw meaningful exceptions
8. Use `debugPrint` cho logging (remove trước production)
9. Named parameters cho methods có > 2 params
10. Error handler riêng (`_handleError`)

**❌ Repository Anti-patterns:**
```dart
// ❌ Return raw Response
Future<Response> getUser() async {
  return await httpService.get('/users/me'); // SAI
}

// ❌ Không handle errors
Future<User> getUser() async {
  final response = await httpService.get('/users/me'); // SAI - không try-catch
  return User.fromJson(response.data);
}

// ❌ UI logic trong repository
Future<User> getUser(BuildContext context) async { // SAI - có BuildContext
  // ...
  Navigator.push(...); // SAI - navigation trong repository
}
```

---

### **⚡ PROVIDERS (State Management)**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/login_response.dart';
import '../repository/auth_repository.dart';

// ==================== STATE CLASS ====================

/// State for authentication
class AuthState {
  /// Currently logged in user (null if not logged in)
  final User? user;
  
  /// Authentication token
  final String? token;
  
  /// Whether an auth operation is in progress
  final bool isLoading;
  
  /// Error message if operation failed
  final String? error;
  
  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });
  
  /// Creates a copy with modified fields
  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  /// Reset state (for logout)
  factory AuthState.initial() => const AuthState();
  
  @override
  String toString() => 
      'AuthState(user: ${user?.email}, isLoading: $isLoading, error: $error)';
}

// ==================== NOTIFIER CLASS ====================

/// Manages authentication state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final Ref ref;
  
  AuthNotifier({
    required this.authRepository,
    required this.ref,
  }) : super(const AuthState()) {
    // Load saved session on initialization
    _loadSavedSession();
  }
  
  /// Load saved user session from storage
  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');
      
      if (token != null && userJson != null) {
        // Parse user data and restore session
        // final user = User.fromJson(jsonDecode(userJson));
        // state = state.copyWith(user: user, token: token);
        debugPrint('📱 Session restored');
      }
    } catch (e) {
      debugPrint('❌ Failed to load session: $e');
    }
  }
  
  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Set loading state and clear previous errors
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );
      
      // Save token and user data
      await _saveSession(response.token, response.user);
      
      // Update state
      state = state.copyWith(
        user: response.user,
        token: response.token,
        isLoading: false,
      );
      
      debugPrint('✅ Login successful: ${response.user.email}');
    } catch (e) {
      // Set error state
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      
      debugPrint('❌ Login error: $e');
    }
  }
  
  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );
      
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
      
      debugPrint('✅ Registration successful');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      
      debugPrint('❌ Registration error: $e');
    }
  }
  
  /// Logout and clear session
  Future<void> logout() async {
    await _clearSession();
    state = AuthState.initial();
    debugPrint('👋 Logged out');
  }
  
  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Save session to local storage
  Future<void> _saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    // await prefs.setString('user_data', jsonEncode(user.toJson()));
  }
  
  /// Clear session from local storage
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}

// ==================== PROVIDERS ====================

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(
    authRepository: authRepository,
    ref: ref,
  );
});

/// Computed: Is user authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user != null && authState.token != null;
});

/// Computed: Current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Computed: User role
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});
```

**✅ Provider Rules:**
1. State class phải immutable với `copyWith()`
2. Include `isLoading`, `error` trong state
3. Set loading state trước mọi async operation
4. Clear error khi bắt đầu operation mới
5. Handle both success và error cases
6. Use `debugPrint` cho logging
7. Inject repository qua constructor
8. Tạo computed providers cho derived state
9. Document state classes và methods
10. Initialize state trong constructor nếu cần

**❌ Provider Anti-patterns:**
```dart
// ❌ Mutable state
class AuthState {
  User? user; // SAI - không final
  bool isLoading = false; // SAI - không final
}

// ❌ Không handle loading state
Future<void> login() async {
  // SAI - thiếu isLoading = true
  final user = await repository.login();
  state = state.copyWith(user: user);
}

// ❌ UI code trong provider
Future<void> login(BuildContext context) async {
  // ...
  Navigator.pushNamed(context, '/home'); // SAI - navigation trong provider
}

// ❌ Không clear error
Future<void> login() async {
  // SAI - không set error = null
  state = state.copyWith(isLoading: true);
  // ...
}
```

---

### **🎨 SCREENS**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/app/theme.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Login screen for user authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Password visibility
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    // IMPORTANT: Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  /// Handle login button press
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Perform login
    await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
  
  /// Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }
  
  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Listen for auth state changes (for side effects)
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Show error snackbar
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear error after showing
        ref.read(authProvider.notifier).clearError();
      }
      
      // Navigate to home on success
      if (next.user != null && previous?.user == null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Header
                const SizedBox(height: AppTheme.spacingLarge),
                Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                
                // Title
                Text(
                  'SnakeAid',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Đăng nhập để tiếp tục',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.spacingLarge * 2),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'user@example.com',
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  enabled: !authState.isLoading,
                ),
                
                const SizedBox(height: AppTheme.spacingMedium),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Mật khẩu',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  validator: _validatePassword,
                  enabled: !authState.isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingSmall),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingMedium),
                
                // Login button
                CustomButton(
                  text: 'Đăng Nhập',
                  onPressed: authState.isLoading ? null : _handleLogin,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: AppTheme.spacingMedium),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/register');
                            },
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**✅ Screen Rules:**
1. Extend `ConsumerStatefulWidget` hoặc `ConsumerWidget`
2. Dispose tất cả controllers trong `dispose()`
3. Use `ref.watch()` để watch state
4. Use `ref.listen()` cho side effects (snackbar, navigation)
5. Validate forms trước khi submit
6. Dismiss keyboard sau submit
7. Show loading states
8. Handle error states
9. Use `AppTheme` constants
10. Extract complex widgets thành separate methods

**❌ Screen Anti-patterns:**
```dart
// ❌ Không dispose controllers
@override
void dispose() {
  // SAI - quên dispose
  super.dispose();
}

// ❌ Hard-code values
Container(
  padding: EdgeInsets.all(16.0), // SAI
  color: Color(0xFF4CAF50), // SAI
)

// ❌ Gọi async trong build
@override
Widget build(BuildContext context) {
  fetchData(); // SAI - async trong build
  return ...;
}

// ❌ Navigation trong build
@override
Widget build(BuildContext context) {
  if (isAuthenticated) {
    Navigator.pushNamed(context, '/home'); // SAI
  }
  return ...;
}
```

---

### **🧱 WIDGETS**

```dart
import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/app/theme.dart';

/// Custom text field widget following app theme
/// 
/// Wraps TextField with consistent styling and validation
class CustomTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController? controller;
  
  /// Label text shown above the field
  final String labelText;
  
  /// Hint text shown when field is empty
  final String? hintText;
  
  /// Icon shown at the start of the field
  final Widget? prefixIcon;
  
  /// Icon/widget shown at the end of the field
  final Widget? suffixIcon;
  
  /// Whether to obscure text (for passwords)
  final bool obscureText;
  
  /// Keyboard type
  final TextInputType? keyboardType;
  
  /// Text input action (next, done, etc.)
  final TextInputAction? textInputAction;
  
  /// Validation function
  final String? Function(String?)? validator;
  
  /// Callback when field is submitted
  final void Function(String)? onSubmitted;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Minimum number of lines
  final int? minLines;
  
  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: BorderSide(
            color: AppTheme.textSecondaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 2,
          ),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[200],
      ),
    );
  }
}
```

**✅ Widget Rules:**
1. Prefer `StatelessWidget` khi không cần local state
2. Tất cả parameters phải `final`
3. Use `const` constructors
4. Provide default values cho optional params
5. Document widget purpose và parameters
6. Use `AppTheme` constants
7. Handle enabled/disabled states
8. Make widgets configurable (don't hard-code)

**❌ Widget Anti-patterns:**
```dart
// ❌ Non-final fields
class CustomButton extends StatelessWidget {
  String text; // SAI - không final
}

// ❌ Hard-coded values
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF4CAF50), // SAI
    padding: EdgeInsets.all(16), // SAI
  ),
)

// ❌ Business logic trong widget
class UserCard extends StatelessWidget {
  Future<void> _deleteUser() async {
    await repository.deleteUser(); // SAI - logic trong widget
  }
}
```

---

## 🎨 THEME & STYLING

```dart
// ✅ LUÔN dùng AppTheme constants
import 'package:snakeaid_mobile/app/theme.dart';

// Colors
Container(color: AppTheme.primaryColor)
Text(style: TextStyle(color: AppTheme.textPrimaryColor))

// Spacing
Padding(padding: EdgeInsets.all(AppTheme.spacingMedium))
SizedBox(height: AppTheme.spacingLarge)

// Typography
Text(
  'Heading',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Border
BorderRadius.circular(AppTheme.borderRadius)
```

**❌ KHÔNG hard-code:**
```dart
// ❌ Hard-coded colors
Container(color: Color(0xFF4CAF50))
Container(color: Colors.green)

// ❌ Hard-coded spacing
Padding(padding: EdgeInsets.all(16.0))
SizedBox(height: 24)

// ❌ Hard-coded font sizes
Text(style: TextStyle(fontSize: 24))
```

---

## 📝 COMMENTS & DOCUMENTATION

```dart
/// Document public APIs với triple-slash comments
/// 
/// Sử dụng markdown formatting:
/// - Bullet points
/// - **Bold text**
/// - `code snippets`
/// 
/// Example:
/// ```dart
/// final user = await repository.getUser('123');
/// ```
class MyClass {
  /// Brief description
  /// 
  /// Detailed explanation if needed
  void myMethod() {}
}

// Single-line comments cho implementation details
// Explain WHY, not WHAT

/* 
 * Block comments cho complex logic
 * hoặc temporary disable code
 */
```

---

## ✅ FINAL CHECKLIST

### **Trước khi commit:**
- [ ] `flutter format .` - Format code
- [ ] `flutter analyze` - No errors/warnings
- [ ] Remove tất cả `debugPrint()` statements
- [ ] Remove tất cả TODO comments
- [ ] Dispose tất cả controllers
- [ ] No hard-coded values
- [ ] Proper error handling
- [ ] Form validation
- [ ] Test trên emulator

### **Code Quality:**
- [ ] Naming conventions đúng
- [ ] Imports organized
- [ ] Comments đầy đủ
- [ ] No unused variables/imports
- [ ] Proper null safety
- [ ] Use `const` where possible

---

**🎯 Mục tiêu:** Code nhất quán, dễ maintain, và scalable!
