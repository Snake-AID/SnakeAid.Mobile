# 📋 IMPLEMENTATION CHECKLIST - SNAKEAID MOBILE

> **MỤC ĐÍCH:** Đảm bảo không bỏ sót bất kỳ file hoặc function nào khi implement feature mới

---

## 🎯 QUY TRÌNH IMPLEMENT FEATURE MỚI

### **BƯỚC 1: PHÂN TÍCH YÊU CẦU**
- [ ] Đọc kỹ requirements/specs
- [ ] Xác định feature thuộc module nào: `auth`, `consultation`, `emergency`, `expert`, `payment`, `rescuer`, `snake_catching`, hoặc `shared`
- [ ] Liệt kê tất cả các models cần thiết
- [ ] Liệt kê tất cả các API endpoints cần call
- [ ] Liệt kê tất cả các screens/UI cần tạo
- [ ] Xác định dependencies với features khác

---

## 📂 CHECKLIST FILES THEO THỨ TỰ IMPLEMENT

### **1️⃣ MODELS** (`lib/features/{feature_name}/models/`)

**Checklist tạo file model:**
- [ ] Tạo file: `{model_name}.dart` (snake_case)
- [ ] Import packages:
  ```dart
  import 'package:json_annotation/json_annotation.dart';
  ```
- [ ] Khai báo part:
  ```dart
  part '{model_name}.g.dart';
  ```
- [ ] Tạo class với `@JsonSerializable()`
- [ ] Khai báo tất cả properties với `final`
- [ ] Tạo `const` constructor với named parameters
- [ ] Implement `fromJson()` factory
- [ ] Implement `toJson()` method
- [ ] Implement `copyWith()` method
- [ ] Implement `==` operator và `hashCode` (nếu cần so sánh)
- [ ] Chạy code generation:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

**Template Model:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? phoneNumber;
  
  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
