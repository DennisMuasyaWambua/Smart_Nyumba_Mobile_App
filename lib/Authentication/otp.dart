import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_nyumba/Authentication/login/login.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Providers/auth_provider.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';

class Otp extends StatefulWidget {
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
  var mail = SharedPrefrenceBuilder().getUserEmail;

  final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent)));
  final List<String> Otp = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (_) => Login()));
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Constants.buttonColor,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      "${Constants.OtpVerification}",
                      style: GoogleFonts.publicSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Constants.buttonColor),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/home.png"))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Pinput(
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                                border:
                                    Border.all(color: Constants.buttonColor))),
                        onCompleted: (pin) {
                          // int ot = pin as int;
                          var authentication =
                              Auth().sendOtp(mail.toString(), pin);

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
                                            child: Text("${value.message}"),
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
                                            child: Text("${value.message}"),
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AuthButton(
                      text: "Verify",
                      onClick: () {
                        // verify the OTP field
                        // get email from shared prefferences
                        setState(() {
                          box1 = ot1.text;
                          box2 = ot2.text;
                          box3 = ot3.text;
                          box4 = ot4.text;
                          Otp.addAll([box1, box2, box3, box4]);
                        });
                        String otp = "$box1$box2$box3$box4";
                        List<int> digits = Otp.map(int.parse).toList();
                        log(digits.toString(), name: "OTP NUMBER");
                        var y = digits.join('');
                        var code = int.parse(y);
                        log(otp.toString(), name: "OTP NUMBER");

                        log(mail.toString(), name: "mail from storage");
                        final SendOtp = Auth().sendOtp(mail.toString(), y);
                        log(code.toString(), name: "OTP CODE");
                        // check
                        SendOtp.then((value) {
                          if (value.status.toString() == true) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Success"),
                                    content: Text("${value.message}"),
                                  );
                                });

                            Navigator.pushNamed(context, "/login");
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text("${value.message}"),
                                  );
                                });
                          }
                        });
                      },
                      bgColor: Constants.buttonColor,
                      textColor: Colors.white),
                ),
                Text(
                  "${Constants.didntGetCode}",
                  style: GoogleFonts.publicSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Constants.buttonColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
