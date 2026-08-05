import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/admin/_admin.dart';
import 'screens/authentication/_auth.dart';
import 'screens/caretaker/_caretaker.dart';
import 'screens/landlord/_landlord.dart';
import 'screens/tenant/_tenant.dart';
import 'utils/api/api_client.dart';
import 'utils/providers.dart';
import 'utils/providers/notifications_provider.dart';
import 'utils/providers/shared_preference_builder.dart';
import 'utils/routes.dart';
import 'utils/services/push_notification_service.dart';
import 'utils/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SharedPrefrenceBuilder.init();

  // When any authenticated request comes back 401 the session is gone;
  // drop the user back at the login screen.
  ApiClient.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Login.routeName,
      (route) => false,
    );
  };

  // Set up push notifications (no-op until Firebase is configured).
  await PushNotificationService.instance.init();

  // Register this device's FCM token on every successful login...
  SharedPrefrenceBuilder.onTokenSet = () {
    PushNotificationService.instance.syncToken();
  };
  // ...drop it on logout / session expiry...
  SharedPrefrenceBuilder.onTokenCleared = () {
    PushNotificationService.instance.unregister();
  };
  // ...and register once now, in case the app was launched already authenticated.
  await PushNotificationService.instance.syncToken();

  // Refresh the in-app notifications list when a push arrives in foreground.
  PushNotificationService.instance.onForegroundMessage = (message) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Provider.of<NotificationsProvider>(ctx, listen: false)
          .fetchNotifications();
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    late DateTime? tokenExpirationDate;
    late bool isTokenValid = false;

    if (SharedPrefrenceBuilder.getExpirationTime != null) {
      tokenExpirationDate = DateTime.parse(SharedPrefrenceBuilder.getExpirationTime!);
      isTokenValid = tokenExpirationDate.isAfter(DateTime.now());
      !isTokenValid ? SharedPrefrenceBuilder.clearInvalidToken() : null;
    }

    Widget getHomeScreen() {
      if (SharedPrefrenceBuilder.getUserToken == null || !isTokenValid) {
        return const Login();
      }

      final role = SharedPrefrenceBuilder.getUserRole;
      switch (role) {
        case "tenant":
          return const TenantDashboard();
        case "landlord":
          return const LandlordDashboard();
        case "caretaker":
          return const CaretakerDashboard();
        default:
          return const AdminDashboard();
      }
    }

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: getHomeScreen(),
        routes: routes,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
