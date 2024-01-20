import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../utils/providers/payment_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../utils/providers/tenants_profile_provider.dart';
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
            GestureDetector(
                onTap: () {
                  var token = SharedPrefrenceBuilder.getUserToken;

                  log(token.toString(), name: "TOKEN BEING SHARED WITH PROVIDER STATE MANAGER");
                  var user =
                      Provider.of<TenantsProfile>(context, listen: false).getUserProfile(token!);

                  user.then((value) {
                    log(value.email.toString(), name: "THIS IS THE USERS EMAIL");
                    var mobile = value.user!.mobileNumber.toString();

                    String amt = '1';
                    String serviceName = "Waste";
                    var pay = Provider.of<Payments>(context, listen: false)
                        .payServiceCharge(mobile, amt, serviceName);

                    pay.then((value) {
                      log(value.toJson().toString(), name: "PAYMENT RESULT");
                    });
                  });

                  Timer.periodic(const Duration(seconds: 3), (timer) {
                    if (hasUserPaid == 0) {
                      var check =
                          Provider.of<Payments>(context, listen: false).checkPaymentStatus();
                      check.then((value) {
                        if (value == 1) {
                          hasUserPaid = value!;
                          log("$value payment was successful", name: "PAYMENT SUCCESS");
                          timer.cancel();
                        } else {
                          log("$value payment failed", name: "PAYMENT FAILED");
                          timer.cancel();
                        }
                        log(value.toString(), name: "FROM CHECKING THE PAYMENT RESULT");
                      });
                      timer.cancel();
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                      );
                      timer.cancel();
                    }
                    timer.cancel();
                  });
                },
                child: const PayServiceChargeCard()),
            GestureDetector(
                onTap: () {
                  // payment status
                  // var history = Provider.of<Payments>(context, listen: false)
                  //     .getAllTransactions();
                  //
                  // history.then((value) {
                  //
                  //   for (int i = 0; i < value!.length; i++) {
                  //        log(value[i].toJson().toString(),
                  //       name: "HISTORIC TRANSACTIONS");
                  //       // get information from here on all transactions and form the system
                  //   }
                  // });
                  Navigator.pushNamed(context, '/allServiceChargeTransactions');
                },
                child: const PaymentStatementCard())
          ],
        ),
        Row(
          children: [
            GestureDetector(onTap: () {}, child: const RequestForRepairsCard()),
            const MarketplaceCard(),
          ],
        ),
      ],
    );
  }
}
