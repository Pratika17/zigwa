class TrashReportModel {
  final String id;
  final String userId;
  final String? userName;
  final List<String>? imageUrls;
  final String? imagePath;
  final LocationModel location;
  final String description;
  final TrashType trashType;
  final TrashStatus status;
  final DateTime reportedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? collectedAt;
  final DateTime? processedAt;
  final String? collectorId;
  final String? collectorName;
  final String? dealerId;
  final String? dealerName;
  final double? estimatedValue;
  final double? actualValue;
  final PaymentModel? payment;

  TrashReportModel({
    required this.id,
    required this.userId,
    this.userName,
    this.imageUrls,
    this.imagePath,
    required this.location,
    required this.description,
    required this.trashType,
    required this.status,
    DateTime? reportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.collectedAt,
    this.processedAt,
    this.collectorId,
    this.collectorName,
    this.dealerId,
    this.dealerName,
    this.estimatedValue,
    this.actualValue,
    this.payment,
  }) : reportedAt = reportedAt ?? createdAt ?? DateTime.now(),
       createdAt = createdAt ?? reportedAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? reportedAt ?? DateTime.now();

  factory TrashReportModel.fromJson(Map<String, dynamic> json) {
    return TrashReportModel(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      userName: json['userName'] ?? json['user_name'],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
      imagePath: json['imagePath'] ?? json['image_path'],
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : 
                LocationModel(
                  latitude: json['latitude']?.toDouble() ?? 0.0,
                  longitude: json['longitude']?.toDouble() ?? 0.0,
                  address: json['address'] ?? '',
                ),
      description: json['description'] ?? '',
      trashType: TrashType.values.firstWhere(
        (type) => type.toString().split('.').last == (json['trashType'] ?? json['trash_type']),
      ),
      status: TrashStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      reportedAt: json['reportedAt'] != null ? DateTime.parse(json['reportedAt']) : 
                  json['reported_at'] != null ? DateTime.parse(json['reported_at']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : 
                 json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : 
                 json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      collectedAt: json['collectedAt'] != null ? DateTime.parse(json['collectedAt']) : 
                   json['collected_at'] != null ? DateTime.parse(json['collected_at']) : null,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : 
                   json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
      collectorId: json['collectorId'] ?? json['collector_id'],
      collectorName: json['collectorName'] ?? json['collector_name'],
      dealerId: json['dealerId'] ?? json['dealer_id'],
      dealerName: json['dealerName'] ?? json['dealer_name'],
      estimatedValue: json['estimatedValue']?.toDouble() ?? json['estimated_value']?.toDouble(),
      actualValue: json['actualValue']?.toDouble() ?? json['actual_value']?.toDouble(),
      payment: json['payment'] != null ? PaymentModel.fromJson(json['payment']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'imageUrls': imageUrls,
      'imagePath': imagePath,
      'location': location.toJson(),
      'description': description,
      'trashType': trashType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reportedAt': reportedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'collectedAt': collectedAt?.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'collectorId': collectorId,
      'collectorName': collectorName,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'estimatedValue': estimatedValue,
      'actualValue': actualValue,
      'payment': payment?.toJson(),
    };
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final String? landmark;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
    };
  }
}

class PaymentModel {
  final String id;
  final double totalAmount;
  final double userAmount; // 25%
  final double collectorAmount; // 65%
  final double platformFee; // 10%
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentModel({
    required this.id,
    required this.totalAmount,
    required this.userAmount,
    required this.collectorAmount,
    required this.platformFee,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      totalAmount: json['totalAmount'].toDouble(),
      userAmount: json['userAmount'].toDouble(),
      collectorAmount: json['collectorAmount'].toDouble(),
      platformFee: json['platformFee'].toDouble(),
      status: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'userAmount': userAmount,
      'collectorAmount': collectorAmount,
      'platformFee': platformFee,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}

enum TrashType {
  plastic,
  paper,
  metal,
  glass,
  organic,
  electronic,
  mixed,
}

enum TrashStatus {
  reported,
  assigned,
  collected,
  processed,
  paid,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
}

extension TrashTypeExtension on TrashType {
  String get displayName {
    switch (this) {
      case TrashType.plastic:
        return 'Plastic';
      case TrashType.paper:
        return 'Paper';
      case TrashType.metal:
        return 'Metal';
      case TrashType.glass:
        return 'Glass';
      case TrashType.organic:
        return 'Organic';
      case TrashType.electronic:
        return 'Electronic';
      case TrashType.mixed:
        return 'Mixed';
    }
  }
}

extension TrashStatusExtension on TrashStatus {
  String get displayName {
    switch (this) {
      case TrashStatus.reported:
        return 'Reported';
      case TrashStatus.assigned:
        return 'Assigned';
      case TrashStatus.collected:
        return 'Collected';
      case TrashStatus.processed:
        return 'Processed';
      case TrashStatus.paid:
        return 'Paid';
    }
  }
}
