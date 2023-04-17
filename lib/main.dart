import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/Authentication/auth_repository.dart';
import 'package:smart_nyumba/Constants/Logo.dart';
import 'package:smart_nyumba/Providers/auth_provider.dart';

import 'Authentication/login/login.dart';

void main() {
  runApp(MultiProvider(providers:[ChangeNotifierProvider(create: (_)=>Auth())],child: const MyApp()));
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

      home:Login()

    );
  }
}
