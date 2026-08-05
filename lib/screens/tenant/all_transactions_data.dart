import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/api_helpers/pdf_invoice_api.dart';
import '../../utils/constants/colors.dart';
import '../../utils/models/rent_summary.dart';
import '../../utils/models/service_summary.dart';
import '../../utils/providers/_providers.dart';
import '../../widgets/tenant/receipt_preview_dialog.dart';
import 'payment_webview_screen.dart';

/// ---------------------------------------------------------------------------
/// Shared, tab-agnostic view models so the Rent and Service Charge tabs render
/// through the same widgets.
/// ---------------------------------------------------------------------------
class _PayRow {
  final String amount;
  final int status; // 1 = completed
  final String mode;
  final DateTime? date;
  final String reference;
  _PayRow(this.amount, this.status, this.mode, this.date, this.reference);
}

class _MonthRow {
  final int month;
  final int year;
  final String monthName;
  final double required;
  final double paid;
  final double balance;
  final String status; // paid / partial / unpaid
  final bool isCurrentMonth;
  final bool isOverdue;
  final List<_PayRow> payments;
  _MonthRow({
    required this.month,
    required this.year,
    required this.monthName,
    required this.required,
    required this.paid,
    required this.balance,
    required this.status,
    required this.isCurrentMonth,
    required this.isOverdue,
    required this.payments,
  });

  String get key => '$month-$year';
}

class _TabModel {
  final String purpose; // "Rent" / "Service Charge"
  final double monthlyAmount;
  final String house;
  final String block;
  final List<_MonthRow> months; // past + current only, newest first
  _TabModel({
    required this.purpose,
    required this.monthlyAmount,
    required this.house,
    required this.block,
    required this.months,
  });

  double get outstanding => months
      .where((m) => (m.isOverdue || m.isCurrentMonth) && m.balance > 0)
      .fold(0.0, (s, m) => s + m.balance);

  int get unpaidCount => months
      .where((m) => (m.isOverdue || m.isCurrentMonth) && m.balance > 0)
      .length;
}

class AllTransactionsData extends StatefulWidget {
  static const routeName = "/all-tx-data";
  const AllTransactionsData({super.key});

  @override
  State<AllTransactionsData> createState() => _AllTransactionsDataState();
}

