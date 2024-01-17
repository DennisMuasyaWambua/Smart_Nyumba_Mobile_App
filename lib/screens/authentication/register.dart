import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/constants.dart';
import '../../utils/providers/auth_provider.dart';
import '../../utils/providers/shared_preference_builder.dart';
import '../../widgets/auth_button.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = " ";
  String firstName = " ";
  String lastName = " ";
  String idNumber = " ";
  String blockNumber = " ";
  String houseNumber = " ";
  String mobileNumber = " ";
  String password = " ";
  String confirmPassword = " ";
  String fname = "first name";
  String lname = "last name";

  bool _isVisible = true;
  bool _isConfirmVisible = true;
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _blockNumberController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialApp(
        home: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 5.0, 10, 5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0,top: 8.0),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset(Constants.SMART_NYUMBA_BLACK),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top:0),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w600,
                          fontSize: 41,
                          color: Color(0xff22215B)),
                    ),
                  ),
                  const Text(
                    "Hassle free property management",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: 'HindJalandhar',
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                        color: Color(0xff22215B)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        inputFields(120.0, 35.0, "First Name",
                            _firstNameController, TextInputType.text,Icons.person),
                        const SizedBox(
                          width: 25,
                        ),
                        inputFields(120.0, 35.0, "Last Name",
                            _lastNameController, TextInputType.text,Icons.person),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: inputFields(300.0, 40.0, "email", _emailController,
                        TextInputType.emailAddress,Icons.email),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        inputFields(150.0, 35.0, "ID number",
                            _idNumberController, TextInputType.number,Icons.credit_card_off_rounded),
                        inputFields(130.0, 35.0, "block number",
                            _blockNumberController, TextInputType.text,Icons.apartment_rounded)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        inputFields(150.0, 35.0, "House number",
                            _houseNumberController, TextInputType.text,Icons.house),
                        inputFields(140.0, 35.0, "Phone",
                            _mobileNumberController, TextInputType.number,Icons.phone),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: passwordField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: newPasswordField(),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                  //   child: TextFormField(
                  //     onSaved: (newValue) => password,
                  //     controller: _passwordController,
                  //     obscureText: _isVisible,
                  //     decoration: InputDecoration(
                  //         prefixIcon: const Icon(
                  //           Icons.lock,
                  //           color: Color(0xfff4eaaf),
                  //         ),
                  //         suffixIcon: InkWell(
                  //             onTap: _tooglePasswordView,
                  //             child: Icon(_isVisible
                  //                 ? Icons.visibility
                  //                 : Icons.visibility_off)),
                  //         hintText: Constants.password),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                  //   child: TextFormField(
                  //     onSaved: (newValue) => confirmPassword,
                  //     controller: _confirmPasswordController,
                  //     obscureText: _isConfirmVisible,
                  //     decoration: InputDecoration(
                  //         prefixIcon: const Icon(
                  //           Icons.lock,
                  //           color: Color(0xfff4eaaf),
                  //         ),
                  //         suffixIcon: InkWell(
                  //             onTap: _toogleConfirmPasswordView,
                  //             child: Icon(_isConfirmVisible
                  //                 ? Icons.visibility
                  //                 : Icons.visibility_off)),
                  //         hintText: Constants.confirmPassword),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: AuthButton(
                        text: Constants.register,
                        onClick: () {
                          // SharedPrefrenceBuilder.init();
                          setState(() {
                            email = _emailController.text;
                            firstName = _firstNameController.text;
                            lastName = _lastNameController.text;
                            idNumber = _idNumberController.text;
                            blockNumber = _blockNumberController.text;
                           houseNumber = _houseNumberController.text;
                            mobileNumber = _mobileNumberController.text;
                            password = _passwordController.text;
                          });

                          String usermail = email.toString();
                          log(usermail.toString(), name: "mail from input");

                          SharedPrefrenceBuilder.setUserEmail(email);

                          var storedMail =
                              SharedPrefrenceBuilder().getUserEmail;

                          log(storedMail.toString(), name: "Stored Mail");

                          final register = Auth().register(
                              email,
                              firstName,
                              lastName,
                              idNumber,
                              blockNumber,
                             houseNumber,
                              mobileNumber,
                              password,context);

                          register.then((value) {
                            log(value.message.toString(),
                                name: " register response message");
                            if (value.status = true) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(

                                      content: Text(value.message),
                                    );
                                  });
                               Navigator.pushNamed(context, "/otp");
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: Text(value.message),
                                    );
                                  });
                            }
                          });
                          // Navigator.pushNamed(context, '/otp');
                        },
                        textColor: const [Color(0xFF222831), Color(0xFF222831)]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        Constants.login,
                        style: GoogleFonts.publicSans(decoration:TextDecoration.none,
                            color: Constants.buttonColor, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputFields(width, height, hint, controller, x,y) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
          controller: controller,
          keyboardType: x,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(y,color: const Color(0xff22215B),),
            hintText: hint,
            contentPadding: const EdgeInsets.only(left: 25, bottom: 12),
            border: InputBorder.none,
          )),
    );
  }

  Widget passwordField() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
          obscureText: _isVisible,
          controller: _passwordController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Password",
            alignLabelWithHint: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
            prefixIcon: const Icon(Icons.security,color: Color(0xff22215B),),
            suffixIcon: InkWell(
                onTap: _tooglePasswordView,
                child: _isVisible
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off)),
          )),
    );
  }

  Widget newPasswordField() {
      return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.02),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
          obscureText: _isConfirmVisible,
          controller: _confirmPasswordController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            alignLabelWithHint: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
            prefixIcon:  const Icon(Icons.security,color: Color(0xff22215B),),
            suffixIcon: InkWell(
                onTap: _toogleConfirmPasswordView,
                child: _isConfirmVisible
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off)),
          )),
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
