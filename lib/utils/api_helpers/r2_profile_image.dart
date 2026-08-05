import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../providers/shared_preference_builder.dart';

/// Stores/fetches the user's profile picture in Cloudflare R2 via backend-issued
/// presigned URLs. The app never holds R2 credentials.
class R2ProfileImage {
  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${SharedPrefrenceBuilder.getUserToken}',
        'Content-Type': 'application/json',
      };

  /// Upload [jpegBytes] as the caller's profile picture. Returns true on success.
  static Future<bool> upload(Uint8List jpegBytes) async {
    try {
      final presign = await SafeHttp.post(
        Uri.parse(Constants.PROFILE_IMAGE_PRESIGN_UPLOAD),
        headers: _authHeaders,
        body: jsonEncode({}),
      );
      // ignore: avoid_print
      print('R2DBG presign status=${presign.statusCode} body=${presign.body}');
      final data = jsonDecode(presign.body);
      if (data is! Map || data['status'] != true) {
        return false;
      }
      final uploadUrl = data['upload_url'] as String;

      // ignore: avoid_print
      print('R2DBG upload_url=$uploadUrl');
      final put = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'image/jpeg'},
        body: jpegBytes,
      );
      final ok = put.statusCode >= 200 && put.statusCode < 300;
      // ignore: avoid_print
      print('R2DBG PUT status=${put.statusCode} bytes=${jpegBytes.length} '
          'body=${put.body}');
      return ok;
    } catch (e) {
      // ignore: avoid_print
      print('R2DBG upload EXCEPTION: $e');
      return false;
    }
  }

  /// Presigned GET URL for the caller's profile picture, or null if none.
  static Future<String?> imageUrl() async {
    try {
      final res = await ApiClient.get(Constants.PROFILE_IMAGE);
      final data = jsonDecode(res.body);
      if (data is Map && data['status'] == true) {
        return data['image_url'] as String?;
      }
      return null;
    } catch (e) {
      log('R2 profile image-url error: $e', name: 'R2');
      return null;
    }
  }
}
