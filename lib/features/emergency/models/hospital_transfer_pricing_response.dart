import 'package:json_annotation/json_annotation.dart';

part 'hospital_transfer_pricing_response.g.dart';

/// Hospital Transfer Pricing API Response (with envelope)
class HospitalTransferPricingApiResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final HospitalTransferPricingResponse? data;
  final dynamic error;

  HospitalTransferPricingApiResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory HospitalTransferPricingApiResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return HospitalTransferPricingApiResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? HospitalTransferPricingResponse.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }
}

/// Hospital Transfer Pricing Response
/// Contains pricing information and selected hospital details
@JsonSerializable()
class HospitalTransferPricingResponse {
  /// Selected hospital ID
  @JsonKey(name: 'hospitalId')
  final int hospitalId;

  /// Hospital name
  @JsonKey(name: 'hospitalName')
  final String hospitalName;

  /// Distance to hospital (from client navigation/routing API)
  @JsonKey(name: 'distanceKm')
  final double distanceKm;

  /// Price per kilometer (from system config)
  @JsonKey(name: 'pricePerKm')
  final double pricePerKm;

  /// Additional price for hospital transfer
  @JsonKey(name: 'hospitalTransferPrice')
  final double hospitalTransferPrice;

  /// Original mission price (rescue service)
  @JsonKey(name: 'baseMissionPrice')
  final double baseMissionPrice;

  /// Total price including hospital transfer
  @JsonKey(name: 'totalPrice')
  final double totalPrice;

  /// Timestamp when pricing was calculated
  @JsonKey(name: 'calculatedAt')
  final DateTime calculatedAt;

  HospitalTransferPricingResponse({
    required this.hospitalId,
    required this.hospitalName,
    required this.distanceKm,
    required this.pricePerKm,
    required this.hospitalTransferPrice,
    required this.baseMissionPrice,
    required this.totalPrice,
    required this.calculatedAt,
  });

  factory HospitalTransferPricingResponse.fromJson(Map<String, dynamic> json) =>
      _$HospitalTransferPricingResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HospitalTransferPricingResponseToJson(this);
}
