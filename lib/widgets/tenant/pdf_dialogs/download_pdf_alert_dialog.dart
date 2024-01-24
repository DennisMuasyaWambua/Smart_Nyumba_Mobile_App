import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DownloadPDFAlertDialog extends StatefulWidget {
  final DateTime date;
  const DownloadPDFAlertDialog({super.key, required this.date});

  @override
  State<DownloadPDFAlertDialog> createState() => _DownloadPDFAlertDialogState();
}

class _DownloadPDFAlertDialogState extends State<DownloadPDFAlertDialog> {
  late TextEditingController pdfNameController;

  @override
  void initState() {
    pdfNameController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    pdfNameController.text = "Service Charge Receipt - ${DateFormat.yMMMd().format(widget.date)}";
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pdfNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Download File"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("File Name"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: TextFormField(
              controller: pdfNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          const Text("Save to"),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                    backgroundColor: const Color(0xFFFFD700),
                  ),
                  child: const Text(
                    "Device",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                  ),
                  child: const Text(
                    "Google Drive",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
