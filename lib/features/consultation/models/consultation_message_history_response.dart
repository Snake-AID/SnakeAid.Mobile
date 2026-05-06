class ConsultationMessageHistoryItem {
  final String id;
  final String consultationId;
  final String senderId;
  final String content;
  final String? attachmentUrl;
  final DateTime sentAt;

  const ConsultationMessageHistoryItem({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.content,
    required this.attachmentUrl,
    required this.sentAt,
  });

  factory ConsultationMessageHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime parseSentAt(dynamic value) {
      if (value == null) return DateTime.now().toUtc();
      return DateTime.tryParse(value.toString()) ?? DateTime.now().toUtc();
    }

    return ConsultationMessageHistoryItem(
      id: (json['id'] ?? '').toString(),
      consultationId: (json['consultationId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      attachmentUrl: json['attachmentUrl']?.toString(),
      sentAt: parseSentAt(json['sentAt']).toUtc(),
    );
  }
}

class ConsultationMessageHistoryMeta {
  final int totalPages;
  final int totalItems;
  final int currentPage;
  final int pageSize;

  const ConsultationMessageHistoryMeta({
    required this.totalPages,
    required this.totalItems,
    required this.currentPage,
    required this.pageSize,
  });

  factory ConsultationMessageHistoryMeta.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return ConsultationMessageHistoryMeta(
      totalPages: parseInt(json['total_pages'], 1),
      totalItems: parseInt(json['total_items'], 0),
      currentPage: parseInt(json['current_page'], 1),
      pageSize: parseInt(json['page_size'], 10),
    );
  }
}

class ConsultationMessageHistoryResponse {
  final List<ConsultationMessageHistoryItem> items;
  final ConsultationMessageHistoryMeta meta;

  const ConsultationMessageHistoryResponse({
    required this.items,
    required this.meta,
  });

  factory ConsultationMessageHistoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final itemsRaw = (json['items'] as List<dynamic>? ?? const []);
    final metaRaw = json['meta'] as Map<String, dynamic>? ?? const {};

    return ConsultationMessageHistoryResponse(
      items: itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(ConsultationMessageHistoryItem.fromJson)
          .toList(),
      meta: ConsultationMessageHistoryMeta.fromJson(metaRaw),
    );
  }
}
