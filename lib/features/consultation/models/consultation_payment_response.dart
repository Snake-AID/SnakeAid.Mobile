class ConsultationPaymentResponse {
  final String referenceId;
  final String referenceType;
  final String transactionId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final double? userWalletBalanceAfter;
  final double? systemWalletBalanceAfter;
  final DateTime? paidAtUtc;
  final String? provider;
  final String? checkoutUrl;
  final int? orderCode;
  final String? paymentLinkId;
  final String? externalTransactionId;

  const ConsultationPaymentResponse({
    required this.referenceId,
    required this.referenceType,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.userWalletBalanceAfter,
    this.systemWalletBalanceAfter,
    this.paidAtUtc,
    this.provider,
    this.checkoutUrl,
    this.orderCode,
    this.paymentLinkId,
    this.externalTransactionId,
  });

  bool get isEscrowed => status.toLowerCase() == 'escrowed';
  bool get isPending => status.toLowerCase() == 'pending';

  factory ConsultationPaymentResponse.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return ConsultationPaymentResponse(
      referenceId: (json['referenceId'] ?? '').toString(),
      referenceType: (json['referenceType'] ?? '').toString(),
      transactionId: (json['transactionId'] ?? '').toString(),
      amount: parseDouble(json['amount']) ?? 0,
      currency: (json['currency'] ?? 'VND').toString(),
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      userWalletBalanceAfter: parseDouble(json['userWalletBalanceAfter']),
      systemWalletBalanceAfter: parseDouble(json['systemWalletBalanceAfter']),
      paidAtUtc: json['paidAtUtc'] != null
          ? DateTime.tryParse(json['paidAtUtc'].toString())
          : null,
      provider: json['provider']?.toString(),
      checkoutUrl: json['checkoutUrl']?.toString(),
      orderCode: parseInt(json['orderCode']),
      paymentLinkId: json['paymentLinkId']?.toString(),
      externalTransactionId: json['externalTransactionId']?.toString(),
    );
  }
}
