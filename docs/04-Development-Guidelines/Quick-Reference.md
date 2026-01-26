# 📖 Quick Reference Guide - SnakeAid Mobile

> Tham khảo nhanh khi implement code

---

## 📂 CẤU TRÚC FILE

### Tạo Feature Mới
```
lib/features/{feature_name}/
├── models/
│   └── {model_name}.dart
├── providers/
│   └── {feature}_provider.dart
├── repository/
│   └── {feature}_repository.dart
├── screens/
│   └── {screen_name}_screen.dart
└── widgets/
    └── {widget_name}.dart
```

---

## 🏗️ CODE TEMPLATES

### 1. Model Template

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? optionalField;
  
  const User({
    required this.id,
    required this.email,
    this.optionalField,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  User copyWith({
    String? id,
    String? email,
    String? optionalField,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      optionalField: optionalField ?? this.optionalField,
    );
  }
}

// Chạy: flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Repository Template

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/providers/http_provider.dart';

final myRepositoryProvider = Provider<MyRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return MyRepository(httpService: httpService);
});

class MyRepository {
  final HttpService httpService;
  
  MyRepository({required this.httpService});
  
  Future<MyModel> getData() async {
    try {
      final response = await httpService.get('/endpoint');
      return MyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 'Unknown error';
      return Exception(message);
    }
    return Exception('Network error: ${error.message}');
  }
}
```

### 3. Provider Template

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/my_repository.dart';

// State
class MyState {
  final dynamic data;
  final bool isLoading;
  final String? error;
  
  const MyState({
    this.data,
    this.isLoading = false,
    this.error,
  });
  
  MyState copyWith({
    dynamic data,
    bool? isLoading,
    String? error,
  }) {
    return MyState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier
class MyNotifier extends StateNotifier<MyState> {
  final MyRepository repository;
  
  MyNotifier({required this.repository}) : super(const MyState());
  
  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final data = await repository.getData();
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  final repository = ref.watch(myRepositoryProvider);
  return MyNotifier(repository: repository);
});
```

### 4. Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/app/theme.dart';
import '../providers/my_provider.dart';

class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});
  
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myProvider.notifier).fetchData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myProvider);
    
    ref.listen(myProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Screen'),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(state),
      ),
    );
  }
  
  Widget _buildContent(MyState state) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          // Content here
        ],
      ),
    );
  }
}
```

### 5. Widget Template

```dart
import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/app/theme.dart';

class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  
  const CustomWidget({
    super.key,
    required this.title,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
```

---

## 🎨 COMMON UI PATTERNS

### Loading State
```dart
Widget build(BuildContext context) {
  final state = ref.watch(myProvider);
  
  if (state.isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  return _buildContent();
}
```

### Error Handling
```dart
// In build method
ref.listen(myProvider, (previous, next) {
  if (next.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next.error!),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
});
```

### Form Validation
```dart
final _formKey = GlobalKey<FormState>();

TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Vui lòng nhập giá trị';
    }
    return null;
  },
)

// On submit
if (_formKey.currentState!.validate()) {
  // Process form
}
```

### Navigation
```dart
// Push
Navigator.pushNamed(context, '/route-name');

// Push with arguments
Navigator.pushNamed(
  context,
  '/route-name',
  arguments: {'id': '123'},
);

// Replace
Navigator.pushReplacementNamed(context, '/route-name');

// Pop
Navigator.pop(context);
```

### Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Title'),
    content: const Text('Content'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Action
          Navigator.pop(context);
        },
        child: const Text('OK'),
      ),
    ],
  ),
);
```

### Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: const EdgeInsets.all(AppTheme.spacingMedium),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Content
      ],
    ),
  ),
);
```

---

## 🔧 COMMON VALIDATIONS

### Email
```dart
String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Vui lòng nhập email';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value!)) {
    return 'Email không hợp lệ';
  }
  return null;
}
```

### Password
```dart
String? validatePassword(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Vui lòng nhập mật khẩu';
  }
  if (value!.length < 6) {
    return 'Mật khẩu phải có ít nhất 6 ký tự';
  }
  return null;
}
```

### Phone Number
```dart
String? validatePhone(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Vui lòng nhập số điện thoại';
  }
  final phoneRegex = RegExp(r'^[0-9]{10}$');
  if (!phoneRegex.hasMatch(value!)) {
    return 'Số điện thoại không hợp lệ';
  }
  return null;
}
```

### Required Field
```dart
String? validateRequired(String? value, String fieldName) {
  if (value?.isEmpty ?? true) {
    return 'Vui lòng nhập $fieldName';
  }
  return null;
}
```

---

## 🎨 THEME USAGE

### Colors
```dart
// Primary
AppTheme.primaryColor
AppTheme.primaryVariant
AppTheme.secondaryColor

