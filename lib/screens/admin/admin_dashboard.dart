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
