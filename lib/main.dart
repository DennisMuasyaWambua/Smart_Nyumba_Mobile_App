import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/admin/_admin.dart';
import 'screens/authentication/_auth.dart';
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

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        home: (SharedPrefrenceBuilder.getUserToken != null && isTokenValid)
            ? SharedPrefrenceBuilder.getUserRole == "tenant"
                ? const TenantDashboard()
                : const AdminDashboard()
            : const Login(),
        routes: routes,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
