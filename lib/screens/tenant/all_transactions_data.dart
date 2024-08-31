import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import '../../utils/api_helpers/pdf_invoice_api.dart';
import '../../utils/constants/colors.dart';
import '../../utils/models/all_transactions.dart';
import '../../utils/models/invoice.dart';
import '../../utils/providers/_providers.dart';
import '../../widgets/tenant/pdf_dialogs/preview_pdf_alert_dialog.dart';

class AllTransactionsData extends StatefulWidget {
  static const routeName = "/all-tx-data";
  const AllTransactionsData({super.key});

  @override
  State<AllTransactionsData> createState() => _AllTransactionsDataState();
}

class _AllTransactionsDataState extends State<AllTransactionsData> {
  int? sortColumnIndex;
  bool isAscending = false;
  String name = '';
  double? balance;
  late Invoice receipt;
  final pdf = pw.Document();
  // late File file;

  @override
  void initState() {
    super.initState();
    final account =
        Auth().getProfile(SharedPrefrenceBuilder.getUserToken!, context);
    account.then((value) {
      setState(() {
        name = value.profile!.user!.firstName!;
      });
      log(name.toString(), name: "USERS NAME");
    });
  }

  @override
  void didChangeDependencies() {
    final DateTime tokenExpirationDate =
        DateTime.parse(SharedPrefrenceBuilder.getExpirationTime!);
    final bool isTokenValid = tokenExpirationDate.isAfter(DateTime.now());
    if (!isTokenValid) {
      SharedPrefrenceBuilder.clearInvalidToken();
      Navigator.pushNamed(context, '/login');
    }

    super.didChangeDependencies();
  }

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {}
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  writePdf() {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Header(level: 0, text: "Fiscal Receipt"),
                  pw.Row(
                    children: [
                      pw.Text("Date"),
                      pw.SizedBox(width: 200),
                      pw.Text("Akilla 2 estate"),
                    ],
                  ),
                ],
              ),
            )
          ];
        },
      ),
    );
  }

  previewPDF(pw.Document pdfDoc, DateTime datePaid) {
    showDialog(
        context: context,
        builder: (_) =>
            PreviewPDFAlertDialog(document: pdfDoc, datePaid: datePaid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Statements"),
      ),
      body: StreamBuilder(
        stream:
            Provider.of<Payments>(context, listen: false).getAllTransactions(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            );
          } else if (snapshot.hasData) {
            List<Transaction>? paymentTransactions = snapshot.data;
            if (paymentTransactions!.isNotEmpty) {
              balance = double.parse(
                      paymentTransactions[0].annualServiceCharge.toString()) -
                  paymentTransactions.length*double.parse(paymentTransactions[0].amount.toString());

              log(balance.toString(), name: "BALANCE");
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Service Charge',
                          style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    // Balance card
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(-0.97, 0.24),
                            end: Alignment(0.97, -0.24),
                            colors: gradYellowGold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.10),
                            Text(
                              "KES: $balance",
                              style: GoogleFonts.hind(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                  height: 0.05,
                                  letterSpacing: -0.34),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.07),
                            Text(
                              "Available Balance",
                              style: GoogleFonts.hind(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 0.05,
                                  letterSpacing: -0.34),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Transactions",
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 0.06,
                              letterSpacing: 0.35),
                        ),
                      ),
                    ),
                    // DATA TABLE
                    Container(
                      width: MediaQuery.of(context).size.width * 0.98,
                      height: MediaQuery.of(context).size.height * 0.45,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: paymentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = paymentTransactions[index];
                          final date =
                              DateFormat.yMMMd().format(transaction.datePaid);

                          return Card(
                            child: ListTile(
                              title: Text("Ksh ${transaction.amount}"),
                              subtitle: Text("${transaction.paymentMode}"),
                              trailing: Text(date),
                              onTap: () {
                                final String date = DateFormat.yMMMd()
                                    .format(transaction.datePaid);

                                // receipt = Invoice(
                                //     name: name,
                                //     estateName: 'Akilla 2',
                                //     amount: transaction.amount.toString(),
                                //     datepaid: transaction.datePaid.toString(),
                                //     purpose: "Service Charge");

                                // log(receipt.name.toString(), name: "RECEIPT OBJECT");

                                final pdfFile = PdfApi.pdfGeneration(
                                    'Akilla 2',
                                    date,
                                    name,
                                    paymentTransactions[index]
                                        .amount
                                        .toString(),
                                    "Service Charge");
                                log(pdfFile.toString(), name: "PDF FILE PATH");
                                previewPDF(pdfFile, transaction.datePaid);
                                // save file object using provider
                                // PdfApi().setIndex(pdfFile);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text("You have made no payments"),
              );
            }
          } else {
            return const Center(
              child: Text("User has no transactions available"),
            );
          }
        },
      ),
        
      );
   
  }
}