import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_nyumba/utils/constants/colors.dart';

import './register.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../../../utils/constants/constants.dart';
import '../../../utils/providers/auth_provider.dart';
import '../../widgets/auth/_auth_widgets.dart';
import '../tenant/tenant_dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = " ";
  String password = " ";

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  // Disposing controllers after use avoids memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 148,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 48.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Smart Nyumba",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w300,
                          fontSize: 35,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'HindJalandhar',
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                          color: royalBlue,
                        ),
                      ),
                    ),
                    const FieldLabel(labelName: "YOUR EMAIL"),
                    EmailField(controller: _emailController),
                    const FieldLabel(labelName: "PASSWORD"),
                    PasswordField(controller: _passwordController),
                    const SizedBox(
                      height: 40,
                    ),
                    _buttonSubmitField(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Register()),
                            );
                          },
                          child: const Text(
                            'Don’t have an account? Register',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: shadeBlack,
                              fontSize: 13,
                              fontFamily: 'Hind',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonSubmitField() {
    return AuthButton(
      text: Constants.login,
      buttonBgColor: gradYellowGold,
      onClick: () {
        setState(() {
          email = _emailController.text;
          password = _passwordController.text;
        });
        // Navigate to the Admin's dashboard
        // Navigator.pushNamed(context, '/adminDashboard');
        debugPrint("$email $password");

        log(email.toString(), name: "EMAIL PARAMETER AT LOGIN");
        log(password.toString(), name: "PASSWORD PARAMETER AT LOGIN");

        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (_) => const TenantDashboard()));
        final login = Auth().login(email, password, context);

        login.then((value) async {
          debugPrint(value.toString());
          log(value.message.toString(), name: "LOGIN MESSAGE");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const TenantDashboard()));

          // if (value.accessToken != null) {
          //   // Saving the users credentials using shared prefrences
          //   SharedPrefrenceBuilder.setUserEmail(email);
          //   SharedPrefrenceBuilder.setUserToken(value.accessToken.toString());
          //   //saving token to provider
          //   Provider.of<Auth>(context,listen:false).setToken(value.accessToken.toString());
          //   log(Provider.of<Auth>(context,listen: false).token.toString(),name: "TOKEN PROVIDER");
          //   // Auth().getProfile(Provider.of<Auth>(context,listen: false).token.toString(), context);
          //
          //   // Set the User id to the user to save the usersprofile
          //   var user = await http.get(Uri.parse(Constants.TENANTS_PROFILE),
          //       headers: {'Authorization': 'Bearer ${value.accessToken}'});
          //
          //   UserProfile usr = UserProfile.fromJson(json.decode(user.body));
          //   var id = usr.profile!.user!.id;
          //   SharedPrefrenceBuilder.setUserID(id!);
          //
          //   log(SharedPrefrenceBuilder().getUserEmail.toString(),
          //       name: "EMAIL ADDRESS GOTTEN FROM LOGIN MESSAGE");
          //   log(SharedPrefrenceBuilder().getUserToken.toString(),
          //       name: "USER TOKEN GOTTEN FROM LOGIN MESSAGE");
          //   // Navigating to the tenants dashboard
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (_) => const TenantDashboard()));
          // } else {
          //   // QuickAlert.show(context: context, type: QuickAlertType.error, text: value.message);
          //   Timer(const Duration(seconds: 3), () {
          //     showDialog(
          //         context: context,
          //         builder: (context) {
          //           Navigator.of(context).pop();
          //
          //           return AlertDialog(
          //             title: const Text("ERROR"),
          //             content: Text(value.message),
          //           );
          //         });
          //   });
          // }
        });
      },
    );
  }
}