class _AllTransactionsDataState extends State<AllTransactionsData>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String name = '';

  // Multi-month selection ("month-year" keys), per tab
  final Set<String> _selectedRent = {};
  final Set<String> _selectedService = {};
  // month-key -> balance, per tab, for totalling the "pay selected" bar
  final Map<String, double> _rentBalances = {};
  final Map<String, double> _serviceBalances = {};

  Set<String> _selectedFor(bool rent) => rent ? _selectedRent : _selectedService;
  Map<String, double> _balancesFor(bool rent) =>
      rent ? _rentBalances : _serviceBalances;

  late Future<_TabModel> _rentFuture;
  late Future<_TabModel> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reload();
    Auth()
        .getProfile(SharedPrefrenceBuilder.getUserToken!, context)
        .then((value) {
      if (!mounted) return;
      setState(() => name = value.profile?.user?.firstName ?? 'Tenant');
    }).catchError((e) {
      log(e.toString(), name: 'STATEMENT PROFILE');
    });
  }

  void _reload() {
    final payments = Provider.of<Payments>(context, listen: false);
    _rentFuture = payments.getMonthlyRentSummary().then(_toRentModel);
    _serviceFuture = payments.getMonthlyServiceSummary().then(_toServiceModel);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- conversions -----------------------------------------------------------

  bool _pastOrCurrent(int month, int year) {
    final now = DateTime.now();
    return year < now.year || (year == now.year && month <= now.month);
  }

  _TabModel _toRentModel(RentSummaryResponse r) {
    final d = r.data;
    final months = <_MonthRow>[];
    if (d != null) {
      for (final s in d.summaries) {
        if (!_pastOrCurrent(s.month, s.year)) continue;
        months.add(_MonthRow(
          month: s.month,
          year: s.year,
          monthName: s.monthName,
          required: double.tryParse(s.requiredAmount) ?? 0,
          paid: double.tryParse(s.totalPaid) ?? 0,
          balance: double.tryParse(s.balance) ?? 0,
          status: s.paymentStatus,
          isCurrentMonth: s.isCurrentMonth,
          isOverdue: s.isOverdue,
          payments: s.payments
              .map((p) => _PayRow(p.amount, p.status, p.paymentMode,
                  p.createdAt, 'RENT-${p.id}'))
              .toList(),
        ));
      }
    }
    months.sort(_newestFirst);
    _rentBalances
      ..clear()
      ..addEntries(
          months.where((m) => m.balance > 0).map((m) => MapEntry(m.key, m.balance)));
    return _TabModel(
      purpose: 'Rent',
      monthlyAmount: double.tryParse(d?.monthlyRent ?? '0') ?? 0,
      house: d?.property.houseNumber ?? '-',
      block: d?.property.block ?? '-',
      months: months,
    );
  }

  _TabModel _toServiceModel(ServiceSummaryResponse r) {
    final d = r.data;
    final months = <_MonthRow>[];
    if (d != null) {
      for (final s in d.summaries) {
        if (!_pastOrCurrent(s.month, s.year)) continue;
        months.add(_MonthRow(
          month: s.month,
          year: s.year,
          monthName: s.monthName,
          required: double.tryParse(s.requiredAmount) ?? 0,
          paid: double.tryParse(s.totalPaid) ?? 0,
          balance: double.tryParse(s.balance) ?? 0,
          status: s.paymentStatus,
          isCurrentMonth: s.isCurrentMonth,
          isOverdue: s.isOverdue,
          payments: s.payments
              .map((p) => _PayRow(p.amount, p.status, p.paymentMode,
                  p.createdAt, p.confirmationCode))
              .toList(),
        ));
      }
    }
    months.sort(_newestFirst);
    _serviceBalances
      ..clear()
      ..addEntries(
          months.where((m) => m.balance > 0).map((m) => MapEntry(m.key, m.balance)));
    return _TabModel(
      purpose: 'Service Charge',
      monthlyAmount: double.tryParse(d?.monthlyService ?? '0') ?? 0,
      house: d?.property.houseNumber ?? '-',
      block: d?.property.block ?? '-',
      months: months,
    );
  }

  int _newestFirst(_MonthRow a, _MonthRow b) {
    if (a.year != b.year) return b.year.compareTo(a.year);
    return b.month.compareTo(a.month);
  }

  // --- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: royalBlue,
        foregroundColor: Colors.white,
        title: Text('Payment Statement',
            style: GoogleFonts.hind(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: lightGold,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hind(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Rent Payments'),
            Tab(text: 'Service Charges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _tab(_rentFuture, rent: true),
          _tab(_serviceFuture, rent: false),
        ],
      ),
    );
  }

  Widget _tab(Future<_TabModel> future, {required bool rent}) {
    return FutureBuilder<_TabModel>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: royalBlue));
        }
        if (snap.hasError || !snap.hasData) {
          return _errorState(rent);
        }
        final model = snap.data!;
        return Stack(
          children: [
            RefreshIndicator(
              color: royalBlue,
              onRefresh: () async {
                setState(_reload);
                await (rent ? _rentFuture : _serviceFuture);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                  _summaryHeader(model),
                  const SizedBox(height: 20),
                  if (model.unpaidCount == 0) _allCaughtUp(),
                  if (model.unpaidCount == 0) const SizedBox(height: 12),
                  Text('Monthly breakdown',
                      style: GoogleFonts.hind(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: royalBlue)),
                  const SizedBox(height: 8),
                  if (model.months.isEmpty)
                    _emptyMonths()
                  else
                    ...model.months.map((m) => _monthCard(model, m, rent)),
                ],
              ),
            ),
            if (_selectedFor(rent).isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _paySelectedBar(rent),
              ),
          ],
        );
      },
    );
  }

  // --- summary header --------------------------------------------------------

  Widget _summaryHeader(_TabModel m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [royalBlue, Color(0xFF3A3A8C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${m.purpose} outstanding',
              style: GoogleFonts.hind(
                  color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text('KES ${m.outstanding.toStringAsFixed(2)}',
              style: GoogleFonts.hind(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Monthly', 'KES ${m.monthlyAmount.toStringAsFixed(0)}'),
              const SizedBox(width: 12),
              _stat(
                  'Months unpaid',
                  m.unpaidCount == 0 ? 'None' : '${m.unpaidCount}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.home_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text('House ${m.house} · Block ${m.block}',
                  style: GoogleFonts.hind(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.hind(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.hind(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // --- month card ------------------------------------------------------------

  Widget _monthCard(_TabModel model, _MonthRow m, bool rent) {
    final ps = _pillStyle(m);
    final isPaid = m.status == 'paid';
    final selectable = !isPaid && m.balance > 0;
    final selected = _selectedFor(rent).contains(m.key);
    void toggle(bool on) => setState(() =>
        on ? _selectedFor(rent).add(m.key) : _selectedFor(rent).remove(m.key));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? royalBlue : const Color(0xFFECECF2),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isPaid) {
              _openReceiptPreview(model, m);
            } else if (selectable) {
              toggle(!selected);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // leading icon / checkbox
                if (selectable)
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      value: selected,
                      activeColor: royalBlue,
                      onChanged: (v) => toggle(v == true),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ps.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(ps.icon, color: ps.fg, size: 20),
                  ),
                const SizedBox(width: 12),
                // month + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${m.monthName} ${m.year}',
                              style: GoogleFonts.hind(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: royalBlue)),
                          if (m.isCurrentMonth) ...[
                            const SizedBox(width: 6),
                            _chip('This month'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isPaid
                            ? 'Paid KES ${m.paid.toStringAsFixed(2)}'
                            : m.paid > 0
                                ? 'Paid KES ${m.paid.toStringAsFixed(2)} · Balance KES ${m.balance.toStringAsFixed(2)}'
                                : 'Due KES ${m.required.toStringAsFixed(2)}',
                        style: GoogleFonts.hind(
                            fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                // trailing pill + affordance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _pill(ps),
                    const SizedBox(height: 6),
                    Text(
                      isPaid
                          ? 'Receipt'
                          : selectable
                              ? (selected ? 'Selected' : 'Select')
                              : '—',
                      style: GoogleFonts.hind(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? darkGreen : royalBlue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: lightGold,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: GoogleFonts.hind(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      );

  // --- status pill -----------------------------------------------------------

  _PillStyle _pillStyle(_MonthRow m) {
    if (m.status == 'paid') {
      return _PillStyle('Paid', const Color(0xFFE7F6E9), darkGreen,
          Icons.check_circle, darkGreen);
    }
    if (m.status == 'partial') {
      return _PillStyle('Partial', const Color(0xFFFFF6DF),
          const Color(0xFF9A7A11), Icons.timelapse, const Color(0xFF9A7A11));
    }
    if (m.isOverdue) {
      return _PillStyle('Overdue', const Color(0xFFFDECEC),
          const Color(0xFFC62828), Icons.warning_amber_rounded,
          const Color(0xFFC62828));
    }
    if (m.isCurrentMonth) {
      return _PillStyle('Due now', const Color(0xFFEAEAF5), royalBlue,
          Icons.schedule, royalBlue);
    }
    return _PillStyle('Unpaid', const Color(0xFFEFEFF3), Colors.grey.shade600,
        Icons.remove_circle_outline, Colors.grey.shade600);
  }

  Widget _pill(_PillStyle s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: s.bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(s.label,
            style: GoogleFonts.hind(
                fontSize: 11, fontWeight: FontWeight.w700, color: s.fg)),
      );

  // --- receipt ---------------------------------------------------------------

  void _openReceiptPreview(_TabModel model, _MonthRow m) {
    final completed = m.payments.where((p) => p.status == 1).toList();
    final pay = completed.isNotEmpty ? completed.first : null;
    final datePaid = DateFormat.yMMMMd().format(pay?.date ?? DateTime.now());
    final reference = pay?.reference ?? '';
    final amount = (m.paid > 0 ? m.paid : m.required).toStringAsFixed(2);
    final period = '${m.monthName} ${m.year}';
    final filename =
        '${model.purpose.replaceAll(' ', '')}-receipt-${m.monthName}-${m.year}.pdf';

    final doc = PdfApi.generateReceipt(
      tenantName: name.isEmpty ? 'Tenant' : name,
      house: model.house,
      block: model.block,
      purpose: model.purpose,
      period: period,
      amount: amount,
      datePaid: datePaid,
      reference: reference,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiptPreviewScreen(
          document: doc,
          filename: filename,
          title: '${model.purpose} receipt',
          subtitle: '$period · KES $amount',
          type: model.purpose == 'Rent' ? 'rent' : 'service',
          month: m.month,
          year: m.year,
        ),
      ),
    );
  }

  // --- pay actions -----------------------------------------------------------

  double _selectedTotal(bool rent) {
    final balances = _balancesFor(rent);
    return _selectedFor(rent).fold(0.0, (s, k) => s + (balances[k] ?? 0));
  }

  Widget _paySelectedBar(bool rent) {
    final count = _selectedFor(rent).length;
    return Material(
      color: royalBlue,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showPayMultiMonthDialog(rent),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pay $count month(s)',
                  style: GoogleFonts.hind(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text('KES ${_selectedTotal(rent).toStringAsFixed(2)}  →',
                  style: GoogleFonts.hind(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  void _showPayMultiMonthDialog(bool rent) {
    final mobileController = TextEditingController();
    final count = _selectedFor(rent).length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Pay $count month(s)',
            style: GoogleFonts.hind(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: KES ${_selectedTotal(rent).toStringAsFixed(2)}',
                style: GoogleFonts.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: royalBlue)),
            const SizedBox(height: 12),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa number',
                hintText: '254XXXXXXXXX',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.hind(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: royalBlue),
            onPressed: () =>
                _initiateMultiMonthPayment(mobileController.text, rent),
            child: Text('Pay now',
                style: GoogleFonts.hind(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateMultiMonthPayment(String mobile, bool rent) async {
    if (!RegExp(r'^254\d{9}$').hasMatch(mobile.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your number as 254XXXXXXXXX')),
      );
      return;
    }
    Navigator.pop(context); // close dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: royalBlue)),
    );
    try {
      final selected = _selectedFor(rent);
      final months = selected.map((k) {
        final p = k.split('-');
        return {'month': int.parse(p[0]), 'year': int.parse(p[1])};
      }).toList();

      final payments = Provider.of<Payments>(context, listen: false);
      final res = rent
          ? await payments.payMultiMonthRent(mobile.trim(), months)
          : await payments.payMultiMonthService(mobile.trim(), months);

      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (res.status == true && res.redirectUrl != null) {
        selected.clear();
        Navigator.pushNamed(
          context,
          PaymentWebViewScreen.routeName,
          arguments: {
            'paymentType': rent ? 'rent' : 'service',
            'redirectUrl': res.redirectUrl,
            'orderTrackingId': res.orderTrackingId,
            'email': SharedPrefrenceBuilder.getUserEmail,
          },
        ).then((_) {
          if (mounted) setState(_reload);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res.message)));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      log(e.toString(), name: 'MULTI-MONTH PAY');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment could not be started.')),
      );
    }
  }

  // --- misc states -----------------------------------------------------------

  Widget _allCaughtUp() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F6E9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: darkGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text("You're all caught up — no payments due.",
                  style: GoogleFonts.hind(
                      color: darkGreen, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _emptyMonths() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No payment history yet.',
              style: GoogleFonts.hind(color: Colors.grey.shade600)),
        ),
      );

  Widget _errorState(bool rent) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Could not load your statement.',
                  style: GoogleFonts.hind(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: royalBlue),
                onPressed: () => setState(_reload),
                child: Text('Retry',
                    style: GoogleFonts.hind(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
}

class _PillStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;
  final Color iconColor;
  _PillStyle(this.label, this.bg, this.fg, this.icon, [Color? ic])
      : iconColor = ic ?? fg;
}
