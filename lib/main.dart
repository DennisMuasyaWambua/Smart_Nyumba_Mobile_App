import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:smart_nyumba/Constants/Logo.dart';

import 'Authentication/login/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: const MyHomePage(),
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
    Timer(Duration(seconds: 2),()=>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=>Login())));
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:Column(
        children: [

          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                        image: AssetImage("assets/images/smart_nyumba.jpeg"),
                        fit: BoxFit.cover,
                  )
                )
              ),
              Positioned(
                top: MediaQuery.of(context).size.height*0.4,
                left: MediaQuery.of(context).size.width*0.3,
                child: Center(
                  child: Logo(width: 200,height: 200,),
                ),
              ),
            ],
          ),
        ],
      )

    );
  }
}
