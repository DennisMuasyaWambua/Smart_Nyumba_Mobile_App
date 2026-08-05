import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';

import '../constants/constants.dart';
import '../models/caretaker_login_response.dart';
import '../models/caretaker_profile.dart';
import 'shared_preference_builder.dart';

class CaretakerProvider {
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  String? idNumber;

  // Login method
  Future<CaretakerLoginResponse> login(
      String email, String password, BuildContext context) async {
    String loginEndpoint = Constants.CARETAKER_LOGIN_URL;
    try {
      Uri loginUri = Uri.parse(loginEndpoint);
      final response = await SafeHttp.post(
        loginUri,
        body: {
          'email': email,
          'password': password,
        },
      );

      log(response.statusCode.toString(), name: "Caretaker Login status code");
      log(response.body.toString(), name: "Caretaker Login response");

      CaretakerLoginResponse loginResponse =
          CaretakerLoginResponse.fromJson(jsonDecode(response.body));

      // Save token if login successful
      if (loginResponse.status == true && loginResponse.tokens?.access != null) {
        SharedPrefrenceBuilder.setUserToken(loginResponse.tokens!.access!);
        log(loginResponse.tokens!.access!, name: "Caretaker Token saved");
      }

      return loginResponse;
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker login");
      throw Exception(e.toString());
    }
  }

  // Logout method
  Future<bool> logout(BuildContext context) async {
    String logoutEndpoint = Constants.CARETAKER_LOGOUT_URL;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        log("No token found", name: "Caretaker Logout");
        return false;
      }

      Uri logoutUri = Uri.parse(logoutEndpoint);
      final response = await SafeHttp.post(
        logoutUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Caretaker Logout status code");
      log(response.body.toString(), name: "Caretaker Logout response");

      if (response.statusCode == 200) {
        SharedPrefrenceBuilder.clearInvalidToken();
        return true;
      }
      return false;
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker logout");
      return false;
    }
  }

  // Get caretaker profile
  Future<CaretakerProfile> getProfile(
      String token, BuildContext context) async {
    try {
      String profileUrl = Constants.CARETAKER_PROFILE_URL;
      Uri uri = Uri.parse(profileUrl);
      final response = await SafeHttp.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      log(token.toString(), name: "CARETAKER TOKEN");
      log(response.body.toString(), name: "CARETAKER PROFILE RESPONSE");

      CaretakerProfile profile =
          CaretakerProfile.fromJson(jsonDecode(response.body));

      // Store profile data locally
      if (profile.profile != null) {
        firstName = profile.profile!.user?.firstName;
        lastName = profile.profile!.user?.lastName;
        email = profile.profile!.user?.email;
        mobileNumber = profile.profile!.user?.mobileNumber;
        idNumber = profile.profile!.caretaker?.idNumber;

        setEmail(email!);
        setFirstName(firstName!);
        setLastName(lastName!);
      }

      return profile;
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker profile");
      throw Exception(e.toString());
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    String forgotPasswordEndpoint = Constants.CARETAKER_FORGOT_PASSWORD;
    try {
      Uri forgotPasswordUri = Uri.parse(forgotPasswordEndpoint);
      final response = await SafeHttp.post(
        forgotPasswordUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Caretaker Forgot Password status code");
      log(response.body.toString(),
          name: "Caretaker Forgot Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker forgot password");
      throw Exception(e.toString());
    }
  }

  // Verify change password with OTP
  Future<Map<String, dynamic>> verifyChangePassword(
      String email, String otp) async {
    String verifyEndpoint = Constants.CARETAKER_VERIFY_CHANGE_PASSWORD;
    try {
      Uri verifyUri = Uri.parse(verifyEndpoint);
      final response = await SafeHttp.post(
        verifyUri,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      log(response.statusCode.toString(),
          name: "Caretaker Verify Change Password status code");
      log(response.body.toString(),
          name: "Caretaker Verify Change Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(),
          name: "Exception from caretaker verify change password");
      throw Exception(e.toString());
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    String resendOtpEndpoint = Constants.CARETAKER_RESEND_OTP;
    try {
      Uri resendOtpUri = Uri.parse(resendOtpEndpoint);
      final response = await SafeHttp.post(
        resendOtpUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Caretaker Resend OTP status code");
      log(response.body.toString(), name: "Caretaker Resend OTP response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker resend OTP");
      throw Exception(e.toString());
    }
  }

  // Set new password
  Future<Map<String, dynamic>> setNewPassword(
      String email, String newPassword) async {
    String newPasswordEndpoint = Constants.CARETAKER_NEW_PASSWORD;
    try {
      Uri newPasswordUri = Uri.parse(newPasswordEndpoint);
      final response = await SafeHttp.post(
        newPasswordUri,
        body: {
          'email': email,
          'new_password': newPassword,
        },
      );

      log(response.statusCode.toString(),
          name: "Caretaker New Password status code");
      log(response.body.toString(), name: "Caretaker New Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from caretaker new password");
      throw Exception(e.toString());
    }
  }

  // Setters for profile data
  void setEmail(String newEmail) {
    email = newEmail;
  }

  void setFirstName(String newFirstName) {
    firstName = newFirstName;
  }

  void setLastName(String newLastName) {
    lastName = newLastName;
  }
}
