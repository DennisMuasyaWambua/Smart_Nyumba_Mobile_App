// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_nyumba/Constants/Constants.dart';
import 'package:smart_nyumba/Models/all_transactions.dart';
import 'package:smart_nyumba/Models/pay_service_charge.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/Providers/shared_preference_builder.dart';
import 'package:smart_nyumba/Providers/tenants_profile_provider.dart';

class Payments with ChangeNotifier {
  // all payments are handled here

  final String baseurl = "https://smartnyumba.com/apps/user/api/v1/";
  final int _serviceChargeAmount = 0;

  int get serviceChargeAmount => _serviceChargeAmount;
  var userId;

  String? token = SharedPrefrenceBuilder().getUserToken;

  //payment of serviceCharge
  Future<PayServiceCharge> payServiceCharge(
      String mobileNumber, amount, serviceName) async {
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
        'mobile_number': mobileNumber,
        'amount': amount,
        'service_name': serviceName,
        'pay_via': 'mpesa'
      });

      log(response.body.toString(), name: "SERVICE CHARGE PAYMENT MESSAGE");

      PayServiceCharge service =
          PayServiceCharge.fromJson(json.decode(response.body));
      // getting users ID
      var appUser = TenantsProfile().getUserProfile(token!);

      appUser.then((value) async {
        userId = value.user!.id;
        log(userId.toString(), name: "US ID");
         // wait ten seconds for the transaction to complete
          Future.delayed(const Duration(seconds: 30));

        if (service.status == true) {
          // checking if the transaction was successful
          var check =
              await http.get(Uri.parse(Constants.ALL_TRANSITIONS), headers: {
            'Authorization': 'Bearer $token',
          });

         

          AllTransactions transactions =
              AllTransactions.fromJson(json.decode(check.body));

          List<Transaction> customerTransaction =
              transactions.transactions!.toList();
          log(customerTransaction.toString(), name: "CUSTOMER TRANSACTIONS");
          for (int i = 0; i < customerTransaction.length; i++) {
            var usr = customerTransaction[i].user;
            var status = customerTransaction[i].status;
            if (userId == usr && status == 1) {
              log(customerTransaction[i].checkoutRequestId.toString(),
                  name: "TRANSACTION COMPLETED");
            } else {
              log("TRANSACTION FAILED", name: "TRANSACTION FAILED");
            }
          }

          // var confirm = customerTransaction.user;
          // var status = customerTransaction.status;
          // log(confirm.toString(), name: "CUSTOMER ID");
          // log(status.toString(), name: "STATUS ID");
        }
      });

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
