import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/models/all_payments.dart';
import 'package:smart_nyumba/utils/providers/all_transactions.dart';

import '../../utils/constants/colors.dart';
import '../../widgets/status_indicator.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = "/payments";
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // var tenantProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // tenantProvider = AllTransactions().fetchEstatePayments();
    // log(tenantProvider.toString(), name: 'INIT PAYMENT METHOD');
  }

  @override
  void didChangeDependencies() {
    // Provider.of<AllTransactions>(context, listen: false).fetchEstatePayments();
    // tenantProvider = Provider.of<AllTransactions>(context, listen: false);
    // tenantProvider.fetchEstatePayments();
    // AllTransactions().getServiceChargePayments();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // log(tenantProvider.tenantData.toString(), name: "TENANT PROVIDER DATA");
    // List<bool?> valuesToShow =
    //     ModalRoute.of(context)!.settings.arguments as List<bool?>;
    // List<dynamic> allTenants = tenantProvider.tenantData;
    // log(allTenants.toString(), name: "ALL TENANTS LIST");
    // List<dynamic> pendingStatusTenants = tenantProvider.tenantData
    //     .where((element) => element['user']['is_active'] == 0)
    //     .toList();
    // List<dynamic> activeStatusTenants = tenantProvider.tenantData
    //     .where((element) => element['user']['is_active'] == 1)
    //     .toList();

    // List<dynamic> renderedList = [];

    // switch (valuesToShow.first) {
    //   case false:
    //     renderedList = pendingStatusTenants;
    //     break;
    //   case true:
    //     renderedList = activeStatusTenants;
    //     break;
    //   default:
    //     renderedList = allTenants;
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
      ),
      body: FutureBuilder(
          future: Provider.of<AllTransactions>(context, listen: false)
              .getServiceChargePayments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              );
            } else {
              log(snapshot.data.toString(), name: 'SNAPSHOT DATA');
              List<Transaction>? paymentTransactions = snapshot.data;

              return SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width ,
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: ListView.builder(
                                    itemCount: paymentTransactions!.length,
                                    itemBuilder: (context, index) {
                    final transaction =  paymentTransactions[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightGold.withOpacity(0.5),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: lightGrey,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(transaction.user.username, style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                            const SizedBox(
                              width: 10.0,
                            ),
                            // Text("Block No: ${tenant['user']['block']['block_number'].toString()}")
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            Text("Service charge paid: ${transaction.amount}"),
                            Text("Mode of payment: ${transaction.paymentMode}"),
                            Text("Date paid: ${DateFormat.yMMMd().format(transaction.datePaid)}"),
                          ],
                        ),
                        trailing: transaction.user.status == 0
                            ? const StatusIndicator(color: statusAmber)
                            : const StatusIndicator(color: darkGreen),
                      ),
                    );
                                    },
                                  ),
                  ));
            }
          }),
    );
  }
}
