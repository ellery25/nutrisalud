import 'package:nutrisalud/core/storage/key_value_store.dart';

/// In-memory store for tests.
class FakeKeyValueStore implements KeyValueStore {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;
  @override
  Future<void> setString(String key, String value) async => _data[key] = value;
  @override
  bool? getBool(String key) => _data[key] as bool?;
  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;
  @override
  List<String>? getStringList(String key) =>
      (_data[key] as List?)?.cast<String>();
  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
}
