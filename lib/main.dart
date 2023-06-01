import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';

import 'Authentication/login/login.dart';
import 'Authentication/otp.dart';
import 'Authentication/register/register.dart';
import 'Tenant/tenantDashboard.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  await SharedPrefrenceBuilder.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Timer(Duration(seconds: 2),()=>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=>Login())));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/otp': (context) => Otp(),
        '/tenantsDashboard': (context) => TenantDashboard(),
      },
    );
  }
}
