import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants/colors.dart';
import 'admin_home.dart';
import 'admin_profile.dart';

class AdminDashboard extends StatefulWidget {
  static const routeName = "/admin-dashboard";

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
          selectedItemColor: darkGold,
          items: [
            BottomNavigationBarItem(
                activeIcon: SvgPicture.asset('assets/icons/home-activated.svg'),
                icon: SvgPicture.asset('assets/icons/home.svg'),
                label: 'Home'),
            BottomNavigationBarItem(
                activeIcon: SvgPicture.asset('assets/icons/user-activated.svg'),
                icon: SvgPicture.asset('assets/icons/user.svg'),
                label: 'Profile'),
          ]),
    );
  }
}
