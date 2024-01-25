import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../utils/Constants/constants.dart';
import '../../utils/Providers/auth_provider.dart';
import '../../utils/Providers/shared_preference_builder.dart';

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
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.transparent),
    ),
  );
  final List<String> otpString = [];
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
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      Constants.OtpVerification,
                      style: GoogleFonts.publicSans(
                          fontSize: 20, fontWeight: FontWeight.w700, color: Constants.buttonColor),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/home.png"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Pinput(
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: Constants.buttonColor),
                          ),
                        ),
                        onCompleted: (pin) {
                          // int ot = pin as int;
                          var authentication = Auth().sendOtp(mail.toString(), pin);

                          authentication.then((value) {
                            if (value.status = true) {
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
                              showDialog(
                                  context: context,
                                  builder: (_) => SimpleDialog(
                                        title: Text(
                                          "Failed",
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
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
