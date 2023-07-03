import 'package:flutter/material.dart';
import 'package:smart_nyumba/Models/all_transactions.dart';

class AllTransactionsData extends StatefulWidget {
  const AllTransactionsData({super.key});

  @override
  State<AllTransactionsData> createState() => _AllTransactionsDataState();
}

class _AllTransactionsDataState extends State<AllTransactionsData> {
  List<Transaction> transaction = [];
  // Utilize stream builder to get the data from the all transactions state pro
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

  Widget buildDataTable() {
    final columns = ["Date paid", "Service", "Amount", "Payment Mode"];

    return DataTable(
      columns: getColumns(columns),
      rows: getRows(transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
