import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Constants/Constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
        selectedItemColor: const Color(0xFFD4AF37),
        items: const[
          BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add),label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),


        ]);
  }
  Widget _addPerson() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: GestureDetector(
          onTap: (){
            Navigator.pushNamed(context, '/createNewRole');
          },
          child: Container(
            height: 160,
            width: 135,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(-0.97, 0.24),
                    end: Alignment(0.97, -0.24),
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(children: [
                const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    Constants.createRole,
                    style: GoogleFonts.hind(
                        letterSpacing: -0.24,
                        height: 1.33,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
  Widget _checkCumulativeServiceChargeBalance() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: 160,
          width: 135,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.serviceChargeBalance,
                  style: GoogleFonts.hind(
                      letterSpacing: -0.24,
                      height: 1.33,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
              Padding(
                padding: EdgeInsets.only(top:35.0,left: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back,color: Colors.black,),
                    Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Text(Constants.dashboard, style: GoogleFonts.hind(color: Colors.black,fontWeight: FontWeight.w700, fontSize: 17),),
                    )
                  ],
                ),
              ),
              Padding(
                padding:  const EdgeInsets.only(right: 150,left: 5),
                child: Text("Welcome admin",style: GoogleFonts.hind(color: Constants.themePurple, fontSize: 28,fontWeight: FontWeight.w700, height: 3,),),
              ),
            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: Row(
                children: [
                  _addPerson(),
                  _checkCumulativeServiceChargeBalance()
                ],
              ),
            )


          ],
        ),
      ),
    );
  }
}
