import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_nyumba/Authentication/register/register.dart';

import 'package:smart_nyumba/Constants/Logo.dart';

import 'package:smart_nyumba/Widgets/AuthButton.dart';

import '../../Constants/Constants.dart';
import '../../Providers/auth_provider.dart';
import '../../Tenant/tenantDashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = " ";
  String password = " ";
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  bool _passwordVisible = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
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
      decoration:
          InputDecoration(icon: Icon(Icons.mail), hintText: Constants.email),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: _passwordVisible,
      controller: _passwordController,
      decoration: InputDecoration(
          icon: Icon(Icons.security),
          suffixIcon: InkWell(
              onTap: _tooglePasswordVisibility,
              child: _passwordVisible
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off)),
          hintText: Constants.password),
    );
  }

  Widget _buttonSubmitField() {
    return AuthButton(
      onClick: () {
        email = _emailController.text;
        password = _passwordController.text;
        print(email);
        print(password);
        final login = Auth().login(email, password);

        login.then((value) {
          print(value.message);

          if (value.accessToken != null) {
            Navigator.push(context,
                new MaterialPageRoute(builder: (_) => TenantDashboard()));
          } else {
            Timer(const Duration(seconds: 3), () {
              showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(new Duration(seconds: 3), () {
                      Navigator.of(context).pop();
                    });
                    return AlertDialog(
                      title: Text("ERROR"),
                      content: Text("${value.message}"),
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
      padding: EdgeInsets.all(8.0),
      child: Center(
          child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context, new MaterialPageRoute(builder: (_) => Register()));
              },
              child: Text(
                Constants.joinMessage + '' + Constants.register,
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
                Logo(
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
