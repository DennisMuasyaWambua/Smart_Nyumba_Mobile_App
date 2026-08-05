import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../utils/constants/colors.dart';

/// Full-screen preview of a generated financial report PDF, with Download
/// (print/save) and Share actions. Reused for both current and historical
/// (filing) periods.
class ReportPreviewScreen extends StatelessWidget {
  final pw.Document document;
  final String filename;
  final String periodLabel;

  const ReportPreviewScreen({
    super.key,
    required this.document,
    required this.filename,
    required this.periodLabel,
  });

  Future<void> _share() async {
    try {
      final bytes = await document.save();
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      log(e.toString(), name: 'REPORT SHARE');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: royalBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Financial Report',
                style: GoogleFonts.hind(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            Text(periodLabel,
                style: GoogleFonts.hind(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _share,
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => document.save(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: filename,
        // The built-in bar already offers print/download-to-file and share.
        actionBarTheme: const PdfActionBarTheme(
          backgroundColor: royalBlue,
          iconColor: Colors.white,
        ),
      ),
    );
  }
}
