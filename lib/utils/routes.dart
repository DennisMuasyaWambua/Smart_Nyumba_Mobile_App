import 'package:flutter/material.dart';

import '../screens/admin/_admin.dart';
import '../screens/authentication/_auth.dart';
import '../screens/tenant/_tenant.dart';

Map<String, Widget Function(BuildContext)> routes = {
  Login.routeName: (context) => const Login(),
  Register.routeName: (context) => const Register(),
  Otp.routeName: (context) => const Otp(),
  AccountProfile.routeName: (context) => const AccountProfile(),
  AllTransactionsData.routeName: (context) => const AllTransactionsData(),
  RequestForRepairsScreen.routeName : (context) => const RequestForRepairsScreen(),
  TenantDashboard.routeName: (context) => const TenantDashboard(),
  TenantHome.routeName: (context) => const TenantHome(),
  MarketPlace.routeName : (context) => const MarketPlace(),
  AdminDashboard.routeName: (context) => const AdminDashboard(),
  AdminHome.routeName: (context) => const AdminHome(),
  AdminProfile.routeName: (context) => const AdminProfile(),
  Companies.routeName: (context) => const Companies(),
  EstateTenants.routeName: (context) => const EstateTenants(),
  CreateRole.routeName: (context) => const CreateRole(),
  Receipt.routeName: (context) => const Receipt(),
  TenantDetails.route: (context) => const TenantDetails(),
};
