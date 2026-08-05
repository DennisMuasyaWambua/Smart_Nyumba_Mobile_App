// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import '../api/api_client.dart';

import '../constants/constants.dart';
import '../models/activation_payment_response.dart';
import '../models/activation_status.dart';
import '../models/all_transactions.dart';
import '../models/pay_service_charge.dart';
import '../models/rent_summary.dart';
import '../models/service_summary.dart';
import './shared_preference_builder.dart';

class Payments with ChangeNotifier {
  // all payments are handled here

  final String baseurl =
      "https://er9yqpmri4.execute-api.eu-west-1.amazonaws.com/dev/apps/user/api/v1/";
  final int _serviceChargeAmount = 0;

  int get serviceChargeAmount => _serviceChargeAmount;
  var userId;
  int paymentStatus = 0;
  String? get token => SharedPrefrenceBuilder.getUserToken;

  //payment of serviceCharge
  Future<PayServiceCharge> payServiceCharge(
      String mobileNumber, String amount, String serviceName) async {
    // String serviceChargeEndpoint = "services/pay-service/";
    // getting the users email address
    String userEmail = SharedPrefrenceBuilder.getUserEmail!;

    log(userEmail.toString(), name: "USER_EMAIL FROM SHARED_PREFERENCES");

    Uri servicecharge = Uri.parse(Constants.PAY_SERVICE);
    // Uri serviceAmt = Uri.parse(Constants.SERVICE_FEE_AMOUNT);
    // var serviceamt = await SafeHttp.get(serviceAmt,headers:{'Authorization': 'Bearer $token'});
    // log(serviceamt.body.toString(),name: "SERVICE AMOUNT");
    // Amount amt = Amount.fromJson(json.decode(serviceamt.body));
    // log(amount.toString(),name: "SERVICE AMOUNT");
    var response = await SafeHttp.post(servicecharge, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'email': userEmail,
      'mobile_number': mobileNumber,
      'service_name': serviceName,
      'pay_via': "pesapal"
    });

    log(response.body.toString(), name: "SERVICE CHARGE PAYMENT MESSAGE");

    PayServiceCharge service = PayServiceCharge.fromJson(json.decode(response.body));
    // getting users ID

