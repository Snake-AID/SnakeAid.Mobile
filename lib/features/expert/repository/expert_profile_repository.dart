import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/expert_profile.dart';

final expertProfileRepositoryProvider = Provider<ExpertProfileRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ExpertProfileRepository(httpService: httpService);
});

class ExpertProfileRepository {
  final HttpService _httpService;

  ExpertProfileRepository({required HttpService httpService})
      : _httpService = httpService;

  /// GET /api/experts/me/profile
  Future<ExpertProfile> getMyProfile() async {
    final response = await _httpService.get('/api/experts/me/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return ExpertProfile.fromJson(data);
  }

  /// PUT /api/experts/me/profile
  Future<ExpertProfile> updateMyProfile({
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    required String biography,
    required double scheduledConsultationFee,
    double? emergencyConsultationFee,
  }) async {
    final response = await _httpService.put(
      '/api/experts/me/profile',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'biography': biography,
        'scheduledConsultationFee': scheduledConsultationFee,
        'emergencyConsultationFee': emergencyConsultationFee,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ExpertProfile.fromJson(data);
  }

  /// Upload avatar image and return the Cloudinary URL
  Future<String?> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      'ReferenceId': '',
    });
    final response = await _httpService.post(
      '/api/media/report',
      data: formData,
      queryParameters: {'type': 'CommunityReport', 'purpose': 'Evidence'},
    );
    final data = response.data['data'];
    if (data != null && data is Map) {
      return data['mediaUrl'] as String?;
    }
    return null;
  }
}