```

---

### **2️⃣ REPOSITORY** (`lib/features/{feature_name}/repository/`)

**Checklist tạo repository:**
- [ ] Tạo file: `{feature_name}_repository.dart`
- [ ] Import dependencies:
  ```dart
  import 'package:dio/dio.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:snakeaid_mobile/core/providers/http_provider.dart';
  ```
- [ ] Import models cần thiết
- [ ] Tạo Provider cho repository:
  ```dart
  final {feature}RepositoryProvider = Provider<{Feature}Repository>((ref) {
    final httpService = ref.watch(httpServiceProvider);
    return {Feature}Repository(httpService: httpService);
  });
  ```
- [ ] Tạo class Repository với constructor nhận `HttpService`
- [ ] Implement methods cho từng API endpoint:
  - [ ] GET requests
  - [ ] POST requests
  - [ ] PUT requests
  - [ ] DELETE requests
- [ ] Implement `_handleError()` method
- [ ] Return domain models (không phải raw Response)

**Template Repository Method:**
```dart
Future<User> getUser(String userId) async {
  try {
    final response = await httpService.get('/users/$userId');
    return User.fromJson(response.data['user']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

Exception _handleError(DioException error) {
  if (error.response != null) {
    final message = error.response?.data['message'] ?? 'Unknown error';
    return Exception(message);
  } else {
    return Exception('Network error: ${error.message}');
  }
}
```

**Checklist API Endpoints:**
Với mỗi endpoint, đảm bảo có:
- [ ] Method name rõ ràng (getUser, createOrder, updateProfile...)
- [ ] Parameters với type annotation đầy đủ
- [ ] Try-catch block
- [ ] Return type chính xác
- [ ] Error handling

---

### **3️⃣ PROVIDERS (State Management)** (`lib/features/{feature_name}/providers/`)

**Checklist tạo provider:**
- [ ] Tạo file: `{feature_name}_provider.dart`
- [ ] Import Riverpod và repository
- [ ] Tạo State class:
  - [ ] Tất cả fields là `final`
  - [ ] Include: `isLoading`, `error`, data fields
  - [ ] Implement `copyWith()` method
  - [ ] Constructor với default values
- [ ] Tạo StateNotifier class:
  - [ ] Extend `StateNotifier<{State}>`
  - [ ] Constructor nhận repository và super với initial state
  - [ ] Implement methods cho mỗi action
- [ ] Tạo StateNotifierProvider
- [ ] Tạo computed providers (derived state) nếu cần

**Template State & Provider:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

// State class
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;
  
  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });
  
  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StateNotifier
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository userRepository;
  
  UserNotifier({required this.userRepository}) : super(const UserState());
  
  Future<void> fetchUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await userRepository.getUser(userId);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepository: userRepository);
});

// Computed providers
final isUserLoggedInProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.user != null;
});
```

**Checklist State Methods:**
- [ ] Mỗi method có pattern: set loading → try/catch → update state
- [ ] Set `error = null` khi bắt đầu action mới
- [ ] Set `isLoading = false` trong finally hoặc catch
- [ ] Handle cả success và error cases

---

### **4️⃣ WIDGETS** (`lib/features/{feature_name}/widgets/`)

**Checklist tạo reusable widget:**
- [ ] Tạo file: `{widget_name}.dart`
- [ ] Import Flutter và AppTheme
- [ ] Extend `StatelessWidget` (hoặc `StatefulWidget` nếu cần state)
- [ ] Tất cả parameters là `final`
- [ ] Sử dụng `const` constructor
- [ ] Provide default values cho optional parameters
- [ ] Sử dụng `AppTheme` constants thay vì hard-code
- [ ] Document public API với comments

**Template Widget:**
```dart
import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/app/theme.dart';

/// Custom card widget for displaying user information
class UserCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  
  const UserCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
```

**Checklist các loại widgets thường cần:**
- [ ] Form fields (text field, dropdown, checkbox...)
- [ ] Buttons (primary, secondary, text...)
- [ ] Cards (info card, list item...)
- [ ] Dialogs (confirm, alert, input...)
- [ ] Loading indicators
- [ ] Empty states
- [ ] Error states

---

### **5️⃣ SCREENS** (`lib/features/{feature_name}/screens/`)

**Checklist tạo screen:**
- [ ] Tạo file: `{screen_name}_screen.dart`
- [ ] Import Flutter, Riverpod, AppTheme
- [ ] Import providers và widgets cần thiết
- [ ] Extend `ConsumerStatefulWidget` hoặc `ConsumerWidget`
- [ ] Tạo `_formKey` nếu có form
- [ ] Tạo controllers cho text fields
- [ ] Override `dispose()` để dispose controllers
- [ ] Implement build method:
  - [ ] Watch providers cần thiết
  - [ ] Setup listeners (`ref.listen()`) cho side effects
  - [ ] Return Scaffold với AppBar
  - [ ] Wrap body trong SafeArea
  - [ ] Add padding với AppTheme constants
- [ ] Implement event handlers (onPressed, onSubmit...)
- [ ] Handle navigation
- [ ] Show loading states
- [ ] Show error messages

**Template Screen:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/app/theme.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const UserProfileScreen({
    super.key,
    required this.userId,
  });
  
  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchUser(widget.userId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    
    // Listen for errors
    ref.listen(userProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SafeArea(
        child: _buildBody(userState),
      ),
    );
  }
  
  Widget _buildBody(UserState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.user == null) {
      return const Center(child: Text('No user data'));
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          UserCard(
            title: state.user!.email,
            subtitle: state.user!.phoneNumber,
          ),
          // More widgets...
        ],
      ),
    );
  }
}
```

**Checklist Screen Components:**
- [ ] Loading state UI
- [ ] Error state UI
- [ ] Empty state UI
- [ ] Success state UI
- [ ] Form validation (nếu có form)
- [ ] Navigation logic
- [ ] Back button handling
- [ ] Keyboard dismiss on tap outside

---

## 🔄 CHECKLIST UPDATE EXISTING FILES

### **App Router** (`lib/app/router.dart`)
Khi thêm screen mới:
- [ ] Import screen mới
- [ ] Thêm route constant:
  ```dart
  static const String userProfile = '/user-profile';
  ```
- [ ] Thêm route vào `routes` map
- [ ] Implement navigation method:
  ```dart
  static void goToUserProfile(BuildContext context, String userId) {
    Navigator.pushNamed(context, userProfile, arguments: userId);
  }
  ```

### **Main App** (`lib/main.dart`)
Nếu cần khởi tạo global providers hoặc services:
- [ ] Import provider/service
- [ ] Wrap app trong `ProviderScope` nếu chưa có
- [ ] Add override nếu cần
- [ ] Initialize trong `main()` nếu cần

---

## 🧪 TESTING CHECKLIST

### **Unit Tests**
- [ ] Test models (fromJson, toJson, copyWith)
- [ ] Test repository methods
- [ ] Test provider state changes
- [ ] Test error handling

### **Widget Tests**
- [ ] Test widgets render correctly
- [ ] Test user interactions
- [ ] Test different states (loading, error, success)

### **Integration Tests**
- [ ] Test complete user flows
- [ ] Test navigation
- [ ] Test API integration

---

## ✅ FINAL CHECKLIST TRƯỚC KHI COMMIT

### **Code Quality**
- [ ] Không có hard-coded values (dùng AppTheme, constants)
- [ ] Không có TODO comments còn lại
- [ ] Dispose tất cả controllers và streams
- [ ] Handle tất cả error cases
- [ ] Validate tất cả user inputs
- [ ] Remove debug prints
- [ ] Format code: `flutter format .`
- [ ] Analyze code: `flutter analyze`

### **Files Created**
- [ ] Models: `{feature}/models/*.dart`
- [ ] Repository: `{feature}/repository/{feature}_repository.dart`
- [ ] Providers: `{feature}/providers/{feature}_provider.dart`
- [ ] Widgets: `{feature}/widgets/*.dart`
- [ ] Screens: `{feature}/screens/*_screen.dart`

### **Dependencies Updated**
- [ ] Update `pubspec.yaml` nếu thêm packages mới
- [ ] Chạy `flutter pub get`
- [ ] Update imports trong các files liên quan

### **Documentation**
- [ ] Comment public APIs
- [ ] Update README nếu cần
- [ ] Document complex logic
- [ ] Add screenshots/GIFs cho UI changes

### **Build & Run**
- [ ] Build thành công: `flutter build apk --debug`
- [ ] Không có warnings quan trọng
- [ ] Test trên emulator/device
- [ ] Test hot reload hoạt động
- [ ] Test dark mode (nếu có)

---

## 📝 TEMPLATE CHECKLIST CHO FEATURE MỚI

Copy template này cho mỗi feature mới:

```markdown
## Feature: [TÊN FEATURE]

### Planning
- [ ] Phân tích requirements
- [ ] Xác định models cần thiết: _______________
- [ ] Xác định API endpoints: _______________
- [ ] Xác định screens cần tạo: _______________
- [ ] Xác định widgets tái sử dụng: _______________

### Models (`lib/features/{feature}/models/`)
- [ ] `{model1}.dart` - [Mô tả]
- [ ] `{model2}.dart` - [Mô tả]
- [ ] Run code generation

### Repository (`lib/features/{feature}/repository/`)
- [ ] `{feature}_repository.dart`
- [ ] Method: `{method1}()` - [Endpoint]
- [ ] Method: `{method2}()` - [Endpoint]
- [ ] Error handling

### Providers (`lib/features/{feature}/providers/`)
- [ ] `{feature}_provider.dart`
- [ ] State class với copyWith()
- [ ] StateNotifier với methods
- [ ] Computed providers

### Widgets (`lib/features/{feature}/widgets/`)
- [ ] `{widget1}.dart` - [Mô tả]
- [ ] `{widget2}.dart` - [Mô tả]

### Screens (`lib/features/{feature}/screens/`)
- [ ] `{screen1}_screen.dart` - [Mô tả]
- [ ] `{screen2}_screen.dart` - [Mô tả]

### Integration
- [ ] Update router
- [ ] Update main.dart (nếu cần)
- [ ] Test navigation flow

### Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Manual testing

### Final
- [ ] Code review
- [ ] Format & Analyze
- [ ] Commit & Push
```

---

## 🚨 COMMON MISTAKES ĐỂ TRÁNH

### ❌ **KHÔNG NÊN:**
1. ❌ Hard-code colors, spacing, fonts
2. ❌ Sử dụng `print()` thay vì `debugPrint()`
3. ❌ Quên dispose controllers
4. ❌ Không handle error states
5. ❌ Không validate user input
6. ❌ Tạo provider mà không inject dependencies
7. ❌ Gọi async code trong `build()` method
8. ❌ Quên thêm `const` cho immutable widgets
9. ❌ Nested callbacks quá sâu (callback hell)
10. ❌ Mix business logic vào UI widgets

### ✅ **NÊN:**
1. ✅ Sử dụng AppTheme constants
2. ✅ Sử dụng `debugPrint()` và xóa trước khi commit
3. ✅ Always dispose trong `dispose()`
4. ✅ Show loading, error, và empty states
5. ✅ Validate tất cả inputs với validators
6. ✅ Inject dependencies qua constructor/provider
7. ✅ Sử dụng `initState()` hoặc `ref.listen()` cho async
8. ✅ Sử dụng `const` constructors khi có thể
9. ✅ Extract complex logic thành separate methods/classes
10. ✅ Separation of concerns: UI ↔ Logic ↔ Data

---

## 🔍 REVIEW CHECKLIST

Trước khi submit PR, review theo checklist này:

### **Architecture**
- [ ] Models immutable và có serialization
- [ ] Repository return domain models
- [ ] Providers manage state correctly
- [ ] UI separated from business logic

### **Code Style**
- [ ] Naming conventions consistent
- [ ] Imports organized properly
- [ ] No unused imports
- [ ] Proper indentation và formatting

### **Functionality**
- [ ] All user flows work end-to-end
- [ ] Error handling comprehensive
- [ ] Loading states shown
- [ ] Navigation works correctly

### **Performance**
- [ ] No unnecessary rebuilds
- [ ] Proper use of `const`
- [ ] Images optimized
- [ ] List views use builders

### **Accessibility**
- [ ] Proper contrast ratios
- [ ] Semantic labels
- [ ] Touch targets adequate size
- [ ] Keyboard navigation works

---

## 📚 QUICK REFERENCE

### **File Naming**
```
Models:      user.dart, snake_info.dart
Repository:  auth_repository.dart, payment_repository.dart
Providers:   auth_provider.dart, payment_provider.dart
Widgets:     custom_button.dart, user_card.dart
Screens:     login_screen.dart, home_screen.dart
```

### **Class Naming**
```
Models:      User, SnakeInfo, PaymentInfo
Repository:  AuthRepository, PaymentRepository
Providers:   AuthNotifier, PaymentNotifier
Widgets:     CustomButton, UserCard
Screens:     LoginScreen, HomeScreen
```

### **Provider Naming**
```
Providers:   authProvider, paymentProvider
Repository:  authRepositoryProvider, paymentRepositoryProvider
Services:    httpServiceProvider, fcmServiceProvider
```

---

**💡 TIP:** Print checklist này ra và tick ✅ khi implement để không bỏ sót!
