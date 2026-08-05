import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

// import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants/constants.dart';
import '../../../utils/providers/_providers.dart';
import '../../utils/constants/colors.dart';
import '../../utils/providers/payment_provider.dart';
import '../../widgets/auth/_auth_widgets.dart';
import '../admin/_admin.dart';
import '../caretaker/_caretaker.dart';
import '../landlord/_landlord.dart';
import '../tenant/tenant_dashboard.dart';
import 'forgot_password.dart';
import 'register.dart';

class Login extends StatefulWidget {
  static const routeName = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    // Check for internet connectivity.
    // If you are running in debug mode, comment out the code to avoid errors.
    Provider.of<InternetChecker>(context).checkForInternetConnection();
    super.didChangeDependencies();
  }

  // Disposing controllers after use avoids memory leaks
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
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const FieldLabel(labelName: "YOUR EMAIL"),
                    EmailField(controller: _emailController),
                    const FieldLabel(labelName: "PASSWORD"),
                    PasswordField(controller: _passwordController),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, ForgotPasswordScreen.routeName),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
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

                        log(email.toString(), name: "EMAIL PARAMETER AT LOGIN");
                        log(password.toString(),
                            name: "PASSWORD PARAMETER AT LOGIN");

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

                        final login = Auth().login(email, password, context);

                        login.then((value) async {
                          if (!mounted) return;

                          setState(() {
                            isLoading = false;
                          });

                          log("Login response: ${value.message}, role: ${value.role}", name: "LOGIN SCREEN");

                          // Check if login was successful (handle both "Login Successful" and "Login successful")
                          if (value.status == true && value.accessToken != null) {
                            log("Login successful, routing to dashboard for role: ${value.role}", name: "LOGIN SCREEN");

                            if (value.role == "tenant") {
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed(
                                    TenantDashboard.routeName);
                              }
                            } else if (value.role == "landlord") {
                              // Check landlord activation status
                              try {
                                if (!mounted) return;
                                final paymentProvider = Provider.of<Payments>(context, listen: false);
                                final activationStatus = await paymentProvider.checkActivationPaymentStatus(email);

                                log("Landlord activation status: $activationStatus", name: "LOGIN SCREEN");

                                if (activationStatus == 1) {
                                  // Activated - proceed to dashboard
                                  if (mounted) {
                                    Navigator.of(context).pushReplacementNamed(
                                        LandlordDashboard.routeName);
                                  }
                                } else {
                                  // Not activated - show error
                                  if (mounted) {
                                    setState(() {
                                      authErrorString = "Account not activated. Please complete activation payment.";
                                    });
                                  }
                                }
                              } catch (e) {
                                log("Error checking activation: $e", name: "LOGIN SCREEN");
                                // If error checking status, still proceed to dashboard
                                if (mounted) {
                                  Navigator.of(context).pushReplacementNamed(
                                      LandlordDashboard.routeName);
                                }
                              }
                            } else if (value.role == "caretaker") {
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed(
                                    CaretakerDashboard.routeName);
                              }
                            } else {
                              // Admin, accounts go to admin dashboard
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed(
                                    AdminDashboard.routeName);
                              }
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                authErrorString = value.message ?? "Login failed";
                              });
                            }
                          }
                        });
                      },
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(Register.routeName);
                          },
                          child: const Text(
                            'Don’t have an account? Register',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: shadeBlack,
                              fontSize: 13,
                              fontFamily: 'Hind',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        authErrorString,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
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
