// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/all_transactions.dart';
import '../models/check_payment_status.dart';
import '../models/pay_service_charge.dart';
import './shared_preference_builder.dart';

class Payments with ChangeNotifier {
  // all payments are handled here

  final String baseurl = "https://er9yqpmri4.execute-api.eu-west-1.amazonaws.com/dev/apps/user/api/v1/";
  final int _serviceChargeAmount = 0;

  int get serviceChargeAmount => _serviceChargeAmount;
  var userId;
  int paymentStatus = 0;
  String? token = SharedPrefrenceBuilder.getUserToken;

  //payment of serviceCharge
  Future<PayServiceCharge> payServiceCharge(String mobileNumber,String amount, String serviceName) async {
    // String serviceChargeEndpoint = "services/pay-service/";
    // getting the users email address
    String userEmail = SharedPrefrenceBuilder.getUserEmail!;

    log(userEmail.toString(), name: "USER_EMAIL FROM SHARED_PREFERENCES");

      Uri servicecharge = Uri.parse(Constants.PAY_SERVICE);
      // Uri serviceAmt = Uri.parse(Constants.SERVICE_FEE_AMOUNT);
      // var serviceamt = await http.get(serviceAmt,headers:{'Authorization': 'Bearer $token'});
      // log(serviceamt.body.toString(),name: "SERVICE AMOUNT");
      // Amount amt = Amount.fromJson(json.decode(serviceamt.body));
      // log(amount.toString(),name: "SERVICE AMOUNT");
      var response = await http.post(servicecharge, headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'email': userEmail,
        'mobile_number': mobileNumber,
        'service_name': serviceName,
        'pay_via': "mpesa"
      });

      log(response.body.toString(), name: "SERVICE CHARGE PAYMENT MESSAGE");

      PayServiceCharge service =
          PayServiceCharge.fromJson(json.decode(response.body));
      // getting users ID

      log(service.status.toString(),
          name: "PAYMENT WAS INITIATED AND THIS IS THE STATUS BACK");
      log(service.message.toString(),
          name: "PAYMENT WAS INITIATED AND THIS IS THE RESPONSE BACK");
      notifyListeners();
      return service;

  }

  Future<int?> checkPaymentStatus() async {
    try {
      String userEmail = SharedPrefrenceBuilder.getUserEmail!;
      var check = await http
          .post(Uri.parse(Constants.CHECK_PAYMENT_COMPLETION), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'email': userEmail
      });
      log(check.body.toString(), name: "THIS IS THE CHECK PAYMENT RESPONSE");

      CheckPaymentStatus pStatus =
          CheckPaymentStatus.fromJson(jsonDecode(check.body));
      paymentStatus = pStatus.data!.status!;

      log(pStatus.status.toString(), name: "PAYMENT_STATUS");
      log(pStatus.message.toString(), name: "PAYMENT_MESSAGE");
      log(pStatus.data.toString(),
          name:
              "****************ALL TRANSACTIONS THAT ARE AVAILABLE***************");
      notifyListeners();
      return paymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK PAYMENT ERROR");
      throw e.toString();
    }
  }

  Stream<List<Transaction>?>getAllTransactions() async* {
    try {
      var allTransactions =
          await http.get(Uri.parse(Constants.ALL_TRANSACTIONS), headers: {
        'Authorization': 'Bearer $token',
      });
      log(allTransactions.body.toString(), name: "ALL TRANSACTIONS");
      AllTransactions all =
          AllTransactions.fromJson(jsonDecode(allTransactions.body));
      log(all.transactions.toString(), name: "TRANSACTIONS AVAILABLE");
      List<Transaction>? transactions = all.transactions;
      
      notifyListeners();
      yield transactions;
    } catch (e) {
      throw e.toString();
    }
  }
}
