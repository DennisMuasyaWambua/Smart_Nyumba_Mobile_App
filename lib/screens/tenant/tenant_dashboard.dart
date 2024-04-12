import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/_providers.dart';
import '../authentication/account_profile.dart';
import '../tenant/tenant_home.dart';


class TenantDashboard extends StatefulWidget {
  static const routeName = "/tenant-dashboard";
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  //getting the Tenats profile from the backend
  int hasUserPaid = 0;
  int myIndex = 0;
  late String lastName;
  var token = SharedPrefrenceBuilder.getUserToken;
  List<Widget> pages = [const TenantHome(), const AccountProfile()];

  @override
  void initState() {
    super.initState();
    Auth().getProfile(token!, context);
  }

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
        ],
      ),
    );
  }

 
}
