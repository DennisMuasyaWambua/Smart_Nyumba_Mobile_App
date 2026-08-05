import 'dart:io';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates and delivers a payment receipt PDF (rent or service charge).
///
/// Kept as a small static helper so it can be called from any screen. Depends
/// only on packages already in pubspec (`pdf`, `printing`, `path_provider`,
/// `open_file`).
class PdfApi {
  static const PdfColor _accent = PdfColor.fromInt(0xFF1A237E); // royalBlue

  /// Build a receipt document for a single payment.
  static pw.Document generateReceipt({
    required String tenantName,
    required String house,
    required String block,
    required String purpose, // "Rent" or "Service Charge"
    required String period, // e.g. "August 2026"
    required String amount, // numeric string, e.g. "1.00"
    required String datePaid, // formatted date string
    String reference = '',
  }) {
    final pdf = pw.Document();
    final amountLabel = 'KES ${_fmtAmount(amount)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header band
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: const pw.BoxDecoration(color: _accent),
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
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('Payment Receipt',
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 12)),
                    ],
                  ),
                  pw.Text('$purpose\n$period',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Meta rows
            _row('Received from', tenantName),
            _row('Property', '$house, Block $block'),
            _row('For', '$purpose — $period'),
            _row('Date paid', datePaid),
            if (reference.isNotEmpty) _row('Reference', reference),

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),

            // Line item table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1.4),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Description', bold: true),
                    _cell('Amount', bold: true, align: pw.TextAlign.right),
                  ],
                ),
                pw.TableRow(children: [
                  _cell('$purpose ($period)'),
                  _cell(amountLabel, align: pw.TextAlign.right),
                ]),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _cell('Total paid', bold: true),
                    _cell(amountLabel, bold: true, align: pw.TextAlign.right),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text('PAID',
                  style: pw.TextStyle(
                      color: PdfColors.green800,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12)),
            ),

            pw.Spacer(),
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated ${DateFormat.yMMMd().format(DateTime.now())} '
                  'at ${DateFormat.jm().format(DateTime.now())}',
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text('This is a system-generated receipt.',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  /// Open the system share sheet with the receipt attached.
  static Future<void> sharePdf(pw.Document doc, String filename) async {
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Save the receipt to the device and open it with the default viewer.
  static Future<String> saveAndOpen(pw.Document doc, String filename) async {
    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
    return file.path;
  }

  static String _fmtAmount(String amount) {
    final v = double.tryParse(amount);
    return v != null ? v.toStringAsFixed(2) : amount;
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(label,
                  style: pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );

  static pw.Widget _cell(String text,
          {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(text,
            textAlign: align,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
}
