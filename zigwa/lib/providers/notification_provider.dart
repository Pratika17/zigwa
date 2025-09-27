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
