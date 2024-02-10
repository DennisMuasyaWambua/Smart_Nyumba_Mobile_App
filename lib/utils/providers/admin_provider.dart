import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/utils/providers/_providers.dart';
import '../constants/constants.dart';

class AdminController with ChangeNotifier {
  late Map<String, dynamic>? _rawTenantsData;
  List<dynamic> tenantData = [];

  void fetchTenants() async {
    String tenantEndpoint = Constants.ADMIN_FETCH_TENANTS;
    Map<String, String> headers = {
      "Authorization": "Bearer ${SharedPrefrenceBuilder.getUserToken}",
    };

    try {
      var uri = Uri.parse(tenantEndpoint);
      final response = await http.get(uri, headers: headers);

      _rawTenantsData = json.decode(response.body);
      _rawTenantsData ?? (tenantData = _rawTenantsData!["tenant"]);

      // Keys in tenantData are: id, email, name, id_number, is_active, user, PropertyBlock

      notifyListeners();
    } catch (e) {
      log("${Exception(e.toString())}", name: "Tenants Data Error");
      throw Exception(e.toString());
    }
  }
}
