import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  //sets
  static Future<bool> setLoggedIn(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setToken(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setFullName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setEmpID(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setLoginID(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setDBName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setCompanyName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setBranchID(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setBranchName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> seBranchName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setWeighLocationID(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setWeighLocationName(String key, String value) async =>
      await _prefs.setString(key, value);

  //getsuserName
  static bool? getLoggedIn(String key) => _prefs.getBool(key);

  static String? getToken(String key) => _prefs.getString(key);

  static String? getFullName(String key) => _prefs.getString(key);

  static String? getEmpID(String key) => _prefs.getString(key);
  static String? getLoginID(String key) => _prefs.getString(key);
  static String? getDBName(String key) => _prefs.getString(key);

  static String? getCompanyName(String key) => _prefs.getString(key);

  static int? getBranchID(String key) => _prefs.getInt(key);
  static String? getBranchName(String key) => _prefs.getString(key);

  static String? getWeighLocationID(String key) => _prefs.getString(key);
  static String? getWeighLocationName(String key) => _prefs.getString(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
