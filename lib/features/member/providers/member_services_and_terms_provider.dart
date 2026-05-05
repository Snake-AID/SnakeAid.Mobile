import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../snake_catching/repository/system_settings_repository.dart';
import '../models/member_services_and_terms.dart';

const _memberServicesAndTermsKey = 'Member:ServicesAndTerms';
const _memberServicesAndTermsTtl = Duration(minutes: 10);

final memberServicesAndTermsProvider =
    FutureProvider.autoDispose<MemberServicesAndTerms>((ref) async {
      final link = ref.keepAlive();
      Timer? ttlTimer;

      void startTtlTimer() {
        ttlTimer?.cancel();
        ttlTimer = Timer(_memberServicesAndTermsTtl, link.close);
      }

      startTtlTimer();
      ref.onCancel(startTtlTimer);
      ref.onResume(() => ttlTimer?.cancel());
      ref.onDispose(() => ttlTimer?.cancel());

      final repository = ref.watch(systemSettingsRepositoryProvider);
      final setting = await repository.getSystemSettingByKey(
        _memberServicesAndTermsKey,
      );

      if (setting == null || setting.value.trim().isEmpty) {
        throw Exception(
          'Không tìm thấy dữ liệu hướng dẫn và chính sách cho member.',
        );
      }

      return MemberServicesAndTerms.fromSettingValue(setting.value);
    });
