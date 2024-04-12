import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/providers/payment_provider.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';
import 'package:smart_nyumba/utils/providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

class PayServiceChargeAlertDialog extends StatefulWidget {
  const PayServiceChargeAlertDialog({super.key});

  @override
  State<PayServiceChargeAlertDialog> createState() =>
      _PayServiceChargeAlertDialogState();
}

class _PayServiceChargeAlertDialogState
    extends State<PayServiceChargeAlertDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay Service Charge"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter your phone number:"),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: controller,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 6,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            ButtonLayout(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 0,
              ),
              borderRadius: 4,
              text: const Text(
                'Pay',
                style: TextStyle(color: Colors.white),
              ),
              onClick: () {
                
                  showDialog(
                      context: context,
                      builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                          ));
                  
                

                var token = SharedPrefrenceBuilder.getUserToken;

                log(token.toString(),
                    name: "TOKEN BEING SHARED WITH PROVIDER STATE MANAGER");
                var user = Provider.of<TenantsProfile>(context, listen: false)
                    .getUserProfile(token!);

                user.then((value) {
                  log(value.email.toString(), name: "THIS IS THE USERS EMAIL");
                  var mobile = value.user!.mobileNumber.toString();
                  if (controller.text.isNotEmpty) {
                    mobile = controller.text.toString();
                  }

                  String amt = value.propertyBlock!.serviceCharge.toString();
                  String serviceName = "Service charge";
                  var pay = Provider.of<Payments>(context, listen: false)
                      .payServiceCharge(mobile, amt, serviceName);

                  pay.then((value) {
                    log(value.toJson().toString(), name: "PAYMENT RESULT");
                  });
                });

                Timer.periodic(const Duration(seconds: 10), (timer) {
                  var check = Provider.of<Payments>(context, listen: false)
                      .checkPaymentStatus();
                  check.then((value) {
                    if (value == 0) {
                      log("$value payment was successful",
                          name: "PAYMENT SUCCESS");
                      timer.cancel();
                    } else {
                      timer.cancel();
                      log("$value payment failed", name: "PAYMENT FAILED");
                      timer.cancel();
                    }
                    log(value.toString(),
                        name: "FROM CHECKING THE PAYMENT RESULT");
                  });
                  timer.cancel();

                  timer.cancel();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
