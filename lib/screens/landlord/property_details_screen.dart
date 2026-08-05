import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/api/api_client.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../utils/constants/constants.dart';
import '../../utils/models/landlord_profile.dart';
import '../../utils/providers/shared_preference_builder.dart';

class PropertyDetailsScreen extends StatefulWidget {
  static const routeName = "/landlord-property-details";

  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  Property? _property;
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _tenants = [];
  Map<String, dynamic> _financialData = {};

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get property from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['property'] != null) {
      _property = args['property'] as Property;
      _loadPropertyDetails();
    }
  }

  Future<void> _loadPropertyDetails() async {
    if (_property == null) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Load tenants for this property
      await _loadTenants(token);

      // Load financial data
      await _loadFinancialData(token);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      log(e.toString(), name: "ERROR LOADING PROPERTY DETAILS");
    }
  }

  Future<void> _loadTenants(String token) async {
    Uri uri = Uri.parse(Constants.ALL_TENANTS_URL);
    final response = await SafeHttp.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Backend returns 'tenant' (singular), matching TenantManagementScreen.
      List<dynamic> allTenants = data['tenant'] ?? [];

      // Filter tenants by property block
      setState(() {
        _tenants = allTenants.where((tenant) {
          int? tenantBlock = tenant['property_block']?['block'];
          String? propertyBlock = _property?.blockNumber;
          // Compare as strings
          return tenantBlock?.toString() == propertyBlock;
        }).toList();
      });
    }
  }

  Future<void> _loadFinancialData(String token) async {
    // Get transactions and calculate property-specific financials
    Uri uri = Uri.parse(Constants.ALL_TRANSACTIONS);
    final response = await SafeHttp.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      double rentRevenue = 0;
      double serviceRevenue = 0;
      int transactionCount = 0;

      // Calculate rent revenue for this property
      if (data['rent_transactions'] != null) {
        for (var transaction in data['rent_transactions']) {
          // Match by property block - would need property_block in transaction
          double amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
          rentRevenue += amount;
          transactionCount++;
        }
      }

      // Calculate service revenue for this property
      if (data['service_transactions'] != null) {
        for (var transaction in data['service_transactions']) {
          double amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
          serviceRevenue += amount;
          transactionCount++;
        }
      }

      setState(() {
        _financialData = {
          'rent_revenue': rentRevenue,
          'service_revenue': serviceRevenue,
          'total_revenue': rentRevenue + serviceRevenue,
          'landlord_payout': rentRevenue + serviceRevenue,
          'transaction_count': transactionCount,
        };
      });
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: GoogleFonts.hind(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hind(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    final totalRevenue = _financialData['total_revenue'] ?? 0.0;
    final payout = _financialData['landlord_payout'] ?? 0.0;
    final rentRevenue = _financialData['rent_revenue'] ?? 0.0;
    final serviceRevenue = _financialData['service_revenue'] ?? 0.0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: GoogleFonts.hind(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            _buildFinancialRow('Total Revenue', totalRevenue, Colors.blue),
            const SizedBox(height: 8),
            _buildFinancialRow('Rent Revenue', rentRevenue, Colors.purple),
            const SizedBox(height: 8),
            _buildFinancialRow('Service Revenue', serviceRevenue, Colors.teal),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Payout',
                    style: GoogleFonts.hind(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[900],
                    ),
                  ),
                  Text(
                    _currencyFormat.format(payout),
                    style: GoogleFonts.hind(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.hind(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          _currencyFormat.format(amount),
          style: GoogleFonts.hind(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTenantsList() {
    if (_tenants.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tenants in this property',
                  style: GoogleFonts.hind(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Tenants',
            style: GoogleFonts.hind(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tenants.length,
          itemBuilder: (context, index) {
            final tenant = _tenants[index];
            final name = tenant['name'] ?? 'N/A';
            final email = tenant['email'] ?? 'N/A';
            final houseNumber = tenant['property_block']?['house_number'] ?? 'N/A';
            final isActive = tenant['is_active'] == 1;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.hind(
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: GoogleFonts.hind(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: GoogleFonts.hind(fontSize: 12),
                    ),
                    Text(
                      'House $houseNumber',
                      style: GoogleFonts.hind(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.hind(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_property == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Property Details',
            style: GoogleFonts.hind(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: Text('No property selected'),
        ),
      );
    }

    final totalHouses = _property!.totalHouses ?? 0;
    final occupiedHouses = _tenants.length;
    final vacantHouses = totalHouses - occupiedHouses;
    final occupancyRate = totalHouses > 0
        ? ((occupiedHouses / totalHouses) * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _property!.blockNumber ?? 'Property Details',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPropertyDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading property details',
                        style: GoogleFonts.hind(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hind(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPropertyDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPropertyDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property Info
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.apartment,
                                        size: 32, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _property!.blockNumber ?? 'N/A',
                                            style: GoogleFonts.hind(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            _property!.location ?? 'N/A',
                                            style: GoogleFonts.hind(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Statistics
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            children: [
                              _buildInfoCard(
                                'Total Houses',
                                totalHouses.toString(),
                                Icons.home,
                                Colors.blue,
                              ),
                              _buildInfoCard(
                                'Occupied',
                                occupiedHouses.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildInfoCard(
                                'Vacant',
                                vacantHouses.toString(),
                                Icons.home_outlined,
                                Colors.orange,
                              ),
                              _buildInfoCard(
                                'Occupancy Rate',
                                '$occupancyRate%',
                                Icons.pie_chart,
                                Colors.purple,
                              ),
                            ],
                          ),
                        ),

                        // Financial Summary
                        _buildFinancialCard(),

                        // Tenants List
                        const SizedBox(height: 16),
                        _buildTenantsList(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}
