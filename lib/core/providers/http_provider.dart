import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';

// Thay đổi URL này thành URL backend của bạn
const String baseUrl =
    'http://192.168.0.110:5000/api'; // hoặc http://10.0.2.2:5000/api cho Android Emulator

// Provider cho HttpService
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService(baseUrl: baseUrl);
});
