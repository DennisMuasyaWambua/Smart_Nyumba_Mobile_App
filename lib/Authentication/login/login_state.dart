import 'package:smart_nyumba/form_submission_status.dart';

class LoginState{
  final String? email;
  final String? password;
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