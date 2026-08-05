import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/api/api_client.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../utils/constants/constants.dart';
import '../../utils/providers/shared_preference_builder.dart';

class TransactionReportsScreen extends StatefulWidget {
  static const routeName = "/landlord-transaction-reports";

  const TransactionReportsScreen({super.key});

  @override
  State<TransactionReportsScreen> createState() =>
      _TransactionReportsScreenState();
}

class _TransactionReportsScreenState extends State<TransactionReportsScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _transactions = [];
  List<dynamic> _filteredTransactions = [];
  String _selectedType = 'all';
  DateTimeRange? _selectedDateRange;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Use landlord-specific transactions endpoint
      Uri uri = Uri.parse(Constants.LANDLORD_TRANSACTIONS);
      final response = await SafeHttp.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Transactions status code");
      log(response.body.toString(), name: "Transactions response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Combine rent and service transactions
            List<dynamic> allTransactions = [];
            if (data['rent_transactions'] != null) {
              for (var t in data['rent_transactions']) {
                t['type'] = 'rent';
                allTransactions.add(t);
              }
            }
            if (data['service_transactions'] != null) {
              for (var t in data['service_transactions']) {
                t['type'] = 'service';
                allTransactions.add(t);
              }
            }
            // Sort by date (most recent first)
            allTransactions.sort((a, b) {
              String dateA = a['date_paid'] ?? a['date'] ?? '';
              String dateB = b['date_paid'] ?? b['date'] ?? '';
              return dateB.compareTo(dateA);
            });

            _transactions = allTransactions;
            _filteredTransactions = _transactions;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        log(e.toString(), name: "ERROR LOADING TRANSACTIONS");
      }
    }
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        // Type filter
        bool matchesType = _selectedType == 'all' ||
            transaction['type'] == _selectedType;

        // Date range filter
        bool matchesDateRange = true;
        if (_selectedDateRange != null) {
          String dateStr = transaction['date_paid'] ?? transaction['date'] ?? '';
          if (dateStr.isNotEmpty) {
            try {
              DateTime transactionDate = DateTime.parse(dateStr);
              matchesDateRange =
                  transactionDate.isAfter(_selectedDateRange!.start) &&
                      transactionDate.isBefore(
                        _selectedDateRange!.end.add(const Duration(days: 1)),
                      );
            } catch (e) {
              matchesDateRange = true; // Include if date parsing fails
            }
          }
        }

        return matchesType && matchesDateRange;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterTransactions();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _filterTransactions();
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'rent';
    final isRent = type == 'rent';
    final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
    final date = transaction['date_paid'] ?? transaction['date'] ?? '';
    final tenantEmail = transaction['tenant_email'] ??
                        transaction['tenant']?['email'] ?? 'N/A';
    final paymentMethod = transaction['payment_method'] ?? 'mpesa';
    final houseNumber = transaction['house_number'] ??
                        transaction['property_block']?['house_number'] ?? 'N/A';
    final accent =
        isRent ? Constants.servicesColor : Constants.paymentColor;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isRent ? Icons.home_outlined : Icons.build_outlined,
            color: accent,
            size: 20,
          ),
        ),
        title: Text(
          isRent ? 'Rent Payment' : 'Service Charge',
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'House $houseNumber • ${_formatDate(date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hind(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          '+ ${_currencyFormat.format(amount)}',
          style: GoogleFonts.hind(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.green.shade700,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Total Amount', _currencyFormat.format(amount)),
                _buildDetailRow(
                  'Your Payout',
                  _currencyFormat.format(amount),
                ),
                _buildDetailRow('Payment Method', paymentMethod.toUpperCase()),
                _buildDetailRow('Date', _formatDate(date)),
                _buildDetailRow('Tenant', tenantEmail),
                _buildDetailRow('House Number', houseNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.hind(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.hind(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildSummaryCard() {
    double totalAmount = 0;
    int rentCount = 0;
    int serviceCount = 0;

    for (var transaction in _filteredTransactions) {
      totalAmount +=
          double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
      if (transaction['type'] == 'rent') {
        rentCount++;
      } else {
        serviceCount++;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constants.themePurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Payout',
            style: GoogleFonts.hind(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(totalAmount),
            style: GoogleFonts.hind(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                    'Rent', '$rentCount', Constants.servicesColor),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Service', '$serviceCount', Constants.paymentColor),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Total', '${_filteredTransactions.length}', Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color dotColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.hind(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.hind(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
          'Transaction Reports',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rent', 'rent'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Service', 'service'),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _selectedDateRange == null
                          ? 'Date Range'
                          : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                      style: GoogleFonts.hind(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Constants.themePurple,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _clearDateFilter,
                      tooltip: 'Clear date filter',
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
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
                              'Error loading transactions',
                              style: GoogleFonts.hind(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _error,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hind(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTransactions,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions found',
                                  style: GoogleFonts.hind(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTransactions,
                            child: ListView.builder(
                              itemCount: _filteredTransactions.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildSummaryCard();
                                }
                                return _buildTransactionCard(
                                  _filteredTransactions[index - 1]
                                      as Map<String, dynamic>,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedType == value;
    return ChoiceChip(
      label: Text(
        label,
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
          color: selected ? Constants.themePurple : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
      onSelected: (_) {
        setState(() {
          _selectedType = value;
        });
        _filterTransactions();
      },
    );
  }
}
