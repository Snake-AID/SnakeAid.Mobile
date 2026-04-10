class RescuerDailyStats {
  final int totalRequests;
  final int totalCompleted;
  final int snakebiteRequests;

  const RescuerDailyStats({
    required this.totalRequests,
    required this.totalCompleted,
    required this.snakebiteRequests,
  });

  factory RescuerDailyStats.fromJson(Map<String, dynamic> json) {
    return RescuerDailyStats(
      totalRequests: json['totalRequests'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      snakebiteRequests: json['snakebiteRequests'] as int? ?? 0,
    );
  }
}
