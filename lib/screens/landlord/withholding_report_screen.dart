import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/subscription_provider.dart';

class WithholdingReportScreen extends StatefulWidget {
  static const routeName = '/withholding-report';
  const WithholdingReportScreen({super.key});

  @override
  State<WithholdingReportScreen> createState() =>
      _WithholdingReportScreenState();
}

class _WithholdingReportScreenState extends State<WithholdingReportScreen> {
  int _year = DateTime.now().year;
  Map<String, dynamic>? _report;
  bool _loading = true;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _loading = true);
    try {
      final report =
          await Provider.of<SubscriptionProvider>(context, listen: false)
              .fetchWithholdingReport(_year);
      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthly = (_report?['monthly'] as List<dynamic>? ?? []);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: royalBlue,
        title: Text(
          'Tax Withholding',
          style: GoogleFonts.hind(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          DropdownButton<int>(
            value: _year,
            dropdownColor: royalBlue,
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white,
            items: List.generate(5, (i) => DateTime.now().year - i)
                .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(
                        '$year',
                        style: GoogleFonts.hind(color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: (year) {
              if (year != null) {
                setState(() => _year = year);
                _loadReport();
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: royalBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: royalBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total withheld in $_year (${_report?['withholding_rate'] ?? '10%'})',
                        style: GoogleFonts.hind(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'KES ${_report?['total_withheld'] ?? '0'}',
                        style: GoogleFonts.hind(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (monthly.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No withholding recorded for $_year.',
                        style: GoogleFonts.hind(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ...monthly.map((row) {
                  final month = (row['month'] ?? 1) as int;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _monthNames[(month - 1).clamp(0, 11)],
                          style: GoogleFonts.hind(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'KES ${row['total_withheld'] ?? '0'}',
                              style: GoogleFonts.hind(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: royalBlue,
                              ),
                            ),
                            Text(
                              'of KES ${row['total_rent'] ?? '0'} rent',
                              style: GoogleFonts.hind(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
