import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../constants/constants.dart';
import 'shared_preference_builder.dart';

/// Self-service account actions shared by every role: editing your own
/// profile and changing your own password.
class AccountSettingsProvider extends ChangeNotifier {
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Returns null on success or an error message on failure.
  Future<String?> updateProfile({
    String? firstName,
    String? lastName,
    String? mobileNumber,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await ApiClient.post(
        Constants.UPDATE_MY_PROFILE,
        body: {
          if (firstName != null && firstName.isNotEmpty)
            'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
          if (mobileNumber != null && mobileNumber.isNotEmpty)
            'mobile_number': mobileNumber,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final profile = data['profile'];
        if (profile != null) {
          if (profile['first_name'] != null) {
            SharedPrefrenceBuilder.setUserFirstName(profile['first_name']);
          }
          if (profile['last_name'] != null) {
            SharedPrefrenceBuilder.setUserLastName(profile['last_name']);
          }
        }
        return null;
      }
      return data['message'] ?? 'Could not update profile';
    } catch (e) {
      log(e.toString(), name: 'AccountSettingsProvider.updateProfile');
      return 'Could not update profile. Check your connection.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Returns null on success or an error message on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await ApiClient.post(
        Constants.CHANGE_MY_PASSWORD,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return null;
      }
      return data['message'] ?? 'Could not change password';
    } catch (e) {
      log(e.toString(), name: 'AccountSettingsProvider.changePassword');
      return 'Could not change password. Check your connection.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
