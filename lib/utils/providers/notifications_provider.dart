import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../models/notification_item.dart';

class NotificationsProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<NotificationItem> get unread =>
      _notifications.where((n) => !n.read).toList();
  int get unreadCount => unread.length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get(Constants.MY_NOTIFICATIONS);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _notifications = (data['notifications'] as List)
            .map((json) => NotificationItem.fromJson(json))
            .toList();
      } else {
        _error = data['message'] ?? 'Could not load notifications';
      }
    } catch (e) {
      log(e.toString(), name: 'NotificationsProvider.fetchNotifications');
      _error = 'Could not load notifications. Check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].read) return;

    // Optimistic update; revert if the API call fails.
    _notifications[index] = _notifications[index].copyWith(read: true);
    notifyListeners();

    try {
      final response = await ApiClient.post(
        Constants.MARK_NOTIFICATION_READ,
        body: {'notification_id': notificationId.toString()},
      );
      if (response.statusCode != 200) {
        _notifications[index] = _notifications[index].copyWith(read: false);
        notifyListeners();
      }
    } catch (e) {
      log(e.toString(), name: 'NotificationsProvider.markAsRead');
      _notifications[index] = _notifications[index].copyWith(read: false);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final previous = _notifications;
    _notifications =
        _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();

    try {
      final response =
          await ApiClient.post(Constants.MARK_ALL_NOTIFICATIONS_READ);
      if (response.statusCode != 200) {
        _notifications = previous;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString(), name: 'NotificationsProvider.markAllAsRead');
      _notifications = previous;
      notifyListeners();
    }
  }
}
