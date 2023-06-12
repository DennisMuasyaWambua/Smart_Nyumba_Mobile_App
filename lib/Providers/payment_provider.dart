import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_nyumba/Models/pay_service_charge.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';

class Payments with ChangeNotifier {
  // all payments are handled here

  final String baseurl = "https://smartnyumba.com/apps/user/api/v1/";
  int _serviceChargeAmount = 0;

  int get serviceChargeAmount => _serviceChargeAmount;

  String? token = SharedPrefrenceBuilder().getUserToken;

  //payment of serviceCharge
  Future<PayServiceCharge> payServiceCharge(
      String mobile_number, amount, service_name) async {
    String serviceChargeEndpoint = "services/pay-service/";
    // getting the users email address
    String userEmail = SharedPrefrenceBuilder().getUserEmail!;

    log(userEmail.toString(), name: "USER_EMAIL FROM SHARED_PREFERENCES");
    try {
      Uri servicecharge = Uri.parse(baseurl + serviceChargeEndpoint);
      var response = await http.post(servicecharge, headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'email': userEmail,
        'mobile_number': mobile_number,
        'amount': amount,
        'service_name': service_name,
        'pay_via': 'mpesa'
      });

      log(response.body.toString(), name: "SERVICE CHARGE PAYMENT MESSAGE");

      PayServiceCharge service =
          PayServiceCharge.fromJson(json.decode(response.body));

      log(service.status.toString(),
          name: "PAYMENT WAS INITIATED AND THIS IS THE STATUS BACK");
      log(service.message.toString(),
          name: "PAYMENT WAS INITIATED AND THIS IS THE RESPONSE BACK");
      notifyListeners();
      return service;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
