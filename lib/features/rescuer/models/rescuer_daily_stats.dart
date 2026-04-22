class RescuerDailyStats {
  final int totalRequests;
  final int snakebiteRequests;
  final int snakeCatchingRequests;
  final int totalCompleted;
  final int snakebiteCompleted;
  final int snakeCatchingCompleted;

  const RescuerDailyStats({
    required this.totalRequests,
    required this.snakebiteRequests,
    required this.snakeCatchingRequests,
    required this.totalCompleted,
    required this.snakebiteCompleted,
    required this.snakeCatchingCompleted,
  });

  factory RescuerDailyStats.fromJson(Map<String, dynamic> json) {
    return RescuerDailyStats(
      totalRequests: json['totalRequests'] as int? ?? 0,
      snakebiteRequests: json['snakebiteRequests'] as int? ?? 0,
      snakeCatchingRequests: json['snakeCatchingRequests'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      snakebiteCompleted: json['snakebiteCompleted'] as int? ?? 0,
      snakeCatchingCompleted: json['snakeCatchingCompleted'] as int? ?? 0,
    );
  }
}
