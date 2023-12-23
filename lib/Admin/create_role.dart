import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Constants/Constants.dart';

class CreateRole extends StatefulWidget {
  const CreateRole({super.key});

  @override
  State<CreateRole> createState() => _CreateRoleState();
}

class _CreateRoleState extends State<CreateRole> {
  TextEditingController roleNameController = TextEditingController();
  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
        selectedItemColor: const Color(0xFFD4AF37),
        items: const[
          BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add),label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),


        ]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top:40.0,left: 20.0),
              child: Row(
                children: [
                  Icon(Icons.arrow_back,color: Colors.black,),

                ],
              ),
            ),

            SizedBox(width:276,child: Text(Constants.addNewRole, style: GoogleFonts.hind(color: Colors.black,fontWeight: FontWeight.w700, fontSize: 17),)),
            Padding(
              padding: EdgeInsets.only(top:5.0,left: 20.0),
              child: Row(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(Constants.addNewRoleDescription, style: GoogleFonts.inter(color: Colors.grey,fontWeight: FontWeight.w400, fontSize: 14),),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:25.0),
              child: Container(
                width: 310,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: Color(0xFFF2F3F3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                child:
                    TextFormField(
                        controller: roleNameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Role Name",
                          contentPadding: EdgeInsets.only(left: 25,bottom: 10),
                          border: InputBorder.none,
                        )),

              ),
            )
          ],
        ),
      ),
    );
  }
}
