import 'package:flutter/material.dart';

import 'marketplace_card.dart';
import 'pay_service_charge_card.dart';
import 'payment_statement_card.dart';
import 'request_for_repairs_card.dart';

// ignore: must_be_immutable
class TenantDashboardGrid extends StatelessWidget {
  int hasUserPaid;
  TenantDashboardGrid({super.key, required this.hasUserPaid});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            PayServiceChargeCard(hasUserPaid: hasUserPaid),
            const PaymentStatementCard(),
          ],
        ),
        const Row(
          children: [
            RequestForRepairsCard(),
            MarketplaceCard(),
          ],
        ),
      ],
    );
  }
}
