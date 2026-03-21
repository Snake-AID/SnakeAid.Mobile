import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakeaid_mobile/features/auth/providers/auth_provider.dart';

class LessonReadState {
  final Set<String> readIds;
  final Set<String> allKnownIds;

  const LessonReadState({
    this.readIds = const {},
    this.allKnownIds = const {},
  });

  /// True nếu có ít nhất một bài học trong danh sách đã biết mà chưa đọc.
  bool get hasUnread => allKnownIds.difference(readIds).isNotEmpty;

  bool isRead(String id) => readIds.contains(id);

  LessonReadState copyWith({
    Set<String>? readIds,
    Set<String>? allKnownIds,
  }) {
    return LessonReadState(
      readIds: readIds ?? this.readIds,
      allKnownIds: allKnownIds ?? this.allKnownIds,
    );
  }
}

class LessonReadNotifier extends StateNotifier<LessonReadState> {
  final String _userId;

  static const String _readKeyPrefix = 'lesson_read_';
  static const String _knownKeyPrefix = 'lesson_known_';

  LessonReadNotifier(this._userId) : super(const LessonReadState()) {
    _load();
  }

  String get _readKey => '$_readKeyPrefix$_userId';
  String get _knownKey => '$_knownKeyPrefix$_userId';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList(_readKey) ?? [];
    final knownList = prefs.getStringList(_knownKey) ?? [];
    state = LessonReadState(
      readIds: readList.toSet(),
      allKnownIds: knownList.toSet(),
    );
  }

  /// Đánh dấu bài học đã đọc và lưu vào SharedPreferences.
  Future<void> markAsRead(String lessonId) async {
    if (state.isRead(lessonId)) return;
    final newReadIds = {...state.readIds, lessonId};
    state = state.copyWith(readIds: newReadIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readKey, newReadIds.toList());
  }

  /// Cập nhật danh sách ID bài học đã biết (gọi sau khi fetch danh sách).
  Future<void> updateKnownIds(List<String> ids) async {
    final newKnown = ids.toSet();
    state = state.copyWith(allKnownIds: newKnown);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_knownKey, ids);
  }
}

/// Provider scoped theo userId — tự reset khi user thay đổi.
final lessonReadProvider =
    StateNotifierProvider<LessonReadNotifier, LessonReadState>((ref) {
  final userId = ref.watch(currentUserProvider)?.id ?? 'guest';
  return LessonReadNotifier(userId);
});
