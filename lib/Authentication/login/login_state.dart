import 'package:smart_nyumba/form_submission_status.dart';

import '../../Constants/Constants.dart';

class LoginState{
  final String? email;
  final String? password;
  final RegExp emailRegex = Constants.emailRegex;
  final RegExp passRegex = Constants.passwordRegex;
  bool get isEmailValid =>  emailRegex.hasMatch(email.toString());
  bool get isPasswordValid => passRegex.hasMatch(password.toString());
  final FormSubmissionStatus? formStatus;
  LoginState({this.email=' ',this.password= ' ',this.formStatus = const InitialFormStatus()});

  LoginState copyWith({
    String? email,
    String? password,
    FormSubmissionStatus? formStatus
  }){
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      formStatus:formStatus?? this.formStatus,
    );

  }

}