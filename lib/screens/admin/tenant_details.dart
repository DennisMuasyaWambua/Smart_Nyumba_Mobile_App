import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class TenantDetails extends StatelessWidget {
  static const route = "/tenant-details";

  const TenantDetails({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> tenantDetails =
        ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenant Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightGold.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: lightGrey,
                  size: 102,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tenantDetails.first['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Chip(
                label: Text(
                  "Status: ${tenantDetails.first['is_active'] == 0 ? "Pending" : "Active"}",
                  style: TextStyle(
                    color: tenantDetails.first['is_active'] == 0 ? Colors.black : Colors.white,
                  ),
                ),
                backgroundColor:
                    tenantDetails.first['is_active'] == 0 ? statusAmber : darkGreen,
              ),
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Property Block No",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(tenantDetails.first['PropertyBlock']['block']['block_number'].toString()),
                          const SizedBox(height: 16),
                          const Text(
                            "House number",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(tenantDetails.first['PropertyBlock']['house_number'].toString()),
                          const SizedBox(height: 16),
                          const Text(
                            "ID Number",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(tenantDetails.first['id_number']),
                          const SizedBox(height: 16),
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(tenantDetails.first['email']),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
