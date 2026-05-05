import 'dart:convert';

/// Model for Expert:ServicesAndTerms system setting
/// Contains usage guide, privacy policy, terms & conditions, and payment policy for experts
class ExpertServicesAndTerms {
  final ExpertUsageGuide? usageGuide;
  final ExpertPrivacyPolicy? privacyPolicy;
  final ExpertTermsAndConditions? termsAndConditions;
  final ExpertPaymentPolicy? paymentPolicy;

  ExpertServicesAndTerms({
    this.usageGuide,
    this.privacyPolicy,
    this.termsAndConditions,
    this.paymentPolicy,
  });

  factory ExpertServicesAndTerms.fromSettingValue(String value) {
    final decoded = jsonDecode(value);
    return ExpertServicesAndTerms.fromJson(decoded);
  }

  factory ExpertServicesAndTerms.fromJson(Map<String, dynamic> json) {
    return ExpertServicesAndTerms(
      usageGuide: json['usage_guide'] != null
          ? ExpertUsageGuide.fromJson(json['usage_guide'])
          : null,
      privacyPolicy: json['privacy_policy'] != null
          ? ExpertPrivacyPolicy.fromJson(json['privacy_policy'])
          : null,
      termsAndConditions: json['terms_and_conditions'] != null
          ? ExpertTermsAndConditions.fromJson(json['terms_and_conditions'])
          : null,
      paymentPolicy: json['payment_policy'] != null
          ? ExpertPaymentPolicy.fromJson(json['payment_policy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'usage_guide': usageGuide?.toJson(),
    'privacy_policy': privacyPolicy?.toJson(),
    'terms_and_conditions': termsAndConditions?.toJson(),
    'payment_policy': paymentPolicy?.toJson(),
  };
}

/// Usage guide with three consulting modes
class ExpertUsageGuide {
  final List<ExpertUsageGuideStep> immediateConsulting;
  final List<ExpertUsageGuideStep> scheduledConsulting;
  final List<ExpertUsageGuideStep> withdrawalGuide;

  ExpertUsageGuide({
    required this.immediateConsulting,
    required this.scheduledConsulting,
    required this.withdrawalGuide,
  });

  factory ExpertUsageGuide.fromJson(Map<String, dynamic> json) {
    return ExpertUsageGuide(
      immediateConsulting: _parseGuideSteps(json['immediate_consulting']),
      scheduledConsulting: _parseGuideSteps(json['scheduled_consulting']),
      withdrawalGuide: _parseGuideSteps(json['withdrawal_guide']),
    );
  }

  static List<ExpertUsageGuideStep> _parseGuideSteps(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => ExpertUsageGuideStep.fromJson(item))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'immediate_consulting': immediateConsulting.map((e) => e.toJson()).toList(),
    'scheduled_consulting': scheduledConsulting.map((e) => e.toJson()).toList(),
    'withdrawal_guide': withdrawalGuide.map((e) => e.toJson()).toList(),
  };
}

/// Individual step in usage guide
class ExpertUsageGuideStep {
  final int? step;
  final String? title;
  final String? details;

  ExpertUsageGuideStep({this.step, this.title, this.details});

  factory ExpertUsageGuideStep.fromJson(Map<String, dynamic> json) {
    return ExpertUsageGuideStep(
      step: json['step'] as int?,
      title: json['title'] as String?,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    'title': title,
    'details': details,
  };
}

/// Privacy policy with sections
class ExpertPrivacyPolicy {
  final List<String> sections;

  ExpertPrivacyPolicy({required this.sections});

  factory ExpertPrivacyPolicy.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    if (sections == null) {
      return ExpertPrivacyPolicy(sections: []);
    }
    if (sections is! List) {
      return ExpertPrivacyPolicy(sections: []);
    }

    return ExpertPrivacyPolicy(sections: sections.whereType<String>().toList());
  }

  Map<String, dynamic> toJson() => {'sections': sections};
}

/// Terms and conditions with key points
class ExpertTermsAndConditions {
  final List<String> keyPoints;
  final String? contact;

  ExpertTermsAndConditions({required this.keyPoints, this.contact});

  factory ExpertTermsAndConditions.fromJson(Map<String, dynamic> json) {
    final keyPoints = json['key_points'];
    final keyPointsList = <String>[];

    if (keyPoints is List) {
      keyPointsList.addAll(keyPoints.whereType<String>());
    }

    return ExpertTermsAndConditions(
      keyPoints: keyPointsList,
      contact: json['contact'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'key_points': keyPoints,
    'contact': contact,
  };
}

/// Payment policy information
class ExpertPaymentPolicy {
  final String? commission;
  final String? processingTime;
  final String? withdrawalFee;
  final String? security;

  ExpertPaymentPolicy({
    this.commission,
    this.processingTime,
    this.withdrawalFee,
    this.security,
  });

  factory ExpertPaymentPolicy.fromJson(Map<String, dynamic> json) {
    return ExpertPaymentPolicy(
      commission: json['commission'] as String?,
      processingTime: json['processing_time'] as String?,
      withdrawalFee: json['withdrawal_fee'] as String?,
      security: json['security'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'commission': commission,
    'processing_time': processingTime,
    'withdrawal_fee': withdrawalFee,
    'security': security,
  };
}
