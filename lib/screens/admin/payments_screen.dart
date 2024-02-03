import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/_providers.dart';
import '../../widgets/status_indicator.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = "/payments";
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late AdminController tenantProvider;

  @override
  void didChangeDependencies() {
    tenantProvider = Provider.of<AdminController>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<bool?> valuesToShow = ModalRoute.of(context)!.settings.arguments as List<bool?>;
    List<dynamic> allTenants = tenantProvider.tenantData;
    List<dynamic> pendingStatusTenants =
        tenantProvider.tenantData.where((element) => element['is_active'] == 0).toList();
    List<dynamic> activeStatusTenants =
        tenantProvider.tenantData.where((element) => element['is_active'] == 1).toList();

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
                      title: Text(tenant['name']),
                      subtitle: Text("Property Block No: ${tenant['PropertyBlock'].toString()}"),
                      trailing: tenant['is_active'] == 0
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
