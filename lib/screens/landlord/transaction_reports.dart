import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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

      Uri uri = Uri.parse(Constants.ALL_TRANSACTIONS);
      final response = await http.get(
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
    final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
    final date = transaction['date_paid'] ?? transaction['date'] ?? '';
    final tenantEmail = transaction['tenant_email'] ??
                        transaction['tenant']?['email'] ?? 'N/A';
    final paymentMethod = transaction['payment_method'] ?? 'mpesa';
    final houseNumber = transaction['house_number'] ??
                        transaction['property_block']?['house_number'] ?? 'N/A';

    // Calculate commission (5%)
    final commission = amount * 0.05;
    final landlordPayout = amount - commission;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ExpansionTile(
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
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'House $houseNumber • $tenantEmail',
              style: GoogleFonts.hind(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(date),
              style: GoogleFonts.hind(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(amount),
              style: GoogleFonts.hind(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
            Text(
              paymentMethod.toUpperCase(),
              style: GoogleFonts.hind(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow('Total Amount', _currencyFormat.format(amount)),
                _buildDetailRow(
                  'Commission (5%)',
                  _currencyFormat.format(commission),
                ),
                _buildDetailRow(
                  'Your Payout',
                  _currencyFormat.format(landlordPayout),
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
    double totalCommission = 0;
    double totalPayout = 0;
    int rentCount = 0;
    int serviceCount = 0;

    for (var transaction in _filteredTransactions) {
      double amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
      totalAmount += amount;
      totalCommission += amount * 0.05;
      totalPayout += amount * 0.95;

      if (transaction['type'] == 'rent') {
        rentCount++;
      } else {
        serviceCount++;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Summary',
              style: GoogleFonts.hind(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Rent', rentCount.toString(), Colors.blue),
                _buildSummaryItem(
                    'Service', serviceCount.toString(), Colors.green),
                _buildSummaryItem(
                    'Total', _filteredTransactions.length.toString(), Colors.orange),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Total Revenue', _currencyFormat.format(totalAmount)),
            _buildDetailRow('Total Commission', _currencyFormat.format(totalCommission)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Total Payout',
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[900],
                    ),
                  ),
                  Text(
                    _currencyFormat.format(totalPayout),
                    style: GoogleFonts.hind(
                      fontSize: 16,
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

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.hind(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hind(
            fontSize: 12,
            color: Colors.grey[700],
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
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = value;
        });
        _filterTransactions();
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
    );
  }
}
