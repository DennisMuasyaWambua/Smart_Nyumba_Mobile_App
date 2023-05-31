import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static void setKey(String key, String value) async {
    init();
    await _preferences!.setString(key, value);
  }

  static  getKey(String key) async {
    init();
    await _preferences!.getString(key);

  }

  static void removePreferences(String key) async {
    init();
    await _preferences!.remove(key);
  }
}
