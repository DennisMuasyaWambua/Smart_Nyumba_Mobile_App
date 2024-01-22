// import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './companies.dart';
import './estate_tenants.dart';

// import '../Constants/constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int myIndex = 0;

  // Widget _addPerson() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Neumorphic(
  //       style: NeumorphicStyle(
  //           shape: NeumorphicShape.concave,
  //           depth: 100,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
  //           lightSource: LightSource.topLeft,
  //           intensity: 30),
  //       child: GestureDetector(
  //         onTap: () {
  //           Navigator.pushNamed(context, '/createNewRole');
  //         },
  //         child: Container(
  //           height: 160,
  //           width: 135,
  //           decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                   begin: Alignment(-0.97, 0.24),
  //                   end: Alignment(0.97, -0.24),
  //                   colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 50),
  //             child: Column(children: [
  //               const Icon(
  //                 Icons.person_add,
  //                 color: Colors.white,
  //                 size: 30,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(top: 8.0),
  //                 child: Text(
  //                   Constants.createRole,
  //                   style: GoogleFonts.hind(
  //                       letterSpacing: -0.24,
  //                       height: 1.33,
  //                       fontSize: 15,
  //                       fontWeight: FontWeight.w700,
  //                       color: Colors.white),
  //                 ),
  //               )
  //             ]),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _checkCumulativeServiceChargeBalance() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Neumorphic(
  //       style: NeumorphicStyle(
  //           shape: NeumorphicShape.concave,
  //           depth: 100,
  //           boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
  //           lightSource: LightSource.topLeft,
  //           intensity: 30),
  //       child: Container(
  //         height: 160,
  //         width: 135,
  //         decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //                 begin: Alignment(-0.97, 0.24),
  //                 end: Alignment(0.97, -0.24),
  //                 colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 50),
  //           child: Column(children: [
  //             const Icon(
  //               Icons.account_balance,
  //               color: Colors.white,
  //               size: 30,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Text(
  //                 Constants.serviceChargeBalance,
  //                 style: GoogleFonts.hind(
  //                     letterSpacing: -0.24,
  //                     height: 1.33,
  //                     fontSize: 15,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.white),
  //               ),
  //             )
  //           ]),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: ListView(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/account_icon.png"),
                      radius: 30,
                    ),
                    title: Text(
                      'Chairman',
                      style: GoogleFonts.hind(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1E25),
                      ),
                    ),
                    subtitle: Text(
                      'smartnyumba@gmail.com',
                      style: GoogleFonts.hind(
                        color: const Color(0xFF7D7F88),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Companies(),
                        ),
                      );
                    },
                    title: const Text('Companies'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  ListTile(
                    onTap: () {},
                    title: const Text('Payments'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EstateTenants(),
                        ),
                      );
                    },
                    title: const Text('Tenants'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          currentIndex: myIndex,
          selectedItemColor: const Color(0xFFD4AF37),
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                    myIndex == 1 ? 'assets/icons/home.svg' : 'assets/icons/home-activated.svg'),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                    myIndex == 0 ? 'assets/icons/user.svg' : 'assets/icons/user-activated.svg'),
                label: 'Profile'),
          ]),
    );
  }
}
