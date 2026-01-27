# 🤖 AI AGENT IMPLEMENTATION RULES - SNAKEAID MOBILE

> **CRITICAL:** AI Agent MUST follow these rules for EVERY implementation task

---

## 🎯 MANDATORY PRE-IMPLEMENTATION CHECKLIST

Before starting ANY implementation, AI MUST:

1. ✅ **READ** complete task requirements
2. ✅ **IDENTIFY** which feature module this belongs to
3. ✅ **LIST** ALL files that need to be created/modified
4. ✅ **CONFIRM** with user if unclear about requirements
5. ✅ **PLAN** implementation order (Models → Repository → Providers → Widgets → Screens)
6. ✅ **CHECK** existing code to avoid duplication

---

## 📋 STEP-BY-STEP IMPLEMENTATION WORKFLOW

### **STEP 1: ANALYSIS & PLANNING**

**AI MUST:**
```markdown
1. Analyze requirements and respond with:
   - Feature name: [name]
   - Module: lib/features/[which_module]/
   - Files to create:
     - [ ] models/[file1].dart
     - [ ] models/[file2].dart
     - [ ] repository/[feature]_repository.dart
     - [ ] providers/[feature]_provider.dart
     - [ ] widgets/[widget1].dart
     - [ ] screens/[screen1]_screen.dart
   - Files to modify:
     - [ ] app/router.dart (if adding new screen)
     - [ ] main.dart (if adding global provider)
   - Dependencies needed: [list packages if any]

2. Ask user: "Xác nhận tôi sẽ tạo các files trên, có cần thay đổi gì không?"
```

**WAIT for user confirmation before proceeding!**

---

### **STEP 2: CREATE MODELS** (if needed)

**For EACH model, AI MUST:**

1. ✅ Create file: `lib/features/{feature}/models/{model_name}.dart`
2. ✅ Use this EXACT template:

```dart
import 'package:json_annotation/json_annotation.dart';

part '{model_name}.g.dart';

/// [Brief description of what this model represents]
@JsonSerializable()
class {ModelName} {
  /// [Description of field]
  final String id;
  
  /// [Description of field]
  final String name;
  
  /// [Description of optional field]
  final String? optionalField;
  
  const {ModelName}({
    required this.id,
    required this.name,
    this.optionalField,
  });
  
  factory {ModelName}.fromJson(Map<String, dynamic> json) => _${ModelName}FromJson(json);
  
  Map<String, dynamic> toJson() => _${ModelName}ToJson(this);
  
  {ModelName} copyWith({
    String? id,
    String? name,
    String? optionalField,
  }) {
    return {ModelName}(
      id: id ?? this.id,
      name: name ?? this.name,
      optionalField: optionalField ?? this.optionalField,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {ModelName} &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => '{ModelName}(id: $id, name: $name)';
}
```

3. ✅ Verify ALL fields are `final`
4. ✅ Verify has `fromJson`, `toJson`, `copyWith`
5. ✅ Add comments for public fields

**After creating models:**
```markdown
Created models:
- ✅ {model1}.dart
- ✅ {model2}.dart

Next: Run code generation with:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Proceed to Repository?
```

---

### **STEP 3: CREATE REPOSITORY**

**AI MUST:**

1. ✅ Create file: `lib/features/{feature}/repository/{feature}_repository.dart`
2. ✅ Use this EXACT structure:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/providers/http_provider.dart';
import 'package:snakeaid_mobile/core/services/http_service.dart';
import '../models/{model}.dart';

/// Provider for {Feature}Repository
final {feature}RepositoryProvider = Provider<{Feature}Repository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return {Feature}Repository(httpService: httpService);
});

/// Repository for {feature} related API calls
/// 
/// Handles [list main responsibilities]
class {Feature}Repository {
  final HttpService httpService;
  
  {Feature}Repository({required this.httpService});
  
  /// [Method description]
  /// 
  /// Returns [{ReturnType}]
  /// Throws [Exception] on failure
  Future<{ReturnType}> {methodName}({
    required String param1,
  }) async {
    try {
      debugPrint('🔍 {Action}: $param1');
      
      final response = await httpService.{method}(
        '/api/{endpoint}',
        data: {
          'param1': param1,
        },
      );
      
      debugPrint('✅ {Action} successful');
      return {ReturnType}.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ {Action} failed: ${e.message}');
      throw _handleError(e);
    }
  }
  
