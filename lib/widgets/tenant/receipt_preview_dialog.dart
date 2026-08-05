import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../utils/api_helpers/pdf_invoice_api.dart';
import '../../utils/api_helpers/r2_receipts.dart';
import '../../utils/constants/colors.dart';

/// Full-screen, in-app receipt preview. Renders the generated PDF with
/// `PdfPreview`, offers Download + Share, and quietly backs the receipt up to
/// Cloudflare R2 (via backend-issued presigned URLs) the first time it opens.
class ReceiptPreviewScreen extends StatefulWidget {
  final pw.Document document;
  final String filename;
  final String title; // e.g. "Rent receipt"
  final String subtitle; // e.g. "August 2026 · KES 1.00"
  final String type; // 'rent' | 'service'
  final int month;
  final int year;

  const ReceiptPreviewScreen({
    super.key,
    required this.document,
    required this.filename,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.month,
    required this.year,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _backupToCloud();
  }

  /// Fire-and-forget upload of the receipt to R2. Failures are non-fatal — the
  /// tenant can still download/share locally.
  Future<void> _backupToCloud() async {
    try {
      final bytes = await widget.document.save();
      final key = await R2Receipts.upload(
        pdfBytes: bytes,
        type: widget.type,
        month: widget.month,
        year: widget.year,
      );
      if (key != null) log('receipt backed up: $key', name: 'RECEIPT');
    } catch (e) {
      log('cloud backup skipped: $e', name: 'RECEIPT');
    }
  }

  Future<void> _run(Future<void> Function() action, String? okMsg) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (okMsg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(okMsg), backgroundColor: darkGreen),
        );
      }
    } catch (e) {
      log(e.toString(), name: 'RECEIPT');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not complete that. Please try again.'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: royalBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: GoogleFonts.hind(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            Text(widget.subtitle,
                style: GoogleFonts.hind(
                    fontSize: 11.5, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfPreview(
              useActions: false,
              canDebug: false,
              build: (format) => widget.document.save(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(
                              () => PdfApi.sharePdf(
                                  widget.document, widget.filename),
                              null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: royalBlue,
                        side: const BorderSide(color: royalBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: Text('Share',
                          style: GoogleFonts.hind(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(
                              () => PdfApi.saveAndOpen(
                                  widget.document, widget.filename),
                              'Receipt saved to your device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _busy
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text('Download',
                          style: GoogleFonts.hind(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
