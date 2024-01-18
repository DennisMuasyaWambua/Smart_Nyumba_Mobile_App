import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/screens/admin/_admin.dart';
import 'package:smart_nyumba/screens/tenant/_tenant.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Payments()),
        ChangeNotifierProvider(create: (context) => TenantsProfile()),
        ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MaterialApp(
        home: const AdminDashboard(),
        routes: routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
