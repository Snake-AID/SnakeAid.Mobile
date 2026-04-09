class ExpertStats {
  final String period;
  final String from;
  final String to;
  final int consultationRequests;
  final int completedConsultations;
  final int totalIncome;
  final String currency;

  const ExpertStats({
    required this.period,
    required this.from,
    required this.to,
    required this.consultationRequests,
    required this.completedConsultations,
    required this.totalIncome,
    required this.currency,
  });

  factory ExpertStats.fromJson(Map<String, dynamic> json) {
    return ExpertStats(
      period: json['period'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      consultationRequests: json['consultationRequests'] as int? ?? 0,
      completedConsultations: json['completedConsultations'] as int? ?? 0,
      totalIncome: json['totalIncome'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'VND',
    );
  }
}
