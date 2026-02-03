/// Media Upload Response Model
class MediaUploadResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final MediaData? data;
  final dynamic error;

  MediaUploadResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? MediaData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

class MediaData {
  final String id;

  MediaData({required this.id});

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      id: json['id'] ?? '',
    );
  }
}