// Background
AppTheme.backgroundColor
AppTheme.surfaceColor

// Text
AppTheme.textPrimaryColor
AppTheme.textSecondaryColor

// Error
AppTheme.errorColor
```

### Spacing
```dart
AppTheme.spacingSmall    // 8.0
AppTheme.spacingMedium   // 16.0
AppTheme.spacingLarge    // 24.0
```

### Typography
```dart
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.headlineMedium
Theme.of(context).textTheme.bodyLarge
Theme.of(context).textTheme.bodyMedium
Theme.of(context).textTheme.labelSmall
```

### Border & Radius
```dart
BorderRadius.circular(AppTheme.borderRadius)  // 8.0
```

---

## 🚀 COMMON COMMANDS

### Code Generation
```bash
# Models (json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Format & Analyze
```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Fix issues
dart fix --apply
```

### Build & Run
```bash
# Run debug
flutter run

# Run release
flutter run --release

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

### Clean
```bash
flutter clean
flutter pub get
```

---

## 📋 IMPLEMENTATION WORKFLOW

### Bước 1: Planning
- [ ] Đọc requirements
- [ ] Xác định models
- [ ] Xác định API endpoints
- [ ] Xác định screens
- [ ] Sketch UI flow

### Bước 2: Models
- [ ] Create model files
- [ ] Add json_serializable
- [ ] Run code generation
- [ ] Test serialization

### Bước 3: Repository
- [ ] Create repository file
- [ ] Implement API methods
- [ ] Add error handling
- [ ] Create provider

### Bước 4: State Management
- [ ] Create state class
- [ ] Create notifier
- [ ] Create provider
- [ ] Add computed providers

### Bước 5: UI - Widgets
- [ ] Create reusable widgets
- [ ] Use AppTheme
- [ ] Add documentation

### Bước 6: UI - Screens
- [ ] Create screen files
- [ ] Wire up providers
- [ ] Add validation
- [ ] Handle states

### Bước 7: Integration
- [ ] Update router
- [ ] Test navigation
- [ ] Test full flow

### Bước 8: Polish
- [ ] Format code
- [ ] Remove debug prints
- [ ] Add comments
- [ ] Test thoroughly

---

## ⚡ DEBUGGING TIPS

### Print Debugging
```dart
debugPrint('🔍 Variable: $value');
debugPrint('✅ Success');
debugPrint('❌ Error: $error');
debugPrint('📱 Device info');
debugPrint('🔐 Auth token');
```

### Provider Debugging
```dart
// Add logger
ref.listen(myProvider, (previous, next) {
  debugPrint('State changed: $previous -> $next');
});
```

### Network Debugging
```dart
// In http_service.dart - already has interceptors
// Check console for REQUEST/RESPONSE logs
```

---

## 🔥 COMMON ISSUES & SOLUTIONS

### Issue: "Bad state: No ProviderScope found"
**Solution:** Wrap app in ProviderScope
```dart
runApp(
  const ProviderScope(
    child: MyApp(),
  ),
);
```

### Issue: Controllers not disposed
**Solution:** Always dispose in dispose()
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### Issue: setState after dispose
**Solution:** Check mounted
```dart
if (mounted) {
  setState(() {});
}
```

### Issue: "A build function returned null"
**Solution:** Always return a widget
```dart
Widget build(BuildContext context) {
  return const SizedBox.shrink(); // Empty widget
}
```

---

## 📚 USEFUL SNIPPETS

### Singleton Pattern
```dart
class MyService {
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
}
```

### Debounce Search
```dart
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    // Perform search
  });
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}
```

### Safe Parse Int
```dart
int? parseInt(String? value) {
  if (value == null) return null;
  return int.tryParse(value);
}
```

### Format DateTime
```dart
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}
```

---

## ✅ COMMIT CHECKLIST

Trước khi commit:
- [ ] `flutter format .`
- [ ] `flutter analyze` (no errors)
- [ ] Remove all `debugPrint()`
- [ ] Remove all TODOs
- [ ] Test on emulator
- [ ] Review changes

---

**💡 Lưu file này để tham khảo nhanh khi code!**
