import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../snake_catching/repository/system_settings_repository.dart';
import '../models/expert_services_and_terms.dart';

/// Provider for Expert:ServicesAndTerms with TTL-based caching
/// Auto-disposes after 10 minutes of inactivity
final expertServicesAndTermsProvider =
    FutureProvider.autoDispose<ExpertServicesAndTerms>((ref) async {
      final repository = ref.watch(systemSettingsRepositoryProvider);

      // Fetch the setting by key
      final setting = await repository.getSystemSettingByKey(
        'Expert:ServicesAndTerms',
      );

      if (setting == null || setting.value.trim().isEmpty) {
        throw Exception('Không tìm thấy dữ liệu Expert:ServicesAndTerms');
      }

      // Parse the setting value and create model
      final termsAndServices = ExpertServicesAndTerms.fromSettingValue(
        setting.value,
      );

      // Set up TTL cache: keep alive for 10 minutes, then invalidate
      ref.keepAlive();
      Timer(const Duration(minutes: 10), () => ref.invalidateSelf());

      return termsAndServices;
    });