  /// Handle DioException and convert to meaningful error
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      String message = 'Đã xảy ra lỗi không mong muốn';
      
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      }
      
      switch (statusCode) {
        case 400:
          message = data['message'] ?? 'Dữ liệu không hợp lệ';
          break;
        case 401:
          message = 'Unauthorized';
          break;
        case 403:
          message = 'Bạn không có quyền thực hiện thao tác này';
          break;
        case 404:
          message = 'Không tìm thấy tài nguyên';
          break;
        case 500:
          message = 'Lỗi server, vui lòng thử lại sau';
          break;
      }
      
      return Exception(message);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Kết nối timeout, vui lòng kiểm tra mạng');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('Không thể kết nối đến server');
    }
    return Exception('Lỗi mạng: ${error.message}');
  }
}
```

3. ✅ Verify EACH method has:
   - Try-catch block
   - debugPrint for logging
   - Proper error handling
   - Returns domain model (not Response)

**After creating repository:**
```markdown
Created repository:
- ✅ {feature}_repository.dart with {X} methods:
  - {method1}() - {endpoint}
  - {method2}() - {endpoint}

Proceed to Provider?
```

---

### **STEP 4: CREATE PROVIDER (State Management)**

**AI MUST:**

1. ✅ Create file: `lib/features/{feature}/providers/{feature}_provider.dart`
2. ✅ Use this EXACT structure:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/{model}.dart';
import '../repository/{feature}_repository.dart';

// ==================== STATE CLASS ====================

/// State for {feature}
class {Feature}State {
  /// [Description of data]
  final {DataType}? data;
  
  /// Whether an operation is in progress
  final bool isLoading;
  
  /// Error message if operation failed
  final String? error;
  
  const {Feature}State({
    this.data,
    this.isLoading = false,
    this.error,
  });
  
  /// Creates a copy with modified fields
  {Feature}State copyWith({
    {DataType}? data,
    bool? isLoading,
    String? error,
  }) {
    return {Feature}State(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  /// Reset state
  factory {Feature}State.initial() => const {Feature}State();
  
  @override
  String toString() => 
      '{Feature}State(data: $data, isLoading: $isLoading, error: $error)';
}

// ==================== NOTIFIER CLASS ====================

/// Manages {feature} state and operations
class {Feature}Notifier extends StateNotifier<{Feature}State> {
  final {Feature}Repository repository;
  
  {Feature}Notifier({required this.repository}) : super(const {Feature}State());
  
  /// [Method description]
  Future<void> {methodName}({required String param}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await repository.{methodName}(param: param);
      state = state.copyWith(data: result, isLoading: false);
      debugPrint('✅ {Action} successful');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      debugPrint('❌ {Action} error: $e');
    }
  }
  
  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Reset state
  void reset() {
    state = {Feature}State.initial();
  }
}

// ==================== PROVIDERS ====================

/// Main {feature} provider
final {feature}Provider = StateNotifierProvider<{Feature}Notifier, {Feature}State>((ref) {
  final repository = ref.watch({feature}RepositoryProvider);
  return {Feature}Notifier(repository: repository);
});

/// Computed: [Description]
final {computed}Provider = Provider<bool>((ref) {
  final state = ref.watch({feature}Provider);
  return state.data != null;
});
```

3. ✅ Verify:
   - State has `isLoading`, `error`, data fields
   - State has `copyWith()` and `initial()`
   - EVERY method sets `isLoading = true` first
   - EVERY method sets `error = null` when starting
   - EVERY method has try-catch
   - Has `clearError()` method

**After creating provider:**
```markdown
Created provider:
- ✅ {feature}_provider.dart
  - State: {Feature}State with copyWith()
  - Notifier: {X} methods
  - Computed providers: {Y}

Proceed to Widgets?
```

---

### **STEP 5: CREATE WIDGETS** (if needed)

**For EACH widget, AI MUST:**

1. ✅ Create file: `lib/features/{feature}/widgets/{widget_name}.dart`
2. ✅ Use this template:

```dart
import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/app/theme.dart';

/// [Widget description and usage]
class {WidgetName} extends StatelessWidget {
  /// [Field description]
  final String title;
  
  /// [Field description]
  final VoidCallback? onTap;
  
  const {WidgetName}({
    super.key,
    required this.title,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
```

3. ✅ Verify:
   - ALL parameters are `final`
   - Uses `const` constructor
   - Uses `AppTheme` constants (NO hard-coded values)
   - Has documentation comments

---

### **STEP 6: CREATE SCREENS**

**For EACH screen, AI MUST:**

1. ✅ Create file: `lib/features/{feature}/screens/{screen_name}_screen.dart`
2. ✅ Use this EXACT template:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/app/theme.dart';
import '../providers/{feature}_provider.dart';
import '../widgets/{widget}.dart';

/// [Screen description and purpose]
class {Screen}Screen extends ConsumerStatefulWidget {
  const {Screen}Screen({super.key});
  
  @override
  ConsumerState<{Screen}Screen> createState() => _{Screen}ScreenState();
}

