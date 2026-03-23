/// A single bookable time slot entry returned from backend
class TimeSlotEntry {
  final String id;         // slot UUID (used as timeSlotId in booking request)
  final String startTime;  // "09:00"
  final String endTime;    // "09:30"

  const TimeSlotEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  String get displayText => '$startTime - $endTime';
}

/// Availability model
/// Model for expert availability/schedule
class AvailabilityDay {
  final DateTime date;
  final String dayOfWeek; // T2, T3, T4, T5, T6, T7, CN
  final bool isAvailable;
  final List<TimeSlotEntry>? timeSlots; // Các khung giờ trống đặt được

  AvailabilityDay({
    required this.date,
    required this.dayOfWeek,
    required this.isAvailable,
    this.timeSlots,
  });

  /// Create from JSON (legacy support)
  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      dayOfWeek: (json['dayOfWeek'] as String?) ?? '',
      isAvailable: (json['isAvailable'] as bool?) ?? false,
      timeSlots: null, // Not reconstructed from JSON cache
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'isAvailable': isAvailable,
      'timeSlots': timeSlots?.map((s) => s.displayText).toList(),
    };
  }

  /// Get day number
  int get day => date.day;
}
