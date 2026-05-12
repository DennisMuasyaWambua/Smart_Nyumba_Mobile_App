import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/utils/constants/constants.dart';
import 'package:smart_nyumba/utils/providers/payment_provider.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';
import 'package:smart_nyumba/utils/providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

class PayRentAlertDialog extends StatefulWidget {
  const PayRentAlertDialog({super.key});

  @override
  State<PayRentAlertDialog> createState() => _PayRentAlertDialogState();
}

class _PayRentAlertDialogState extends State<PayRentAlertDialog> {
  late TextEditingController controller;
  String? rentAmount;
  double? commission;
  double? landlordAmount;

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

  void calculateCommission(String amount) {
    double rent = double.parse(amount);
    setState(() {
      rentAmount = amount;
      commission = rent * (Constants.COMMISSION_RATE / 100);
      landlordAmount = rent - commission!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay Rent"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your phone number:"),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller,
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
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
                hintText: "254XXXXXXXXX",
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: Provider.of<TenantsProfile>(context, listen: false)
                  .getUserProfile(SharedPrefrenceBuilder.getUserToken!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.propertyBlock?.rentCharged != null) {
                  String rent = snapshot.data!.propertyBlock!.rentCharged!;
                  calculateCommission(rent);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Rent to Pay:',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'KES $rent',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        const Text(
                          'Payment breakdown:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform Commission (${Constants.COMMISSION_RATE}%):',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'KES ${commission?.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Landlord receives:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'KES ${landlordAmount?.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
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
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your phone number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  ),
                );

                var token = SharedPrefrenceBuilder.getUserToken;

                log(token.toString(), name: "TOKEN FOR RENT PAYMENT");
                var user = Provider.of<TenantsProfile>(context, listen: false)
                    .getUserProfile(token!);

                user.then((value) {
                  log(value.email.toString(), name: "USER EMAIL FOR RENT PAYMENT");

                  String mobile = controller.text.toString();
                  String rent = value.propertyBlock!.rentCharged.toString();

                  var pay = Provider.of<Payments>(context, listen: false)
                      .payRent(mobile, rent, context);

                  pay.then((value) {
                    log(value.toJson().toString(), name: "RENT PAYMENT RESULT");

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value.message ?? 'Payment initiated'),
                        backgroundColor: value.status == true ? Colors.green : Colors.orange,
                      ),
                    );
                  }).catchError((error) {
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment failed: ${error.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                });

                Timer.periodic(const Duration(seconds: 10), (timer) {
                  var check = Provider.of<Payments>(context, listen: false)
                      .checkRentPaymentStatus();
                  check.then((value) {
                    if (value == 0) {
                      log("$value rent payment was successful", name: "RENT PAYMENT SUCCESS");
                      timer.cancel();

                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rent payment completed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      timer.cancel();
                      log("$value rent payment failed", name: "RENT PAYMENT FAILED");
                    }
                  }).catchError((error) {
                    timer.cancel();
                    log(error.toString(), name: "RENT PAYMENT CHECK ERROR");
                  });
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
