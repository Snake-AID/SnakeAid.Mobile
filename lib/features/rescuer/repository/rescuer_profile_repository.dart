import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/rescuer_profile.dart';

final rescuerProfileRepositoryProvider = Provider<RescuerProfileRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return RescuerProfileRepository(httpService: httpService);
});

class RescuerProfileRepository {
  final HttpService _httpService;

  RescuerProfileRepository({required HttpService httpService})
      : _httpService = httpService;

  /// GET /api/rescuers/me/profile
  Future<RescuerProfile> getMyProfile() async {
    final response = await _httpService.get('/api/rescuers/me/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return RescuerProfile.fromJson(data);
  }

  /// PUT /api/rescuers/me/profile
  Future<RescuerProfile> updateMyProfile({
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final response = await _httpService.put(
      '/api/rescuers/me/profile',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return RescuerProfile.fromJson(data);
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
