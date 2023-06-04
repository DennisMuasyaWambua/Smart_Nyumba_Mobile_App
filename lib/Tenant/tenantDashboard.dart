import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Tenant/serviceChargePaymentScreen.dart';

import '../Constants/Constants.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({Key? key}) : super(key: key);

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: MaterialApp(
          home: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   topBar(context),
                  welcomeMsg(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: notificationCards(context),
                  ),
                  servicesCard(context),

                ],
              ),
          ),
        ),
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }
}

//top Bar widget
Material topBar(BuildContext context){
  return Material(
    child: Container(
        height:100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
             Center(
               child: Text(
                Constants.dashboard,
                 style: GoogleFonts.hind(fontSize: 25,fontWeight: FontWeight.bold,color:Colors.black),
               ),
             )
          ],
        ),
    ),
  );
}

//Welcome message bar
Material welcomeMsg(BuildContext context){
  return Material(
    child:Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 3.0, 0, 5.0),
      child: Text(Constants.welcomeMsg,style: GoogleFonts.hind(fontSize:30,fontWeight: FontWeight.bold,),),
    ),
  );
}

//Notification cards
Material notificationCards(BuildContext context){
  return Material(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Constants.buttonColor,
                  elevation: 20,
                  child: Container(
                    width: 150,
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded,color: Colors.white,size: 35.0,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(Constants.paymentHistory, style: GoogleFonts.hind(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white),),
                        )
                      ],
                    ),

                  )
                ),
                Card(
                    color: Constants.serviceColor,
                    elevation: 20,
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance,color: Colors.white,size: 35.0,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(Constants.serviceChargeBalance, style: GoogleFonts.hind(fontSize: 12.5, fontWeight: FontWeight.w500,color: Colors.white),),
                          ),
                          Text("KES: 3000", style: GoogleFonts.hind(fontSize: 12, fontWeight: FontWeight.w500,color: Colors.white),)
                        ],
                      ),

                    )
                )
              ],
            ),

            Row(
              
              children: [
                // Paying service charge 
                Card(
                    color: Constants.paymentColor,
                    elevation: 20,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, new MaterialPageRoute(builder: (_)=>ServiceChargePayment()));
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on,color: Colors.white,size: 35.0,),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(Constants.payServiceCharge, style: GoogleFonts.hind(fontSize: 15, fontWeight: FontWeight.w500,color: Colors.white),),
                            )
                          ],
                        ),

                      ),
                    )
                ),
                Card(
                    color: Constants.servicesColor,
                    elevation: 20,
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cleaning_services_outlined,color: Colors.white,size: 35.0,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(Constants.service, style: GoogleFonts.hind(fontSize: 15, fontWeight: FontWeight.w500,color: Colors.white),),
                          ),

                        ],
                      ),

                    )
                )
              ],
            )

          ],
        ),
  );
}

//services Card
Material servicesCard(BuildContext context){
    return Material(
        child: Card(
            elevation: 20,
            child:Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: MediaQuery.of(context).size.width*0.6,
                height: MediaQuery.of(context).size.height*0.2,
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                          Text(Constants.service,style: GoogleFonts.hind(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),),
                          Text(Constants.noService,style: GoogleFonts.hind(fontWeight: FontWeight.w200, fontSize: 13, color: Colors.black),),
                          Container(decoration:BoxDecoration(shape: BoxShape.circle,),padding:EdgeInsets.only(top: 70.0),alignment:Alignment.bottomCenter,child: Card(elevation:20.0,child: Icon(Icons.add, size: 35.0,)))

                      ],
                    ),
                ),

              ),
            ),
        ),
    );
}

//Bottom navigation Appbar
Material bottomNavigationBar(BuildContext context){
  return Material(
      child: Container(
        color: Constants.purple,
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
              IconButton(
                  onPressed: (){
                    //Navigation to different screen
                  },
                  icon: Icon(Icons.home,color: Colors.white,size: 25.0,)
              ),
              IconButton(
                  onPressed: (){
                    //Navigation to different screen
                  },
                  icon: Icon(Icons.add,color: Colors.white,size: 25.0,)
              ),
              IconButton(
                  onPressed: (){
                    //Navigation to different screen
                  },
                  icon: Icon(Icons.person,color: Colors.white,size: 25.0,)
              ),
          ],
        ),
      ),
  );
}