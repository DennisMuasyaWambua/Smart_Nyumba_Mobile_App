import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utils/providers/landlord_provider.dart';

class FinancialDashboard extends StatefulWidget {
  static const routeName = "/landlord-financial-dashboard";

  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _financialData;
  String _selectedPeriod = 'all';
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final data = await LandlordProvider().getFinancialSummary(
        period: _selectedPeriod,
      );

      if (mounted) {
        setState(() {
          _financialData = data;
          _isLoading = false;
        });
        log(data.toString(), name: "FINANCIAL DATA");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        log(e.toString(), name: "ERROR LOADING FINANCIAL DATA");
      }
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.hind(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'rent';
    final amount = transaction['amount'] ?? 0.0;
    final date = transaction['date'] ?? '';
    final tenantEmail = transaction['tenant_email'] ?? 'N/A';
    final paymentMethod = transaction['payment_method'] ?? 'mpesa';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == 'rent' ? Colors.blue[100] : Colors.green[100],
          child: Icon(
            type == 'rent' ? Icons.home : Icons.build,
            color: type == 'rent' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          type == 'rent' ? 'Rent Payment' : 'Service Charge',
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenantEmail,
              style: GoogleFonts.hind(fontSize: 12),
            ),
            Text(
              '$date • ${paymentMethod.toUpperCase()}',
              style: GoogleFonts.hind(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(amount),
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.green[700],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySummary(Map<String, dynamic> property) {
    final blockNumber = property['block_number'] ?? 'N/A';
    final location = property['location'] ?? 'N/A';
    final totalRevenue = property['total_revenue'] ?? 0.0;
    final tenantCount = property['tenant_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.apartment, color: Colors.blueAccent),
        title: Text(
          blockNumber,
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          location,
          style: GoogleFonts.hind(fontSize: 12, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Revenue:', style: GoogleFonts.hind()),
                    Text(
                      _currencyFormat.format(totalRevenue),
                      style: GoogleFonts.hind(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rent Revenue:', style: GoogleFonts.hind()),
                    Text(
                      _currencyFormat.format(property['rent_revenue'] ?? 0.0),
                      style: GoogleFonts.hind(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Service Revenue:', style: GoogleFonts.hind()),
                    Text(
                      _currencyFormat.format(property['service_revenue'] ?? 0.0),
                      style: GoogleFonts.hind(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tenants:', style: GoogleFonts.hind()),
                    Text(
                      tenantCount.toString(),
                      style: GoogleFonts.hind(fontWeight: FontWeight.w600),
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
          'Financial Dashboard',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadFinancialData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Time'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('This Year'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('This Month'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
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
                        'Error loading data',
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
                        onPressed: _loadFinancialData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    if (_financialData == null || _financialData!['status'] != true) {
      return const Center(child: Text('No data available'));
    }

    final data = _financialData!['data'];
    final summary = data['summary'];
    final recentTransactions = data['recent_transactions'] as List<dynamic>? ?? [];
    final propertyList = data['property_summary'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadFinancialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Text(
                'Showing: ${_selectedPeriod == 'all' ? 'All Time' : _selectedPeriod == 'year' ? 'This Year' : 'This Month'}',
                style: GoogleFonts.hind(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Total Revenue',
                    _currencyFormat.format(summary['total_revenue'] ?? 0.0),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Commission (5%)',
                          _currencyFormat.format(summary['total_commission'] ?? 0.0),
                          Icons.percent,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Your Payout',
                          _currencyFormat.format(summary['total_landlord_payout'] ?? 0.0),
                          Icons.payments,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Rent Revenue',
                          _currencyFormat.format(summary['total_rent_revenue'] ?? 0.0),
                          Icons.home,
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Service Revenue',
                          _currencyFormat.format(summary['total_service_revenue'] ?? 0.0),
                          Icons.build,
                          Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Transactions Section
            if (recentTransactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recent Transactions',
                  style: GoogleFonts.hind(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(
                      recentTransactions[index] as Map<String, dynamic>);
                },
              ),
            ],

            // Property Summary Section
            if (propertyList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Properties Overview',
                  style: GoogleFonts.hind(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: propertyList.length,
                itemBuilder: (context, index) {
                  return _buildPropertySummary(
                      propertyList[index] as Map<String, dynamic>);
                },
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
