// import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    if (columnIndex == 0) {}
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
                    Container(
                      
                      child: Padding(
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
                      ),
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
