import 'dart:convert';
import 'dart:developer';

import '../api/api_client.dart';
import '../constants/constants.dart';

/// Drives the universal forgot-password flow:
/// 1. [requestOtp] — email → server sends a reset OTP
/// 2. [verifyOtp]  — email + otp → validates the code
/// 3. [setNewPassword] — email + new password → resets it
class PasswordResetProvider {
  Future<({bool ok, String message})> _post(
      String url, Map<String, String> body, String fallbackOk) async {
    try {
      final res = await ApiClient.post(url, body: body, auth: false);
      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
      final ok = res.statusCode >= 200 && res.statusCode < 300 &&
          (data['status'] == true || data['status'] == null);
      return (
        ok: ok,
        message: (data['message'] ?? (ok ? fallbackOk : 'Something went wrong'))
            .toString(),
      );
    } catch (e) {
      log(e.toString(), name: 'PasswordResetProvider');
      return (ok: false, message: 'Network error. Please try again.');
    }
  }

  Future<({bool ok, String message})> requestOtp(String email) =>
      _post(Constants.USER_FORGOT_PASSWORD, {'email': email},
          'A reset code has been sent to your email.');

  Future<({bool ok, String message})> verifyOtp(String email, String otp) =>
      _post(Constants.USER_VERIFY_RESET_OTP, {'email': email, 'otp': otp},
          'Code verified.');

  Future<({bool ok, String message})> setNewPassword(
          String email, String newPassword, String confirmPassword) =>
      _post(
          Constants.USER_NEW_PASSWORD,
          {
            'email': email,
            'new_password': newPassword,
            'confirm_new_password': confirmPassword,
          },
          'Password reset successfully.');
}
