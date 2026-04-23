import 'package:intl/intl.dart';

class ExpertCertificateMedia {
  final String id;
  final String mediaUrl;
  final String? fileName;

  ExpertCertificateMedia({
    required this.id,
    required this.mediaUrl,
    this.fileName,
  });

  factory ExpertCertificateMedia.fromJson(Map<String, dynamic> json) {
    return ExpertCertificateMedia(
      id: json['id']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      fileName: json['fileName'] as String?,
    );
  }
}

class ExpertCertificate {
  final String id;
  final String certificateName;
  final String issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool isVerified;
  final String? rejectionReason;
  final List<ExpertCertificateMedia> reportMediaFiles;

  ExpertCertificate({
    required this.id,
    required this.certificateName,
    required this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    required this.isVerified,
    this.rejectionReason,
    required this.reportMediaFiles,
  });

  factory ExpertCertificate.fromJson(Map<String, dynamic> json) {
    return ExpertCertificate(
      id: json['id']?.toString() ?? '',
      certificateName: json['certificateName'] as String? ?? '',
      issuingOrganization: json['issuingOrganization'] as String? ?? '',
      issueDate: _parseDate(json['issueDate']),
      expiryDate: _parseDate(json['expiryDate']),
      isVerified: json['verificationStatus'] == 'Verified',
      rejectionReason: json['rejectionReason'] as String?,
      reportMediaFiles: ((json['media'] ?? json['reportMediaFiles']) as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExpertCertificateMedia.fromJson)
          .toList(),
    );
  }

  String? get primaryMediaUrl =>
      reportMediaFiles.isNotEmpty ? reportMediaFiles.first.mediaUrl : null;

  String? get issueDateLabel => _formatDate(issueDate);

  String? get expiryDateLabel => _formatDate(expiryDate);

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) return null;
      if (parsed.isUtc) {
        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
        );
      }
      return parsed;
    }
    return null;
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
