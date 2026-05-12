import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/constants.dart';
import '../../utils/providers/_providers.dart';
import '../../utils/providers/caretaker_provider.dart';
import '../../widgets/auth/_auth_widgets.dart';
import 'caretaker_dashboard.dart';

class CaretakerLogin extends StatefulWidget {
  static const routeName = "/caretaker-login";

  const CaretakerLogin({super.key});

  @override
  State<CaretakerLogin> createState() => _CaretakerLoginState();
}

class _CaretakerLoginState extends State<CaretakerLogin> {
  String email = " ";
  String password = " ";

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String authErrorString = "";

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Provider.of<InternetChecker>(context).checkForInternetConnection();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 148,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Smart Nyumba",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w300,
                          fontSize: 35,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Caretaker Sign in",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        "Manage maintenance requests",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const FieldLabel(labelName: "YOUR EMAIL"),
                    EmailField(controller: _emailController),
                    const FieldLabel(labelName: "PASSWORD"),
                    PasswordField(controller: _passwordController),
                    const SizedBox(
                      height: 40,
                    ),
                    ButtonLayout(
                      width: double.infinity,
                      height: 56,
                      text: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              Constants.login,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Hind',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      onClick: () {
                        if (_emailController.text == "" ||
                            _passwordController.text == "") {
                          setState(() {
                            authErrorString = "Empty fields";
                          });
                          return;
                        }
                        setState(() {
                          email = _emailController.text;
                          password = _passwordController.text;
                          authErrorString = "";
                          isLoading = true;
                        });

                        debugPrint("$email, $password");

                        log(email.toString(),
                            name: "EMAIL PARAMETER AT CARETAKER LOGIN");
                        log(password.toString(),
                            name: "PASSWORD PARAMETER AT CARETAKER LOGIN");

                        if (!Provider.of<InternetChecker>(context,
                                listen: false)
                            .isInternetActive) {
                          setState(() {
                            isLoading = false;
                          });
                          Provider.of<InternetChecker>(context, listen: false)
                              .showInternetConnectionDialog(context);
                          return;
                        }

                        final login =
                            CaretakerProvider().login(email, password, context);

                        login.then((value) async {
                          setState(() {
                            isLoading = false;
                          });

                          if (value.status == true &&
                              value.message == "Login Successful") {
                            // Save role
                            if (value.role != null) {
                              SharedPrefrenceBuilder.setUserRole(value.role!);
                            }
                            Navigator.of(context).pushReplacementNamed(
                                CaretakerDashboard.routeName);
                          } else {
                            setState(() {
                              authErrorString = value.message ?? "Login failed";
                            });
                          }
                        }).catchError((error) {
                          setState(() {
                            isLoading = false;
                            authErrorString = "An error occurred during login";
                          });
                          log(error.toString(),
                              name: "Error from caretaker login");
                        });
                      },
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          authErrorString,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
