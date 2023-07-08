import 'dart:developer';

import 'package:flutter/material.dart';
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
  List<Transaction> transaction = [];
  // Utilize stream builder to get the data from the all transactions state pro
  Future<Object> getAllTransactions() async {
    Future<List<Transaction>?> history =
        Provider.of<Payments>(context, listen: false).getAllTransactions();

    List transactionList = [];
    // history.then((value) {
    //   log(value.toString(), name: "VALUE FROM TRANSACTION PROMISE");
    //   for (int i = 0; i < value!.length; i++) {
    //         transactionList=value[i] as List<Transaction>;
    //   }
    // });

    // transactionList.add(history);
    log(transactionList.toString(), name: "ALL TRANSACTION DATA");

    return transactionList;
  }

  List<DataColumn> getColumns(List<String> columns) =>
      columns.map((String column) => DataColumn(label: Text(column))).toList();
  List<DataRow> getRows(List<Transaction> transaction) => transaction
      .map((Transaction transaction) => DataRow(cells: [
            DataCell(Text("${transaction.datePaid}")),
            DataCell(Text("${transaction.serviceName}")),
            DataCell(Text("${transaction.amount}")),
            DataCell(Text("${transaction.paymentMode}")),
          ]))
      .toList();

  Widget buildDataTable(var rows) {
    final columns = ["Date paid", "Service", "Amount", "Payment Mode"];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(rows),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTransactions();
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
                child: CircularProgressIndicator(color: Constants.buttonColor),
              );
            } else if (snapshot.hasData) {
              List<Transaction>? paymentTransactions = snapshot.data;
            return  SingleChildScrollView(
              child: Column(
                  children: [
                         DataTable(columns: [
                          DataColumn(label: Text("Date paid")),
                          DataColumn(label: Text("Service")),
                          DataColumn(label: Text("Amount")),
                          DataColumn(label: Text("Payment mode")),
                         ], rows:List<DataRow>.generate(paymentTransactions!.length, (index) => DataRow(
                          cells: <DataCell>[DataCell(Text("${paymentTransactions[index].datePaid}")),DataCell(Text("${paymentTransactions[index].serviceName}")),DataCell(Text("${paymentTransactions[index].amount}")),DataCell(Text("${paymentTransactions[index].paymentMode}"))]
                         )) )
                        
                            
                         
                  ],
                ),
            );
             
             
              
            } else {
              return Center(
                  child: const Text("User has no Transactions available"));
            }
          },
        ),
      ),
    );
  }
}
