import 'dart:developer';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../providers/shared_preference_builder.dart';

/// Handles messages that arrive while the app is terminated or in the
/// background. Must be a top-level function (not a closure/instance method).
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // The OS renders "notification" messages itself; nothing to do here for now.
  // A Firebase app must be initialised in this isolate before using Firebase.
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

/// Thin wrapper around Firebase Cloud Messaging.
///
/// The whole thing degrades gracefully: if Firebase is not configured (no
/// google-services.json baked in), [init] catches the failure and every method
/// becomes a no-op, so the app runs exactly as before until credentials are
/// added.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _available = false;
  bool _initialised = false;

  /// Optional hook fired when a push arrives while the app is foregrounded —
  /// wire it to refresh the in-app notifications list.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Initialise Firebase + messaging. Safe to call once at startup; if Firebase
  /// isn't set up yet this quietly disables push and returns.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      log('Firebase not configured, push disabled: $e',
          name: 'PushNotificationService');
      _available = false;
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((message) {
        log('Foreground push: ${message.notification?.title}',
            name: 'PushNotificationService');
        onForegroundMessage?.call(message);
      });

      // Re-register whenever FCM rotates the token.
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _registerToken(token);
      });
    } catch (e) {
      log('Push setup error: $e', name: 'PushNotificationService');
    }
  }

  /// Fetch the current token and register it with the backend. Call after a
  /// successful login and on app start when already authenticated.
  Future<void> syncToken() async {
    if (!_available) return;
    if (SharedPrefrenceBuilder.getUserToken == null) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerToken(token);
      }
    } catch (e) {
      log('Could not get FCM token: $e', name: 'PushNotificationService');
    }
  }

  Future<void> _registerToken(String fcmToken) async {
    if (SharedPrefrenceBuilder.getUserToken == null) return;
    try {
      await ApiClient.post(
        Constants.REGISTER_DEVICE,
        body: {
          'token': fcmToken,
          'platform': _platform(),
        },
      );
      log('Device token registered', name: 'PushNotificationService');
    } catch (e) {
      log('Device registration failed: $e', name: 'PushNotificationService');
    }
  }

  /// Remove this device's token from the backend, e.g. on logout, so the user
  /// stops receiving pushes on this device.
  Future<void> unregister() async {
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiClient.post(
          Constants.UNREGISTER_DEVICE,
          body: {'token': token},
        );
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      log('Device unregister failed: $e', name: 'PushNotificationService');
    }
  }

  String _platform() {
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {}
    return 'android';
  }
}
