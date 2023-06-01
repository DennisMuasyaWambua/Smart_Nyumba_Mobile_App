import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;
  static const useremail = 'email';
  static const token = 'token';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setUserEmail(String email)async {
    await _preferences!.setString(useremail,email);
  }

  String? get getUserEmail {
    return _preferences!.getString(useremail);
  }

  static void removePreferences(String key) async {
    await _preferences!.remove(key);
  }
}
