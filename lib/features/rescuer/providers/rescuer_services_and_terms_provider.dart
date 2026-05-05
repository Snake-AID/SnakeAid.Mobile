import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../snake_catching/repository/system_settings_repository.dart';
import '../models/rescuer_services_and_terms.dart';

const _rescuerServicesAndTermsKey = 'Rescuer:ServicesAndTerms';
const _rescuerServicesAndTermsTtl = Duration(minutes: 10);

final rescuerServicesAndTermsProvider =
    FutureProvider.autoDispose<RescuerServicesAndTerms>((ref) async {
      final link = ref.keepAlive();
      Timer? ttlTimer;

      void startTtlTimer() {
        ttlTimer?.cancel();
        ttlTimer = Timer(_rescuerServicesAndTermsTtl, link.close);
      }

      startTtlTimer();
      ref.onCancel(startTtlTimer);
      ref.onResume(() => ttlTimer?.cancel());
      ref.onDispose(() => ttlTimer?.cancel());

      final repository = ref.watch(systemSettingsRepositoryProvider);
      final setting = await repository.getSystemSettingByKey(
        _rescuerServicesAndTermsKey,
      );

      if (setting == null || setting.value.trim().isEmpty) {
        throw Exception(
          'Không tìm thấy dữ liệu hướng dẫn và chính sách cho đội cứu hộ.',
        );
      }

      return RescuerServicesAndTerms.fromSettingValue(setting.value);
    });
