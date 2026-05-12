import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/landlord_login_response.dart';
import '../models/landlord_profile.dart';
import '../models/landlord_property.dart';
import '../models/subordinate_create_response.dart';
import 'shared_preference_builder.dart';

class LandlordProvider {
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  String? idNumber;
  List<Property>? properties;

  // Login method
  Future<LandlordLoginResponse> login(
      String email, String password, BuildContext context) async {
    String loginEndpoint = Constants.LANDLORD_LOGIN_URL;
    try {
      Uri loginUri = Uri.parse(loginEndpoint);
      final response = await http.post(
        loginUri,
        body: {
          'email': email,
          'password': password,
        },
      );

      log(response.statusCode.toString(), name: "Landlord Login status code");
      log(response.body.toString(), name: "Landlord Login response");

      LandlordLoginResponse loginResponse =
          LandlordLoginResponse.fromJson(jsonDecode(response.body));

      // Save token if login successful
      if (loginResponse.status == true && loginResponse.tokens?.access != null) {
        SharedPrefrenceBuilder.setUserToken(loginResponse.tokens!.access!);
        log(loginResponse.tokens!.access!, name: "Landlord Token saved");
      }

      return loginResponse;
    } catch (e) {
      log(e.toString(), name: "Exception from landlord login");
      throw Exception(e.toString());
    }
  }

  // Logout method
  Future<bool> logout(BuildContext context) async {
    String logoutEndpoint = Constants.LANDLORD_LOGOUT_URL;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        log("No token found", name: "Landlord Logout");
        return false;
      }

