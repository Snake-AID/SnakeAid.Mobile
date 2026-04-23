import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../../emergency/models/report_media_response.dart';
import '../models/expert_certificate.dart';

final expertCertificateRepositoryProvider =
    Provider<ExpertCertificateRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ExpertCertificateRepository(httpService: httpService);
});

class ExpertCertificateRepository {
  final HttpService _httpService;

  ExpertCertificateRepository({required HttpService httpService})
      : _httpService = httpService;

  Future<List<ExpertCertificate>> getMyCertificates() async {
    try {
      final response = await _httpService.get('/api/experts/me/certificates');
      final data = _unwrapData(response.data);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ExpertCertificate.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể tải chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<ExpertCertificate> getCertificate(String certificateId) async {
    try {
      final response = await _httpService
          .get('/api/experts/me/certificates/$certificateId');
      final data = _unwrapData(response.data);
      if (data is Map<String, dynamic>) {
        return ExpertCertificate.fromJson(data);
      }
      throw Exception('Dữ liệu chứng chỉ không hợp lệ');
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể tải chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<ExpertCertificate> createCertificate({
    required String certificateName,
    required String issuingOrganization,
    required DateTime? issueDate,
    required DateTime? expiryDate,
    required List<String> reportMediaIds,
  }) async {
    try {
      final response = await _httpService.post(
        '/api/experts/me/certificates',
        data: {
          'certificateName': certificateName,
          'issuingOrganization': issuingOrganization,
          'issueDate': issueDate?.toIso8601String(),
          'expiryDate': expiryDate?.toIso8601String(),
          'reportMediaIds': reportMediaIds,
        },
      );
      final data = _unwrapData(response.data);
      if (data is Map<String, dynamic>) {
        return ExpertCertificate.fromJson(data);
      }
      throw Exception('Dữ liệu chứng chỉ không hợp lệ');
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể tạo chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<ExpertCertificate> updateCertificate({
    required String certificateId,
    required String certificateName,
    required String issuingOrganization,
    required DateTime? issueDate,
    required DateTime? expiryDate,
    required List<String> reportMediaIds,
  }) async {
    try {
      final response = await _httpService.put(
        '/api/experts/me/certificates/$certificateId',
        data: {
          'certificateName': certificateName,
          'issuingOrganization': issuingOrganization,
          'issueDate': issueDate?.toIso8601String(),
          'expiryDate': expiryDate?.toIso8601String(),
          'reportMediaIds': reportMediaIds,
        },
      );
      final data = _unwrapData(response.data);
      if (data is Map<String, dynamic>) {
        return ExpertCertificate.fromJson(data);
      }
      throw Exception('Dữ liệu chứng chỉ không hợp lệ');
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể cập nhật chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> deleteCertificate(String certificateId) async {
    try {
      await _httpService.delete('/api/experts/me/certificates/$certificateId');
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể xóa chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<ReportMediaResponse> uploadCertificateImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last.split('\\').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'ReferenceId': '',
      });
      final response = await _httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': 'ExpertCertificate',
          'purpose': 'Evidence',
        },
      );
      final apiResponse = ReportMediaApiResponse.fromJson(response.data);
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }
      return apiResponse.data!;
    } on DioException catch (e) {
      throw Exception(_messageForError(e, 'Không thể tải ảnh chứng chỉ'));
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  dynamic _unwrapData(dynamic payload) {
    if (payload is Map && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  String _messageForError(DioException e, String fallback) {
    final message = e.response?.data is Map
        ? (e.response?.data['message'] as String?)
        : null;
    if (message != null && message.isNotEmpty) return message;
    return fallback;
  }
}
