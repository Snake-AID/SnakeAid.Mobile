import 'dart:convert';

class RescuerServicesAndTerms {
  final String role;
  final List<RescuerUsageGuideItem> usageGuide;
  final List<RescuerPolicyItem> privacyPolicy;
  final List<RescuerFaqItem> faq;
  final RescuerSupportInfo? support;

  const RescuerServicesAndTerms({
    required this.role,
    required this.usageGuide,
    required this.privacyPolicy,
    required this.faq,
    this.support,
  });

  factory RescuerServicesAndTerms.fromSettingValue(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid rescuer services and terms format');
    }
    return RescuerServicesAndTerms.fromJson(decoded);
  }

  factory RescuerServicesAndTerms.fromJson(Map<String, dynamic> json) {
    return RescuerServicesAndTerms(
      role: json['role']?.toString() ?? 'RESCUER',
      usageGuide: (json['usage_guide'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RescuerUsageGuideItem.fromJson)
          .toList(),
      privacyPolicy: (json['privacy_policy'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RescuerPolicyItem.fromJson)
          .toList(),
      faq: (json['faq'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RescuerFaqItem.fromJson)
          .toList(),
      support: json['support'] is Map<String, dynamic>
          ? RescuerSupportInfo.fromJson(json['support'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RescuerUsageGuideItem {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> details;

  const RescuerUsageGuideItem({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.details,
  });

  factory RescuerUsageGuideItem.fromJson(Map<String, dynamic> json) {
    return RescuerUsageGuideItem(
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      details: (json['details'] as List<dynamic>? ?? const [])
          .map((detail) => detail.toString())
          .where((detail) => detail.isNotEmpty)
          .toList(),
    );
  }
}

class RescuerPolicyItem {
  final String item;
  final String content;

  const RescuerPolicyItem({required this.item, required this.content});

  factory RescuerPolicyItem.fromJson(Map<String, dynamic> json) {
    return RescuerPolicyItem(
      item: json['item']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

class RescuerFaqItem {
  final String category;
  final String question;
  final List<String> items;

  const RescuerFaqItem({
    required this.category,
    required this.question,
    required this.items,
  });

  factory RescuerFaqItem.fromJson(Map<String, dynamic> json) {
    final dynamic answer = json['answer'];
    final List<String> normalizedItems;

    if (json['items'] is List) {
      normalizedItems = (json['items'] as List<dynamic>)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (answer != null && answer.toString().isNotEmpty) {
      normalizedItems = [answer.toString()];
    } else {
      normalizedItems = const [];
    }

    return RescuerFaqItem(
      category: json['category']?.toString() ?? 'Chung',
      question: json['question']?.toString() ?? '',
      items: normalizedItems,
    );
  }
}

class RescuerSupportInfo {
  final String hotline;
  final String workingHours;
  final String responseTime;
  final String supportScope;

  const RescuerSupportInfo({
    required this.hotline,
    required this.workingHours,
    required this.responseTime,
    required this.supportScope,
  });

  factory RescuerSupportInfo.fromJson(Map<String, dynamic> json) {
    return RescuerSupportInfo(
      hotline: json['hotline']?.toString() ?? '',
      workingHours: json['working_hours']?.toString() ?? '',
      responseTime: json['response_time']?.toString() ?? '',
      supportScope: json['support_scope']?.toString() ?? '',
    );
  }
}
