import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Authentication/register/register.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Constants/Logo.dart';
import 'package:smart_nyumba/Tenant/tenantDashboard.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = " ";
  String password = " ";
  bool _isVisible = true;
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetMaterialApp(
        home: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/smart_nyumba.jpeg"),
              fit: BoxFit.cover
            )
          ),
          child: SingleChildScrollView(
            child: Stack(
              children: [

                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 200, 10, 5),
                    child: Neumorphic(
                      style:NeumorphicStyle(
                        shape: NeumorphicShape.concave,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20.0)),
                        depth: 10,
                        color: Colors.white,
                        lightSource: LightSource.topLeft,
                        intensity: 20
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        height: MediaQuery.of(context).size.height*0.6,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Logo(height: 120,width: 120,),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: Text(Constants.login, style:GoogleFonts.publicSans(color: Constants.buttonColor, fontSize: 22) ,),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: TextFormField(

                                onSaved: (newValue)=>email,
                                controller: _emailController,
                                decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person, color: Color(0xfff4eaaf),),

                                      hintText: Constants.email,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: TextFormField(
                                onSaved: (newValue)=>password,
                                controller: _passwordController,
                                obscureText: _isVisible,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock,color: Color(0xfff4eaaf),),
                                  suffixIcon: InkWell(onTap:_tooglePasswordView ,child: Icon(_isVisible?Icons.visibility:Icons.visibility_off)),
                                  hintText: Constants.password
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AuthButton(
                                  text: Constants.login,
                                  onClick: (){
                                  //implement bloc state management
                                  // Navigator.push(context, new MaterialPageRoute(builder: (_)=>TenantDashboard()));
                                  // Get.to(()=>TenantDashboard());
                                    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (_)=>TenantDashboard()));
                              }, bgColor: Constants.buttonColor, textColor: Colors.white),
                            ),
                            
                           GestureDetector(
                             onTap: (){
                               //Transitioning using Get
                               Get.to(()=>const Register(),transition: Transition.fade,duration: Duration(seconds: 1));

                             },
                             child:Text(Constants.joinMessage+ ' '+Constants.register, style:GoogleFonts.publicSans(color: Constants.buttonColor, fontSize: 13) ,) ,
                           )

                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _tooglePasswordView() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }
}
