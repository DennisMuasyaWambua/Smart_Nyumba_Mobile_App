import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Constants/Logo.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = " ";
  String password = " ";
  String confirmPassword = " ";
  bool _isVisible = true;
  bool  _isConfirmVisible = true;
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  MaterialApp(
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
                  padding: const EdgeInsets.fromLTRB(40.0, 100, 10, 5),
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
                      width: MediaQuery.of(context).size.width*0.85,
                      height: MediaQuery.of(context).size.height*0.7,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Logo(height: 120,width: 120,),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: Text(Constants.register, style:GoogleFonts.publicSans(color: Constants.buttonColor, fontSize: 22) ,),
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
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: TextFormField(
                              onSaved: (newValue)=>confirmPassword,
                              controller: _confirmPasswordController,
                              obscureText: _isConfirmVisible,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock,color: Color(0xfff4eaaf),),
                                  suffixIcon: InkWell(onTap:_toogleConfirmPasswordView,child: Icon(_isConfirmVisible?Icons.visibility:Icons.visibility_off)),
                                  hintText: Constants.confirmPassword
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AuthButton(text: Constants.register, onClick: (){
                              //implement bloc state management
                            }, bgColor: Constants.buttonColor, textColor: Colors.white),
                          ),

                          GestureDetector(
                            onTap: (){
                              //Transitioning using Get
                              // Get.to(()=>const Register(),transition: Transition.fade,duration: Duration(seconds: 1));

                            },
                            child:Text(Constants.login, style:GoogleFonts.publicSans(color: Constants.buttonColor, fontSize: 13) ,) ,
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
  void _toogleConfirmPasswordView() {
    setState(() {
      _isConfirmVisible = !_isConfirmVisible;
    });
  }

}
