import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../models/subscription.dart';
import './shared_preference_builder.dart';

class SubscriptionProvider with ChangeNotifier {
  String? get token => SharedPrefrenceBuilder.getUserToken;

  MySubscription? mySubscription;

  bool get isPremium => mySubscription?.isPremium ?? false;

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $token',
      };

  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      var response = await SafeHttp.get(Uri.parse(Constants.SUBSCRIPTION_PLANS),
          headers: _authHeaders);
      log(response.body.toString(), name: "SUBSCRIPTION PLANS");

      var data = json.decode(response.body);
      List<SubscriptionPlan> plans = (data['plans'] as List<dynamic>? ?? [])
          .map((p) => SubscriptionPlan.fromJson(p))
          .toList();
      return plans;
    } catch (e) {
      log(e.toString(), name: "SUBSCRIPTION PLANS ERROR");
      throw e.toString();
    }
  }

  Future<MySubscription?> fetchMySubscription() async {
    try {
      var response = await SafeHttp.get(Uri.parse(Constants.MY_SUBSCRIPTION),
          headers: _authHeaders);
      log(response.body.toString(), name: "MY SUBSCRIPTION");

      var data = json.decode(response.body);
      if (data['status'] == true && data['subscription'] != null) {
        mySubscription = MySubscription.fromJson(data['subscription']);
      } else {
        mySubscription = null;
      }
      notifyListeners();
      return mySubscription;
    } catch (e) {
      log(e.toString(), name: "MY SUBSCRIPTION ERROR");
      return null;
    }
  }

  Future<SubscriptionPaymentInit> initiatePayment(
      String tier, String phoneNumber) async {
    try {
      var response = await SafeHttp.post(
          Uri.parse(Constants.INITIATE_SUBSCRIPTION_PAYMENT),
          headers: _authHeaders,
          body: {
            'tier': tier,
            'phone_number': phoneNumber,
          });
      log(response.body.toString(), name: "INITIATE SUBSCRIPTION PAYMENT");

      return SubscriptionPaymentInit.fromJson(json.decode(response.body));
    } catch (e) {
      log(e.toString(), name: "INITIATE SUBSCRIPTION PAYMENT ERROR");
      throw e.toString();
    }
  }

  /// Returns 0 = pending, 1 = completed, 2 = failed (project convention).
  Future<int?> checkSubscriptionPaymentStatus(String orderId) async {
    try {
      var response = await SafeHttp.post(
          Uri.parse(Constants.CHECK_SUBSCRIPTION_PAYMENT_STATUS),
          headers: _authHeaders,
          body: {'order_id': orderId});
      log(response.body.toString(), name: "CHECK SUBSCRIPTION PAYMENT");

      var data = json.decode(response.body);
      int? paymentStatus = data['payment_status'];
      if (paymentStatus == 1) {
        await fetchMySubscription();
      }
      return paymentStatus;
    } catch (e) {
      log(e.toString(), name: "CHECK SUBSCRIPTION PAYMENT ERROR");
      throw e.toString();
    }
  }

  // ---- KRA eTIMS (PREMIUM) ----

  Future<EtimsDevice?> fetchDevice() async {
    try {
      var response = await SafeHttp.get(Uri.parse(Constants.ETIMS_DEVICE),
          headers: _authHeaders);
      log(response.body.toString(), name: "ETIMS DEVICE");

      var data = json.decode(response.body);
      if (data['device'] == null) return null;
      return EtimsDevice.fromJson(data['device']);
    } catch (e) {
      log(e.toString(), name: "ETIMS DEVICE ERROR");
      return null;
    }
  }

  Future<Map<String, dynamic>> initializeDevice(String kraPin,
      String deviceSerial, String taxMapping) async {
    try {
      var response = await SafeHttp.post(Uri.parse(Constants.ETIMS_DEVICE_INIT),
          headers: _authHeaders,
          body: {
            'kra_pin': kraPin,
            'device_serial': deviceSerial,
            'tax_mapping': taxMapping,
          });
      log(response.body.toString(), name: "ETIMS DEVICE INIT");
      return json.decode(response.body);
    } catch (e) {
      log(e.toString(), name: "ETIMS DEVICE INIT ERROR");
      throw e.toString();
    }
  }

  Future<List<EtimsInvoice>> fetchInvoices() async {
    try {
      var response = await SafeHttp.get(Uri.parse(Constants.ETIMS_INVOICES),
          headers: _authHeaders);
      log(response.body.toString(), name: "ETIMS INVOICES");

      var data = json.decode(response.body);
      return (data['invoices'] as List<dynamic>? ?? [])
          .map((i) => EtimsInvoice.fromJson(i))
          .toList();
    } catch (e) {
      log(e.toString(), name: "ETIMS INVOICES ERROR");
      throw e.toString();
    }
  }

  Future<bool> retryInvoice(int rentPaymentId) async {
    try {
      var response = await SafeHttp.post(Uri.parse(Constants.ETIMS_INVOICE_RETRY),
          headers: _authHeaders,
          body: {'rent_payment_id': rentPaymentId.toString()});
      log(response.body.toString(), name: "ETIMS INVOICE RETRY");
      return json.decode(response.body)['status'] == true;
    } catch (e) {
      log(e.toString(), name: "ETIMS INVOICE RETRY ERROR");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchWithholdingReport(int year) async {
    try {
      var response = await SafeHttp.get(
          Uri.parse('${Constants.ETIMS_WITHHOLDING_REPORT}?year=$year'),
          headers: _authHeaders);
      log(response.body.toString(), name: "WITHHOLDING REPORT");
      return json.decode(response.body);
    } catch (e) {
      log(e.toString(), name: "WITHHOLDING REPORT ERROR");
      throw e.toString();
    }
  }
}
