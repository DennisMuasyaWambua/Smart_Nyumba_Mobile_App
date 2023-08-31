import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Constants/Logo.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';

import '../../Providers/auth_provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = " ";
  String FirstName = " ";
  String LastName = " ";
  String IdNumber = " ";
  String BlockNumber = " ";
  String HouseNumber = " ";
  String MobileNumber = " ";
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 5.0, 10, 5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Image.asset(Constants.SMART_NYUMBA_BLACK),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      inputFields(120.0, 35.0, _firstNameController,
                          TextInputType.text),
                      const SizedBox(
                        width: 25,
                      ),
                      inputFields(
                          120.0, 35.0, _firstNameController, TextInputType.text)
                    ],
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  //   child: Text(
                  //     Constants.register,
                  //     style: GoogleFonts.publicSans(
                  //         color: Constants.buttonColor, fontSize: 22),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 3.0, 2.0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => email,
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.mail,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.email,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => FirstName,
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.firstName,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => LastName,
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.lastName,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => IdNumber,
                      controller: _idNumberController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.credit_card_rounded,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.idNumber,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => BlockNumber,
                      controller: _blockNumberController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.apartment_rounded,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.blockNumber,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => HouseNumber,
                      controller: _houseNumberController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.house,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.houseNumber,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => MobileNumber,
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xfff4eaaf),
                        ),
                        hintText: Constants.mobileNumber,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => password,
                      controller: _passwordController,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xfff4eaaf),
                          ),
                          suffixIcon: InkWell(
                              onTap: _tooglePasswordView,
                              child: Icon(_isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          hintText: Constants.password),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
                    child: TextFormField(
                      onSaved: (newValue) => confirmPassword,
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmVisible,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xfff4eaaf),
                          ),
                          suffixIcon: InkWell(
                              onTap: _toogleConfirmPasswordView,
                              child: Icon(_isConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          hintText: Constants.confirmPassword),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: AuthButton(
                        text: Constants.register,
                        onClick: () {
                          // SharedPrefrenceBuilder.init();
                          setState(() {
                            email = _emailController.text;
                            FirstName = _firstNameController.text;
                            LastName = _lastNameController.text;
                            IdNumber = _idNumberController.text;
                            BlockNumber = _blockNumberController.text;
                            HouseNumber = _houseNumberController.text;
                            MobileNumber = _mobileNumberController.text;
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
                              FirstName,
                              LastName,
                              IdNumber,
                              BlockNumber,
                              HouseNumber,
                              MobileNumber,
                              password);

                          register.then((value) {
                            log(value.message.toString(),
                                name: " register response message");
                            if (value.message !=
                                "User with this email already registered.") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Success"),
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
                          Navigator.pushNamed(context, '/otp');
                        },
                        textColor: [Color(0xFF222831), Color(0xFF222831)]),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      Constants.login,
                      style: GoogleFonts.publicSans(
                          color: Constants.buttonColor, fontSize: 13),
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

  Widget inputFields(width, height, controller, x) {
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
          decoration: const InputDecoration(
          
            contentPadding: EdgeInsets.only(left: 25),
            border: InputBorder.none,
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
