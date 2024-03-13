import 'package:shared_preferences/shared_preferences.dart';

class FirsTimePreferences {
  static const String _firstTimeKey = 'firstTime';

  static Future<void> setFirstTime(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
  }

  static Future<bool?> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey);
  }
}
