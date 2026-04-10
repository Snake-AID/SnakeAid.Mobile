import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/member_profile.dart';

final memberProfileRepositoryProvider = Provider<MemberProfileRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return MemberProfileRepository(httpService: httpService);
});

class MemberProfileRepository {
  final HttpService _httpService;

  MemberProfileRepository({required HttpService httpService})
      : _httpService = httpService;

  /// GET /api/members/me/profile
  Future<MemberProfile> getMyProfile() async {
    final response = await _httpService.get('/api/members/me/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return MemberProfile.fromJson(data);
  }

  /// PUT /api/members/me/profile
  Future<MemberProfile> updateMyProfile({
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    required List<String> emergencyContacts,
    required bool hasUnderlyingDisease,
  }) async {
    final response = await _httpService.put(
      '/api/members/me/profile',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'emergencyContacts': emergencyContacts,
        'hasUnderlyingDisease': hasUnderlyingDisease,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return MemberProfile.fromJson(data);
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
