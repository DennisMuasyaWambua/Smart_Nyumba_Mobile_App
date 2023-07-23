import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_nyumba/Providers/payment_provider.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/Tenant/tenats_drawer.dart';

import '../Constants/Constants.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  //getting the Tenats profile from the backend
  int hasUserPaid = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: TenantsDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/smartnyumba.png",
                width: 70,
                height: 40,
                fit: BoxFit.cover,
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    Constants.dashboard,
                    style: GoogleFonts.urbanist(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  )),
            ],
          )),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    Constants.welcomeMsg,
                    style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: _gridView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridView() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
                onTap: () {
                  // payment status
                  // var history = Provider.of<Payments>(context, listen: false)
                  //     .getAllTransactions();

                  // history.then((value) {

                  //   for (int i = 0; i < value!.length; i++) {
                  //        log(value[i].toJson().toString(),
                  //       name: "HISTORIC TRANSACTIONS");
                  //       // get information from here on all transactions and form the system
                  //   }
                  // });
                  Navigator.pushNamed(context, '/allServiceChargeTransactions');
                },
                child: _paymentHistory()),
            GestureDetector(
                onTap: () {
                  var token = SharedPrefrenceBuilder().getUserToken.toString();

                  log(token.toString(),
                      name: "TOKEN BEING SHARED WITH PROVIDER STATE MANAGER");
                  var user = Provider.of<TenantsProfile>(context, listen: false)
                      .getUserProfile(token);

                  user.then((value) {
                    log(value.email.toString(),
                        name: "THIS IS THE USERS EMAIL");
                    var mobile = value.user!.mobileNumber.toString();
                    var serviceAmt =
                        value.propertyBlock!.serviceCharge.toString();
                    String serviceName = "Waste";
                    var pay = Provider.of<Payments>(context, listen: false)
                        .payServiceCharge(mobile, serviceAmt, serviceName);

                    pay.then((value) {
                      log(value.toJson().toString(), name: "PAYMENT RESULT");
                    });
                  });

                  Timer.periodic(const Duration(seconds: 3), (timer) {
                    if (hasUserPaid == 0) {
                      var check = Provider.of<Payments>(context, listen: false)
                          .checkPaymentStatus();
                      check.then((value) {
                        if (value == 1) {
                          hasUserPaid = value!;
                          log("$value payment was successful",
                              name: "PAYMENT SUCCESS");
                        } else {
                          log("$value payment was successful",
                              name: "PAYMENT FAILED");
                        }
                        log(value.toString(),
                            name: "FROM CHECKING THE PAYMENT RESULT");
                      });
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                      );
                      timer.cancel();
                    }
                  });
                },
                child: _payServiceCharge())
          ],
        ),
        Row(
          children: [
            GestureDetector(
                onTap: () {
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.custom,
                      barrierDismissible: true,
                      confirmBtnText: "Send");
                },
                child: _requestForRepairs()),
            _marketPlace(),
          ],
        ),
      ],
    );
  }

  Widget _paymentHistory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFFFFD700), Color(0xFFD4AF37)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.history,
                color: Colors.white,
                size: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.paymentHistory,
                  style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget _payServiceCharge() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFF5AFF15), Color(0xFF00B712)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.payServiceCharge,
                  style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget _requestForRepairs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFF09C6F9), Color(0xFF045DE9)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              Icon(
                Icons.plumbing_rounded,
                color: Colors.white,
                size: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.service,
                  style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget _marketPlace() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFF77EED8), Color(0xFF9EABE4)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              Icon(
                Icons.store,
                color: Colors.white,
                size: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.marketPlace,
                  style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
