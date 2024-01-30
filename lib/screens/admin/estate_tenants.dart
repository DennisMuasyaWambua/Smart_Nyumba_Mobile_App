import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/providers/_providers.dart';
import '../../widgets/admin/tenant_card_tile.dart';

class EstateTenants extends StatefulWidget {
  static const routeName = "/estate-tenants";
  const EstateTenants({super.key});

  @override
  State<EstateTenants> createState() => _EstateTenantsState();
}

class _EstateTenantsState extends State<EstateTenants> {
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
        title: const Text("Tenants"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Column(
                children: renderedList.map((tenant) => TenantCardTile(tenant: tenant)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
