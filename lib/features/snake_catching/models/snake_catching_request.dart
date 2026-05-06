/// Model for creating a snake catching request
class SnakeCatchingRequest {
  final String address;
  final double lng;
  final double lat;
  final String? additionalDetails;
  final String? notes;
  final List<SnakeSpeciesItem> snakeSpeciesList;
  // Media IDs from uploaded photos (optional — attached for AI detection history)
  final List<String>? mediaIdList;

  SnakeCatchingRequest({
    required this.address,
    required this.lng,
    required this.lat,
    this.additionalDetails,
    this.notes,
    required this.snakeSpeciesList,
    this.mediaIdList,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lng': lng,
      'lat': lat,
      if (additionalDetails != null) 'additionalDetails': additionalDetails,
      if (notes != null) 'notes': notes,
      'snakeSpeciesList': snakeSpeciesList.map((e) => e.toJson()).toList(),
      if (mediaIdList != null && mediaIdList!.isNotEmpty)
        'mediaIdList': mediaIdList,
    };
  }
}

/// Snake species item with quantity (for request)
class SnakeSpeciesItem {
  final int snakeSpeciesId;
  final int quantity;

  SnakeSpeciesItem({required this.snakeSpeciesId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'snakeSpeciesId': snakeSpeciesId, 'quantity': quantity};
  }
}

/// API Response wrapper
class SnakeCatchingResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final SnakeCatchingRequestData? data;
  final String? error;

  SnakeCatchingResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory SnakeCatchingResponse.fromJson(Map<String, dynamic> json) {
    return SnakeCatchingResponse(
      statusCode: json['status_code'] as int,
      message: json['message'] as String? ?? '',
      isSuccess: json['is_success'] as bool? ?? false,
      data: json['data'] != null
          ? SnakeCatchingRequestData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      error: json['error'] as String?,
    );
  }
}

/// API List Response wrapper
class SnakeCatchingListResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<SnakeCatchingRequestData> data;
  final String? error;

  SnakeCatchingListResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    required this.data,
    this.error,
  });

  factory SnakeCatchingListResponse.fromJson(Map<String, dynamic> json) {
    return SnakeCatchingListResponse(
      statusCode: json['status_code'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      isSuccess: json['is_success'] as bool? ?? true,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => SnakeCatchingRequestData.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }
}

/// Rescuer info embedded in an assigned snake catching request
class AssignedRescuerInfo {
  final String accountId;
  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? email;
  final double? rating;
  final int? ratingCount;

  AssignedRescuerInfo({
    required this.accountId,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.email,
    this.rating,
    this.ratingCount,
  });

  factory AssignedRescuerInfo.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested account structure
    final account = json['account'] as Map<String, dynamic>?;
    return AssignedRescuerInfo(
      accountId: json['accountId'] as String? ?? '',
      fullName:
          (json['fullName'] as String?) ??
          (account?['fullName'] as String?) ??
          (json['userName'] as String?),
      avatarUrl:
          (json['avatarUrl'] as String?) ?? (account?['avatarUrl'] as String?),
      phoneNumber: json['phoneNumber'] as String?,
      email: (json['email'] as String?) ?? (account?['email'] as String?),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
    );
  }
}

/// Feedback/rating on a snake catching request
class FeedbackItem {
  final String id;
  final String referenceId;
  final String type;
  final String raterId;
  final String targetUserId;
  final String? targetUserRole;
  final int rating;
  final String? comments;
  final DateTime? createdAt;

