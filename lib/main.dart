import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/admin/_admin.dart';
import 'screens/authentication/_auth.dart';
import 'screens/caretaker/_caretaker.dart';
import 'screens/landlord/_landlord.dart';
import 'screens/tenant/_tenant.dart';
import 'utils/providers.dart';
import 'utils/providers/shared_preference_builder.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  await SharedPrefrenceBuilder.init();
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
        home: getHomeScreen(),
        routes: routes,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
