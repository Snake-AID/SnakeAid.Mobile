import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/availability_model.dart';
import '../../providers/expert_detail_provider.dart';

// Primary color constant
const Color _primaryColor = Color(0xFF228B22);
const Color _backgroundColor = Color(0xFFF6F8F6);

/// Time Slot model for UI rendering
class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  String get displayText => '$startTime - $endTime';
}

/// Date model for horizontal scroller
class AvailableDate {
  final DateTime date;
  final String dayLabel;
  final bool hasAvailability;

  AvailableDate({
    required this.date,
    required this.dayLabel,
    required this.hasAvailability,
  });
}

/// Consultation Time Selection Screen
/// Allows users to select date, time slot, and duration for consultation
class ConsultationTimeSelectionScreen extends ConsumerStatefulWidget {
  final String expertId;

  const ConsultationTimeSelectionScreen({
    super.key,
    required this.expertId,
  });

  @override
  ConsumerState<ConsultationTimeSelectionScreen> createState() =>
      _ConsultationTimeSelectionScreenState();
}

class _ConsultationTimeSelectionScreenState
    extends ConsumerState<ConsultationTimeSelectionScreen> {
  int? _selectedDateIndex;
  int? _selectedTimeSlotIndex;

  /// Real slot ID from backend (used as timeSlotId in booking request)
  String? _selectedSlotId;

  /// Captured at selection time — used directly in _handleContinue (avoids re-filtering)
  DateTime? _selectedDateObj;
  TimeSlot? _selectedSlotObj;

  // Fallback mock dates when provider has no availability yet
  late List<AvailableDate> _mockDates;

  // Fallback mock time slots per day (used only during initial load)
  static const List<TimeSlot> _mockTimeSlots = [
    TimeSlot(startTime: '09:00', endTime: '09:30', isAvailable: true),
    TimeSlot(startTime: '09:30', endTime: '10:00', isAvailable: true),
    TimeSlot(startTime: '10:00', endTime: '10:30', isAvailable: true),
    TimeSlot(startTime: '10:30', endTime: '11:00', isAvailable: true),
    TimeSlot(startTime: '11:00', endTime: '11:30', isAvailable: false),
    TimeSlot(startTime: '11:30', endTime: '12:00', isAvailable: true),
    TimeSlot(startTime: '14:00', endTime: '14:30', isAvailable: true),
    TimeSlot(startTime: '14:30', endTime: '15:00', isAvailable: false),
  ];

  // Whether backend data has been received (not just loading)
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeMockDates();
    // Force fresh fetch every time screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(expertDetailProvider(widget.expertId));
    });
  }

  void _initializeMockDates() {
    final now = DateTime.now();
    _mockDates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      final dayLabel = _getDayLabel(date);
      final hasAvailability = index != 2 && index != 5;

      return AvailableDate(
        date: date,
        dayLabel: dayLabel,
        hasAvailability: hasAvailability,
      );
    });
  }

  String _getDayLabel(DateTime date) {
    final weekday = date.weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'T.HAI';
      case DateTime.tuesday:
        return 'T.BA';
      case DateTime.wednesday:
        return 'T.TƯ';
      case DateTime.thursday:
        return 'T.NĂM';
      case DateTime.friday:
        return 'T.SÁU';
      case DateTime.saturday:
        return 'T.BẢY';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  String _getFullDayLabel(DateTime date) {
    final weekday = date.weekday;
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final dayLabel = _getFullDayLabel(date);
    
    if (includeYear) {
      return '$dayLabel, $day/$month/$year';
    } else {
      return '$dayLabel, $day/$month';
    }
  }

  /// Format giá tiền thành chuỗi VNĐ
  String _formatFee(double fee) {
    if (fee <= 0) return 'Miễn phí';
    return '${fee.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VNĐ';
  }

  void _handleContinue() {
    if (_selectedDateObj == null || _selectedSlotObj == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ tư vấn')),
      );
      return;
    }

    // Navigate to documents screen with consultation details + real timeSlotId
    context.push(
      '/consultation-documents/${widget.expertId}',
      extra: {
        'consultationType': 'scheduled',
        'selectedDate': _formatDate(_selectedDateObj!),
        'selectedTime': '${_selectedSlotObj!.startTime} (30 phút)',
        'duration': '30 phút',
        'price': _formatFee(ref.read(expertDetailProvider(widget.expertId)).expert?.scheduledConsultationFee ?? 0),
        if (_selectedSlotId != null) 'timeSlotId': _selectedSlotId!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertDetailProvider(widget.expertId));
    final theme = Theme.of(context);

    // Track whether real data has been received
    if (!state.isLoading && state.expert != null && !_dataLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _dataLoaded = true);
      });
    }

    // Derive display dates and slots from provider when available
    final availability = state.expert?.availability ?? const <AvailabilityDay>[];
    // now dùng UTC+7 để khớp với giờ VN thực tế (device timezone có thể khác)
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    // Chỉ giữ ngày mà còn ít nhất 1 slot chưa qua
    final futureAvailability = availability.where((d) {
      // Nếu không có slot data, giữ lại nếu ngày chưa hết
      if (d.timeSlots == null || d.timeSlots!.isEmpty) {
        final dayEnd = DateTime.utc(d.date.year, d.date.month, d.date.day, 23, 59, 59);
        return !dayEnd.isBefore(now);
      }
      // Có slot data: chỉ giữ nếu còn ít nhất 1 slot trong tương lai
      return d.timeSlots!.any((e) {
        final parts = e.startTime.split(':');
        final slotStart = DateTime.utc(d.date.year, d.date.month, d.date.day,
            int.parse(parts[0]), int.parse(parts[1]));
        return slotStart.isAfter(now);
      });
    }).toList();

    // Use mock dates only while data hasn't loaded yet
    final displayDates = futureAvailability.isNotEmpty
        ? futureAvailability.map((d) => AvailableDate(
              date: d.date,
              dayLabel: d.dayOfWeek,
              hasAvailability: d.isAvailable,
            )).toList()
        : (_dataLoaded ? const <AvailableDate>[] : _mockDates);

    // Helper: parse "HH:mm" thành DateTime UTC (= giờ VN wall-clock) của ngày được chọn
    DateTime _slotDateTime(DateTime date, String timeStr) {
      final parts = timeStr.split(':');
      return DateTime.utc(date.year, date.month, date.day,
          int.parse(parts[0]), int.parse(parts[1]));
    }

    final List<TimeSlot> displaySlots;
    final List<TimeSlotEntry> rawSlotsForSelected;
    if (futureAvailability.isNotEmpty &&
        _selectedDateIndex != null &&
        _selectedDateIndex! < futureAvailability.length) {
      final selectedDay = futureAvailability[_selectedDateIndex!];
      final allSlots = selectedDay.timeSlots ?? const <TimeSlotEntry>[];
      // Lọc bỏ slot đã qua (so sánh startTime với thời điểm hiện tại)
      rawSlotsForSelected = allSlots.where((e) {
        final slotStart = _slotDateTime(selectedDay.date, e.startTime);
        return slotStart.isAfter(now);
      }).toList();
      displaySlots = rawSlotsForSelected
          .map((e) => TimeSlot(startTime: e.startTime, endTime: e.endTime, isAvailable: true))
          .toList();
      // Reset selection if the previously selected slot was filtered out
      if (_selectedTimeSlotIndex != null && _selectedTimeSlotIndex! >= displaySlots.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() { _selectedTimeSlotIndex = null; _selectedSlotId = null; });
        });
      }
    } else if (!_dataLoaded) {
      // Still loading — show mock slots so UI isn't empty
      rawSlotsForSelected = const [];
      displaySlots = _selectedDateIndex != null ? _mockTimeSlots : const [];
    } else {
      // Data loaded but no availability
      rawSlotsForSelected = const [];
      displaySlots = const [];
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chọn Thời Gian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expert == null
              ? const Center(child: Text('Không tìm thấy chuyên gia'))
              : (_dataLoaded && availability.isEmpty)
                  ? _buildNoAvailability(theme)
                  : Column(
                  children: [
                    // Main scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Expert Profile Card
                                  _buildExpertProfile(
                                      context, state.expert!, theme),
                                ],
                              ),
                            ),

                            // Horizontal Date Scroller
                            _buildDateScroller(displayDates, theme),

                            // Available Times Section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildAvailableTimesSection(
                                  displayDates, displaySlots, rawSlotsForSelected, theme),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Summary & Actions
                    if (_selectedDateIndex != null &&
                        _selectedTimeSlotIndex != null)
                      _buildBottomSummary(displayDates, displaySlots, theme),
                  ],
                ),
    );
  }

  /// Build expert profile summary card
  Widget _buildExpertProfile(BuildContext context, expert, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: expert.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(expert.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: expert.avatarUrl == null ? Colors.grey[300] : null,
            ),
            child: expert.avatarUrl == null
                ? Icon(Icons.person, size: 28, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 16),

          // Expert info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expert.specialty ?? (expert.specialties.isEmpty ? null : expert.specialties.first) ?? 'Chuyên gia tư vấn',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal date scroller
  Widget _buildDateScroller(List<AvailableDate> displayDates, ThemeData theme) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayDates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final dateItem = displayDates[index];
          final isSelected = _selectedDateIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
                _selectedTimeSlotIndex = null;
                _selectedSlotId = null;
                _selectedDateObj = null;
                _selectedSlotObj = null;
              });
            },
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryColor.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateItem.dayLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateItem.date.day}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'tháng ${dateItem.date.month}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build empty state when expert has no available time slots
  Widget _buildNoAvailability(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[350],
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có lịch trống',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chuyên gia hiện chưa có khung giờ nào khả dụng.\nVui lòng thử lại sau hoặc chọn chuyên gia khác.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Quay lại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build available times section
  Widget _buildAvailableTimesSection(
    List<AvailableDate> displayDates,
    List<TimeSlot> displaySlots,
    List<TimeSlotEntry> rawSlots,
    ThemeData theme,
  ) {
    if (_selectedDateIndex == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Vui lòng chọn ngày để xem giờ khả dụng',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (displaySlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Không có khung giờ nào cho ngày này',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final selectedDate = displayDates[_selectedDateIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giờ Khả Dụng - ${_formatDate(selectedDate.date, includeYear: false)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: displaySlots.length,
          itemBuilder: (context, index) {
            final timeSlot = displaySlots[index];
            final isSelected = _selectedTimeSlotIndex == index;

            return InkWell(
              onTap: timeSlot.isAvailable
                  ? () {
                      setState(() {
                        _selectedTimeSlotIndex = index;
                        // Lấy slot ID từ rawSlotsForSelected (đã lọc past slots)
                        _selectedSlotId = index < rawSlots.length
                            ? rawSlots[index].id
                            : null;
                        // Lưu đối tượng được chọn để dùng trong _handleContinue (tránh re-filter)
                        _selectedDateObj = _selectedDateIndex != null
                            ? displayDates[_selectedDateIndex!].date
                            : null;
                        _selectedSlotObj = timeSlot;
                      });
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: !timeSlot.isAvailable
                      ? Colors.grey.shade100
                      : isSelected
                          ? _primaryColor
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !timeSlot.isAvailable
                        ? Colors.transparent
                        : isSelected
                            ? _primaryColor
                            : Colors.grey.shade300,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeSlot.displayText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: !timeSlot.isAvailable
                        ? Colors.grey.shade400
                        : isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                    decoration: !timeSlot.isAvailable
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build bottom summary and action buttons
  Widget _buildBottomSummary(
    List<AvailableDate> displayDates,
    List<TimeSlot> displaySlots,
    ThemeData theme,
  ) {
    if (_selectedDateObj == null || _selectedSlotObj == null) return const SizedBox.shrink();
    final selectedDate = _selectedDateObj!;
    final selectedTimeSlot = _selectedSlotObj!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn Đã Chọn',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(selectedDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedTimeSlot.displayText} (30 phút)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price
              Row(
                children: [
                  Icon(
                    Icons.payments,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatFee(ref.read(expertDetailProvider(widget.expertId)).expert?.scheduledConsultationFee ?? 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Divider
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 16),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _handleContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tiếp Tục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Quay lại',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