class _{Screen}ScreenState extends ConsumerState<{Screen}Screen> {
  // Controllers (if needed)
  final _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read({feature}Provider.notifier).fetchData();
    });
  }
  
  @override
  void dispose() {
    // CRITICAL: Dispose controllers
    _textController.dispose();
    super.dispose();
  }
  
  /// Handle action
  Future<void> _handleAction() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Call provider
    await ref.read({feature}Provider.notifier).doAction();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch({feature}Provider);
    
    // Listen for side effects
    ref.listen<{Feature}State>({feature}Provider, (previous, next) {
      // Show error
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        ref.read({feature}Provider.notifier).clearError();
      }
      
      // Navigate on success (if needed)
      if (next.data != null && previous?.data == null) {
        // Navigator.pushNamed(context, '/next-screen');
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('{Screen Title}'),
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }
  
  Widget _buildBody({Feature}State state) {
    // Loading state
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Empty state
    if (state.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Không có dữ liệu',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    // Content
    return SingleChildScrollView(
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

3. ✅ Verify screen has:
   - `ConsumerStatefulWidget` or `ConsumerWidget`
   - `dispose()` method disposing ALL controllers
   - `ref.watch()` for state
   - `ref.listen()` for side effects
   - Loading state UI
   - Empty state UI (if applicable)
   - Error handling with SnackBar
   - Uses `AppTheme` constants
   - `SafeArea` wrapper

---

### **STEP 7: UPDATE ROUTER** (if adding new screen)

**AI MUST:**

1. ✅ Open: `lib/app/router.dart`
2. ✅ Add route constant:
```dart
static const String {screenName} = '/{screen-name}';
```
3. ✅ Add to routes map
4. ✅ Add navigation helper method if needed

**Report:**
```markdown
Updated router:
- ✅ Added route: /{screen-name}
- ✅ Added navigation helper: goTo{Screen}()
```

---

## 🚨 MANDATORY VALIDATION RULES

### **Before submitting implementation, AI MUST check:**

#### **Models:**
- [ ] All fields are `final`
- [ ] Has `@JsonSerializable()`
- [ ] Has `fromJson()` and `toJson()`
- [ ] Has `copyWith()` method
- [ ] Has `==` operator and `hashCode`
- [ ] Has documentation comments
- [ ] No business logic in model

#### **Repository:**
- [ ] Injects `HttpService` via constructor
- [ ] Has provider declaration
- [ ] All methods are `async` with `Future<T>`
- [ ] All methods have try-catch
- [ ] Returns domain models (not Response)
- [ ] Has `_handleError()` method
- [ ] Has `debugPrint` for logging
- [ ] Error messages in Vietnamese

#### **Provider:**
- [ ] State class has `isLoading` and `error`
- [ ] State has `copyWith()` method
- [ ] Every method sets `isLoading = true` first
- [ ] Every method sets `error = null` at start
- [ ] Every method has try-catch
- [ ] Has `clearError()` method
- [ ] Has computed providers for derived state
- [ ] No UI code in provider

#### **Widgets:**
- [ ] All parameters are `final`
- [ ] Uses `const` constructor
- [ ] Uses `AppTheme` constants (NO hard-coded values)
- [ ] Has documentation comments
- [ ] Stateless when possible

#### **Screens:**
- [ ] Extends `ConsumerStatefulWidget` or `ConsumerWidget`
- [ ] Has `dispose()` method
- [ ] Disposes ALL controllers
- [ ] Uses `ref.watch()` for state
- [ ] Uses `ref.listen()` for side effects
- [ ] Shows loading state
- [ ] Shows empty state (if applicable)
- [ ] Shows error with SnackBar
- [ ] Uses `AppTheme` constants
- [ ] Wrapped in `SafeArea`
- [ ] Dismisses keyboard on submit

---

## ❌ FORBIDDEN ACTIONS

**AI MUST NEVER:**

1. ❌ Hard-code colors, spacing, fonts
   ```dart
   // WRONG
   Container(color: Color(0xFF4CAF50))
   Padding(padding: EdgeInsets.all(16.0))
   
   // CORRECT
   Container(color: AppTheme.primaryColor)
   Padding(padding: EdgeInsets.all(AppTheme.spacingMedium))
   ```

2. ❌ Use `print()` instead of `debugPrint()`
   ```dart
   // WRONG
   print('Hello');
   
   // CORRECT
   debugPrint('🔍 Hello');
   ```

3. ❌ Forget to dispose controllers
   ```dart
   // WRONG - missing dispose
   
   // CORRECT
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

4. ❌ Make mutable state
   ```dart
   // WRONG
   class MyState {
     String data; // Not final!
   }
   
   // CORRECT
   class MyState {
     final String data;
   }
   ```

5. ❌ Skip error handling
   ```dart
   // WRONG
   Future<User> getUser() async {
     final response = await httpService.get('/user');
     return User.fromJson(response.data);
   }
   
   // CORRECT
   Future<User> getUser() async {
     try {
       final response = await httpService.get('/user');
       return User.fromJson(response.data);
     } on DioException catch (e) {
       throw _handleError(e);
     }
   }
   ```

6. ❌ Put business logic in UI
   ```dart
   // WRONG - calculation in build()
   Widget build(BuildContext context) {
     final total = items.fold(0, (sum, item) => sum + item.price);
     return Text('$total');
   }
   
   // CORRECT - calculation in provider
   ```

7. ❌ Call async in build()
   ```dart
   // WRONG
   Widget build(BuildContext context) {
     fetchData(); // Async call!
     return ...;
   }
   
   // CORRECT - use initState or ref.listen
   ```

8. ❌ Skip loading states
   ```dart
   // WRONG - no loading indicator
   
   // CORRECT
   if (state.isLoading) {
     return const Center(child: CircularProgressIndicator());
   }
   ```

---

## 📝 AI RESPONSE TEMPLATE

**After completing implementation, AI MUST respond with:**

```markdown
## ✅ Implementation Complete: {Feature Name}

### 📁 Files Created:
1. ✅ models/{model1}.dart - {Description}
2. ✅ models/{model2}.dart - {Description}
3. ✅ repository/{feature}_repository.dart - {X} API methods
4. ✅ providers/{feature}_provider.dart - State management
5. ✅ widgets/{widget1}.dart - {Description}
6. ✅ screens/{screen1}_screen.dart - {Description}

### 📝 Files Modified:
1. ✅ app/router.dart - Added route /{screen-name}

### 🔧 Next Steps:
1. Run code generation (for models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Test the implementation:
   ```bash
   flutter run
   ```

3. Verify:
   - [ ] UI displays correctly
   - [ ] Loading states work
   - [ ] Error handling works
   - [ ] Navigation works
   - [ ] Data persists (if applicable)

### 📋 Validation Checklist:
- ✅ All models have serialization
- ✅ Repository handles errors
- ✅ Provider has loading/error states
- ✅ Screen disposes controllers
- ✅ Uses AppTheme constants
- ✅ No hard-coded values
- ✅ Vietnamese error messages
- ✅ Documentation comments added

Would you like me to:
- Add more features?
- Add tests?
- Fix any issues?
```

---

## 🎯 QUICK VALIDATION CHECKLIST

Before saying "done", AI MUST verify:

### **Code Quality:**
- [ ] No hard-coded colors/spacing/fonts
- [ ] All imports organized correctly
- [ ] All fields properly typed
- [ ] All async operations handled
- [ ] All controllers disposed

### **Functionality:**
- [ ] Loading states implemented
- [ ] Error handling implemented
- [ ] Empty states implemented (if applicable)
- [ ] Validation implemented (if forms)
- [ ] Navigation works

### **Documentation:**
- [ ] Classes documented
- [ ] Public methods documented
- [ ] Complex logic explained
- [ ] TODO comments removed

### **Best Practices:**
- [ ] Follows feature-based architecture
- [ ] Separation of concerns maintained
- [ ] Immutable state pattern used
- [ ] Provider pattern used correctly
- [ ] No memory leaks (dispose called)

---

## 🔄 ITERATIVE IMPLEMENTATION

**If task is large, AI MUST:**

1. Break into smaller chunks
2. Implement one chunk at a time
3. Report progress after each chunk
4. Ask user before proceeding to next chunk

Example:
```markdown
Task is large. I'll break it into:
1. Models & Repository (API layer)
2. State Management (Providers)
3. UI Components (Widgets)
4. Screens & Navigation

Shall I start with Models & Repository?
```

---

## 📚 REFERENCE DURING IMPLEMENTATION

**AI MUST reference these files:**

1. `Coding-Standards.md` - For naming, structure, patterns
2. `Implementation-Checklist.md` - For complete checklist
3. `Quick-Reference.md` - For code templates
4. Existing code in `lib/core/` - For service usage
5. Existing code in `lib/app/theme.dart` - For styling

---

## 🚀 FINAL REMINDER

**BEFORE marking task as complete:**

1. ✅ Double-check ALL validation rules
2. ✅ Ensure NO hard-coded values
3. ✅ Verify ALL error cases handled
4. ✅ Confirm ALL controllers disposed
5. ✅ Test mental walkthrough of user flow
6. ✅ Provide clear next steps to user

**Quality over speed. Complete implementation over partial.**

---

**💡 This is a BINDING contract for AI implementation. Follow EVERY rule, EVERY time.**
