import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;
  Function(String paymentType)? _onPaymentComplete;

  /// Initialize deep link listener
  ///
  /// Call this in your main.dart or app initialization
  ///
  /// Example:
  /// ```dart
  /// DeepLinkService().initialize(
  ///   onPaymentComplete: (paymentType) {
  ///     // Handle payment completion based on type
  ///     if (paymentType == 'activation') {
  ///       // Navigate to activation success screen
  ///     } else if (paymentType == 'service') {
  ///       // Navigate to service payment success screen
  ///     } else if (paymentType == 'rent') {
  ///       // Navigate to rent payment success screen
  ///     }
  ///   }
  /// );
  /// ```
  void initialize({
    required Function(String paymentType) onPaymentComplete,
  }) {
    _onPaymentComplete = onPaymentComplete;

    // Handle initial deep link when app is cold started
    _handleInitialLink();

    // Handle deep links when app is already running
    _handleIncomingLinks();
  }

  /// Handle the initial deep link when app is opened via deep link
  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _processDeepLink(uri);
      }
    } on PlatformException catch (e) {
      // Handle error
      debugPrint('Deep link error (initial): ${e.message}');
    } on FormatException catch (e) {
      // Handle format error
      debugPrint('Deep link format error (initial): $e');
    }
  }

  /// Handle incoming deep links when app is running
  void _handleIncomingLinks() {
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _processDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  /// Process the deep link and extract payment information
  void _processDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    try {
      // Check if this is a payment completion link
      // Expected format: smartnyumba://payment-complete?type=activation|service|rent
      if (uri.scheme == 'smartnyumba' && uri.host == 'payment-complete') {
        final paymentType = uri.queryParameters['type'];

        if (paymentType != null && _onPaymentComplete != null) {
          debugPrint('Payment completed for type: $paymentType');
          _onPaymentComplete!(paymentType);
        } else {
          debugPrint('Invalid payment deep link - missing type parameter');
        }
      } else {
        debugPrint('Unknown deep link format: $uri');
      }
    } catch (e) {
      debugPrint('Error processing deep link: $e');
    }
  }

  /// Dispose the deep link listener
  void dispose() {
    _sub?.cancel();
  }
}

// Helper function to avoid avoid_print lint
void debugPrint(String message) {
  // In production, you might want to use a logging framework
  // For now, we'll just use print with a prefix
  // ignore: avoid_print
  print('[DeepLink] $message');
}
