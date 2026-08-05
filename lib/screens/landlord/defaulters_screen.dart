import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utils/api/api_client.dart';
import '../../utils/api_helpers/pdf_defaulters_api.dart';
import '../../utils/constants/constants.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/landlord/report_preview_screen.dart';

class DefaultersScreen extends StatefulWidget {
  static const routeName = '/landlord-defaulters';
  const DefaultersScreen({super.key});

  @override
  State<DefaultersScreen> createState() => _DefaultersScreenState();
}

class _DefaultersScreenState extends State<DefaultersScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _properties = [];
  int _totalDefaulters = 0;
  double _totalArrears = 0;
  double _totalPenalty = 0;
  double _totalDue = 0;

  final _money = NumberFormat.currency(symbol: 'KSh ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final token = SharedPrefrenceBuilder.getUserToken;
      final res = await SafeHttp.get(
        Uri.parse(Constants.LANDLORD_DEFAULTERS),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to load defaulters (${res.statusCode})');
      }
      final data = jsonDecode(res.body);
      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Could not load defaulters');
      }
      final props = <Map<String, dynamic>>[];
      for (final p in (data['properties'] as List? ?? [])) {
        props.add(Map<String, dynamic>.from(p as Map));
      }
      if (!mounted) return;
      setState(() {
        _properties = props;
        _totalDefaulters = (data['total_defaulters'] ?? 0) as int;
        _totalArrears = ((data['total_arrears'] ?? 0) as num).toDouble();
        _totalPenalty = ((data['total_penalty'] ?? 0) as num).toDouble();
        _totalDue =
            ((data['total_due'] ?? data['total_arrears'] ?? 0) as num)
                .toDouble();
        _loading = false;
      });
    } catch (e) {
      log(e.toString(), name: 'DEFAULTERS');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Defaulters',
            style: GoogleFonts.hind(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: (_loading || _error.isNotEmpty || _totalDefaulters == 0)
          ? null
          : FloatingActionButton.extended(
              onPressed: _generatePdf,
              backgroundColor: Constants.themePurple,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text('Report',
                  style: GoogleFonts.hind(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _errorState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: _body(),
                  ),
                ),
    );
  }

  List<Widget> _body() {
    final withDefaulters =
        _properties.where((p) => (p['defaulter_count'] ?? 0) > 0).toList();
    if (withDefaulters.isEmpty) {
      return [_emptyState()];
    }
    return [
      _hero(),
      for (final p in withDefaulters) ...[
        _propertyHeader(p),
        ...((p['defaulters'] as List? ?? []))
            .map((d) => _defaulterCard(Map<String, dynamic>.from(d as Map))),
      ],
      const SizedBox(height: 24),
    ];
  }

  Widget _hero() {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total due',
                        style: GoogleFonts.hind(
                            fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(_money.format(_totalDue),
                        style: GoogleFonts.hind(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$_totalDefaulters',
                      style: GoogleFonts.hind(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(_totalDefaulters == 1 ? 'defaulter' : 'defaulters',
                      style: GoogleFonts.hind(
                          fontSize: 12, color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Arrears ${_money.format(_totalArrears)}'
            '${_totalPenalty > 0 ? '  +  penalty ${_money.format(_totalPenalty)}' : ''}',
            style: GoogleFonts.hind(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _propertyHeader(Map<String, dynamic> p) {
    final rate = ((p['penalty_rate'] ?? 0) as num).toDouble();
    final due =
        ((p['total_due'] ?? p['total_arrears'] ?? 0) as num).toDouble();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${p['block_number'] ?? '-'}  •  ${p['defaulter_count'] ?? 0} owing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hind(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Constants.themePurple),
                ),
              ),
              Text(_money.format(due),
                  style: GoogleFonts.hind(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: () => _editPenalty(p),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.percent,
                      size: 13, color: Constants.themePurple),
                  const SizedBox(width: 4),
                  Text(
                    rate > 0
                        ? 'Late penalty ${_rateLabel(rate)}%'
                        : 'Set late penalty',
                    style: GoogleFonts.hind(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Constants.themePurple),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit,
                      size: 12, color: Constants.themePurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rateLabel(double r) =>
      r == r.truncateToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(2);

  Future<void> _editPenalty(Map<String, dynamic> p) async {
    final ctrl = TextEditingController(
        text: ((p['penalty_rate'] ?? 0) as num) == 0
            ? ''
            : _rateLabel(((p['penalty_rate'] ?? 0) as num).toDouble()));
    final saved = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text('Late penalty — ${p['block_number'] ?? ''}',
            style: GoogleFonts.hind(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Percentage added to a defaulter\'s outstanding balance in this '
              'property.',
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Penalty rate (%)',
                hintText: 'e.g. 5',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Constants.themePurple),
            onPressed: () => Navigator.pop(dctx, true),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final rate = double.tryParse(ctrl.text.trim());
    if (rate == null || rate < 0 || rate > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enter a rate between 0 and 100.')));
      }
      return;
    }
    try {
      final res = await ApiClient.post(
        Constants.SET_PROPERTY_PENALTY,
        body: {
          'property_id': '${p['property_id']}',
          'penalty_rate': '$rate',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not update penalty.')));
      }
    } catch (e) {
      log(e.toString(), name: 'SET PENALTY');
    }
  }

  void _generatePdf() {
    final name = '${SharedPrefrenceBuilder.getUserFirstName ?? ''} '
            '${SharedPrefrenceBuilder.getUserLastName ?? ''}'
        .trim();
    final doc = PdfDefaultersApi.generate(
      landlordName: name,
      generatedOn: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      totalDefaulters: _totalDefaulters,
      totalArrears: _totalArrears,
      totalPenalty: _totalPenalty,
      totalDue: _totalDue,
      properties: _properties,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReportPreviewScreen(
        document: doc,
        filename: 'SmartNyumba_Defaulters.pdf',
        periodLabel: 'Defaulters',
      ),
    ));
  }

  Widget _defaulterCard(Map<String, dynamic> d) {
    final rentArrears = ((d['rent_arrears'] ?? 0) as num).toDouble();
    final serviceArrears = ((d['service_arrears'] ?? 0) as num).toDouble();
    final rentMonths = (d['rent_months_overdue'] ?? 0) as int;
    final serviceMonths = (d['service_months_overdue'] ?? 0) as int;
    final total = ((d['total_arrears'] ?? 0) as num).toDouble();
    final penalty = ((d['penalty_amount'] ?? 0) as num).toDouble();
    final due = ((d['total_due'] ?? d['total_arrears'] ?? 0) as num).toDouble();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade400, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d['tenant_name'] ?? d['tenant_email'] ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hind(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('House ${d['house_number'] ?? '-'}',
                          style: GoogleFonts.hind(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(_money.format(due),
                    style: GoogleFonts.hind(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (rentArrears > 0)
                  _chip('Rent', rentArrears, rentMonths,
                      Constants.servicesColor),
                if (serviceArrears > 0)
                  _chip('Service', serviceArrears, serviceMonths,
                      Constants.paymentColor),
              ],
            ),
            if (penalty > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Arrears ${_money.format(total)}  +  penalty ${_money.format(penalty)}',
                style: GoogleFonts.hind(
                    fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, double amount, int months, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label  ${_money.format(amount)}  ·  ${months}mo',
        style: GoogleFonts.hind(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _emptyState() {
    return SizedBox(
      height: 460,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text('No defaulters',
                style: GoogleFonts.hind(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text('Every tenant is up to date on rent\nand service charges.',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Could not load defaulters',
                style:
                    GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error,
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.themePurple),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
