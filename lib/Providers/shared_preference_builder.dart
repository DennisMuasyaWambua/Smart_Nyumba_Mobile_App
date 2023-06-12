import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;
  static const useremail = 'email';
  static const Token = 'token';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setUserEmail(String email) async {
    await _preferences!.setString(useremail, email);
  }

  static Future setUserToken(String token) async {
    await _preferences!.setString(Token, token);
  }

  String? get getUserToken  {
    return _preferences!.getString(Token);
  }

  String? get getUserEmail {
    return _preferences!.getString(useremail);
  }

  static void removePreferences(String key) async {
    await _preferences!.remove(key);
  }
}
