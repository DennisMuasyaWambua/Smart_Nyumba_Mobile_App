import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Authentication/register/register.dart';

import 'package:smart_nyumba/Models/user_profile.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';

import 'package:smart_nyumba/Widgets/AuthButton.dart';

import '../../Constants/Constants.dart';
import '../../Providers/auth_provider.dart';
import '../../Tenant/tenantDashboard.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = " ";
  String password = " ";
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loginForm(),
          ],
        ),
      ),
    ));
  }

  Widget _emailField() {
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
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(left: 25),
            border: InputBorder.none,
          )),
    );
  }

  Widget _passwordField() {
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
          obscureText: _passwordVisible,
          controller: _passwordController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
            suffixIcon: InkWell(
                onTap: _tooglePasswordVisibility,
                child: _passwordVisible
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off)),
          )),
    );
  }

  Widget _buttonSubmitField() {
    return AuthButton(
      onClick: () {
        setState(() {
          email = _emailController.text;
          password = _passwordController.text;
        });
        

        print("$email $password");

        log(email.toString(), name: "EMAIL PARAMETER AT LOGIN");
        log(password.toString(), name: "PASSWORD PARAMETER AT LOGIN");

        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (_) => const TenantDashboard()));
        final login = Auth().login(email, password);

        login.then((value) async {
          print(value.toString());
          log(value.message.toString(), name: "LOGIN MESSAGE");

          if (value.accessToken != null) {
            // Saving the users credentials using shared prefrences
            SharedPrefrenceBuilder.setUserEmail(email);
            SharedPrefrenceBuilder.setUserToken(value.accessToken.toString());
            // Set the User id to the user to save the usersprofile
            var user = await http.get(Uri.parse(Constants.TENANTS_PROFILE),
                headers: {'Authorization': 'Bearer ${value.accessToken}'});

            UserProfile usr = UserProfile.fromJson(json.decode(user.body));
            var id = usr.profile!.user!.id;
            SharedPrefrenceBuilder.setUserID(id!);

            log(SharedPrefrenceBuilder().getUserEmail.toString(),
                name: "EMAIL ADDRESS GOTTEN FROM LOGIN MESSAGE");
            log(SharedPrefrenceBuilder().getUserToken.toString(),
                name: "USER TOKEN GOTTEN FROM LOGIN MESSAGE");
            // Navigating to the tenants dashboard
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TenantDashboard()));
          } else {
            // QuickAlert.show(context: context, type: QuickAlertType.error, text: value.message);
            Timer(const Duration(seconds: 3), () {
              showDialog(
                  context: context,
                  builder: (context) {
                    Navigator.of(context).pop();

                    return AlertDialog(
                      title: const Text("ERROR"),
                      content: Text(value.message),
                    );
                  });
            });
          }
        });
      },
      text: Constants.login,
      textColor: const [Color(0xFFD4AF37), Color(0xFFFFD700)],
    );
  }

  Widget _registerPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Register()));
              },
              child: Text(
                '${Constants.joinMessage}${Constants.register}',
                style: GoogleFonts.publicSans(
                    color: Constants.buttonColor, fontSize: 13),
              ))),
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 140, 10, 5),
                child: Text(
                  "Smart Nyumba",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: 'HindJalandhar',
                      fontWeight: FontWeight.w300,
                      fontSize: 35,
                      color: Color(0xff22215B)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text(
                  "Sign in",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: 'HindJalandhar',
                      fontWeight: FontWeight.w600,
                      fontSize: 74,
                      color: Color(0xff22215B)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text("YOUR EMAIL",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Color(0xFF888888),
                        fontSize: 13,
                        fontFamily: 'karala',
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.40)),
              ),
              _emailField(),
              const Padding(
                  padding: EdgeInsets.only(bottom: 5, top: 40),
                  child: Text("PASSWORD",
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Color(0xFF888888),
                          fontSize: 13,
                          fontFamily: 'karala',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.40))),
              _passwordField(),
              const SizedBox(
                height: 40,
              ),
              _buttonSubmitField(),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const Register()));
                },
                child: const SizedBox(
                  width: 300,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Don’t have an account? Register',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Color(0xFF121515),
                        fontSize: 13,
                        fontFamily: 'Hind',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _tooglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }
}
