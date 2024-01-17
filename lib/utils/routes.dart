import 'package:flutter/material.dart';

import '../screens/admin/_admin.dart';
import '../screens/authentication/_auth.dart';
import '../screens/tenant/_tenant.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/login': (context) => const Login(),
  '/register': (context) => const Register(),
  '/otp': (context) => const Otp(),
  '/tenantsDashboard': (context) => const TenantDashboard(),
  '/adminDashboard': (context) => const AdminDashboard(),
  '/allServiceChargeTransactions': (context) => const AllTransactionsData(),
  '/createNewRole': (context) => const CreateRole(),
  '/receipt': (context) => const Receipt()
};
