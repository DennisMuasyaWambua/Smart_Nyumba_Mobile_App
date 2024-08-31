import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';
import 'package:smart_nyumba/widgets/button_layout.dart';

import '../../utils/constants/constants.dart';
import '../../utils/providers/auth_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import 'package:http/http.dart' as http;

class Otp extends StatefulWidget {
  static const routeName = "/otp";

  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  var ot1 = TextEditingController();
  var ot2 = TextEditingController();
  var ot3 = TextEditingController();
  var ot4 = TextEditingController();
  String box1 = '';
  String box2 = '';
  String box3 = '';
  String box4 = '';
  String mail = SharedPrefrenceBuilder.getUserEmail!;

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 60,
    textStyle: const TextStyle(fontSize: 22, color: Colors.black),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.transparent),
    ),
  );
  final List<String> otpString = [];
  String authErrorString = "";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Constants.buttonColor),
        actionsIconTheme: const IconThemeData(color: Constants.buttonColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0, top: 8.0),
                  child: Image.asset(Constants.SMART_NYUMBA_BLACK),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text(
                    "ENTER OTP",
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text("Enter the OTP code sent to your email"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Pinput(
                      length: 4,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: darkGold),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          authErrorString = "";
                        });
                      },
                      onCompleted: (pin) {
                        setState(() {
                          isLoading = true;
                        });
                        // int ot = pin as int;
                        var authentication =
                            Auth().sendOtp(mail.toString(), pin);

                        authentication.then((value) {
                          setState(() {
                            isLoading = false;
                          });

                          if (value.status == true) {
                            showDialog(
                                context: context,
                                builder: (_) => SimpleDialog(
                                      title: Text(
                                        "Activated",
                                        style: GoogleFonts.urbanist(
                                            color: Constants.buttonColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        Center(
                                          child: Text(value.message),
                                        )
                                      ],
                                    ));
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            setState(() {
                              authErrorString = "Invalid code provided";
                            });
                          }
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        authErrorString,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                const SizedBox(height: 20),
                ButtonLayout(
                  borderRadius: 6,
                  width: 248,
                  height: 40,
                  text: const Text(
                    "Resend Code",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onClick: () async {
                    var email = SharedPrefrenceBuilder.getUserEmail;
                    const String resendOtp = Constants.REGISTER_RESEND_OTP;
                    final response = await http
                        .post(Uri.parse(resendOtp), body: {"email": email});
                    log(response.body.toString(), name: "RESEND CODE");
                    showDialog(
                        context: context,
                        builder: ((_) => AlertDialog(
                              content: Container(width:300,height:100,child: Center(child: Text("OTP sent check your email"))),
                            )));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
