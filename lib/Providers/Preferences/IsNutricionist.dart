import 'package:shared_preferences/shared_preferences.dart';

class isNutricionist {

  late SharedPreferences _prefs;

  isNutricionist._(this._prefs);

  static Future<isNutricionist> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return isNutricionist._(prefs);
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