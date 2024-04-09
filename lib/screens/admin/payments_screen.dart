import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late AllTransactions tenantProvider;

  @override
  void didChangeDependencies() {
    Provider.of<AllTransactions>(context, listen: false).fetchEstatePayments();
    tenantProvider = Provider.of<AllTransactions>(context, listen: false);
    tenantProvider.fetchEstatePayments();
    AllTransactions().getServiceChargePayments();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    log(tenantProvider.tenantData.toString(), name: "TENANT PROVIDER DATA");
    List<bool?> valuesToShow =
        ModalRoute.of(context)!.settings.arguments as List<bool?>;
    List<dynamic> allTenants = tenantProvider.tenantData;
    log(allTenants.toString(), name: "ALL TENANTS LIST");
    List<dynamic> pendingStatusTenants = tenantProvider.tenantData
        .where((element) => element['user']['is_active'] == 0)
        .toList();
    List<dynamic> activeStatusTenants = tenantProvider.tenantData
        .where((element) => element['user']['is_active'] == 1)
        .toList();

    List<dynamic> renderedList = [];

    switch (valuesToShow.first) {
      case false:
        renderedList = pendingStatusTenants;
        break;
      case true:
        renderedList = activeStatusTenants;
        break;
      default:
        renderedList = allTenants;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: renderedList
              .map((tenant) => Card(
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
                      title: Text(tenant['user']['first_name']),
                      subtitle: Column(
                        children: [
                          Text("Service charge paid: ${tenant['amount']}"),
                          Text("Mode of payment: ${tenant['payment_mode']}"),
                          Text("Date paid: ${tenant['date_paid']}"),
                        ],
                      ),
                      trailing: tenant['user']['is_active'] == 0
                          ? const StatusIndicator(color: statusAmber)
                          : const StatusIndicator(color: darkGreen),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
