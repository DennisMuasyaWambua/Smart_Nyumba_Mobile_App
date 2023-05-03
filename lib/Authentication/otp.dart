import 'package:flutter/material.dart';
import 'package:smart_nyumba/Constants/Constants.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child:
                    IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back,color: Constants.buttonColor,)),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:AssetImage("assets/images/home.png") 
                    )
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child:TextFormField(
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        hintText: '*',
                        filled: true,
                        fillColor: Colors.grey.shade200
                      ),
                    ),

                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
