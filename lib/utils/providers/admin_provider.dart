import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/utils/providers/_providers.dart';
import '../constants/constants.dart';

class AdminController with ChangeNotifier {
  late Map<String, dynamic>? _rawTenantsData;
  List<dynamic> tenantData = [];

   fetchTenants() async {
    String tenantEndpoint = Constants.ADMIN_FETCH_TENANTS;
    Map<String, String> headers = {
      "Authorization": "Bearer ${SharedPrefrenceBuilder.getUserToken}",
    };
    log(SharedPrefrenceBuilder.getUserToken.toString(), name: "ADMIN_TOKEN");

    try {
      var uri = Uri.parse(tenantEndpoint);
      final response = await http.get(uri, headers: headers);
      // log(response.body.toString(), name: "ADMIN CONTROLLER");

      _rawTenantsData = json.decode(response.body);
      _rawTenantsData != null
          ? (tenantData = _rawTenantsData!["tenant"])
          : null;

      log(_rawTenantsData!["tenant"].toString(), name: "ADMIN DATA");

      // Keys in tenantData are: id, email, name, id_number, is_active, user, PropertyBlock

      notifyListeners();
    } catch (e) {
      log("${Exception(e.toString())}", name: "Tenants Data Error");
      throw Exception(e.toString());
    }
  }
}
