import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../models/repair.dart';

class RepairsProvider extends ChangeNotifier {
  List<Repair> _repairs = [];
  bool _isLoading = false;
  String? _error;

  List<Repair> get repairs => _repairs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Repair> get pendingRepairs =>
      _repairs.where((r) => r.status == 'pending').toList();
  List<Repair> get inProgressRepairs =>
      _repairs.where((r) => r.status == 'in_progress').toList();
  List<Repair> get completedRepairs =>
      _repairs.where((r) => r.status == 'completed').toList();

  /// Caretaker: load every repair request in the estate.
  Future<void> fetchAllRepairs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get(Constants.CARETAKER_ALL_REPAIRS);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _repairs = (data['repairs'] as List)
            .map((json) => Repair.fromJson(json))
            .toList();
      } else {
        _error = data['message'] ?? 'Could not load repair requests';
      }
    } catch (e) {
      log(e.toString(), name: 'RepairsProvider.fetchAllRepairs');
      _error = 'Could not load repair requests. Check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Caretaker: move a repair to a new status (pending -> in_progress -> completed).
  Future<String?> updateStatus(int repairId, String newStatus) async {
    try {
      final response = await ApiClient.post(
        Constants.UPDATE_REPAIR_STATUS,
        body: {
          'repair_id': repairId.toString(),
          'status': newStatus,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final index = _repairs.indexWhere((r) => r.id == repairId);
        if (index != -1) {
          _repairs[index] = _repairs[index].copyWith(status: newStatus);
          notifyListeners();
        }
        return null;
      }
      return data['message'] ?? 'Could not update repair status';
    } catch (e) {
      log(e.toString(), name: 'RepairsProvider.updateStatus');
      return 'Could not update repair status. Check your connection.';
    }
  }

  /// Tenant: submit a new repair request. Returns null on success or an
  /// error message on failure.
  Future<String?> submitRepair({
    required String email,
    required String brokenProperty,
    required String description,
    String? blockNumber,
    String? houseNumber,
  }) async {
    try {
      final response = await ApiClient.post(
        Constants.TENANT_REQUEST_REPAIR,
        body: {
          'email': email,
          'broken_property': brokenProperty,
          'description_broken_property': description,
          if (blockNumber != null) 'block_number': blockNumber,
          if (houseNumber != null) 'house_number': houseNumber,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return null;
      }
      return data['message'] ?? 'Could not submit repair request';
    } catch (e) {
      log(e.toString(), name: 'RepairsProvider.submitRepair');
      return 'Could not submit repair request. Check your connection.';
    }
  }
}
