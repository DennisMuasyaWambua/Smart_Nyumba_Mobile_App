import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/admin/_admin.dart';
import 'screens/authentication/_auth.dart';
import 'screens/tenant/tenant_dashboard.dart';
import 'utils/providers/_providers.dart';
import 'utils/routes.dart';

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
      providers: [
        ChangeNotifierProvider(create: (context) => Payments()),
        ChangeNotifierProvider(create: (context) => TenantsProfile()),
        ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MaterialApp(
        home: (SharedPrefrenceBuilder.getUserToken != null && isTokenValid)
            ? SharedPrefrenceBuilder.getUserRole == "tenant"
                ? const TenantDashboard()
                : const AdminDashboard()
            : const Login(),
        routes: routes,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            elevation: 0,
            backgroundColor: Color(0xfffafafa),
            iconTheme: IconThemeData(color: Colors.black),
            actionsIconTheme: IconThemeData(color: Colors.black),
            centerTitle: true,
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
