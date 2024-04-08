import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../utils/constants/colors.dart';
import 'download_pdf_alert_dialog.dart';

class PreviewPDFAlertDialog extends StatelessWidget {
  final pw.Document document;
  final DateTime datePaid;
  const PreviewPDFAlertDialog({super.key, required this.document, required this.datePaid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 370,
        width: 700,
        child: Theme(
          data: ThemeData(
            primaryColor: lightGold,
          ),
          child: PdfPreview(
            useActions: false,
            canDebug: false,
            actions: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DownloadPDFAlertDialog(date: datePaid, document: document),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                ),
                child: const Text(
                  "Download Receipt",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            build: (format) => document.save(),
          ),
        ),
      ),
    );
  }
}
