/// Availability model
/// Model for expert availability/schedule
class AvailabilityDay {
  final DateTime date;
  final String dayOfWeek; // T2, T3, T4, T5, T6, T7, CN
  final bool isAvailable;
  final List<String>? timeSlots; // Các khung giờ trống: "08:00-09:00", "10:00-11:00"

  AvailabilityDay({
    required this.date,
    required this.dayOfWeek,
    required this.isAvailable,
    this.timeSlots,
  });

  /// Create from JSON
  factory AvailabilityDay.fromJson(Map<String, dynamic> json) {
    return AvailabilityDay(
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      dayOfWeek: json['dayOfWeek'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      timeSlots: json['timeSlots'] != null
          ? List<String>.from(json['timeSlots'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'isAvailable': isAvailable,
      'timeSlots': timeSlots,
    };
  }

  /// Get day number
  int get day => date.day;
}