  const FeedbackItem({
    required this.id,
    required this.referenceId,
    required this.type,
    required this.raterId,
    required this.targetUserId,
    this.targetUserRole,
    required this.rating,
    this.comments,
    this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      raterId: json['raterId'] as String? ?? '',
      targetUserId: json['targetUserId'] as String? ?? '',
      targetUserRole: json['targetUserRole'] as String?,
      rating: json['rating'] as int? ?? 0,
      comments: json['comments'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Snake catching request data (the main data object)
class SnakeCatchingRequestData {
  final String id;
  final String userId;
  final String address;
  final LocationCoordinates locationCoordinates;
  final double lng;
  final double lat;
  final String? additionalDetails;
  final String status;
  final String priority;
  final DateTime requestDate;
  final DateTime? preferredTime;
  final DateTime? assignedAt;
  final String? assignedRescuerId;
  final AssignedRescuerInfo? assignedRescuer;
  final double? estimatedPrice;
  final double? distanceKm;
  final String? cancellationReason;
  final String? notes;
  final RequestUserInfo? user;
  final MissionData? mission;
  final List<RequestMedia> media;
  final List<SnakeSpeciesDetail> details;
  final List<FeedbackItem> feedbacks;

  SnakeCatchingRequestData({
    required this.id,
    required this.userId,
    required this.address,
    required this.locationCoordinates,
    required this.lng,
    required this.lat,
    this.additionalDetails,
    required this.status,
    required this.priority,
    required this.requestDate,
    this.preferredTime,
    this.assignedAt,
    this.assignedRescuerId,
    this.assignedRescuer,
    this.estimatedPrice,
    this.distanceKm,
    this.cancellationReason,
    this.notes,
    this.user,
    this.mission,
    this.media = const [],
    required this.details,
    this.feedbacks = const [],
  });

  factory SnakeCatchingRequestData.fromJson(Map<String, dynamic> json) {
    return SnakeCatchingRequestData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      address: json['address'] as String? ?? '',
      locationCoordinates: LocationCoordinates.fromJson(
        json['locationCoordinates'] as Map<String, dynamic>? ?? {},
      ),
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      additionalDetails: json['additionalDetails'] as String?,
      status: json['status'] as String? ?? 'Pending',
      priority: json['priority'] as String? ?? 'Normal',
      requestDate: DateTime.parse(json['requestDate'] as String),
      preferredTime: json['preferredTime'] != null
          ? DateTime.parse(json['preferredTime'] as String)
          : null,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      // Prefer top-level field; fall back to assignedRescuer.accountId
      assignedRescuerId:
          (json['assignedRescuerId'] as String?) ??
          (json['assignedRescuer'] as Map<String, dynamic>?)?['accountId']
              as String?,
      assignedRescuer: json['assignedRescuer'] != null
          ? AssignedRescuerInfo.fromJson(
              json['assignedRescuer'] as Map<String, dynamic>,
            )
          : null,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      cancellationReason: json['cancellationReason'] as String?,
      notes: json['notes'] as String?,
      user: json['user'] != null
          ? RequestUserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      mission: json['mission'] != null
          ? MissionData.fromJson(json['mission'] as Map<String, dynamic>)
          : (json['missions'] as List<dynamic>?)?.isNotEmpty == true
          ? MissionData.fromJson(
              (json['missions'] as List<dynamic>).first as Map<String, dynamic>,
            )
          : null,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => RequestMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      details:
          (json['details'] as List<dynamic>?)
              ?.map(
                (e) => SnakeSpeciesDetail.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      feedbacks:
          (json['feedbacks'] as List<dynamic>?)
              ?.map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Location coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({required this.latitude, required this.longitude});

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Snake species detail (from response)
class SnakeSpeciesDetail {
  final String id;
  final String snakeCatchingRequestId;
  final int snakeSpeciesId;
  final int quantity;
  final String snakeSpeciesName;
  final String snakeSpeciesScientificName;

  SnakeSpeciesDetail({
    required this.id,
    required this.snakeCatchingRequestId,
    required this.snakeSpeciesId,
    required this.quantity,
    required this.snakeSpeciesName,
    required this.snakeSpeciesScientificName,
  });

  factory SnakeSpeciesDetail.fromJson(Map<String, dynamic> json) {
    return SnakeSpeciesDetail(
      id: json['id'] as String,
      snakeCatchingRequestId: json['snakeCatchingRequestId'] as String,
      snakeSpeciesId: json['snakeSpeciesId'] as int,
      quantity: json['quantity'] as int,
      snakeSpeciesName: json['snakeSpeciesName'] as String? ?? '',
      snakeSpeciesScientificName:
          json['snakeSpeciesScientificName'] as String? ?? '',
    );
  }
}

/// User information from snake catching request
class RequestUserInfo {
  final String accountId;
  final String userName;
  final String email;
  final String phoneNumber;
  final double rating;
  final int ratingCount;
  final List<String> emergencyContacts;
  final bool hasUnderlyingDisease;
  final RequestAccount? account;

  RequestUserInfo({
    required this.accountId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.rating,
    required this.ratingCount,
    this.emergencyContacts = const [],
    required this.hasUnderlyingDisease,
    this.account,
  });

  factory RequestUserInfo.fromJson(Map<String, dynamic> json) {
    return RequestUserInfo(
      accountId: json['accountId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      emergencyContacts:
          (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hasUnderlyingDisease: json['hasUnderlyingDisease'] as bool? ?? false,
      account: json['account'] != null
          ? RequestAccount.fromJson(json['account'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Account information
class RequestAccount {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;

  RequestAccount({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
  });

  factory RequestAccount.fromJson(Map<String, dynamic> json) {
    return RequestAccount(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'User',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Catching environment embedded in mission (e.g. "Tại nhà")
class CatchingEnvironmentInfo {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? currency;

  const CatchingEnvironmentInfo({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency,
  });

  factory CatchingEnvironmentInfo.fromJson(Map<String, dynamic> json) {
    return CatchingEnvironmentInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String?,
    );
  }
}

/// A single snake detail line inside a mission (after rescuer confirms)
class MissionDetailItem {
  final String id;
  final String snakeCatchingMissionId;
  final int snakeSpeciesId;
  final String snakeSpeciesName;
  final int quantity;
  final double price;

  const MissionDetailItem({
    required this.id,
    required this.snakeCatchingMissionId,
    required this.snakeSpeciesId,
    required this.snakeSpeciesName,
    required this.quantity,
    required this.price,
  });

  factory MissionDetailItem.fromJson(Map<String, dynamic> json) {
    return MissionDetailItem(
      id: json['id'] as String? ?? '',
      snakeCatchingMissionId: json['snakeCatchingMissionId'] as String? ?? '',
      snakeSpeciesId: json['snakeSpeciesId'] as int? ?? 0,
      snakeSpeciesName: json['snakeSpeciesName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Mission data from accepted request
class MissionData {
  final String id;
  final String rescuerId;
  final String snakeCatchingRequestId;
  final String status;

  /// Base service fee (e.g. 500 000 VNĐ) — platform's fixed charge
  final double? price;

  /// Travel/deposit fee already paid by customer in round 1
  final double? estimatedCost;

  /// Total round-2 payment = price + snakeFee + envFee
  final double? actualCost;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? cancellationReason;
  final CatchingEnvironmentInfo? catchingEnvironment;
  final List<MissionDetailItem> missionDetails;

  /// Evidence photos uploaded during this mission
  final List<RequestMedia> media;

  MissionData({
    required this.id,
    required this.rescuerId,
    required this.snakeCatchingRequestId,
    required this.status,
    this.price,
    this.estimatedCost,
    this.actualCost,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.notes,
    this.cancellationReason,
    this.catchingEnvironment,
    this.missionDetails = const [],
    this.media = const [],
  });

  factory MissionData.fromJson(Map<String, dynamic> json) {
    return MissionData(
      id: json['id'] as String? ?? '',
      rescuerId: json['rescuerId'] as String? ?? '',
      snakeCatchingRequestId: json['snakeCatchingRequestId'] as String? ?? '',
      status: json['status'] as String? ?? 'Preparing',
      price: (json['price'] as num?)?.toDouble(),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      actualCost: (json['actualCost'] as num?)?.toDouble(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      arrivedAt: json['arrivedAt'] != null
          ? DateTime.parse(json['arrivedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      catchingEnvironment: json['catchingEnvironment'] != null
          ? CatchingEnvironmentInfo.fromJson(
              json['catchingEnvironment'] as Map<String, dynamic>,
            )
          : null,
      missionDetails:
          (json['missionDetails'] as List<dynamic>?)
              ?.map(
                (e) => MissionDetailItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => RequestMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Media information from request
class RequestMedia {
  final String id;
  final String url;
  final String type;
  final String? purpose;
  final DateTime? createdAt;

  RequestMedia({
    required this.id,
    required this.url,
    required this.type,
    this.purpose,
    this.createdAt,
  });

  factory RequestMedia.fromJson(Map<String, dynamic> json) {
    return RequestMedia(
      id: json['id'] as String? ?? '',
      // API may return 'mediaUrl' (rescuer uploads) or 'url' (member uploads)
      url: json['mediaUrl'] as String? ?? json['url'] as String? ?? '',
      type:
          json['contentType'] as String? ?? json['type'] as String? ?? 'image',
      purpose: json['purpose'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
