import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/trash_report_model.dart';
import '../providers/notification_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'zigwa.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        user_type TEXT NOT NULL,
        password TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        total_earnings REAL NOT NULL DEFAULT 0.0,
        total_reports INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 5.0,
        profile_image_url TEXT,
        address TEXT
      )
    ''');

    // Trash reports table
    await db.execute('''
      CREATE TABLE trash_reports (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        collector_id TEXT,
        dealer_id TEXT,
        trash_type TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        estimated_value REAL NOT NULL DEFAULT 0.0,
        actual_value REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        collected_at TEXT,
        processed_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (collector_id) REFERENCES users (id),
        FOREIGN KEY (dealer_id) REFERENCES users (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        data TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        trash_report_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        collector_id TEXT NOT NULL,
        dealer_id TEXT,
        total_amount REAL NOT NULL,
        user_amount REAL NOT NULL,
        collector_amount REAL NOT NULL,
        platform_fee REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        processed_at TEXT,
        FOREIGN KEY (trash_report_id) REFERENCES trash_reports (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (collector_id) REFERENCES users (id),
        FOREIGN KEY (dealer_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<String?> insertUser(UserModel user) async {
    try {
      final db = await database;
      await db.insert('users', _userToMap(user));
      return user.id;
    } catch (e) {
      print('Error inserting user: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmailAndPassword(String email, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (maps.isNotEmpty) {
        return _mapToUser(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email and password: $e');
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      final db = await database;
      final result = await db.update(
        'users',
        _userToMap(user),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result > 0;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<List<UserModel>> getUsersByType(UserType userType) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'user_type = ? AND is_active = 1',
        whereArgs: [userType.toString().split('.').last],
      );

      return maps.map((map) => _mapToUser(map)).toList();
    } catch (e) {
      print('Error getting users by type: $e');
      return [];
    }
  }

  // Trash report operations
  Future<String?> insertTrashReport(TrashReportModel report) async {
    try {
      final db = await database;
      await db.insert('trash_reports', _trashReportToMap(report));
      return report.id;
    } catch (e) {
      print('Error inserting trash report: $e');
      return null;
    }
  }

  Future<TrashReportModel?> getTrashReportById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trash_reports',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToTrashReport(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting trash report by id: $e');
      return null;
    }
  }

  Future<List<TrashReportModel>> getTrashReportsByUserId(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trash_reports',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToTrashReport(map)).toList();
    } catch (e) {
      print('Error getting trash reports by user id: $e');
      return [];
    }
  }

  Future<List<TrashReportModel>> getTrashReportsByStatus(TrashStatus status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trash_reports',
        where: 'status = ?',
        whereArgs: [status.toString().split('.').last],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToTrashReport(map)).toList();
    } catch (e) {
      print('Error getting trash reports by status: $e');
      return [];
    }
  }

  Future<List<TrashReportModel>> getTrashReportsByCollectorId(String collectorId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trash_reports',
        where: 'collector_id = ?',
        whereArgs: [collectorId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToTrashReport(map)).toList();
    } catch (e) {
      print('Error getting trash reports by collector id: $e');
      return [];
    }
  }

  Future<bool> updateTrashReport(TrashReportModel report) async {
    try {
      final db = await database;
      final result = await db.update(
        'trash_reports',
        _trashReportToMap(report),
        where: 'id = ?',
        whereArgs: [report.id],
      );
      return result > 0;
    } catch (e) {
      print('Error updating trash report: $e');
      return false;
    }
  }

  // Notification operations
  Future<String?> insertNotification(NotificationModel notification) async {
    try {
      final db = await database;
      await db.insert('notifications', _notificationToMap(notification));
      return notification.id;
    } catch (e) {
      print('Error inserting notification: $e');
      return null;
    }
  }

  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) => _mapToNotification(map)).toList();
    } catch (e) {
      print('Error getting notifications by user id: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final db = await database;
      final result = await db.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      return result > 0;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Helper methods for data conversion
  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'user_type': user.userType.toString().split('.').last,
      'password': user.password,
      'is_active': user.isActive ? 1 : 0,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      'total_earnings': user.totalEarnings,
      'total_reports': user.totalReports,
      'rating': user.rating,
      'profile_image_url': user.profileImageUrl,
      'address': user.address,
    };
  }

  UserModel _mapToUser(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['user_type'],
      ),
      password: map['password'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      totalEarnings: map['total_earnings']?.toDouble() ?? 0.0,
      totalReports: map['total_reports'] ?? 0,
      rating: map['rating']?.toDouble() ?? 5.0,
      profileImageUrl: map['profile_image_url'],
      address: map['address'],
    );
  }

  Map<String, dynamic> _trashReportToMap(TrashReportModel report) {
    return {
      'id': report.id,
      'user_id': report.userId,
      'collector_id': report.collectorId,
      'dealer_id': report.dealerId,
      'trash_type': report.trashType.toString().split('.').last,
      'status': report.status.toString().split('.').last,
      'description': report.description,
      'image_path': report.imagePath,
      'latitude': report.location.latitude,
      'longitude': report.location.longitude,
      'address': report.location.address,
      'estimated_value': report.estimatedValue,
      'actual_value': report.actualValue,
      'created_at': report.createdAt.toIso8601String(),
      'updated_at': report.updatedAt.toIso8601String(),
      'collected_at': report.collectedAt?.toIso8601String(),
      'processed_at': report.processedAt?.toIso8601String(),
    };
  }

  TrashReportModel _mapToTrashReport(Map<String, dynamic> map) {
    return TrashReportModel(
      id: map['id'],
      userId: map['user_id'],
      collectorId: map['collector_id'],
      dealerId: map['dealer_id'],
      trashType: TrashType.values.firstWhere(
        (e) => e.toString().split('.').last == map['trash_type'],
      ),
      status: TrashStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      description: map['description'],
      imagePath: map['image_path'],
      location: LocationModel(
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'],
      ),
      estimatedValue: map['estimated_value']?.toDouble() ?? 0.0,
      actualValue: map['actual_value']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      collectedAt: map['collected_at'] != null ? DateTime.parse(map['collected_at']) : null,
      processedAt: map['processed_at'] != null ? DateTime.parse(map['processed_at']) : null,
    );
  }

  Map<String, dynamic> _notificationToMap(NotificationModel notification) {
    return {
      'id': notification.id,
      'user_id': notification.userId,
      'title': notification.title,
      'message': notification.message,
      'type': notification.type.toString().split('.').last,
      'is_read': notification.isRead ? 1 : 0,
      'created_at': notification.createdAt.toIso8601String(),
      'data': notification.data != null ? jsonEncode(notification.data) : null,
    };
  }

  NotificationModel _mapToNotification(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      data: map['data'] != null ? jsonDecode(map['data']) : null,
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
