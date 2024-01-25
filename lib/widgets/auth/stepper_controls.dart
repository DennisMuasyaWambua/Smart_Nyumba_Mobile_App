import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_nyumba/screens/authentication/login.dart';
import 'package:smart_nyumba/screens/authentication/otp.dart';

import '../../utils/providers/auth_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';

class StepperControls extends StatelessWidget {
  final int currentStep;
  final ControlsDetails details;
  final String email;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String blockNumber;
  final String houseNumber;
  final String mobileNumber;
  final String password;

  const StepperControls({
    super.key,
    required this.currentStep,
    required this.details,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.blockNumber,
    required this.houseNumber,
    required this.mobileNumber,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: currentStep == 0 ? 24 : 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: currentStep != 2
                      ? details.onStepContinue
                      : () {
                          String usermail = email.toString();
                          log(usermail.toString(), name: "mail from input");

                          SharedPrefrenceBuilder.setUserEmail(email);

                          var storedMail = SharedPrefrenceBuilder.getUserEmail;

                          log(storedMail.toString(), name: "Stored Mail");

                          final register = Auth().register(email, firstName, lastName, idNumber,
                              blockNumber, houseNumber, mobileNumber, password, context);

                          register.then((value) {
                            log(
                              value.message.toString(),
                              name: " register response message",
                            );
                            if (value.status = true) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(value.message),
                                    );
                                  });
                              Navigator.of(context).pushReplacementNamed(Otp.routeName);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    Future.delayed(const Duration(seconds: 3), () {
                                      Navigator.of(context).pop();
                                    });
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: Text(value.message),
                                    );
                                  });
                            }
                          });
                        },
                  child: Text(currentStep != 2 ? "CONTINUE" : "SIGN UP"),
                ),
              ),
              currentStep > 0
                  ? TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text("BACK"),
                    )
                  : const SizedBox(),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Login.routeName);
            },
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
