import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repository/consultation_repository.dart';

/// Màn hình hoàn thành & đánh giá tư vấn
class ConsultationCompletionScreen extends ConsumerStatefulWidget {
  final String expertName;
  final String expertSpecialty;
  final int durationSeconds;
  final String consultationId;

  const ConsultationCompletionScreen({
    super.key,
    required this.expertName,
    required this.expertSpecialty,
    required this.durationSeconds,
    required this.consultationId,
  });

  @override
  ConsumerState<ConsultationCompletionScreen> createState() =>
      _ConsultationCompletionScreenState();
}

class _ConsultationCompletionScreenState
    extends ConsumerState<ConsultationCompletionScreen> {
  static const Color _primary = Color(0xFF228B22);
  static const Color _bg = Color(0xFFF6F8F6);

  int _selectedStars = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;
  int get _charCount => _feedbackController.text.length;

  final List<String> _quickTags = [
    'Rất chuyên nghiệp',
    'Tư vấn chi tiết',
    'Phản hồi nhanh',
    'Dễ hiểu',
  ];

  String get _formattedDuration {
    final m = widget.durationSeconds ~/ 60;
    final s = widget.durationSeconds % 60;
    if (m == 0) return '$s giây';
    return '$m phút ${s > 0 ? '$s giây' : ''}';
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final comment = [
        _feedbackController.text.trim(),
        ..._selectedTags,
      ].where((s) => s.isNotEmpty).join(' | ');

      await repo.submitReview(
        consultationId: widget.consultationId,
        rating: _selectedStars,
        comment: comment,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá!'),
          backgroundColor: _primary,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/member-home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửii đánh giá: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── App Bar ─────────────────────────────────────────────────
          _buildAppBar(),

          // ── Scrollable content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success header
                  _buildSuccessHeader(),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Session summary card
                        _buildSessionCard(),
                        const SizedBox(height: 24),

                        // Payment details card
                        _buildSectionTitle('Thanh Toán Đã Xử Lý'),
                        const SizedBox(height: 12),
                        _buildPaymentCard(),
                        const SizedBox(height: 24),

                        // Star rating
                        _buildSectionTitle('Đánh Giá Chuyên Gia'),
                        const SizedBox(height: 12),
                        _buildStarRating(),
                        const SizedBox(height: 24),

                        // Feedback textarea
                        _buildSectionTitle('Nhận Xét (Tùy chọn)'),
                        const SizedBox(height: 12),
                        _buildFeedbackBox(),
                        const SizedBox(height: 12),
                        _buildQuickTags(),
                        const SizedBox(height: 32),

                        // Submit
                        _buildSubmitButton(),
                        const SizedBox(height: 12),
                        _buildSkipButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Footer buttons
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Hoàn Thành Tư Vấn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go('/member-home'),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close,
                        size: 24, color: Color(0xFF333333)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success Header ─────────────────────────────────────────────────────────

  Widget _buildSuccessHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDDA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cảm ơn bạn đã sử dụng dịch vụ!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Phiên tư vấn đã kết thúc',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6C757D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Session Card ───────────────────────────────────────────────────────────

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withOpacity(0.1),
            ),
            child: const Icon(Icons.person, size: 32, color: _primary),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expertName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.calendar_today_outlined,
                    _formatDateTime(DateTime.now())),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.schedule_outlined, _formattedDuration),
                const SizedBox(height: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: _primary),
                      SizedBox(width: 4),
                      Text(
                        'Đã Hoàn Thành',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6C757D)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  // ── Payment Card ───────────────────────────────────────────────────────────

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _buildPaymentRow('Số tiền', '150.000 VNĐ', valueGreen: true),
          const SizedBox(height: 12),
          _buildPaymentRow('Phương thức', 'PayOS'),
          const Divider(height: 24, color: Color(0xFFF3F4F6)),
          Row(
            children: const [
              Icon(Icons.check_circle, size: 18, color: _primary),
              SizedBox(width: 8),
              Text(
                'Đã thanh toán thành công',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool valueGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6C757D))),
        Text(
          value,
          style: TextStyle(
            fontSize: valueGreen ? 15 : 14,
            fontWeight: FontWeight.bold,
            color: valueGreen ? _primary : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  // ── Star Rating ────────────────────────────────────────────────────────────

  Widget _buildStarRating() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _selectedStars;
            return GestureDetector(
              onTap: () => setState(() => _selectedStars = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star : Icons.star_outline,
                  size: 44,
                  color: filled
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFD1D5DB),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedStars == 0
              ? 'Chọn số sao'
              : _starLabel(_selectedStars),
          style: const TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1: return 'Không hài lòng';
      case 2: return 'Cần cải thiện';
      case 3: return 'Bình thường';
      case 4: return 'Hài lòng';
      case 5: return 'Tuyệt vời!';
      default: return '';
    }
  }

  // ── Feedback Box ───────────────────────────────────────────────────────────

  Widget _buildFeedbackBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            maxLength: 200,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn...',
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 14,
            child: Text(
              '$_charCount/200',
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Tags ─────────────────────────────────────────────────────────────

  Widget _buildQuickTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickTags.map((tag) {
          final selected = _selectedTags.contains(tag);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedTags.remove(tag);
                } else {
                  _selectedTags.add(tag);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? _primary.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? _primary : const Color(0xFFD1D5DB),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? _primary : const Color(0xFF6C757D),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Gửii Đánh Giá',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/member-home'),
        child: const Text(
          'Bỏ qua',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6C757D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/consultation-home'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary),
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Lịch Sử Tư Vấn',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/member-home'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary),
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Về Trang Chủ',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDateTime(DateTime dt) {
    final pad = (int v) => v.toString().padLeft(2, '0');
    return '${pad(dt.day)}/${pad(dt.month)}/${dt.year} - ${pad(dt.hour)}:${pad(dt.minute)}';
  }
}
