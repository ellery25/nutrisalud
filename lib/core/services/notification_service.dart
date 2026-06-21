import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notification categories the product supports.
enum NotificationTopic {
  mealReminder,
  hydrationReminder,
  habitReminder,
  educationalContent,
  weeklyReport,
}

/// Push/local notification abstraction. Feature code depends only on this
/// interface so FCM or any other transport can be swapped without changes.
abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();

  /// Returns the device's current FCM registration token, or null if
  /// unavailable (permissions denied, Firebase not configured).
  Future<String?> getToken();

  Future<void> subscribe(NotificationTopic topic);
  Future<void> unsubscribe(NotificationTopic topic);
}

/// No-op implementation used until Firebase credentials are provisioned.
/// Logs intent in debug builds so notification flows remain testable.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async =>
      debugPrint('[notifications] initialize (noop)');

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> subscribe(NotificationTopic topic) async =>
      debugPrint('[notifications] subscribe ${topic.name} (noop)');

  @override
  Future<void> unsubscribe(NotificationTopic topic) async =>
      debugPrint('[notifications] unsubscribe ${topic.name} (noop)');
}

/// Production FCM implementation. Injected via ProviderScope override in
/// main.dart once Firebase.initializeApp() succeeds.
class FcmNotificationService implements NotificationService {
  String? _token;

  @override
  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    await requestPermission();
    _token = await messaging.getToken();
    messaging.onTokenRefresh.listen((t) => _token = t);
    FirebaseMessaging.onMessage.listen(_handleForeground);
    debugPrint('[FCM] initialized — token: $_token');
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() async {
    _token ??= await FirebaseMessaging.instance.getToken();
    return _token;
  }

  @override
  Future<void> subscribe(NotificationTopic topic) =>
      FirebaseMessaging.instance.subscribeToTopic(_topicName(topic));

  @override
  Future<void> unsubscribe(NotificationTopic topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(_topicName(topic));

  void _handleForeground(RemoteMessage message) {
    debugPrint('[FCM] foreground: ${message.notification?.title}');
  }

  String _topicName(NotificationTopic topic) => switch (topic) {
        NotificationTopic.mealReminder => 'meal_reminders',
        NotificationTopic.hydrationReminder => 'hydration_reminders',
        NotificationTopic.habitReminder => 'habit_reminders',
        NotificationTopic.educationalContent => 'educational_content',
        NotificationTopic.weeklyReport => 'weekly_reports',
      };
}

/// Defaults to [NoopNotificationService]. Overridden with [FcmNotificationService]
/// in main.dart once Firebase.initializeApp() succeeds.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => const NoopNotificationService(),
);
