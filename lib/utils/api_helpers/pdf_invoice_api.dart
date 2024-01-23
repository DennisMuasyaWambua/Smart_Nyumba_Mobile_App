import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfApi with ChangeNotifier {
  late String _file;
  late Uint8List logobytes;
  late PdfImage logoImage;
  String get filePath => _file;
  void setFile(String file) {
    _file = file;
    notifyListeners();
  }

  getLogo() async {
    final pdf = pw.Document();
    ByteData bytes = await rootBundle.load('assets/avatar.png');
    logobytes = bytes.buffer.asUint8List();

    try {
      logoImage = PdfImage.file(
        pdf.document,
        bytes: logobytes,
      );
    } catch (e) {
      debugPrint("catch--  $e");

      log(e.toString(), name: "IMAGE FETCH ERROR");
    }
  }

  static Future<File> pdfGeneration(String estateName, datePaid, name, amount, purpose) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return <pw.Widget>[receipt(estateName, datePaid, name, amount, purpose)];
        },
      ),
    );
    return PdfApi.saveDocument(name: "Service-charge-receipt-${DateTime.now()}", pdf: pdf);
  }

  static pw.Widget receipt(String estateName, datePaid, name, amount, purpose) => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  estateName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      'P.O Box 1234-00100 . Nairobi . Kenya',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    // pw.Text('P.O Box 1234-0010'),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  "Service Charge Receipt",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    decorationThickness: 2,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    "Name: ",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 16),
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(width: 2),
                      ),
                    ),
                    child: pw.Text(
                      name,
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    "Date: ",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(width: 2),
                      ),
                    ),
                    child: pw.Text(
                      datePaid,
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                      child: pw.Text(
                        "No",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                    child: pw.Text(
                      "Item",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                      child: pw.Text(
                        "Item Count",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                      child: pw.Text(
                        "Total",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Center(
                    child: pw.Text(
                      "1",
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                    child: pw.Text(
                      "Service Charge",
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      "1",
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                    child: pw.Text(
                      "1.00",
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Compiled on: ${DateFormat.yMMMd().format(DateTime.now())} at ${DateFormat.jm().format(DateTime.now())}"),
              pw.Text("Prepared by: Smart Nyumba"),
            ],
          )
        ],
      );

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    // final bytes = await pdf.save();

    Directory dir = await getApplicationDocumentsDirectory();
    debugPrint(dir.path);
    log("${dir.parent.parent.parent.parent.parent.parent.path}storage/self/primary/Download",
        name: "PATH");
    File file = File("${dir.path}/$name");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
