import 'package:shared_preferences/shared_preferences.dart';

class UserPersistence {

  late SharedPreferences _prefs;

  UserPersistence._(this._prefs);

  static Future<UserPersistence> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return UserPersistence._(prefs);
  }

  Future<void> saveUser(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String getUser(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setUser(String key, String newValue) async {
    await _prefs.setString(key, newValue);
  }
}