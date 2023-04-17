import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_nyumba/Authentication/auth_repository.dart';
import 'package:smart_nyumba/Authentication/login/login_bloc.dart';
import 'package:smart_nyumba/Authentication/login/login_event.dart';
import 'package:smart_nyumba/Authentication/login/login_state.dart';
import 'package:smart_nyumba/Constants/Logo.dart';
import 'package:smart_nyumba/Widgets/AuthButton.dart';
import 'package:smart_nyumba/form_submission_status.dart';

import '../../Constants/Constants.dart';
import '../../Providers/auth_provider.dart';

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
            image:DecorationImage(
                image: AssetImage("assets/images/smart_nyumba.jpeg"),
                fit: BoxFit.cover
            ),

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
  Widget _emailField(){
      return TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
            icon: Icon(Icons.mail),
            hintText: Constants.email
        ),
      );
  }
  Widget _passwordField(){
    return TextFormField(

      obscureText:_passwordVisible ,
      controller: _passwordController,
      decoration: InputDecoration(
          icon: Icon(Icons.security),
          suffixIcon: InkWell(onTap: _tooglePasswordVisibility,child: _passwordVisible?Icon(Icons.visibility):Icon(Icons.visibility_off)),
          hintText: Constants.password
      ),
    );
  }
  Widget _buttonSubmitField(){
      return
      AuthButton(
        onClick: (){
          email = _emailController.text;
          password = _passwordController.text;
          print(email);
          print(password);
          final login = Auth().login(email, password);

          login.then((value) {
            print(value.message);
          });
        },
        bgColor: Constants.buttonColor,
        text: Constants.login,
        textColor: Colors.white,
      );
  }
  Widget _loginForm(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Card(
        elevation: 50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Logo(height: 90, width: 90,),
                  _emailField(),
                  _passwordField(),
                  _buttonSubmitField()
                ],
              ),
          ),
        ),
      ),
    );
  }
  void _tooglePasswordVisibility(){
    setState(() {
      _passwordVisible = !_passwordVisible;
    });

  }
}
