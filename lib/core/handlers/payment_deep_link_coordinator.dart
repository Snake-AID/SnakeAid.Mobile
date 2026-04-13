import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentDeepLinkEvent {
  final int eventId;
  final Uri uri;
  final bool isSuccess;
  final bool isCancelled;
  final String? status;
  final String? id;
  final String? reason;
  final int? orderCode;

  const PaymentDeepLinkEvent({
    required this.eventId,
    required this.uri,
    required this.isSuccess,
    required this.isCancelled,
    this.status,
    this.id,
    this.reason,
    this.orderCode,
  });

  static PaymentDeepLinkEvent? tryParse(Uri uri) {
    final isSnakeAidScheme = uri.scheme == 'snakeaid' && uri.host == 'payment';
    final isHttpsCallback =
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == 'snakeaid-dev.duykhiem.id.vn' &&
        uri.path.startsWith('/payos/');

    if (!isSnakeAidScheme && !isHttpsCallback) {
      return null;
    }

    final status = uri.queryParameters['status'];
    final cancelParam = _parseBool(uri.queryParameters['cancel']) ?? false;
    final successParam = _parseBool(uri.queryParameters['success']);
    final normalizedStatus = status?.toUpperCase();
    final path = uri.path.toLowerCase();

    final isCancelled =
        cancelParam ||
        normalizedStatus == 'CANCELLED' ||
        normalizedStatus == 'CANCELED' ||
        normalizedStatus == 'FAILED' ||
        path.endsWith('/cancel');

    final isSuccess =
        successParam ??
        (!isCancelled &&
            (normalizedStatus == 'PAID' ||
                normalizedStatus == 'SUCCESS' ||
                normalizedStatus == 'COMPLETED' ||
                path.endsWith('/return') ||
                path.endsWith('/success')));

    return PaymentDeepLinkEvent(
      eventId: DateTime.now().microsecondsSinceEpoch,
      uri: uri,
      isSuccess: isSuccess,
      isCancelled: isCancelled,
      status: status,
      id: uri.queryParameters['id'],
      reason: uri.queryParameters['reason'],
      orderCode: int.tryParse(uri.queryParameters['orderCode'] ?? ''),
    );
  }

  static bool? _parseBool(String? value) {
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }
}

class PaymentDeepLinkCoordinator {
  PaymentDeepLinkCoordinator._();

  static final PaymentDeepLinkCoordinator instance =
      PaymentDeepLinkCoordinator._();

  final StreamController<PaymentDeepLinkEvent> _controller =
      StreamController<PaymentDeepLinkEvent>.broadcast();

  PaymentDeepLinkEvent? _latestEvent;

  Stream<PaymentDeepLinkEvent> get stream => _controller.stream;
  PaymentDeepLinkEvent? get latestEvent => _latestEvent;

  bool tryPublish(Uri uri) {
    final event = PaymentDeepLinkEvent.tryParse(uri);
    if (event == null) {
      return false;
    }

    _latestEvent = event;
    _controller.add(event);
    return true;
  }
}

final paymentDeepLinkCoordinatorProvider =
    Provider<PaymentDeepLinkCoordinator>((ref) {
      return PaymentDeepLinkCoordinator.instance;
    });
