import 'package:flutter/material.dart';

/// Working hours configuration screen for experts.
/// Allows selecting active days and setting time slot availability per day.
class ExpertWorkingHoursScreen extends StatefulWidget {
  const ExpertWorkingHoursScreen({super.key});

  @override
  State<ExpertWorkingHoursScreen> createState() =>
      _ExpertWorkingHoursScreenState();
}

class _TimeSlot {
  TimeOfDay start;
  TimeOfDay end;

  _TimeSlot({required this.start, required this.end});

  _TimeSlot copy() => _TimeSlot(start: start, end: end);
}

class _ExpertWorkingHoursScreenState extends State<ExpertWorkingHoursScreen> {
  static const Color _purple = Color(0xFF6C47C2);

  // Selected days: 1=Mon, 2=Tue, ..., 7=Sun
  final Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};

  // Time slots per weekday
  late final Map<int, List<_TimeSlot>> _slots;

  static const List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const List<String> _dayFullNames = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  @override
  void initState() {
    super.initState();
    _slots = {
      for (int d = 1; d <= 7; d++)
        d: [
          _TimeSlot(
              start: const TimeOfDay(hour: 8, minute: 0),
              end: const TimeOfDay(hour: 12, minute: 0)),
          _TimeSlot(
              start: const TimeOfDay(hour: 13, minute: 0),
              end: const TimeOfDay(hour: 17, minute: 0)),
        ]
    };
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(
    int weekday,
    int slotIndex, {
    required bool isStart,
  }) async {
    final slot = _slots[weekday]![slotIndex];
    final initial = isStart ? slot.start : slot.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _slots[weekday]![slotIndex].start = picked;
      } else {
        _slots[weekday]![slotIndex].end = picked;
      }
    });
  }

  void _addSlot(int weekday) {
    setState(() {
      _slots[weekday]!.add(
        _TimeSlot(
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 10, minute: 0),
        ),
      );
    });
  }

  void _removeSlot(int weekday, int index) {
    if (_slots[weekday]!.length <= 1) return;
    setState(() => _slots[weekday]!.removeAt(index));
  }

  void _copyToAll(int sourceWeekday) {
    final source = _slots[sourceWeekday]!.map((s) => s.copy()).toList();
    setState(() {
      for (final d in _selectedDays) {
        if (d != sourceWeekday) {
          _slots[d] = source.map((s) => s.copy()).toList();
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã sao chép lịch ${_dayFullNames[sourceWeekday - 1]} sang tất cả các ngày',
        ),
        backgroundColor: _purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _save() {
    // TODO: persist working hours
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu lịch làm việc'),
        backgroundColor: _purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C47C2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giờ Làm Việc',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Day selector ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ngày Làm Việc',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (i) {
                            final day = i + 1;
                            final selected = _selectedDays.contains(day);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    if (_selectedDays.length > 1) {
                                      _selectedDays.remove(day);
                                    }
                                  } else {
                                    _selectedDays.add(day);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected
                                      ? _purple
                                      : const Color(0xFFF0EBF9),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: _purple.withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _dayLabels[i],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF6C47C2),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Time slots per selected day ────────────────────────────
                  ...List.generate(7, (i) {
                    final day = i + 1;
                    if (!_selectedDays.contains(day)) return const SizedBox.shrink();
                    final slots = _slots[day]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Day header
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: _purple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _dayFullNames[i],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Slot rows
                            ...List.generate(slots.length, (si) {
                              final slot = slots[si];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    // Start time
                                    _TimeButton(
                                      label: _formatTime(slot.start),
                                      onTap: () => _pickTime(day, si, isStart: true),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '—',
                                        style: TextStyle(
                                          color: Color(0xFF999999),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    // End time
                                    _TimeButton(
                                      label: _formatTime(slot.end),
                                      onTap: () => _pickTime(day, si, isStart: false),
                                    ),

                                    const Spacer(),

                                    // Copy to all (first slot only)
                                    if (si == 0)
                                      GestureDetector(
                                        onTap: () => _copyToAll(day),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _purple.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.copy_all,
                                                  size: 14, color: _purple),
                                              SizedBox(width: 4),
                                              Text(
                                                'Sao chép',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: _purple,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 10),

                                    const SizedBox(width: 6),

                                    // Remove slot
                                    GestureDetector(
                                      onTap: () => _removeSlot(day, si),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: slots.length > 1
                                              ? const Color(0xFFFFEEEE)
                                              : const Color(0xFFF5F5F5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: slots.length > 1
                                              ? const Color(0xFFDC3545)
                                              : const Color(0xFFCCCCCC),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Add slot
                            GestureDetector(
                              onTap: () => _addSlot(day),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _purple.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add,
                                        size: 16, color: _purple),
                                    SizedBox(width: 6),
                                    Text(
                                      'Thêm khung giờ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Save button ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu Lịch Làm Việc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBF9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6C47C2).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time,
                size: 14, color: Color(0xFF6C47C2)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C47C2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
