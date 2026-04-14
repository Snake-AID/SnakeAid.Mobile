enum PayOsFlowType {
  topup,
  consultation,
  snakebiteIncident,
  snakeCatchingDeposit,
  snakeCatchingPayment,
}

extension PayOsFlowTypeX on PayOsFlowType {
  String get prefix {
    return switch (this) {
      PayOsFlowType.topup => 'TOPUP-',
      PayOsFlowType.consultation => 'CONSULTPAY-',
      PayOsFlowType.snakebiteIncident => 'INCIDENT-',
      PayOsFlowType.snakeCatchingDeposit => 'CATCHING-',
      PayOsFlowType.snakeCatchingPayment => 'CATCHING-',
    };
  }

  String get expectedTransactionType {
    return switch (this) {
      PayOsFlowType.topup => 'WalletTopup',
      PayOsFlowType.consultation => 'ConsultationPayment',
      PayOsFlowType.snakebiteIncident => 'SnakebiteIncidentPayment',
      PayOsFlowType.snakeCatchingDeposit => 'CatchingDeposit',
      PayOsFlowType.snakeCatchingPayment => 'CatchingPayment',
    };
  }

  String get storageValue {
    return switch (this) {
      PayOsFlowType.topup => 'topup',
      PayOsFlowType.consultation => 'consultation',
      PayOsFlowType.snakebiteIncident => 'snakebiteIncident',
      PayOsFlowType.snakeCatchingDeposit => 'snakeCatchingDeposit',
      PayOsFlowType.snakeCatchingPayment => 'snakeCatchingPayment',
    };
  }

  static PayOsFlowType fromStorageValue(String value) {
    return PayOsFlowType.values.firstWhere(
      (flow) => flow.storageValue == value,
      orElse: () => PayOsFlowType.topup,
    );
  }
}

class PayOsPendingContext {
  final PayOsFlowType flowType;
  final String transactionId;
  final int? orderCode;
  final String? referenceId;
  final DateTime startedAt;

  const PayOsPendingContext({
    required this.flowType,
    required this.transactionId,
    required this.startedAt,
    this.orderCode,
    this.referenceId,
  });

  String get expectedPrefix => flowType.prefix;
  String get expectedTransactionType => flowType.expectedTransactionType;

  Map<String, dynamic> toJson() {
    return {
      'flowType': flowType.storageValue,
      'transactionId': transactionId,
      'orderCode': orderCode,
      'referenceId': referenceId,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory PayOsPendingContext.fromJson(Map<String, dynamic> json) {
    return PayOsPendingContext(
      flowType: PayOsFlowTypeX.fromStorageValue(
        json['flowType']?.toString() ?? '',
      ),
      transactionId: json['transactionId']?.toString() ?? '',
      orderCode: json['orderCode'] is int
          ? json['orderCode'] as int
          : int.tryParse(json['orderCode']?.toString() ?? ''),
      referenceId: json['referenceId']?.toString(),
      startedAt:
          DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
