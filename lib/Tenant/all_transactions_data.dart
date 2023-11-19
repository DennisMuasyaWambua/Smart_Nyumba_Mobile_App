// import 'dart:developer';
import 'dart:developer';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/Models/all_transactions.dart';
import 'package:smart_nyumba/Providers/payment_provider.dart';
import 'package:smart_nyumba/Tenant/tenant_receipt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Constants/Constants.dart';

class AllTransactionsData extends StatefulWidget {
  const AllTransactionsData({super.key});

  @override
  State<AllTransactionsData> createState() => _AllTransactionsDataState();
}

class _AllTransactionsDataState extends State<AllTransactionsData> {
  int? sortColumnIndex;
  bool isAscending = false;
  final pdf = pw.Document();
  late File? file;

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {}
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  writePdf(){
    // pdf.addPage(
    //     pw.Page(
    //         pageFormat: PdfPageFormat.a4,
    //         build: (pw.Context context){
    //           return pw.Center(
    //               child: pw.Text("Hello ")
    //           );
    //         }
    //     )
    // );
    pdf.addPage(
      pw.MultiPage(
        pageFormat:PdfPageFormat.a4,
        margin:const pw.EdgeInsets.all(32),
        build:(pw.Context context){
          return <pw.Widget>[
            pw.Header(level: 0,child: pw.Text("Fiscal Receipt")),
            pw.Paragraph(text: "Payment of service charge"),
          ];
        }
      )
    );
  }
  Future savePdf()async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;

    File _file = File("$documentPath/sample.pdf");
    log(documentPath.toString(),name: "DOCUMENT PATH");

    _file.writeAsBytes(await pdf.save());

    setState(() {
      file = _file;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder(
          future: Provider.of<Payments>(context, listen: false)
              .getAllTransactions(),
          builder: (context, snapshot) {
           
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              );
            } else if (snapshot.hasData) {
              List<Transaction>? paymentTransactions = snapshot.data;
              return SingleChildScrollView(
                child: Column(

                  children: [
                   Padding(
                     padding: const EdgeInsets.only(top:50,left: 30.0),
                     child: Row(
                     children: [
                       GestureDetector(
                         onTap:(){

                         },
                         child: Icon(
                           Icons.arrow_back,
                           color: Colors.black,
                         ),
                       ),
                       SizedBox(width: MediaQuery.of(context).size.width*0.25,),
                       Text(
                         "Payments",
                         style: GoogleFonts.hind(
                             fontSize: 17,
                             color: Colors.black,
                             fontWeight: FontWeight.w700),
                       ),
                     ],
                     ),
                   ),

                    Padding(
                      padding: const EdgeInsets.only(top: 30.0,left:30.0),
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

                    SizedBox(height: MediaQuery.of(context).size.height*0.05),
                    // Balance card
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.70,
                        height: MediaQuery.of(context).size.height*0.20,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-0.97, 0.24),
                            end: Alignment(0.97, -0.24),
                            colors: [Color(0xFFFFD700),Color(0xFFD4AF37)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.10),
                            Text("KES: 0", style: GoogleFonts.hind(color: Colors.white,fontSize: 21,fontWeight: FontWeight.w600,height: 0.05,letterSpacing: -0.34),),
                            SizedBox(height: MediaQuery.of(context).size.height*0.07),
                            Text("Available Balance", style: GoogleFonts.hind(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600,height: 0.05,letterSpacing: -0.34),),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.10),

                    // DATA TABLE
                    Container(
                      width: MediaQuery.of(context).size.width*0.98,
                      height: MediaQuery.of(context).size.height*0.45,
                      decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                      child:Card(
                        elevation: 25,
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Transactions",style: GoogleFonts.inter(fontSize: 16
                                    ,fontWeight: FontWeight.w600,height: 0.06,letterSpacing: 0.35),),
                              ),
                            ),
                            Flexible(
                              child: DataTable2(
                                  columnSpacing: 0,
                                  horizontalMargin: 10,
                                  minWidth: 0,
                                  sortAscending: isAscending,
                                  sortColumnIndex: sortColumnIndex,
                                  columns:  [
                                    DataColumn2(label: Text("Date paid",style: GoogleFonts.inter(color: Color(0xFF77767E),fontSize: 12.0,fontWeight: FontWeight.w400,height: 0.11),)),
                                    DataColumn(label: Text("Amount", style:  GoogleFonts.inter(color: Color(0xFF77767E),fontSize: 12.0,fontWeight: FontWeight.w400,height: 0.11),)),
                                    DataColumn(label: Text("Payment mode", style:  GoogleFonts.inter(color: Color(0xFF77767E),fontSize: 12.0,fontWeight: FontWeight.w400,height: 0.11),)),
                                  ],

                                  rows: List<DataRow>.generate(
                                      paymentTransactions!.length,
                                          (index) => DataRow(cells: <DataCell>[
                                        DataCell(Text(
                                            "${paymentTransactions[index].datePaid}")),
                                        DataCell(Text(
                                            "KES ${paymentTransactions[index].amount}")),
                                        DataCell(Text(
                                            "${paymentTransactions[index].paymentMode}"))
                                      ],
                                            onSelectChanged: (bool? selected){
                                            if(selected != null && selected){
                                                writePdf();
                                                savePdf();
                                                // Navigator.push(context, new MaterialPageRoute(builder: (_)=>Receipt()));
                                              showDialog(context: context, builder: (_)=>AlertDialog(
                                                content: PdfView(path: file!.path,),
                                              ));
                                            }
                                          }))
                              ),
                            )
                          ],
                        ),

                      ),
                    ),



                  ],
                ),
              );
            } else {
              return const Center(
                  child: Text("User has no Transactions available"));
            }
          },
        ),
      ),
    );
  }
}
