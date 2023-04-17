import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_nyumba/Authentication/login/login_event.dart';
import 'package:smart_nyumba/Authentication/login/login_state.dart';
import 'package:smart_nyumba/form_submission_status.dart';

import '../auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent,LoginState>{
  final AuthRepository? authRepo;
  LoginBloc({this.authRepo}):super(LoginState()){
    on <LoginEvent>(
        (event,emit){}
    );
  }

 @override
  Stream<LoginState>mapEventToState(LoginEvent event)async*{
    //email updated
    if(event is LoginEmailChanged){
      yield state.copyWith(email: event.email);

    //  password updated
    }else if( event is LoginPasswordChanged){
      yield state.copyWith(password: event.password);

    //  Form updated
    }else if(event is LoginSubmitted){
      yield state.copyWith(formStatus: FormSubmitting());

      try{
        await authRepo?.login();
        yield state.copyWith(formStatus: SubmissionSuccess());
      }catch (e){
        yield state.copyWith(formStatus: SubmissionFailed(exception:e as Exception));
      }
    }
 }
}