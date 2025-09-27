import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import '../providers/notification_provider.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    // You can navigate to specific screens based on the payload
    final payload = notificationResponse.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      // This would typically involve using a navigation service
    }
  }

  // Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'zigwa_channel',
      'Zigwa Notifications',
      channelDescription: 'Notifications for Zigwa waste management app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    // Save notification to database
    final notification = NotificationModel(
      id: _uuid.v4(),
      title: title,
      body: body,
      data: payload != null ? {'payload': payload} : {},
      createdAt: DateTime.now(),
      type: type,
    );

    await _databaseService.saveNotification(notification);
  }

  // Send notification to all collection workers
  Future<void> sendNotificationToCollectors({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // In a real app, this would send push notifications via Firebase
    // For demo purposes, we'll show local notifications
    await showLocalNotification(
      title: title,
      body: body,
      payload: data.toString(),
      type: NotificationType.trashReported,
    );
  }

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // In a real app, this would send push notifications via Firebase
    // For demo purposes, we'll show local notifications
    await showLocalNotification(
      title: title,
      body: body,
      payload: data.toString(),
      type: _getNotificationTypeFromData(data),
    );
  }

  // Get notifications from database
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _databaseService.getNotifications();
    } catch (e) {
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      for (final notification in notifications) {
        if (!notification.isRead) {
          await _databaseService.markNotificationAsRead(notification.id);
        }
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databaseService.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Send notification when trash is reported
  Future<void> notifyTrashReported({
    required String reportId,
    required String location,
    required String trashType,
  }) async {
    await sendNotificationToCollectors(
      title: 'New Trash Report',
      body: 'New $trashType waste reported at $location',
      data: {
        'type': 'trash_reported',
        'reportId': reportId,
        'location': location,
        'trashType': trashType,
      },
    );
  }

  // Send notification when trash is assigned
  Future<void> notifyTrashAssigned({
    required String userId,
    required String reportId,
    required String location,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Trash Collection Assigned',
      body: 'You have been assigned to collect trash at $location',
      data: {
        'type': 'trash_assigned',
        'reportId': reportId,
        'location': location,
      },
    );
  }

  // Send notification when trash is collected
  Future<void> notifyTrashCollected({
    required String userId,
    required String reportId,
    required String collectorName,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Trash Collected',
      body: 'Your reported trash has been collected by $collectorName',
      data: {
        'type': 'trash_collected',
        'reportId': reportId,
        'collectorName': collectorName,
      },
    );
  }

  // Send notification when trash is processed
  Future<void> notifyTrashProcessed({
    required String userId,
    required String collectorId,
    required String reportId,
    required double value,
  }) async {
    // Notify user
    await sendNotificationToUser(
      userId: userId,
      title: 'Trash Processed',
      body: 'Your trash has been processed. Value: \$${value.toStringAsFixed(2)}',
      data: {
        'type': 'trash_processed',
        'reportId': reportId,
        'value': value,
      },
    );

    // Notify collector
    await sendNotificationToUser(
      userId: collectorId,
      title: 'Trash Processed',
      body: 'Collected trash has been processed. Value: \$${value.toStringAsFixed(2)}',
      data: {
        'type': 'trash_processed',
        'reportId': reportId,
        'value': value,
      },
    );
  }

  // Send notification when payment is processed
  Future<void> notifyPaymentReceived({
    required String userId,
    required String reportId,
    required double amount,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Payment Received',
      body: 'You have received \$${amount.toStringAsFixed(2)} for your contribution',
      data: {
        'type': 'payment_received',
        'reportId': reportId,
        'amount': amount,
      },
    );
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'trash_reported':
        return NotificationType.trashReported;
      case 'trash_assigned':
        return NotificationType.trashAssigned;
      case 'trash_collected':
        return NotificationType.trashCollected;
      case 'trash_processed':
        return NotificationType.trashProcessed;
      case 'payment_received':
        return NotificationType.paymentReceived;
      default:
        return NotificationType.general;
    }
  }
}
