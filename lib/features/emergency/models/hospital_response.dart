import 'package:json_annotation/json_annotation.dart';

part 'hospital_response.g.dart';

@JsonSerializable()
class HospitalResponse {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'contactNumber')
  final String? contactNumber;

  @JsonKey(name: 'distanceKm')
  final double distanceKm;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  HospitalResponse({
    required this.id,
    required this.name,
    required this.address,
    this.contactNumber,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
  });

  factory HospitalResponse.fromJson(Map<String, dynamic> json) =>
      _$HospitalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HospitalResponseToJson(this);
}

class HospitalApiResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<HospitalResponse>? data;
  final String? error;

  HospitalApiResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory HospitalApiResponse.fromJson(Map<String, dynamic> json) {
    return HospitalApiResponse(
      statusCode: json['status_code'] ?? json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? json['isSuccess'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((e) => HospitalResponse.fromJson(e))
                .toList()
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'HospitalApiResponse(isSuccess: $isSuccess, message: $message)';
}
