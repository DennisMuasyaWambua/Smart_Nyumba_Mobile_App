import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_nyumba/utils/constants/constants.dart';
import 'package:smart_nyumba/utils/models/all_tenants.dart';
import 'package:smart_nyumba/utils/providers/shared_preference_builder.dart';

class Tenancy with ChangeNotifier {
  Future getAllTenants() async {
    var token = SharedPrefrenceBuilder.getUserToken;
    var allTenantsEndpoint = Constants.ALL_TENANTS_URL;

    final response = await http.get(Uri.parse(allTenantsEndpoint), headers: {
      'Authorization': 'Bearer $token',
    });
    log(response.body.toString(), name: "ALL TENANTS RESPONSE");
    AllTenants tenants = AllTenants.fromJson(jsonDecode(response.body));
    log(tenants.tenant.toString(), name: "ALL_TENANTS");
    var alltenants = tenants.tenant;
    notifyListeners();
    return alltenants;
  }
}
