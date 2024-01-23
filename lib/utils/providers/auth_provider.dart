import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/alerts.dart';
import '../constants/constants.dart';
import '../models/login_response_message.dart';
import '../models/register_response_message.dart';
import '../models/send_otp.dart';
import '../models/user_profile.dart';
import '../providers/shared_preference_builder.dart';

class Auth with ChangeNotifier {
  late String? firstName, lastName, email, houseNumber;
  late int? blockNumber;
  late User? user;

  late String authToken;

  String get token => authToken;
  String get lName => lastName!;
  String get mail => email!;
  String get fname => firstName!;
  int get blkNo => blockNumber!;
  String get hseNo => houseNumber!;

  void setToken(String newToken) {
    authToken = newToken;
    notifyListeners();
  }

  void setLastName(String lName) {
    lastName = lName;
    notifyListeners();
  }

  void setEmail(String mail) {
    email = mail;
    notifyListeners();
  }

  void setUsersData(User usr) {
    user = usr;
    notifyListeners();
  }

  void setFirstName(String fName) {
    firstName = fName;
    notifyListeners();
  }

  void setBlockNumber(int blockNo) {
    blockNumber = blockNo;
    notifyListeners();
  }

  void setHouseNumber(String hseNo) {
    houseNumber = hseNo;
    notifyListeners();
  }

  late LoginResponseMessage loginResponseMessage;

  // log in method
  Future<LoginResponseMessage> login(String email, password, BuildContext context) async {
    String loginEndpoint = Constants.LOGIN_URL;
    // log(loginEndpoint.toString(), name: "LOGIN URL");
    // log("${email.toString()}, ${password.toString()}", name: "PARAMETERS BEING  USED");
    // debugPrint(loginEndpoint);

    try {
      var uri = Uri.parse(loginEndpoint);
      final response = await http.post(uri, body: {'email': email, 'password': password});
      // log(uri.toString(), name: "LOGIN URL");
      // debugPrint(response.body);
      // log(response.body.toString(), name: " RESPONSE");
      // log(response.statusCode.toString(), name: "Status code");
      loginResponseMessage = LoginResponseMessage.fromJson(json.decode(response.body));
      log(loginResponseMessage.message.toString(), name: "Response message from login");
      // Saving the token from logging in

      // SharedPrefrenceBuilder.setUserToken(loginResponseMessage.accessToken!);
      if (loginResponseMessage.accessToken != null) {
        SharedPrefrenceBuilder.setUserToken(loginResponseMessage.accessToken!);
        setToken(loginResponseMessage.accessToken!);
        SharedPrefrenceBuilder.setExpirationTime(
          DateTime.now().add(const Duration(hours: 1)),
        );
        // log(SharedPrefrenceBuilder.getExpirationTime!, name: "Token Expiration Time");
        // log(loginResponseMessage.status.toString(), name: "Status");
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) => Alert().alert(
        //     loginResponseMessage.message.toString(),
        //   ),
        // );
        // log(loginResponseMessage.message.toString(), name: "Success message");
        notifyListeners();
        return loginResponseMessage;
      } else {
        // log(loginResponseMessage.status.toString(), name: "Status");
        // log(loginResponseMessage.message.toString(), name: "Error message");
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) =>
        //         Alert().alert(loginResponseMessage.message.toString()));
        // print(loginResponseMessage.message);
        if (loginResponseMessage.message == "Invalid data provided") {
          return LoginResponseMessage(status: false, message: "Enter a valid email address");
        } else if (loginResponseMessage.message == "Please provide correct username or password") {
          return LoginResponseMessage(status: false, message: "Invalid username or password");
        } else if (loginResponseMessage.message == "user does not exist") {
          return LoginResponseMessage(status: false, message: "User does not exist");
        }
        return loginResponseMessage;
      }
    } catch (e) {
      log("${Exception(e.toString())}", name: "Exception message from login");
      throw Exception(e.toString());
    }
  }

  // register method
  Future<RegisterResponse> register(String email, firstName, lastName, idNumber, blockNumber,
      houseNumber, mobileNumber, password, BuildContext context) async {
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
      RegisterResponse registerResponse = RegisterResponse.fromJson(jsonDecode(response.body));

      if (registerResponse.status = true) {
        showDialog(
            context: context,
            builder: (BuildContext context) => Alert().alert(registerResponse.message.toString()));
        return registerResponse;
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => Alert().alert(registerResponse.message.toString()));
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

      final verifyOtp = await http.post(otpVerification, body: {"email": email, "otp": otp});

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

  //get the users profile
  Future<UserProfile> getProfile(String token, BuildContext context) async {
    try {
      String userProfileUrl = Constants.USER_PROFILE;
      Uri uri = Uri.parse(userProfileUrl);
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });
      log(token.toString(), name: "USER TOKEN");
      log(response.body.toString(), name: "USER PROFILE RESPONSE");
      UserProfile user = UserProfile.fromJson(jsonDecode(response.body));
      log(user.toJson().toString(), name: "USER PROFILE");
      firstName = user.profile!.user!.firstName;
      lastName = user.profile!.user!.lastName;
      email = user.profile!.user!.email;
      houseNumber = user.profile!.propertyBlock!.houseNumber;
      blockNumber = user.profile!.propertyBlock!.block;

      setEmail(email!);
      setFirstName(firstName!);
      setLastName(lastName!);
      setHouseNumber(houseNumber!);
      setBlockNumber(blockNumber!);

      notifyListeners();
      return user;
    } catch (e) {
      log(e.toString(), name: "ERROR FROM GETTING USER PROFILE");
      throw e.toString();
    }
  }
}
