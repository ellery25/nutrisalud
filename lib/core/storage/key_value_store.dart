import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over non-sensitive local key-value persistence.
/// Backed by SharedPreferences today; swappable for tests or other stores.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  bool? getBool(String key);
  Future<void> setBool(String key, bool value);
  List<String>? getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  @override
  bool? getBool(String key) => _prefs.getBool(key);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Overridden in main() with the real instance after async init.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);
