import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/constants.dart';

class ServiceChargePayment extends StatefulWidget {
  const ServiceChargePayment({Key? key}) : super(key: key);

  @override
  State<ServiceChargePayment> createState() => _ServiceChargePaymentState();
}

class _ServiceChargePaymentState extends State<ServiceChargePayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialApp(
        home: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [topNav(context), paymentCard(context)],
          ),
        ),
      ),
    );
  }
}

//Top Navigation bar
Material topNav(BuildContext context) {
  return Material(
    child: SizedBox(
      height: 100,
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20.0,
              )),
          Text(
            Constants.payment,
            style: GoogleFonts.hind(fontSize: 16.0, fontWeight: FontWeight.w400),
          )
        ],
      ),
    ),
  );
}

//Apartment card
Material paymentCard(BuildContext context) {
  return Material(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
      child: Card(
        elevation: 25,
        child: Row(
          children: [
            Container(
              width: 30,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/mansion.jpg"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                Constants.serviceCharge,
                style: GoogleFonts.hind(
                    fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
