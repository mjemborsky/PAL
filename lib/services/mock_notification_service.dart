import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/phone_data_models.dart';

class MockNotificationService extends ChangeNotifier {
  final List<MockNotification> _notifications = [];
  Timer? _generatorTimer;

  List<MockNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  MockNotificationService() {
    _seedInitialNotifications();
    _startMockStream();
  }

  void _seedInitialNotifications() {
    _notifications.addAll([
      MockNotification(
        id: '1',
        appName: 'Messages',
        title: 'Alex',
        body: 'Are we still on for the session tonight?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        category: NotificationCategory.message,
      ),
      MockNotification(
        id: '2',
        appName: 'Calendar',
        title: 'Reminder: Dev Sync',
        body: 'Starts in 15 minutes',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        category: NotificationCategory.system,
      ),
    ]);
  }

  void _startMockStream() {
    _generatorTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      final newNotif = MockNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        appName: 'Discord',
        title: '#general',
        body: 'New build pushed to the main repo!',
        timestamp: DateTime.now(),
        category: NotificationCategory.social,
      );
      _notifications.insert(0, newNotif);
      notifyListeners();
    });
  }

  void dismissNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _generatorTimer?.cancel();
    super.dispose();
  }
}
