import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceBuilder {
  static SharedPreferences? _preferences;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // The auth token lives in secure storage; an in-memory copy keeps the
  // existing synchronous getUserToken API working.
  static String? _cachedToken;

  /// Fired after a new auth token is stored (i.e. on every successful login).
  /// main.dart wires this to register the device for push notifications,
  /// keeping this storage layer free of any push/Firebase dependency.
  static void Function()? onTokenSet;

  /// Fired when the session is cleared (logout / 401). main.dart wires this to
  /// drop the device's push token so notifications stop for this device.
  static void Function()? onTokenCleared;

  static const useremail = 'email';
  static const userToken = 'token';
  static const userRole = 'role';
  static const userFirstName = 'first_name';
  static const userLastName = 'last_name';
  static const id = 'user_id';
  static const tokenEpirationTime = 'expiration_time';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();

    // Migrate any token stored in plain SharedPreferences by older app
    // versions into secure storage.
    final legacyToken = _preferences!.getString(userToken);
    if (legacyToken != null) {
      await _secureStorage.write(key: userToken, value: legacyToken);
      await _preferences!.remove(userToken);
    }

    _cachedToken = await _secureStorage.read(key: userToken);
  }

  static Future setUserEmail(String email) async {
    await _preferences!.setString(useremail, email);
  }

  static Future setUserID(int uid) async {
    await _preferences!.setInt(id, uid);
  }

  static Future setUserToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: userToken, value: token);
    onTokenSet?.call();
  }

  static Future setUserRole(String role) async {
    await _preferences!.setString(userRole, role);
  }

  static Future setUserFirstName(String firstName) async {
    await _preferences!.setString(userFirstName, firstName);
  }

  static Future setUserLastName(String lastName) async {
    await _preferences!.setString(userLastName, lastName);
  }

  static Future setExpirationTime(DateTime expirationTime) async {
    await _preferences!.setString(tokenEpirationTime, expirationTime.toIso8601String());
  }

  static int? get getuserID {
    return _preferences!.getInt(id);
  }

  static String? get getUserToken {
    return _cachedToken;
  }

  static String? get getUserRole {
    return _preferences!.getString(userRole);
  }

  static String? get getUserFirstName {
    return _preferences!.getString(userFirstName);
  }

  static String? get getUserLastName {
    return _preferences!.getString(userLastName);
  }

  static String? get getUserEmail {
    return _preferences!.getString(useremail);
  }

  static String? get getExpirationTime {
    return _preferences!.getString(tokenEpirationTime);
  }

  static void clearInvalidToken() async {
    // Drop the push token first, while the auth token is still available for
    // the best-effort backend unregister call.
    onTokenCleared?.call();
    _cachedToken = null;
    await _secureStorage.delete(key: userToken);
    await _preferences!.remove(SharedPrefrenceBuilder.userRole);
    await _preferences!.remove(SharedPrefrenceBuilder.tokenEpirationTime);
  }

  static void removePreferences(String key) async {
    await _preferences!.remove(key);
  }
}
