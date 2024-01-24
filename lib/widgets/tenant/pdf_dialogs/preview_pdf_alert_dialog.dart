import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:smart_nyumba/widgets/tenant/pdf_dialogs/download_pdf_alert_dialog.dart';

class PreviewPDFAlertDialog extends StatelessWidget {
  final File file;
  final DateTime datePaid;
  const PreviewPDFAlertDialog({super.key, required this.file, required this.datePaid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 370,
        width: 700,
        child: Theme(
          data: ThemeData(
            primaryColor: const Color(0xFFFFD700),
          ),
          child: PdfPreview(
            useActions: false,
            canDebug: false,
            actions: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DownloadPDFAlertDialog(date: datePaid),
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
            build: (format) => file.readAsBytesSync(),
          ),
        ),
      ),
    );
  }
}
