import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../constants/constants.dart';
import '../providers/shared_preference_builder.dart';

/// Stores/fetches receipt PDFs in Cloudflare R2 via backend-issued presigned
/// URLs. The app never holds R2 credentials.
class R2Receipts {
  static Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${SharedPrefrenceBuilder.getUserToken}',
        'Content-Type': 'application/json',
      };

  /// Upload [pdfBytes] and return the stored object key, or null on failure.
  static Future<String?> upload({
    required Uint8List pdfBytes,
    required String type, // 'rent' | 'service'
    required int month,
    required int year,
  }) async {
    try {
      final presign = await SafeHttp.post(
        Uri.parse(Constants.RECEIPT_PRESIGN_UPLOAD),
        headers: _authHeaders,
        body: jsonEncode({'type': type, 'month': month, 'year': year}),
      );
      final data = jsonDecode(presign.body);
      if (data is! Map || data['status'] != true) return null;
      final key = data['key'] as String;
      final uploadUrl = data['upload_url'] as String;

      final put = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'application/pdf'},
        body: pdfBytes,
      );
      if (put.statusCode >= 200 && put.statusCode < 300) {
        log('receipt stored: $key', name: 'R2');
        return key;
      }
      log('R2 PUT failed ${put.statusCode}: ${put.body}', name: 'R2');
      return null;
    } catch (e) {
      log('R2 upload error: $e', name: 'R2');
      return null;
    }
  }

  /// Presigned GET URL for a stored receipt, or null on failure.
  static Future<String?> downloadUrl(String key) async {
    try {
      final res = await SafeHttp.post(
        Uri.parse(Constants.RECEIPT_PRESIGN_DOWNLOAD),
        headers: _authHeaders,
        body: jsonEncode({'key': key}),
      );
      final data = jsonDecode(res.body);
      if (data is Map && data['status'] == true) {
        return data['download_url'] as String;
      }
      return null;
    } catch (e) {
      log('R2 download-url error: $e', name: 'R2');
      return null;
    }
  }
}
