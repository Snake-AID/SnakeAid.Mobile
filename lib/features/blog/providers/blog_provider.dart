import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_model.dart';
import '../repository/blog_repository.dart';

// ---------------------------------------------------------------------------
// Shared Blog List State
// ---------------------------------------------------------------------------

class BlogListState {
  final List<BlogModel> blogs;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const BlogListState({
    this.blogs = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  BlogListState copyWith({
    List<BlogModel>? blogs,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return BlogListState(
      blogs: blogs ?? this.blogs,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<BlogModel> get filtered {
    if (searchQuery.isEmpty) return blogs;
    final q = searchQuery.toLowerCase();
    return blogs.where((b) => b.title.toLowerCase().contains(q)).toList();
  }
}

// ---------------------------------------------------------------------------
// Member – Published Blogs
// ---------------------------------------------------------------------------

final blogListProvider = StateNotifierProvider<BlogListNotifier, BlogListState>(
  (ref) {
    final repo = ref.watch(blogRepositoryProvider);
    return BlogListNotifier(repo);
  },
);

class BlogListNotifier extends StateNotifier<BlogListState> {
  final BlogRepository _repo;

  BlogListNotifier(this._repo) : super(const BlogListState()) {
    loadBlogs();
  }

  Future<void> loadBlogs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final blogs = await _repo.getBlogs(status: 'Published');
      state = state.copyWith(blogs: blogs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadBlogs();

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Optimistically toggle like and refresh
  Future<void> toggleLike(String id) async {
    final idx = state.blogs.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final blog = state.blogs[idx];
    final wasLiked = blog.isLikedByViewer;
    final updated = blog.copyWith(
      likedViewer: wasLiked ? [] : const ['liked'],
      likeCount: wasLiked ? blog.likeCount - 1 : blog.likeCount + 1,
    );
    final newList = [...state.blogs];
    newList[idx] = updated;
    state = state.copyWith(blogs: newList);
    try {
      await _repo.toggleLike(id, isCurrentlyLiked: wasLiked);
    } catch (_) {
      // rollback
      newList[idx] = blog;
      state = state.copyWith(blogs: List.from(newList));
    }
  }

  /// Sync like state from detail screen back to list (no API call)
  void syncLike({
    required String id,
    required bool isLiked,
    required int likeCount,
  }) {
    final idx = state.blogs.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final newList = [...state.blogs];
    newList[idx] = newList[idx].copyWith(
      likedViewer: isLiked ? const ['liked'] : [],
      likeCount: likeCount,
    );
    state = state.copyWith(blogs: newList);
  }
}

// ---------------------------------------------------------------------------
// Expert – Own Blogs (all statuses)
// ---------------------------------------------------------------------------

final expertBlogListProvider =
    StateNotifierProvider<ExpertBlogListNotifier, BlogListState>((ref) {
      final repo = ref.watch(blogRepositoryProvider);
      return ExpertBlogListNotifier(repo);
    });

class ExpertBlogListNotifier extends StateNotifier<BlogListState> {
  final BlogRepository _repo;

  ExpertBlogListNotifier(this._repo) : super(const BlogListState()) {
    loadBlogs();
  }

  Future<void> loadBlogs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final blogs = await _repo.getBlogs();
      state = state.copyWith(blogs: blogs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadBlogs();

  /// Delete a blog then refresh
  Future<void> deleteBlog(String id) async {
    await _repo.deleteBlog(id);
    await loadBlogs();
  }

  /// Promote Draft → PendingApproval via PUT
  Future<void> submitForApproval({required BlogModel blog}) async {
    await _repo.updateBlog(
      id: blog.id,
      title: blog.title,
      content: blog.content,
      thumbnailUrl: blog.thumbnailUrl,
      status: BlogStatus.pendingApproval,
      category: blog.category,
      tags: blog.tags,
      readingTime: blog.readingTime,
    );
    await loadBlogs();
  }
}

// ---------------------------------------------------------------------------
// Blog Detail
// ---------------------------------------------------------------------------

class BlogDetailState {
  final BlogModel? blog;
  final bool isLoading;
  final String? error;

  const BlogDetailState({this.blog, this.isLoading = false, this.error});

  BlogDetailState copyWith({
    BlogModel? blog,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BlogDetailState(
      blog: blog ?? this.blog,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final blogDetailProvider =
    StateNotifierProvider.family<BlogDetailNotifier, BlogDetailState, String>((
      ref,
      id,
    ) {
      final repo = ref.watch(blogRepositoryProvider);
      return BlogDetailNotifier(repo, id, ref);
    });

class BlogDetailNotifier extends StateNotifier<BlogDetailState> {
  final BlogRepository _repo;
  final String _id;
  final Ref _ref;

  BlogDetailNotifier(this._repo, this._id, this._ref)
    : super(const BlogDetailState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final blog = await _repo.getBlogById(_id);
      state = state.copyWith(blog: blog, isLoading: false);
      // increment view (non-critical, ignore errors)
      _repo.incrementView(_id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike() async {
    final blog = state.blog;
    if (blog == null) return;
    final wasLiked = blog.isLikedByViewer;
    // optimistic update
    state = state.copyWith(
      blog: blog.copyWith(
        likedViewer: wasLiked ? [] : const ['liked'],
        likeCount: wasLiked ? blog.likeCount - 1 : blog.likeCount + 1,
      ),
    );
    try {
      await _repo.toggleLike(_id, isCurrentlyLiked: wasLiked);
      // Sync like state back to the list so it reflects correctly when navigating back
      _ref
          .read(blogListProvider.notifier)
          .syncLike(
            id: _id,
            isLiked: !wasLiked,
            likeCount: wasLiked ? blog.likeCount - 1 : blog.likeCount + 1,
          );
    } catch (_) {
      // rollback
      state = state.copyWith(blog: blog);
    }
  }
}

// ---------------------------------------------------------------------------
// Blog Form (Create / Edit)
// ---------------------------------------------------------------------------

class BlogFormState {
  final bool isSaving; // saving as Draft
  final bool isSubmitting; // submitting for approval
  final String? error;
  final bool success;

  const BlogFormState({
    this.isSaving = false,
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  BlogFormState copyWith({
    bool? isSaving,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? success,
  }) {
    return BlogFormState(
      isSaving: isSaving ?? this.isSaving,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }
}

final blogFormProvider =
    StateNotifierProvider.autoDispose<BlogFormNotifier, BlogFormState>((ref) {
      final repo = ref.watch(blogRepositoryProvider);
      return BlogFormNotifier(repo);
    });

class BlogFormNotifier extends StateNotifier<BlogFormState> {
  final BlogRepository _repo;

  BlogFormNotifier(this._repo) : super(const BlogFormState());

  /// Save as Draft — create or update depending on whether [existingId] is provided
  Future<void> saveAsDraft({
    String? existingId,
    required String title,
    required String content,
    required String thumbnailUrl,
    required BlogCategory category,
    required List<BlogTag> tags,
    required int readingTime,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true, success: false);
    try {
      if (existingId != null) {
        await _repo.updateBlog(
          id: existingId,
          title: title,
          content: content,
          thumbnailUrl: thumbnailUrl,
          status: BlogStatus.draft,
          category: category,
          tags: tags,
          readingTime: readingTime,
        );
      } else {
        await _repo.createBlog(
          title: title,
          content: content,
          thumbnailUrl: thumbnailUrl,
          status: BlogStatus.draft,
          category: category,
          tags: tags,
          readingTime: readingTime,
        );
      }
      state = state.copyWith(isSaving: false, success: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  /// Submit for approval — create or update with PendingApproval status
  Future<void> submitForApproval({
    String? existingId,
    required String title,
    required String content,
    required String thumbnailUrl,
    required BlogCategory category,
    required List<BlogTag> tags,
    required int readingTime,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      success: false,
    );
    try {
      if (existingId != null) {
        await _repo.updateBlog(
          id: existingId,
          title: title,
          content: content,
          thumbnailUrl: thumbnailUrl,
          status: BlogStatus.pendingApproval,
          category: category,
          tags: tags,
          readingTime: readingTime,
        );
      } else {
        await _repo.createBlog(
          title: title,
          content: content,
          thumbnailUrl: thumbnailUrl,
          status: BlogStatus.pendingApproval,
          category: category,
          tags: tags,
          readingTime: readingTime,
        );
      }
      state = state.copyWith(isSubmitting: false, success: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  /// PATCH status only — Draft → PendingApproval (no content update)
  Future<void> promoteToApproval(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      success: false,
    );
    try {
      await _repo.updateStatus(id, BlogStatus.pendingApproval);
      state = state.copyWith(isSubmitting: false, success: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}
