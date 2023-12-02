import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';


import '../Constants/Constants.dart';
import '../Models/invoice.dart';


class Receipt extends StatefulWidget {
  const Receipt({super.key});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  // creating the

  // write pdf function


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:50,left: 30.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap:(){
                                Navigator.pushNamed(context,'/allServiceChargeTransactions');
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.25,),
                          Text(
                            "Receipt",
                            style: GoogleFonts.hind(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          

                        ],
                      ),
                    ),
                  ],
                ),

        ),
      ),
    );
  }

