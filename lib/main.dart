import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/authentication/_auth.dart';
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
    return const MaterialApp(
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
    super.initState();

    // Timer(Duration(seconds: 2),()=>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=>Login())));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Payments()),
        ChangeNotifierProvider(create: (context) => TenantsProfile()),
        ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MaterialApp(
        home: const Login(),
        debugShowCheckedModeBanner: false,
        routes: routes,
      ),
    );
  }
}
