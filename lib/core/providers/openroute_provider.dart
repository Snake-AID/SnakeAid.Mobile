import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/openroute_service.dart';
import '../interceptors/logging_interceptor.dart';

/// Provider for OpenRouteService
final openRouteServiceProvider = Provider<OpenRouteService>((ref) {
  // Create dedicated Dio instance for OpenRoute (external API)
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openrouteservice.org',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Only add LoggingInterceptor (no TokenRefreshInterceptor needed)
  dio.interceptors.add(LoggingInterceptor());

  return OpenRouteService(dio);
});
