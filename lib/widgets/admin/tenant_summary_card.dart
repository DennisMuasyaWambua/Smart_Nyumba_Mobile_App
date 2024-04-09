import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/models/all_tenants.dart';

import '../../screens/admin/_admin.dart';
import '../../utils/constants/colors.dart';
import '../../utils/providers/admin_provider.dart';
import '../status_indicator.dart';

class TenantSummaryCard extends StatefulWidget {
  const TenantSummaryCard({super.key});

  @override
  State<TenantSummaryCard> createState() => _TenantSummaryCardState();
}

class _TenantSummaryCardState extends State<TenantSummaryCard> {
  List occupants = [];
  Tenant? occupant;
  int active = 0;
  int inactive = 0;
  getTenants() {
    var tenant = AdminController().getTenants();

    tenant.then((value) {
      setState(() {
        occupants = value;
      });

  

      log(active.toString(), name: "ACTIVE");
      log(inactive.toString(), name: "INACTIVE");
      log(value.length.toString(), name: "TENANTS LENGTH");
      log(value[0].toJson().toString(), name: "TENANTS Content");
    });
  }

  @override
  void initState() {
    super.initState();
    getTenants();
  }

  @override
  Widget build(BuildContext context) {
    AdminController tenantProvider =
        Provider.of<AdminController>(context, listen: false);
    tenantProvider.fetchTenants();

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(EstateTenants.routeName, arguments: [null]),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tenants",
                    style: GoogleFonts.hind(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 150,
                child: tenantProvider.tenantData.isNotEmpty ||
                        occupants.isNotEmpty
                    ? Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  occupants.length.toString(),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 10),
                                const Text("Total"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                    EstateTenants.routeName,
                                    arguments: [false],
                                  ),
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.transparent;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Text(
                                          tenantProvider.tenantData
                                              .where((element) =>
                                                  element['is_active'] == 0)
                                              .length
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Pending",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            StatusIndicator(color: statusAmber),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                    EstateTenants.routeName,
                                    arguments: [true],
                                  ),
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors.transparent;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Text(
                                          tenantProvider.tenantData
                                              .where((element) =>
                                                  element['is_active'] == 1)
                                              .length
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Active",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            StatusIndicator(color: darkGreen),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No Data",
                          style: TextStyle(
                            color: lightGrey,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
