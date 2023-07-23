import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Authentication/register/register.dart';

import 'package:smart_nyumba/Constants/Logo.dart';
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
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/smart_nyumba.jpeg"),
                fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _loginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
          icon: Icon(Icons.mail), hintText: Constants.email),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: _passwordVisible,
      controller: _passwordController,
      decoration: InputDecoration(
          icon: const Icon(Icons.security),
          suffixIcon: InkWell(
              onTap: _tooglePasswordVisibility,
              child: _passwordVisible
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off)),
          hintText: Constants.password),
    );
  }

  Widget _buttonSubmitField() {
    return AuthButton(
      onClick: () {
        email = _emailController.text;
        password = _passwordController.text;

        log(email.toString(), name: "EMAIL PARAMETER AT LOGIN");
        log(password.toString(), name: "PASSWORD PARAMETER AT LOGIN");
        final login = Auth().login(email, password);

        login.then((value) async {
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
      bgColor: Constants.buttonColor,
      text: Constants.login,
      textColor: Colors.white,
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
      child: Card(
        elevation: 50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(
                  height: 90,
                  width: 90,
                ),
                _emailField(),
                _passwordField(),
                _buttonSubmitField(),
                _registerPage()
              ],
            ),
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