      Uri logoutUri = Uri.parse(logoutEndpoint);
      final response = await http.post(
        logoutUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Landlord Logout status code");
      log(response.body.toString(), name: "Landlord Logout response");

      if (response.statusCode == 200) {
        SharedPrefrenceBuilder.clearInvalidToken();
        return true;
      }
      return false;
    } catch (e) {
      log(e.toString(), name: "Exception from landlord logout");
      return false;
    }
  }

  // Get landlord profile
  Future<LandlordProfile> getProfile(String token, BuildContext context) async {
    try {
      String profileUrl = Constants.LANDLORD_PROFILE_URL;
      Uri uri = Uri.parse(profileUrl);
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      log(token.toString(), name: "LANDLORD TOKEN");
      log(response.body.toString(), name: "LANDLORD PROFILE RESPONSE");

      LandlordProfile profile =
          LandlordProfile.fromJson(jsonDecode(response.body));

      // Store profile data locally
      if (profile.profile != null) {
        firstName = profile.profile!.user?.firstName;
        lastName = profile.profile!.user?.lastName;
        email = profile.profile!.user?.email;
        mobileNumber = profile.profile!.user?.mobileNumber;
        idNumber = profile.profile!.landlord?.idNumber;
        properties = profile.profile!.properties;

        setEmail(email!);
        setFirstName(firstName!);
        setLastName(lastName!);
      }

      return profile;
    } catch (e) {
      log(e.toString(), name: "Exception from landlord profile");
      throw Exception(e.toString());
    }
  }

  // Add house to property block
  Future<AddHouseResponse> addHouse(
    String block,
    String houseNumber,
    String serviceCharge,
    String rentCharged,
    BuildContext context,
  ) async {
    String addHouseEndpoint = Constants.ADD_HOUSE_URL;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      Uri addHouseUri = Uri.parse(addHouseEndpoint);
      final response = await http.post(
        addHouseUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'block': block,
          'house_number': houseNumber,
          'service_charge': serviceCharge,
          'rent_charged': rentCharged,
        },
      );

      log(response.statusCode.toString(), name: "Add House status code");
      log(response.body.toString(), name: "Add House response");

      AddHouseResponse addHouseResponse =
          AddHouseResponse.fromJson(jsonDecode(response.body));

      return addHouseResponse;
    } catch (e) {
      log(e.toString(), name: "Exception from add house");
      throw Exception(e.toString());
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    String forgotPasswordEndpoint = Constants.LANDLORD_FORGOT_PASSWORD;
    try {
      Uri forgotPasswordUri = Uri.parse(forgotPasswordEndpoint);
      final response = await http.post(
        forgotPasswordUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Landlord Forgot Password status code");
      log(response.body.toString(), name: "Landlord Forgot Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from landlord forgot password");
      throw Exception(e.toString());
    }
  }

  // Verify change password with OTP
  Future<Map<String, dynamic>> verifyChangePassword(
      String email, String otp) async {
    String verifyEndpoint = Constants.LANDLORD_VERIFY_CHANGE_PASSWORD;
    try {
      Uri verifyUri = Uri.parse(verifyEndpoint);
      final response = await http.post(
        verifyUri,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      log(response.statusCode.toString(),
          name: "Landlord Verify Change Password status code");
      log(response.body.toString(),
          name: "Landlord Verify Change Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(),
          name: "Exception from landlord verify change password");
      throw Exception(e.toString());
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    String resendOtpEndpoint = Constants.LANDLORD_RESEND_OTP;
    try {
      Uri resendOtpUri = Uri.parse(resendOtpEndpoint);
      final response = await http.post(
        resendOtpUri,
        body: {'email': email},
      );

      log(response.statusCode.toString(),
          name: "Landlord Resend OTP status code");
      log(response.body.toString(), name: "Landlord Resend OTP response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from landlord resend OTP");
      throw Exception(e.toString());
    }
  }

  // Set new password
  Future<Map<String, dynamic>> setNewPassword(
      String email, String newPassword) async {
    String newPasswordEndpoint = Constants.LANDLORD_NEW_PASSWORD;
    try {
      Uri newPasswordUri = Uri.parse(newPasswordEndpoint);
      final response = await http.post(
        newPasswordUri,
        body: {
          'email': email,
          'new_password': newPassword,
        },
      );

      log(response.statusCode.toString(),
          name: "Landlord New Password status code");
      log(response.body.toString(), name: "Landlord New Password response");

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString(), name: "Exception from landlord new password");
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

  // Register subordinate (accountant or caretaker) by landlord
  Future<SubordinateCreateResponse> registerSubordinate(
    String email,
    String firstName,
    String lastName,
    String idNumber,
    String mobileNumber,
    String role, // "accounts" or "caretaker"
    BuildContext context,
  ) async {
    String endpoint = Constants.LANDLORD_CREATE_SUBORDINATE;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Prepare JSON body
      Map<String, dynamic> requestBody = {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobileNumber,
        'id_number': idNumber,
        'role': role,
      };

      log(jsonEncode(requestBody), name: "Register Subordinate request body");

      Uri uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      log(response.statusCode.toString(), name: "Register Subordinate status code");
      log(response.body.toString(), name: "Register Subordinate response");

      SubordinateCreateResponse subordinateResponse =
          SubordinateCreateResponse.fromJson(jsonDecode(response.body));

      return subordinateResponse;
    } catch (e) {
      log(e.toString(), name: "Exception from register subordinate");
      throw Exception(e.toString());
    }
  }

  // Get financial summary data for landlord dashboard
  Future<Map<String, dynamic>> getFinancialSummary({
    String period = 'all', // all, month, year
    int? year,
    int? month,
  }) async {
    String endpoint = Constants.LANDLORD_FINANCIAL_SUMMARY;
    try {
      String? token = SharedPrefrenceBuilder.getUserToken;
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Build query parameters
      Map<String, String> queryParams = {'period': period};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();

      Uri uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      log(response.statusCode.toString(), name: "Financial Summary status code");
      log(response.body.toString(), name: "Financial Summary response");

      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch financial data');
      }
    } catch (e) {
      log(e.toString(), name: "Exception from financial summary");
      throw Exception(e.toString());
    }
  }
}
