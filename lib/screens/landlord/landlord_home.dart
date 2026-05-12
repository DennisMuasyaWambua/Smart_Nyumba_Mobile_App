import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/landlord/dashboard_action_card.dart';
import '../../widgets/landlord/landlord_summary_card.dart';
import 'add_house_screen.dart';
import 'financial_dashboard.dart';
import 'landlord_profile.dart';
import 'landlord_properties.dart';
import 'register_subordinate_screen.dart';
import 'tenant_management.dart';
import 'transaction_reports.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class LandlordHome extends StatefulWidget {
  static const routeName = "/landlord-home";

  const LandlordHome({super.key});

  @override
  State<LandlordHome> createState() => _LandlordHomeState();
}

class _LandlordHomeState extends State<LandlordHome> {
  String firstName = '';
  String lastName = '';
  List<Property>? properties;
  int _selectedIndex = 0;
  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    log(token.toString(), name: "LANDLORD TOKEN");
    _loadProfile();
  }

  void _loadProfile() {
    final profile = LandlordProvider().getProfile(token!, context);
    profile.then((value) {
      if (mounted) {
        setState(() {
          log(value.profile!.user!.toJson().toString(),
              name: "FETCHING LANDLORD PROFILE");
          firstName = value.profile!.user!.firstName ?? '';
          lastName = value.profile!.user!.lastName ?? '';
          properties = value.profile!.properties;
          log("$firstName $lastName", name: "LANDLORD NAME");
          log(properties?.length.toString() ?? '0',
              name: "NUMBER OF PROPERTIES");
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING LANDLORD PROFILE");
    });
  }

  List<Widget> get _pages => [
        _buildDashboard(),
        const LandlordPropertiesScreen(),
        const AddHouseScreen(),
        const LandlordProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'Landlord Dashboard',
              style: GoogleFonts.hind(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Welcome $firstName $lastName',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: LandlordSummaryCard(
              totalProperties: properties?.length ?? 0,
            ),
          ),
          // Financial Dashboard Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Financial Overview',
                  style: GoogleFonts.hind(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                DashboardActionCard(
                  title: 'Financial Dashboard',
                  icon: Icons.analytics,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      FinancialDashboard.routeName,
                    );
                  },
                ),
              ],
            ),
          ),
          // Management Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Management',
                  style: GoogleFonts.hind(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Tenant Management',
                        icon: Icons.people,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            TenantManagementScreen.routeName,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Transaction Reports',
                        icon: Icons.receipt_long,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            TransactionReportsScreen.routeName,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Manage Team Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Manage Team',
                  style: GoogleFonts.hind(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Register Accountant',
                        icon: Icons.person_add,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RegisterSubordinateScreen.routeName,
                            arguments: {'role': 'accounts'},
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Register Caretaker',
                        icon: Icons.engineering,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RegisterSubordinateScreen.routeName,
                            arguments: {'role': 'caretaker'},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Nyumba',
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, NotificationsScreen.routeName);
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4169E1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_home),
            label: 'Add House',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
