// import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Admin/companies.dart';
import 'package:smart_nyumba/Admin/estate_tenants.dart';

import '../Constants/constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(selectedItemColor: const Color(0xFFD4AF37), items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
          onTap: () {
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/account_icon.png"),
                  radius: 30,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Chairman",
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 0.04,
                letterSpacing: 0.31,
                color: const Color(0xFF1A1E25),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "smartnyumba@gmail.com",
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 0.06,
                letterSpacing: 0.32,
                color: const Color(0xFF7D7F88),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Companies()));
              },
              child: Container(
                width: 300,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Center(
                    child: Text(
                  "Companies",
                  style: GoogleFonts.hind(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 0.05,
                      letterSpacing: 0.29),
                )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Center(
                  child: Text(
                "Payments",
                style: GoogleFonts.hind(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 0.05,
                    letterSpacing: 0.29),
              )),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EstateTenants()));
              },
              child: Container(
                width: 300,
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Center(
                    child: Text(
                  "Tenants",
                  style: GoogleFonts.hind(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 0.05,
                      letterSpacing: 0.29),
                )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
