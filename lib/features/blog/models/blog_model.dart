/// Blog status matching backend enum BlogStatus
enum BlogStatus {
  draft,          // 0
  pendingApproval, // 1
  published,      // 2
  rejected,       // 3
}

BlogStatus blogStatusFromInt(int v) => BlogStatus.values[v.clamp(0, 3)];
BlogStatus blogStatusFromString(dynamic v) {
  if (v is int) return blogStatusFromInt(v);
  switch (v?.toString()) {
    case 'Draft':           return BlogStatus.draft;
    case 'PendingApproval': return BlogStatus.pendingApproval;
    case 'Published':       return BlogStatus.published;
    case 'Rejected':        return BlogStatus.rejected;
    default:                return BlogStatus.draft;
  }
}

String blogStatusToString(BlogStatus s) => const {
  BlogStatus.draft:           'Draft',
  BlogStatus.pendingApproval: 'PendingApproval',
  BlogStatus.published:       'Published',
  BlogStatus.rejected:        'Rejected',
}[s]!;

String blogStatusLabel(BlogStatus s) => const {
  BlogStatus.draft:           'Bản nháp',
  BlogStatus.pendingApproval: 'Chờ duyệt',
  BlogStatus.published:       'Đã đăng',
  BlogStatus.rejected:        'Bị từ chối',
}[s]!;

/// Blog category matching backend enum BlogCategory
enum BlogCategory {
  snakeKnowledge, // 0
  snakeSpecies,   // 1
  snakeHealth,    // 2
  snakeFeeding,   // 3
  snakeHabitat,   // 4
  other,          // 5
}

BlogCategory blogCategoryFromInt(int v) => BlogCategory.values[v.clamp(0, 5)];
BlogCategory blogCategoryFromString(dynamic v) {
  if (v is int) return blogCategoryFromInt(v);
  switch (v?.toString()) {
    case 'SnakeKnowledge': return BlogCategory.snakeKnowledge;
    case 'SnakeSpecies':   return BlogCategory.snakeSpecies;
    case 'SnakeHealth':    return BlogCategory.snakeHealth;
    case 'SnakeFeeding':   return BlogCategory.snakeFeeding;
    case 'SnakeHabitat':   return BlogCategory.snakeHabitat;
    default:               return BlogCategory.other;
  }
}

String blogCategoryToString(BlogCategory c) => const {
  BlogCategory.snakeKnowledge: 'SnakeKnowledge',
  BlogCategory.snakeSpecies:   'SnakeSpecies',
  BlogCategory.snakeHealth:    'SnakeHealth',
  BlogCategory.snakeFeeding:   'SnakeFeeding',
  BlogCategory.snakeHabitat:   'SnakeHabitat',
  BlogCategory.other:          'Other',
}[c]!;

String blogCategoryLabel(BlogCategory c) => const {
  BlogCategory.snakeKnowledge: 'Kiến thức rắn',
  BlogCategory.snakeSpecies:   'Loài rắn',
  BlogCategory.snakeHealth:    'Sức khỏe rắn',
  BlogCategory.snakeFeeding:   'Nuôi rắn',
  BlogCategory.snakeHabitat:   'Môi trường sống',
  BlogCategory.other:          'Khác',
}[c]!;

/// Blog tag matching backend enum BlogTag
enum BlogTag {
  venomous,           // 0
  nonVenomous,        // 1
  safety,             // 2
  wildSnake,          // 3
  snakeCare,          // 4
  snakeBehavior,      // 5
  snakeIdentification,// 6
  snakeConservation,  // 7
  snakeMyths,         // 8
  other,              // 9
}

BlogTag blogTagFromInt(int v) {
  if (v < 0 || v >= BlogTag.values.length) return BlogTag.other;
  return BlogTag.values[v];
}
BlogTag blogTagFromString(dynamic v) {
  if (v is int) return blogTagFromInt(v);
  switch (v?.toString()) {
    case 'Venomous':           return BlogTag.venomous;
    case 'NonVenomous':        return BlogTag.nonVenomous;
    case 'Safety':             return BlogTag.safety;
    case 'WildSnake':          return BlogTag.wildSnake;
    case 'SnakeCare':          return BlogTag.snakeCare;
    case 'SnakeBehavior':      return BlogTag.snakeBehavior;
    case 'SnakeIdentification':return BlogTag.snakeIdentification;
    case 'SnakeConservation':  return BlogTag.snakeConservation;
    case 'SnakeMyths':         return BlogTag.snakeMyths;
    default:                   return BlogTag.other;
  }
}

