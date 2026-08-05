import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/constants.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/landlord_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../utils/providers/subscription_provider.dart';
import '../../widgets/landlord/dashboard_action_card.dart';
import 'add_house_screen.dart';
import 'etims_invoices_screen.dart';
import 'defaulters_screen.dart';
import 'financial_dashboard.dart';
import 'landlord_profile.dart';
import 'landlord_properties.dart';
import 'pricing_settings_screen.dart';
import 'register_subordinate_screen.dart';
import 'onboard_tenant_screen.dart';
import 'tenant_management.dart';
import 'transaction_reports.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'withholding_report_screen.dart';

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

  Map<String, dynamic>? _monthSummary;
  bool _loadingKpi = true;
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KSh ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    log(token.toString(), name: "LANDLORD TOKEN");
    _loadProfile();
    _loadSubscription();
    _loadKpi();
  }

  Future<void> _loadKpi() async {
    try {
      final data =
          await LandlordProvider().getFinancialSummary(period: 'month');
      if (!mounted) return;
      Map<String, dynamic>? summary;
      if (data['status'] == true) {
        final inner = data['data'];
        if (inner is Map && inner['summary'] is Map<String, dynamic>) {
          summary = inner['summary'] as Map<String, dynamic>;
        }
      }
      setState(() {
        _monthSummary = summary;
        _loadingKpi = false;
      });
    } catch (e) {
      log(e.toString(), name: "ERROR LOADING HOME KPI");
      if (!mounted) return;
      setState(() => _loadingKpi = false);
    }
  }

  void _loadSubscription() {
    Provider.of<SubscriptionProvider>(context, listen: false)
        .fetchMySubscription()
        .catchError((error) {
      log(error.toString(), name: "ERROR LOADING SUBSCRIPTION");
      return null;
    });
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

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFF4A90E2)),
            const SizedBox(width: 8),
            Text(
              'Premium Feature',
              style: GoogleFonts.hind(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This feature requires the PREMIUM plan (KES 9,999/mo). '
          'Upgrade to unlock KRA eTIMS automation and automated 10% tax withholding.',
          style: GoogleFonts.hind(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Not now',
              style: GoogleFonts.hind(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushNamed(context, PricingSettingsScreen.routeName)
                  .then((_) => _loadSubscription());
            },
            child: Text(
              'Upgrade',
              style: GoogleFonts.hind(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
    return RefreshIndicator(
      onRefresh: () async {
        _loadProfile();
        await _loadKpi();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        children: [
          _buildGreeting(),
          _buildKpiHero(),
          // Premium Tools Section (PREMIUM tier only)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<SubscriptionProvider>(
              builder: (context, subscriptionProvider, _) {
                final isPremium = subscriptionProvider.isPremium;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Premium Tools',
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
                            title: 'eTIMS Invoices',
                            icon: Icons.receipt,
                            locked: !isPremium,
                            onTap: () {
                              if (isPremium) {
                                Navigator.pushNamed(
                                  context,
                                  EtimsInvoicesScreen.routeName,
                                );
                              } else {
                                _showUpgradeDialog();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardActionCard(
                            title: 'Tax Withholding',
                            icon: Icons.account_balance,
                            locked: !isPremium,
                            onTap: () {
                              if (isPremium) {
                                Navigator.pushNamed(
                                  context,
                                  WithholdingReportScreen.routeName,
                                );
                              } else {
                                _showUpgradeDialog();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Defaulters',
                        icon: Icons.warning_amber_rounded,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            DefaultersScreen.routeName,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardActionCard(
                        title: 'Onboard New Tenant',
                        icon: Icons.person_add_alt_1,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            OnboardTenantScreen.routeName,
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
      ),
    );
  }

  Widget _buildGreeting() {
    final name = '$firstName $lastName'.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: GoogleFonts.hind(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              name.isEmpty ? 'Landlord' : name,
              style: GoogleFonts.hind(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Constants.themePurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiHero() {
    final payout =
        ((_monthSummary?['total_landlord_payout'] ?? 0) as num).toDouble();
    final revenue =
        ((_monthSummary?['total_revenue'] ?? 0) as num).toDouble();
    final propertyCount = properties?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, FinancialDashboard.routeName),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Constants.themePurple, Color(0xFF6495ED)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "This month's payout",
                    style: GoogleFonts.hind(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 14),
                ],
              ),
              const SizedBox(height: 6),
              _loadingKpi
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      ),
                    )
                  : Text(
                      _currencyFormat.format(payout),
                      style: GoogleFonts.hind(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildHeroStat(
                      'Collected',
                      _loadingKpi ? '—' : _currencyFormat.format(revenue),
                      Icons.payments_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: _buildHeroStat(
                      'Properties',
                      '$propertyCount',
                      Icons.apartment,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hind(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.hind(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
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
        selectedItemColor: Constants.themePurple,
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
