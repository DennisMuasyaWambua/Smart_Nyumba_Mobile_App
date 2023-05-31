import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Authentication/login/login.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Models/send_otp.dart';
import 'package:smart_nyumba/Providers/auth_provider.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';
import 'package:smart_nyumba/Widgets/OtpField.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  var ot1, ot2, ot3, ot4 = TextEditingController();
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
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    OtpField(numberInput: ot1),
                    SizedBox(
                      width: 8,
                    ),
                    OtpField(numberInput: ot2),
                    SizedBox(
                      width: 8,
                    ),
                    OtpField(numberInput: ot3),
                    SizedBox(
                      width: 8,
                    ),
                    OtpField(numberInput: ot4)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AuthButton(
                      text: "Verify",
                      onClick: () {
                        // verify the OTP field
                        // get email from shared prefferences
                        String otp = '$ot1$ot2$ot3$ot4';
                        log(otp.toString(), name: "OTP NUMBER");
                        var mail = SharedPrefrenceBuilder.getKey("email");
                        log(mail.toString(), name: "mail from string");
                        final SendOtp = Auth().sendOtp(mail, otp);

                        // check
                        SendOtp.then((value) {
                          if (value.status = true) {

                            showDialog(
                                context: context,
                                builder: (context) {
                             
                                  return  AlertDialog(
                                      title: Text("Success"),
                                      content: Text("${value.message}"),
                                    );
                                  
                                });

                            Navigator.pushNamed(context, "/login");
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                             
                                  return  AlertDialog(
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
