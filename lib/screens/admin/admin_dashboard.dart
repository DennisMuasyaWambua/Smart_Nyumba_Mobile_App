import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'admin_home.dart';
import 'admin_profile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int myIndex = 0;
  List<Widget> pages = [const AdminHome(), const AdminProfile()];

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
      body: IndexedStack(
        index: myIndex,
        children: pages,
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
