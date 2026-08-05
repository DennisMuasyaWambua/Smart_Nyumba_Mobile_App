import 'package:flutter/material.dart';

import '../screens/admin/_admin.dart';
import '../screens/authentication/_auth.dart';
import '../screens/caretaker/_caretaker.dart';
import '../screens/landlord/_landlord.dart';
import '../screens/tenant/_tenant.dart';

Map<String, Widget Function(BuildContext)> routes = {
  Login.routeName: (context) => const Login(),
  Register.routeName: (context) => const Register(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  Otp.routeName: (context) => const Otp(),
  ActivationPaymentScreen.routeName: (context) => const ActivationPaymentScreen(),
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
  PaymentScreen.routeName: (context) => const PaymentScreen(),
  LandlordLogin.routeName: (context) => const LandlordLogin(),
  LandlordDashboard.routeName: (context) => const LandlordDashboard(),
  LandlordHome.routeName: (context) => const LandlordHome(),
  LandlordPropertiesScreen.routeName: (context) => const LandlordPropertiesScreen(),
  AddHouseScreen.routeName: (context) => const AddHouseScreen(),
  LandlordProfileScreen.routeName: (context) => const LandlordProfileScreen(),
  RegisterSubordinateScreen.routeName: (context) => const RegisterSubordinateScreen(),
  OnboardTenantScreen.routeName: (context) => const OnboardTenantScreen(),
  FinancialDashboard.routeName: (context) => const FinancialDashboard(),
  TenantManagementScreen.routeName: (context) => const TenantManagementScreen(),
  TransactionReportsScreen.routeName: (context) => const TransactionReportsScreen(),
  DefaultersScreen.routeName: (context) => const DefaultersScreen(),
  PropertyDetailsScreen.routeName: (context) => const PropertyDetailsScreen(),
  NotificationsScreen.routeName: (context) => const NotificationsScreen(),
  SettingsScreen.routeName: (context) => const SettingsScreen(),
  PricingSettingsScreen.routeName: (context) => const PricingSettingsScreen(),
  EtimsInvoicesScreen.routeName: (context) => const EtimsInvoicesScreen(),
  WithholdingReportScreen.routeName: (context) => const WithholdingReportScreen(),
  CaretakerLogin.routeName: (context) => const CaretakerLogin(),
  CaretakerDashboard.routeName: (context) => const CaretakerDashboard(),
  CaretakerHome.routeName: (context) => const CaretakerHome(),
  RepairRequestsScreen.routeName: (context) => const RepairRequestsScreen(),
  CaretakerProfileScreen.routeName: (context) => const CaretakerProfileScreen(),
  PaymentWebViewScreen.routeName: (context) => const PaymentWebViewScreen(),
};