    log(service.status.toString(), name: "PAYMENT WAS INITIATED AND THIS IS THE STATUS BACK");
    log(service.message.toString(), name: "PAYMENT WAS INITIATED AND THIS IS THE RESPONSE BACK");
    notifyListeners();
    return service;
  }

  Future<int?> checkPaymentStatus(String orderTrackingId) async {
    try {
      var check = await SafeHttp.post(
          Uri.parse(Constants.CHECK_PAYMENT_STATUS),
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: {
            'order_tracking_id': orderTrackingId,
            'transaction_type': 'service',
          });
      log(check.body.toString(), name: "THIS IS THE CHECK PAYMENT RESPONSE");

      // CheckPaymentStatusAPIView returns the transaction status at the top
      // level: {"transaction_id": .., "status": 0|1|2, ...}. It live-queries
      // Pesapal, so the value is authoritative without waiting for the IPN.
      final decoded = jsonDecode(check.body);
      final statusValue = decoded is Map ? decoded['status'] : null;
      paymentStatus = statusValue is int ? statusValue : 0;

      log(paymentStatus.toString(), name: "PAYMENT_STATUS");
      notifyListeners();
      return paymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK PAYMENT ERROR");
      throw e.toString();
    }
  }

  // Payment of rent
  Future<PayServiceCharge> payRent(
      String mobileNumber, String amount, BuildContext context) async {
    String userEmail = SharedPrefrenceBuilder.getUserEmail!;

    log(userEmail.toString(), name: "USER_EMAIL FROM SHARED_PREFERENCES");
    log(amount.toString(), name: "RENT AMOUNT TO BE PAID");

    // Get current month and year for rent payment
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    log("Month: $currentMonth, Year: $currentYear", name: "RENT PAYMENT DATE");

    Uri payRentUri = Uri.parse(Constants.PAY_RENT);
    var response = await SafeHttp.post(payRentUri, headers: {
      'Authorization': 'Bearer $token',
    }, body: {
      'email': userEmail,
      'mobile_number': mobileNumber,
      'month': currentMonth.toString(),
      'year': currentYear.toString(),
      'pay_via': "pesapal"
    });

    log(response.body.toString(), name: "RENT PAYMENT MESSAGE");

    PayServiceCharge rentPayment = PayServiceCharge.fromJson(json.decode(response.body));

    log(rentPayment.status.toString(), name: "RENT PAYMENT INITIATED STATUS");
    log(rentPayment.message.toString(), name: "RENT PAYMENT RESPONSE MESSAGE");

    notifyListeners();
    return rentPayment;
  }

  // Check rent payment status
  Future<int?> checkRentPaymentStatus(String orderTrackingId) async {
    try {
      var check = await SafeHttp.post(
          Uri.parse(Constants.CHECK_RENT_PAYMENT_COMPLETION),
          headers: {
            'Authorization': 'Bearer $token',
          },
          body: {
            'order_tracking_id': orderTrackingId,
            'transaction_type': 'rent',
          });

      log(check.body.toString(), name: "CHECK RENT PAYMENT RESPONSE");

      // CheckPaymentStatusAPIView returns the status at the top level and
      // live-queries Pesapal, so this reflects the true payment state.
      final decoded = jsonDecode(check.body);
      final statusValue = decoded is Map ? decoded['status'] : null;
      final int rentPaymentStatus = statusValue is int ? statusValue : 0;

      log(rentPaymentStatus.toString(), name: "RENT_PAYMENT_STATUS");

      notifyListeners();
      return rentPaymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK RENT PAYMENT ERROR");
      throw e.toString();
    }
  }

  Stream<List<Transaction>?> getAllTransactions() async* {
    try {
      log(token!, name: "User Token");
      var allTransactions = await SafeHttp.get(Uri.parse(Constants.ALL_TRANSACTIONS), headers: {
        'Authorization': 'Bearer $token',
      });
      log(allTransactions.body.toString(), name: "ALL TRANSACTIONS");

      AllTransactions all = AllTransactions.fromJson(jsonDecode(allTransactions.body));
      log(all.transactions.toString(), name: "TRANSACTIONS AVAILABLE");

      List<Transaction>? transactions = all.transactions;
      log(transactions.toString(), name: "TRANSACTIONS TO STREAM");

      notifyListeners();
      yield transactions;
    } catch (e, stackTrace) {
      log('Error in getAllTransactions: ${e.toString()}', name: "TRANSACTIONS ERROR");
      log('Stack trace: ${stackTrace.toString()}', name: "TRANSACTIONS ERROR STACK");

      // Yield empty list on error so UI doesn't hang
      yield [];
    }
  }

  // Initiate landlord activation payment via M-Pesa STK Push (OLD - Deprecated)
  Future<ActivationPaymentResponse> initiateActivationPayment(
      String email, String mobileNumber) async {
    log(email.toString(), name: "ACTIVATION PAYMENT EMAIL");
    log(mobileNumber.toString(), name: "ACTIVATION PAYMENT MOBILE");

    Uri activationPaymentUri = Uri.parse(Constants.INITIATE_ACTIVATION_PAYMENT);
    var response = await SafeHttp.post(activationPaymentUri, body: {
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
    var response = await SafeHttp.post(activationPaymentUri, body: {
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

      var check = await SafeHttp.post(Uri.parse(Constants.CHECK_ACTIVATION_STATUS),
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

  // Get monthly rent summary with balances
  Future<RentSummaryResponse> getMonthlyRentSummary() async {
    try {
      log(token!, name: "User Token");
      var response = await SafeHttp.get(
        Uri.parse(Constants.MONTHLY_RENT_SUMMARY),
        headers: {'Authorization': 'Bearer $token'},
      );

      log(response.body.toString(), name: "MONTHLY RENT SUMMARY RESPONSE");

      RentSummaryResponse rentSummary =
          RentSummaryResponse.fromJson(jsonDecode(response.body));

      log(rentSummary.status.toString(), name: "RENT SUMMARY STATUS");
      if (rentSummary.data != null) {
        log(rentSummary.data!.summaries.length.toString(),
            name: "NUMBER OF MONTHS");
      }

      notifyListeners();
      return rentSummary;
    } catch (e, stackTrace) {
      log('Error in getMonthlyRentSummary: ${e.toString()}',
          name: "RENT SUMMARY ERROR");
      log('Stack trace: ${stackTrace.toString()}',
          name: "RENT SUMMARY ERROR STACK");
      throw e.toString();
    }
  }

  // Get monthly service-charge summary with paid/unpaid months
  Future<ServiceSummaryResponse> getMonthlyServiceSummary() async {
    try {
      var response = await SafeHttp.get(
        Uri.parse(Constants.MONTHLY_SERVICE_SUMMARY),
        headers: {'Authorization': 'Bearer $token'},
      );

      log(response.body.toString(), name: "MONTHLY SERVICE SUMMARY RESPONSE");

      ServiceSummaryResponse serviceSummary =
          ServiceSummaryResponse.fromJson(jsonDecode(response.body));

      log(serviceSummary.status.toString(), name: "SERVICE SUMMARY STATUS");
      notifyListeners();
      return serviceSummary;
    } catch (e, stackTrace) {
      log('Error in getMonthlyServiceSummary: ${e.toString()}',
          name: "SERVICE SUMMARY ERROR");
      log('Stack trace: ${stackTrace.toString()}',
          name: "SERVICE SUMMARY ERROR STACK");
      throw e.toString();
    }
  }

  // Pay for multiple months of rent at once
  Future<PayServiceCharge> payMultiMonthRent(
      String mobileNumber, List<Map<String, int>> months) async {
    try {
      log(mobileNumber.toString(), name: "MULTI-MONTH MOBILE");
      log(months.toString(), name: "MONTHS TO PAY");

      Uri payMultiMonthUri = Uri.parse(Constants.PAY_MULTI_MONTH_RENT);
      var response = await SafeHttp.post(
        payMultiMonthUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile_number': mobileNumber,
          'months': months,
          'pay_via': 'pesapal'
        }),
      );

      log(response.body.toString(), name: "MULTI-MONTH RENT PAYMENT RESPONSE");

      PayServiceCharge rentPayment =
          PayServiceCharge.fromJson(json.decode(response.body));

      log(rentPayment.status.toString(),
          name: "MULTI-MONTH RENT PAYMENT STATUS");
      log(rentPayment.message.toString(),
          name: "MULTI-MONTH RENT PAYMENT MESSAGE");

      notifyListeners();
      return rentPayment;
    } catch (e) {
      log(e.toString(), name: "MULTI-MONTH RENT PAYMENT ERROR");
      throw e.toString();
    }
  }

  // Pay service charge for multiple months at once (advance or overdue)
  Future<PayServiceCharge> payMultiMonthService(
      String mobileNumber, List<Map<String, int>> months) async {
    try {
      var response = await SafeHttp.post(
        Uri.parse(Constants.PAY_MULTI_MONTH_SERVICE),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile_number': mobileNumber,
          'months': months,
          'pay_via': 'pesapal'
        }),
      );

      log(response.body.toString(), name: "MULTI-MONTH SERVICE PAYMENT RESPONSE");

      PayServiceCharge servicePayment =
          PayServiceCharge.fromJson(json.decode(response.body));

      notifyListeners();
      return servicePayment;
    } catch (e) {
      log(e.toString(), name: "MULTI-MONTH SERVICE PAYMENT ERROR");
      throw e.toString();
    }
  }
}
