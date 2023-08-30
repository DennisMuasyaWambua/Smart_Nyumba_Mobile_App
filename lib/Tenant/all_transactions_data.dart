// import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Models/all_transactions.dart';
import 'package:smart_nyumba/Providers/payment_provider.dart';

class AllTransactionsData extends StatefulWidget {
  const AllTransactionsData({super.key});

  @override
  State<AllTransactionsData> createState() => _AllTransactionsDataState();
}

class _AllTransactionsDataState extends State<AllTransactionsData> {
  int? sortColumnIndex;
  bool isAscending = false;

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) { 
        
    }
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/smartnyumba.png",
                width: 70,
                height: 40,
                fit: BoxFit.cover,
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    Constants.serviceChargePayments ,
                    style: GoogleFonts.urbanist(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  )),
            ],
          )),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: Provider.of<Payments>(context, listen: false)
              .getAllTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Constants.buttonColor),
              );
            } else if (snapshot.hasData) {
              List<Transaction>? paymentTransactions = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                          sortAscending: isAscending,
                          sortColumnIndex: sortColumnIndex,
                          columns: const [
                            DataColumn(label: Text("Date paid")),
                            DataColumn(label: Text("Service")),
                            DataColumn(label: Text("Amount")),
                            DataColumn(label: Text("Payment mode")),
                          ],
                          rows: List<DataRow>.generate(
                              paymentTransactions!.length,
                              (index) => DataRow(cells: <DataCell>[
                                    DataCell(Text(
                                        "${paymentTransactions[index].datePaid}")),
                                    DataCell(Text(
                                        "${paymentTransactions[index].serviceName}")),
                                    DataCell(Text(
                                        "${paymentTransactions[index].amount}")),
                                    DataCell(Text(
                                        "${paymentTransactions[index].paymentMode}"))
                                  ]))),
                    )
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
