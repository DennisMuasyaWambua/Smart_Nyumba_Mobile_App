import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;
  static const useremail = 'email';
  static const userToken = 'token';
  static const userRole = 'role';
  static const id = 'user_id';
  static const tokenEpirationTime = 'expiration_time';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setUserEmail(String email) async {
    await _preferences!.setString(useremail, email);
  }

  static Future setUserID(int uid) async {
    await _preferences!.setInt(id, uid);
  }

  static Future setUserToken(String token) async {
    await _preferences!.setString(userToken, token);
  }

  static Future setUserRole(String role) async {
    await _preferences!.setString(userRole, role);
  }

  static Future setExpirationTime(DateTime expirationTime) async {
    await _preferences!.setString(tokenEpirationTime, expirationTime.toIso8601String());
  }

  static int? get getuserID {
    return _preferences!.getInt(id);
  }

  static String? get getUserToken {
    return _preferences!.getString(userToken);
  }

  static String? get getUserRole {
    return _preferences!.getString(userRole);
  }

  static String? get getUserEmail {
    return _preferences!.getString(useremail);
  }

  static String? get getExpirationTime {
    return _preferences!.getString(tokenEpirationTime);
  }

  static void clearInvalidToken() async {
    await _preferences!.remove(SharedPrefrenceBuilder.userToken);
    await _preferences!.remove(SharedPrefrenceBuilder.userRole);
    await _preferences!.remove(SharedPrefrenceBuilder.tokenEpirationTime);
  }

  static void removePreferences(String key) async {
    await _preferences!.remove(key);
  }
}
