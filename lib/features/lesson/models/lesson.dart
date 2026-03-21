class LessonData {
  final String id;
  final String title;
  final String content;
  final String category;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonData({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    return LessonData(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      isPublished: json['isPublished'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Extracts the first YouTube URL found in [content], or null.
  String? get youtubeUrl {
    final pattern = RegExp(
      r'https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)[\w\-]+',
    );
    final match = pattern.firstMatch(content);
    return match?.group(0);
  }

  /// Returns [content] with YouTube URLs stripped out (for display).
  String get cleanContent {
    final pattern = RegExp(r'https?://\S+');
    return content.replaceAll(pattern, '').trim();
  }
}

class LessonListResponse {
  final bool isSuccess;
  final String message;
  final List<LessonData> data;

  const LessonListResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  factory LessonListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<LessonData> items = [];
    if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map(LessonData.fromJson)
          .toList();
    }
    return LessonListResponse(
      isSuccess: (json['isSuccess'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: items,
    );
  }
}

class LessonResponse {
  final bool isSuccess;
  final String message;
  final LessonData? data;

  const LessonResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      isSuccess: (json['isSuccess'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: json['data'] != null
          ? LessonData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
