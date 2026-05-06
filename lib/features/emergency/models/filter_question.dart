/// Filter Question Response Model for Snake Identification Questionnaire
class FilterQuestionResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<FilterQuestion>? data;
  final dynamic error;

  FilterQuestionResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory FilterQuestionResponse.fromJson(Map<String, dynamic> json) {
    return FilterQuestionResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
                .map((q) => FilterQuestion.fromJson(q))
                .toList()
          : null,
      error: json['error'],
    );
  }
}

/// Filter Question Model
class FilterQuestion {
  final int id;
  final String question;
  final List<FilterOption> options;

  FilterQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory FilterQuestion.fromJson(Map<String, dynamic> json) {
    return FilterQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((o) => FilterOption.fromJson(o))
              .toList() ??
          [],
    );
  }
}

/// Filter Option Model
class FilterOption {
  final int id;
  final String optionText;
  final String? optionImageUrl;

  FilterOption({
    required this.id,
    required this.optionText,
    this.optionImageUrl,
  });

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: json['id'] ?? 0,
      optionText: json['optionText'] ?? '',
      optionImageUrl: json['optionImageUrl'],
    );
  }
}
