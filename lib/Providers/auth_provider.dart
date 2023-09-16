import 'dart:async';
import 'dart:developer';
import 'package:smart_nyumba/Models/login_response_message.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/Models/register_response_message.dart';
import 'package:smart_nyumba/Models/send_otp.dart';
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'dart:convert';

import '../Constants/Constants.dart';

class Auth {
  // log in method
  Future<LoginResponseMessage> login(String email, password) async {
    String loginEndpoint = Constants.LOGIN_URL;
    log(loginEndpoint.toString(), name: "LOGIN URL");
    log("${email.toString()}${password.toString()}",
        name: "PARAMETERS BEING  USED");
    print(loginEndpoint);

    try {
      var uri = Uri.parse(loginEndpoint);
      final response =
          await http.post(uri, body: {'email': email, 'password': password});
      log(uri.toString(), name: "LOGIN URL");
      print(response.body);
      log(response.body.toString(), name: " RESPONSE");
      log(response.statusCode.toString(), name: "Status code");
      LoginResponseMessage loginResponseMessage =
          LoginResponseMessage.fromJson(json.decode(response.body));
      // print(loginResponseMessage.message);
      log(loginResponseMessage.message.toString(),
          name: "Response message from login");
      // Saving the token from logging in
      SharedPrefrenceBuilder.setUserToken(
          loginResponseMessage.accessToken.toString());
      if (loginResponseMessage.accessToken != null) {
        SharedPrefrenceBuilder.setUserToken(
            loginResponseMessage.accessToken.toString());
        log(loginResponseMessage.status.toString(), name: "Status");
        log(loginResponseMessage.message.toString(), name: "Success message");

        return loginResponseMessage;
      } else {
        log(loginResponseMessage.status.toString(), name: "Status");
        log(loginResponseMessage.message.toString(), name: "Error message");
        // print(loginResponseMessage.message);
        return LoginResponseMessage(
            message: "An error occurred", status: false);
      }
    } catch (e) {
      log("${Exception(e.toString())}", name: "Exception message from login");
      throw Exception(e.toString());
    }
  }

  // register method
  Future<RegisterResponse> register(String email, firstName, lastName, idNumber,
      blockNumber, houseNumber, mobileNumber, password) async {
    String registerEndpoint = Constants.REGISTER_URL;
    try {
      Uri register = Uri.parse(registerEndpoint);
      final response = await http.post(register, body: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobileNumber,
        'id_number': idNumber,
        'block_number': blockNumber,
        "house_number": houseNumber,
        'password': password,
      });
      log(response.statusCode.toString(), name: "Register status code");
      log(response.body.toString(), name: "Register response");
      RegisterResponse registerResponse =
          RegisterResponse.fromJson(jsonDecode(response.body));

      if (registerResponse.status = true) {
        return registerResponse;
      } else {
        return registerResponse;
      }
    } catch (e) {
      // Navigator.pushNamed(context, "/otp");
      log(e.toString(), name: "Exception message from user register");
      throw Exception(e.toString());
    }
  }

  // send otp
  Future<SendOtp> sendOtp(String email, String otp) async {
    try {
      log(email.toString(), name: "OTP EMAIL");
      log(otp.toString(), name: "OTP CODE FROM BOXES");
      String otpVerificationUrl = Constants.VERIFY_OTP;
      Uri otpVerification = Uri.parse(otpVerificationUrl);

      final verifyOtp =
          await http.post(otpVerification, body: {"email": email, "otp": otp});

      log(verifyOtp.body, name: "Verified Status from user register");
      SendOtp result = SendOtp.fromJson(jsonDecode(verifyOtp.body));

      if (result.status = true) {
        return result;
      } else {
        return result;
      }
    } catch (e) {
      log(e.toString(), name: "Exception message from OTP");
      throw Exception(e.toString());
    }
  }
}
