import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds an accountant-friendly landlord financial report as a paginated PDF:
/// header, financial summary, per-property occupancy, and a transaction ledger
/// grouped by month with subtotals. Downloadable + shareable by the caller.
class PdfReportApi {
  static const PdfColor _accent = PdfColor.fromInt(0xFF22215B); // themePurple
  static final NumberFormat _money =
      NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2);

  static pw.Document generate({
    required String landlordName,
    required String periodLabel,
    required String generatedOn,
    required double totalRent,
    required double totalService,
    required double totalRevenue,
    required double totalPayout,
    required int rentCount,
    required int serviceCount,
    required List<Map<String, dynamic>> occupancy,
    required int totalUnits,
    required int totalOccupied,
    required int totalVacant,
    required double overallOccupancyRate,
    required List<Map<String, dynamic>> transactions,
  }) {
    final pdf = pw.Document();
    final groups = _monthGroups(transactions);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) =>
            ctx.pageNumber == 1 ? pw.SizedBox() : _miniHeader(periodLabel),
        footer: (ctx) => _footer(ctx, generatedOn),
        build: (ctx) => [
          _header(landlordName, periodLabel, generatedOn),
          pw.SizedBox(height: 18),
          _sectionTitle('Financial Summary'),
          pw.SizedBox(height: 6),
          _summaryTable(totalRent, totalService, totalRevenue, totalPayout,
              rentCount, serviceCount),
          pw.SizedBox(height: 18),
          _sectionTitle('Occupancy Summary'),
          pw.SizedBox(height: 6),
          _occupancyTable(occupancy, totalUnits, totalOccupied, totalVacant,
              overallOccupancyRate),
          pw.SizedBox(height: 18),
          _sectionTitle('Transaction Ledger'),
          if (groups.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child: pw.Text('No transactions in this period.',
                  style: const pw.TextStyle(color: PdfColors.grey600)),
            ),
          for (final g in groups) ...[
            pw.SizedBox(height: 10),
            _monthHeading(g.label, g.total),
            pw.SizedBox(height: 4),
            _ledgerTable(g.rows),
          ],
          pw.SizedBox(height: 18),
          _grandTotalRow(totalRevenue),
        ],
      ),
    );
    return pdf;
  }

  // ------------------------------------------------------------ header/footer
  static pw.Widget _header(
      String landlordName, String periodLabel, String generatedOn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _accent,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Smart Nyumba',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Financial Report',
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 12)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(landlordName.isEmpty ? 'Landlord' : landlordName,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(periodLabel,
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 11)),
              pw.Text('Generated $generatedOn',
                  style: const pw.TextStyle(
                      color: PdfColors.white, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _miniHeader(String periodLabel) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Smart Nyumba — Financial Report',
              style: pw.TextStyle(
                  fontSize: 9,
                  color: _accent,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(periodLabel,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx, String generatedOn) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by Smart Nyumba • $generatedOn',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(title,
        style: pw.TextStyle(
            fontSize: 13, fontWeight: pw.FontWeight.bold, color: _accent));
  }

  // -------------------------------------------------------------- summary
  static pw.Widget _summaryTable(double rent, double service, double revenue,
      double payout, int rentCount, int serviceCount) {
    pw.TableRow row(String label, String value, {bool bold = false}) {
      return pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          child: pw.Text(value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
      ]);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
      },
      children: [
        row('Rent collected ($rentCount payments)', _money.format(rent)),
        row('Service charges collected ($serviceCount payments)',
            _money.format(service)),
        row('Total revenue', _money.format(revenue), bold: true),
        row('Your net payout', _money.format(payout)),
      ],
    );
  }

  // ------------------------------------------------------------ occupancy
  static pw.Widget _occupancyTable(List<Map<String, dynamic>> occupancy,
      int totalUnits, int totalOccupied, int totalVacant, double rate) {
    pw.Widget cell(String t, {bool header = false, bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 10,
                color: header ? PdfColors.white : PdfColors.black,
                fontWeight: (header || bold)
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal)),
      );
    }

    pw.Widget cellR(String t, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: pw.Text(t,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2.5),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _accent),
          children: [
            cell('Property', header: true),
            cell('Location', header: true),
            cell('Units', header: true),
            cell('Occupied', header: true),
            cell('Vacant', header: true),
            cell('Rate', header: true),
          ],
        ),
        for (final o in occupancy)
          pw.TableRow(children: [
            cell('${o['block_number'] ?? '-'}'),
            cell('${o['location'] ?? '-'}'),
            cellR('${o['total_units'] ?? 0}'),
            cellR('${o['occupied_units'] ?? 0}'),
            cellR('${o['vacant_units'] ?? 0}'),
            cellR('${o['occupancy_rate'] ?? 0}%'),
          ]),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            cell('Portfolio total', bold: true),
            cell(''),
            cellR('$totalUnits', bold: true),
            cellR('$totalOccupied', bold: true),
            cellR('$totalVacant', bold: true),
            cellR('${rate.toStringAsFixed(1)}%', bold: true),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------- ledger
  static pw.Widget _monthHeading(String label, double total) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      color: PdfColors.grey200,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _accent)),
          pw.Text('Subtotal: ${_money.format(total)}',
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _ledgerTable(List<Map<String, dynamic>> rows) {
    pw.Widget cell(String t, {bool header = false, pw.TextAlign? align}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: pw.Text(t,
            textAlign: align ?? pw.TextAlign.left,
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight:
                    header ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.6),
        1: pw.FlexColumnWidth(1.4),
        2: pw.FlexColumnWidth(3),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.8),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            cell('Date', header: true),
            cell('Type', header: true),
            cell('Tenant', header: true),
            cell('Unit', header: true),
            cell('Method', header: true),
            cell('Amount', header: true, align: pw.TextAlign.right),
          ],
        ),
        for (final r in rows)
          pw.TableRow(children: [
            cell(_shortDate(r)),
            cell(r['type'] == 'rent' ? 'Rent' : 'Service'),
            cell('${r['tenant_email'] ?? '-'}'.split('@').first),
            cell('${r['house_number'] ?? '-'}'),
            cell('${r['payment_method'] ?? 'mpesa'}'.toUpperCase()),
            cell(_money.format(_amount(r)), align: pw.TextAlign.right),
          ]),
      ],
    );
  }

  static pw.Widget _grandTotalRow(double total) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _accent,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TOTAL COLLECTED',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(_money.format(total),
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- helpers
  static double _amount(Map r) =>
      double.tryParse(r['amount']?.toString() ?? '0') ?? 0.0;

  static String _dateStr(Map r) => (r['date_paid'] ?? r['date'] ?? '').toString();

  static String _shortDate(Map r) {
    final s = _dateStr(r);
    if (s.isEmpty) return '-';
    try {
      return DateFormat('dd MMM yy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  static List<_MonthGroup> _monthGroups(List<Map<String, dynamic>> txns) {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in txns) {
      DateTime? d;
      try {
        d = DateTime.parse(_dateStr(t));
      } catch (_) {}
      final key = d != null ? DateFormat('yyyy-MM').format(d) : 'unknown';
      map.putIfAbsent(key, () => []).add(t);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) {
      final rows = map[k]!;
      final total = rows.fold(0.0, (s, t) => s + _amount(t));
      final label = k == 'unknown'
          ? 'Undated'
          : DateFormat('MMMM yyyy').format(DateTime.parse('$k-01'));
      return _MonthGroup(label: label, rows: rows, total: total);
    }).toList();
  }
}

class _MonthGroup {
  final String label;
  final List<Map<String, dynamic>> rows;
  final double total;
  _MonthGroup({required this.label, required this.rows, required this.total});
}
