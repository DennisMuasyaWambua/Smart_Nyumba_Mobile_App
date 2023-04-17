import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:smart_nyumba/Models/login_response_message.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth with ChangeNotifier{
  Future<LoginResponseMessage> login(String email, password) async {
    const headers = {
      'Content-Type': 'application/json',
    };
    String loginEndpoint =
        "https://98c6-41-80-115-25.ngrok-free.app/apps/api/v1/user/auth/user-login/";

    try {
      final response =
      await http.post(Uri.parse(loginEndpoint),body: {'email':email,'password':password});
      log(response.statusCode.toString(),name: "Status code");
      LoginResponseMessage loginResponseMessage =
      LoginResponseMessage.fromJson(jsonDecode(response.body));
      // print(loginResponseMessage.message);
      log(loginResponseMessage.message.toString(), name: "Response message from login");
      if (loginResponseMessage.status == true) {
        log(loginResponseMessage.status.toString(), name: "Status");
        log(loginResponseMessage.message.toString(), name: "Success message");
        // print(loginResponseMessage.message);
        return loginResponseMessage;
      } else {
        log(loginResponseMessage.status.toString(), name: "Status");
        log(loginResponseMessage.message.toString(), name: "Error message");
        // print(loginResponseMessage.message);
        return LoginResponseMessage(message: "An error occurred", status: false);
      }
    } catch (e) {
      log(e.toString(), name: "Exception message from login");
      throw Exception(e.toString());
    }
    notifyListeners();
  }
}
