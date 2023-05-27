import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_nyumba/Models/login_response_message.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/Models/register_response_message.dart';
import 'dart:convert';

import 'package:smart_nyumba/Tenant/tenantDashboard.dart';

import '../Constants/Constants.dart';

class Auth {
  Future<LoginResponseMessage> login(String email, password) async {
    String loginEndpoint = "${Constants.USER_BASEURL}/auth/user-login/";

    try {
      final response = await http.post(Uri.parse(loginEndpoint),
          body: {'email': email, 'password': password});
      log(response.statusCode.toString(), name: "Status code");
      LoginResponseMessage loginResponseMessage =
          LoginResponseMessage.fromJson(jsonDecode(response.body));
      // print(loginResponseMessage.message);
      log(loginResponseMessage.message.toString(),
          name: "Response message from login");
      if (loginResponseMessage.status == true) {
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
      log(e.toString(), name: "Exception message from login");
      throw Exception(e.toString());
    }
  }

  Future<RegisterResponse> register(String email, firstName, lastName, idNumber,
      blockNumber, houseNumber, mobileNumber, password) async {
    String registerEndpoint = "${Constants.USER_BASEURL}/auth/user-register";
    try {
      Uri register = Uri.parse(registerEndpoint);
      final response = await http.post(register, body: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'blockNumber': blockNumber
      });
      RegisterResponse registerResponse =
          RegisterResponse.fromJson(jsonDecode(response.body));

      if (registerResponse.status == true) {
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
}
