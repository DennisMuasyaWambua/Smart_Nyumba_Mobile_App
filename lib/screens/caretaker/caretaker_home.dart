import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/providers/caretaker_provider.dart';
import '../../utils/providers/repairs_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/caretaker/caretaker_summary_card.dart';
import '../landlord/onboard_tenant_screen.dart';
import 'caretaker_profile.dart';
import 'repair_requests_screen.dart';

class CaretakerHome extends StatefulWidget {
  static const routeName = "/caretaker-home";

  const CaretakerHome({super.key});

  @override
  State<CaretakerHome> createState() => _CaretakerHomeState();
}

class _CaretakerHomeState extends State<CaretakerHome> {
  String firstName = '';
  String lastName = '';
  int _selectedIndex = 0;
  var token = SharedPrefrenceBuilder.getUserToken;

  @override
  void initState() {
    super.initState();
    log(token.toString(), name: "CARETAKER TOKEN");
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepairsProvider>().fetchAllRepairs();
    });
  }

  void _loadProfile() {
    final profile = CaretakerProvider().getProfile(token!, context);
    profile.then((value) {
      if (mounted) {
        setState(() {
          log(value.profile!.user!.toJson().toString(),
              name: "FETCHING CARETAKER PROFILE");
          firstName = value.profile!.user!.firstName ?? '';
          lastName = value.profile!.user!.lastName ?? '';
          log("$firstName $lastName", name: "CARETAKER NAME");
        });
      }
    }).catchError((error) {
      log(error.toString(), name: "ERROR LOADING CARETAKER PROFILE");
    });
  }

  List<Widget> get _pages => [
        _buildDashboard(),
        const RepairRequestsScreen(),
        const CaretakerProfileScreen(),
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
              'Caretaker Dashboard',
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
            child: Consumer<RepairsProvider>(
              builder: (context, repairs, _) => CaretakerSummaryCard(
                pendingRequests: repairs.pendingRepairs.length,
                inProgressRequests: repairs.inProgressRepairs.length,
                completedRequests: repairs.completedRepairs.length,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.hind(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.person_add_alt_1,
              label: 'Onboard New Tenant',
              color: const Color(0xFF22C55E),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  OnboardTenantScreen.routeName,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.build,
              label: 'View Repair Requests',
              color: const Color(0xFF4169E1),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.calendar_today,
              label: 'Maintenance Schedule',
              color: const Color(0xFF6495ED),
              onTap: () {
                // Navigate to maintenance schedule
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance schedule coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.hind(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
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
            icon: Icon(Icons.build),
            label: 'Repairs',
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
