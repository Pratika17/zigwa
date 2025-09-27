class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? profileImage;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double? rating;
  final int? completedTasks;
  final double? totalEarnings;
  final int totalReports;
  final String password;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    this.profileImageUrl,
    required this.createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.rating = 5.0,
    this.completedTasks = 0,
    this.totalEarnings = 0.0,
    this.totalReports = 0,
    this.password = '',
    this.address,
  }) : updatedAt = updatedAt ?? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      userType: UserType.values.firstWhere(
        (type) => type.toString().split('.').last == json['userType'],
      ),
      profileImage: json['profileImage'],
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : 
                 json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      rating: json['rating']?.toDouble() ?? 5.0,
      completedTasks: json['completedTasks'] ?? json['completed_tasks'] ?? 0,
      totalEarnings: json['totalEarnings']?.toDouble() ?? json['total_earnings']?.toDouble() ?? 0.0,
      totalReports: json['totalReports'] ?? json['total_reports'] ?? 0,
      password: json['password'] ?? '',
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'profileImage': profileImage,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'rating': rating,
      'completedTasks': completedTasks,
      'totalEarnings': totalEarnings,
      'totalReports': totalReports,
      'password': password,
      'address': address,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    String? profileImage,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
    int? completedTasks,
    double? totalEarnings,
    int? totalReports,
    String? password,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      completedTasks: completedTasks ?? this.completedTasks,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalReports: totalReports ?? this.totalReports,
      password: password ?? this.password,
      address: address ?? this.address,
    );
  }
}

enum UserType {
  user,
  collectionWorker,
  dealer,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.user:
        return 'User';
      case UserType.collectionWorker:
        return 'Collection Worker';
      case UserType.dealer:
        return 'Dealer';
    }
  }

  String get description {
    switch (this) {
      case UserType.user:
        return 'Report trash and earn rewards';
      case UserType.collectionWorker:
        return 'Collect trash and earn money';
      case UserType.dealer:
        return 'Process waste and manage payments';
    }
  }
}
