import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/constants/colors.dart';

class DownloadPDFAlertDialog extends StatefulWidget {
  final pw.Document document;
  final DateTime date;

  const DownloadPDFAlertDialog({
    super.key,
    required this.date,
    required this.document,
  });

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
    pdfNameController.text =
        "Service Charge Receipt - ${DateFormat.yMMMd().format(widget.date)}";
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pdfNameController.dispose();
    super.dispose();
  }

  static Future<bool> _CheckPermissions(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    // final bytes = await pdf.save();
    // checking permissions and granting them if not granted
    if (await _CheckPermissions(Permission.storage) == true) {
      log("Permission Granted", name: "PERMISSION GRANTED");
    } else {
      log("Permission Denied", name: "PERMISSION DENIED");
    }
    var newName = name.replaceAll(" ", "_");
    Directory dir = await getApplicationDocumentsDirectory();
    debugPrint(dir.path);
    log(dir.parent.parent.parent.path, name: "APPS DOCUMENT DIRECTORY");
    log("${dir.parent.parent.parent.parent.parent.parent.path}storage/self/primary/Download",
        name: "PATH");
    var downloadsPath =
        "${dir.parent.parent.parent.parent.parent.parent.path}storage/self/primary/Download";
    File file = File("$downloadsPath/$newName.pdf");
    log(file.toString(), name: "FILE LOCATION");

    try {
      await file.writeAsBytes(await pdf.save());
      log("Documment was successfully saved",
          name: "DOCUMENT DOWNLOAD SUCCESS");
    } catch (e) {
      log("Error saving pdf: $e");
    }

    // checking if the file exists
    bool fileExists = await file.exists();
    if (fileExists) {
      log("The file exists", name: "FILE EXISTS");
      showDialog(
          context: context,
          builder: ((_) => AlertDialog(
                content: Container(width:300,height:100,child: Center(child: Text("success"))),
              )));
      Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop();
      });
      
    } else {
      log("the file does not exists", name: "NO SUCH FILE");
    }

    return file;
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
          Row(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => saveDocument(
                      name: pdfNameController.text, pdf: widget.document),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                    backgroundColor: lightGold,
                  ),
                  child: const Text(
                    "Device",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // SizedBox(width: 10.0,),
              // ElevatedButton(
              //   onPressed: () {},
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: lightGold,
              //   ),
              //   child: const Text(
              //     "Drive",
              //     style: TextStyle(
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
