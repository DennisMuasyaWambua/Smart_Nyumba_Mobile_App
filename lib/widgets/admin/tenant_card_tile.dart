import 'package:flutter/material.dart';

import '../../screens/admin/_admin.dart';
import '../../utils/constants/colors.dart';
import '../status_indicator.dart';

class TenantCardTile extends StatelessWidget {
  final Map<String, dynamic> tenant;
  const TenantCardTile({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          TenantDetails.route,
          arguments: [tenant],
        ),
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
        subtitle: Column(
          children: [
            Text("Block No: ${tenant['PropertyBlock']['block']['block_number'].toString()}"),
             Text("House Number: ${tenant['PropertyBlock']['house_number'].toString()}")
          ],
        ),
        trailing: tenant['is_active'] == 0
            ? const StatusIndicator(color: statusAmber)
            : const StatusIndicator(color: darkGreen),
      ),
    );
  }
}
