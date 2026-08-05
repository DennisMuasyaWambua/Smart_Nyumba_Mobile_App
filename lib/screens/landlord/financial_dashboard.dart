import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utils/constants/constants.dart';
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

  static const List<({String value, String label})> _periods = [
    (value: 'month', label: 'This Month'),
    (value: 'year', label: 'This Year'),
    (value: 'all', label: 'All Time'),
  ];

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

  Widget _buildPeriodChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = _periods[index];
          final selected = period.value == _selectedPeriod;
          return ChoiceChip(
            label: Text(
              period.label,
              style: GoogleFonts.hind(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Constants.themePurple,
              ),
            ),
            selected: selected,
            selectedColor: Constants.themePurple,
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(
                color: selected
                    ? Constants.themePurple
                    : Colors.grey.shade300,
              ),
            ),
            showCheckmark: false,
            onSelected: (_) {
              if (period.value == _selectedPeriod) return;
              setState(() {
                _selectedPeriod = period.value;
              });
              _loadFinancialData();
            },
          );
        },
      ),
    );
  }

  String get _selectedPeriodLabel => _periods
      .firstWhere((p) => p.value == _selectedPeriod,
          orElse: () => _periods.last)
      .label;

  Widget _buildHeroCard(Map<String, dynamic> summary) {
    final payout = summary['total_landlord_payout'] ?? 0.0;
    final totalRevenue = summary['total_revenue'] ?? 0.0;
    final commission = summary['total_commission'] ?? 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.themePurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Payout • $_selectedPeriodLabel',
            style: GoogleFonts.hind(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
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
                child: _buildHeroStat('Total Collected',
                    _currencyFormat.format(totalRevenue)),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildHeroStat('Historical Commission',
                    _currencyFormat.format(commission)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.hind(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.hind(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
      String title, double amount, double total, IconData icon, Color color) {
    final share = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.hind(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(amount),
                      style: GoogleFonts.hind(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.hind(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Constants.themePurple,
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.hind(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.hind(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'rent';
    final amount = transaction['amount'] ?? 0.0;
    final date = transaction['date'] ?? '';
    final tenantEmail = transaction['tenant_email'] ?? 'N/A';
    final paymentMethod = transaction['payment_method'] ?? 'mpesa';
    final isRent = type == 'rent';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isRent ? Constants.servicesColor : Constants.paymentColor)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRent ? Icons.home_outlined : Icons.build_outlined,
              color:
                  isRent ? Constants.servicesColor : Constants.paymentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRent ? 'Rent Payment' : 'Service Charge',
                  style: GoogleFonts.hind(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  tenantEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hind(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ ${_currencyFormat.format(amount)}',
                style: GoogleFonts.hind(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.green.shade700,
                ),
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
        ],
      ),
    );
  }

  Widget _buildPropertySummary(Map<String, dynamic> property) {
    final blockNumber = property['block_number'] ?? 'N/A';
    final location = property['location'] ?? 'N/A';
    final totalRevenue = property['total_revenue'] ?? 0.0;
    final tenantCount = property['tenant_count'] ?? 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Constants.themePurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apartment,
              color: Constants.themePurple, size: 20),
        ),
        title: Text(
          blockNumber,
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          location,
          style: GoogleFonts.hind(fontSize: 12, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(totalRevenue),
              style: GoogleFonts.hind(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              '$tenantCount tenant${tenantCount == 1 ? '' : 's'}',
              style: GoogleFonts.hind(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildPropertyDetailRow('Rent Revenue',
                    ((property['rent_revenue'] ?? 0.0) as num).toDouble()),
                const SizedBox(height: 8),
                _buildPropertyDetailRow('Service Revenue',
                    ((property['service_revenue'] ?? 0.0) as num).toDouble()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.hind(color: Colors.grey.shade700)),
        Text(
          _currencyFormat.format(amount),
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Financial Dashboard',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
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
      return _buildEmptyState(
        Icons.insights_outlined,
        'No financial data yet',
        'Once tenants start paying rent and service charges, your summary will show up here.',
      );
    }

    final data = _financialData!['data'];
    final summary = data['summary'];
    final recentTransactions =
        data['recent_transactions'] as List<dynamic>? ?? [];
    final propertyList = data['property_summary'] as List<dynamic>? ?? [];
    final totalRevenue = (summary['total_revenue'] ?? 0.0) as num;

    return RefreshIndicator(
      onRefresh: _loadFinancialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildPeriodChips(),
            const SizedBox(height: 16),
            _buildHeroCard(summary),

            _buildSectionHeader('Revenue Breakdown'),
            _buildBreakdownRow(
              'Rent',
              ((summary['total_rent_revenue'] ?? 0.0) as num).toDouble(),
              totalRevenue.toDouble(),
              Icons.home_outlined,
              Constants.servicesColor,
            ),
            _buildBreakdownRow(
              'Service Charges',
              ((summary['total_service_revenue'] ?? 0.0) as num).toDouble(),
              totalRevenue.toDouble(),
              Icons.build_outlined,
              Constants.paymentColor,
            ),

            _buildSectionHeader('Recent Transactions'),
            if (recentTransactions.isEmpty)
              _buildEmptyState(
                Icons.receipt_long_outlined,
                'No transactions yet',
                'Payments from your tenants will show up here as they come in.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionItem(
                      recentTransactions[index] as Map<String, dynamic>);
                },
              ),

            _buildSectionHeader('Properties Overview'),
            if (propertyList.isEmpty)
              _buildEmptyState(
                Icons.apartment_outlined,
                'No properties yet',
                'Add a property to start tracking its revenue here.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: propertyList.length,
                itemBuilder: (context, index) {
                  return _buildPropertySummary(
                      propertyList[index] as Map<String, dynamic>);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
