import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/api/api_client.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../utils/api_helpers/pdf_report_api.dart';
import '../../utils/constants/constants.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/landlord/report_preview_screen.dart';

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
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  List<Map<String, dynamic>> _occupancy = [];
  String _landlordName = '';
  int _totalUnits = 0;
  int _totalOccupied = 0;
  int _totalVacant = 0;
  double _overallOccupancy = 0;
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
      final token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await SafeHttp.get(
        Uri.parse(Constants.LANDLORD_TRANSACTIONS),
        headers: {'Authorization': 'Bearer $token'},
      );

      log(response.statusCode.toString(), name: "Transactions status code");

      if (response.statusCode != 200) {
        throw Exception('Failed to load transactions (${response.statusCode})');
      }

      final data = jsonDecode(response.body);
      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Could not load transactions');
      }

      final all = <Map<String, dynamic>>[];
      for (final t in (data['rent_transactions'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(t as Map);
        m['type'] = 'rent';
        all.add(m);
      }
      for (final t in (data['service_transactions'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(t as Map);
        m['type'] = 'service';
        all.add(m);
      }
      // Newest first.
      all.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));

      final occ = <Map<String, dynamic>>[];
      for (final o in (data['occupancy'] as List? ?? [])) {
        occ.add(Map<String, dynamic>.from(o as Map));
      }

      if (!mounted) return;
      setState(() {
        _transactions = all;
        _occupancy = occ;
        _landlordName = (data['landlord_name'] ?? '').toString();
        _totalUnits = (data['total_units'] ?? 0) as int;
        _totalOccupied = (data['total_occupied'] ?? 0) as int;
        _totalVacant = (data['total_vacant'] ?? 0) as int;
        _overallOccupancy =
            ((data['overall_occupancy_rate'] ?? 0) as num).toDouble();
        _isLoading = false;
      });
      _filterTransactions();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      log(e.toString(), name: "ERROR LOADING TRANSACTIONS");
    }
  }

  String _dateOf(Map t) => (t['date_paid'] ?? t['date'] ?? '').toString();

  double _amountOf(Map t) =>
      double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;

  double _payoutOf(Map t) =>
      t['payout'] is num ? (t['payout'] as num).toDouble() : _amountOf(t);

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((t) {
        final matchesType =
            _selectedType == 'all' || t['type'] == _selectedType;

        var matchesDate = true;
        if (_selectedDateRange != null) {
          final dateStr = _dateOf(t);
          if (dateStr.isNotEmpty) {
            try {
              final d = DateTime.parse(dateStr);
              matchesDate = d.isAfter(_selectedDateRange!.start
                      .subtract(const Duration(days: 1))) &&
                  d.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)));
            } catch (_) {
              matchesDate = true;
            }
          }
        }
        return matchesType && matchesDate;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _filterTransactions();
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDateRange = null);
    _filterTransactions();
  }

  // ---- totals over the currently-filtered set ----
  double get _rentTotal => _filteredTransactions
      .where((t) => t['type'] == 'rent')
      .fold(0.0, (s, t) => s + _amountOf(t));

  double get _serviceTotal => _filteredTransactions
      .where((t) => t['type'] == 'service')
      .fold(0.0, (s, t) => s + _amountOf(t));

  double get _payoutTotal =>
      _filteredTransactions.fold(0.0, (s, t) => s + _payoutOf(t));

  double get _revenueTotal => _rentTotal + _serviceTotal;

  /// Groups the filtered transactions by calendar month, newest month first.
  List<_MonthGroup> _monthGroups() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in _filteredTransactions) {
      DateTime? d;
      try {
        d = DateTime.parse(_dateOf(t));
      } catch (_) {}
      final key = d != null ? DateFormat('yyyy-MM').format(d) : 'unknown';
      map.putIfAbsent(key, () => []).add(t);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) {
      final list = map[k]!;
      final total = list.fold(0.0, (s, t) => s + _amountOf(t));
      final label = k == 'unknown'
          ? 'Undated'
          : DateFormat('MMMM yyyy').format(DateTime.parse('$k-01'));
      return _MonthGroup(label: label, transactions: list, total: total);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Financial Report',
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      floatingActionButton: (_isLoading || _error.isNotEmpty)
          ? null
          : FloatingActionButton.extended(
              onPressed: _openReportGenerator,
              backgroundColor: Constants.themePurple,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text('Generate report',
                  style: GoogleFonts.hind(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: _buildReportBody(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportBody() {
    if (_filteredTransactions.isEmpty) {
      return [_buildEmptyState()];
    }
    final groups = _monthGroups();
    return [
      _buildHero(),
      _buildBreakdown(),
      if (_occupancy.isNotEmpty) _buildOccupancy(),
      const SizedBox(height: 8),
      for (final g in groups) ...[
        _buildMonthHeader(g),
        ...g.transactions.map(_buildTransactionCard),
      ],
      const SizedBox(height: 96),
    ];
  }

  // ------------------------------------------------------------ occupancy
  Widget _buildOccupancy() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Occupancy',
                  style: GoogleFonts.hind(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Constants.themePurple)),
              Text('$_totalOccupied/$_totalUnits units • ${_overallOccupancy.toStringAsFixed(0)}%',
                  style: GoogleFonts.hind(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 8),
          ..._occupancy.map(_buildOccupancyRow),
        ],
      ),
    );
  }

  Widget _buildOccupancyRow(Map<String, dynamic> o) {
    final total = (o['total_units'] ?? 0) as int;
    final occupied = (o['occupied_units'] ?? 0) as int;
    final rate = ((o['occupancy_rate'] ?? 0) as num).toDouble();
    final share = total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('${o['block_number'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hind(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Text(
                  '$occupied/$total occupied • ${o['vacant_units'] ?? 0} vacant',
                  style: GoogleFonts.hind(
                      fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Constants.themePurple),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text('${rate.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.hind(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- hero
  Widget _buildHero() {
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
            'Total Collected${_selectedType == 'all' ? '' : ' • ${_selectedType[0].toUpperCase()}${_selectedType.substring(1)}'}',
            style: GoogleFonts.hind(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(_revenueTotal),
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
                child: _buildHeroStat('Rent', _currencyFormat.format(_rentTotal),
                    Constants.servicesColor),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildHeroStat('Service',
                    _currencyFormat.format(_serviceTotal), Constants.paymentColor),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildHeroStat(
                    'Your payout', _currencyFormat.format(_payoutTotal), null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, Color? dotColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hind(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hind(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ breakdown
  Widget _buildBreakdown() {
    final total = _revenueTotal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          _buildBreakdownRow('Rent', _rentTotal, total,
              Icons.home_outlined, Constants.servicesColor),
          const SizedBox(height: 10),
          _buildBreakdownRow('Service charges', _serviceTotal, total,
              Icons.build_outlined, Constants.paymentColor),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
      String title, double amount, double total, IconData icon, Color color) {
    final share = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: GoogleFonts.hind(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(_currencyFormat.format(amount),
                      style: GoogleFonts.hind(
                          fontSize: 13, fontWeight: FontWeight.w700)),
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
    );
  }

  // --------------------------------------------------------- month header
  Widget _buildMonthHeader(_MonthGroup g) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            g.label,
            style: GoogleFonts.hind(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Constants.themePurple,
            ),
          ),
          Text(
            _currencyFormat.format(g.total),
            style: GoogleFonts.hind(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- rows
  Widget _buildTransactionCard(Map<String, dynamic> t) {
    final isRent = t['type'] == 'rent';
    final amount = _amountOf(t);
    final date = _dateOf(t);
    final tenantEmail = (t['tenant_email'] ?? 'N/A').toString();
    final paymentMethod = (t['payment_method'] ?? 'mpesa').toString();
    final houseNumber = (t['house_number'] ?? 'N/A').toString();
    final blockNumber = (t['block_number'] ?? '').toString();
    final confirmation = (t['confirmation_code'] ?? '').toString();
    final accent = isRent ? Constants.servicesColor : Constants.paymentColor;

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
          style: GoogleFonts.hind(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${tenantEmail.split('@').first} • House $houseNumber',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hind(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              _formatDateShort(date),
              style: GoogleFonts.hind(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildDetailRow('Amount', _currencyFormat.format(amount)),
                _buildDetailRow(
                    'Your payout', _currencyFormat.format(_payoutOf(t))),
                _buildDetailRow('Tenant', tenantEmail),
                _buildDetailRow(
                    'Property',
                    blockNumber.isEmpty
                        ? 'House $houseNumber'
                        : 'Block $blockNumber, House $houseNumber'),
                _buildDetailRow('Method', paymentMethod.toUpperCase()),
                _buildDetailRow('Date', _formatDateLong(date)),
                if (confirmation.isNotEmpty)
                  _buildDetailRow('Confirmation', confirmation),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.hind(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      return DateFormat('dd MMM').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateLong(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // ---------------------------------------------- report generation (PDF)
  List<_ReportPeriod> _periodsFor(String periodicity, int year) {
    String mmm(DateTime d) => DateFormat('MMM').format(d);
    if (periodicity == 'year') {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year + 1, 1, 1);
      return [_ReportPeriod('FY $year', start, end)];
    }
    if (periodicity == 'half') {
      return List.generate(2, (h) {
        final start = DateTime(year, h * 6 + 1, 1);
        final end = DateTime(year, h * 6 + 7, 1);
        return _ReportPeriod(
            'H${h + 1} $year (${mmm(start)}–${mmm(end.subtract(const Duration(days: 1)))})',
            start,
            end);
      });
    }
    // quarter
    return List.generate(4, (q) {
      final start = DateTime(year, q * 3 + 1, 1);
      final end = DateTime(year, q * 3 + 4, 1);
      return _ReportPeriod(
          'Q${q + 1} $year (${mmm(start)}–${mmm(end.subtract(const Duration(days: 1)))})',
          start,
          end);
    });
  }

  int _currentPeriodIndex(String periodicity, DateTime now) {
    if (periodicity == 'year') return 0;
    if (periodicity == 'half') return now.month <= 6 ? 0 : 1;
    return (now.month - 1) ~/ 3;
  }

  Future<void> _openReportGenerator() async {
    final now = DateTime.now();
    var periodicity = 'quarter';
    var year = now.year;
    var index = _currentPeriodIndex(periodicity, now);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          final periods = _periodsFor(periodicity, year);
          if (index >= periods.length) index = periods.length - 1;

          Widget periodicityChip(String label, String value) {
            final sel = periodicity == value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label,
                    style: GoogleFonts.hind(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Constants.themePurple)),
                selected: sel,
                selectedColor: Constants.themePurple,
                backgroundColor: Colors.white,
                shape: StadiumBorder(
                    side: BorderSide(
                        color: sel
                            ? Constants.themePurple
                            : Colors.grey.shade300)),
                showCheckmark: false,
                onSelected: (_) => setSheet(() {
                  periodicity = value;
                  index = _currentPeriodIndex(value, now);
                }),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 20 + MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Generate Report',
                    style: GoogleFonts.hind(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Constants.themePurple)),
                const SizedBox(height: 4),
                Text(
                  'Pick a reporting period. The PDF is filing-ready — preview, '
                  'download or share it.',
                  style: GoogleFonts.hind(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text('Periodicity',
                    style: GoogleFonts.hind(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    periodicityChip('Quarterly', 'quarter'),
                    periodicityChip('Semi-annual', 'half'),
                    periodicityChip('Annual', 'year'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Year',
                        style: GoogleFonts.hind(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setSheet(() => year--),
                        ),
                        Text('$year',
                            style: GoogleFonts.hind(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: year >= now.year
                              ? null
                              : () => setSheet(() => year++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < periods.length; i++)
                      ChoiceChip(
                        label: Text(periods[i].label,
                            style: GoogleFonts.hind(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: index == i
                                    ? Colors.white
                                    : Constants.themePurple)),
                        selected: index == i,
                        selectedColor: Constants.themePurple,
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: index == i
                                    ? Constants.themePurple
                                    : Colors.grey.shade300)),
                        showCheckmark: false,
                        onSelected: (_) => setSheet(() => index = i),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      _generateReport(periods[index]);
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text('Generate PDF',
                        style: GoogleFonts.hind(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.themePurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _generateReport(_ReportPeriod period) {
    // Transactions within the selected period [start, end).
    final rows = _transactions.where((t) {
      try {
        final d = DateTime.parse(_dateOf(t));
        return !d.isBefore(period.start) && d.isBefore(period.end);
      } catch (_) {
        return false;
      }
    }).toList();

    final rent = rows
        .where((t) => t['type'] == 'rent')
        .fold(0.0, (s, t) => s + _amountOf(t));
    final service = rows
        .where((t) => t['type'] == 'service')
        .fold(0.0, (s, t) => s + _amountOf(t));
    final payout = rows.fold(0.0, (s, t) => s + _payoutOf(t));
    final rentCount = rows.where((t) => t['type'] == 'rent').length;
    final serviceCount = rows.where((t) => t['type'] == 'service').length;

    final doc = PdfReportApi.generate(
      landlordName: _landlordName,
      periodLabel: period.label,
      generatedOn: DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      totalRent: rent,
      totalService: service,
      totalRevenue: rent + service,
      totalPayout: payout,
      rentCount: rentCount,
      serviceCount: serviceCount,
      occupancy: _occupancy,
      totalUnits: _totalUnits,
      totalOccupied: _totalOccupied,
      totalVacant: _totalVacant,
      overallOccupancyRate: _overallOccupancy,
      transactions: rows,
    );

    final safe = period.label.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReportPreviewScreen(
        document: doc,
        filename: 'SmartNyumba_Report_$safe.pdf',
        periodLabel: period.label,
      ),
    ));
  }

  // -------------------------------------------------------------- chrome
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                    : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                style: GoogleFonts.hind(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Constants.themePurple,
                side: BorderSide(color: Colors.grey.shade300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            if (_selectedDateRange != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: _clearDateFilter,
                tooltip: 'Clear date filter',
              ),
            ],
          ],
        ),
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
        setState(() => _selectedType = value);
        _filterTransactions();
      },
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedType == 'all' && _selectedDateRange == null
                  ? 'No payments yet'
                  : 'No transactions match your filters',
              style: GoogleFonts.hind(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Rent and service charge payments from your\ntenants will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Could not load report',
              style:
                  GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.hind(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
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

class _MonthGroup {
  final String label;
  final List<Map<String, dynamic>> transactions;
  final double total;

  _MonthGroup({
    required this.label,
    required this.transactions,
    required this.total,
  });
}

/// A reporting window: [start, end) with a human label (e.g. "Q3 2026").
class _ReportPeriod {
  final String label;
  final DateTime start;
  final DateTime end; // exclusive

  _ReportPeriod(this.label, this.start, this.end);
}
