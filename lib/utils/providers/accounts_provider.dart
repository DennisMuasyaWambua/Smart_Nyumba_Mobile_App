import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';

import '../constants/constants.dart';
import '../models/accounts_login_response.dart';
import '../models/accounts_profile.dart';
import '../models/all_payments.dart';
import 'shared_preference_builder.dart';

class AccountsProvider {
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  String? idNumber;

  // Login method
  Future<AccountsLoginResponse> login(
      String email, String password, BuildContext context) async {
    String loginEndpoint = Constants.ACCOUNTS_LOGIN_URL;
    try {
      Uri loginUri = Uri.parse(loginEndpoint);
      final response = await SafeHttp.post(
        loginUri,
        body: {
          'email': email,
          'password': password,
        },
      );

      log(response.statusCode.toString(), name: "Accounts Login status code");
      log(response.body.toString(), name: "Accounts Login response");

      AccountsLoginResponse loginResponse =
          AccountsLoginResponse.fromJson(jsonDecode(response.body));

      // Save token if login successful
      if (loginResponse.status == true && loginResponse.tokens?.access != null) {
        SharedPrefrenceBuilder.setUserToken(loginResponse.tokens!.access!);
        log(loginResponse.tokens!.access!, name: "Accounts Token saved");
      }

      return loginResponse;
    } catch (e) {
      log(e.toString(), name: "Exception from accounts login");
      throw Exception(e.toString());
    }
  }

  // Logout method
  Future<bool> logout(BuildContext context) async {
    String logoutEndpoint = Constants.ACCOUNTS_LOGOUT_URL;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        log("No token found", name: "Accounts Logout");
        return false;
      }

      Uri logoutUri = Uri.parse(logoutEndpoint);
      final response = await SafeHttp.post(
        logoutUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Accounts Logout status code");
      log(response.body.toString(), name: "Accounts Logout response");

      if (response.statusCode == 200) {
        SharedPrefrenceBuilder.clearInvalidToken();
        return true;
      }
      return false;
    } catch (e) {
      log(e.toString(), name: "Exception from accounts logout");
      return false;
    }
  }

  // Get accounts profile
  Future<AccountsProfile> getProfile(String token, BuildContext context) async {
    try {
      String profileUrl = Constants.ACCOUNTS_PROFILE_URL;
      Uri uri = Uri.parse(profileUrl);
      final response = await SafeHttp.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      log(token.toString(), name: "ACCOUNTS TOKEN");
      log(response.body.toString(), name: "ACCOUNTS PROFILE RESPONSE");

      AccountsProfile profile =
          AccountsProfile.fromJson(jsonDecode(response.body));

      // Store profile data locally
      if (profile.profile != null) {
        firstName = profile.profile!.user?.firstName;
        lastName = profile.profile!.user?.lastName;
        email = profile.profile!.user?.email;
        mobileNumber = profile.profile!.user?.mobileNumber;
        idNumber = profile.profile!.accounts?.idNumber;

        setEmail(email!);
        setFirstName(firstName!);
        setLastName(lastName!);
      }

      return profile;
    } catch (e) {
      log(e.toString(), name: "Exception from accounts profile");
      throw Exception(e.toString());
    }
  }

  // Get all payments - this is the main function for accounts staff
  Future<AllPayments> getAllPayments(String token, BuildContext context) async {
    try {
      String paymentsUrl = Constants.ALL_PAYMENTS;
      Uri uri = Uri.parse(paymentsUrl);
      final response = await SafeHttp.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      log(response.statusCode.toString(), name: "GET ALL PAYMENTS STATUS");
      log(response.body.toString(), name: "ALL PAYMENTS RESPONSE");

      AllPayments payments = AllPayments.fromJson(jsonDecode(response.body));

      return payments;
    } catch (e) {
      log(e.toString(), name: "Exception from get all payments");
      throw Exception(e.toString());
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    String forgotPasswordEndpoint = Constants.ACCOUNTS_FORGOT_PASSWORD;
    try {
      Uri forgotPasswordUri = Uri.parse(forgotPasswordEndpoint);
      final response = await SafeHttp.post(
        forgotPasswordUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Accounts Forgot Password status code");
      log(response.body.toString(), name: "Accounts Forgot Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from accounts forgot password");
      throw Exception(e.toString());
    }
  }

  // Verify change password with OTP
  Future<Map<String, dynamic>> verifyChangePassword(
      String email, String otp) async {
    String verifyEndpoint = Constants.ACCOUNTS_VERIFY_CHANGE_PASSWORD;
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
          name: "Accounts Verify Change Password status code");
      log(response.body.toString(),
          name: "Accounts Verify Change Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(),
          name: "Exception from accounts verify change password");
      throw Exception(e.toString());
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    String resendOtpEndpoint = Constants.ACCOUNTS_RESEND_OTP;
    try {
      Uri resendOtpUri = Uri.parse(resendOtpEndpoint);
      final response = await SafeHttp.post(
        resendOtpUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Accounts Resend OTP status code");
      log(response.body.toString(), name: "Accounts Resend OTP response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from accounts resend OTP");
      throw Exception(e.toString());
    }
  }

  // Set new password
  Future<Map<String, dynamic>> setNewPassword(
      String email, String newPassword) async {
    String newPasswordEndpoint = Constants.ACCOUNTS_NEW_PASSWORD;
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
          name: "Accounts New Password status code");
      log(response.body.toString(), name: "Accounts New Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from accounts new password");
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
