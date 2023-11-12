import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/Admin/admin_dashboard.dart';
import 'package:smart_nyumba/Admin/create_role.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/Tenant/all_transactions_data.dart';
import 'package:smart_nyumba/Tenant/tenant_receipt.dart';

import 'Authentication/login/login.dart';
import 'Authentication/otp.dart';
import 'Authentication/register/register.dart';
import 'Providers/auth_provider.dart';
import 'Providers/payment_provider.dart';
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
    // TODO: implement initState
    super.initState();

    // Timer(Duration(seconds: 2),()=>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=>Login())));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
       ChangeNotifierProvider(
        create: (context)=>Payments()
        ),
        ChangeNotifierProvider(
          create: (context)=>TenantsProfile()
        ),
        ChangeNotifierProvider(create:(context)=>Auth()),
    ], 
    child:  MaterialApp(
      home: const Login(),
      debugShowCheckedModeBanner: false,
      
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/otp': (context) => const Otp(),
        '/tenantsDashboard': (context) => const TenantDashboard(),
        '/adminDashboard':(context)=>const AdminDashboard(),
        '/allServiceChargeTransactions':(context)=>const AllTransactionsData(),
        '/createNewRole':(context)=>const CreateRole(),
        '/receipt':(context)=>const Receipt()
      },
    ),);
  }
}
