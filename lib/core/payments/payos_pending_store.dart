import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'payos_pending_context.dart';

class PayOsPendingStore {
  final String storageKey;

  const PayOsPendingStore(this.storageKey);

  Future<void> save(PayOsPendingContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(context.toJson()));
  }

  Future<PayOsPendingContext?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return PayOsPendingContext.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
