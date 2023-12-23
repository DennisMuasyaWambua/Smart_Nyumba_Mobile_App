import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../Constants/Constants.dart';
import '../Providers/auth_provider.dart';
import '../Providers/payment_provider.dart';
import '../Providers/shared_preference_builder.dart';
import '../Providers/tenants_profile_provider.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  int hasUserPaid = 0;
  int myIndex =0;
  var lastName = ' ';
  var token =  SharedPrefrenceBuilder().getUserToken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(token.toString(),name: "THIS IS THE USERS TOKEN");
    final profile =  Auth().getProfile(token!,context);
    profile.then((value)async{
      setState(() {
        log(value.profile!.user!.toJson().toString(),name: "FETCHING PROFILE");
        lastName = value.profile!.user!.firstName.toString();
        Provider.of<Auth>(context,listen: false).setLastName(value.profile!.user!.lastName.toString());
        log(lastName.toString(),name: "USERS LAST NAME");
      });

      // User? user = value.profile!.user;
      // Provider.of<Auth>(context,listen: false).setUsersData(user!);

    });
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Column(

            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  Constants.dashboard,
                  style: GoogleFonts.hind(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
              ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Welcome $lastName',
                      style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 30),
                child: _gridView(),
              ),
            ],
          ),
        );


  }
  Widget _gridView() {
    // log(context.read<Auth>().token.toString(),name:"THIS IS THE TOKEN");
    return Column(

      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [
        Row(
          children: [

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

                    String amt = '1';
                    String serviceName = "Waste";
                    var pay = Provider.of<Payments>(context, listen: false)
                        .payServiceCharge(mobile,amt, serviceName);


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
                          timer.cancel();
                        } else {
                          log("$value payment failed",
                              name: "PAYMENT FAILED");
                          timer.cancel();
                        }
                        log(value.toString(),
                            name: "FROM CHECKING THE PAYMENT RESULT");
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
                child: _payServiceCharge()),
            GestureDetector(
                onTap: () {
                  // payment status
                  // var history = Provider.of<Payments>(context, listen: false)
                  //     .getAllTransactions();
                  //
                  // history.then((value) {
                  //
                  //   for (int i = 0; i < value!.length; i++) {
                  //        log(value[i].toJson().toString(),
                  //       name: "HISTORIC TRANSACTIONS");
                  //       // get information from here on all transactions and form the system
                  //   }
                  // });
                  Navigator.pushNamed(context, '/allServiceChargeTransactions');
                },
                child: _paymentHistory())

          ],
        ),
        Row(
          children: [
            GestureDetector(
                onTap: () {

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
          height: MediaQuery.of(context).size.height*0.22,
          width: MediaQuery.of(context).size.width*0.40,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.history,
                color: Colors.white,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 5.0,right: 5.0),
                child: Text(
                  Constants.paymentHistory,
                  style: GoogleFonts.hind(
                      height: 1.33,
                      fontSize: 15,
                      letterSpacing: -0.24,
                      fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.only(left: 0.5,right: 5.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height*0.22,
          width: MediaQuery.of(context).size.width*0.40,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-0.97, 0.24),
                  end: Alignment(0.97, -0.24),
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 5.0,right: 5.0),
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
    );
  }

  Widget _requestForRepairs() {
    return Padding(
      padding: const EdgeInsets.only(left: 0.5,right: 5.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: MediaQuery.of(context).size.height*0.22,
          width: MediaQuery.of(context).size.width*0.40,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              shadows: const [
                BoxShadow(
                  color: Color(0x19A3A3A3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.plumbing_rounded,
                color: Colors.black,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 5.0,right: 5.0),
                child: Text(
                  Constants.service,
                  style: GoogleFonts.hind(
                      height: 1.33,
                      letterSpacing: -0.24,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
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
          height: MediaQuery.of(context).size.height*0.22,
          width: MediaQuery.of(context).size.width*0.40,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              shadows: const [
                BoxShadow(
                  color: Color(0x19A3A3A3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(children: [
              const Icon(
                Icons.store,
                color: Colors.black,
                size: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 5.0,right: 5.0),
                child: Text(
                  Constants.marketPlace,
                  style: GoogleFonts.hind(
                      letterSpacing: -0.24,
                      height: 1.33,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
