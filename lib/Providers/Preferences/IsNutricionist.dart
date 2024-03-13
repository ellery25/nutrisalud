import 'package:shared_preferences/shared_preferences.dart';

class IsNutricionist {
  late SharedPreferences _prefs;

  IsNutricionist._(this._prefs);

  static Future<IsNutricionist> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return IsNutricionist._(prefs);
  }

  Future<void> saveIsNutricionist(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getIsNutricionist(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setIsNutricionist(String key, bool newValue) async {
    await _prefs.setBool(key, newValue);
  }
}
