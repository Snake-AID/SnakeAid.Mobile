import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../repository/rescuer_shift_repository.dart';

final scheduleSelectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final scheduleWeekStartProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(
    Duration(days: now.weekday - 1),
  );
});

final rescuerWeeklyScheduleProvider =
    FutureProvider.autoDispose<List<ShiftAssignment>>((ref) async {
      final repo = ref.watch(rescuerShiftRepositoryProvider);
      final startOfWeek = ref.watch(scheduleWeekStartProvider);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final startDateStr = DateFormat('yyyy-MM-dd').format(startOfWeek);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endOfWeek);

      return await repo.getAssignments(
        startDate: startDateStr,
        endDate: endDateStr,
      );
    });

class RescuerScheduleScreen extends ConsumerWidget {
  const RescuerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(scheduleSelectedDateProvider);
    final startOfWeek = ref.watch(scheduleWeekStartProvider);
    final scheduleAsync = ref.watch(rescuerWeeklyScheduleProvider);
    final markedDateKeys = scheduleAsync.maybeWhen(
      data: (shifts) => shifts
          .map((s) => DateTime.tryParse(s.shiftStartLocal))
          .whereType<DateTime>()
          .map((dt) => DateFormat('yyyy-MM-dd').format(dt))
          .toSet(),
      orElse: () => <String>{},
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Lịch làm việc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final now = DateTime.now();
              final normalizedNow = DateTime(now.year, now.month, now.day);
              ref.read(scheduleSelectedDateProvider.notifier).state =
                  normalizedNow;
              ref.read(scheduleWeekStartProvider.notifier).state =
                  normalizedNow.subtract(Duration(days: normalizedNow.weekday - 1));
            },
            tooltip: 'Hôm nay',
          ),
        ],
      ),
      body: Column(
        children: [
          // Thẻ chọn tuần
          Container(
            color: const Color(0xFFFF6B35),
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    final prev = startOfWeek.subtract(const Duration(days: 7));
                    final weekdayOffset = selectedDate.weekday - 1;
                    ref.read(scheduleWeekStartProvider.notifier).state = prev;
                    ref.read(scheduleSelectedDateProvider.notifier).state =
                        prev.add(Duration(days: weekdayOffset));
                  },
                ),
                Text(
                  'Tuần ${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM').format(startOfWeek.add(const Duration(days: 6)))}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    final next = startOfWeek.add(const Duration(days: 7));
                    final weekdayOffset = selectedDate.weekday - 1;
                    ref.read(scheduleWeekStartProvider.notifier).state = next;
                    ref.read(scheduleSelectedDateProvider.notifier).state =
                        next.add(Duration(days: weekdayOffset));
                  },
                ),
              ],
            ),
          ),

          // Row các ngày trong tuần
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final hasShift = markedDateKeys.contains(dateKey);
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                final dayName = dayNames[index];

                return GestureDetector(
                  onTap: () {
                    ref.read(scheduleSelectedDateProvider.notifier).state =
                        date;
                  },
                  child: Container(
                    width: 45,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: const Color(0xFFFF6B35),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (hasShift)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: SizedBox(
                              width: 6,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFD32F2F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday
                                            ? const Color(0xFFFF6B35)
                                            : const Color(0xFF757575)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday
                                            ? const Color(0xFFFF6B35)
                                            : const Color(0xFF333333)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: scheduleAsync.when(
              data: (shifts) {
                final selectedDateStr = DateFormat(
                  'yyyy-MM-dd',
                ).format(selectedDate);

                // Filter shifts for the strictly selected date
                final currentDayShifts = shifts.where((s) {
                  if (s.shiftStartLocal.isEmpty) return false;
                  final dt = DateTime.tryParse(s.shiftStartLocal);
                  if (dt == null) return false;
                  return DateFormat('yyyy-MM-dd').format(dt) == selectedDateStr;
                }).toList();

                if (currentDayShifts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Color(0xFFDDDDDD),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có lịch trong ngày ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                currentDayShifts.sort((a, b) {
                  final dtA =
                      DateTime.tryParse(a.shiftStartLocal) ?? DateTime(9999);
                  final dtB =
                      DateTime.tryParse(b.shiftStartLocal) ?? DateTime(9999);
                  return dtA.compareTo(dtB);
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: currentDayShifts.length,
                  itemBuilder: (context, index) {
                    final item = currentDayShifts[index];
                    return _buildShiftCard(item);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Lỗi tải lịch làm việc: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(ShiftAssignment item) {
    final shiftName = item.shift?.name ?? 'Ca tùy chỉnh';

    DateTime? startDt;
    if (item.shiftStartLocal.isNotEmpty) {
      startDt = DateTime.tryParse(item.shiftStartLocal);
    }
    final timeStr = startDt != null
        ? "${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}"
        : '';

    DateTime? endDt;
    if (item.shiftEndLocal.isNotEmpty) {
      endDt = DateTime.tryParse(item.shiftEndLocal);
    }
    final endTimeStr = endDt != null
        ? "${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}"
        : '';

    String statusVi = item.status;
    Color statusColor = const Color(0xFFDDDDDD);
    Color statusBg = const Color(0xFFF9F9F9);

    switch (item.status.toLowerCase()) {
      case 'scheduled':
        statusVi = 'Đã lên lịch';
        statusColor = const Color(0xFFFF6B35);
        statusBg = const Color(0xFFFFF3E0);
        break;
      case 'inprogress':
      case 'in_progress':
      case 'active':
        statusVi = 'Đang làm việc';
        statusColor = const Color(0xFFFF9800);
        statusBg = const Color(0xFFFFF3E0);
        break;
      case 'completed':
      case 'done':
        statusVi = 'Đã hoàn thành';
        statusColor = const Color(0xFF1976D2);
        statusBg = const Color(0xFFE3F2FD);
        break;
      case 'cancelled':
        statusVi = 'Đã hủy';
        statusColor = const Color(0xFFD32F2F);
        statusBg = const Color(0xFFFFEBEE);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột Timeline bên trái
            Container(
              width: 85,
              constraints: const BoxConstraints(minHeight: 112),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: statusBg,
                border: Border(right: BorderSide(color: statusColor, width: 2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'đến',
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endTimeStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            // Cột Content bên phải
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            shiftName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusVi,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 14,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          startDt != null
                              ? '${_getVietnameseDay(startDt.weekday)}, ${DateFormat('dd/MM/yyyy').format(startDt)}'
                              : '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getVietnameseDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 7:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}
