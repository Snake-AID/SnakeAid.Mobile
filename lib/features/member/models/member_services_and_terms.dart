import 'dart:convert';

class MemberServicesAndTerms {
  final String role;
  final List<MemberUsageGuideItem> usageGuide;
  final MemberPrivacyPolicy privacyPolicy;
  final List<MemberPaymentPolicyItem> paymentPolicy;
  final List<MemberFaqItem> faq;
  final MemberSupportInfo support;

  const MemberServicesAndTerms({
    required this.role,
    required this.usageGuide,
    required this.privacyPolicy,
    required this.paymentPolicy,
    required this.faq,
    required this.support,
  });

  factory MemberServicesAndTerms.fromSettingValue(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid services and terms format');
    }

    return MemberServicesAndTerms.fromJson(decoded);
  }

  factory MemberServicesAndTerms.fromJson(Map<String, dynamic> json) {
    return MemberServicesAndTerms(
      role: json['role']?.toString() ?? 'MEMBER',
      usageGuide: (json['usage_guide'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MemberUsageGuideItem.fromJson)
          .toList(),
      privacyPolicy: MemberPrivacyPolicy.fromJson(
        json['privacy_policy'] as Map<String, dynamic>? ?? const {},
      ),
      paymentPolicy: (json['payment_policy'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MemberPaymentPolicyItem.fromJson)
          .toList(),
      faq: (json['faq'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MemberFaqItem.fromJson)
          .toList(),
      support: MemberSupportInfo.fromJson(
        json['support'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class MemberUsageGuideItem {
  final int id;
  final String feature;
  final String description;
  final List<String> steps;

  const MemberUsageGuideItem({
    required this.id,
    required this.feature,
    required this.description,
    required this.steps,
  });

  factory MemberUsageGuideItem.fromJson(Map<String, dynamic> json) {
    return MemberUsageGuideItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      feature: json['feature']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .map((step) => step.toString())
          .where((step) => step.isNotEmpty)
          .toList(),
    );
  }
}

class MemberPrivacyPolicy {
  final String commitment;
  final String locationAccess;
  final String dataSecurity;

  const MemberPrivacyPolicy({
    required this.commitment,
    required this.locationAccess,
    required this.dataSecurity,
  });

  factory MemberPrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return MemberPrivacyPolicy(
      commitment: json['commitment']?.toString() ?? '',
      locationAccess: json['location_access']?.toString() ?? '',
      dataSecurity: json['data_security']?.toString() ?? '',
    );
  }
}

class MemberPaymentPolicyItem {
  final String item;
  final String content;

  const MemberPaymentPolicyItem({required this.item, required this.content});

  factory MemberPaymentPolicyItem.fromJson(Map<String, dynamic> json) {
    return MemberPaymentPolicyItem(
      item: json['item']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

class MemberFaqItem {
  final String question;
  final String answer;

  const MemberFaqItem({required this.question, required this.answer});

  factory MemberFaqItem.fromJson(Map<String, dynamic> json) {
    return MemberFaqItem(
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}

class MemberSupportInfo {
  final String hotline;
  final String email;
  final String workingHours;
  final String liveChat;

  const MemberSupportInfo({
    required this.hotline,
    required this.email,
    required this.workingHours,
    required this.liveChat,
  });

  factory MemberSupportInfo.fromJson(Map<String, dynamic> json) {
    return MemberSupportInfo(
      hotline: json['hotline']?.toString() ?? '078 717 1699',
      email: json['email']?.toString() ?? 'support@snakeaid.vn',
      workingHours: json['working_hours']?.toString() ?? '6:00 - 23:00',
      liveChat: json['live_chat']?.toString() ?? 'Phản hồi trong vòng 5 phút.',
    );
  }
}
