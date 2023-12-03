import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Models/invoice.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi with ChangeNotifier{
 var _file;
 String get filePath=>_file;
 void setFile(String file){
    _file = file;
    notifyListeners();
 }
  static Future pdfGeneration(Invoice invoice) {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return <pw.Widget>[receipt(invoice)];
        }));
    return PdfApi.saveDocument(
        name: "Service-charge-receipt-${DateTime.now()}", pdf: pdf);
  }

  static pw.Widget receipt(Invoice invoice) => pw.Column(
        children: [
          pw.Center(
            child: pw.Text(
              "${invoice.estateName}",
            ),
          ),
          pw.Text(
            "Date paid: ${invoice.datepaid}",
          ),
          pw.Row(
            children: [
              pw.Text("Name: ${invoice.name}"),
              pw.Text("Amount paid: ${invoice.amount}"),
            ],
          ),
          pw.Text(
            "Purpose: ${invoice.purpose}",
          ),
        ],
      );

  static Future<File> saveDocument({
    required String name,
    required Document pdf,

  }) async {
    final bytes = await pdf.save();


    Directory dir = await getApplicationDocumentsDirectory();
    debugPrint("${dir.path}");
    log("${dir.parent.parent.parent.parent.parent.parent.path}storage/self/primary/Download", name: "PATH");
    File file = File("${dir.path}/$name");



    await file.writeAsBytes(await pdf.save());



    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}