import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_nyumba/Authentication/Profile/account_profile.dart';
import 'package:smart_nyumba/Models/user_profile.dart';
import 'package:smart_nyumba/Providers/payment_provider.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Providers/tenants_profile_provider.dart';
import 'package:smart_nyumba/Tenant/tenant_home.dart';

import '../Constants/Constants.dart';
import '../Providers/auth_provider.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  //getting the Tenats profile from the backend
  int hasUserPaid = 0;
  int myIndex =0;
  var lastName;
  var token =  SharedPrefrenceBuilder().getUserToken;
  List<Widget> pages = [
    TenantHome(),
    AccountProfile()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Auth().getProfile(Provider.of<Auth>(context,listen: false).token, context);
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: IndexedStack(
       children: pages,
       index: myIndex,
     ),
     bottomNavigationBar: _bottomNavigationBar(),
   );
  }

  // Widget _gridView() {
  //   // log(context.read<Auth>().token.toString(),name:"THIS IS THE TOKEN");
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           GestureDetector(
  //               onTap: () {
  //                 // payment status
  //                 // var history = Provider.of<Payments>(context, listen: false)
  //                 //     .getAllTransactions();
  //
  //                 // history.then((value) {
  //
  //                 //   for (int i = 0; i < value!.length; i++) {
  //                 //        log(value[i].toJson().toString(),
  //                 //       name: "HISTORIC TRANSACTIONS");
  //                 //       // get information from here on all transactions and form the system
  //                 //   }
  //                 // });
  //                 Navigator.pushNamed(context, '/allServiceChargeTransactions');
  //               },
  //               child: _paymentHistory()),
  //           GestureDetector(
  //               onTap: () {
  //                 var token = SharedPrefrenceBuilder().getUserToken.toString();
  //
  //                 log(token.toString(),
  //                     name: "TOKEN BEING SHARED WITH PROVIDER STATE MANAGER");
  //                 var user = Provider.of<TenantsProfile>(context, listen: false)
  //                     .getUserProfile(token);
  //
  //                 user.then((value) {
  //                   log(value.email.toString(),
  //                       name: "THIS IS THE USERS EMAIL");
  //                   var mobile = value.user!.mobileNumber.toString();
  //                   int serviceAmt =
  //                       value.propertyBlock!.serviceCharge;
  //                   String serviceName = "Waste";
  //                   var pay = Provider.of<Payments>(context, listen: false)
  //                       .payServiceCharge(mobile, serviceAmt
  //                       , serviceName);
  //
  //                   pay.then((value) {
  //                     log(value.toJson().toString(), name: "PAYMENT RESULT");
  //                   });
  //                 });
  //
  //                 Timer.periodic(const Duration(seconds: 3), (timer) {
  //                   if (hasUserPaid == 0) {
  //                     var check = Provider.of<Payments>(context, listen: false)
  //                         .checkPaymentStatus();
  //                     check.then((value) {
  //                       if (value == 1) {
  //                         hasUserPaid = value!;
  //                         log("$value payment was successful",
  //                             name: "PAYMENT SUCCESS");
  //                       } else {
  //                         log("$value payment was successful",
  //                             name: "PAYMENT FAILED");
  //                       }
  //                       log(value.toString(),
  //                           name: "FROM CHECKING THE PAYMENT RESULT");
  //                     });
  //                   } else {
  //                     QuickAlert.show(
  //                       context: context,
  //                       type: QuickAlertType.success,
  //                     );
  //                     timer.cancel();
  //                   }
  //                 });
  //               },
  //               child: _payServiceCharge())
  //         ],
  //       ),
  //       Row(
  //         children: [
  //           GestureDetector(
  //               onTap: () {
  //                 QuickAlert.show(
  //                     context: context,
  //                     type: QuickAlertType.custom,
  //                     barrierDismissible: true,
  //                     confirmBtnText: "Send");
  //               },
  //               child: _requestForRepairs()),
  //           _marketPlace(),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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
          height: 160,
          width: 135,
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
                padding: const EdgeInsets.only(top: 8.0),
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
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            depth: 100,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
            lightSource: LightSource.topLeft,
            intensity: 30),
        child: Container(
          height: 160,
          width: 135,
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
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  Constants.payServiceCharge,
                  style: GoogleFonts.hind(
                      letterSpacing: -0.24,
                      height: 1.33,
                      fontSize: 15,
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
          height: 160,
          width: 135,
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
                padding: const EdgeInsets.only(top: 8.0),
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
          height: 160,
          width: 135,
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
                padding: const EdgeInsets.only(top: 8.0),
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

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (index){
          setState(() {
            myIndex=index;
          });
      },
        currentIndex: myIndex,
      selectedItemColor: const Color(0xFFD4AF37),
      items: const[
        BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),


    ]);
  }
}
