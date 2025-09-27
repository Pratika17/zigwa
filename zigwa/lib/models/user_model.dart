class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? profileImage;
  final DateTime createdAt;
  final bool isActive;
  final double? rating;
  final int? completedTasks;
  final double? totalEarnings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
    this.rating,
    this.completedTasks,
    this.totalEarnings,
  });

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
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      rating: json['rating']?.toDouble(),
      completedTasks: json['completedTasks'],
      totalEarnings: json['totalEarnings']?.toDouble(),
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
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'rating': rating,
      'completedTasks': completedTasks,
      'totalEarnings': totalEarnings,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserType? userType,
    String? profileImage,
    DateTime? createdAt,
    bool? isActive,
    double? rating,
    int? completedTasks,
    double? totalEarnings,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      completedTasks: completedTasks ?? this.completedTasks,
      totalEarnings: totalEarnings ?? this.totalEarnings,
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
