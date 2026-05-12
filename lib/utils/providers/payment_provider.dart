// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/activation_payment_response.dart';
import '../models/activation_status.dart';
import '../models/all_transactions.dart';
import '../models/check_payment_status.dart';
import '../models/pay_service_charge.dart';
import './shared_preference_builder.dart';

class Payments with ChangeNotifier {
  // all payments are handled here

  final String baseurl =
      "https://er9yqpmri4.execute-api.eu-west-1.amazonaws.com/dev/apps/user/api/v1/";
  final int _serviceChargeAmount = 0;

  int get serviceChargeAmount => _serviceChargeAmount;
  var userId;
  int paymentStatus = 0;
  String? token = SharedPrefrenceBuilder.getUserToken;

  //payment of serviceCharge
  Future<PayServiceCharge> payServiceCharge(
      String mobileNumber, String amount, String serviceName) async {
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

    PayServiceCharge service = PayServiceCharge.fromJson(json.decode(response.body));
    // getting users ID

    log(service.status.toString(), name: "PAYMENT WAS INITIATED AND THIS IS THE STATUS BACK");
    log(service.message.toString(), name: "PAYMENT WAS INITIATED AND THIS IS THE RESPONSE BACK");
    notifyListeners();
    return service;
  }

  Future<int?> checkPaymentStatus() async {
    try {
      String userEmail = SharedPrefrenceBuilder.getUserEmail!;
      var check = await http.post(Uri.parse(Constants.CHECK_PAYMENT_COMPLETION), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'email': userEmail
      });
      log(check.body.toString(), name: "THIS IS THE CHECK PAYMENT RESPONSE");

      CheckPaymentStatus pStatus = CheckPaymentStatus.fromJson(jsonDecode(check.body));
      paymentStatus = pStatus.data!.status!;

      log(pStatus.status.toString(), name: "PAYMENT_STATUS");
      log(pStatus.message.toString(), name: "PAYMENT_MESSAGE");
      log(pStatus.data.toString(),
          name: "****************ALL TRANSACTIONS THAT ARE AVAILABLE***************");
      notifyListeners();
      return paymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK PAYMENT ERROR");
      throw e.toString();
    }
  }

  // Payment of rent with commission deduction
  Future<PayServiceCharge> payRent(
      String mobileNumber, String amount, BuildContext context) async {
    String userEmail = SharedPrefrenceBuilder.getUserEmail!;

    log(userEmail.toString(), name: "USER_EMAIL FROM SHARED_PREFERENCES");
    log(amount.toString(), name: "RENT AMOUNT TO BE PAID");

    // Calculate commission (deducted from rent, not added)
    double rentAmount = double.parse(amount);
    double commission = rentAmount * (Constants.COMMISSION_RATE / 100);
    double landlordAmount = rentAmount - commission;

    log(commission.toString(), name: "COMMISSION AMOUNT (${Constants.COMMISSION_RATE}%) - GOES TO PLATFORM");
    log(landlordAmount.toString(), name: "LANDLORD AMOUNT - GOES TO LANDLORD");

    Uri payRentUri = Uri.parse(Constants.PAY_RENT);
    var response = await http.post(payRentUri, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'email': userEmail,
      'mobile_number': mobileNumber,
      'rent_amount': amount,
      'commission': commission.toStringAsFixed(2),
      'landlord_amount': landlordAmount.toStringAsFixed(2),
      'pay_via': "mpesa"
    });

    log(response.body.toString(), name: "RENT PAYMENT MESSAGE");

    PayServiceCharge rentPayment = PayServiceCharge.fromJson(json.decode(response.body));

    log(rentPayment.status.toString(), name: "RENT PAYMENT INITIATED STATUS");
    log(rentPayment.message.toString(), name: "RENT PAYMENT RESPONSE MESSAGE");

    notifyListeners();
    return rentPayment;
  }

  // Check rent payment status
  Future<int?> checkRentPaymentStatus() async {
    try {
      String userEmail = SharedPrefrenceBuilder.getUserEmail!;
      var check = await http.post(Uri.parse(Constants.CHECK_RENT_PAYMENT_COMPLETION), headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'email': userEmail
      });

      log(check.body.toString(), name: "CHECK RENT PAYMENT RESPONSE");

      CheckPaymentStatus pStatus = CheckPaymentStatus.fromJson(jsonDecode(check.body));
      int rentPaymentStatus = pStatus.data!.status!;

      log(pStatus.status.toString(), name: "RENT_PAYMENT_STATUS");
      log(pStatus.message.toString(), name: "RENT_PAYMENT_MESSAGE");

      notifyListeners();
      return rentPaymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK RENT PAYMENT ERROR");
      throw e.toString();
    }
  }

  Stream<List<Transaction>?> getAllTransactions() async* {

      log(token!, name: "User Token");
      var allTransactions = await http.get(Uri.parse(Constants.ALL_TRANSACTIONS), headers: {
        'Authorization': 'Bearer $token',
      });
      log(allTransactions.body.toString(), name: "ALL TRANSACTIONS");
      AllTransactions all = AllTransactions.fromJson(jsonDecode(allTransactions.body));
      log(all.transactions.toString(), name: "TRANSACTIONS AVAILABLE");
      List<Transaction>? transactions = all.transactions;
      log(transactions.toString(), name: "TRANSACTIONS TO STREAM");

      notifyListeners();
      yield transactions;

  }

  // Initiate landlord activation payment via M-Pesa STK Push (OLD - Deprecated)
  Future<ActivationPaymentResponse> initiateActivationPayment(
      String email, String mobileNumber) async {
    log(email.toString(), name: "ACTIVATION PAYMENT EMAIL");
    log(mobileNumber.toString(), name: "ACTIVATION PAYMENT MOBILE");

    Uri activationPaymentUri = Uri.parse(Constants.INITIATE_ACTIVATION_PAYMENT);
    var response = await http.post(activationPaymentUri, body: {
      'email': email,
      'mobile_number': mobileNumber,
    });

    log(response.body.toString(), name: "ACTIVATION PAYMENT RESPONSE");

    ActivationPaymentResponse paymentResponse =
        ActivationPaymentResponse.fromJson(json.decode(response.body));

    log(paymentResponse.status.toString(), name: "ACTIVATION PAYMENT STATUS");
    log(paymentResponse.message.toString(), name: "ACTIVATION PAYMENT MESSAGE");

    notifyListeners();
    return paymentResponse;
  }

  // Initiate landlord activation payment via Pesapal (NEW)
  Future<ActivationPaymentResponse> initiateActivationPaymentPesapal({
    required String email,
    required String mobileNumber,
    String firstName = '',
    String lastName = '',
  }) async {
    log(email.toString(), name: "PESAPAL ACTIVATION EMAIL");
    log(mobileNumber.toString(), name: "PESAPAL ACTIVATION MOBILE");
    log(firstName.toString(), name: "PESAPAL ACTIVATION FIRSTNAME");
    log(lastName.toString(), name: "PESAPAL ACTIVATION LASTNAME");

    Uri activationPaymentUri = Uri.parse(Constants.INITIATE_ACTIVATION_PAYMENT);
    var response = await http.post(activationPaymentUri, body: {
      'email': email,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
    });

    log(response.body.toString(), name: "PESAPAL ACTIVATION RESPONSE");

    ActivationPaymentResponse paymentResponse =
        ActivationPaymentResponse.fromJson(json.decode(response.body));

    log(paymentResponse.status.toString(), name: "PESAPAL ACTIVATION STATUS");
    log(paymentResponse.message.toString(), name: "PESAPAL ACTIVATION MESSAGE");
    if (paymentResponse.data != null) {
      log(paymentResponse.data.toString(), name: "PESAPAL ACTIVATION DATA");
    }

    notifyListeners();
    return paymentResponse;
  }

  // Check landlord activation payment status (for polling)
  Future<int?> checkActivationPaymentStatus(String email) async {
    try {
      log(email.toString(), name: "CHECK ACTIVATION STATUS EMAIL");

      var check = await http.post(Uri.parse(Constants.CHECK_ACTIVATION_STATUS),
          body: {'email': email});

      log(check.body.toString(), name: "CHECK ACTIVATION STATUS RESPONSE");

      ActivationStatus activationStatus =
          ActivationStatus.fromJson(jsonDecode(check.body));

      log(activationStatus.activationStatus.toString(),
          name: "ACTIVATION_STATUS");
      log(activationStatus.message.toString(), name: "ACTIVATION_MESSAGE");

      notifyListeners();
      return activationStatus.activationStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK ACTIVATION STATUS ERROR");
      throw e.toString();
    }
  }
}
