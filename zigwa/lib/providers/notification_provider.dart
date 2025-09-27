import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  final NotificationService _notificationService = NotificationService();

  NotificationProvider() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _notificationService.getNotifications();
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendNotificationToCollectors({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _notificationService.sendNotificationToCollectors(
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      debugPrint('Error sending notification to collectors: $e');
    }
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      debugPrint('Error sending notification to user: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

enum NotificationType {
  trashReported,
  trashAssigned,
  trashCollected,
  trashProcessed,
  paymentReceived,
  general,
}
