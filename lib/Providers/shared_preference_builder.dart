import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;
  static const useremail = 'email';
  static const Token = 'token';
  static const  id = 'user_id';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setUserEmail(String email) async {
    await _preferences!.setString(useremail, email);
  }

  static Future setUserID(int UID) async {
    await _preferences!.setInt(id, UID );
  }

  static Future setUserToken(String token) async {
    await _preferences!.setString(Token, token);
  }

  int? get getuserID {
    return _preferences!.getInt(id);
  }

  String? get getUserToken {
    return _preferences!.getString(Token);
  }

  String? get getUserEmail {
    return _preferences!.getString(useremail);
  }

  static void removePreferences(String key) async {
    await _preferences!.remove(key);
  }
}
