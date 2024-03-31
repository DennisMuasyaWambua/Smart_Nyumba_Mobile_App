import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:smart_nyumba/utils/constants/constants.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';
import 'package:http/http.dart' as http;

class AllTransactions with ChangeNotifier {
  late Map<String, dynamic>? _estatePayments;
  List<dynamic> tenantData = [];

  fetchEstatePayments() async {
    String allPayments = Constants.ALL_PAYMENTS;

    Map<String, String> headers = {
      "Authorization": "Bearer ${SharedPrefrenceBuilder.getUserToken}",
    };

    var allPaymentsUri = Uri.parse(allPayments);
    final response = await http.get(allPaymentsUri, headers: headers);

    _estatePayments = json.decode(response.body);
    log(_estatePayments.toString(), name: "ALL_ESTATE_TRANSACTIONS_DECODED");
    _estatePayments != null
        ? (tenantData = _estatePayments!["transactions"])
        : null;

    notifyListeners();
  }
}
