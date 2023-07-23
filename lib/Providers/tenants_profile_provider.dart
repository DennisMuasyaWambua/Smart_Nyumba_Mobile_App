import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Models/user_profile.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class TenantsProfile with ChangeNotifier {
  UserProfile profile = UserProfile();

  UserProfile get user => profile;

  Future<Profile> getUserProfile(String token) async {
    //user profile endpoint
    String profileEndpoint = Constants.TENANTS_PROFILE;

    try {
      // headers
      Map<String, String> headers = {
        "Authorization": "Bearer $token",
      };
      var response =
          await http.get(Uri.parse(profileEndpoint), headers: headers);
      log(response.body.toString(), name: "USER profile");

      UserProfile data = UserProfile.fromJson(json.decode(response.body));
      Profile appUser = data.profile as Profile;
      log(data.profile.toString(), name: "USER PROFILE");
      notifyListeners();
      return appUser;
    } catch (e) {
      throw e.toString();
    }
  }
}