String blogTagToString(BlogTag t) => const {
  BlogTag.venomous:           'Venomous',
  BlogTag.nonVenomous:        'NonVenomous',
  BlogTag.safety:             'Safety',
  BlogTag.wildSnake:          'WildSnake',
  BlogTag.snakeCare:          'SnakeCare',
  BlogTag.snakeBehavior:      'SnakeBehavior',
  BlogTag.snakeIdentification:'SnakeIdentification',
  BlogTag.snakeConservation:  'SnakeConservation',
  BlogTag.snakeMyths:         'SnakeMyths',
  BlogTag.other:              'Other',
}[t]!;

String blogTagLabel(BlogTag t) => const {
  BlogTag.venomous:           'Có độc',
  BlogTag.nonVenomous:        'Không độc',
  BlogTag.safety:             'An toàn',
  BlogTag.wildSnake:          'Rắn hoang dã',
  BlogTag.snakeCare:          'Chăm sóc rắn',
  BlogTag.snakeBehavior:      'Hành vi rắn',
  BlogTag.snakeIdentification:'Nhận dạng rắn',
  BlogTag.snakeConservation:  'Bảo tồn',
  BlogTag.snakeMyths:         'Lầm tưởng',
  BlogTag.other:              'Khác',
}[t]!;

/// Author summary embedded in blog response
class BlogAuthor {
  final String id;
  final String fullName;
  final String? avatarUrl;

  const BlogAuthor({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
    return BlogAuthor(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ??
          json['userName']?.toString() ??
          json['name']?.toString() ??
          'Tác giả',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

/// Blog model matching backend Blog entity
class BlogModel {
  final String id;
  final String authorId;
  final BlogAuthor? author;
  final String title;
  final String thumbnailUrl;
  final String content;
  final BlogCategory category;
  final List<BlogTag> tags;
  final int viewCount;
  final int likeCount;
  final int readingTime; // minutes
  final BlogStatus status;
  final String? rejectionReason;
  final List<String> likedViewer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BlogModel({
    required this.id,
    required this.authorId,
    this.author,
    required this.title,
    required this.thumbnailUrl,
    required this.content,
    required this.category,
    required this.tags,
    required this.viewCount,
    required this.likeCount,
    required this.readingTime,
    required this.status,
    this.rejectionReason,
    this.likedViewer = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // Parse tags
    final rawTags = json['tags'] as List? ?? [];
    final tags = rawTags.map((t) => blogTagFromString(t)).toList();

    // Parse author
    BlogAuthor? author;
    if (json['author'] is Map<String, dynamic>) {
      author = BlogAuthor.fromJson(json['author'] as Map<String, dynamic>);
    }

    return BlogModel(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      author: author,
      title: json['title']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: blogCategoryFromString(json['category']),
      tags: tags,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      readingTime: (json['readingTime'] as num?)?.toInt() ?? 1,
      status: blogStatusFromString(json['status']),
      rejectionReason: json['rejectionReason']?.toString(),
      likedViewer: (json['likedViewer'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'title': title,
    'content': content,
    'thumbnailUrl': thumbnailUrl,
    'status': blogStatusToString(status),
    'category': blogCategoryToString(category),
    'tags': tags.map(blogTagToString).toList(),
    'readingTime': readingTime,
  };

  /// True if the currently authenticated viewer has liked this blog.
  bool get isLikedByViewer => likedViewer.isNotEmpty;

  BlogModel copyWith({
    String? title,
    String? thumbnailUrl,
    String? content,
    BlogCategory? category,
    List<BlogTag>? tags,
    int? readingTime,
    BlogStatus? status,
    int? viewCount,
    int? likeCount,
    List<String>? likedViewer,
    String? rejectionReason,
  }) {
    return BlogModel(
      id: id,
      authorId: authorId,
      author: author,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      readingTime: readingTime ?? this.readingTime,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      likedViewer: likedViewer ?? this.likedViewer,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
