import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/Models/user_profile.dart';

import '../../Constants/Constants.dart';
import '../../Providers/auth_provider.dart';

class AccountProfile extends StatefulWidget {
  const AccountProfile({super.key});

  @override
  State<AccountProfile> createState() => _ProfileState();
}

class _ProfileState extends State<AccountProfile> {
  String email=' ';
  String name = ' ';
  int blockNumber =0;
  String houseNumber = ' ';
  String phoneNumber = ' ';
  Stream<UserProfile> userprofile() async*{
    yield UserProfile();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final account =  Auth().getProfile(Provider.of<Auth>(context,listen: false).token, context);
    account.then((value)async{
      setState(() {
        email = value.profile!.user!.email!;
        name = value.profile!.user!.firstName!;
        blockNumber = value.profile!.propertyBlock!.block!;
        houseNumber = value.profile!.propertyBlock!.houseNumber!;
        phoneNumber = value.profile!.user!.mobileNumber!;
      });

    });

  }
  @override
  Widget build(BuildContext context) {


    // setState(() {
    //   email = Provider.of<Auth>(context,listen: false).email;
    //   name =  Provider.of<Auth>(context,listen: false).firstName;
    //   blockNumber = Provider.of<Auth>(context,listen: false).blkNo;
    //   houseNumber = Provider.of<Auth>(context,listen: false).hseNo;
    // });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
              child:Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.10,),
                  CircleAvatar(
                    backgroundColor: Colors.amberAccent,
                    backgroundImage:AssetImage(Constants.SMART_NYUMBA_BLACK),
                    radius:  40,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                  Text(
                    '$name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1A1E25),
                      fontSize: 24,
                      fontFamily: 'Hind',
                      fontWeight: FontWeight.w700,
                      height: 0.04,
                      letterSpacing: 0.31,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                  Text(
                    '$email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7D7F88),
                      fontSize: 16,
                      fontFamily: 'Hind',
                      fontWeight: FontWeight.w400,
                      height: 0.06,
                      letterSpacing: 0.32,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                    child: Divider(endIndent: 10,thickness: 1,),
                  ),
                  ListTile(
                    leading: Container(width: 50,height: 50,child: Card(elevation: 10,child: Icon(Icons.person,color: Colors.black,),),),
                    title: ExpansionTile(title: Text("Personal Details",style: GoogleFonts.hind(fontSize:16, fontWeight: FontWeight.w500,letterSpacing:0.32,height: 0.06, ),),
                            children: [
                              Align(alignment: Alignment.centerLeft,child: Text("Name: $name",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),)),
                              Align(alignment: Alignment.centerLeft,child: Text("Email: $email",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),)),
                              Align(alignment: Alignment.centerLeft,child: Text("Block number: $blockNumber",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),)),
                              Align(alignment:Alignment.centerLeft,child: Text("House number: $houseNumber",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),))
                            ],
                            textColor: Colors.black,collapsedTextColor: Colors.black,),
                  ),
                  ListTile(
                    leading: Container(width: 50,height: 50,child: Card(elevation: 10,child: Icon(Icons.credit_card_rounded,color: Colors.black,),),),
                    title: ExpansionTile(title: Text("Payment Details",style: GoogleFonts.hind(fontSize:16, fontWeight: FontWeight.w500,letterSpacing:0.32,height: 0.06, ),),
                      children: [
                        Align(alignment: Alignment.centerLeft,child: Text("Payment Method: MPESA",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Mobile No: $phoneNumber",style: GoogleFonts.hind(fontSize: 13, fontWeight: FontWeight.w400,color: Colors.grey),)),

                      ],
                      textColor: Colors.black,collapsedTextColor: Colors.black,),
                  )
                ],
              ),
            ),
      ),
    );

  }
}
