import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/authentication/login.dart';
import '../../screens/authentication/otp.dart';
import '../../utils/constants/colors.dart';
import '../../utils/providers/_providers.dart';

class StepperControls extends StatefulWidget {
  final int currentStep;
  final ControlsDetails details;
  final String email;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String blockNumber;
  final String houseNumber;
  final String mobileNumber;
  final String phoneNumber;
  final String approverEmail;
  final String estateName;
  final String estateLocation;
  final String password;
  final String confirmPassword;
  final String role;

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
    required this.phoneNumber,
    required this.approverEmail,
    required this.estateName,
    required this.estateLocation,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  @override
  State<StepperControls> createState() => _StepperControlsState();
}

class _StepperControlsState extends State<StepperControls> {
  bool isLoading = false;
  String authErrorString = "";

  bool nullValueCheck() {
    // Common required fields for all roles
    if (widget.email.isEmpty ||
        widget.firstName.isEmpty ||
        widget.lastName.isEmpty ||
        widget.idNumber.isEmpty ||
        widget.mobileNumber.isEmpty ||
        widget.role.isEmpty) {
      return true;
    }

    // Tenant-specific required fields
    if (widget.role == 'tenant') {
      if (widget.blockNumber.isEmpty ||
          widget.houseNumber.isEmpty ||
          widget.password.isEmpty) {
        return true;
      }
    }

    // Landlord-specific required fields
    if (widget.role == 'landlord') {
      if (widget.approverEmail.isEmpty ||
          widget.estateName.isEmpty ||
          widget.estateLocation.isEmpty) {
        return true;
      }
    }

    // Other non-tenant roles (caretaker, accounts)
    if (widget.role != 'tenant' && widget.role != 'landlord') {
      if (widget.approverEmail.isEmpty) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 4),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: royalBlue,
                    ),
                  ),
                )
              : Row(
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
                            horizontal: widget.currentStep == 0 ? 24 : 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: widget.currentStep != 2
                            ? widget.details.onStepContinue
                            : () {
                                // Check if any values are null
                                if (nullValueCheck()) {
                                  setState(() {
                                    authErrorString = "All fields are required";
                                  });
                                  return;
                                } else if (widget.password != widget.confirmPassword) {
                                  setState(() {
                                    authErrorString = "Passwords do not match";
                                  });
                                  return;
                                } else {
                                  setState(() {
                                    authErrorString = "";
                                  });
                                }

                                if (!Provider.of<InternetChecker>(context, listen: false)
                                    .isInternetActive) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Provider.of<InternetChecker>(context, listen: false)
                                      .showInternetConnectionDialog(context);
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                String usermail = widget.email.toString();
                                log(usermail.toString(), name: "mail from input");

                                SharedPrefrenceBuilder.setUserEmail(widget.email);

                                String storedMail = SharedPrefrenceBuilder.getUserEmail!;

                                log(storedMail.toString(), name: "Stored Mail");

                                final register = Auth().register(
                                    widget.email,
                                    widget.firstName,
                                    widget.lastName,
                                    widget.idNumber,
                                    widget.blockNumber,
                                    widget.houseNumber,
                                    widget.mobileNumber,
                                    widget.phoneNumber,
                                    widget.approverEmail,
                                    widget.estateName,
                                    widget.estateLocation,
                                    widget.password,
                                    widget.role,
                                    context);

                                register.then((value) {
                                  log(
                                    value.status.toString(),
                                    name: " register response message",
                                  );
                                  if (value.status == true) {
                                    // Store role and firstName for post-OTP routing
                                    SharedPrefrenceBuilder.setUserRole(widget.role);
                                    SharedPrefrenceBuilder.setUserFirstName(widget.firstName);

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(value.message),
                                          );
                                        });
                                     Navigator.of(context).pushReplacementNamed(Otp.routeName);

                                  } else {
                                    setState(() {
                                      isLoading = false;
                                      authErrorString = value.message;
                                    });
                                  }

                                });
                              },
                        child: Text(widget.currentStep != 2 ? "CONTINUE" : "SIGN UP"),
                      ),
                    ),
                    widget.currentStep > 0
                        ? isLoading
                            ? const SizedBox()
                            : TextButton(
                                onPressed: widget.details.onStepCancel,
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
          const SizedBox(
            height: 30,
          ),
          Text(
            authErrorString,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
