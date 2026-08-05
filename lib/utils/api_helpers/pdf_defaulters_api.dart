import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a printable/shareable defaulters report for rent collectors:
/// summary + per-property tables of tenants in arrears (rent, service, penalty,
/// total due).
class PdfDefaultersApi {
  static const PdfColor _accent = PdfColor.fromInt(0xFF22215B);
  static const PdfColor _danger = PdfColor.fromInt(0xFFC62828);

  static String _money(num v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return 'KSh $buf';
  }

  static pw.Document generate({
    required String landlordName,
    required String generatedOn,
    required int totalDefaulters,
    required num totalArrears,
    required num totalPenalty,
    required num totalDue,
    required List<Map<String, dynamic>> properties,
  }) {
    final pdf = pw.Document();
    final withDefaulters =
        properties.where((p) => (p['defaulter_count'] ?? 0) > 0).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Smart Nyumba • Defaulters Report • $generatedOn',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
        build: (ctx) => [
          _header(landlordName, generatedOn),
          pw.SizedBox(height: 16),
          _summary(totalDefaulters, totalArrears, totalPenalty, totalDue),
          pw.SizedBox(height: 18),
          if (withDefaulters.isEmpty)
            pw.Text('No defaulters — all tenants are up to date.',
                style: const pw.TextStyle(color: PdfColors.grey600)),
          for (final p in withDefaulters) ...[
            pw.SizedBox(height: 10),
            _propertyHeading(p),
            pw.SizedBox(height: 4),
            _table((p['defaulters'] as List? ?? [])
                .map((d) => Map<String, dynamic>.from(d as Map))
                .toList()),
          ],
          pw.SizedBox(height: 18),
          _grandTotal(totalDue),
        ],
      ),
    );
    return pdf;
  }

  static pw.Widget _header(String landlordName, String generatedOn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
          color: _accent, borderRadius: pw.BorderRadius.circular(10)),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Smart Nyumba',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text('Defaulters Report',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text(landlordName.isEmpty ? 'Landlord' : landlordName,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text('Generated $generatedOn',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
          ]),
        ],
      ),
    );
  }

  static pw.Widget _summary(
      int defaulters, num arrears, num penalty, num due) {
    pw.Widget box(String label, String value, {PdfColor? color}) {
      return pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 3),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: color ?? PdfColors.black)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ]),
        ),
      );
    }

    return pw.Row(children: [
      box('Defaulters', '$defaulters'),
      box('Arrears', _money(arrears)),
      box('Penalty', _money(penalty)),
      box('Total due', _money(due), color: _danger),
    ]);
  }

  static pw.Widget _propertyHeading(Map<String, dynamic> p) {
    final rate = (p['penalty_rate'] ?? 0);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      color: PdfColors.grey200,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              '${p['block_number'] ?? '-'}  •  ${p['defaulter_count'] ?? 0} owing'
              '${rate != 0 ? '  •  penalty $rate%' : ''}',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _accent)),
          pw.Text('Due: ${_money((p['total_due'] ?? 0) as num)}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _table(List<Map<String, dynamic>> rows) {
    pw.Widget cell(String t, {bool header = false, pw.TextAlign? align}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: pw.Text(t,
            textAlign: align ?? pw.TextAlign.left,
            maxLines: 1,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight:
                    header ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.6),
        1: pw.FlexColumnWidth(1.1),
        2: pw.FlexColumnWidth(1.6),
        3: pw.FlexColumnWidth(1.6),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.7),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            cell('Tenant', header: true),
            cell('Unit', header: true),
            cell('Rent', header: true, align: pw.TextAlign.right),
            cell('Service', header: true, align: pw.TextAlign.right),
            cell('Penalty', header: true, align: pw.TextAlign.right),
            cell('Total due', header: true, align: pw.TextAlign.right),
          ],
        ),
        for (final r in rows)
          pw.TableRow(children: [
            cell('${r['tenant_name'] ?? r['tenant_email'] ?? '-'}'),
            cell('${r['house_number'] ?? '-'}'),
            cell(_money((r['rent_arrears'] ?? 0) as num),
                align: pw.TextAlign.right),
            cell(_money((r['service_arrears'] ?? 0) as num),
                align: pw.TextAlign.right),
            cell(_money((r['penalty_amount'] ?? 0) as num),
                align: pw.TextAlign.right),
            cell(_money((r['total_due'] ?? 0) as num),
                align: pw.TextAlign.right),
          ]),
      ],
    );
  }

  static pw.Widget _grandTotal(num due) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
          color: _danger, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TOTAL DUE',
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(_money(due),
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
