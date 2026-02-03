import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';

const String baseUrl = 'https://snakeaid.duykhiem.id.vn';
// const String baseUrl = 'http://10.0.2.2:8080';
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService(baseUrl: baseUrl);
});
