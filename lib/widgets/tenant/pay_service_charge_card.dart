import 'dart:async';
import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_nyumba/utils/providers/_providers.dart';

import '../../utils/constants/constants.dart';

// ignore: must_be_immutable
class PayServiceChargeCard extends StatelessWidget {
  int hasUserPaid;
  PayServiceChargeCard({super.key, required this.hasUserPaid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var token = SharedPrefrenceBuilder.getUserToken;

        log(token.toString(), name: "TOKEN BEING SHARED WITH PROVIDER STATE MANAGER");
        var user = Provider.of<TenantsProfile>(context, listen: false).getUserProfile(token!);

        user.then((value) {
          log(value.email.toString(), name: "THIS IS THE USERS EMAIL");
          var mobile = value.user!.mobileNumber.toString();

          String amt = '1';
          String serviceName = "Waste";
          var pay = Provider.of<Payments>(context, listen: false)
              .payServiceCharge(mobile, amt, serviceName);

          pay.then((value) {
            log(value.toJson().toString(), name: "PAYMENT RESULT");
          });
        });

        Timer.periodic(const Duration(seconds: 3), (timer) {
          if (hasUserPaid == 0) {
            var check = Provider.of<Payments>(context, listen: false).checkPaymentStatus();
            check.then((value) {
              if (value == 1) {
                hasUserPaid = value!;
                log("$value payment was successful", name: "PAYMENT SUCCESS");
                timer.cancel();
              } else {
                log("$value payment failed", name: "PAYMENT FAILED");
                timer.cancel();
              }
              log(value.toString(), name: "FROM CHECKING THE PAYMENT RESULT");
            });
            timer.cancel();
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
            );
            timer.cancel();
          }
          timer.cancel();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 0.5, right: 5.0),
        child: Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.concave,
              depth: 100,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
              lightSource: LightSource.topLeft,
              intensity: 30),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.22,
            width: MediaQuery.of(context).size.width * 0.40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.97, 0.24),
                end: Alignment(0.97, -0.24),
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      Constants.payServiceCharge,
                      style: GoogleFonts.hind(
                          letterSpacing: -0.24,
                          height: 1.33,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
