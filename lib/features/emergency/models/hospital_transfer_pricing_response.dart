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
  @JsonKey(name: 'hospitalId')
  final int hospitalId;

  @JsonKey(name: 'hospitalName')
  final String hospitalName;

  @JsonKey(name: 'requiresHospitalization')
  final bool requiresHospitalization;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  HospitalTransferPricingResponse({
    required this.hospitalId,
    required this.hospitalName,
    required this.requiresHospitalization,
    required this.updatedAt,
  });

  factory HospitalTransferPricingResponse.fromJson(Map<String, dynamic> json) =>
      _$HospitalTransferPricingResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HospitalTransferPricingResponseToJson(this);
}
