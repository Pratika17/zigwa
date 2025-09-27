class TrashReportModel {
  final String id;
  final String userId;
  final String userName;
  final List<String> imageUrls;
  final LocationModel location;
  final String description;
  final TrashType trashType;
  final TrashStatus status;
  final DateTime reportedAt;
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
    required this.userName,
    required this.imageUrls,
    required this.location,
    required this.description,
    required this.trashType,
    required this.status,
    required this.reportedAt,
    this.collectedAt,
    this.processedAt,
    this.collectorId,
    this.collectorName,
    this.dealerId,
    this.dealerName,
    this.estimatedValue,
    this.actualValue,
    this.payment,
  });

  factory TrashReportModel.fromJson(Map<String, dynamic> json) {
    return TrashReportModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      imageUrls: List<String>.from(json['imageUrls']),
      location: LocationModel.fromJson(json['location']),
      description: json['description'],
      trashType: TrashType.values.firstWhere(
        (type) => type.toString().split('.').last == json['trashType'],
      ),
      status: TrashStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      reportedAt: DateTime.parse(json['reportedAt']),
      collectedAt: json['collectedAt'] != null ? DateTime.parse(json['collectedAt']) : null,
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : null,
      collectorId: json['collectorId'],
      collectorName: json['collectorName'],
      dealerId: json['dealerId'],
      dealerName: json['dealerName'],
      estimatedValue: json['estimatedValue']?.toDouble(),
      actualValue: json['actualValue']?.toDouble(),
      payment: json['payment'] != null ? PaymentModel.fromJson(json['payment']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'imageUrls': imageUrls,
      'location': location.toJson(),
      'description': description,
      'trashType': trashType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reportedAt': reportedAt.toIso8601String(),
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
