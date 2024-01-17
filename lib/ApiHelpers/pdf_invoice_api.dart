import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi with ChangeNotifier{
 late String _file;
 late Uint8List logobytes;
 late PdfImage logoImage;
 String get filePath=>_file;
 void setFile(String file){
    _file = file;
    notifyListeners();
 }
 getLogo()async{
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

       log(e.toString(),name: "IMAGE FETCH ERROR");
     }

 }

  static Future pdfGeneration(String estateName, datePaid, name, amount, purpose)async{
    final pdf = pw.Document();


    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return <pw.Widget>[receipt(estateName, datePaid, name, amount, purpose)];
        }));
    return PdfApi.saveDocument(
        name: "Service-charge-receipt-${DateTime.now()}", pdf: pdf);
  }

  static pw.Widget receipt(String estateName, datePaid, name, amount, purpose) => pw.Column(

        children: [

          pw.Center(
            child: pw.Text(
              estateName,
            ),
          ),
          pw.SizedBox(height: 3 * PdfPageFormat.cm),
          pw.Text(
            "Date paid: $datePaid",
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            children: [
              pw.Text("Name: $name"),
              pw.SizedBox(width: 2 * PdfPageFormat.cm),
              pw.Text("Amount paid: $amount"),
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Text(
            "Purpose: $purpose",
          ),
        ],
      );

  static Future<File> saveDocument({
    required String name,
    required Document pdf,

  }) async {
    // final bytes = await pdf.save();


    Directory dir = await getApplicationDocumentsDirectory();
    debugPrint(dir.path);
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
