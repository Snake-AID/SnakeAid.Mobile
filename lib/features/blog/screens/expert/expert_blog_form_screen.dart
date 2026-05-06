import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/blog_model.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/blog_rich_content_view.dart';

/// Create or edit a blog post.
/// Pass [existingBlog] via `extra` when editing.
class ExpertBlogFormScreen extends ConsumerStatefulWidget {
  final BlogModel? existingBlog;

  const ExpertBlogFormScreen({super.key, this.existingBlog});

  @override
  ConsumerState<ExpertBlogFormScreen> createState() =>
      _ExpertBlogFormScreenState();
}

class _ExpertBlogFormScreenState extends ConsumerState<ExpertBlogFormScreen> {
  static const _purple = Color(0xFF6C47C2);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _thumbnailCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _readingTimeCtrl;

  late BlogCategory _category;
  late Set<BlogTag> _selectedTags;

  bool _isPreviewMode = false;

  bool get _isEditing => widget.existingBlog != null;
  bool get _isDraft => widget.existingBlog?.status == BlogStatus.draft;
  bool get _isPublished => widget.existingBlog?.status == BlogStatus.published;
  bool get _isReadOnly => _isPublished;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBlog;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _thumbnailCtrl = TextEditingController(text: b?.thumbnailUrl ?? '');
    _contentCtrl = TextEditingController(text: b?.content ?? '');
    _readingTimeCtrl = TextEditingController(
      text: b?.readingTime.toString() ?? '5',
    );
    _category = b?.category ?? BlogCategory.snakeKnowledge;
    _selectedTags = b != null ? {...b.tags} : {};
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _thumbnailCtrl.dispose();
    _contentCtrl.dispose();
    _readingTimeCtrl.dispose();
    super.dispose();
  }

  /// Insert [before] at cursor; if [after] is given, wrap selection/cursor.
  void _insertAtCursor(String before, {String? after}) {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final selected = text.substring(start, end);
    final inserted = after != null
        ? '$before$selected$after'
        : '$before$selected';
    final newText = text.replaceRange(start, end, inserted);
    // Place cursor between markers when no selection was present
    final cursorOffset = (after != null && selected.isEmpty)
        ? start + before.length
        : start + inserted.length;
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(blogFormProvider);
    final notifier = ref.read(blogFormProvider.notifier);

    // Listen for success
    ref.listen<BlogFormState>(blogFormProvider, (prev, next) {
      if (!next.success) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.isSaving
                  ? 'Đã lưu bản nháp'
                  : 'Bài viết đã được gửi để duyệt',
            ),
            backgroundColor: _purple,
          ),
        );
        context.pop();
      }
    });

    final isBusy = formState.isSaving || formState.isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        title: Text(
          _isPublished
              ? 'Xem bài viết'
              : (_isEditing ? 'Chỉnh sửa bài viết' : 'Viết bài mới'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Read-only banner for Published blogs
            if (_isReadOnly)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bài viết đã được đăng. Không thể chỉnh sửa.',
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Error banner
            if (formState.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  formState.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            _SectionLabel(label: 'Tiêu đề *'),
            _buildField(
              controller: _titleCtrl,
              hint: 'Nhập tiêu đề bài viết',
              maxLines: 2,
              readOnly: _isReadOnly,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập tiêu đề'
                  : null,
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'URL ảnh bìa *'),
            _buildField(
              controller: _thumbnailCtrl,
              hint: 'https://...',
              keyboardType: TextInputType.url,
              readOnly: _isReadOnly,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập URL ảnh bìa'
                  : null,
            ),
            const SizedBox(height: 16),

            // Thumbnail preview
            if (_thumbnailCtrl.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _thumbnailCtrl.text.trim(),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text(
                        'Không tải được ảnh',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Danh mục'),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Tags'),
            _buildTagChips(),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Thời gian đọc (phút) *'),
            _buildField(
              controller: _readingTimeCtrl,
              hint: '5',
              keyboardType: TextInputType.number,
              readOnly: _isReadOnly,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập';
                final n = int.tryParse(v.trim());
                if (n == null || n < 1) return 'Phải là số nguyên dương';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Nội dung *'),
            _buildContentEditor(),

            // Bottom padding so FAB doesn't cover last field
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom action bar — hidden when blog is Published (read-only)
      bottomNavigationBar: _isReadOnly
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Lưu (save as Draft)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await notifier.saveAsDraft(
                                existingId: widget.existingBlog?.id,
                                title: _titleCtrl.text.trim(),
                                content: _contentCtrl.text.trim(),
                                thumbnailUrl: _thumbnailCtrl.text.trim(),
                                category: _category,
                                tags: _selectedTags.toList(),
                                readingTime: int.parse(
                                  _readingTimeCtrl.text.trim(),
                                ),
                              );
                            },
                      icon: formState.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C47C2),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Lưu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _purple,
                        side: const BorderSide(color: _purple),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Đăng bài — only for new blog OR draft blog
                  if (!_isEditing || _isDraft)
                    ...([
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  if (_isDraft) {
                                    // Draft: PATCH status only, no content change
                                    await notifier.promoteToApproval(
                                      widget.existingBlog!.id,
                                    );
                                  } else {
                                    // New blog: POST with PendingApproval
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    await notifier.submitForApproval(
                                      existingId: widget.existingBlog?.id,
                                      title: _titleCtrl.text.trim(),
                                      content: _contentCtrl.text.trim(),
                                      thumbnailUrl: _thumbnailCtrl.text.trim(),
                                      category: _category,
                                      tags: _selectedTags.toList(),
                                      readingTime: int.parse(
                                        _readingTimeCtrl.text.trim(),
                                      ),
                                    );
                                  }
                                },
                          icon: formState.isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: const Text('Đăng bài'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rich content editor (Edit / Preview tabs + formatting toolbar)
  // ---------------------------------------------------------------------------

  Widget _buildContentEditor() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tab switcher ────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Soạn thảo',
                icon: Icons.edit_outlined,
                active: !_isPreviewMode,
                isLeft: true,
                onTap: () => setState(() => _isPreviewMode = false),
              ),
            ),
            Expanded(
              child: _TabButton(
                label: 'Xem trước',
                icon: Icons.visibility_outlined,
                active: _isPreviewMode,
                isLeft: false,
                onTap: () => setState(() => _isPreviewMode = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isPreviewMode)
          // ── Preview ───────────────────────────────────────────────────────
          Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _contentCtrl.text.trim().isEmpty
                ? Center(
                    child: Text(
                      'Chưa có nội dung để xem trước.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  )
                : BlogRichContentView(content: _contentCtrl.text),
          )
        else ...[
          // ── Formatting toolbar (edit mode only) ───────────────────────────
          if (!_isReadOnly) _buildFormattingToolbar(),
          if (!_isReadOnly) const SizedBox(height: 6),

          // ── Text area ─────────────────────────────────────────────────────
          TextFormField(
            controller: _contentCtrl,
            maxLines: 18,
            keyboardType: TextInputType.multiline,
            readOnly: _isReadOnly,
            onChanged: (_) => setState(() {}),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Vui lòng nhập nội dung'
                : null,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.5,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  '## Tiêu đề bài viết\n\nNội dung đoạn văn...\n\n> ⚠️ Callout cảnh báo\n> ✅ Callout thành công\n> 💡 Mẹo / thông tin\n\n![Mô tả ảnh](https://url-ảnh)',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.5,
                height: 1.6,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6C47C2),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarBtn(
              label: 'B',
              tooltip: 'In đậm',
              bold: true,
              onTap: () => _insertAtCursor('**', after: '**'),
            ),
            _ToolbarBtn(
              label: 'I',
              tooltip: 'In nghiêng',
              italic: true,
              onTap: () => _insertAtCursor('*', after: '*'),
            ),
            const _ToolbarDivider(),
            _ToolbarBtn(
              label: 'H2',
              tooltip: 'Tiêu đề lớn',
              onTap: () => _insertAtCursor('\n## '),
            ),
            _ToolbarBtn(
              label: 'H3',
              tooltip: 'Tiêu đề nhỏ',
              onTap: () => _insertAtCursor('\n### '),
            ),
            _ToolbarBtn(
              label: '—',
              tooltip: 'Đường kẻ ngang',
              onTap: () => _insertAtCursor('\n\n---\n\n'),
            ),
            const _ToolbarDivider(),
            _ToolbarBtn(
              label: '⚠️',
              tooltip: 'Callout cảnh báo',
              onTap: () => _insertAtCursor('\n> ⚠️ '),
            ),
            _ToolbarBtn(
              label: '✅',
              tooltip: 'Callout thành công',
              onTap: () => _insertAtCursor('\n> ✅ '),
            ),
            _ToolbarBtn(
              label: '💡',
              tooltip: 'Callout mẹo / thông tin',
              onTap: () => _insertAtCursor('\n> 💡 '),
            ),
            _ToolbarBtn(
              label: '🚫',
              tooltip: 'Callout nguy hiểm',
              onTap: () => _insertAtCursor('\n> 🚫 '),
            ),
            _ToolbarBtn(
              label: 'ℹ️',
              tooltip: 'Callout thông tin',
              onTap: () => _insertAtCursor('\n> ℹ️ '),
            ),
            const _ToolbarDivider(),
            _ToolbarBtn(
              label: '🖼️',
              tooltip: 'Chèn ảnh',
              onTap: () => _insertAtCursor('\n![Mô tả ảnh](', after: ')\n'),
            ),
            _ToolbarBtn(
              label: '• ',
              tooltip: 'Danh sách bullet',
              onTap: () => _insertAtCursor('\n- '),
            ),
            _ToolbarBtn(
              label: '1.',
              tooltip: 'Danh sách số',
              onTap: () => _insertAtCursor('\n1. '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: readOnly ? null : (_) => setState(() {}), // refresh preview
      validator: readOnly ? null : validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C47C2), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BlogCategory>(
          value: _category,
          isExpanded: true,
          onChanged: _isReadOnly
              ? null
              : (v) {
                  if (v != null) setState(() => _category = v);
                },
          items: BlogCategory.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(blogCategoryLabel(c)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BlogTag.values.map((tag) {
        final selected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(blogTagLabel(tag)),
          selected: selected,
          onSelected: _isReadOnly
              ? null
              : (v) {
                  setState(() {
                    if (v) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
          selectedColor: const Color(0xFF6C47C2).withOpacity(0.15),
          checkmarkColor: const Color(0xFF6C47C2),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF6C47C2) : Colors.grey[700],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar helpers
// ---------------------------------------------------------------------------

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool isLeft;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C47C2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? purple : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft ? 10 : 0),
            bottomLeft: Radius.circular(isLeft ? 10 : 0),
            topRight: Radius.circular(isLeft ? 0 : 10),
            bottomRight: Radius.circular(isLeft ? 0 : 10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final bool bold;
  final bool italic;

  const _ToolbarBtn({
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.bold = false,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey[300],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label helper
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
      ),
    );
  }
}
